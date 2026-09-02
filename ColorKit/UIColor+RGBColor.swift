//
//  UIColor+RGBColor.swift
//  ColorKit
//
//  Created by Stephano Portella on 26/04/25.
//

import UIKit

extension UIColor {
    /// The color as an 8-bit RGB triplet. Wide-gamut components that fall
    /// outside `0...1` are clamped.
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
