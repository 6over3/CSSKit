// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

/// A CSS `<angle>` value. https://www.w3.org/TR/css-values-4/#angles
public enum CSSAngle: Sendable, Hashable {
    /// An angle in degrees. There are 360 degrees in a full circle.
    case deg(Double)

    /// An angle in radians. There are 2π radians in a full circle.
    case rad(Double)

    /// An angle in gradians. There are 400 gradians in a full circle.
    case grad(Double)

    /// An angle in turns. There is 1 turn in a full circle.
    case turn(Double)
}

// MARK: - Parsing

extension CSSAngle {
    /// Parses an `<angle>` value.
    static func parse(_ input: Parser) -> Result<CSSAngle, BasicParseError> {
        parseInternal(input, allowUnitlessZero: false)
    }

    /// Parses an `<angle>` value, allowing unitless zero.
    static func parseWithUnitlessZero(_ input: Parser) -> Result<CSSAngle, BasicParseError> {
        parseInternal(input, allowUnitlessZero: true)
    }

    private static func parseInternal(_ input: Parser, allowUnitlessZero: Bool) -> Result<CSSAngle, BasicParseError> {
        let location = input.currentSourceLocation()

        switch input.next() {
        case let .success(token):
            switch token {
            case let .dimension(numeric, unit):
                let value = numeric.value
                switch unit.value.lowercased() {
                case "deg":
                    return .success(.deg(value))
                case "rad":
                    return .success(.rad(value))
                case "grad":
                    return .success(.grad(value))
                case "turn":
                    return .success(.turn(value))
                default:
                    return .failure(location.newBasicUnexpectedTokenError(token))
                }

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

// MARK: - Conversions

public extension CSSAngle {
    /// The value of pi.
    private static let pi = Double.pi

    /// The angle converted to degrees.
    var degrees: Double {
        switch self {
        case let .deg(v):
            v
        case let .rad(v):
            v * 180.0 / CSSAngle.pi
        case let .grad(v):
            v * 180.0 / 200.0
        case let .turn(v):
            v * 360.0
        }
    }

    /// The angle converted to radians.
    var radians: Double {
        switch self {
        case let .deg(v):
            v * CSSAngle.pi / 180.0
        case let .rad(v):
            v
        case let .grad(v):
            v * CSSAngle.pi / 200.0
        case let .turn(v):
            v * 2.0 * CSSAngle.pi
        }
    }

    /// The angle converted to gradians.
    var gradians: Double {
        switch self {
        case let .deg(v):
            v * 200.0 / 180.0
        case let .rad(v):
            v * 200.0 / CSSAngle.pi
        case let .grad(v):
            v
        case let .turn(v):
            v * 400.0
        }
    }

    /// The angle converted to turns.
    var turns: Double {
        switch self {
        case let .deg(v):
            v / 360.0
        case let .rad(v):
            v / (2.0 * CSSAngle.pi)
        case let .grad(v):
            v / 400.0
        case let .turn(v):
            v
        }
    }

    /// The raw numeric value without unit.
    var value: Double {
        switch self {
        case let .deg(v), let .rad(v), let .grad(v), let .turn(v):
            v
        }
    }
}

// MARK: - ToCss

extension CSSAngle: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        let (value, unit): (Double, String)

        switch self {
        case let .deg(v):
            value = v
            unit = "deg"
        case let .rad(v):
            // We print 5 digits of precision by default.
            // Switch to degrees if there are an even number of them.
            let deg = degrees
            if (deg * 100_000.0).rounded().truncatingRemainder(dividingBy: 1) == 0.0 {
                value = deg
                unit = "deg"
            } else {
                value = v
                unit = "rad"
            }
        case let .grad(v):
            value = v
            unit = "grad"
        case let .turn(v):
            value = v
            unit = "turn"
        }

        serializeDimension(value: value, unit: unit, dest: &dest)
    }

    /// Serializes the angle, allowing unitless zero.
    public func serializeWithUnitlessZero(dest: inout some CSSWriter) {
        if isZero {
            dest.write("0")
        } else {
            serialize(dest: &dest)
        }
    }
}

// MARK: - Zero

extension CSSAngle: Zero {
    public static var zero: CSSAngle { .deg(0.0) }

    public var isZero: Bool { value == 0.0 }
}

// MARK: - Signed

extension CSSAngle: Signed {
    public var cssSign: Double { value.cssSign }

    public var isPositive: Bool { value >= 0.0 }

    public var isNegative: Bool { value < 0.0 }
}

// MARK: - Equatable

extension CSSAngle: Equatable {
    public static func == (lhs: CSSAngle, rhs: CSSAngle) -> Bool {
        lhs.degrees == rhs.degrees
    }
}

// MARK: - Comparable

extension CSSAngle: Comparable {
    public static func < (lhs: CSSAngle, rhs: CSSAngle) -> Bool {
        lhs.degrees < rhs.degrees
    }
}

// MARK: - Arithmetic

public extension CSSAngle {
    static func + (lhs: CSSAngle, rhs: CSSAngle) -> CSSAngle {
        .deg(lhs.degrees + rhs.degrees)
    }

    static func - (lhs: CSSAngle, rhs: CSSAngle) -> CSSAngle {
        .deg(lhs.degrees - rhs.degrees)
    }

    static func * (lhs: CSSAngle, rhs: Double) -> CSSAngle {
        switch lhs {
        case let .deg(v): .deg(v * rhs)
        case let .rad(v): .rad(v * rhs)
        case let .grad(v): .grad(v * rhs)
        case let .turn(v): .turn(v * rhs)
        }
    }

    static func / (lhs: CSSAngle, rhs: Double) -> CSSAngle {
        switch lhs {
        case let .deg(v): .deg(v / rhs)
        case let .rad(v): .rad(v / rhs)
        case let .grad(v): .grad(v / rhs)
        case let .turn(v): .turn(v / rhs)
        }
    }
}
