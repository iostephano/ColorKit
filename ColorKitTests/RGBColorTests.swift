//
//  RGBColorTests.swift
//  ColorKitTests
//
//  Created by Stephano Portella on 02/09/26.
//

import Testing
import UIKit
@testable import ColorKit

struct RGBColorTests {

    @Test("Distance to itself is zero")
    func zeroDistanceToSelf() {
        let color = RGBColor(red: 120, green: 30, blue: 200)
        #expect(color.distance(to: color) == 0)
    }

    @Test("Opposite corners of the RGB cube are at distance 1")
    func maxDistance() {
        let black = RGBColor(red: 0, green: 0, blue: 0)
        let white = RGBColor(red: 255, green: 255, blue: 255)
        #expect(abs(black.distance(to: white) - 1.0) < 0.0001)
    }

    @Test("Distance is symmetric")
    func symmetricDistance() {
        let a = RGBColor(red: 10, green: 90, blue: 240)
        let b = RGBColor(red: 200, green: 15, blue: 60)
        #expect(a.distance(to: b) == b.distance(to: a))
    }

    @Test("Hex string is upper-case and zero-padded")
    func hexFormatting() {
        #expect(RGBColor(red: 0, green: 0, blue: 0).hexString == "#000000")
        #expect(RGBColor(red: 255, green: 255, blue: 255).hexString == "#FFFFFF")
        #expect(RGBColor(red: 26, green: 43, blue: 60).hexString == "#1A2B3C")
    }

    @Test("RGB string uses decimal channel values")
    func rgbFormatting() {
        #expect(RGBColor(red: 26, green: 43, blue: 60).rgbString == "(26,43,60)")
    }

    @Test("Converts to a UIColor that round-trips back to the same triplet")
    func uiColorRoundTrip() {
        let original = RGBColor(red: 64, green: 128, blue: 192)
        #expect(original.uiColor.rgbColor == original)
    }
}
