// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A CSS rectangle value with top, right, bottom, and left components.
/// Used for properties like `margin`, `padding`, `border-width`, etc.
public struct CSSRect<T: Equatable & Sendable & CSSSerializable>: Equatable, Sendable {
    /// The top value.
    public let top: T

    /// The right value.
    public let right: T

    /// The bottom value.
    public let bottom: T

    /// The left value.
    public let left: T

    /// Creates a rect with all four values specified.
    public init(top: T, right: T, bottom: T, left: T) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }

    /// Creates a rect with the same value for all sides.
    public init(all: T) {
        top = all
        right = all
        bottom = all
        left = all
    }

    /// Creates a rect with vertical and horizontal values (top/bottom, left/right).
    public init(vertical: T, horizontal: T) {
        top = vertical
        right = horizontal
        bottom = vertical
        left = horizontal
    }

    /// Creates a rect with top, horizontal, and bottom values.
    public init(top: T, horizontal: T, bottom: T) {
        self.top = top
        right = horizontal
        self.bottom = bottom
        left = horizontal
    }
}

// MARK: - Hashable

extension CSSRect: Hashable where T: Hashable {}

// MARK: - Parsing

extension CSSRect where T: CSSParseable {
    /// Parses a CSS rect value (1-4 values in CSS shorthand format).
    static func parse(_ input: Parser) -> Result<CSSRect<T>, BasicParseError> {
        // Parse first value
        guard case let .success(first) = T.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Try second value
        guard case let .success(second) = input.tryParse({ T.parse($0) }) else {
            // Only one value: apply to all sides
            return .success(CSSRect(all: first))
        }

        // Try third value
        guard case let .success(third) = input.tryParse({ T.parse($0) }) else {
            // Two values: top/bottom, left/right
            return .success(CSSRect(vertical: first, horizontal: second))
        }

        // Try fourth value
        guard case let .success(fourth) = input.tryParse({ T.parse($0) }) else {
            // Three values: top, left/right, bottom
            return .success(CSSRect(top: first, horizontal: second, bottom: third))
        }

        // Four values: top, right, bottom, left
        return .success(CSSRect(top: first, right: second, bottom: third, left: fourth))
    }
}

// MARK: - ToCss

extension CSSRect: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        // Try to minimize output
        if top == right, right == bottom, bottom == left {
            // All four are the same: output one value
            top.serialize(dest: &dest)
        } else if top == bottom, right == left {
            // Vertical and horizontal pairs: output two values
            top.serialize(dest: &dest)
            dest.write(" ")
            right.serialize(dest: &dest)
        } else if right == left {
            // Top, horizontal, bottom: output three values
            top.serialize(dest: &dest)
            dest.write(" ")
            right.serialize(dest: &dest)
            dest.write(" ")
            bottom.serialize(dest: &dest)
        } else {
            // All different: output four values
            top.serialize(dest: &dest)
            dest.write(" ")
            right.serialize(dest: &dest)
            dest.write(" ")
            bottom.serialize(dest: &dest)
            dest.write(" ")
            left.serialize(dest: &dest)
        }
    }
}

// MARK: - Common Type Aliases

/// A rect of length-percentage values.
public typealias CSSLengthPercentageRect = CSSRect<CSSLengthPercentage>

/// A rect of length-percentage-or-auto values.
public typealias CSSLengthPercentageOrAutoRect = CSSRect<CSSLengthPercentageOrAuto>
