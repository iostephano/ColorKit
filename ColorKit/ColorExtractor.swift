//
//  ColorExtractor.swift
//  ColorKit
//
//  Created by Stephano Portella on 02/09/26.
//

import UIKit

/// Extrae los colores dominantes y visualmente distintos de una imagen.
///
/// Está partido en dos para que el bucle pesado pueda salir del main actor: el
/// decodificado toca `UIImage`/`CGImage` (que no son `Sendable`) y se queda ahí;
/// la clusterización es aritmética pura sobre `[UInt8]` y corre en una tarea
/// desprendida.
enum ColorExtractor {

    /// Resolución a la que se reduce la imagen para escanear píxeles: chica para
    /// analizarla en bastante menos de un frame, grande para no perder la
    /// distribución de color.
    static let sampleSize = CGSize(width: 100, height: 100)

    /// Ancho de la cubeta por canal que fusiona tonos casi idénticos.
    static let quantizationStep: UInt8 = 16

    /// Distancia RGB normalizada (0...1) mínima para que dos colores aparezcan
    /// los dos en la paleta.
    static let distinctnessThreshold = 0.10

    /// Hasta `maxColors` colores dominantes y mutuamente distintos, del más
    /// frecuente al menos. Vacío si la imagen no se puede decodificar o
    /// `maxColors <= 0`.
    @MainActor
    static func dominantColors(from image: UIImage, maxColors: Int) async -> [UIColor] {
        guard maxColors > 0, let pixels = rgbaBytes(from: image, sampleSize: sampleSize) else {
            return []
        }

        let step = quantizationStep
        let threshold = distinctnessThreshold
        let palette = await Task.detached(priority: .userInitiated) {
            cluster(rgbaBytes: pixels, maxColors: maxColors, quantizationStep: step, threshold: threshold)
        }.value

        return palette.map(\.uiColor)
    }

    // MARK: - Clusterización (pura, testeable, sin actor)

    /// Agrupa un buffer RGBA crudo (`R,G,B,A` empaquetado, 4 bytes por píxel) en
    /// una paleta ordenada. Sin dibujo de UIKit, para que los tests puedan
    /// pasarle un buffer armado a mano.
    static func cluster(
        rgbaBytes: [UInt8],
        maxColors: Int,
        quantizationStep: UInt8 = quantizationStep,
        threshold: Double = distinctnessThreshold
    ) -> [RGBColor] {
        guard maxColors > 0, rgbaBytes.count >= 4 else { return [] }

        let step = Int(max(1, quantizationStep))

        // Cuenta por cubeta gruesa, pero guarda el primer color real visto en
        // cada cubeta para que la paleta reporte colores reales de la imagen y
        // no el piso de la cubeta.
        var counts: [RGBColor: Int] = [:]
        var representative: [RGBColor: RGBColor] = [:]

        var index = 0
        let lastPixelStart = rgbaBytes.count - 4
        while index <= lastPixelStart {
            defer { index += 4 }

            let alpha = rgbaBytes[index + 3]
            if alpha < 128 { continue }

            let actual = RGBColor(
                red: rgbaBytes[index],
                green: rgbaBytes[index + 1],
                blue: rgbaBytes[index + 2]
            )
            let bucket = RGBColor(
                red: quantize(actual.red, step: step),
                green: quantize(actual.green, step: step),
                blue: quantize(actual.blue, step: step)
            )
            counts[bucket, default: 0] += 1
            if representative[bucket] == nil { representative[bucket] = actual }
        }

        let ranked = counts.sorted { lhs, rhs in
            lhs.value != rhs.value ? lhs.value > rhs.value : lhs.key.hexString < rhs.key.hexString
        }

        var palette: [RGBColor] = []
        for (bucket, _) in ranked {
            if palette.count >= maxColors { break }
            guard let color = representative[bucket] else { continue }
            if palette.allSatisfy({ $0.distance(to: color) >= threshold }) {
                palette.append(color)
            }
        }
        return palette
    }

    private static func quantize(_ value: UInt8, step: Int) -> UInt8 {
        let bucketed = (Int(value) / step) * step
        return UInt8(min(255, bucketed))
    }

    // MARK: - Decodificado (main actor, UIKit)

    /// Dibuja `image` en un contexto `sampleSize` fuera de pantalla y devuelve
    /// sus bytes crudos, `R,G,B,A` por píxel (alfa premultiplicado al final).
    @MainActor
    static func rgbaBytes(from image: UIImage, sampleSize: CGSize) -> [UInt8]? {
        guard let cgImage = image.cgImage else { return nil }

        let width = Int(sampleSize.width)
        let height = Int(sampleSize.height)
        guard width > 0, height > 0 else { return nil }

        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var buffer = [UInt8](repeating: 0, count: height * bytesPerRow)

        guard let context = CGContext(
            data: &buffer,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        context.interpolationQuality = .medium
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return buffer
    }
}
