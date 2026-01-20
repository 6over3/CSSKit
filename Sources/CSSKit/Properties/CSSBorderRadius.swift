// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A value for the `border-radius` shorthand property.
/// https://www.w3.org/TR/css-backgrounds-3/#border-radius
public struct CSSBorderRadius: Equatable, Sendable, Hashable {
    /// The x and y radius values for the top left corner.
    public var topLeft: CSSSize2D<CSSLengthPercentage>
    /// The x and y radius values for the top right corner.
    public var topRight: CSSSize2D<CSSLengthPercentage>
    /// The x and y radius values for the bottom right corner.
    public var bottomRight: CSSSize2D<CSSLengthPercentage>
    /// The x and y radius values for the bottom left corner.
    public var bottomLeft: CSSSize2D<CSSLengthPercentage>

    public init(
        topLeft: CSSSize2D<CSSLengthPercentage>,
        topRight: CSSSize2D<CSSLengthPercentage>,
        bottomRight: CSSSize2D<CSSLengthPercentage>,
        bottomLeft: CSSSize2D<CSSLengthPercentage>
    ) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomRight = bottomRight
        self.bottomLeft = bottomLeft
    }

    /// Creates a border radius with the same value for all corners.
    public init(_ all: CSSSize2D<CSSLengthPercentage>) {
        topLeft = all
        topRight = all
        bottomRight = all
        bottomLeft = all
    }

    /// Creates a border radius with the same value for all corners (single length/percentage).
    public init(_ all: CSSLengthPercentage) {
        let size = CSSSize2D(width: all, height: all)
        topLeft = size
        topRight = size
        bottomRight = size
        bottomLeft = size
    }

    /// The default value (all zeros).
    public static var `default`: Self {
        let zeroLP = CSSLengthPercentage.dimension(CSSLength(0, .px))
        let zero = CSSSize2D(width: zeroLP, height: zeroLP)
        return Self(topLeft: zero, topRight: zero, bottomRight: zero, bottomLeft: zero)
    }
}

// MARK: - Parsing

extension CSSBorderRadius {
    /// Parses a `border-radius` value.
    /// Syntax: `<length-percentage>{1,4} [ / <length-percentage>{1,4} ]?`
    static func parse(_ input: Parser) -> Result<CSSBorderRadius, BasicParseError> {
        // Parse horizontal radii
        guard case let .success(widths) = parseRadiusRect(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Check for optional `/` separator for vertical radii
        let heights: CSSRect<CSSLengthPercentage>
        if input.tryParse({ $0.expectDelim("/") }).isOK {
            guard case let .success(h) = parseRadiusRect(input) else {
                return .failure(input.newBasicError(.endOfInput))
            }
            heights = h
        } else {
            heights = widths
        }

        return .success(CSSBorderRadius(
            topLeft: CSSSize2D(width: widths.top, height: heights.top),
            topRight: CSSSize2D(width: widths.right, height: heights.right),
            bottomRight: CSSSize2D(width: widths.bottom, height: heights.bottom),
            bottomLeft: CSSSize2D(width: widths.left, height: heights.left)
        ))
    }

    /// Parses 1-4 length-percentage values into a rect.
    private static func parseRadiusRect(_ input: Parser) -> Result<CSSRect<CSSLengthPercentage>, BasicParseError> {
        guard case let .success(first) = CSSLengthPercentage.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Try second value
        guard case let .success(second) = input.tryParse({ CSSLengthPercentage.parse($0) }) else {
            // One value: all same
            return .success(CSSRect(all: first))
        }

        // Try third value
        guard case let .success(third) = input.tryParse({ CSSLengthPercentage.parse($0) }) else {
            // Two values: first = top/bottom, second = left/right
            return .success(CSSRect(vertical: first, horizontal: second))
        }

        // Try fourth value
        if case let .success(fourth) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
            // Four values: top, right, bottom, left
            return .success(CSSRect(top: first, right: second, bottom: third, left: fourth))
        }

        // Three values: top, left/right, bottom
        return .success(CSSRect(top: first, right: second, bottom: third, left: second))
    }
}

// MARK: - ToCss

extension CSSBorderRadius: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        // Extract horizontal and vertical radii
        let widths = CSSRect(
            top: topLeft.width,
            right: topRight.width,
            bottom: bottomRight.width,
            left: bottomLeft.width
        )
        let heights = CSSRect(
            top: topLeft.height,
            right: topRight.height,
            bottom: bottomRight.height,
            left: bottomLeft.height
        )

        // Output horizontal radii
        widths.serialize(dest: &dest)

        // Only output vertical radii if different from horizontal
        if widths != heights {
            dest.write(" / ")
            heights.serialize(dest: &dest)
        }
    }
}
