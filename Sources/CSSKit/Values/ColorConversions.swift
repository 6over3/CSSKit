// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// Color space conversion functions for CSS Color Level 4.

/// RGB color components as doubles in the range [0.0, 1.0].
public struct RGBComponents: Equatable, Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double

    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }
}

/// Converts HSL to RGB. https://drafts.csswg.org/css-color/#hsl-color
public func hslToRgb(hue: Double, saturation: Double, lightness: Double) -> RGBComponents {
    func hueToRgb(m1: Double, m2: Double, h3: Double) -> Double {
        var h3 = h3
        if h3 < 0.0 {
            h3 += 3.0
        }
        if h3 > 3.0 {
            h3 -= 3.0
        }
        if h3 * 2.0 < 1.0 {
            return m1 + (m2 - m1) * h3 * 2.0
        } else if h3 * 2.0 < 3.0 {
            return m2
        } else if h3 < 2.0 {
            return m1 + (m2 - m1) * (2.0 - h3) * 2.0
        } else {
            return m1
        }
    }

    let m2 = if lightness <= 0.5 {
        lightness * (saturation + 1.0)
    } else {
        lightness + saturation - lightness * saturation
    }

    let m1 = lightness * 2.0 - m2
    let hueTimes3 = hue * 3.0

    let red = hueToRgb(m1: m1, m2: m2, h3: hueTimes3 + 1.0)
    let green = hueToRgb(m1: m1, m2: m2, h3: hueTimes3)
    let blue = hueToRgb(m1: m1, m2: m2, h3: hueTimes3 - 1.0)

    return RGBComponents(red: red, green: green, blue: blue)
}

/// Converts HWB to RGB. https://drafts.csswg.org/css-color-4/#hwb-to-rgb
public func hwbToRgb(hue: Double, whiteness: Double, blackness: Double) -> RGBComponents {
    if whiteness + blackness >= 1.0 {
        let gray = whiteness / (whiteness + blackness)
        return RGBComponents(red: gray, green: gray, blue: gray)
    }

    let rgb = hslToRgb(hue: hue, saturation: 1.0, lightness: 0.5)
    let scale = 1.0 - whiteness - blackness

    return RGBComponents(
        red: rgb.red * scale + whiteness,
        green: rgb.green * scale + whiteness,
        blue: rgb.blue * scale + whiteness
    )
}
