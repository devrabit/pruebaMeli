# 📄 SPEC — Refactorización de Vistas a Atomic Design

## 🎯 Objetivo

Refactorizar las vistas actuales de la aplicación a una arquitectura basada en **Atomic Design**, con el fin de:

* Mejorar la reutilización de componentes
* Aumentar la mantenibilidad
* Reducir duplicación de código
* Facilitar testing y escalabilidad

---

## 🧩 Alcance

* Todas las vistas de presentación (SwiftUI)
* Componentes UI reutilizables
* Estructura de carpetas
* Integración con ViewModels existentes

---

## 🧱 Definición de Atomic Design

Se deben organizar los componentes en 5 niveles:

```text
Atoms → Molecules → Organisms → Templates → Pages
```

---

## 🧬 Estructura de Carpetas

```bash 
UI/
 ├── Atoms/
 ├── Molecules/
 ├── Organisms/
 ├── Templates/
 └── Views/
```

---

## 🔹 1. Atoms (Componentes básicos)

### Definición

Elementos UI más pequeños y reutilizables.
No deben tener lógica de negocio.

---

### Ejemplos

```swift 
TextLabel
PrimaryButton
AsyncImageView
StarRatingView
```

---

### Reglas

* Sin dependencias externas
* Configuración vía props
* Sin estado complejo

---

### Ejemplo

```swift 
struct StarRatingView: View {
    let rating: Int
    
    var body: some View {
        HStack {
            ForEach(0..<5) { index in
                Image(systemName: index < rating ? "star.fill" : "star")
            }
        }
    }
}
```

---

## 🔸 2. Molecules (Combinación de atoms)

### Definición

Agrupación de atoms con una responsabilidad específica.

---

### Ejemplos

```swift 
ReviewRowView
ProductInfoView
```

---

### Ejemplo

```swift 
struct ReviewRowView: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(review.author)
            StarRatingView(rating: review.rating)
            Text(review.text)
        }
    }
}
```

---

## 🔶 3. Organisms (Componentes complejos)

### Definición

Secciones completas de UI compuestas por múltiples molecules.

---

### Ejemplos

```swift 
ProductGridView
ReviewListView
```

---

### Responsabilidades

* Layout completo
* Manejo de estados UI (loading, empty)
* Integración con ViewModel (limitado)

---

## 🔷 4. Templates (Estructura de pantalla)

### Definición

Define la estructura de una pantalla sin datos concretos.

---

### Ejemplo

```swift
struct ProductGridTemplate: View {
    
    let products: [Product]
    
    var body: some View {
        ScrollView {
            ProductGridView(products: products)
        }
    }
}
```

---

## 🔵 5. Pages (Pantallas finales)

### Definición

Pantallas conectadas a lógica real (ViewModel, navegación).

---

### Ejemplo

```swift 
struct ProductPage: View {
    
    @StateObject var viewModel: ProductViewModel
    
    var body: some View {
        ProductGridTemplate(products: viewModel.products)
    }
}
```

---

## 🔄 Estrategia de Refactorización

### Paso 1: Identificar componentes

* Detectar vistas repetidas
* Extraer UI común

---

### Paso 2: Crear Atoms

* Botones
* Textos
* Imágenes
* Rating (reusar `StarRatingView`)

---

### Paso 3: Construir Molecules

* ReviewRow
* ProductCard

---

### Paso 4: Crear Organisms

* Grid de productos
* Lista de reviews

---

### Paso 5: Separar Templates y Pages

* Templates sin lógica
* Pages con ViewModel

---

## ♻️ Reutilización

* Evitar duplicación de UI
* Centralizar estilos
* Componentes configurables

---

## 🎨 Consistencia UI

* Debe respetar:

```text
appReferenceUI
imagenes/ReviewList.png
```

---




---

## ⚠️ Reglas Técnicas

* No mover lógica de negocio a la UI
* Mantener separación con dominio (hexagonal)
* Evitar ViewModels dentro de Atoms/Molecules
* Inyección de dependencias solo en Views

---

## 🚀 Criterios de Aceptación

* [x] Vistas organizadas en Atomic Design
* [x] Componentes reutilizables implementados
* [x] Reducción de duplicación
* [x] UI consistente con diseños
* [x] Integración correcta con ViewModel
* [ ] Tests ≥ 80% cobertura
* [x] Código más legible y mantenible

