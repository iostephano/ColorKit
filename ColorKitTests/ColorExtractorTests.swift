//
//  ColorExtractorTests.swift
//  ColorKitTests
//
//  Created by Stephano Portella on 02/09/26.
//

import Testing
import UIKit
@testable import ColorKit

struct ColorExtractorTests {

    /// Arma un buffer RGBA empaquetado a partir de una lista de tramos `(color, cantidad)`.
    private func buffer(_ runs: [(RGBColor, Int)], alpha: UInt8 = 255) -> [UInt8] {
        var bytes: [UInt8] = []
        for (color, count) in runs {
            for _ in 0..<count {
                bytes.append(contentsOf: [color.red, color.green, color.blue, alpha])
            }
        }
        return bytes
    }

    @Test("A solid image yields exactly one color")
    func solidColor() {
        let red = RGBColor(red: 255, green: 0, blue: 0)
        let palette = ColorExtractor.cluster(rgbaBytes: buffer([(red, 50)]), maxColors: 5)
        #expect(palette == [red])
    }

    @Test("Colors are ordered from most to least frequent")
    func frequencyOrdering() {
        let blue = RGBColor(red: 0, green: 0, blue: 255)
        let green = RGBColor(red: 0, green: 255, blue: 0)
        let red = RGBColor(red: 255, green: 0, blue: 0)
        let bytes = buffer([(blue, 10), (green, 30), (red, 60)])

        let palette = ColorExtractor.cluster(rgbaBytes: bytes, maxColors: 5)

        #expect(palette == [red, green, blue])
    }

    @Test("maxColors caps the palette size")
    func respectsMaxColors() {
        let bytes = buffer([
            (RGBColor(red: 255, green: 0, blue: 0), 40),
            (RGBColor(red: 0, green: 255, blue: 0), 30),
            (RGBColor(red: 0, green: 0, blue: 255), 20),
            (RGBColor(red: 255, green: 255, blue: 0), 10),
        ])

        #expect(ColorExtractor.cluster(rgbaBytes: bytes, maxColors: 2).count == 2)
    }

    @Test("Transparent pixels are ignored")
    func skipsTransparentPixels() {
        let red = RGBColor(red: 255, green: 0, blue: 0)
        let ghost = RGBColor(red: 0, green: 255, blue: 0)

        var bytes = buffer([(red, 10)])
        bytes.append(contentsOf: buffer([(ghost, 40)], alpha: 10)) // por debajo del corte de 128

        let palette = ColorExtractor.cluster(rgbaBytes: bytes, maxColors: 5)

        #expect(palette == [red])
    }

    @Test("Near-identical shades collapse into one bucket")
    func quantizationMergesNeighbors() {
        // Tres tonos dentro de una misma cubeta de ancho 16 en cada canal.
        let bytes = buffer([
            (RGBColor(red: 240, green: 2, blue: 1), 20),
            (RGBColor(red: 246, green: 5, blue: 4), 20),
            (RGBColor(red: 241, green: 9, blue: 6), 20),
        ])

        let palette = ColorExtractor.cluster(rgbaBytes: bytes, maxColors: 5, quantizationStep: 16)

        #expect(palette.count == 1)
        // La paleta reporta el primer color real visto en la cubeta.
        #expect(palette.first == RGBColor(red: 240, green: 2, blue: 1))
    }

    @Test("Colors closer than the threshold are not both returned")
    func distinctnessFiltering() {
        let bright = RGBColor(red: 255, green: 0, blue: 0)
        let almostBright = RGBColor(red: 245, green: 0, blue: 0)
        let bytes = buffer([(bright, 50), (almostBright, 40)])

        // step 1 desactiva la cuantización, así los dos sobreviven al conteo;
        // el filtro de distinción es lo que tiene que descartar el segundo.
        let palette = ColorExtractor.cluster(
            rgbaBytes: bytes,
            maxColors: 5,
            quantizationStep: 1,
            threshold: 0.10
        )

        #expect(palette == [bright])
    }

    @Test("Degenerate inputs return an empty palette")
    func degenerateInputs() {
        #expect(ColorExtractor.cluster(rgbaBytes: [], maxColors: 5).isEmpty)
        #expect(ColorExtractor.cluster(rgbaBytes: [1, 2, 3], maxColors: 5).isEmpty)
        #expect(ColorExtractor.cluster(rgbaBytes: [1, 2, 3, 255], maxColors: 0).isEmpty)
    }

    @Test("dominantColors decodes a real UIImage end to end")
    @MainActor
    func endToEndWithImage() async {
        let fill = UIColor(red: 0.10, green: 0.60, blue: 0.60, alpha: 1)
        let image = Self.solidImage(color: fill, size: CGSize(width: 32, height: 32))

        let colors = await ColorExtractor.dominantColors(from: image, maxColors: 4)

        #expect(colors.count == 1)
        #expect(colors.first?.rgbColor.distance(to: fill.rgbColor) ?? 1 < 0.1)
    }

    @MainActor
    private static func solidImage(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
