// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A CSS `<resolution>` value. https://www.w3.org/TR/css-values-4/#resolution
public enum CSSResolution: Sendable, Hashable {
    /// Dots per inch.
    case dpi(Double)

    /// Dots per centimeter.
    case dpcm(Double)

    /// Dots per `px` unit (1 dppx = 96 dpi).
    case dppx(Double)

    /// Alias for dppx (x descriptor in image-set).
    case x(Double)
}

// MARK: - Parsing

extension CSSResolution {
    /// Parses a `<resolution>` value.
    static func parse(_ input: Parser) -> Result<CSSResolution, BasicParseError> {
        let location = input.currentSourceLocation()

        switch input.next() {
        case let .success(token):
            switch token {
            case let .dimension(numeric, unit):
                let value = numeric.value
                switch unit.value.lowercased() {
                case "dpi":
                    return .success(.dpi(value))
                case "dpcm":
                    return .success(.dpcm(value))
                case "dppx":
                    return .success(.dppx(value))
                case "x":
                    return .success(.x(value))
                default:
                    return .failure(location.newBasicUnexpectedTokenError(token))
                }

            default:
                return .failure(location.newBasicUnexpectedTokenError(token))
            }

        case let .failure(error):
            return .failure(error)
        }
    }
}

// MARK: - Conversions

public extension CSSResolution {
    /// Pixels per inch (1 dpi = 1 dot per inch).
    private static let dpiPerDpcm: Double = 2.54
    /// Pixels per dppx (1 dppx = 96 dpi).
    private static let dpiPerDppx: Double = 96.0

    /// The resolution converted to dots per inch.
    var inDpi: Double {
        switch self {
        case let .dpi(v):
            v
        case let .dpcm(v):
            v * CSSResolution.dpiPerDpcm
        case let .dppx(v), let .x(v):
            v * CSSResolution.dpiPerDppx
        }
    }

    /// The resolution converted to dots per centimeter.
    var inDpcm: Double {
        inDpi / CSSResolution.dpiPerDpcm
    }

    /// The resolution converted to dots per px unit.
    var inDppx: Double {
        inDpi / CSSResolution.dpiPerDppx
    }

    /// The raw numeric value without unit.
    var value: Double {
        switch self {
        case let .dpi(v), let .dpcm(v), let .dppx(v), let .x(v):
            v
        }
    }
}

// MARK: - ToCss

extension CSSResolution: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        let (value, unit): (Double, String)

        switch self {
        case let .dpi(v):
            value = v
            unit = "dpi"
        case let .dpcm(v):
            value = v
            unit = "dpcm"
        case let .dppx(v):
            value = v
            unit = "dppx"
        case let .x(v):
            // Serialize as dppx for consistency
            value = v
            unit = "dppx"
        }

        serializeDimension(value: value, unit: unit, dest: &dest)
    }
}

// MARK: - Zero

extension CSSResolution: Zero {
    public static var zero: CSSResolution { .dpi(0.0) }

    public var isZero: Bool { value == 0.0 }
}

// MARK: - Signed

extension CSSResolution: Signed {
    public var cssSign: Double { value.cssSign }

    public var isPositive: Bool { value >= 0.0 }

    public var isNegative: Bool { value < 0.0 }
}

// MARK: - Equatable

extension CSSResolution: Equatable {
    public static func == (lhs: CSSResolution, rhs: CSSResolution) -> Bool {
        lhs.inDpi == rhs.inDpi
    }
}

// MARK: - Comparable

extension CSSResolution: Comparable {
    public static func < (lhs: CSSResolution, rhs: CSSResolution) -> Bool {
        lhs.inDpi < rhs.inDpi
    }
}

// MARK: - Arithmetic

public extension CSSResolution {
    static func * (lhs: CSSResolution, rhs: Double) -> CSSResolution {
        switch lhs {
        case let .dpi(v): .dpi(v * rhs)
        case let .dpcm(v): .dpcm(v * rhs)
        case let .dppx(v): .dppx(v * rhs)
        case let .x(v): .x(v * rhs)
        }
    }

    static func / (lhs: CSSResolution, rhs: Double) -> CSSResolution {
        switch lhs {
        case let .dpi(v): .dpi(v / rhs)
        case let .dpcm(v): .dpcm(v / rhs)
        case let .dppx(v): .dppx(v / rhs)
        case let .x(v): .x(v / rhs)
        }
    }
}
