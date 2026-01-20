// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

/// An alpha/opacity value that can be either a number (0-1) or percentage (0%-100%).
/// https://www.w3.org/TR/css-color-4/#typedef-alpha-value
public struct CSSAlphaValue: Equatable, Sendable, Hashable {
    /// The alpha value as a unit value (0.0 to 1.0).
    public let value: Double

    /// Creates an alpha value from a unit value (0.0 to 1.0).
    /// The value is clamped to the valid range.
    public init(_ value: Double) {
        self.value = min(max(value, 0.0), 1.0)
    }

    /// Creates an alpha value without clamping.
    /// Use this only when you know the value is valid or need to preserve out-of-range values.
    public init(unclamped value: Double) {
        self.value = value
    }

    /// Creates an opaque alpha value (1.0).
    public static var opaque: Self {
        Self(1.0)
    }

    /// Creates a transparent alpha value (0.0).
    public static var transparent: Self {
        Self(0.0)
    }
}

// MARK: - Parsing

extension CSSAlphaValue {
    /// Parses an alpha value (number or percentage).
    /// The result is clamped to [0, 1].
    static func parse(_ input: Parser) -> Result<CSSAlphaValue, BasicParseError> {
        let location = input.currentSourceLocation()

        switch input.next() {
        case let .success(token):
            switch token {
            case let .number(numeric):
                return .success(CSSAlphaValue(numeric.value))
            case let .percentage(numeric):
                return .success(CSSAlphaValue(numeric.value))
            default:
                return .failure(location.newBasicUnexpectedTokenError(token))
            }

        case let .failure(error):
            return .failure(error)
        }
    }

    /// Parses an optional alpha value, returning nil for the "none" keyword.
    static func parseNoneOr(_ input: Parser) -> Result<CSSAlphaValue?, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(nil)
        }
        return parse(input).map { Optional($0) }
    }
}

// MARK: - ToCss

extension CSSAlphaValue: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if value == 1.0 {
            dest.write("1")
        } else {
            for decimals in 2 ... 6 {
                let multiplier = pow(10.0, Double(decimals))
                let rounded = (value * multiplier).rounded() / multiplier
                if abs(rounded - value) < 1e-7 {
                    let formatted = String(format: "%.\(decimals)g", value)
                    dest.write(formatted)
                    return
                }
            }
            dest.write(formatDouble(value))
        }
    }
}

// MARK: - Convenience

public extension CSSAlphaValue {
    /// Whether this alpha value is fully opaque.
    var isOpaque: Bool {
        value >= 1.0
    }

    /// Whether this alpha value is fully transparent.
    var isTransparent: Bool {
        value <= 0.0
    }

    /// Returns the value as a percentage (0-100).
    var percentValue: Double {
        value * 100.0
    }
}

// MARK: - ExpressibleByFloatLiteral

extension CSSAlphaValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.init(value)
    }
}

// MARK: - Comparable

extension CSSAlphaValue: Comparable {
    public static func < (lhs: CSSAlphaValue, rhs: CSSAlphaValue) -> Bool {
        lhs.value < rhs.value
    }
}
