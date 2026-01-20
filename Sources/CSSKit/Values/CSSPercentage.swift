// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A CSS `<percentage>` value (stored as 0.0-1.0). https://www.w3.org/TR/css-values-4/#percentages
public struct CSSPercentage: Equatable, Sendable, Hashable {
    /// The percentage value as a unit value (0.0 to 1.0).
    public let value: Double

    /// Creates a percentage from a unit value (0.0 to 1.0).
    public init(_ value: Double) {
        self.value = value
    }

    /// Creates a percentage from a percentage value (0 to 100).
    public init(percent: Double) {
        value = percent / 100.0
    }

    /// Returns the percentage as a value from 0 to 100.
    public var percentValue: Double {
        value * 100.0
    }
}

// MARK: - Parsing

extension CSSPercentage {
    /// Parses a `<percentage>` value.
    static func parse(_ input: Parser) -> Result<CSSPercentage, BasicParseError> {
        input.expectPercentage().map { CSSPercentage($0) }
    }
}

// MARK: - ToCss

extension CSSPercentage: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        let percentValue = value * 100.0

        if percentValue.truncatingRemainder(dividingBy: 1) == 0 {
            dest.write(String(Int(percentValue)))
        } else if percentValue != 0, abs(percentValue) < 1.0 {
            let str = formatDouble(percentValue)
            if percentValue < 0 {
                dest.write("-")
                if str.hasPrefix("-0.") {
                    dest.write(String(str.dropFirst(2)))
                } else {
                    dest.write(String(str.dropFirst()))
                }
            } else {
                if str.hasPrefix("0.") {
                    dest.write(String(str.dropFirst()))
                } else {
                    dest.write(str)
                }
            }
        } else {
            dest.write(formatDouble(percentValue))
        }
        dest.write("%")
    }
}

// MARK: - Zero

extension CSSPercentage: Zero {
    public static var zero: CSSPercentage { CSSPercentage(0.0) }

    public var isZero: Bool { value == 0.0 }
}

// MARK: - Signed

extension CSSPercentage: Signed {
    public var cssSign: Double { value.cssSign }

    public var isPositive: Bool { value >= 0.0 }

    public var isNegative: Bool { value < 0.0 }
}

// MARK: - Arithmetic

public extension CSSPercentage {
    static func + (lhs: CSSPercentage, rhs: CSSPercentage) -> CSSPercentage {
        CSSPercentage(lhs.value + rhs.value)
    }

    static func - (lhs: CSSPercentage, rhs: CSSPercentage) -> CSSPercentage {
        CSSPercentage(lhs.value - rhs.value)
    }

    static func * (lhs: CSSPercentage, rhs: Double) -> CSSPercentage {
        CSSPercentage(lhs.value * rhs)
    }

    static func / (lhs: CSSPercentage, rhs: Double) -> CSSPercentage {
        CSSPercentage(lhs.value / rhs)
    }
}

// MARK: - Comparable

extension CSSPercentage: Comparable {
    public static func < (lhs: CSSPercentage, rhs: CSSPercentage) -> Bool {
        lhs.value < rhs.value
    }
}
