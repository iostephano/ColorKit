# ColorKit — Extractor de colores dominantes de una imagen

ColorKit es una app de iOS que toma una foto de la galería o la cámara y devuelve
su paleta de colores dominantes, mostrándolos como círculos con su código en
**HEX** o **RGB**. Existe como proyecto de portafolio para mostrar cómo abordo un
problema de procesamiento de imagen en iOS con **UIKit y Core Graphics puros**:
leer el buffer de píxeles a mano, agrupar colores parecidos y mantener el trabajo
pesado fuera del hilo principal con `async/await`.

<img width="1389" height="696" alt="ColorKit" src="https://github.com/user-attachments/assets/746561b4-2291-4d1b-b7c5-8a485c9d17ba" />

---

## Tecnologías usadas

- Swift 6 (con verificación estricta de concurrencia activada)
- UIKit, construido por código (sin Storyboards salvo la pantalla de lanzamiento)
- Core Graphics para leer el buffer de píxeles RGBA de la imagen
- `async/await` + `Task.detached` para clusterizar los píxeles sin bloquear la UI
- `@MainActor` aislando el decodificado de `UIImage`/`CGImage`
- Swift Testing para las pruebas
- Integración continua con GitHub Actions (compila y corre los tests en cada push/PR)
- Cero dependencias externas

---

## Cómo está organizado el proyecto

Es un repo pequeño, de un solo módulo:

```
ColorKit/
├── ColorKit/
│   ├── AppDelegate.swift / SceneDelegate.swift   # Arranque (ventana + root VC por código)
│   ├── ViewController.swift                      # Pantalla única: elegir imagen y mostrar la paleta
│   ├── ColorPaletteView.swift                    # UIView custom: dos filas de swatches + toggle HEX/RGB
│   ├── ColorExtractor.swift                      # El núcleo: decodifica píxeles y clusteriza colores
│   ├── RGBColor.swift                            # Triplete RGB de 8 bits, Hashable y Sendable
│   └── UIColor+RGBColor.swift                    # Puente entre UIColor y RGBColor + formato HEX/RGB
└── ColorKitTests/                                # Swift Testing sobre la lógica de ColorExtractor y RGBColor
```

`ColorExtractor` separa dos responsabilidades:

- **Decodificar** (`@MainActor`): dibuja la imagen en un contexto RGBA de 100x100 y
  entrega sus bytes crudos. Toca `UIImage`/`CGImage`, que no son `Sendable`, así
  que se queda en el hilo principal.
- **Clusterizar** (función pura, sin UIKit): cuenta píxeles por "cubeta" de color,
  se queda con el color real más frecuente de cada cubeta y filtra los que están
  demasiado cerca entre sí. Opera sobre `[UInt8]`, así que corre en un
  `Task.detached` y es directamente testeable.

---

## Cómo funciona / flujo principal

1. El usuario toca el botón **+** y elige *Galería* o *Cámara*.
2. `UIImagePickerController` devuelve una `UIImage`, que se muestra en pantalla.
3. `ColorExtractor.dominantColors(from:maxColors:)` decodifica la imagen a un
   buffer RGBA de 100x100 en el `@MainActor`.
4. El buffer (ya `Sendable`) pasa a un `Task.detached` que:
   - cuantiza cada píxel a cubetas de 16 niveles por canal y las cuenta,
   - ordena las cubetas por frecuencia,
   - recorre el ranking quedándose con colores mutuamente distintos (distancia
     RGB normalizada mayor o igual a 0.10) hasta llenar la paleta.
5. La paleta vuelve al `@MainActor` y `ColorPaletteView` pinta los swatches.
6. El toggle cambia el texto de cada swatch entre `#RRGGBB` y `(r,g,b)` sin
   recalcular nada.

---

## Funcionalidades / qué demuestra

- Extracción de hasta 14 colores dominantes de cualquier foto.
- Lectura directa del buffer de píxeles con `CGContext` (sin librerías de color).
- Agrupado de tonos casi idénticos + filtro de distancia para que la paleta no
  repita variaciones del mismo color.
- Cambio de formato HEX / RGB en vivo.
- Botón de reinicio para limpiar imagen y paleta.
- Interfaz por código pensada para modo oscuro.

---

## Pruebas

`ColorKitTests` (Swift Testing) cubre la lógica central, que es pura y no necesita
simulador para la mayoría de los casos:

- **`ColorExtractor.cluster`**: imagen sólida da un color; orden por frecuencia;
  respeto de `maxColors`; los píxeles transparentes (alpha < 128) se ignoran; los
  tonos dentro de una misma cubeta colapsan en uno; el filtro de distancia
  descarta colores casi iguales; entradas degeneradas (buffer vacío o a medias)
  devuelven paleta vacía.
- **`ColorExtractor.dominantColors`**: prueba de extremo a extremo que decodifica
  una `UIImage` real y verifica el color resultante.
- **`RGBColor`**: distancia (cero consigo mismo, 1 entre esquinas opuestas del
  cubo, simétrica), formato HEX con padding, formato RGB y round-trip con `UIColor`.

Correr los tests:

```bash
xcodebuild test \
  -project ColorKit.xcodeproj \
  -scheme ColorKit \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Cómo correr el proyecto

1. Clona el repo:
   ```bash
   git clone https://github.com/iostephano/ColorKit.git
   ```
2. Abre `ColorKit.xcodeproj` con **Xcode 26** (ver `.xcode-version`).
3. El objetivo mínimo es **iOS 26**. Elige un simulador de iPhone y ejecuta (Cmd-R).
4. La opción *Cámara* solo funciona en un dispositivo físico; en el simulador usa
   *Galería*.

---

## Cosas pendientes o limitadas (a propósito)

- **Es una demo de una sola pantalla.** No hay persistencia: al cerrar la app se
  pierde la paleta.
- **El algoritmo es deliberadamente simple:** cuantización uniforme + conteo por
  cubeta + filtro de distancia euclidiana en RGB. No usa espacios de color
  perceptuales (Lab), ni k-means, ni mediana de cortes. Es suficiente para el
  propósito del repo y fácil de leer y testear.
- **La imagen se analiza a 100x100.** Prioriza velocidad sobre precisión en
  imágenes con muchísimos matices.
- **No hay exportar/copiar la paleta** ni compartir; el foco está en la extracción.
- Los textos de la interfaz están en español; los identificadores del código, en inglés.

---

## Autor

Stephano Portella

