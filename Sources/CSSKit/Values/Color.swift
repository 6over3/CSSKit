// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// CSS Color Level 4 implementation.
// https://drafts.csswg.org/css-color-4/

import Foundation

// MARK: - Basic Color Structs

/// RGB color components (0-255 range).
public struct RGBColor: Equatable, Sendable, Hashable {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }
}

/// Legacy sRGB color with red, green, blue, and alpha components.
public struct RgbaLegacy: Equatable, Sendable, Hashable {
    /// The red component (0-255 range, as Double for precision).
    public let red: Double
    /// The green component (0-255 range, as Double for precision).
    public let green: Double
    /// The blue component (0-255 range, as Double for precision).
    public let blue: Double
    /// The alpha component (0.0-1.0).
    public let alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    /// Creates an RGBA value from UInt8 components.
    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: Double) {
        self.red = Double(red)
        self.green = Double(green)
        self.blue = Double(blue)
        self.alpha = alpha
    }

    /// Creates an RGBA value from unit double components (0.0-1.0), scaling to 0-255.
    public init(normalizedRed red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red * 255.0
        self.green = green * 255.0
        self.blue = blue * 255.0
        self.alpha = alpha.clamped(to: 0.0 ... OPAQUE)
    }
}

/// Backward-compatible alias for RgbaLegacy.
public typealias RGBAColor = RgbaLegacy

// MARK: - HSL Color

/// Color specified by hue, saturation and lightness components.
/// https://drafts.csswg.org/css-color/#the-hsl-notation
public struct Hsl: Equatable, Sendable, Hashable {
    /// The hue component (0-360 degrees, or nil for "none").
    public let hue: Double?
    /// The saturation component (0.0-1.0, or nil for "none").
    public let saturation: Double?
    /// The lightness component (0.0-1.0, or nil for "none").
    public let lightness: Double?
    /// The alpha component (0.0-1.0, or nil for "none").
    public let alpha: Double?

    public init(hue: Double?, saturation: Double?, lightness: Double?, alpha: Double?) {
        self.hue = hue
        self.saturation = saturation
        self.lightness = lightness
        self.alpha = alpha
    }
}

// MARK: - HWB Color

/// Color specified by hue, whiteness and blackness components.
/// https://drafts.csswg.org/css-color/#the-hwb-notation
public struct Hwb: Equatable, Sendable, Hashable {
    /// The hue component (0-360 degrees, or nil for "none").
    public let hue: Double?
    /// The whiteness component (0.0-1.0, or nil for "none").
    public let whiteness: Double?
    /// The blackness component (0.0-1.0, or nil for "none").
    public let blackness: Double?
    /// The alpha component (0.0-1.0, or nil for "none").
    public let alpha: Double?

    public init(hue: Double?, whiteness: Double?, blackness: Double?, alpha: Double?) {
        self.hue = hue
        self.whiteness = whiteness
        self.blackness = blackness
        self.alpha = alpha
    }
}

// MARK: - Lab Color

/// Color specified by lightness, a- and b-axis components.
/// https://drafts.csswg.org/css-color/#lab-colors
public struct Lab: Equatable, Sendable, Hashable {
    /// The lightness component (0-100, or nil for "none").
    public let lightness: Double?
    /// The a-axis component (typically -125 to 125, or nil for "none").
    public let a: Double?
    /// The b-axis component (typically -125 to 125, or nil for "none").
    public let b: Double?
    /// The alpha component (0.0-1.0, or nil for "none").
    public let alpha: Double?

    public init(lightness: Double?, a: Double?, b: Double?, alpha: Double?) {
        self.lightness = lightness
        self.a = a
        self.b = b
        self.alpha = alpha
    }
}

// MARK: - LCH Color

/// Color specified by lightness, chroma and hue components.
/// https://drafts.csswg.org/css-color/#lch-colors
public struct Lch: Equatable, Sendable, Hashable {
    /// The lightness component (0-100, or nil for "none").
    public let lightness: Double?
    /// The chroma component (0-150 typically, or nil for "none").
    public let chroma: Double?
    /// The hue component (0-360 degrees, or nil for "none").
    public let hue: Double?
    /// The alpha component (0.0-1.0, or nil for "none").
    public let alpha: Double?

    public init(lightness: Double?, chroma: Double?, hue: Double?, alpha: Double?) {
        self.lightness = lightness
        self.chroma = chroma
        self.hue = hue
        self.alpha = alpha
    }
}

// MARK: - Oklab Color

/// Color specified by lightness, a- and b-axis components in the Oklab space.
/// https://drafts.csswg.org/css-color/#ok-lab
public struct Oklab: Equatable, Sendable, Hashable {
    /// The lightness component (0.0-1.0, or nil for "none").
    public let lightness: Double?
    /// The a-axis component (typically -0.4 to 0.4, or nil for "none").
    public let a: Double?
    /// The b-axis component (typically -0.4 to 0.4, or nil for "none").
    public let b: Double?
    /// The alpha component (0.0-1.0, or nil for "none").
    public let alpha: Double?

    public init(lightness: Double?, a: Double?, b: Double?, alpha: Double?) {
        self.lightness = lightness
        self.a = a
        self.b = b
        self.alpha = alpha
    }
}

// MARK: - Oklch Color

/// Color specified by lightness, chroma and hue components in the Oklch space.
/// https://drafts.csswg.org/css-color/#ok-lab
public struct Oklch: Equatable, Sendable, Hashable {
    /// The lightness component (0.0-1.0, or nil for "none").
    public let lightness: Double?
    /// The chroma component (0.0-0.4 typically, or nil for "none").
    public let chroma: Double?
    /// The hue component (0-360 degrees, or nil for "none").
    public let hue: Double?
    /// The alpha component (0.0-1.0, or nil for "none").
    public let alpha: Double?

    public init(lightness: Double?, chroma: Double?, hue: Double?, alpha: Double?) {
        self.lightness = lightness
        self.chroma = chroma
        self.hue = hue
        self.alpha = alpha
    }
}

// MARK: - Predefined Color Space

/// A Predefined color space specified in:
/// https://drafts.csswg.org/css-color-4/#predefined
public enum PredefinedColorSpace: Equatable, Sendable, Hashable {
    /// https://drafts.csswg.org/css-color-4/#predefined-sRGB
    case srgb
    /// https://drafts.csswg.org/css-color-4/#predefined-sRGB-linear
    case srgbLinear
    /// https://drafts.csswg.org/css-color-4/#predefined-display-p3
    case displayP3
    /// https://drafts.csswg.org/css-color-4/#predefined-display-p3-linear
    case displayP3Linear
    /// https://drafts.csswg.org/css-color-4/#predefined-a98-rgb
    case a98Rgb
    /// https://drafts.csswg.org/css-color-4/#predefined-prophoto-rgb
    case prophotoRgb
    /// https://drafts.csswg.org/css-color-4/#predefined-rec2020
    case rec2020
    /// https://drafts.csswg.org/css-color-4/#predefined-xyz
    case xyzD50
    /// https://drafts.csswg.org/css-color-4/#predefined-xyz
    case xyzD65

    /// Parses a predefined color space from the given input.
    static func parse(_ input: Parser) -> Result<Self, BasicParseError> {
        let location = input.currentSourceLocation()

        switch input.expectIdent() {
        case let .success(ident):
            let lower = ident.value.lowercased()
            switch lower {
            case "srgb": return .success(.srgb)
            case "srgb-linear": return .success(.srgbLinear)
            case "display-p3": return .success(.displayP3)
            case "display-p3-linear": return .success(.displayP3Linear)
            case "a98-rgb": return .success(.a98Rgb)
            case "prophoto-rgb": return .success(.prophotoRgb)
            case "rec2020": return .success(.rec2020)
            case "xyz-d50": return .success(.xyzD50)
            case "xyz", "xyz-d65": return .success(.xyzD65)
            default:
                return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
            }
        case let .failure(error):
            return .failure(error)
        }
    }
}

// MARK: - Color Space

/// A color space for the color() function, including predefined, device-cmyk, and custom spaces.
/// https://drafts.csswg.org/css-color-5/#color-function
public enum ColorSpace: Equatable, Sendable, Hashable {
    /// A predefined color space
    case predefined(PredefinedColorSpace)
    /// The device-cmyk color space.
    /// https://drafts.csswg.org/css-color-5/#device-cmyk
    case deviceCmyk
    /// A custom color space starting with "--".
    /// https://drafts.csswg.org/css-color-5/#custom-color
    case custom(String)

    /// Parses a color space from the given input (for use in color() function).
    static func parse(_ input: Parser) -> Result<Self, BasicParseError> {
        let location = input.currentSourceLocation()

        switch input.expectIdent() {
        case let .success(ident):
            let value = ident.value
            let lower = value.lowercased()

            // Check for predefined color spaces
            switch lower {
            case "srgb": return .success(.predefined(.srgb))
            case "srgb-linear": return .success(.predefined(.srgbLinear))
            case "display-p3": return .success(.predefined(.displayP3))
            case "display-p3-linear": return .success(.predefined(.displayP3Linear))
            case "a98-rgb": return .success(.predefined(.a98Rgb))
            case "prophoto-rgb": return .success(.predefined(.prophotoRgb))
            case "rec2020": return .success(.predefined(.rec2020))
            case "xyz-d50": return .success(.predefined(.xyzD50))
            case "xyz", "xyz-d65": return .success(.predefined(.xyzD65))
            case "device-cmyk": return .success(.deviceCmyk)
            default:
                // Check for custom color space
                if value.hasPrefix("--") {
                    return .success(.custom(value))
                }
                return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
            }
        case let .failure(error):
            return .failure(error)
        }
    }
}

// MARK: - Device CMYK Color

/// A color specified by cyan, magenta, yellow, and black components.
/// https://drafts.csswg.org/css-color-5/#device-cmyk
public struct DeviceCmyk: Equatable, Sendable, Hashable {
    /// The cyan component (0.0-1.0, or nil for "none").
    public let cyan: Double?
    /// The magenta component (0.0-1.0, or nil for "none").
    public let magenta: Double?
    /// The yellow component (0.0-1.0, or nil for "none").
    public let yellow: Double?
    /// The black component (0.0-1.0, or nil for "none").
    public let black: Double?
    /// The alpha component (0.0-1.0, or nil for "none").
    public let alpha: Double?

    public init(cyan: Double?, magenta: Double?, yellow: Double?, black: Double?, alpha: Double?) {
        self.cyan = cyan
        self.magenta = magenta
        self.yellow = yellow
        self.black = black
        self.alpha = alpha
    }
}

// MARK: - Color with Custom Space

/// A color specified by the color() function with a custom or device-cmyk color space.
/// Supports 3 or 4 components depending on the color space.
public struct ColorWithSpace: Equatable, Sendable, Hashable {
    /// The color space.
    public let colorSpace: ColorSpace
    /// The color components (3 for predefined, 4 for device-cmyk/custom).
    public let components: [Double?]
    /// The alpha component.
    public let alpha: Double?

    public init(colorSpace: ColorSpace, components: [Double?], alpha: Double?) {
        self.colorSpace = colorSpace
        self.components = components
        self.alpha = alpha
    }
}

// MARK: - Light-Dark Color

/// A color that varies between light and dark mode.
/// https://drafts.csswg.org/css-color-5/#light-dark
public struct LightDark<C: Equatable & Sendable & Hashable>: Equatable, Sendable, Hashable {
    /// The color to use in light mode.
    public let light: C
    /// The color to use in dark mode.
    public let dark: C

    public init(light: C, dark: C) {
        self.light = light
        self.dark = dark
    }
}

// MARK: - ColorFunction

/// A color specified by the color() function.
/// https://drafts.csswg.org/css-color-4/#color-function
public struct ColorFunction: Equatable, Sendable, Hashable {
    /// The color space for this color.
    public let colorSpace: PredefinedColorSpace
    /// The first component of the color. Either red or x.
    public let c1: Double?
    /// The second component of the color. Either green or y.
    public let c2: Double?
    /// The third component of the color. Either blue or z.
    public let c3: Double?
    /// The alpha component of the color.
    public let alpha: Double?

    public init(colorSpace: PredefinedColorSpace, c1: Double?, c2: Double?, c3: Double?, alpha: Double?) {
        self.colorSpace = colorSpace
        self.c1 = c1
        self.c2 = c2
        self.c3 = c3
        self.alpha = alpha
    }
}

// MARK: - Color Enum

/// Describes one of the <color> values according to the CSS specification.
///
/// Most components are `Optional`, so when the value is `nil`, that component
/// serializes to the "none" keyword.
///
/// https://drafts.csswg.org/css-color-4/#color-type
public enum Color: Equatable, Sendable, Hashable {
    /// The 'currentcolor' keyword.
    case currentColor
    /// Specify sRGB colors directly by their red/green/blue/alpha channels.
    case rgba(RgbaLegacy)
    /// Specifies a color in sRGB using hue, saturation and lightness components.
    case hsl(Hsl)
    /// Specifies a color in sRGB using hue, whiteness and blackness components.
    case hwb(Hwb)
    /// Specifies a CIELAB color by CIE Lightness and its a- and b-axis hue
    /// coordinates (red/green-ness, and yellow/blue-ness) using the CIE LAB
    /// rectangular coordinate model.
    case lab(Lab)
    /// Specifies a CIELAB color by CIE Lightness, Chroma, and hue using the
    /// CIE LCH cylindrical coordinate model.
    case lch(Lch)
    /// Specifies an Oklab color by Oklab Lightness and its a- and b-axis hue
    /// coordinates (red/green-ness, and yellow/blue-ness) using the Oklab
    /// rectangular coordinate model.
    case oklab(Oklab)
    /// Specifies an Oklab color by Oklab Lightness, Chroma, and hue using
    /// the OKLCH cylindrical coordinate model.
    case oklch(Oklch)
    /// Specifies a color in a predefined color space.
    case colorFunction(ColorFunction)
    /// Specifies a CMYK color using device-cmyk() or color(device-cmyk ...).
    /// https://drafts.csswg.org/css-color-5/#device-cmyk
    case deviceCmyk(DeviceCmyk)
    /// Specifies a color in a custom or extended color space.
    /// https://drafts.csswg.org/css-color-5/#color-function
    case colorWithSpace(ColorWithSpace)
}

// MARK: - Number/Percentage/Angle Helpers

/// Either a number or a percentage.
public enum NumberOrPercentage: Equatable, Sendable, Hashable {
    /// `<number>`.
    case number(Double)
    /// `<percentage>` (stored as unit value, i.e., divided by 100).
    case percentage(Double)

    /// The value as a percentage (unit value).
    public var unitValue: Double {
        switch self {
        case let .number(value): value
        case let .percentage(unitValue): unitValue
        }
    }

    /// Returns the value with percentages adjusted to the given basis.
    public func value(percentageBasis: Double) -> Double {
        switch self {
        case let .number(value): value
        case let .percentage(unitValue): unitValue * percentageBasis
        }
    }
}

/// Either an angle or a number.
public enum AngleOrNumber: Equatable, Sendable, Hashable {
    /// `<number>`.
    case number(Double)
    /// `<angle>` (stored as degrees).
    case angle(Double)

    /// The angle in degrees.
    public var degrees: Double {
        switch self {
        case let .number(value): value
        case let .angle(degrees): degrees
        }
    }
}

// MARK: - Utility Functions

/// The opaque alpha value of 1.0.
public let OPAQUE: Double = 1.0

/// Clamps a 0..1 unit value to a 0..255 range.
public func clampUnitF32(_ val: Double) -> UInt8 {
    clampFloor256F32(val * 255.0)
}

/// Round and clamp a single number to a UInt8.
public func clampFloor256F32(_ val: Double) -> UInt8 {
    let rounded = val.rounded()
    let clamped = min(max(rounded, 0), 255)
    return UInt8(clamping: Int(clamped))
}

/// Normalize hue to [0, 360) range.
/// https://drafts.csswg.org/css-values/#angles
func normalizeHue(_ hue: Double) -> Double {
    // Subtract an integer before rounding, to avoid some rounding errors:
    hue - 360.0 * (hue / 360.0).rounded(.down)
}

/// Converts a string to lowercase using ASCII-only case folding.
private func asciiLowercase(_ s: String) -> String {
    var result = ""
    result.reserveCapacity(s.utf8.count)
    for scalar in s.unicodeScalars {
        if scalar.value >= 0x41, scalar.value <= 0x5A {
            // ASCII A-Z -> a-z
            result.append(Character(UnicodeScalar(scalar.value + 32)!))
        } else {
            result.append(Character(scalar))
        }
    }
    return result
}

// MARK: - ColorFactory Protocol

/// A type that can create colors from parsed CSS color values.
public protocol ColorFactory {
    /// Creates a color from the CSS `currentcolor` keyword.
    static func makeCurrentColor() -> Self

    /// Creates a color from red, green, blue, and alpha components (0-255 range as Double).
    static func makeRgba(red: Double, green: Double, blue: Double, alpha: Double) -> Self

    /// Creates a color from hue, saturation, lightness, and alpha components.
    static func makeHsl(hue: Double?, saturation: Double?, lightness: Double?, alpha: Double?) -> Self

    /// Creates a color from hue, whiteness, blackness, and alpha components.
    static func makeHwb(hue: Double?, whiteness: Double?, blackness: Double?, alpha: Double?) -> Self

    /// Creates a color from the `lab` notation.
    static func makeLab(lightness: Double?, a: Double?, b: Double?, alpha: Double?) -> Self

    /// Creates a color from the `lch` notation.
    static func makeLch(lightness: Double?, chroma: Double?, hue: Double?, alpha: Double?) -> Self

    /// Creates a color from the `oklab` notation.
    static func makeOklab(lightness: Double?, a: Double?, b: Double?, alpha: Double?) -> Self

    /// Creates a color from the `oklch` notation.
    static func makeOklch(lightness: Double?, chroma: Double?, hue: Double?, alpha: Double?) -> Self

    /// Creates a color with a predefined color space.
    static func makeColorFunction(
        colorSpace: PredefinedColorSpace,
        c1: Double?, c2: Double?, c3: Double?,
        alpha: Double?
    ) -> Self

    /// Creates a device-cmyk color.
    static func makeDeviceCmyk(
        cyan: Double?, magenta: Double?, yellow: Double?, black: Double?,
        alpha: Double?
    ) -> Self

    /// Creates a color with a custom or extended color space.
    static func makeColorWithSpace(
        colorSpace: ColorSpace,
        components: [Double?],
        alpha: Double?
    ) -> Self
}

// MARK: - Color: ColorFactory

extension Color: ColorFactory {
    public static func makeCurrentColor() -> Self {
        .currentColor
    }

    public static func makeRgba(red: Double, green: Double, blue: Double, alpha: Double) -> Self {
        .rgba(RgbaLegacy(red: red, green: green, blue: blue, alpha: alpha))
    }

    public static func makeHsl(hue: Double?, saturation: Double?, lightness: Double?, alpha: Double?) -> Self {
        .hsl(Hsl(hue: hue, saturation: saturation, lightness: lightness, alpha: alpha))
    }

    public static func makeHwb(hue: Double?, whiteness: Double?, blackness: Double?, alpha: Double?) -> Self {
        .hwb(Hwb(hue: hue, whiteness: whiteness, blackness: blackness, alpha: alpha))
    }

    public static func makeLab(lightness: Double?, a: Double?, b: Double?, alpha: Double?) -> Self {
        .lab(Lab(lightness: lightness, a: a, b: b, alpha: alpha))
    }

    public static func makeLch(lightness: Double?, chroma: Double?, hue: Double?, alpha: Double?) -> Self {
        .lch(Lch(lightness: lightness, chroma: chroma, hue: hue, alpha: alpha))
    }

    public static func makeOklab(lightness: Double?, a: Double?, b: Double?, alpha: Double?) -> Self {
        .oklab(Oklab(lightness: lightness, a: a, b: b, alpha: alpha))
    }

    public static func makeOklch(lightness: Double?, chroma: Double?, hue: Double?, alpha: Double?) -> Self {
        .oklch(Oklch(lightness: lightness, chroma: chroma, hue: hue, alpha: alpha))
    }

    public static func makeColorFunction(
        colorSpace: PredefinedColorSpace,
        c1: Double?, c2: Double?, c3: Double?,
        alpha: Double?
    ) -> Self {
        .colorFunction(ColorFunction(colorSpace: colorSpace, c1: c1, c2: c2, c3: c3, alpha: alpha))
    }

    public static func makeDeviceCmyk(
        cyan: Double?, magenta: Double?, yellow: Double?, black: Double?,
        alpha: Double?
    ) -> Self {
        .deviceCmyk(DeviceCmyk(cyan: cyan, magenta: magenta, yellow: yellow, black: black, alpha: alpha))
    }

    public static func makeColorWithSpace(
        colorSpace: ColorSpace,
        components: [Double?],
        alpha: Double?
    ) -> Self {
        .colorWithSpace(ColorWithSpace(colorSpace: colorSpace, components: components, alpha: alpha))
    }
}

// MARK: - ColorParser Protocol

/// Protocol for customizing color component parsing behavior.
protocol ColorParser {
    /// The type that the parser will construct on a successful parse.
    associatedtype Output: ColorFactory
    /// A custom error type that can be returned from the parsing functions.
    associatedtype Error: Equatable & Sendable

    /// Parses an `<angle>` or `<number>`, returning degrees.
    func parseAngleOrNumber(_ input: Parser) -> Result<AngleOrNumber, ParseError<Error>>

    /// Parses a `<percentage>` value as a unit value (0.0 to 1.0).
    func parsePercentage(_ input: Parser) -> Result<Double, ParseError<Error>>

    /// Parses a `<number>` value.
    func parseNumber(_ input: Parser) -> Result<Double, ParseError<Error>>

    /// Parses a `<number>` or `<percentage>` value.
    func parseNumberOrPercentage(_ input: Parser) -> Result<NumberOrPercentage, ParseError<Error>>
}

// MARK: - DefaultColorParser

/// Default implementation of a `ColorParser`.
struct DefaultColorParser: ColorParser {
    typealias Output = Color
    typealias Error = Never

    func parseAngleOrNumber(_ input: Parser) -> Result<AngleOrNumber, ParseError<Never>> {
        let location = input.currentSourceLocation()
        switch input.next() {
        case let .success(token):
            switch token {
            case let .number(numeric):
                return .success(.number(numeric.value))
            case let .dimension(numeric, unit):
                let degrees: Double
                switch unit.value.lowercased() {
                case "deg":
                    degrees = numeric.value
                case "grad":
                    degrees = numeric.value * 360.0 / 400.0
                case "rad":
                    degrees = numeric.value * 360.0 / (2.0 * .pi)
                case "turn":
                    degrees = numeric.value * 360.0
                default:
                    return .failure(location.newUnexpectedTokenError(.ident(unit)))
                }
                return .success(.angle(degrees))
            default:
                return .failure(location.newUnexpectedTokenError(token))
            }
        case let .failure(error):
            return .failure(error.asParseError())
        }
    }

    func parsePercentage(_ input: Parser) -> Result<Double, ParseError<Never>> {
        input.expectPercentage().mapError { $0.asParseError() }
    }

    func parseNumber(_ input: Parser) -> Result<Double, ParseError<Never>> {
        input.expectNumber().mapError { $0.asParseError() }
    }

    func parseNumberOrPercentage(_ input: Parser) -> Result<NumberOrPercentage, ParseError<Never>> {
        let location = input.currentSourceLocation()
        switch input.next() {
        case let .success(token):
            switch token {
            case let .number(numeric):
                return .success(.number(numeric.value))
            case let .percentage(numeric):
                return .success(.percentage(numeric.value))
            default:
                return .failure(location.newUnexpectedTokenError(token))
            }
        case let .failure(error):
            return .failure(error.asParseError())
        }
    }
}

// MARK: - Color Parsing

/// Returns the named color with the given name (ASCII case-insensitive).
public func parseColorKeyword<Output: ColorFactory>(_ ident: String) -> Output? {
    let lower = asciiLowercase(ident)
    switch lower {
    case "transparent":
        return Output.makeRgba(red: 0, green: 0, blue: 0, alpha: 0.0)
    case "currentcolor":
        return Output.makeCurrentColor()
    default:
        if let rgb = namedColors[lower] {
            return Output.makeRgba(red: Double(rgb.red), green: Double(rgb.green), blue: Double(rgb.blue), alpha: OPAQUE)
        }
        return nil
    }
}

/// Parses a CSS color using the specified parser.
func parseColorWith<P: ColorParser>(
    _ colorParser: P,
    input: Parser
) -> Result<P.Output, ParseError<P.Error>> {
    let location = input.currentSourceLocation()
    switch input.next() {
    case let .success(token):
        switch token {
        case let .hash(value), let .idHash(value):
            if let rgba = parseHashColor(value.value) {
                return .success(P.Output.makeRgba(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha))
            }
            return .failure(location.newUnexpectedTokenError(token))

        case let .ident(value):
            if let color: P.Output = parseColorKeyword(value.value) {
                return .success(color)
            }
            return .failure(location.newUnexpectedTokenError(token))

        case let .function(name):
            return input.parseNestedBlock { arguments in
                parseColorFunction(colorParser, name: name.value, arguments: arguments)
            }

        default:
            return .failure(location.newUnexpectedTokenError(token))
        }

    case let .failure(error):
        return .failure(error.asParseError())
    }
}

/// Parses a color function: rgb(), hsl(), lab(), color(), etc.
private func parseColorFunction<P: ColorParser>(
    _ colorParser: P,
    name: String,
    arguments: Parser
) -> Result<P.Output, ParseError<P.Error>> {
    let color: Result<P.Output, ParseError<P.Error>>
    switch name.lowercased() {
    case "rgb", "rgba":
        color = parseRgb(colorParser, arguments: arguments)
    case "hsl", "hsla":
        color = parseHsl(colorParser, arguments: arguments)
    case "hwb":
        color = parseHwb(colorParser, arguments: arguments)
    case "lab":
        // for L: 0% = 0.0, 100% = 100.0
        // for a and b: -100% = -125, 100% = 125
        color = parseLabLike(colorParser, arguments: arguments, lightnessRange: 100.0, abRange: 125.0) {
            P.Output.makeLab(lightness: $0, a: $1, b: $2, alpha: $3)
        }
    case "lch":
        // for L: 0% = 0.0, 100% = 100.0
        // for C: 0% = 0, 100% = 150
        color = parseLchLike(colorParser, arguments: arguments, lightnessRange: 100.0, chromaRange: 150.0) {
            P.Output.makeLch(lightness: $0, chroma: $1, hue: $2, alpha: $3)
        }
    case "oklab":
        // for L: 0% = 0.0, 100% = 1.0
        // for a and b: -100% = -0.4, 100% = 0.4
        color = parseLabLike(colorParser, arguments: arguments, lightnessRange: 1.0, abRange: 0.4) {
            P.Output.makeOklab(lightness: $0, a: $1, b: $2, alpha: $3)
        }
    case "oklch":
        // for L: 0% = 0.0, 100% = 1.0
        // for C: 0% = 0.0, 100% = 0.4
        color = parseLchLike(colorParser, arguments: arguments, lightnessRange: 1.0, chromaRange: 0.4) {
            P.Output.makeOklch(lightness: $0, chroma: $1, hue: $2, alpha: $3)
        }
    case "color":
        color = parseColorWithColorSpaceLevel5(colorParser, arguments: arguments)
    case "device-cmyk":
        color = parseDeviceCmyk(colorParser, arguments: arguments)
    default:
        return .failure(arguments.newUnexpectedTokenError(.ident(Lexeme(name))))
    }

    // Verify exhausted
    switch color {
    case let .success(value):
        switch arguments.expectExhausted() {
        case .success:
            return .success(value)
        case let .failure(error):
            return .failure(error.asParseError())
        }
    case let .failure(error):
        return .failure(error)
    }
}

// MARK: - RGB Parsing

private func parseRgb<P: ColorParser>(
    _ colorParser: P,
    arguments: Parser
) -> Result<P.Output, ParseError<P.Error>> {
    // Parse first component, checking for "none"
    let maybeRed: NumberOrPercentage?
    switch parseNoneOr(arguments, { colorParser.parseNumberOrPercentage($0) }) {
    case let .success(value): maybeRed = value
    case let .failure(error): return .failure(error)
    }

    // If the first component is not "none" and is followed by a comma, then we
    // are parsing the legacy syntax.
    let isLegacySyntax = maybeRed != nil && arguments.tryParse { $0.expectComma() }.isOK

    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    if isLegacySyntax {
        // Legacy syntax: rgb(255, 0, 0) or rgb(100%, 0%, 0%)
        switch maybeRed! {
        case let .number(value):
            red = value
            switch colorParser.parseNumber(arguments) {
            case let .success(g): green = g
            case let .failure(error): return .failure(error)
            }
            if case let .failure(error) = arguments.expectComma() {
                return .failure(error.asParseError())
            }
            switch colorParser.parseNumber(arguments) {
            case let .success(b): blue = b
            case let .failure(error): return .failure(error)
            }
        case let .percentage(unitValue):
            red = unitValue * 255.0
            switch colorParser.parsePercentage(arguments) {
            case let .success(g): green = g * 255.0
            case let .failure(error): return .failure(error)
            }
            if case let .failure(error) = arguments.expectComma() {
                return .failure(error.asParseError())
            }
            switch colorParser.parsePercentage(arguments) {
            case let .success(b): blue = b * 255.0
            case let .failure(error): return .failure(error)
            }
        }

        switch parseLegacyAlpha(colorParser, arguments: arguments) {
        case let .success(a): alpha = a
        case let .failure(error): return .failure(error)
        }
    } else {
        // Modern syntax: rgb(255 0 0) or rgb(255 0 0 / 50%)
        func getComponentValue(_ c: NumberOrPercentage?) -> Double {
            guard let c else { return 0 }
            switch c {
            case let .number(value): return value
            case let .percentage(unitValue): return unitValue * 255.0
            }
        }

        red = getComponentValue(maybeRed)

        switch parseNoneOr(arguments, { colorParser.parseNumberOrPercentage($0) }) {
        case let .success(g): green = getComponentValue(g)
        case let .failure(error): return .failure(error)
        }

        switch parseNoneOr(arguments, { colorParser.parseNumberOrPercentage($0) }) {
        case let .success(b): blue = getComponentValue(b)
        case let .failure(error): return .failure(error)
        }

        switch parseModernAlpha(colorParser, arguments: arguments) {
        case let .success(a): alpha = a ?? OPAQUE
        case let .failure(error): return .failure(error)
        }
    }

    return .success(P.Output.makeRgba(red: red, green: green, blue: blue, alpha: alpha))
}

// MARK: - HSL Parsing

private func parseHsl<P: ColorParser>(
    _ colorParser: P,
    arguments: Parser
) -> Result<P.Output, ParseError<P.Error>> {
    // Parse hue, checking for "none"
    let maybeHue: AngleOrNumber?
    switch parseNoneOr(arguments, { colorParser.parseAngleOrNumber($0) }) {
    case let .success(value): maybeHue = value
    case let .failure(error): return .failure(error)
    }

    // If the hue is not "none" and is followed by a comma, then we are parsing
    // the legacy syntax.
    let isLegacySyntax = maybeHue != nil && arguments.tryParse { $0.expectComma() }.isOK

    let saturation: Double?
    let lightness: Double?
    let alpha: Double?

    if isLegacySyntax {
        switch colorParser.parsePercentage(arguments) {
        case let .success(s): saturation = s
        case let .failure(error): return .failure(error)
        }
        if case let .failure(error) = arguments.expectComma() {
            return .failure(error.asParseError())
        }
        switch colorParser.parsePercentage(arguments) {
        case let .success(l): lightness = l
        case let .failure(error): return .failure(error)
        }
        switch parseLegacyAlpha(colorParser, arguments: arguments) {
        case let .success(a): alpha = a
        case let .failure(error): return .failure(error)
        }
    } else {
        // Modern syntax: numbers are treated as percentages
        func parsePercentageOrNumber(_ input: Parser) -> Result<Double, ParseError<P.Error>> {
            switch colorParser.parseNumberOrPercentage(input) {
            case let .success(value):
                switch value {
                case let .number(num): .success(num / 100.0)
                case let .percentage(pct): .success(pct)
                }
            case let .failure(error):
                .failure(error)
            }
        }

        switch parseNoneOr(arguments, parsePercentageOrNumber) {
        case let .success(s): saturation = s
        case let .failure(error): return .failure(error)
        }
        switch parseNoneOr(arguments, parsePercentageOrNumber) {
        case let .success(l): lightness = l
        case let .failure(error): return .failure(error)
        }
        switch parseModernAlpha(colorParser, arguments: arguments) {
        case let .success(a): alpha = a
        case let .failure(error): return .failure(error)
        }
    }

    let hue = maybeHue.map { normalizeHue($0.degrees) }
    let clampedSaturation = saturation.map { $0.clamped(to: 0.0 ... 1.0) }
    let clampedLightness = lightness.map { $0.clamped(to: 0.0 ... 1.0) }

    return .success(P.Output.makeHsl(hue: hue, saturation: clampedSaturation, lightness: clampedLightness, alpha: alpha))
}

// MARK: - HWB Parsing

private func parseHwb<P: ColorParser>(
    _ colorParser: P,
    arguments: Parser
) -> Result<P.Output, ParseError<P.Error>> {
    // Modern syntax: numbers are treated as percentages
    func parsePercentageOrNumber(_ input: Parser) -> Result<Double, ParseError<P.Error>> {
        switch colorParser.parseNumberOrPercentage(input) {
        case let .success(value):
            switch value {
            case let .number(num): .success(num / 100.0)
            case let .percentage(pct): .success(pct)
            }
        case let .failure(error):
            .failure(error)
        }
    }

    switch parseComponents(
        colorParser,
        arguments: arguments,
        f1: { colorParser.parseAngleOrNumber($0) },
        f2: parsePercentageOrNumber,
        f3: parsePercentageOrNumber
    ) {
    case .success(let (hue, whiteness, blackness, alpha)):
        let normalizedHue = hue.map { normalizeHue($0.degrees) }
        let clampedWhiteness = whiteness.map { $0.clamped(to: 0.0 ... 1.0) }
        let clampedBlackness = blackness.map { $0.clamped(to: 0.0 ... 1.0) }
        return .success(P.Output.makeHwb(hue: normalizedHue, whiteness: clampedWhiteness, blackness: clampedBlackness, alpha: alpha))
    case let .failure(error):
        return .failure(error)
    }
}

// MARK: - Lab-like Parsing

private func parseLabLike<P: ColorParser>(
    _ colorParser: P,
    arguments: Parser,
    lightnessRange: Double,
    abRange: Double,
    intoColor: (Double?, Double?, Double?, Double?) -> P.Output
) -> Result<P.Output, ParseError<P.Error>> {
    switch parseComponents(
        colorParser,
        arguments: arguments,
        f1: { colorParser.parseNumberOrPercentage($0) },
        f2: { colorParser.parseNumberOrPercentage($0) },
        f3: { colorParser.parseNumberOrPercentage($0) }
    ) {
    case .success(let (lightness, a, b, alpha)):
        let l = lightness.map { $0.value(percentageBasis: lightnessRange) }
        let aVal = a.map { $0.value(percentageBasis: abRange) }
        let bVal = b.map { $0.value(percentageBasis: abRange) }
        return .success(intoColor(l, aVal, bVal, alpha))
    case let .failure(error):
        return .failure(error)
    }
}

// MARK: - LCH-like Parsing

private func parseLchLike<P: ColorParser>(
    _ colorParser: P,
    arguments: Parser,
    lightnessRange: Double,
    chromaRange: Double,
    intoColor: (Double?, Double?, Double?, Double?) -> P.Output
) -> Result<P.Output, ParseError<P.Error>> {
    switch parseComponents(
        colorParser,
        arguments: arguments,
        f1: { colorParser.parseNumberOrPercentage($0) },
        f2: { colorParser.parseNumberOrPercentage($0) },
        f3: { colorParser.parseAngleOrNumber($0) }
    ) {
    case .success(let (lightness, chroma, hue, alpha)):
        let l = lightness.map { $0.value(percentageBasis: lightnessRange) }
        let c = chroma.map { $0.value(percentageBasis: chromaRange) }
        let h = hue.map { normalizeHue($0.degrees) }
        return .success(intoColor(l, c, h, alpha))
    case let .failure(error):
        return .failure(error)
    }
}

// MARK: - color() Function Parsing

private func parseColorWithColorSpaceLevel5<P: ColorParser>(
    _ colorParser: P,
    arguments: Parser
) -> Result<P.Output, ParseError<P.Error>> {
    let colorSpace: ColorSpace
    switch ColorSpace.parse(arguments) {
    case let .success(cs): colorSpace = cs
    case let .failure(error): return .failure(error.asParseError())
    }

    // Device-CMYK and custom color spaces take 4 components
    switch colorSpace {
    case let .predefined(predefined):
        // Standard 3-component color space
        switch parseComponents(
            colorParser,
            arguments: arguments,
            f1: { colorParser.parseNumberOrPercentage($0) },
            f2: { colorParser.parseNumberOrPercentage($0) },
            f3: { colorParser.parseNumberOrPercentage($0) }
        ) {
        case .success(let (c1, c2, c3, alpha)):
            let c1Val = c1.map(\.unitValue)
            let c2Val = c2.map(\.unitValue)
            let c3Val = c3.map(\.unitValue)
            return .success(P.Output.makeColorFunction(colorSpace: predefined, c1: c1Val, c2: c2Val, c3: c3Val, alpha: alpha))
        case let .failure(error):
            return .failure(error)
        }

    case .deviceCmyk:
        // CMYK takes 4 components
        switch parse4Components(colorParser, arguments: arguments) {
        case .success(let (c1, c2, c3, c4, alpha)):
            let cyan = c1.map { $0.unitValue.clamped(to: 0.0 ... 1.0) }
            let magenta = c2.map { $0.unitValue.clamped(to: 0.0 ... 1.0) }
            let yellow = c3.map { $0.unitValue.clamped(to: 0.0 ... 1.0) }
            let black = c4.map { $0.unitValue.clamped(to: 0.0 ... 1.0) }
            return .success(P.Output.makeDeviceCmyk(cyan: cyan, magenta: magenta, yellow: yellow, black: black, alpha: alpha))
        case let .failure(error):
            return .failure(error)
        }

    case .custom:
        // Custom color spaces take 4 components
        switch parse4Components(colorParser, arguments: arguments) {
        case .success(let (c1, c2, c3, c4, alpha)):
            let components = [
                c1.map(\.unitValue),
                c2.map(\.unitValue),
                c3.map(\.unitValue),
                c4.map(\.unitValue),
            ]
            return .success(P.Output.makeColorWithSpace(colorSpace: colorSpace, components: components, alpha: alpha))
        case let .failure(error):
            return .failure(error)
        }
    }
}

// MARK: - device-cmyk() Function Parsing

private func parseDeviceCmyk<P: ColorParser>(
    _ colorParser: P,
    arguments: Parser
) -> Result<P.Output, ParseError<P.Error>> {
    // Parse first component
    let maybeC1: NumberOrPercentage?
    switch parseNoneOr(arguments, { colorParser.parseNumberOrPercentage($0) }) {
    case let .success(value): maybeC1 = value
    case let .failure(error): return .failure(error)
    }

    // Check for legacy comma syntax
    let isLegacySyntax = maybeC1 != nil && arguments.tryParse { $0.expectComma() }.isOK

    if isLegacySyntax {
        // Legacy syntax: device-cmyk(c, m, y, k) - only numbers allowed
        guard case let .number(c1Val) = maybeC1 else {
            return .failure(arguments.newUnexpectedTokenError(.ident(Lexeme("percentage"))))
        }

        // Parse remaining 3 components with commas
        let c2Val: Double
        switch colorParser.parseNumber(arguments) {
        case let .success(v): c2Val = v
        case let .failure(error): return .failure(error)
        }
        if case let .failure(error) = arguments.expectComma() {
            return .failure(error.asParseError())
        }

        let c3Val: Double
        switch colorParser.parseNumber(arguments) {
        case let .success(v): c3Val = v
        case let .failure(error): return .failure(error)
        }
        if case let .failure(error) = arguments.expectComma() {
            return .failure(error.asParseError())
        }

        let c4Val: Double
        switch colorParser.parseNumber(arguments) {
        case let .success(v): c4Val = v
        case let .failure(error): return .failure(error)
        }

        // Legacy syntax with commas - alpha uses comma separator
        let alpha: Double
        switch parseLegacyAlpha(colorParser, arguments: arguments) {
        case let .success(a): alpha = a
        case let .failure(error): return .failure(error)
        }

        return .success(P.Output.makeDeviceCmyk(
            cyan: c1Val.clamped(to: 0.0 ... 1.0),
            magenta: c2Val.clamped(to: 0.0 ... 1.0),
            yellow: c3Val.clamped(to: 0.0 ... 1.0),
            black: c4Val.clamped(to: 0.0 ... 1.0),
            alpha: alpha
        ))
    } else {
        // Modern syntax: device-cmyk(c m y k) or device-cmyk(c m y k / alpha)
        func getValue(_ nop: NumberOrPercentage?) -> Double? {
            nop.map { $0.unitValue.clamped(to: 0.0 ... 1.0) }
        }

        let c1 = getValue(maybeC1)

        let maybeC2: NumberOrPercentage?
        switch parseNoneOr(arguments, { colorParser.parseNumberOrPercentage($0) }) {
        case let .success(v): maybeC2 = v
        case let .failure(error): return .failure(error)
        }

        let maybeC3: NumberOrPercentage?
        switch parseNoneOr(arguments, { colorParser.parseNumberOrPercentage($0) }) {
        case let .success(v): maybeC3 = v
        case let .failure(error): return .failure(error)
        }

        let maybeC4: NumberOrPercentage?
        switch parseNoneOr(arguments, { colorParser.parseNumberOrPercentage($0) }) {
        case let .success(v): maybeC4 = v
        case let .failure(error): return .failure(error)
        }

        let alpha: Double?
        switch parseModernAlpha(colorParser, arguments: arguments) {
        case let .success(a): alpha = a
        case let .failure(error): return .failure(error)
        }

        return .success(P.Output.makeDeviceCmyk(
            cyan: c1,
            magenta: getValue(maybeC2),
            yellow: getValue(maybeC3),
            black: getValue(maybeC4),
            alpha: alpha
        ))
    }
}

// MARK: - Component Parsing Helpers

/// Parses three color components and alpha with the modern syntax.
private func parseComponents<P: ColorParser, R1, R2, R3>(
    _ colorParser: P,
    arguments: Parser,
    f1: (Parser) -> Result<R1, ParseError<P.Error>>,
    f2: (Parser) -> Result<R2, ParseError<P.Error>>,
    f3: (Parser) -> Result<R3, ParseError<P.Error>>
) -> Result<(R1?, R2?, R3?, Double?), ParseError<P.Error>> {
    let r1: R1?
    switch parseNoneOr(arguments, f1) {
    case let .success(value): r1 = value
    case let .failure(error): return .failure(error)
    }

    let r2: R2?
    switch parseNoneOr(arguments, f2) {
    case let .success(value): r2 = value
    case let .failure(error): return .failure(error)
    }

    let r3: R3?
    switch parseNoneOr(arguments, f3) {
    case let .success(value): r3 = value
    case let .failure(error): return .failure(error)
    }

    let alpha: Double?
    switch parseModernAlpha(colorParser, arguments: arguments) {
    case let .success(alphaValue): alpha = alphaValue
    case let .failure(error): return .failure(error)
    }

    return .success((r1, r2, r3, alpha))
}

/// Parses four color components and alpha with the modern syntax.
private func parse4Components<P: ColorParser>(
    _ colorParser: P,
    arguments: Parser
) -> Result<(NumberOrPercentage?, NumberOrPercentage?, NumberOrPercentage?, NumberOrPercentage?, Double?), ParseError<P.Error>> {
    let r1: NumberOrPercentage?
    switch parseNoneOr(arguments, { colorParser.parseNumberOrPercentage($0) }) {
    case let .success(value): r1 = value
    case let .failure(error): return .failure(error)
    }

    let r2: NumberOrPercentage?
    switch parseNoneOr(arguments, { colorParser.parseNumberOrPercentage($0) }) {
    case let .success(value): r2 = value
    case let .failure(error): return .failure(error)
    }

    let r3: NumberOrPercentage?
    switch parseNoneOr(arguments, { colorParser.parseNumberOrPercentage($0) }) {
    case let .success(value): r3 = value
    case let .failure(error): return .failure(error)
    }

    let r4: NumberOrPercentage?
    switch parseNoneOr(arguments, { colorParser.parseNumberOrPercentage($0) }) {
    case let .success(value): r4 = value
    case let .failure(error): return .failure(error)
    }

    let alpha: Double?
    switch parseModernAlpha(colorParser, arguments: arguments) {
    case let .success(alphaValue): alpha = alphaValue
    case let .failure(error): return .failure(error)
    }

    return .success((r1, r2, r3, r4, alpha))
}

/// Parse "none" or call the provided parser.
private func parseNoneOr<T, E: Equatable>(
    _ input: Parser,
    _ thing: (Parser) -> Result<T, ParseError<E>>
) -> Result<T?, ParseError<E>> {
    if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
        return .success(nil)
    }
    switch thing(input) {
    case let .success(value): return .success(value)
    case let .failure(error): return .failure(error)
    }
}

// MARK: - Alpha Parsing

/// Parses the alpha component, clipping the result to [0.0..1.0].
private func parseAlphaComponent<P: ColorParser>(
    _ colorParser: P,
    arguments: Parser
) -> Result<Double, ParseError<P.Error>> {
    switch colorParser.parseNumberOrPercentage(arguments) {
    case let .success(value):
        .success(value.unitValue.clamped(to: 0.0 ... OPAQUE))
    case let .failure(error):
        .failure(error)
    }
}

/// Parses legacy alpha (comma-separated).
private func parseLegacyAlpha<P: ColorParser>(
    _ colorParser: P,
    arguments: Parser
) -> Result<Double, ParseError<P.Error>> {
    if arguments.isExhausted {
        return .success(OPAQUE)
    }
    if case let .failure(error) = arguments.expectComma() {
        return .failure(error.asParseError())
    }
    return parseAlphaComponent(colorParser, arguments: arguments)
}

/// Parses modern alpha (slash-separated, supports "none").
private func parseModernAlpha<P: ColorParser>(
    _ colorParser: P,
    arguments: Parser
) -> Result<Double?, ParseError<P.Error>> {
    if arguments.isExhausted {
        return .success(OPAQUE)
    }
    if case let .failure(error) = arguments.expectDelim("/") {
        return .failure(error.asParseError())
    }
    return parseNoneOr(arguments) { parseAlphaComponent(colorParser, arguments: $0) }
}

// MARK: - Hash Color Parsing

/// Parses a color hash without the leading '#' character.
public func parseHashColor(_ value: String) -> RgbaLegacy? {
    let bytes = Array(value.utf8)
    return parseHashColorBytes(bytes)
}

/// Parses a color hash from bytes without the leading '#' character.
func parseHashColorBytes(_ value: [UInt8]) -> RgbaLegacy? {
    switch value.count {
    case 8:
        guard let red1 = fromHex(value[0]), let red2 = fromHex(value[1]),
              let green1 = fromHex(value[2]), let green2 = fromHex(value[3]),
              let blue1 = fromHex(value[4]), let blue2 = fromHex(value[5]),
              let alpha1 = fromHex(value[6]), let alpha2 = fromHex(value[7])
        else {
            return nil
        }
        return RgbaLegacy(
            red: red1 * 16 + red2,
            green: green1 * 16 + green2,
            blue: blue1 * 16 + blue2,
            alpha: Double(alpha1 * 16 + alpha2) / 255.0
        )
    case 6:
        guard let red1 = fromHex(value[0]), let red2 = fromHex(value[1]),
              let green1 = fromHex(value[2]), let green2 = fromHex(value[3]),
              let blue1 = fromHex(value[4]), let blue2 = fromHex(value[5])
        else {
            return nil
        }
        return RgbaLegacy(
            red: red1 * 16 + red2,
            green: green1 * 16 + green2,
            blue: blue1 * 16 + blue2,
            alpha: OPAQUE
        )
    case 4:
        guard let red = fromHex(value[0]), let green = fromHex(value[1]),
              let blue = fromHex(value[2]), let alpha = fromHex(value[3])
        else {
            return nil
        }
        return RgbaLegacy(
            red: red * 17,
            green: green * 17,
            blue: blue * 17,
            alpha: Double(alpha * 17) / 255.0
        )
    case 3:
        guard let red = fromHex(value[0]), let green = fromHex(value[1]),
              let blue = fromHex(value[2])
        else {
            return nil
        }
        return RgbaLegacy(red: red * 17, green: green * 17, blue: blue * 17, alpha: OPAQUE)
    default:
        return nil
    }
}

/// Returns the named color with the given name (ASCII case-insensitive).
public func parseNamedColor(_ ident: String) -> RGBColor? {
    namedColors[asciiLowercase(ident)]
}

/// Returns an iterator over all named CSS colors.
public func allNamedColors() -> Dictionary<String, RGBColor>.Iterator {
    namedColors.makeIterator()
}

private func fromHex(_ char: UInt8) -> UInt8? {
    switch char {
    case UInt8(ascii: "0") ... UInt8(ascii: "9"):
        char - UInt8(ascii: "0")
    case UInt8(ascii: "a") ... UInt8(ascii: "f"):
        char - UInt8(ascii: "a") + 10
    case UInt8(ascii: "A") ... UInt8(ascii: "F"):
        char - UInt8(ascii: "A") + 10
    default:
        nil
    }
}

// MARK: - Color.parse Convenience

extension Color {
    /// Parses a `<color>` value using the default color parser.
    static func parse(_ input: Parser) -> Result<Color, ParseError<Never>> {
        parseColorWith(DefaultColorParser(), input: input)
    }
}

// MARK: - Clamped Extension

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Serialize Color Alpha

/// Serializes the alpha component of a color.
public func serializeColorAlpha(dest: inout some CSSWriter, alpha: Double?, legacySyntax: Bool) {
    guard let alpha else {
        dest.write(" / none")
        return
    }

    // If the alpha component is fully opaque, don't emit the alpha value in CSS.
    if alpha == OPAQUE {
        return
    }

    dest.write(legacySyntax ? ", " : " / ")

    // Serialize with minimal decimal places needed
    // Start with fewer decimals and increase until the value is accurate
    for decimals in 2 ... 6 {
        let multiplier = pow(10.0, Double(decimals))
        let rounded = (alpha * multiplier).rounded() / multiplier
        if abs(rounded - alpha) < 1e-7 {
            // Use FormatStyle for consistent formatting
            let formatted = rounded.formatted(
                .number
                    .precision(.fractionLength(0 ... decimals))
                    .rounded(rule: .toNearestOrAwayFromZero)
            )
            dest.write(formatted)
            return
        }
    }

    // Fallback to 6 decimal places
    let formatted = alpha.formatted(
        .number
            .precision(.fractionLength(0 ... 6))
            .rounded(rule: .toNearestOrAwayFromZero)
    )
    dest.write(formatted)
}

// MARK: - ToCss Conformance

extension PredefinedColorSpace: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .srgb: dest.write("srgb")
        case .srgbLinear: dest.write("srgb-linear")
        case .displayP3: dest.write("display-p3")
        case .displayP3Linear: dest.write("display-p3-linear")
        case .a98Rgb: dest.write("a98-rgb")
        case .prophotoRgb: dest.write("prophoto-rgb")
        case .rec2020: dest.write("rec2020")
        case .xyzD50: dest.write("xyz-d50")
        case .xyzD65: dest.write("xyz-d65")
        }
    }
}

/// A helper for serializing modern color components that support "none".
private struct ModernComponent {
    let value: Double?

    func serialize(dest: inout some CSSWriter) {
        if let value {
            if value.isFinite {
                value.serialize(dest: &dest)
            } else if value.isNaN {
                dest.write("calc(NaN)")
            } else {
                // Infinite
                if value.sign == .minus {
                    dest.write("calc(-infinity)")
                } else {
                    dest.write("calc(infinity)")
                }
            }
        } else {
            dest.write("none")
        }
    }
}

/// Serializes a color channel value, using integer format when possible.
/// Uses up to 6 decimal places for non-integers (matching browser behavior).
private func serializeColorChannel(_ value: Double, dest: inout some CSSWriter) {
    // If the value is a whole number, serialize as integer
    if value.truncatingRemainder(dividingBy: 1) == 0, value >= 0, value <= Double(Int.max) {
        dest.write(String(Int(value)))
    } else {
        // Use up to 6 decimal places with standard rounding
        let formatted = value.formatted(
            .number
                .precision(.fractionLength(0 ... 6))
                .rounded(rule: .toNearestOrAwayFromZero)
        )
        dest.write(formatted)
    }
}

extension RgbaLegacy: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        let hasAlpha = alpha != OPAQUE

        dest.write(hasAlpha ? "rgba(" : "rgb(")
        serializeColorChannel(red, dest: &dest)
        dest.write(", ")
        serializeColorChannel(green, dest: &dest)
        dest.write(", ")
        serializeColorChannel(blue, dest: &dest)

        // Legacy syntax does not allow none components.
        serializeColorAlpha(dest: &dest, alpha: alpha, legacySyntax: true)

        dest.write(")")
    }
}

extension Hsl: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        let rgb = hslToRgb(
            hue: (hue ?? 0.0) / 360.0,
            saturation: saturation ?? 0.0,
            lightness: lightness ?? 0.0
        )
        RgbaLegacy(normalizedRed: rgb.red, green: rgb.green, blue: rgb.blue, alpha: alpha ?? OPAQUE).serialize(dest: &dest)
    }
}

extension Hwb: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        let rgb = hwbToRgb(
            hue: (hue ?? 0.0) / 360.0,
            whiteness: whiteness ?? 0.0,
            blackness: blackness ?? 0.0
        )
        RgbaLegacy(normalizedRed: rgb.red, green: rgb.green, blue: rgb.blue, alpha: alpha ?? OPAQUE).serialize(dest: &dest)
    }
}

extension Lab: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("lab(")
        ModernComponent(value: lightness).serialize(dest: &dest)
        dest.write(" ")
        ModernComponent(value: a).serialize(dest: &dest)
        dest.write(" ")
        ModernComponent(value: b).serialize(dest: &dest)
        serializeColorAlpha(dest: &dest, alpha: alpha, legacySyntax: false)
        dest.write(")")
    }
}

extension Lch: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("lch(")
        ModernComponent(value: lightness).serialize(dest: &dest)
        dest.write(" ")
        ModernComponent(value: chroma).serialize(dest: &dest)
        dest.write(" ")
        ModernComponent(value: hue).serialize(dest: &dest)
        serializeColorAlpha(dest: &dest, alpha: alpha, legacySyntax: false)
        dest.write(")")
    }
}

extension Oklab: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("oklab(")
        ModernComponent(value: lightness).serialize(dest: &dest)
        dest.write(" ")
        ModernComponent(value: a).serialize(dest: &dest)
        dest.write(" ")
        ModernComponent(value: b).serialize(dest: &dest)
        serializeColorAlpha(dest: &dest, alpha: alpha, legacySyntax: false)
        dest.write(")")
    }
}

extension Oklch: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("oklch(")
        ModernComponent(value: lightness).serialize(dest: &dest)
        dest.write(" ")
        ModernComponent(value: chroma).serialize(dest: &dest)
        dest.write(" ")
        ModernComponent(value: hue).serialize(dest: &dest)
        serializeColorAlpha(dest: &dest, alpha: alpha, legacySyntax: false)
        dest.write(")")
    }
}

extension ColorFunction: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("color(")
        colorSpace.serialize(dest: &dest)
        dest.write(" ")
        ModernComponent(value: c1).serialize(dest: &dest)
        dest.write(" ")
        ModernComponent(value: c2).serialize(dest: &dest)
        dest.write(" ")
        ModernComponent(value: c3).serialize(dest: &dest)
        serializeColorAlpha(dest: &dest, alpha: alpha, legacySyntax: false)
        dest.write(")")
    }
}

extension ColorSpace: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .predefined(predefined):
            predefined.serialize(dest: &dest)
        case .deviceCmyk:
            dest.write("device-cmyk")
        case let .custom(name):
            dest.write(name)
        }
    }
}

extension DeviceCmyk: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("color(device-cmyk ")
        ModernComponent(value: cyan).serialize(dest: &dest)
        dest.write(" ")
        ModernComponent(value: magenta).serialize(dest: &dest)
        dest.write(" ")
        ModernComponent(value: yellow).serialize(dest: &dest)
        dest.write(" ")
        ModernComponent(value: black).serialize(dest: &dest)
        serializeColorAlpha(dest: &dest, alpha: alpha, legacySyntax: false)
        dest.write(")")
    }
}

extension ColorWithSpace: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("color(")
        colorSpace.serialize(dest: &dest)
        for component in components {
            dest.write(" ")
            ModernComponent(value: component).serialize(dest: &dest)
        }
        serializeColorAlpha(dest: &dest, alpha: alpha, legacySyntax: false)
        dest.write(")")
    }
}

extension Color: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .currentColor:
            dest.write("currentcolor")
        case let .rgba(rgba):
            rgba.serialize(dest: &dest)
        case let .hsl(hsl):
            hsl.serialize(dest: &dest)
        case let .hwb(hwb):
            hwb.serialize(dest: &dest)
        case let .lab(lab):
            lab.serialize(dest: &dest)
        case let .lch(lch):
            lch.serialize(dest: &dest)
        case let .oklab(oklab):
            oklab.serialize(dest: &dest)
        case let .oklch(oklch):
            oklch.serialize(dest: &dest)
        case let .colorFunction(colorFunction):
            colorFunction.serialize(dest: &dest)
        case let .deviceCmyk(deviceCmyk):
            deviceCmyk.serialize(dest: &dest)
        case let .colorWithSpace(colorWithSpace):
            colorWithSpace.serialize(dest: &dest)
        }
    }
}

// MARK: - Named Colors

/// Creates an RGB color concisely.
private func rgb(_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> RGBColor {
    RGBColor(red: red, green: green, blue: blue)
}

/// All CSS named colors.
/// https://drafts.csswg.org/css-color-4/#typedef-named-color
private let namedColors: [String: RGBColor] = [
    "black": rgb(0, 0, 0),
    "silver": rgb(192, 192, 192),
    "gray": rgb(128, 128, 128),
    "white": rgb(255, 255, 255),
    "maroon": rgb(128, 0, 0),
    "red": rgb(255, 0, 0),
    "purple": rgb(128, 0, 128),
    "fuchsia": rgb(255, 0, 255),
    "green": rgb(0, 128, 0),
    "lime": rgb(0, 255, 0),
    "olive": rgb(128, 128, 0),
    "yellow": rgb(255, 255, 0),
    "navy": rgb(0, 0, 128),
    "blue": rgb(0, 0, 255),
    "teal": rgb(0, 128, 128),
    "aqua": rgb(0, 255, 255),

    "aliceblue": rgb(240, 248, 255),
    "antiquewhite": rgb(250, 235, 215),
    "aquamarine": rgb(127, 255, 212),
    "azure": rgb(240, 255, 255),
    "beige": rgb(245, 245, 220),
    "bisque": rgb(255, 228, 196),
    "blanchedalmond": rgb(255, 235, 205),
    "blueviolet": rgb(138, 43, 226),
    "brown": rgb(165, 42, 42),
    "burlywood": rgb(222, 184, 135),
    "cadetblue": rgb(95, 158, 160),
    "chartreuse": rgb(127, 255, 0),
    "chocolate": rgb(210, 105, 30),
    "coral": rgb(255, 127, 80),
    "cornflowerblue": rgb(100, 149, 237),
    "cornsilk": rgb(255, 248, 220),
    "crimson": rgb(220, 20, 60),
    "cyan": rgb(0, 255, 255),
    "darkblue": rgb(0, 0, 139),
    "darkcyan": rgb(0, 139, 139),
    "darkgoldenrod": rgb(184, 134, 11),
    "darkgray": rgb(169, 169, 169),
    "darkgreen": rgb(0, 100, 0),
    "darkgrey": rgb(169, 169, 169),
    "darkkhaki": rgb(189, 183, 107),
    "darkmagenta": rgb(139, 0, 139),
    "darkolivegreen": rgb(85, 107, 47),
    "darkorange": rgb(255, 140, 0),
    "darkorchid": rgb(153, 50, 204),
    "darkred": rgb(139, 0, 0),
    "darksalmon": rgb(233, 150, 122),
    "darkseagreen": rgb(143, 188, 143),
    "darkslateblue": rgb(72, 61, 139),
    "darkslategray": rgb(47, 79, 79),
    "darkslategrey": rgb(47, 79, 79),
    "darkturquoise": rgb(0, 206, 209),
    "darkviolet": rgb(148, 0, 211),
    "deeppink": rgb(255, 20, 147),
    "deepskyblue": rgb(0, 191, 255),
    "dimgray": rgb(105, 105, 105),
    "dimgrey": rgb(105, 105, 105),
    "dodgerblue": rgb(30, 144, 255),
    "firebrick": rgb(178, 34, 34),
    "floralwhite": rgb(255, 250, 240),
    "forestgreen": rgb(34, 139, 34),
    "gainsboro": rgb(220, 220, 220),
    "ghostwhite": rgb(248, 248, 255),
    "gold": rgb(255, 215, 0),
    "goldenrod": rgb(218, 165, 32),
    "greenyellow": rgb(173, 255, 47),
    "grey": rgb(128, 128, 128),
    "honeydew": rgb(240, 255, 240),
    "hotpink": rgb(255, 105, 180),
    "indianred": rgb(205, 92, 92),
    "indigo": rgb(75, 0, 130),
    "ivory": rgb(255, 255, 240),
    "khaki": rgb(240, 230, 140),
    "lavender": rgb(230, 230, 250),
    "lavenderblush": rgb(255, 240, 245),
    "lawngreen": rgb(124, 252, 0),
    "lemonchiffon": rgb(255, 250, 205),
    "lightblue": rgb(173, 216, 230),
    "lightcoral": rgb(240, 128, 128),
    "lightcyan": rgb(224, 255, 255),
    "lightgoldenrodyellow": rgb(250, 250, 210),
    "lightgray": rgb(211, 211, 211),
    "lightgreen": rgb(144, 238, 144),
    "lightgrey": rgb(211, 211, 211),
    "lightpink": rgb(255, 182, 193),
    "lightsalmon": rgb(255, 160, 122),
    "lightseagreen": rgb(32, 178, 170),
    "lightskyblue": rgb(135, 206, 250),
    "lightslategray": rgb(119, 136, 153),
    "lightslategrey": rgb(119, 136, 153),
    "lightsteelblue": rgb(176, 196, 222),
    "lightyellow": rgb(255, 255, 224),
    "limegreen": rgb(50, 205, 50),
    "linen": rgb(250, 240, 230),
    "magenta": rgb(255, 0, 255),
    "mediumaquamarine": rgb(102, 205, 170),
    "mediumblue": rgb(0, 0, 205),
    "mediumorchid": rgb(186, 85, 211),
    "mediumpurple": rgb(147, 112, 219),
    "mediumseagreen": rgb(60, 179, 113),
    "mediumslateblue": rgb(123, 104, 238),
    "mediumspringgreen": rgb(0, 250, 154),
    "mediumturquoise": rgb(72, 209, 204),
    "mediumvioletred": rgb(199, 21, 133),
    "midnightblue": rgb(25, 25, 112),
    "mintcream": rgb(245, 255, 250),
    "mistyrose": rgb(255, 228, 225),
    "moccasin": rgb(255, 228, 181),
    "navajowhite": rgb(255, 222, 173),
    "oldlace": rgb(253, 245, 230),
    "olivedrab": rgb(107, 142, 35),
    "orange": rgb(255, 165, 0),
    "orangered": rgb(255, 69, 0),
    "orchid": rgb(218, 112, 214),
    "palegoldenrod": rgb(238, 232, 170),
    "palegreen": rgb(152, 251, 152),
    "paleturquoise": rgb(175, 238, 238),
    "palevioletred": rgb(219, 112, 147),
    "papayawhip": rgb(255, 239, 213),
    "peachpuff": rgb(255, 218, 185),
    "peru": rgb(205, 133, 63),
    "pink": rgb(255, 192, 203),
    "plum": rgb(221, 160, 221),
    "powderblue": rgb(176, 224, 230),
    "rebeccapurple": rgb(102, 51, 153),
    "rosybrown": rgb(188, 143, 143),
    "royalblue": rgb(65, 105, 225),
    "saddlebrown": rgb(139, 69, 19),
    "salmon": rgb(250, 128, 114),
    "sandybrown": rgb(244, 164, 96),
    "seagreen": rgb(46, 139, 87),
    "seashell": rgb(255, 245, 238),
    "sienna": rgb(160, 82, 45),
    "skyblue": rgb(135, 206, 235),
    "slateblue": rgb(106, 90, 205),
    "slategray": rgb(112, 128, 144),
    "slategrey": rgb(112, 128, 144),
    "snow": rgb(255, 250, 250),
    "springgreen": rgb(0, 255, 127),
    "steelblue": rgb(70, 130, 180),
    "tan": rgb(210, 180, 140),
    "thistle": rgb(216, 191, 216),
    "tomato": rgb(255, 99, 71),
    "turquoise": rgb(64, 224, 208),
    "violet": rgb(238, 130, 238),
    "wheat": rgb(245, 222, 179),
    "whitesmoke": rgb(245, 245, 245),
    "yellowgreen": rgb(154, 205, 50),
]
