# 📄 SPEC TÉCNICO — Visualización de Productos en Grilla

## 🎯 Objetivo

Mostrar un listado de productos en formato **grilla**, incluyendo:

* Imagen del producto
* Título
* Precio mock visual (placeholder de UI)
* Cantidad de reviews
* Rating promedio (1–5)

La UI debe basarse en el diseño definido en `appReferenceUI`.

---

## 🧩 Requisitos Funcionales

1. Mostrar productos en formato **grid (2 columnas)**
2. Cada celda debe contener:

   * Imagen (URL remota)
   * Título
   * Cantidad de reviews
   * Rating promedio (calculado)
3. Permitir persistencia local de los productos (cache)
4. Cargar datos desde almacenamiento local si existen
5. Refrescar datos desde API después de mostrar cache local (flujo cache → API)

---

## 🧮 Cálculo de Rating Promedio

rating_{avg} = \frac{\sum_{i=1}^{n} rating_i}{n}

### Reglas:

* Si `reviews = []` → `averageRating = 0.0`
* Redondear a 1 decimal
* Rango válido: 0.0 – 5.0

---

## 🧱 Arquitectura (Hexagonal)

### 🔷 Dominio

```swift
struct Product: Codable {
    let id: Int
    let title: String
    let image: String
    let reviews: [Review]
    
    var reviewCount: Int {
        reviews.count
    }
    
    var averageRating: Double {
        guard !reviews.isEmpty else { return 0.0 }
        let total = reviews.reduce(0) { $0 + $1.rating }
        let average = Double(total) / Double(reviews.count)
        return (average * 10).rounded() / 10
    }
}

struct Review: Codable {
    let author: String
    let rating: Int
    let text: String
}
```

---

### 🔷 Puertos

```swift
protocol ProductRepository {
    func fetchProducts() -> AnyPublisher<[Product], Error>
    func saveProducts(_ products: [Product])
    func loadLocalProducts() -> [Product]
}
```

---

### 🔷 Casos de Uso

```swift
final class GetProductsUseCase {
    private let repository: ProductRepository
    init(repository: ProductRepository) {
        self.repository = repository
    }
    func execute() -> AnyPublisher<[Product], Error> {
        repository.fetchProducts()
    }
}

final class LoadCachedProductsUseCase {
    private let repository: ProductRepository
    init(repository: ProductRepository) {
        self.repository = repository
    }
    func execute() -> [Product] {
        repository.loadLocalProducts()
    }
}
```

---

## 💾 Persistencia

* Uso de `FileProductLocalStore` (JSON en `cachesDirectory`)
* Guardar después de consumo exitoso
* Cargar en inicio o sin conexión

---

## 🎨 Presentación (UI)

* Basada en `appReferenceUI`
* Layout tipo **grid**
* Scroll vertical
* Celdas uniformes
* `ContentView` solo orquesta estados y navegación
* Vistas desacopladas en carpeta `Views/`

### Componentes UI actuales

* `ProductsGridView` (grilla 2 columnas)
* `ProductCardView` (imagen, título, precio mock, rating y reseñas)
* `StarRatingView` (componente reutilizable para estrellas)
* `ProductEmptyStateView`
* `ProductErrorStateView`
* `ProductErrorBannerView`

---

## 🔄 ViewModel

```swift
final class ProductViewModel: ObservableObject {
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    
    private let getProductsUseCase: GetProductsUseCase
    private let loadCachedProductsUseCase: LoadCachedProductsUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(getProductsUseCase: GetProductsUseCase,
         loadCachedProductsUseCase: LoadCachedProductsUseCase) {
        self.getProductsUseCase = getProductsUseCase
        self.loadCachedProductsUseCase = loadCachedProductsUseCase
    }
    
    func load() {
        let localProducts = loadCachedProductsUseCase.execute()
        if !localProducts.isEmpty {
            products = localProducts
        }
        
        error = nil
        isLoading = true
        
        getProductsUseCase.execute()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let err) = completion {
                    self?.error = err.localizedDescription
                }
            }, receiveValue: { [weak self] products in
                self?.error = nil
                self?.products = products
            })
            .store(in: &cancellables)
    }
}
```

---

## 🧪 Tests Unitarios (REQUERIDO)

### 🎯 Objetivo

Garantizar la correcta lógica de negocio, cálculo y flujo de datos.

---

### ✅ Casos a cubrir

#### 🔹 Dominio

* [x] Cálculo correcto de `averageRating`
* [x] Manejo de lista vacía (`reviews = []`)
* [x] Conteo correcto de reviews

---

#### 🔹 Use Cases

* [x] `GetProductsUseCase` retorna datos correctamente
* [x] Manejo de error en fetch
* [x] `LoadCachedProductsUseCase` retorna datos persistidos

---

#### 🔹 Repositorio (Mock)

* [x] Simulación de respuesta exitosa
* [x] Simulación de error
* [x] Validación de guardado local

---

#### 🔹 ViewModel

* [x] Estado inicial correcto
* [x] Actualización de `products`
* [x] Manejo de error
* [x] Flujo: cache → API
* [x] Carga de cache sin bloquear refresh remoto

---

### 🧪 Ejemplo

```swift
func testAverageRating() {
    let reviews = [
        Review(author: "A", rating: 5, text: ""),
        Review(author: "B", rating: 3, text: "")
    ]
    
    let product = Product(id: 1, title: "Test", image: "", reviews: reviews)
    
    XCTAssertEqual(product.averageRating, 4.0)
}
```

---

### 🧱 Buenas prácticas

* Uso de **mocks** para `ProductRepository`
* No depender de red real
* Tests rápidos y aislados
* Cobertura mínima sugerida: **80%**

---

## ⚠️ Estados de UI

* Loading
* Empty
* Error
* Data
* Data + Error Banner (cuando existe data cacheada y falla refresh)

---

## 🚀 Criterios de Aceptación

* [x] Grid funcional
* [x] Datos correctos (imagen, título, precio visual, rating, reviews)
* [x] Persistencia funcionando
* [x] UI basada en `appReferenceUI`
* [x] Vistas desacopladas en `Views/`
* [x] Componente `StarRatingView` reutilizable integrado en cards
* [x] Tests unitarios implementados
* [x] Cobertura mínima alcanzada
* [x] Buen rendimiento con 100+ productos

---
