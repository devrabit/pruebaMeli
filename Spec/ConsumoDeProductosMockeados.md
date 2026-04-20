# 📄 SPEC TÉCNICO — Consumo de Productos Mockeados con Proxyman

## 🎯 Objetivo

Implementar el consumo de un listado de **100+ productos** desde una API REST mockeada en entorno local utilizando Proxyman.
Cada producto contiene:

* `image` (URL)
* `title` (String)
* `reviews` (0 a 20 elementos)

  * `author` (String)
  * `rating` (Int: 1–5)
  * `text` (String)

---

## 🧩 Requisitos Funcionales

1. Consumir endpoint `/products`
2. Mostrar listado de productos
3. Cada producto debe reflejar correctamente:

   * Imagen
   * Título
   * Cantidad de reviews
4. Manejar:

   * Lista vacía
   * Error de red
   * Latencia simulada

---

## ⚙️ Requisitos Técnicos

### 1. Configuración de entorno

* Se debe utilizar **Proxyman** con `Map Local`
* La API debe apuntar a:

```
http://localhost:<port>/products
```

* La **base URL debe ser configurable**, por ejemplo:

```swift
struct Environment {
    static var baseURL: String {
        return ProcessInfo.processInfo.environment["BASE_URL"] 
            ?? "http://localhost:8080"
    }
}
```

---

### 2. Uso de URLSession

* El consumo de red debe realizarse exclusivamente con `URLSession`
* No se permite Alamofire ni librerías externas

Ejemplo base:

```swift
func request<T: Decodable>(_ endpoint: String) -> AnyPublisher<T, Error> {
    guard let url = URL(string: Environment.baseURL + endpoint) else {
        return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
    }

    return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: T.self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}
```

---

### 3. Arquitectura: Hexagonal (Ports & Adapters)

#### 🔷 Dominio (Core)

**Entidades**

```swift
struct Product {
    let id: Int
    let title: String
    let image: String
    let reviews: [Review]
}

struct Review {
    let author: String
    let rating: Int
    let text: String
}
```

---

#### 🔷 Puertos (Ports)

```swift
protocol ProductRepository {
    func fetchProducts() -> AnyPublisher<[Product], Error>
}
```

---

#### 🔷 Adaptadores (Adapters)

##### 🌐 API Adapter

```swift
final class ProductAPIRepository: ProductRepository {

    private let network: NetworkClient

    init(network: NetworkClient) {
        self.network = network
    }

    func fetchProducts() -> AnyPublisher<[Product], Error> {
        network.request("/products")
    }
}
```

---

#### 🔷 Infraestructura

```swift
protocol NetworkClient {
    func request<T: Decodable>(_ endpoint: String) -> AnyPublisher<T, Error>
}
```

```swift
final class URLSessionNetworkClient: NetworkClient {
    func request<T>(_ endpoint: String) -> AnyPublisher<T, Error> where T : Decodable {
        guard let url = URL(string: Environment.baseURL + endpoint) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
```

---

#### 🔷 Aplicación (Use Case)

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
```

---

#### 🔷 Presentación (ViewModel)

```swift
final class ProductViewModel: ObservableObject {

    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var error: String?

    private let useCase: GetProductsUseCase
    private var cancellables = Set<AnyCancellable>()

    init(useCase: GetProductsUseCase) {
        self.useCase = useCase
    }

    func load() {
        isLoading = true

        useCase.execute()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let err) = completion {
                    self?.error = err.localizedDescription
                }
            }, receiveValue: { [weak self] products in
                self?.products = products
            })
            .store(in: &cancellables)
    }
}
```

---

## 🔐 Seguridad

* ❌ No hardcodear API Keys
* ❌ No almacenar datos sensibles en texto plano
* ✅ Uso de `http://localhost` permitido únicamente para desarrollo
* ✅ En producción usar HTTPS obligatorio
* ✅ Separación de configuración por entorno

---

## 🧪 Mocking con Proxyman

Los fixtures HTTP viven fuera de `Spec/` (solo documentación) para mantener **cohesión por dominio**:

```
Mocks/
└── Products/
    └── list.json    # cuerpo de respuesta sugerido para GET /products (100+ ítems)
```

* Endpoint interceptado:

```
GET /products
```

* Respuesta:

  * En Proxyman **Map Local**, apunta el cuerpo al archivo `Mocks/Products/list.json` (array JSON con 100+ productos).
  * Variación de:

    * `reviews: []`
    * `reviews: [0...20]`

* Se recomienda simular:

  * Delay (1–3s)
  * HTTP 500
  * Empty state

---

## 📊 Consideraciones de Performance

* Uso de `List` o `LazyVStack` para listas grandes
* Evitar procesamiento pesado en el main thread
* Lazy loading de imágenes (`AsyncImage`)

---

## 🧠 Buenas Prácticas

* Inyección de dependencias
* Separación de capas (Hexagonal)
* Testabilidad del `UseCase`
* Reutilización del `NetworkClient`

---

## 🚀 Criterios de Aceptación

* [x] Se consumen correctamente 100+ productos
* [x] La base URL es configurable
* [x] Se usa `URLSession`
* [x] Se implementa arquitectura hexagonal
* [x] No hay datos sensibles hardcodeados
* [x] Funciona correctamente con Proxyman (localhost)
* [x] Manejo de errores y estados vacíos

---


