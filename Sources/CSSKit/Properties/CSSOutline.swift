// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Outline Style

/// A value for the `outline-style` property.
/// https://drafts.csswg.org/css-ui/#outline-style
public enum CSSOutlineStyle: Equatable, Sendable, Hashable {
    /// The `auto` keyword.
    case auto
    /// A value equivalent to the `border-style` property.
    case lineStyle(CSSLineStyle)

    /// The default value (none).
    public static var `default`: Self { .lineStyle(.none) }
}

// MARK: - Outline

/// A value for the `outline` shorthand property.
/// https://drafts.csswg.org/css-ui/#outline
public struct CSSOutline: Equatable, Sendable, Hashable {
    /// The outline width.
    public var width: CSSBorderSideWidth
    /// The outline style.
    public var style: CSSOutlineStyle
    /// The outline color.
    public var color: Color

    public init(
        width: CSSBorderSideWidth = .medium,
        style: CSSOutlineStyle = .lineStyle(.none),
        color: Color = .currentColor
    ) {
        self.width = width
        self.style = style
        self.color = color
    }

    /// The default outline value.
    public static var `default`: Self {
        Self(width: .medium, style: .lineStyle(.none), color: .currentColor)
    }
}

// MARK: - Parsing

extension CSSOutlineStyle {
    static func parse(_ input: Parser) -> Result<CSSOutlineStyle, BasicParseError> {
        // Try auto keyword first
        if input.tryParse({ $0.expectIdentMatching("auto") }).isOK {
            return .success(.auto)
        }

        // Try line style
        if case let .success(lineStyle) = CSSLineStyle.parse(input) {
            return .success(.lineStyle(lineStyle))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSOutline {
    static func parse(_ input: Parser) -> Result<CSSOutline, BasicParseError> {
        var color: Color?
        var style: CSSOutlineStyle?
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
                if case let .success(s) = input.tryParse({ CSSOutlineStyle.parse($0) }) {
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
            return .success(CSSOutline(
                width: width ?? .medium,
                style: style ?? .lineStyle(.none),
                color: color ?? .currentColor
            ))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

// MARK: - ToCss

extension CSSOutlineStyle: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .auto:
            dest.write("auto")
        case let .lineStyle(style):
            style.serialize(dest: &dest)
        }
    }
}

extension CSSOutline: CSSSerializable {
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
