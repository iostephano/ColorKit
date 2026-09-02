//
//  UIColor+RGBColor.swift
//  ColorKit
//
//  Created by Stephano Portella on 02/09/26.
//

import UIKit

extension UIColor {
    /// El color como triplete RGB de 8 bits. Los componentes de gama amplia que
    /// caen fuera de `0...1` se recortan.
    var rgbColor: RGBColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return RGBColor(
            red: Self.channelByte(red),
            green: Self.channelByte(green),
            blue: Self.channelByte(blue)
        )
    }

    var hexString: String { rgbColor.hexString }

    var rgbString: String { rgbColor.rgbString }

    private static func channelByte(_ value: CGFloat) -> UInt8 {
        let scaled = (value * 255).rounded()
        return UInt8(min(255, max(0, scaled)))
    }
}
