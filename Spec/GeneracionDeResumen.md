# 📄 SPEC TÉCNICO — Generación de Resumen de Reviews con AI On-Device

## 🎯 Objetivo

Permitir generar un **resumen inteligente de las reviews de un producto** usando capacidades de **AI on-device**, sin depender de servicios cloud.

El resumen debe incluir:

* Sentimiento general (positivo, neutro, negativo)
* Puntos fuertes
* Puntos débiles
* Frase resumen (1 línea)

---

## 🧩 Requisitos Funcionales

1. Cada producto tendrá un botón:

   ```text
   "Generar resumen"
   ```

2. El botón:

   * ✅ Solo se muestra si `reviews.count > 5`
   * ❌ No se muestra si ≤ 5 reviews

3. Al presionar:

   * Genera resumen usando AI on-device
   * Muestra loading mientras procesa
   * Renderiza resultado estructurado

4. Si ya existe resumen:

   * Mostrar resumen persistido
   * Mostrar botón:

     ```text
     "Regenerar resumen"
     ```

---

## 🧠 Estructura del Resumen

```swift 
struct ReviewSummary {
    let sentiment: Sentiment
    let strengths: [String]
    let weaknesses: [String]
    let summary: String
}

enum Sentiment {
    case positive
    case neutral
    case negative
}
```

---

## 🧱 Arquitectura (Hexagonal)

### 🔷 Dominio

```swift 
struct Product {
    let id: Int
    let title: String
    let reviews: [Review]
    var summary: ReviewSummary?
}
```

---

### 🔷 Puertos

```swift 
protocol ReviewSummaryGenerator {
    func generateSummary(from reviews: [Review]) async throws -> ReviewSummary
}

protocol SummaryRepository {
    func saveSummary(_ summary: ReviewSummary, for productId: Int)
    func loadSummary(for productId: Int) -> ReviewSummary?
}
```

---

### 🔷 Casos de Uso

```swift 
final class GenerateReviewSummaryUseCase {
    
    private let generator: ReviewSummaryGenerator
    private let repository: SummaryRepository
    
    init(generator: ReviewSummaryGenerator,
         repository: SummaryRepository) {
        self.generator = generator
        self.repository = repository
    }
    
    func execute(product: Product) async throws -> ReviewSummary {
        
        if let cached = repository.loadSummary(for: product.id) {
            return cached
        }
        
        let summary = try await generator.generateSummary(from: product.reviews)
        repository.saveSummary(summary, for: product.id)
        
        return summary
    }
}

final class RegenerateReviewSummaryUseCase {
    
    private let generator: ReviewSummaryGenerator
    private let repository: SummaryRepository
    
    init(generator: ReviewSummaryGenerator,
         repository: SummaryRepository) {
        self.generator = generator
        self.repository = repository
    }
    
    func execute(product: Product) async throws -> ReviewSummary {
        let summary = try await generator.generateSummary(from: product.reviews)
        repository.saveSummary(summary, for: product.id)
        return summary
    }
}
```

---

## 🤖 AI On-Device (REQUERIDO)

### Restricciones

* ❌ NO usar APIs cloud:

  * OpenAI
  * Gemini
  * Claude
* ✅ Solo procesamiento local

---

### Opciones válidas en iOS

* Foundation Models framework (recomendado), con fallback heurístico si no está disponible

### Foundation Models: compatibilidad del sistema

* **Versión mínima del SO:** Foundation Models para generación de texto aplica en **iOS 26.0+**
* **Versiones del modelo en el SO:** Apple alinea actualizaciones del modelo con el sistema (línea **26.0–26.3** y línea **26.4+**).
* **Disponibilidad real en runtime:** además del SO, hay que validar:
  * dispositivo elegible para Apple Intelligence;
  * Apple Intelligence activada en Ajustes;
  * modelo listo (por ejemplo descargado y disponible).
* **Validación obligatoria en app:** comprobar `SystemLanguageModel.default.availability` (o `isAvailable`) antes de crear `LanguageModelSession`; si no está disponible, usar el **fallback heurístico**.

#### Nota de implementación (`@Generable`)

* `@Generable(description:)` está disponible solo en **iOS 26.0+**.
* Para mantener compatibilidad con targets menores:
  * marcar tipos generables con `@available(iOS 26.0, *)`;
  * preferir `@Generable` simple en tipos compartidos fuera de bloques totalmente iOS 26+.

---

### Estrategia

1. Concatenar reviews en un solo texto
2. Limitar tamaño (ej: top 20 reviews)
3. Prompt estructurado:

```text 
Analiza las siguientes opiniones de usuarios y genera:

1. Sentimiento general (positivo, neutro o negativo)
2. 3 puntos fuertes
3. 3 puntos débiles
4. Una frase resumen de máximo 20 palabras

Opiniones:
{reviews}
```

---

### Adapter AI

```swift 
final class OnDeviceSummaryGenerator: ReviewSummaryGenerator {
    
    func generateSummary(from reviews: [Review]) async throws -> ReviewSummary {
        let text = reviews.map { $0.text }.joined(separator: "\n")
        
        // Integración con Foundation Models (fallback heurístico)
        // Procesar texto y mapear respuesta
        
        return ReviewSummary(
            sentiment: .positive,
            strengths: ["Buena calidad"],
            weaknesses: ["Precio alto"],
            summary: "Producto bien valorado con algunos detalles de costo."
        )
    }
}
```

---

## 💾 Persistencia

### Estrategia

* Persistir resumen por `productId`
* Usar:

  * CachesDirectory
  * o base local equivalente

### Reglas

* Guardar después de generación
* Leer antes de generar
* Permitir sobrescritura en regeneración

---

## 🎨 UI / UX

### Comportamiento

* Botón visible solo si `reviews.count > 5`
* Estados:

  * Idle → botones **Generar resumen** / **Regenerar resumen** (según exista cache en memoria)
  * Loading → spinner en la tarjeta
  * Success → el resumen **no** se muestra inline en la grilla; se presenta en un **modal** (sheet)
  * Error → mensaje de error en la tarjeta y reintento vía el mismo flujo de generación

### Modal de resumen (referencia visual)

* Diseño alineado con `imgReferences/ModalResumen.png`:
  * Título **RESUMEN DE RESEÑAS** y cierre circular (X)
  * Bloque **SENTIMIENTO GENERAL** con gráfico circular (verde / naranja / rojo) y titular según `Sentiment`
  * **PUNTOS FUERTES** (👍) y **PUNTOS DÉBILES** (👎) como listas con viñetas
  * **FRASE RESUMEN** entre comillas tipográficas
  * CTA inferior a ancho completo: **VER TODAS LAS RESEÑAS** (cierra el modal; punto de extensión para navegar al listado de reseñas)
* Implementación: `Views/ReviewSummaryModalView.swift`
* Presentación desde la tarjeta: `Views/ProductCardView.swift` con `.sheet` y detents (fracción + large), apertura automática al terminar la carga exitosa y enlace **Ver resumen** si ya existe resumen

### Componentes UI relacionados

* `ProductCardView` — acciones de resumen y presentación del sheet
* `ProductsGridView` — pasa estado de summaries / loading / errores al grid
* `ReviewSummaryModalView` — layout del modal descrito arriba

---

## 🔄 ViewModel

```swift 
@MainActor
final class ProductViewModel: ObservableObject {
    
    @Published var summaries: [Int: ReviewSummary] = [:]
    @Published var loadingIds: Set<Int> = []
    
    private let generateUseCase: GenerateReviewSummaryUseCase
    private let regenerateUseCase: RegenerateReviewSummaryUseCase
    
    init(generateUseCase: GenerateReviewSummaryUseCase,
         regenerateUseCase: RegenerateReviewSummaryUseCase) {
        self.generateUseCase = generateUseCase
        self.regenerateUseCase = regenerateUseCase
    }
    
    func generateSummary(_ product: Product) async {
        loadingIds.insert(product.id)
        
        do {
            let summary = try await generateUseCase.execute(product: product)
            summaries[product.id] = summary
        } catch {
            print(error)
        }
        
        loadingIds.remove(product.id)
    }
}
```

---

## 🧪 Tests Unitarios (REQUERIDO)

### 🎯 Cobertura mínima

* ≥ 80%

---

### ✅ Casos a cubrir

#### 🔹 Use Cases

* [x] Genera resumen correctamente
* [x] Usa cache cuando existe
* [x] Regenera correctamente (sobrescribe)

---

#### 🔹 Repositorio

* [x] Guarda resumen
* [x] Recupera resumen por `productId`

---

#### 🔹 AI Generator (Mock)

* [x] Retorna estructura válida
* [x] Maneja errores

---

#### 🔹 ViewModel

* [x] Manejo de loading
* [x] Actualización de estado
* [x] Manejo de error

---

### 🧪 Ejemplo

```swift
func testUsesCachedSummary() async throws {
    let repo = MockSummaryRepository()
    let generator = MockGenerator()
    
    repo.stubSummary = ReviewSummary(...)
    
    let useCase = GenerateReviewSummaryUseCase(generator: generator, repository: repo)
    
    let result = try await useCase.execute(product: Product(...))
    
    XCTAssertEqual(result.summary, repo.stubSummary.summary)
}
```

---

## 🔐 Seguridad

* No enviar datos fuera del dispositivo
* No almacenar texto sensible sin cifrado (si aplica)
* Limitar tamaño de input al modelo

---

## 🚀 Criterios de Aceptación

* [x] Botón visible solo con >5 reviews
* [x] Generación de resumen funcional
* [x] Resumen mostrado en modal acorde a `imgReferences/ModalResumen.png` (`ReviewSummaryModalView` + sheet desde `ProductCardView`)
* [x] Uso exclusivo de AI on-device
* [x] Persistencia local implementada
* [x] Opción de regenerar disponible
* [x] Tests unitarios ≥ 80%
* [x] Buen performance (respuesta < 2s aprox)


