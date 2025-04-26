//
//  ColorExtractor.swift
//  ColorKit
//
//  Created by Stephano Portella on 26/04/25.
//

import UIKit

struct ColorExtractor {
    
    static func extractDistinctColors(from image: UIImage, maxColors: Int) -> [UIColor] {
        guard let resizedImage = image.resized(to: CGSize(width: 100, height: 100)),
              let pixelData = resizedImage.pixelData() else {
            return []
        }
        
        var colorCount: [UIColor: Int] = [:]
        
        for i in stride(from: 0, to: pixelData.count, by: 4) {
            let r = pixelData[i]
            let g = pixelData[i + 1]
            let b = pixelData[i + 2]
            let a = pixelData[i + 3]
            
            if a < 128 { continue }
            
            let color = UIColor(red: CGFloat(r) / 255.0,
                                green: CGFloat(g) / 255.0,
                                blue: CGFloat(b) / 255.0,
                                alpha: 1.0)
            
            colorCount[color, default: 0] += 1
        }
        
        let sortedColors = colorCount.sorted { $0.value > $1.value }.map { $0.key }
        var distinctColors: [UIColor] = []
        
        for color in sortedColors {
            if distinctColors.count >= maxColors {
                break
            }
            if isColorDistinct(color, from: distinctColors) {
                distinctColors.append(color)
            }
        }
        
        return distinctColors
    }
    
    private static func isColorDistinct(_ color: UIColor, from colors: [UIColor]) -> Bool {
        for existingColor in colors {
            if color.isSimilar(to: existingColor, threshold: 0.1) {
                return false
            }
        }
        return true
    }
}

private extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(origin: .zero, size: size))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized
    }
    
    func pixelData() -> [UInt8]? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = Int(size.width)
        let height = Int(size.height)
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let totalBytes = height * bytesPerRow
        
        var pixelData = [UInt8](repeating: 0, count: totalBytes)
        
        guard let context = CGContext(data: &pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        return pixelData
    }
}

private extension UIColor {
    func isSimilar(to color: UIColor, threshold: CGFloat) -> Bool {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let distance = sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2))
        
        return distance < threshold
    }
}
