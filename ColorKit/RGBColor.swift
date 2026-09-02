//
//  RGBColor.swift
//  ColorKit
//
//  Created by Stephano Portella on 26/04/25.
//

import UIKit

/// An 8-bit-per-channel RGB triplet.
///
/// Used instead of `UIColor` in the clustering path: it has dependable
/// `Hashable` semantics for dictionary counting and is `Sendable`.
struct RGBColor: Hashable, Sendable {
    let red: UInt8
    let green: UInt8
    let blue: UInt8
}

extension RGBColor {
    /// Euclidean distance to `other`, normalized so black↔white is `1`.
    func distance(to other: RGBColor) -> Double {
        let dr = Double(red) - Double(other.red)
        let dg = Double(green) - Double(other.green)
        let db = Double(blue) - Double(other.blue)
        return (dr * dr + dg * dg + db * db).squareRoot() / (255.0 * 3.0.squareRoot())
    }

    var uiColor: UIColor {
        UIColor(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: 1.0
        )
    }

    var hexString: String {
        String(format: "#%02X%02X%02X", red, green, blue)
    }

    var rgbString: String {
        "(\(red),\(green),\(blue))"
    }
}
