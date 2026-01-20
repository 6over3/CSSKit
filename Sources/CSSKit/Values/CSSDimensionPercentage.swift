// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A protocol for dimension types that can be used with CSSDimensionPercentage.
public protocol CSSDimension: Equatable, Sendable, CSSSerializable, Zero, Signed {
    /// Multiplies the dimension by a scalar.
    static func * (lhs: Self, rhs: Double) -> Self
}

/// Internal protocol for dimensions that can be parsed in calc context.
protocol CSSCalcDimension: CSSDimension {
    static func parse(_ input: Parser) -> Result<Self, BasicParseError>
    static func fromNumber(_ value: Double) -> Self
}

// Conform our dimension types to CSSDimension
extension CSSLength: CSSDimension {}
extension CSSAngle: CSSDimension {}
extension CSSTime: CSSDimension {}
extension CSSResolution: CSSDimension {}

// Conform dimension types that support calc parsing to CSSCalcDimension
extension CSSLength: CSSCalcDimension {
    static func fromNumber(_ value: Double) -> CSSLength {
        CSSLength(value, .px)
    }
}

extension CSSAngle: CSSCalcDimension {
    static func fromNumber(_ value: Double) -> CSSAngle {
        .deg(value)
    }
}

/// Dimension or percentage, optionally mixed in calc(). https://drafts.csswg.org/css-values-4/#mixed-percentages
public indirect enum CSSDimensionPercentage<D: CSSDimension & Hashable>: Sendable, Hashable {
    /// An explicit dimension value.
    case dimension(D)

    /// A percentage.
    case percentage(CSSPercentage)

    /// A `calc()` expression.
    case calc(CSSCalc<CSSDimensionPercentage<D>>)
}

// MARK: - Convenience Type Aliases

/// A length or percentage value.
public typealias CSSLengthPercentage = CSSDimensionPercentage<CSSLength>

/// An angle or percentage value.
public typealias CSSAnglePercentage = CSSDimensionPercentage<CSSAngle>

/// A time or percentage value.
public typealias CSSTimePercentage = CSSDimensionPercentage<CSSTime>

// MARK: - Parsing

extension CSSDimensionPercentage where D == CSSLength {
    /// Parses a `<length-percentage>` value.
    static func parse(_ input: Parser) -> Result<CSSLengthPercentage, BasicParseError> {
        parseInternal(input, allowUnitlessZero: false)
    }

    /// Parses a `<length-percentage>` value, allowing unitless zero.
    static func parseWithUnitlessZero(_ input: Parser) -> Result<CSSLengthPercentage, BasicParseError> {
        parseInternal(input, allowUnitlessZero: true)
    }

    private static func parseInternal(_ input: Parser, allowUnitlessZero: Bool) -> Result<CSSLengthPercentage, BasicParseError> {
        let state = input.state()

        // Try calc() first
        if case let .success(calc) = input.tryParse({ CSSCalc<CSSLengthPercentage>.parse($0) }) {
            switch calc {
            case let .value(v): return .success(v)
            case let .number(n): return .success(.dimension(CSSLength(n, .px)))
            default: return .success(.calc(calc))
            }
        }

        // Try length
        let lengthResult = allowUnitlessZero
            ? CSSLength.parseWithUnitlessZero(input)
            : CSSLength.parse(input)

        if case let .success(length) = lengthResult {
            return .success(.dimension(length))
        }

        // Reset and try percentage
        input.reset(state)

        if case let .success(pct) = CSSPercentage.parse(input) {
            return .success(.percentage(pct))
        }

        // Failed
        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSDimensionPercentage where D == CSSAngle {
    /// Parses an `<angle-percentage>` value.
    static func parse(_ input: Parser) -> Result<CSSAnglePercentage, BasicParseError> {
        parseInternal(input, allowUnitlessZero: false)
    }

    /// Parses an `<angle-percentage>` value, allowing unitless zero.
    static func parseWithUnitlessZero(_ input: Parser) -> Result<CSSAnglePercentage, BasicParseError> {
        parseInternal(input, allowUnitlessZero: true)
    }

    private static func parseInternal(_ input: Parser, allowUnitlessZero: Bool) -> Result<CSSAnglePercentage, BasicParseError> {
        let state = input.state()

        // Try calc() first
        if case let .success(calc) = input.tryParse({ CSSCalc<CSSAnglePercentage>.parse($0) }) {
            switch calc {
            case let .value(v): return .success(v)
            case let .number(n): return .success(.dimension(CSSAngle.deg(n)))
            default: return .success(.calc(calc))
            }
        }

        // Try angle
        let angleResult = allowUnitlessZero
            ? CSSAngle.parseWithUnitlessZero(input)
            : CSSAngle.parse(input)

        if case let .success(angle) = angleResult {
            return .success(.dimension(angle))
        }

        // Reset and try percentage
        input.reset(state)

        if case let .success(pct) = CSSPercentage.parse(input) {
            return .success(.percentage(pct))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

// MARK: - CSSCalcParseable

extension CSSDimensionPercentage: CSSCalcParseable where D: CSSCalcDimension {
    static func parseCalcValue(_ input: Parser) -> Result<CSSDimensionPercentage<D>, BasicParseError> {
        let state = input.state()

        // Try dimension
        if case let .success(dim) = D.parse(input) {
            return .success(.dimension(dim))
        }

        // Reset and try percentage
        input.reset(state)

        if case let .success(pct) = CSSPercentage.parse(input) {
            return .success(.percentage(pct))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

// MARK: - ToCss

extension CSSDimensionPercentage: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .dimension(d):
            d.serialize(dest: &dest)
        case let .percentage(p):
            p.serialize(dest: &dest)
        case let .calc(c):
            c.serialize(dest: &dest)
        }
    }
}

// MARK: - Zero

extension CSSDimensionPercentage: Zero {
    public static var zero: CSSDimensionPercentage<D> {
        .dimension(D.zero)
    }

    public var isZero: Bool {
        switch self {
        case let .dimension(d):
            d.isZero
        case let .percentage(p):
            p.isZero
        case .calc:
            false
        }
    }
}

// MARK: - Signed

extension CSSDimensionPercentage: Signed {
    public var cssSign: Double {
        switch self {
        case let .dimension(d):
            d.cssSign
        case let .percentage(p):
            p.cssSign
        case .calc:
            0.0 // Unknown without evaluation
        }
    }

    public var isPositive: Bool {
        switch self {
        case let .dimension(d):
            d.isPositive
        case let .percentage(p):
            p.isPositive
        case .calc:
            true // Unknown
        }
    }

    public var isNegative: Bool {
        switch self {
        case let .dimension(d):
            d.isNegative
        case let .percentage(p):
            p.isNegative
        case .calc:
            false // Unknown
        }
    }
}

// MARK: - Equatable

extension CSSDimensionPercentage: Equatable {
    public static func == (lhs: CSSDimensionPercentage<D>, rhs: CSSDimensionPercentage<D>) -> Bool {
        switch (lhs, rhs) {
        case let (.dimension(l), .dimension(r)):
            l == r
        case let (.percentage(l), .percentage(r)):
            l == r
        case let (.calc(l), .calc(r)):
            l == r
        default:
            false
        }
    }
}

// MARK: - Arithmetic

public extension CSSDimensionPercentage {
    static func * (lhs: CSSDimensionPercentage<D>, rhs: Double) -> CSSDimensionPercentage<D> {
        switch lhs {
        case let .dimension(d):
            .dimension(d * rhs)
        case let .percentage(p):
            .percentage(p * rhs)
        case let .calc(c):
            .calc(c * rhs)
        }
    }
}

// MARK: - CSSNumberOrPercentage

/// Either a `<number>` or `<percentage>`.
public enum CSSNumberOrPercentage: Equatable, Sendable, Hashable {
    /// A number.
    case number(Double)
    /// A percentage.
    case percentage(CSSPercentage)

    /// The value as a unit value (percentages return their 0-1 value).
    public var unitValue: Double {
        switch self {
        case let .number(v):
            v
        case let .percentage(p):
            p.value
        }
    }

    /// Returns the value with percentages adjusted to the given basis.
    public func value(percentageBasis: Double) -> Double {
        switch self {
        case let .number(v):
            v
        case let .percentage(p):
            p.value * percentageBasis
        }
    }
}

extension CSSNumberOrPercentage {
    /// Parses a `<number>` or `<percentage>`.
    static func parse(_ input: Parser) -> Result<CSSNumberOrPercentage, BasicParseError> {
        let location = input.currentSourceLocation()

        switch input.next() {
        case let .success(token):
            switch token {
            case let .number(numeric):
                return .success(.number(numeric.value))
            case let .percentage(numeric):
                return .success(.percentage(CSSPercentage(numeric.value)))
            default:
                return .failure(location.newBasicUnexpectedTokenError(token))
            }
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSNumberOrPercentage: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .number(v):
            v.serialize(dest: &dest)
        case let .percentage(p):
            p.serialize(dest: &dest)
        }
    }
}

// MARK: - CSSLengthPercentageOrAuto

/// A length-percentage value or the `auto` keyword.
public enum CSSLengthPercentageOrAuto: Equatable, Sendable, Hashable {
    /// A length or percentage value.
    case lengthPercentage(CSSLengthPercentage)
    /// The `auto` keyword.
    case auto
}

extension CSSLengthPercentageOrAuto {
    /// Parses a `<length-percentage>` or `auto`.
    static func parse(_ input: Parser) -> Result<CSSLengthPercentageOrAuto, BasicParseError> {
        // Try auto first
        if input.tryParse({ $0.expectIdentMatching("auto") }).isOK {
            return .success(.auto)
        }

        // Try length-percentage
        switch CSSLengthPercentage.parse(input) {
        case let .success(lp):
            return .success(.lengthPercentage(lp))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSLengthPercentageOrAuto: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .lengthPercentage(lp):
            lp.serialize(dest: &dest)
        case .auto:
            dest.write("auto")
        }
    }
}

// MARK: - CSSLengthPercentageOrNone

/// A length-percentage value or the `none` keyword.
public enum CSSLengthPercentageOrNone: Equatable, Sendable, Hashable {
    /// A length or percentage value.
    case lengthPercentage(CSSLengthPercentage)
    /// The `none` keyword.
    case none
}

extension CSSLengthPercentageOrNone {
    /// Parses a `<length-percentage>` or `none`.
    static func parse(_ input: Parser) -> Result<CSSLengthPercentageOrNone, BasicParseError> {
        // Try none first
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        // Try length-percentage
        switch CSSLengthPercentage.parse(input) {
        case let .success(lp):
            return .success(.lengthPercentage(lp))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSLengthPercentageOrNone: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .lengthPercentage(lp):
            lp.serialize(dest: &dest)
        case .none:
            dest.write("none")
        }
    }
}
