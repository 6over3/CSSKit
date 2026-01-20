// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A single box shadow value.
/// https://drafts.csswg.org/css-backgrounds/#box-shadow
public struct CSSBoxShadow: Equatable, Sendable, Hashable {
    /// The color of the box shadow.
    public var color: Color
    /// The x offset of the shadow.
    public var xOffset: CSSLength
    /// The y offset of the shadow.
    public var yOffset: CSSLength
    /// The blur radius of the shadow.
    public var blur: CSSLength
    /// The spread distance of the shadow.
    public var spread: CSSLength
    /// Whether the shadow is inset within the box.
    public var inset: Bool

    public init(
        color: Color = .currentColor,
        xOffset: CSSLength,
        yOffset: CSSLength,
        blur: CSSLength = .zero,
        spread: CSSLength = .zero,
        inset: Bool = false
    ) {
        self.color = color
        self.xOffset = xOffset
        self.yOffset = yOffset
        self.blur = blur
        self.spread = spread
        self.inset = inset
    }
}

/// A value for the `box-shadow` property (list of shadows).
/// https://drafts.csswg.org/css-backgrounds/#box-shadow
public enum CSSBoxShadowList: Equatable, Sendable, Hashable {
    /// The `none` keyword (no shadow).
    case none
    /// A list of box shadows.
    case shadows([CSSBoxShadow])

    /// The default value (none).
    public static var `default`: Self { .none }
}

// MARK: - Parsing

extension CSSBoxShadow {
    static func parse(_ input: Parser) -> Result<CSSBoxShadow, BasicParseError> {
        var color: Color?
        var lengths: (CSSLength, CSSLength, CSSLength, CSSLength)?
        var inset = false

        // Order doesn't matter, parse in any order
        while true {
            if !inset {
                if input.tryParse({ $0.expectIdentMatching("inset") }).isOK {
                    inset = true
                    continue
                }
            }

            if lengths == nil {
                if case let .success(l) = input.tryParse({ inp -> Result<(CSSLength, CSSLength, CSSLength, CSSLength), BasicParseError> in
                    guard case let .success(horizontal) = CSSLength.parse(inp) else {
                        return .failure(inp.newBasicError(.endOfInput))
                    }
                    guard case let .success(vertical) = CSSLength.parse(inp) else {
                        return .failure(inp.newBasicError(.endOfInput))
                    }
                    let blur: CSSLength = if case let .success(b) = inp.tryParse({ CSSLength.parse($0) }) {
                        b
                    } else {
                        .zero
                    }
                    let spread: CSSLength = if case let .success(s) = inp.tryParse({ CSSLength.parse($0) }) {
                        s
                    } else {
                        .zero
                    }
                    return .success((horizontal, vertical, blur, spread))
                }) {
                    lengths = l
                    continue
                }
            }

            if color == nil {
                if case let .success(c) = input.tryParse({ Color.parse($0) }) {
                    color = c
                    continue
                }
            }

            break
        }

        guard let lengths else {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(CSSBoxShadow(
            color: color ?? .currentColor,
            xOffset: lengths.0,
            yOffset: lengths.1,
            blur: lengths.2,
            spread: lengths.3,
            inset: inset
        ))
    }
}

extension CSSBoxShadowList {
    static func parse(_ input: Parser) -> Result<CSSBoxShadowList, BasicParseError> {
        // Try none keyword
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        // Parse comma-separated list of shadows
        var shadows: [CSSBoxShadow] = []

        guard case let .success(first) = CSSBoxShadow.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }
        shadows.append(first)

        while input.tryParse({ $0.expectComma() }).isOK {
            guard case let .success(shadow) = CSSBoxShadow.parse(input) else {
                return .failure(input.newBasicError(.endOfInput))
            }
            shadows.append(shadow)
        }

        return .success(.shadows(shadows))
    }
}

// MARK: - ToCss

extension CSSBoxShadow: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if inset {
            dest.write("inset ")
        }

        xOffset.serialize(dest: &dest)
        dest.write(" ")
        yOffset.serialize(dest: &dest)

        if blur != .zero || spread != .zero {
            dest.write(" ")
            blur.serialize(dest: &dest)

            if spread != .zero {
                dest.write(" ")
                spread.serialize(dest: &dest)
            }
        }

        if color != .currentColor {
            dest.write(" ")
            color.serialize(dest: &dest)
        }
    }
}

extension CSSBoxShadowList: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case let .shadows(shadows):
            var first = true
            for shadow in shadows {
                if first {
                    first = false
                } else {
                    dest.write(", ")
                }
                shadow.serialize(dest: &dest)
            }
        }
    }
}
