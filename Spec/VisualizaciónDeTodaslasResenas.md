# 📄 SPEC — Visualización de Todas las Reseñas en Sheet

## 🎯 Objetivo

Permitir al usuario visualizar el listado completo de reseñas de un producto mediante un **modal tipo sheet**, reutilizando componentes existentes y manteniendo consistencia visual con el diseño definido.

---

## 🧩 Escenario (BDD)

```text
Dado que existe el botón "VER TODAS LAS RESEÑAS"
Cuando el usuario hace tap sobre el botón
Entonces se muestra un sheet con el listado completo de reviews del producto
```

---

## 🧩 Requisitos Funcionales

1. En ReviewSummaryModalView existe el botón:

   ```text
   VER TODAS LAS RESEÑAS
   ```

2. Al hacer tap:

   * Presentar un **sheet modal**
   * Mostrar todas las reviews del producto

3. Cada review debe contener:

   * Autor
   * Rating (1–5)
   * Texto

4. El listado debe soportar:

   * Scroll vertical
   * Cantidad dinámica (0 a 20 reviews)

---

## 🎨 UI / UX

### Requisito obligatorio

La UI debe ser **idéntica a**:

```text
imagenes/ReviewList.png
```

---

### 📱 Comportamiento del Sheet

* Presentación tipo `.sheet`
* Soporte para swipe down (dismiss)
* Header opcional con título:

  ```text
  Reseñas
  ```

---

### 🧱 Estructura de la Vista

```swift 
struct ReviewListView: View {
    
    let reviews: [Review]
    
    var body: some View {
        VStack {
            
            Text("Reseñas")
                .font(.headline)
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(reviews.indices, id: \.self) { index in
                        ReviewRow(review: reviews[index])
                    }
                }
                .padding()
            }
        }
    }
}
```

---

## ♻️ Reutilización de Componentes

### 🔹 StarRatingView (REQUERIDO)

* Debe reutilizarse el componente existente:

```text
StarRatingView
```

---

### Uso esperado:

```swift
StarRatingView(rating: review.rating)
```

---

## 🧱 Componente ReviewRow

```swift 
struct ReviewRow: View {
    
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text(review.author)
                .font(.subheadline)
                .bold()
            
            StarRatingView(rating: review.rating)
            
            Text(review.text)
                .font(.body)
        }
    }
}
```

---

## 🔄 Integración desde Producto

```swift 
@State private var showReviews = false

Button("VER TODAS LAS RESEÑAS") {
    showReviews = true
}
.sheet(isPresented: $showReviews) {
    ReviewListView(reviews: product.reviews)
}
```

---

## ⚠️ Estados de UI

* Lista vacía:

  ```text
  "No hay reseñas disponibles"
  ```

* Lista con datos:

  * Render normal

---

## 🧪 Tests Unitarios (REQUERIDO)

### 🎯 Cobertura mínima

* ≥ 80%

---

### ✅ Casos a cubrir

#### 🔹 ViewModel (si aplica)

* [ ] Apertura del sheet
* [ ] Paso correcto de reviews

---

#### 🔹 UI

* [ ] Renderiza lista de reviews
* [ ] Muestra estado vacío
* [ ] Reutiliza `StarRatingView`

---

#### 🔹 Integración

* [ ] Tap en botón abre sheet
* [ ] Sheet recibe datos correctos

---

### 🧪 Ejemplo

```swift 
func testSheetIsPresented() {
    let viewModel = ProductViewModel(...)
    
    viewModel.showReviews = true
    
    XCTAssertTrue(viewModel.showReviews)
}
```

---

## 🧱 Arquitectura

* Mantener separación:

  * Presentación (SwiftUI)
  * Dominio (Review)
* No duplicar lógica de rating
* Reutilizar componentes existentes

---

## 🚀 Criterios de Aceptación

* [x] Botón "VER TODAS LAS RESEÑAS" visible
* [x] Tap abre sheet correctamente
* [x] UI igual a `ReviewList.png`
* [x] Uso de `StarRatingView`
* [x] Manejo de lista vacía
* [x] Scroll funcional
* [ ] Tests ≥ 80% cobertura

