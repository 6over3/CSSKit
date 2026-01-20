// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - CSS Number Types

/// A CSS `<number>` value.
/// https://www.w3.org/TR/css-values-4/#numbers
public typealias CSSNumber = Double

/// A CSS `<integer>` value.
/// https://www.w3.org/TR/css-values-4/#integers
public typealias CSSInteger = Int

// MARK: - CSSNumber Parse Methods

extension Double {
    /// Parses a CSS `<number>` value.
    static func parse(_ input: Parser) -> Result<Double, BasicParseError> {
        input.expectNumber()
    }
}

extension Int {
    /// Parses a CSS `<integer>` value.
    static func parse(_ input: Parser) -> Result<Int, BasicParseError> {
        input.expectInteger().map { Int($0) }
    }
}

// MARK: - CSSCalcValue Conformance for Numbers

extension Double: CSSCalcValue {}

extension Double: CSSCalcParseable {
    static func parseCalcValue(_ input: Parser) -> Result<Double, BasicParseError> {
        input.expectNumber()
    }
}

// MARK: - Numeric Parsing Helpers

extension Parser {
    /// Parses a CSS number value (plain number only, no calc).
    func parseNumber() -> Result<Double, BasicParseError> {
        expectNumber()
    }

    /// Parses a CSS integer value (plain integer only, no calc).
    func parseInteger() -> Result<Int, BasicParseError> {
        expectInteger().map { Int($0) }
    }

    /// Parses a CSS `<number>` value, including calc() expressions.
    func parseCSSNumber() -> Result<CSSNumber, BasicParseError> {
        // Try calc() first
        if case let .success(calc) = tryParse({ CSSCalc<Double>.parse($0) }) {
            switch calc {
            case let .value(v):
                return .success(v)
            case let .number(n):
                return .success(n)
            default:
                // Numbers in calc should always resolve to a number
                return .failure(newBasicError(.endOfInput))
            }
        }

        // Fall back to plain number
        return expectNumber()
    }

    /// Parses a CSS `<integer>` value, including calc() expressions.
    func parseCSSInteger() -> Result<CSSInteger, BasicParseError> {
        if case let .success(calc) = tryParse({ CSSCalc<Double>.parse($0) }) {
            switch calc {
            case let .value(v):
                if v.truncatingRemainder(dividingBy: 1) == 0 {
                    return .success(Int(v))
                }
                return .failure(newBasicError(.endOfInput))
            case let .number(n):
                if n.truncatingRemainder(dividingBy: 1) == 0 {
                    return .success(Int(n))
                }
                return .failure(newBasicError(.endOfInput))
            default:
                return .failure(newBasicError(.endOfInput))
            }
        }

        return expectInteger().map { Int($0) }
    }
}

// MARK: - Zero Protocol

/// A type that has a zero value and can check for zero.
public protocol Zero {
    /// The zero value for this type.
    static var zero: Self { get }

    /// Whether this value is zero.
    var isZero: Bool { get }
}

extension CSSNumber: Zero {
    public static var zero: CSSNumber { 0.0 }
    public var isZero: Bool { self == 0.0 }
}

extension CSSInteger: Zero {
    public static var zero: CSSInteger { 0 }
    public var isZero: Bool { self == 0 }
}

// MARK: - Sign Protocol

/// A type that can report its sign.
public protocol Signed {
    /// The sign of this value: -1.0, 0.0, or 1.0.
    var cssSign: Double { get }

    /// Whether this value is positive (>= 0).
    var isPositive: Bool { get }

    /// Whether this value is negative (< 0).
    var isNegative: Bool { get }
}

extension CSSNumber: Signed {
    public var cssSign: Double {
        if self == 0.0 {
            return sign == .plus ? 0.0 : -0.0
        }
        return self > 0 ? 1.0 : -1.0
    }

    public var isPositive: Bool { self >= 0.0 }

    public var isNegative: Bool { self < 0.0 }
}

// MARK: - Serialization Helpers

/// Serializes a dimension value with its unit.
public func serializeDimension(
    value: Double,
    unit: String,
    dest: inout some CSSWriter
) {
    if value == 0.0 && value.sign == .minus {
        dest.write("-0")
    } else if value != 0.0 && abs(value) < 1.0 {
        let str = formatDouble(value)
        if value < 0 {
            dest.write("-")
            if str.hasPrefix("-0.") {
                dest.write(String(str.dropFirst(2)))
            } else if str.hasPrefix("-0") {
                dest.write(String(str.dropFirst(2)))
            } else {
                dest.write(String(str.dropFirst()))
            }
        } else {
            if str.hasPrefix("0.") {
                dest.write(String(str.dropFirst()))
            } else if str.hasPrefix("0"), str.count > 1 {
                dest.write(String(str.dropFirst()))
            } else {
                dest.write(str)
            }
        }
    } else {
        value.serialize(dest: &dest)
    }

    // Write the unit, handling scientific notation disambiguation
    if unit == "e" || unit == "E" || unit.hasPrefix("e-") || unit.hasPrefix("E-") {
        // Escape 'e' to avoid confusion with scientific notation
        dest.write("\\65 ")
        serializeName(String(unit.dropFirst()), dest: &dest)
    } else {
        serializeIdentifier(unit, dest: &dest)
    }
}
