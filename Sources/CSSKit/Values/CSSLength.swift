// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// All CSS length units.
/// https://www.w3.org/TR/css-values-4/#lengths
public enum CSSLengthUnit: String, CaseIterable, Sendable, Hashable {
    // MARK: - Absolute Lengths

    // https://www.w3.org/TR/css-values-4/#absolute-lengths

    /// Pixels
    case px
    /// Centimeters
    case cm
    /// Millimeters
    case mm
    /// Quarter-millimeters
    case q
    /// Inches
    case `in`
    /// Points
    case pt
    /// Picas
    case pc

    // MARK: - Font-relative Lengths

    // https://www.w3.org/TR/css-values-4/#font-relative-lengths

    /// Width of the "0" (zero) character in the element's font
    case ch
    /// Calculated font-size of the element
    case em
    /// x-height of the element's font
    case ex
    /// Represents the "cap height" of the element's font
    case cap
    /// Advance measure of the "水" (CJK water ideograph) glyph
    case ic
    /// Line height of the element
    case lh
    /// Calculated font-size of the root element
    case rem
    /// x-height of the root element's font
    case rex
    /// "0" character width of the root element's font
    case rch
    /// Cap height of the root element's font
    case rcap
    /// "水" glyph advance measure of the root element's font
    case ric
    /// Line height of the root element
    case rlh

    // MARK: - Viewport-percentage Lengths

    // https://www.w3.org/TR/css-values-4/#viewport-relative-lengths

    /// 1% of the viewport's width
    case vw
    /// 1% of the viewport's height
    case vh
    /// 1% of the viewport's smaller dimension
    case vmin
    /// 1% of the viewport's larger dimension
    case vmax
    /// 1% of the size of the initial containing block in the inline axis
    case vi
    /// 1% of the size of the initial containing block in the block axis
    case vb

    // MARK: - Small Viewport Units

    /// 1% of the small viewport's width
    case svw
    /// 1% of the small viewport's height
    case svh
    /// 1% of the small viewport's smaller dimension
    case svmin
    /// 1% of the small viewport's larger dimension
    case svmax
    /// 1% of the small viewport in the inline axis
    case svi
    /// 1% of the small viewport in the block axis
    case svb

    // MARK: - Large Viewport Units

    /// 1% of the large viewport's width
    case lvw
    /// 1% of the large viewport's height
    case lvh
    /// 1% of the large viewport's smaller dimension
    case lvmin
    /// 1% of the large viewport's larger dimension
    case lvmax
    /// 1% of the large viewport in the inline axis
    case lvi
    /// 1% of the large viewport in the block axis
    case lvb

    // MARK: - Dynamic Viewport Units

    /// 1% of the dynamic viewport's width
    case dvw
    /// 1% of the dynamic viewport's height
    case dvh
    /// 1% of the dynamic viewport's smaller dimension
    case dvmin
    /// 1% of the dynamic viewport's larger dimension
    case dvmax
    /// 1% of the dynamic viewport in the inline axis
    case dvi
    /// 1% of the dynamic viewport in the block axis
    case dvb

    // MARK: - Container Query Lengths

    // https://www.w3.org/TR/css-contain-3/#container-lengths

    /// 1% of a query container's width
    case cqw
    /// 1% of a query container's height
    case cqh
    /// 1% of a query container's inline size
    case cqi
    /// 1% of a query container's block size
    case cqb
    /// 1% of a query container's smaller dimension
    case cqmin
    /// 1% of a query container's larger dimension
    case cqmax
}

public extension CSSLengthUnit {
    /// Creates a length unit from a string (case-insensitive).
    init?(string: String) {
        let lower = string.lowercased()
        if lower == "in" {
            self = .in
            return
        }
        guard let unit = CSSLengthUnit(rawValue: lower) else {
            return nil
        }
        self = unit
    }

    /// Whether this is an absolute length unit.
    var isAbsolute: Bool {
        switch self {
        case .px, .cm, .mm, .q, .in, .pt, .pc:
            true
        default:
            false
        }
    }

    /// Whether this is a font-relative length unit.
    var isFontRelative: Bool {
        switch self {
        case .ch, .em, .ex, .cap, .ic, .lh, .rem, .rex, .rch, .rcap, .ric, .rlh:
            true
        default:
            false
        }
    }

    /// Whether this is a viewport-relative length unit.
    var isViewportRelative: Bool {
        switch self {
        case .vw, .vh, .vmin, .vmax, .vi, .vb,
             .svw, .svh, .svmin, .svmax, .svi, .svb,
             .lvw, .lvh, .lvmin, .lvmax, .lvi, .lvb,
             .dvw, .dvh, .dvmin, .dvmax, .dvi, .dvb:
            true
        default:
            false
        }
    }

    /// Whether this is a container query length unit.
    var isContainerRelative: Bool {
        switch self {
        case .cqw, .cqh, .cqi, .cqb, .cqmin, .cqmax:
            true
        default:
            false
        }
    }
}

// MARK: - CSSLength

/// A CSS `<length>` value.
/// https://www.w3.org/TR/css-values-4/#lengths
public struct CSSLength: Sendable, Hashable {
    /// The numeric value.
    public let value: Double

    /// The unit of measurement.
    public let unit: CSSLengthUnit

    /// Creates a length with the given value and unit.
    public init(_ value: Double, _ unit: CSSLengthUnit) {
        self.value = value
        self.unit = unit
    }

    // MARK: - Convenience Constructors

    public static func px(_ value: Double) -> Self { Self(value, .px) }
    public static func em(_ value: Double) -> Self { Self(value, .em) }
    public static func rem(_ value: Double) -> Self { Self(value, .rem) }
    public static func percent(_ value: Double) -> Self { Self(value, .px) } // Note: percentage is separate
    public static func vw(_ value: Double) -> Self { Self(value, .vw) }
    public static func vh(_ value: Double) -> Self { Self(value, .vh) }
    public static func cm(_ value: Double) -> Self { Self(value, .cm) }
    public static func mm(_ value: Double) -> Self { Self(value, .mm) }
    public static func pt(_ value: Double) -> Self { Self(value, .pt) }
    public static func pc(_ value: Double) -> Self { Self(value, .pc) }
}

// MARK: - Parsing

extension CSSLength {
    /// Parses a `<length>` value.
    static func parse(_ input: Parser) -> Result<CSSLength, BasicParseError> {
        parseInternal(input, allowUnitlessZero: false)
    }

    /// Parses a `<length>` value, allowing unitless zero.
    static func parseWithUnitlessZero(_ input: Parser) -> Result<CSSLength, BasicParseError> {
        parseInternal(input, allowUnitlessZero: true)
    }

    private static func parseInternal(_ input: Parser, allowUnitlessZero: Bool) -> Result<CSSLength, BasicParseError> {
        let location = input.currentSourceLocation()

        switch input.next() {
        case let .success(token):
            switch token {
            case let .dimension(numeric, unitLexeme):
                let value = numeric.value
                if let unit = CSSLengthUnit(string: unitLexeme.value) {
                    return .success(CSSLength(value, unit))
                }
                return .failure(location.newBasicUnexpectedTokenError(token))

            case let .number(numeric) where numeric.value == 0.0 && allowUnitlessZero:
                return .success(.zero)

            default:
                return .failure(location.newBasicUnexpectedTokenError(token))
            }

        case let .failure(error):
            return .failure(error)
        }
    }
}

// MARK: - ToCss

extension CSSLength: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        serializeDimension(value: value, unit: unit.rawValue, dest: &dest)
    }
}

// MARK: - Zero

extension CSSLength: Zero {
    public static var zero: CSSLength { CSSLength(0.0, .px) }

    public var isZero: Bool { value == 0.0 }
}

// MARK: - Signed

extension CSSLength: Signed {
    public var cssSign: Double { value.cssSign }

    public var isPositive: Bool { value >= 0.0 }

    public var isNegative: Bool { value < 0.0 }
}

// MARK: - Conversion to Pixels

extension CSSLength {
    /// Conversion factors to pixels for absolute units.
    private static let pxPerIn: Double = 96.0
    private static let pxPerCm: Double = 96.0 / 2.54
    private static let pxPerMm: Double = 96.0 / 25.4
    private static let pxPerQ: Double = 96.0 / 101.6 // 1q = 1/4mm
    private static let pxPerPt: Double = 96.0 / 72.0
    private static let pxPerPc: Double = 96.0 / 6.0 // 1pc = 12pt

    /// The length converted to pixels, or nil for relative units that require context.
    public var pixels: Double? {
        switch unit {
        case .px:
            value
        case .in:
            value * CSSLength.pxPerIn
        case .cm:
            value * CSSLength.pxPerCm
        case .mm:
            value * CSSLength.pxPerMm
        case .q:
            value * CSSLength.pxPerQ
        case .pt:
            value * CSSLength.pxPerPt
        case .pc:
            value * CSSLength.pxPerPc
        default:
            nil
        }
    }
}

// MARK: - Comparable

extension CSSLength: Comparable {
    public static func < (lhs: CSSLength, rhs: CSSLength) -> Bool {
        if lhs.unit == rhs.unit {
            return lhs.value < rhs.value
        }
        // For absolute units, compare in pixels
        if let lhsPx = lhs.pixels, let rhsPx = rhs.pixels {
            return lhsPx < rhsPx
        }
        // Can't compare relative units without context
        return false
    }
}

// MARK: - Arithmetic

public extension CSSLength {
    static func * (lhs: CSSLength, rhs: Double) -> CSSLength {
        CSSLength(lhs.value * rhs, lhs.unit)
    }

    static func / (lhs: CSSLength, rhs: Double) -> CSSLength {
        CSSLength(lhs.value / rhs, lhs.unit)
    }

    static prefix func - (length: CSSLength) -> CSSLength {
        CSSLength(-length.value, length.unit)
    }
}
