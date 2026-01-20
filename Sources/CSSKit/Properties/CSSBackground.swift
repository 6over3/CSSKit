// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Background Repeat Keyword

/// A repeat style value used within `background-repeat`.
/// https://www.w3.org/TR/css-backgrounds-3/#typedef-repeat-style
public enum CSSBackgroundRepeatKeyword: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The image is repeated in this direction.
    case `repeat`
    /// The image is repeated so that it fits, and then spaced apart evenly.
    case space
    /// The image is scaled so that it repeats an even number of times.
    case round
    /// The image is placed once and not repeated in this direction.
    case noRepeat = "no-repeat"

    /// The default value (repeat).
    public static var `default`: Self { .repeat }
}

// MARK: - Background Repeat

/// A value for the `background-repeat` property.
/// https://www.w3.org/TR/css-backgrounds-3/#background-repeat
public struct CSSBackgroundRepeat: Equatable, Sendable, Hashable {
    /// A repeat style for the x direction.
    public var x: CSSBackgroundRepeatKeyword
    /// A repeat style for the y direction.
    public var y: CSSBackgroundRepeatKeyword

    public init(x: CSSBackgroundRepeatKeyword = .repeat, y: CSSBackgroundRepeatKeyword = .repeat) {
        self.x = x
        self.y = y
    }

    /// The default value (repeat repeat).
    public static var `default`: Self {
        Self(x: .repeat, y: .repeat)
    }

    /// Creates a repeat-x value.
    public static var repeatX: Self {
        Self(x: .repeat, y: .noRepeat)
    }

    /// Creates a repeat-y value.
    public static var repeatY: Self {
        Self(x: .noRepeat, y: .repeat)
    }
}

// MARK: - Background Attachment

/// A value for the `background-attachment` property.
/// https://www.w3.org/TR/css-backgrounds-3/#background-attachment
public enum CSSBackgroundAttachment: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The background scrolls with the container.
    case scroll
    /// The background is fixed to the viewport.
    case fixed
    /// The background is fixed with regard to the element's contents.
    case local

    /// The default value (scroll).
    public static var `default`: Self { .scroll }
}

// MARK: - Background Origin

/// A value for the `background-origin` property.
/// https://www.w3.org/TR/css-backgrounds-3/#background-origin
public enum CSSBackgroundOrigin: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The position is relative to the border box.
    case borderBox = "border-box"
    /// The position is relative to the padding box.
    case paddingBox = "padding-box"
    /// The position is relative to the content box.
    case contentBox = "content-box"

    /// The default value (padding-box).
    public static var `default`: Self { .paddingBox }
}

// MARK: - Background Clip

/// A value for the `background-clip` property.
/// https://drafts.csswg.org/css-backgrounds-4/#background-clip
public enum CSSBackgroundClip: Equatable, Sendable, Hashable {
    /// The background is clipped to the border box.
    case borderBox
    /// The background is clipped to the padding box.
    case paddingBox
    /// The background is clipped to the content box.
    case contentBox
    /// The background is clipped to the area painted by the border.
    case border
    /// The background is clipped to the text content of the element.
    case text

    /// The default value (border-box).
    public static var `default`: Self { .borderBox }

    /// Whether this is a standard background box (not border or text).
    public var isBackgroundBox: Bool {
        switch self {
        case .borderBox, .paddingBox, .contentBox:
            true
        case .border, .text:
            false
        }
    }
}

// MARK: - Background Position

/// A value for the `background-position` property.
/// https://drafts.csswg.org/css-backgrounds/#background-position
public struct CSSBackgroundPosition: Equatable, Sendable, Hashable {
    /// The x-position.
    public var x: CSSHorizontalPosition
    /// The y-position.
    public var y: CSSVerticalPosition

    public init(
        x: CSSHorizontalPosition = .lengthPercentage(.zero),
        y: CSSVerticalPosition = .lengthPercentage(.zero)
    ) {
        self.x = x
        self.y = y
    }

    /// Creates a background position from a generic position.
    public init(position: CSSPosition) {
        x = position.horizontal
        y = position.vertical
    }

    /// The default value (0% 0%).
    public static var `default`: Self {
        Self()
    }

    /// Converts to a generic position.
    public func toPosition() -> CSSPosition {
        CSSPosition(horizontal: x, vertical: y)
    }

    /// Whether this position is at the origin (0 0).
    public var isZero: Bool {
        switch (x, y) {
        case let (.lengthPercentage(xLp), .lengthPercentage(yLp)):
            xLp.isZero && yLp.isZero
        case (.keyword(.left), .keyword(.top)):
            true
        default:
            false
        }
    }
}

// MARK: - Background

/// A value for the `background` shorthand property.
/// https://www.w3.org/TR/css-backgrounds-3/#background
public struct CSSBackground: Equatable, Sendable, Hashable {
    /// The background image.
    public var image: CSSImage
    /// The background color.
    public var color: Color
    /// The background position.
    public var position: CSSBackgroundPosition
    /// How the background image should repeat.
    public var `repeat`: CSSBackgroundRepeat
    /// The size of the background image.
    public var size: CSSBackgroundSize
    /// The background attachment.
    public var attachment: CSSBackgroundAttachment
    /// The background origin.
    public var origin: CSSBackgroundOrigin
    /// How the background should be clipped.
    public var clip: CSSBackgroundClip

    public init(
        image: CSSImage = .none,
        color: Color = .rgba(RgbaLegacy(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)),
        position: CSSBackgroundPosition = .default,
        repeat: CSSBackgroundRepeat = .default,
        size: CSSBackgroundSize = .auto,
        attachment: CSSBackgroundAttachment = .scroll,
        origin: CSSBackgroundOrigin = .paddingBox,
        clip: CSSBackgroundClip = .borderBox
    ) {
        self.image = image
        self.color = color
        self.position = position
        self.repeat = `repeat`
        self.size = size
        self.attachment = attachment
        self.origin = origin
        self.clip = clip
    }

    /// The default background value.
    public static var `default`: Self {
        Self()
    }
}

/// A list of background layers.
public struct CSSBackgroundList: Equatable, Sendable, Hashable {
    /// The background layers.
    public var backgrounds: [CSSBackground]

    public init(backgrounds: [CSSBackground]) {
        self.backgrounds = backgrounds
    }

    /// Creates a single-layer background list.
    public init(background: CSSBackground) {
        backgrounds = [background]
    }
}

// MARK: - Parsing

extension CSSBackgroundRepeatKeyword {
    static func parse(_ input: Parser) -> Result<CSSBackgroundRepeatKeyword, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let value = ident.value.lowercased()
        if let keyword = CSSBackgroundRepeatKeyword.allCases.first(where: { $0.rawValue == value }) {
            return .success(keyword)
        }

        return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
    }
}

extension CSSBackgroundRepeat {
    static func parse(_ input: Parser) -> Result<CSSBackgroundRepeat, BasicParseError> {
        // Try repeat-x / repeat-y first
        if case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
            switch ident.value.lowercased() {
            case "repeat-x":
                return .success(.repeatX)
            case "repeat-y":
                return .success(.repeatY)
            default:
                break
            }
        }

        guard case let .success(x) = CSSBackgroundRepeatKeyword.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let y: CSSBackgroundRepeatKeyword = if case let .success(yVal) = input.tryParse({ CSSBackgroundRepeatKeyword.parse($0) }) {
            yVal
        } else {
            x
        }

        return .success(CSSBackgroundRepeat(x: x, y: y))
    }
}

extension CSSBackgroundAttachment {
    static func parse(_ input: Parser) -> Result<CSSBackgroundAttachment, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let value = ident.value.lowercased()
        if let attachment = CSSBackgroundAttachment.allCases.first(where: { $0.rawValue == value }) {
            return .success(attachment)
        }

        return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
    }
}

extension CSSBackgroundOrigin {
    static func parse(_ input: Parser) -> Result<CSSBackgroundOrigin, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let value = ident.value.lowercased()
        if let origin = CSSBackgroundOrigin.allCases.first(where: { $0.rawValue == value }) {
            return .success(origin)
        }

        return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
    }
}

extension CSSBackgroundClip {
    static func parse(_ input: Parser) -> Result<CSSBackgroundClip, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        switch ident.value.lowercased() {
        case "border-box":
            return .success(.borderBox)
        case "padding-box":
            return .success(.paddingBox)
        case "content-box":
            return .success(.contentBox)
        case "border":
            return .success(.border)
        case "text":
            return .success(.text)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSBackgroundPosition {
    static func parse(_ input: Parser) -> Result<CSSBackgroundPosition, BasicParseError> {
        guard case let .success(position) = CSSPosition.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }
        return .success(CSSBackgroundPosition(position: position))
    }
}

extension CSSBackground {
    static func parse(_ input: Parser) -> Result<CSSBackground, BasicParseError> {
        var color: Color?
        var position: CSSBackgroundPosition?
        var size: CSSBackgroundSize?
        var image: CSSImage?
        var `repeat`: CSSBackgroundRepeat?
        var attachment: CSSBackgroundAttachment?
        var origin: CSSBackgroundOrigin?
        var clip: CSSBackgroundClip?

        while true {
            // Color
            if color == nil {
                if case let .success(c) = input.tryParse({ Color.parse($0) }) {
                    color = c
                    continue
                }
            }

            // Position
            if position == nil {
                if case let .success(pos) = input.tryParse({ CSSBackgroundPosition.parse($0) }) {
                    position = pos

                    // Try to parse size after /
                    if case let .success(s) = input.tryParse({ inp -> Result<CSSBackgroundSize, BasicParseError> in
                        guard inp.expectDelim("/").isOK else {
                            return .failure(inp.newBasicError(.endOfInput))
                        }
                        return CSSBackgroundSize.parse(inp)
                    }) {
                        size = s
                    }

                    continue
                }
            }

            // Image
            if image == nil {
                if case let .success(img) = input.tryParse({ CSSImage.parse($0) }) {
                    image = img
                    continue
                }
            }

            // Repeat
            if `repeat` == nil {
                if case let .success(rep) = input.tryParse({ CSSBackgroundRepeat.parse($0) }) {
                    `repeat` = rep
                    continue
                }
            }

            // Attachment
            if attachment == nil {
                if case let .success(att) = input.tryParse({ CSSBackgroundAttachment.parse($0) }) {
                    attachment = att
                    continue
                }
            }

            // Origin
            if origin == nil {
                if case let .success(orig) = input.tryParse({ CSSBackgroundOrigin.parse($0) }) {
                    origin = orig
                    continue
                }
            }

            // Clip
            if clip == nil {
                if case let .success(c) = input.tryParse({ CSSBackgroundClip.parse($0) }) {
                    clip = c
                    continue
                }
            }

            break
        }

        // If clip is not set but origin is, clip defaults to origin
        if clip == nil, let origin {
            clip = origin.toClip()
        }

        return .success(CSSBackground(
            image: image ?? .none,
            color: color ?? .rgba(RgbaLegacy(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)),
            position: position ?? .default,
            repeat: `repeat` ?? .default,
            size: size ?? .auto,
            attachment: attachment ?? .scroll,
            origin: origin ?? .paddingBox,
            clip: clip ?? .borderBox
        ))
    }
}

extension CSSBackgroundList {
    static func parse(_ input: Parser) -> Result<CSSBackgroundList, BasicParseError> {
        var backgrounds: [CSSBackground] = []

        guard case let .success(first) = CSSBackground.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }
        backgrounds.append(first)

        while input.tryParse({ $0.expectComma() }).isOK {
            guard case let .success(bg) = CSSBackground.parse(input) else {
                return .failure(input.newBasicError(.endOfInput))
            }
            backgrounds.append(bg)
        }

        return .success(CSSBackgroundList(backgrounds: backgrounds))
    }
}

// MARK: - Origin to Clip Conversion

public extension CSSBackgroundOrigin {
    /// Converts origin to the equivalent clip value.
    func toClip() -> CSSBackgroundClip {
        switch self {
        case .borderBox:
            .borderBox
        case .paddingBox:
            .paddingBox
        case .contentBox:
            .contentBox
        }
    }
}

// MARK: - ToCss

extension CSSBackgroundRepeatKeyword: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSBackgroundRepeat: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch (x, y) {
        case (.repeat, .noRepeat):
            dest.write("repeat-x")
        case (.noRepeat, .repeat):
            dest.write("repeat-y")
        case let (x, y):
            x.serialize(dest: &dest)
            if y != x {
                dest.write(" ")
                y.serialize(dest: &dest)
            }
        }
    }
}

extension CSSBackgroundAttachment: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSBackgroundOrigin: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSBackgroundClip: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .borderBox:
            dest.write("border-box")
        case .paddingBox:
            dest.write("padding-box")
        case .contentBox:
            dest.write("content-box")
        case .border:
            dest.write("border")
        case .text:
            dest.write("text")
        }
    }
}

extension CSSBackgroundPosition: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        toPosition().serialize(dest: &dest)
    }
}

extension CSSBackground: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        var hasOutput = false

        if color != .rgba(RgbaLegacy(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)) {
            color.serialize(dest: &dest)
            hasOutput = true
        }

        if image != .none {
            if hasOutput { dest.write(" ") }
            image.serialize(dest: &dest)
            hasOutput = true
        }

        if !position.isZero || size != .auto {
            if hasOutput { dest.write(" ") }
            position.serialize(dest: &dest)

            if size != .auto {
                dest.write(" / ")
                size.serialize(dest: &dest)
            }
            hasOutput = true
        }

        if `repeat` != .default {
            if hasOutput { dest.write(" ") }
            `repeat`.serialize(dest: &dest)
            hasOutput = true
        }

        if attachment != .scroll {
            if hasOutput { dest.write(" ") }
            attachment.serialize(dest: &dest)
            hasOutput = true
        }

        let outputPaddingBox = origin != .paddingBox ||
            (clip != .borderBox && clip.isBackgroundBox)
        if outputPaddingBox {
            if hasOutput { dest.write(" ") }
            origin.serialize(dest: &dest)
            hasOutput = true
        }

        if (outputPaddingBox && clip != origin.toClip()) || clip != .borderBox {
            if hasOutput { dest.write(" ") }
            clip.serialize(dest: &dest)
            hasOutput = true
        }

        if !hasOutput {
            dest.write("none")
        }
    }
}

extension CSSBackgroundList: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        var first = true
        for background in backgrounds {
            if first {
                first = false
            } else {
                dest.write(", ")
            }
            background.serialize(dest: &dest)
        }
    }
}
