//
//  ReviewSummaryModalView.swift
//  PruebaMeli
//

import SwiftUI

struct ReviewSummaryModalView: View {
    let summary: ReviewSummary
    let onDismiss: () -> Void
    let onViewAllReviews: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    sentimentSection
                    strengthsSection
                    weaknessesSection
                    phraseSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }

            PrimaryActionButton(title: "VER TODAS LAS RESEÑAS", action: onViewAllReviews)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 16)
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text("RESUMEN DE RESEÑAS")
                .font(.system(size: 13, weight: .bold))
                .tracking(0.6)
                .foregroundStyle(.primary)

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    private var sentimentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("SENTIMIENTO GENERAL")

            HStack(alignment: .center, spacing: 16) {
                SentimentPieChart(sentiment: summary.sentiment)
                    .frame(width: 88, height: 88)

                Text(sentimentHeadline)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var strengthsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("👍")
                sectionTitle("PUNTOS FUERTES")
            }
            bulletList(summary.strengths)
        }
    }

    private var weaknessesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("👎")
                sectionTitle("PUNTOS DÉBILES")
            }
            bulletList(summary.weaknesses)
        }
    }

    private var phraseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("FRASE RESUMEN")
            Text("“\(summary.summary)”")
                .font(.system(size: 14, weight: .regular))
                .italic()
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .tracking(0.8)
            .foregroundStyle(.secondary)
    }

    private func bulletList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, line in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text(line)
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var sentimentHeadline: String {
        switch summary.sentiment {
        case .positive:
            return "Predominantemente positivo"
        case .neutral:
            return "Opiniones mixtas"
        case .negative:
            return "Mixto con tendencia negativa"
        }
    }
}

private struct SentimentPieChart: View {
    let sentiment: Sentiment

    private var segments: [(Color, Double)] {
        switch sentiment {
        case .positive:
            return [(Color.green.opacity(0.85), 0.55), (Color.orange.opacity(0.9), 0.25), (Color.red.opacity(0.85), 0.2)]
        case .neutral:
            return [(Color.green.opacity(0.85), 0.3), (Color.orange.opacity(0.9), 0.4), (Color.red.opacity(0.85), 0.3)]
        case .negative:
            return [(Color.green.opacity(0.85), 0.2), (Color.orange.opacity(0.9), 0.25), (Color.red.opacity(0.85), 0.55)]
        }
    }

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            var start = -Double.pi / 2

            for (color, fraction) in segments {
                let sweep = fraction * 2 * Double.pi
                var path = Path()
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .radians(start),
                    endAngle: .radians(start + sweep),
                    clockwise: false
                )
                path.closeSubpath()
                context.fill(path, with: .color(color))
                start += sweep
            }
        }
        .overlay {
            Circle()
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        }
    }
}
