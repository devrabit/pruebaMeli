# PruebaMeli

App iOS en SwiftUI para visualizar productos, reseñas y generar un resumen on-device de opiniones.

## Stack

- SwiftUI + Combine
- Arquitectura hexagonal (Domain / Application / Adapters / Infrastructure)
- Atomic Design para capa UI (`UI/Atoms`, `UI/Molecules`, `UI/Organisms`, `UI/Templates`, `UI/Pages`)
- Persistencia local en archivos JSON (cache de productos y resúmenes)

## Funcionalidades

- Grilla de productos con imagen, título, precio mock, rating promedio y cantidad de reseñas.
- Estados de pantalla: loading, error, empty, success.
- Generación de resumen de reseñas por producto.
  - Usa `FoundationModels` cuando está disponible.
  - Fallback heurístico local cuando no hay disponibilidad.
- Modal de resumen y sheet con listado completo de reseñas.

## Demo en video

- Video de demostración: [`Video/demo.mp4`](Video/demo.mp4)

<video src="Video/demo.mp4" controls width="720">
  Tu visor de Markdown no soporta video embebido.
  Puedes abrir la demo aquí: <a href="Video/demo.mp4">Video/demo.mp4</a>.
</video>

## Estructura del proyecto

- `PruebaMeli/PruebaMeli/Domain`: entidades y puertos.
- `PruebaMeli/PruebaMeli/Application`: casos de uso.
- `PruebaMeli/PruebaMeli/Adapters`: implementación de repositorios y generador de resumen.
- `PruebaMeli/PruebaMeli/Infrastructure`: red, environment y stores locales.
- `PruebaMeli/PruebaMeli/UI`: componentes Atomic Design.
- `PruebaMeli/PruebaMeliTests`: tests unitarios.
- `PruebaMeli/PruebaMeliUITests`: tests UI.
- `Spec`: especificaciones funcionales.
- `Mocks/Products/list.json`: fixture principal para endpoint de productos.

## Requisitos

- Xcode 16+ (recomendado el más reciente).
- iOS deployment target actual del proyecto: `18.5`.
- Para usar Foundation Models en runtime:
  - dispositivo compatible con Apple Intelligence,
  - Apple Intelligence activada,
  - OS compatible para `SystemLanguageModel` (iOS/iPadOS/macOS/visionOS 26+).

## Configuracion y ejecucion

1. Abre `PruebaMeli/PruebaMeli.xcodeproj`.
2. Selecciona scheme `PruebaMeli`.
3. Ejecuta en simulador o dispositivo.

### Base URL

La app toma `BASE_URL` desde variable de entorno; si no existe usa:

- `http://localhost:8080`

Codigo:

- `PruebaMeli/PruebaMeli/Infrastructure/Environment.swift`

Para trabajar con mocks, expone `GET /products` apuntando a `Mocks/Products/list.json` (por ejemplo con Proxyman o un servidor local).

### Configuracion con Proxyman

Configuracion recomendada para correr la app consumiendo mocks:

1. Abre Proxyman y habilita SSL Proxying para:
   - host: `localhost`
   - puerto: `8080`
2. Ve a **Tools > Map Local** y crea una regla:
   - **URL**: `http://localhost:8080/products`
   - **Local file**: `Mocks/Products/list.json`
3. En Xcode, abre:
   - `Product > Scheme > Edit Scheme... > Run > Arguments > Environment Variables`
4. Agrega la variable:
   - `BASE_URL = http://localhost:8080`
5. Ejecuta la app con el scheme `PruebaMeli`.

Notas:

- Si usas simulador iOS, `localhost` apunta a tu Mac, por lo que no necesitas cambiar a IP local.
- Si pruebas en dispositivo fisico, usa la IP de tu Mac (por ejemplo `http://192.168.1.10:8080`) en `BASE_URL` y en la regla de Proxyman.
- Si no se ven productos, valida que la regla de Map Local este activa y que la URL solicitada sea exactamente `/products`.

## Testing

Desde Xcode:

- Product > Test

Desde terminal (ejemplo):

```bash
xcodebuild test \
  -project "PruebaMeli/PruebaMeli.xcodeproj" \
  -scheme "PruebaMeli" \
  -destination "platform=iOS Simulator,name=iPhone 16"
```

## Persistencia local

- Productos: `products-cache.json` en `cachesDirectory` (`FileProductLocalStore`).
- Resumenes: `review-summaries.json` en `cachesDirectory` (`FileSummaryRepository`). Al abrir la app, `ProductViewModel` vuelve a cargar todos los resúmenes guardados en memoria para mostrar el estado correcto en la grilla.

## Specs implementadas

- `Spec/ConsumoDeProductosMockeados.md`
- `Spec/VisualizacionDeProductosGrilla.md`
- `Spec/GeneracionDeResumen.md`
- `Spec/VisualizaciónDeTodaslasResenas.md`
- `Spec/RefactorizacionAtomicDesing.md`

## Notas

- Este repositorio puede generar artefactos locales de pruebas (`*.xcresult`, reportes de cobertura) que no son parte del codigo fuente.
- La generacion de resumen esta pensada para ejecutarse localmente sin proveedores cloud.
