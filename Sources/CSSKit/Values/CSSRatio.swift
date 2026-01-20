// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A CSS `<ratio>` value (e.g. 16/9). https://www.w3.org/TR/css-values-4/#ratios
public struct CSSRatio: Equatable, Sendable, Hashable {
    /// The numerator (width component).
    public let numerator: Double

    /// The denominator (height component).
    public let denominator: Double

    /// Creates a ratio with the given numerator and denominator.
    public init(_ numerator: Double, _ denominator: Double = 1.0) {
        self.numerator = numerator
        self.denominator = denominator
    }

    /// The ratio as a single value (numerator / denominator).
    public var value: Double {
        numerator / denominator
    }

    /// Common aspect ratios.
    public static let widescreen = Self(16, 9)
    public static let fullscreen = Self(4, 3)
    public static let square = Self(1, 1)
}

// MARK: - Parsing

extension CSSRatio {
    /// Parses a `<ratio>` value (number or number / number).
    static func parse(_ input: Parser) -> Result<CSSRatio, BasicParseError> {
        guard case let .success(numerator) = input.expectNumber() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Try to parse " / denominator"
        if input.tryParse({ $0.expectDelim("/") }).isOK {
            guard case let .success(denominator) = input.expectNumber() else {
                return .failure(input.newBasicError(.endOfInput))
            }
            return .success(CSSRatio(numerator, denominator))
        }

        // Just a single number
        return .success(CSSRatio(numerator))
    }
}

// MARK: - ToCss

extension CSSRatio: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        numerator.serialize(dest: &dest)
        if denominator != 1.0 {
            dest.write(" / ")
            denominator.serialize(dest: &dest)
        }
    }
}

// MARK: - Comparable

extension CSSRatio: Comparable {
    public static func < (lhs: CSSRatio, rhs: CSSRatio) -> Bool {
        lhs.value < rhs.value
    }
}
