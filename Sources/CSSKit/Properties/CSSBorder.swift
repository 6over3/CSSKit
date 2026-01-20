// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Border Side Width

/// A value for the `border-width` property.
/// https://www.w3.org/TR/css-backgrounds-3/#border-width
public enum CSSBorderSideWidth: Equatable, Sendable, Hashable {
    /// A UA defined `thin` value.
    case thin
    /// A UA defined `medium` value.
    case medium
    /// A UA defined `thick` value.
    case thick
    /// An explicit width.
    case length(CSSLength)

    /// The default value (medium).
    public static var `default`: Self { .medium }
}

// MARK: - Line Style

/// A `<line-style>` value, used in the `border-style` property.
/// https://drafts.csswg.org/css-backgrounds/#typedef-line-style
public enum CSSLineStyle: String, Equatable, Sendable, Hashable, CaseIterable {
    /// No border.
    case none
    /// Similar to `none` but with different rules for tables.
    case hidden
    /// Looks as if the content on the inside of the border is sunken into the canvas.
    case inset
    /// Looks as if it were carved in the canvas.
    case groove
    /// Looks as if the content on the inside of the border is coming out of the canvas.
    case outset
    /// Looks as if it were coming out of the canvas.
    case ridge
    /// A series of round dots.
    case dotted
    /// A series of square-ended dashes.
    case dashed
    /// A single line segment.
    case solid
    /// Two parallel solid lines with some space between them.
    case double

    /// The default value (none).
    public static var `default`: Self { .none }
}

// MARK: - Border Side

/// A value for a single border side shorthand property (e.g., `border-top`).
/// https://www.w3.org/TR/css-backgrounds-3/#propdef-border-top
public struct CSSBorderSide: Equatable, Sendable, Hashable {
    /// The width of the border.
    public var width: CSSBorderSideWidth
    /// The border style.
    public var style: CSSLineStyle
    /// The border color.
    public var color: Color

    public init(
        width: CSSBorderSideWidth = .medium,
        style: CSSLineStyle = .none,
        color: Color = .currentColor
    ) {
        self.width = width
        self.style = style
        self.color = color
    }

    /// The default border value.
    public static var `default`: Self {
        Self(width: .medium, style: .none, color: .currentColor)
    }
}

// MARK: - Border Style Rect

/// A value for the `border-style` shorthand property.
/// https://drafts.csswg.org/css-backgrounds/#propdef-border-style
public struct CSSBorderStyle: Equatable, Sendable, Hashable {
    public var top: CSSLineStyle
    public var right: CSSLineStyle
    public var bottom: CSSLineStyle
    public var left: CSSLineStyle

    public init(top: CSSLineStyle, right: CSSLineStyle, bottom: CSSLineStyle, left: CSSLineStyle) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }

    /// Creates a border style with the same value on all sides.
    public init(_ all: CSSLineStyle) {
        top = all
        right = all
        bottom = all
        left = all
    }

    /// Creates a border style with vertical and horizontal values.
    public init(vertical: CSSLineStyle, horizontal: CSSLineStyle) {
        top = vertical
        right = horizontal
        bottom = vertical
        left = horizontal
    }
}

// MARK: - Border Width Rect

/// A value for the `border-width` shorthand property.
/// https://drafts.csswg.org/css-backgrounds/#propdef-border-width
public struct CSSBorderWidth: Equatable, Sendable, Hashable {
    public var top: CSSBorderSideWidth
    public var right: CSSBorderSideWidth
    public var bottom: CSSBorderSideWidth
    public var left: CSSBorderSideWidth

    public init(top: CSSBorderSideWidth, right: CSSBorderSideWidth, bottom: CSSBorderSideWidth, left: CSSBorderSideWidth) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }

    /// Creates a border width with the same value on all sides.
    public init(_ all: CSSBorderSideWidth) {
        top = all
        right = all
        bottom = all
        left = all
    }

    /// Creates a border width with vertical and horizontal values.
    public init(vertical: CSSBorderSideWidth, horizontal: CSSBorderSideWidth) {
        top = vertical
        right = horizontal
        bottom = vertical
        left = horizontal
    }
}

// MARK: - Border Color Rect

/// A value for the `border-color` shorthand property.
/// https://drafts.csswg.org/css-backgrounds/#propdef-border-color
public struct CSSBorderColor: Equatable, Sendable, Hashable {
    public var top: Color
    public var right: Color
    public var bottom: Color
    public var left: Color

    public init(top: Color, right: Color, bottom: Color, left: Color) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }

    /// Creates a border color with the same value on all sides.
    public init(_ all: Color) {
        top = all
        right = all
        bottom = all
        left = all
    }

    /// Creates a border color with vertical and horizontal values.
    public init(vertical: Color, horizontal: Color) {
        top = vertical
        right = horizontal
        bottom = vertical
        left = horizontal
    }
}

// MARK: - Logical Border Shorthands

/// A value for the `border-block-style` shorthand property.
/// https://drafts.csswg.org/css-logical/#propdef-border-block-style
public struct CSSBorderBlockStyle: Equatable, Sendable, Hashable {
    /// The block start value.
    public var start: CSSLineStyle
    /// The block end value.
    public var end: CSSLineStyle

    public init(start: CSSLineStyle, end: CSSLineStyle) {
        self.start = start
        self.end = end
    }

    /// Creates with the same value for both.
    public init(_ both: CSSLineStyle) {
        start = both
        end = both
    }
}

/// A value for the `border-block-width` shorthand property.
/// https://drafts.csswg.org/css-logical/#propdef-border-block-width
public struct CSSBorderBlockWidth: Equatable, Sendable, Hashable {
    /// The block start value.
    public var start: CSSBorderSideWidth
    /// The block end value.
    public var end: CSSBorderSideWidth

    public init(start: CSSBorderSideWidth, end: CSSBorderSideWidth) {
        self.start = start
        self.end = end
    }

    /// Creates with the same value for both.
    public init(_ both: CSSBorderSideWidth) {
        start = both
        end = both
    }
}

/// A value for the `border-block-color` shorthand property.
/// https://drafts.csswg.org/css-logical/#propdef-border-block-color
public struct CSSBorderBlockColor: Equatable, Sendable, Hashable {
    /// The block start value.
    public var start: Color
    /// The block end value.
    public var end: Color

    public init(start: Color, end: Color) {
        self.start = start
        self.end = end
    }

    /// Creates with the same value for both.
    public init(_ both: Color) {
        start = both
        end = both
    }
}

/// A value for the `border-inline-style` shorthand property.
/// https://drafts.csswg.org/css-logical/#propdef-border-inline-style
public struct CSSBorderInlineStyle: Equatable, Sendable, Hashable {
    /// The inline start value.
    public var start: CSSLineStyle
    /// The inline end value.
    public var end: CSSLineStyle

    public init(start: CSSLineStyle, end: CSSLineStyle) {
        self.start = start
        self.end = end
    }

    /// Creates with the same value for both.
    public init(_ both: CSSLineStyle) {
        start = both
        end = both
    }
}

/// A value for the `border-inline-width` shorthand property.
/// https://drafts.csswg.org/css-logical/#propdef-border-inline-width
public struct CSSBorderInlineWidth: Equatable, Sendable, Hashable {
    /// The inline start value.
    public var start: CSSBorderSideWidth
    /// The inline end value.
    public var end: CSSBorderSideWidth

    public init(start: CSSBorderSideWidth, end: CSSBorderSideWidth) {
        self.start = start
        self.end = end
    }

    /// Creates with the same value for both.
    public init(_ both: CSSBorderSideWidth) {
        start = both
        end = both
    }
}

/// A value for the `border-inline-color` shorthand property.
/// https://drafts.csswg.org/css-logical/#propdef-border-inline-color
public struct CSSBorderInlineColor: Equatable, Sendable, Hashable {
    /// The inline start value.
    public var start: Color
    /// The inline end value.
    public var end: Color

    public init(start: Color, end: Color) {
        self.start = start
        self.end = end
    }

    /// Creates with the same value for both.
    public init(_ both: Color) {
        start = both
        end = both
    }
}

// MARK: - Parsing

extension CSSBorderSideWidth {
    static func parse(_ input: Parser) -> Result<CSSBorderSideWidth, BasicParseError> {
        // Try keywords first
        if case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
            switch ident.value.lowercased() {
            case "thin": return .success(.thin)
            case "medium": return .success(.medium)
            case "thick": return .success(.thick)
            default: break
            }
        }

        // Try length
        if case let .success(length) = input.tryParse({ CSSLength.parse($0) }) {
            return .success(.length(length))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSLineStyle {
    static func parse(_ input: Parser) -> Result<CSSLineStyle, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "none": return .success(.none)
        case "hidden": return .success(.hidden)
        case "inset": return .success(.inset)
        case "groove": return .success(.groove)
        case "outset": return .success(.outset)
        case "ridge": return .success(.ridge)
        case "dotted": return .success(.dotted)
        case "dashed": return .success(.dashed)
        case "solid": return .success(.solid)
        case "double": return .success(.double)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSBorderSide {
    static func parse(_ input: Parser) -> Result<CSSBorderSide, BasicParseError> {
        var color: Color?
        var style: CSSLineStyle?
        var width: CSSBorderSideWidth?
        var any = false

        // Order doesn't matter, parse in any order
        while true {
            if width == nil {
                if case let .success(w) = input.tryParse({ CSSBorderSideWidth.parse($0) }) {
                    width = w
                    any = true
                    continue
                }
            }

            if style == nil {
                if case let .success(s) = input.tryParse({ CSSLineStyle.parse($0) }) {
                    style = s
                    any = true
                    continue
                }
            }

            if color == nil {
                if case let .success(c) = input.tryParse({ Color.parse($0) }) {
                    color = c
                    any = true
                    continue
                }
            }

            break
        }

        if any {
            return .success(CSSBorderSide(
                width: width ?? .medium,
                style: style ?? .none,
                color: color ?? .currentColor
            ))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSBorderStyle {
    static func parse(_ input: Parser) -> Result<CSSBorderStyle, BasicParseError> {
        guard case let .success(top) = CSSLineStyle.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Try right
        guard case let .success(right) = input.tryParse({ CSSLineStyle.parse($0) }) else {
            return .success(CSSBorderStyle(top))
        }

        // Try bottom
        guard case let .success(bottom) = input.tryParse({ CSSLineStyle.parse($0) }) else {
            return .success(CSSBorderStyle(vertical: top, horizontal: right))
        }

        // Try left
        if case let .success(left) = input.tryParse({ CSSLineStyle.parse($0) }) {
            return .success(CSSBorderStyle(top: top, right: right, bottom: bottom, left: left))
        }

        return .success(CSSBorderStyle(top: top, right: right, bottom: bottom, left: right))
    }
}

extension CSSBorderWidth {
    static func parse(_ input: Parser) -> Result<CSSBorderWidth, BasicParseError> {
        guard case let .success(top) = CSSBorderSideWidth.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Try right
        guard case let .success(right) = input.tryParse({ CSSBorderSideWidth.parse($0) }) else {
            return .success(CSSBorderWidth(top))
        }

        // Try bottom
        guard case let .success(bottom) = input.tryParse({ CSSBorderSideWidth.parse($0) }) else {
            return .success(CSSBorderWidth(vertical: top, horizontal: right))
        }

        // Try left
        if case let .success(left) = input.tryParse({ CSSBorderSideWidth.parse($0) }) {
            return .success(CSSBorderWidth(top: top, right: right, bottom: bottom, left: left))
        }

        return .success(CSSBorderWidth(top: top, right: right, bottom: bottom, left: right))
    }
}

extension CSSBorderColor {
    static func parse(_ input: Parser) -> Result<CSSBorderColor, BasicParseError> {
        guard case let .success(top) = Color.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Try right
        guard case let .success(right) = input.tryParse({ Color.parse($0) }) else {
            return .success(CSSBorderColor(top))
        }

        // Try bottom
        guard case let .success(bottom) = input.tryParse({ Color.parse($0) }) else {
            return .success(CSSBorderColor(vertical: top, horizontal: right))
        }

        // Try left
        if case let .success(left) = input.tryParse({ Color.parse($0) }) {
            return .success(CSSBorderColor(top: top, right: right, bottom: bottom, left: left))
        }

        return .success(CSSBorderColor(top: top, right: right, bottom: bottom, left: right))
    }
}

extension CSSBorderBlockStyle {
    static func parse(_ input: Parser) -> Result<CSSBorderBlockStyle, BasicParseError> {
        guard case let .success(start) = CSSLineStyle.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        if case let .success(end) = input.tryParse({ CSSLineStyle.parse($0) }) {
            return .success(CSSBorderBlockStyle(start: start, end: end))
        }

        return .success(CSSBorderBlockStyle(start))
    }
}

extension CSSBorderBlockWidth {
    static func parse(_ input: Parser) -> Result<CSSBorderBlockWidth, BasicParseError> {
        guard case let .success(start) = CSSBorderSideWidth.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        if case let .success(end) = input.tryParse({ CSSBorderSideWidth.parse($0) }) {
            return .success(CSSBorderBlockWidth(start: start, end: end))
        }

        return .success(CSSBorderBlockWidth(start))
    }
}

extension CSSBorderBlockColor {
    static func parse(_ input: Parser) -> Result<CSSBorderBlockColor, BasicParseError> {
        guard case let .success(start) = Color.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        if case let .success(end) = input.tryParse({ Color.parse($0) }) {
            return .success(CSSBorderBlockColor(start: start, end: end))
        }

        return .success(CSSBorderBlockColor(start))
    }
}

extension CSSBorderInlineStyle {
    static func parse(_ input: Parser) -> Result<CSSBorderInlineStyle, BasicParseError> {
        guard case let .success(start) = CSSLineStyle.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        if case let .success(end) = input.tryParse({ CSSLineStyle.parse($0) }) {
            return .success(CSSBorderInlineStyle(start: start, end: end))
        }

        return .success(CSSBorderInlineStyle(start))
    }
}

extension CSSBorderInlineWidth {
    static func parse(_ input: Parser) -> Result<CSSBorderInlineWidth, BasicParseError> {
        guard case let .success(start) = CSSBorderSideWidth.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        if case let .success(end) = input.tryParse({ CSSBorderSideWidth.parse($0) }) {
            return .success(CSSBorderInlineWidth(start: start, end: end))
        }

        return .success(CSSBorderInlineWidth(start))
    }
}

extension CSSBorderInlineColor {
    static func parse(_ input: Parser) -> Result<CSSBorderInlineColor, BasicParseError> {
        guard case let .success(start) = Color.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        if case let .success(end) = input.tryParse({ Color.parse($0) }) {
            return .success(CSSBorderInlineColor(start: start, end: end))
        }

        return .success(CSSBorderInlineColor(start))
    }
}

// MARK: - ToCss

extension CSSBorderSideWidth: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .thin: dest.write("thin")
        case .medium: dest.write("medium")
        case .thick: dest.write("thick")
        case let .length(l): l.serialize(dest: &dest)
        }
    }
}

extension CSSLineStyle: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSBorderSide: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        // If all defaults, just output style
        if self == .default {
            style.serialize(dest: &dest)
            return
        }

        var needsSpace = false

        if width != .default {
            width.serialize(dest: &dest)
            needsSpace = true
        }

        if style != .default {
            if needsSpace { dest.write(" ") }
            style.serialize(dest: &dest)
            needsSpace = true
        }

        if color != .currentColor {
            if needsSpace { dest.write(" ") }
            color.serialize(dest: &dest)
        }
    }
}

extension CSSBorderStyle: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        top.serialize(dest: &dest)

        let topEqBottom = top == bottom
        let leftEqRight = left == right

        if topEqBottom, leftEqRight, top == left {
            // All same - already output
            return
        }

        dest.write(" ")
        right.serialize(dest: &dest)

        if topEqBottom, leftEqRight {
            // Two values
            return
        }

        dest.write(" ")
        bottom.serialize(dest: &dest)

        if left == right {
            // Three values
            return
        }

        dest.write(" ")
        left.serialize(dest: &dest)
    }
}

extension CSSBorderWidth: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        top.serialize(dest: &dest)

        let topEqBottom = top == bottom
        let leftEqRight = left == right

        if topEqBottom, leftEqRight, top == left {
            return
        }

        dest.write(" ")
        right.serialize(dest: &dest)

        if topEqBottom, leftEqRight {
            return
        }

        dest.write(" ")
        bottom.serialize(dest: &dest)

        if left == right {
            return
        }

        dest.write(" ")
        left.serialize(dest: &dest)
    }
}

extension CSSBorderColor: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        top.serialize(dest: &dest)

        let topEqBottom = top == bottom
        let leftEqRight = left == right

        if topEqBottom, leftEqRight, top == left {
            return
        }

        dest.write(" ")
        right.serialize(dest: &dest)

        if topEqBottom, leftEqRight {
            return
        }

        dest.write(" ")
        bottom.serialize(dest: &dest)

        if left == right {
            return
        }

        dest.write(" ")
        left.serialize(dest: &dest)
    }
}

extension CSSBorderBlockStyle: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if end != start {
            dest.write(" ")
            end.serialize(dest: &dest)
        }
    }
}

extension CSSBorderBlockWidth: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if end != start {
            dest.write(" ")
            end.serialize(dest: &dest)
        }
    }
}

extension CSSBorderBlockColor: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if end != start {
            dest.write(" ")
            end.serialize(dest: &dest)
        }
    }
}

extension CSSBorderInlineStyle: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if end != start {
            dest.write(" ")
            end.serialize(dest: &dest)
        }
    }
}

extension CSSBorderInlineWidth: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if end != start {
            dest.write(" ")
            end.serialize(dest: &dest)
        }
    }
}

extension CSSBorderInlineColor: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if end != start {
            dest.write(" ")
            end.serialize(dest: &dest)
        }
    }
}
