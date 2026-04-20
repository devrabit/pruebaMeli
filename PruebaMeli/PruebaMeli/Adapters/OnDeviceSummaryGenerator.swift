//
//  OnDeviceSummaryGenerator.swift
//  PruebaMeli
//

import Foundation

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
@Generable
private enum GuidedSentiment {
    case positive
    case neutral
    case negative
}

@available(iOS 26.0, *)
@Generable
private struct GuidedReviewSummary {
    @Guide(description: "Sentimiento agregado de las reseñas")
    var sentiment: GuidedSentiment

    @Guide(description: "Hasta 3 fortalezas recurrentes (frases cortas en español)", .maximumCount(3))
    var strengths: [String]

    @Guide(description: "Hasta 3 debilidades recurrentes (frases cortas en español)", .maximumCount(3))
    var weaknesses: [String]

    @Guide(description: "Resumen en 1–2 frases en español, tono informativo")
    var summary: String
}
#endif

enum OnDeviceSummaryError: LocalizedError {
    case insufficientReviews
    case emptyReviewText

    var errorDescription: String? {
        switch self {
        case .insufficientReviews:
            return "Se requieren más reviews para generar el resumen."
        case .emptyReviewText:
            return "No hay texto suficiente para generar el resumen."
        }
    }
}

final class OnDeviceSummaryGenerator: ReviewSummaryGenerator {
    private let positiveWords = ["excelente", "bueno", "perfecto", "recomendado", "calidad", "rapido", "genial"]
    private let negativeWords = ["malo", "defectuoso", "lento", "caro", "fragil", "decepcion", "fallo"]

    func generateSummary(from reviews: [Review]) async throws -> ReviewSummary {
        guard reviews.count > 5 else {
            throw OnDeviceSummaryError.insufficientReviews
        }

        let candidateReviews = Array(reviews.prefix(20))
        let texts = candidateReviews.map(\.text).joined(separator: " ").lowercased()
        guard !texts.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OnDeviceSummaryError.emptyReviewText
        }

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            if SystemLanguageModel.default.isAvailable {
                do {
                    return try await generateWithFoundationModels(candidateReviews: candidateReviews)
                } catch {
                    // Intentional fallback to on-device heuristics.
                }
            }
        }
        #endif

        return makeHeuristicSummary(candidateReviews: candidateReviews, texts: texts)
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func generateWithFoundationModels(candidateReviews: [Review]) async throws -> ReviewSummary {
        let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)
        let session = LanguageModelSession(model: model) {
            "Eres un analista de reseñas de e-commerce. Trabaja solo con el texto de las reseñas que recibes."
            "Idioma de salida: español."
            "No inventes hechos ni puntuaciones que no aparezcan en las reseñas."
            "Si el texto es ambiguo, elige sentimiento neutral."
        }

        let body = Self.reviewTextBlock(from: candidateReviews)
        let prompt = Prompt {
            "Genera un resumen estructurado a partir de estas reseñas de producto:\n\n\(body)"
        }

        let response = try await session.respond(to: prompt, generating: GuidedReviewSummary.self)
        let guided = response.content

        let sentiment: Sentiment
        switch guided.sentiment {
        case .positive: sentiment = .positive
        case .neutral: sentiment = .neutral
        case .negative: sentiment = .negative
        }

        let strengths = guided.strengths
            .prefix(3)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let weaknesses = guided.weaknesses
            .prefix(3)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let summaryText = guided.summary.trimmingCharacters(in: .whitespacesAndNewlines)

        return ReviewSummary(
            sentiment: sentiment,
            strengths: strengths.isEmpty ? ["Sin fortalezas claras destacadas"] : Array(strengths),
            weaknesses: weaknesses.isEmpty ? ["Sin debilidades claras destacadas"] : Array(weaknesses),
            summary: summaryText.isEmpty ? "Resumen generado a partir de las reseñas." : summaryText
        )
    }

    private static func reviewTextBlock(from reviews: [Review]) -> String {
        var lines: [String] = []
        var budget = 6000
        for (index, review) in reviews.prefix(20).enumerated() {
            let trimmed = review.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            let snippet = String(trimmed.prefix(400))
            let line = "[\(index + 1)] \(snippet)"
            if line.count > budget { break }
            lines.append(line)
            budget -= line.count + 1
        }
        return lines.joined(separator: "\n")
    }
    #endif

    private func makeHeuristicSummary(candidateReviews: [Review], texts: String) -> ReviewSummary {
        let positiveHits = positiveWords.reduce(0) { $0 + texts.components(separatedBy: $1).count - 1 }
        let negativeHits = negativeWords.reduce(0) { $0 + texts.components(separatedBy: $1).count - 1 }
        let sentiment: Sentiment = positiveHits == negativeHits ? .neutral : (positiveHits > negativeHits ? .positive : .negative)

        let strengths = topTokens(from: candidateReviews, excluding: negativeWords, limit: 3)
        let weaknesses = topTokens(from: candidateReviews, excluding: positiveWords, limit: 3)
        let sentence = buildSummarySentence(sentiment: sentiment, strengths: strengths, weaknesses: weaknesses)

        return ReviewSummary(
            sentiment: sentiment,
            strengths: strengths.isEmpty ? ["Buena experiencia general"] : strengths,
            weaknesses: weaknesses.isEmpty ? ["Sin observaciones frecuentes"] : weaknesses,
            summary: sentence
        )
    }

    private func topTokens(from reviews: [Review], excluding blocked: [String], limit: Int) -> [String] {
        let stopWords: Set<String> = ["el", "la", "los", "las", "de", "del", "con", "por", "para", "muy", "que", "en", "un", "una", "es", "producto"]
        var counter: [String: Int] = [:]

        for token in reviews.map(\.text).joined(separator: " ")
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter({ $0.count > 4 }) {
            guard !stopWords.contains(token), !blocked.contains(token) else { continue }
            counter[token, default: 0] += 1
        }

        return counter
            .sorted { lhs, rhs in lhs.value == rhs.value ? lhs.key < rhs.key : lhs.value > rhs.value }
            .prefix(limit)
            .map(\.key)
    }

    private func buildSummarySentence(sentiment: Sentiment, strengths: [String], weaknesses: [String]) -> String {
        let sentimentText: String
        switch sentiment {
        case .positive: sentimentText = "valoraciones mayormente positivas"
        case .neutral: sentimentText = "opiniones mixtas"
        case .negative: sentimentText = "valoraciones con tendencia negativa"
        }

        let strengthText = strengths.first ?? "buen desempeño general"
        let weaknessText = weaknesses.first ?? "sin puntos críticos frecuentes"
        return "Predominan \(sentimentText), destacando \(strengthText), aunque aparece \(weaknessText) como oportunidad de mejora."
    }
}
