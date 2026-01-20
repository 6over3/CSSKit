// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Text Transform

/// Defines how text case should be transformed.
/// https://www.w3.org/TR/css-text-3/#text-transform-property
public enum CSSTextTransformCase: String, Equatable, Sendable, Hashable {
    /// Text should not be transformed.
    case none
    /// Text should be uppercased.
    case uppercase
    /// Text should be lowercased.
    case lowercase
    /// Each word should be capitalized.
    case capitalize
}

/// Defines how ideographic characters should be transformed.
/// https://www.w3.org/TR/css-text-3/#text-transform-property
public struct CSSTextTransformOther: OptionSet, Equatable, Sendable, Hashable {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    /// Puts all typographic character units in full-width form.
    public static let fullWidth = Self(rawValue: 1 << 0)
    /// Converts all small Kana characters to the equivalent full-size Kana.
    public static let fullSizeKana = Self(rawValue: 1 << 1)
}

/// A value for the `text-transform` property.
/// https://www.w3.org/TR/css-text-3/#text-transform-property
public struct CSSTextTransform: Equatable, Sendable, Hashable {
    /// How case should be transformed.
    public var `case`: CSSTextTransformCase
    /// How ideographic characters should be transformed.
    public var other: CSSTextTransformOther

    public init(case: CSSTextTransformCase = .none, other: CSSTextTransformOther = []) {
        self.case = `case`
        self.other = other
    }

    /// The `none` value.
    public static let none = Self(case: .none, other: [])
}

// MARK: - White Space & Word Breaking

/// A value for the `white-space` property.
/// https://www.w3.org/TR/css-text-3/#white-space-property
public enum CSSWhiteSpace: String, Equatable, Sendable, Hashable {
    /// Sequences of white space are collapsed into a single character.
    case normal
    /// White space is not collapsed.
    case pre
    /// White space is collapsed, but no line wrapping occurs.
    case nowrap
    /// White space is preserved, but line wrapping occurs.
    case preWrap = "pre-wrap"
    /// Like pre-wrap, but with different line breaking rules.
    case breakSpaces = "break-spaces"
    /// White space is collapsed, but with different line breaking rules.
    case preLine = "pre-line"
}

/// A value for the `word-break` property.
/// https://www.w3.org/TR/css-text-3/#word-break-property
public enum CSSWordBreak: String, Equatable, Sendable, Hashable {
    /// Words break according to their customary rules.
    case normal
    /// Breaking is forbidden within "words".
    case keepAll = "keep-all"
    /// Breaking is allowed within "words".
    case breakAll = "break-all"
    /// Breaking is allowed if there are no otherwise acceptable break points in a line.
    case breakWord = "break-word"
}

/// A value for the `line-break` property.
/// https://www.w3.org/TR/css-text-3/#line-break-property
public enum CSSLineBreak: String, Equatable, Sendable, Hashable {
    /// The UA determines the set of line-breaking restrictions to use.
    case auto
    /// Breaks text using the least restrictive set of line-breaking rules.
    case loose
    /// Breaks text using the most common set of line-breaking rules.
    case normal
    /// Breaks text using the most stringent set of line-breaking rules.
    case strict
    /// There is a soft wrap opportunity around every typographic character unit.
    case anywhere
}

/// A value for the `hyphens` property.
/// https://www.w3.org/TR/css-text-3/#hyphenation
public enum CSSHyphens: String, Equatable, Sendable, Hashable {
    /// Words are not hyphenated.
    case none
    /// Words are only hyphenated where there are characters inside the word that explicitly suggest hyphenation opportunities.
    case manual
    /// Words may be broken at hyphenation opportunities determined automatically by the UA.
    case auto
}

/// A value for the `overflow-wrap` property.
/// https://www.w3.org/TR/css-text-3/#overflow-wrap-property
public enum CSSOverflowWrap: String, Equatable, Sendable, Hashable {
    /// Lines may break only at allowed break points.
    case normal
    /// Breaking is allowed if there are no otherwise acceptable break points in a line.
    case anywhere
    /// As for anywhere except that soft wrap opportunities introduced by break-word are
    /// not considered when calculating min-content intrinsic sizes.
    case breakWord = "break-word"
}

// MARK: - Text Alignment

/// A value for the `text-align` property.
/// https://www.w3.org/TR/css-text-3/#text-align-property
public enum CSSTextAlign: String, Equatable, Sendable, Hashable {
    /// Inline-level content is aligned to the start edge of the line box.
    case start
    /// Inline-level content is aligned to the end edge of the line box.
    case end
    /// Inline-level content is aligned to the line-left edge of the line box.
    case left
    /// Inline-level content is aligned to the line-right edge of the line box.
    case right
    /// Inline-level content is centered within the line box.
    case center
    /// Text is justified according to the method specified by the text-justify property.
    case justify
    /// Matches the parent element.
    case matchParent = "match-parent"
    /// Same as justify, but also justifies the last line.
    case justifyAll = "justify-all"
}

/// A value for the `text-align-last` property.
/// https://www.w3.org/TR/css-text-3/#text-align-last-property
public enum CSSTextAlignLast: String, Equatable, Sendable, Hashable {
    /// Content on the affected line is aligned per `text-align-all` unless set to `justify`, in which case it is start-aligned.
    case auto
    /// Inline-level content is aligned to the start edge of the line box.
    case start
    /// Inline-level content is aligned to the end edge of the line box.
    case end
    /// Inline-level content is aligned to the line-left edge of the line box.
    case left
    /// Inline-level content is aligned to the line-right edge of the line box.
    case right
    /// Inline-level content is centered within the line box.
    case center
    /// Text is justified according to the method specified by the text-justify property.
    case justify
    /// Matches the parent element.
    case matchParent = "match-parent"
}

/// A value for the `text-justify` property.
/// https://www.w3.org/TR/css-text-3/#text-justify-property
public enum CSSTextJustify: String, Equatable, Sendable, Hashable {
    /// The UA determines the justification algorithm to follow.
    case auto
    /// Justification is disabled.
    case none
    /// Justification adjusts spacing at word separators only.
    case interWord = "inter-word"
    /// Justification adjusts spacing between each character.
    case interCharacter = "inter-character"
}

// MARK: - Spacing

/// A value for the `word-spacing` and `letter-spacing` properties.
/// https://www.w3.org/TR/css-text-3/#word-spacing-property
/// https://www.w3.org/TR/css-text-3/#letter-spacing-property
public enum CSSSpacing: Equatable, Sendable, Hashable {
    /// No additional spacing is applied.
    case normal
    /// Additional spacing between each word or letter.
    case length(CSSLength)
}

/// A value for the `text-indent` property.
/// https://www.w3.org/TR/css-text-3/#text-indent-property
public struct CSSTextIndent: Equatable, Sendable, Hashable {
    /// The amount to indent.
    public var value: CSSLengthPercentage
    /// Inverts which lines are affected.
    public var hanging: Bool
    /// Affects the first line after each hard break.
    public var eachLine: Bool

    public init(value: CSSLengthPercentage, hanging: Bool = false, eachLine: Bool = false) {
        self.value = value
        self.hanging = hanging
        self.eachLine = eachLine
    }
}

/// A value for the `text-size-adjust` property.
/// https://drafts.csswg.org/css-size-adjust/#adjustment-control
public enum CSSTextSizeAdjust: Equatable, Sendable, Hashable {
    /// Use the default size adjustment when displaying on a small device.
    case auto
    /// No size adjustment when displaying on a small device.
    case none
    /// When displaying on a small device, the font size is multiplied by this percentage.
    case percentage(CSSPercentage)
}

// MARK: - Text Decoration

/// A value for the `text-decoration-line` property.
/// https://www.w3.org/TR/css-text-decor-4/#text-decoration-line-property
public struct CSSTextDecorationLine: OptionSet, Equatable, Sendable, Hashable {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    /// Each line of text is underlined.
    public static let underline = Self(rawValue: 1 << 0)
    /// Each line of text has a line over it.
    public static let overline = Self(rawValue: 1 << 1)
    /// Each line of text has a line through the middle.
    public static let lineThrough = Self(rawValue: 1 << 2)
    /// The text blinks.
    public static let blink = Self(rawValue: 1 << 3)
    /// The text is decorated as a spelling error.
    public static let spellingError = Self(rawValue: 1 << 4)
    /// The text is decorated as a grammar error.
    public static let grammarError = Self(rawValue: 1 << 5)

    /// No decoration.
    public static let none: CSSTextDecorationLine = []
}

/// A value for the `text-decoration-style` property.
/// https://www.w3.org/TR/css-text-decor-4/#text-decoration-style-property
public enum CSSTextDecorationStyle: String, Equatable, Sendable, Hashable {
    /// A single line segment.
    case solid
    /// Two parallel solid lines with some space between them.
    case double
    /// A series of round dots.
    case dotted
    /// A series of square-ended dashes.
    case dashed
    /// A wavy line.
    case wavy

    /// The default value.
    public static let `default`: CSSTextDecorationStyle = .solid
}

/// A value for the `text-decoration-thickness` property.
/// https://www.w3.org/TR/css-text-decor-4/#text-decoration-width-property
public enum CSSTextDecorationThickness: Equatable, Sendable, Hashable {
    /// The UA chooses an appropriate thickness for text decoration lines.
    case auto
    /// Use the thickness defined in the current font.
    case fromFont
    /// An explicit length or percentage.
    case lengthPercentage(CSSLengthPercentage)

    /// The default value.
    public static let `default`: CSSTextDecorationThickness = .auto
}

/// A value for the `text-decoration` shorthand property.
/// https://www.w3.org/TR/css-text-decor-4/#text-decoration-property
public struct CSSTextDecoration: Equatable, Sendable, Hashable {
    /// The lines to display.
    public var line: CSSTextDecorationLine
    /// The thickness of the lines.
    public var thickness: CSSTextDecorationThickness
    /// The style of the lines.
    public var style: CSSTextDecorationStyle
    /// The color of the lines.
    public var color: Color
    /// The vendor prefix.
    public var vendorPrefix: CSSVendorPrefix

    public init(
        line: CSSTextDecorationLine = [],
        thickness: CSSTextDecorationThickness = .auto,
        style: CSSTextDecorationStyle = .solid,
        color: Color = .currentColor,
        vendorPrefix: CSSVendorPrefix = .none
    ) {
        self.line = line
        self.thickness = thickness
        self.style = style
        self.color = color
        self.vendorPrefix = vendorPrefix
    }

    /// The default value.
    public static let `default` = Self()
}

/// A value for the `text-decoration-skip-ink` property.
/// https://www.w3.org/TR/css-text-decor-4/#text-decoration-skip-ink-property
public enum CSSTextDecorationSkipInk: String, Equatable, Sendable, Hashable {
    /// UAs may interrupt underlines and overlines.
    case auto
    /// UAs must interrupt underlines and overlines.
    case none
    /// UA must draw continuous underlines and overlines.
    case all
}

// MARK: - Text Emphasis

/// A keyword for the fill mode in `text-emphasis-style`.
/// https://www.w3.org/TR/css-text-decor-4/#text-emphasis-style-property
public enum CSSTextEmphasisFillMode: String, Equatable, Sendable, Hashable {
    /// The shape is filled with solid color.
    case filled
    /// The shape is hollow.
    case open
}

/// A text emphasis shape for the `text-emphasis-style` property.
/// https://www.w3.org/TR/css-text-decor-4/#text-emphasis-style-property
public enum CSSTextEmphasisShape: String, Equatable, Sendable, Hashable {
    /// Display small circles as marks.
    case dot
    /// Display large circles as marks.
    case circle
    /// Display double circles as marks.
    case doubleCircle = "double-circle"
    /// Display triangles as marks.
    case triangle
    /// Display sesames as marks.
    case sesame
}

/// A value for the `text-emphasis-style` property.
/// https://www.w3.org/TR/css-text-decor-4/#text-emphasis-style-property
public enum CSSTextEmphasisStyle: Equatable, Sendable, Hashable {
    /// No emphasis.
    case none
    /// Defines the fill and shape of the marks.
    case keyword(fill: CSSTextEmphasisFillMode, shape: CSSTextEmphasisShape?)
    /// Display the given string as marks.
    case string(CSSString)

    /// The default value.
    public static let `default`: CSSTextEmphasisStyle = .none
}

/// A value for the `text-emphasis` shorthand property.
/// https://www.w3.org/TR/css-text-decor-4/#text-emphasis-property
public struct CSSTextEmphasis: Equatable, Sendable, Hashable {
    /// The text emphasis style.
    public var style: CSSTextEmphasisStyle
    /// The text emphasis color.
    public var color: Color
    /// The vendor prefix.
    public var vendorPrefix: CSSVendorPrefix

    public init(
        style: CSSTextEmphasisStyle = .none,
        color: Color = .currentColor,
        vendorPrefix: CSSVendorPrefix = .none
    ) {
        self.style = style
        self.color = color
        self.vendorPrefix = vendorPrefix
    }

    /// The default value.
    public static let `default` = Self()
}

/// A vertical position keyword for the `text-emphasis-position` property.
/// https://www.w3.org/TR/css-text-decor-4/#text-emphasis-position-property
public enum CSSTextEmphasisPositionVertical: String, Equatable, Sendable, Hashable {
    /// Draw marks over the text in horizontal typographic modes.
    case over
    /// Draw marks under the text in horizontal typographic modes.
    case under
}

/// A horizontal position keyword for the `text-emphasis-position` property.
/// https://www.w3.org/TR/css-text-decor-4/#text-emphasis-position-property
public enum CSSTextEmphasisPositionHorizontal: String, Equatable, Sendable, Hashable {
    /// Draw marks to the right of the text in vertical typographic modes.
    case left
    /// Draw marks to the left of the text in vertical typographic modes.
    case right
}

/// A value for the `text-emphasis-position` property.
/// https://www.w3.org/TR/css-text-decor-4/#text-emphasis-position-property
public struct CSSTextEmphasisPosition: Equatable, Sendable, Hashable {
    /// The vertical position.
    public var vertical: CSSTextEmphasisPositionVertical
    /// The horizontal position.
    public var horizontal: CSSTextEmphasisPositionHorizontal

    public init(
        vertical: CSSTextEmphasisPositionVertical,
        horizontal: CSSTextEmphasisPositionHorizontal = .right
    ) {
        self.vertical = vertical
        self.horizontal = horizontal
    }
}

// MARK: - Text Shadow

/// A value for the `text-shadow` property.
/// https://www.w3.org/TR/css-text-decor-4/#text-shadow-property
public struct CSSTextShadow: Equatable, Sendable, Hashable {
    /// The color of the text shadow.
    public var color: Color
    /// The x offset of the text shadow.
    public var xOffset: CSSLength
    /// The y offset of the text shadow.
    public var yOffset: CSSLength
    /// The blur radius of the text shadow.
    public var blur: CSSLength
    /// The spread distance of the text shadow.
    public var spread: CSSLength

    public init(
        color: Color = .currentColor,
        xOffset: CSSLength,
        yOffset: CSSLength,
        blur: CSSLength = .zero,
        spread: CSSLength = .zero
    ) {
        self.color = color
        self.xOffset = xOffset
        self.yOffset = yOffset
        self.blur = blur
        self.spread = spread
    }
}

// MARK: - Box Decoration Break

/// A value for the `box-decoration-break` property.
/// https://www.w3.org/TR/css-break-3/#break-decoration
public enum CSSBoxDecorationBreak: String, Equatable, Sendable, Hashable {
    /// The element is rendered with no breaks present, and then sliced by the breaks afterward.
    case slice
    /// Each box fragment is independently wrapped with the border, padding, and margin.
    case clone

    /// The default value.
    public static let `default`: CSSBoxDecorationBreak = .slice
}

// MARK: - Direction & Bidi

/// A value for the `direction` property.
/// https://drafts.csswg.org/css-writing-modes-3/#direction
public enum CSSDirection: String, Equatable, Sendable, Hashable {
    /// This value sets inline base direction (bidi directionality) to line-left-to-line-right.
    case ltr
    /// This value sets inline base direction (bidi directionality) to line-right-to-line-left.
    case rtl
}

/// A value for the `unicode-bidi` property.
/// https://drafts.csswg.org/css-writing-modes-3/#unicode-bidi
public enum CSSUnicodeBidi: String, Equatable, Sendable, Hashable {
    /// The box does not open an additional level of embedding.
    case normal
    /// If the box is inline, this value creates a directional embedding by opening an additional level of embedding.
    case embed
    /// On an inline box, this bidi-isolates its contents.
    case isolate
    /// This value puts the box's immediate inline content in a directional override.
    case bidiOverride = "bidi-override"
    /// This combines the isolation behavior of isolate with the directional override behavior of bidi-override.
    case isolateOverride = "isolate-override"
    /// This value behaves as isolate except that the base directionality is determined using a heuristic rather than the direction property.
    case plaintext
}

// MARK: - Parsing

extension CSSTextTransformCase {
    static func parse(_ input: Parser) -> Result<CSSTextTransformCase, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "none": return .success(.none)
        case "uppercase": return .success(.uppercase)
        case "lowercase": return .success(.lowercase)
        case "capitalize": return .success(.capitalize)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSTextTransformOther {
    static func parse(_ input: Parser) -> Result<CSSTextTransformOther, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "full-width": return .success(.fullWidth)
        case "full-size-kana": return .success(.fullSizeKana)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSTextTransform {
    static func parse(_ input: Parser) -> Result<CSSTextTransform, BasicParseError> {
        var textCase: CSSTextTransformCase?
        var other: CSSTextTransformOther = []

        while true {
            if textCase == nil {
                if case let .success(c) = input.tryParse({ CSSTextTransformCase.parse($0) }) {
                    textCase = c
                    if c == .none {
                        other = []
                        break
                    }
                    continue
                }
            }

            if case let .success(o) = input.tryParse({ CSSTextTransformOther.parse($0) }) {
                other.insert(o)
                continue
            }

            break
        }

        return .success(CSSTextTransform(case: textCase ?? .none, other: other))
    }
}

extension CSSWhiteSpace {
    static func parse(_ input: Parser) -> Result<CSSWhiteSpace, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "normal": return .success(.normal)
        case "pre": return .success(.pre)
        case "nowrap": return .success(.nowrap)
        case "pre-wrap": return .success(.preWrap)
        case "break-spaces": return .success(.breakSpaces)
        case "pre-line": return .success(.preLine)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSWordBreak {
    static func parse(_ input: Parser) -> Result<CSSWordBreak, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "normal": return .success(.normal)
        case "keep-all": return .success(.keepAll)
        case "break-all": return .success(.breakAll)
        case "break-word": return .success(.breakWord)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSLineBreak {
    static func parse(_ input: Parser) -> Result<CSSLineBreak, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "auto": return .success(.auto)
        case "loose": return .success(.loose)
        case "normal": return .success(.normal)
        case "strict": return .success(.strict)
        case "anywhere": return .success(.anywhere)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSHyphens {
    static func parse(_ input: Parser) -> Result<CSSHyphens, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "none": return .success(.none)
        case "manual": return .success(.manual)
        case "auto": return .success(.auto)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSOverflowWrap {
    static func parse(_ input: Parser) -> Result<CSSOverflowWrap, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "normal": return .success(.normal)
        case "anywhere": return .success(.anywhere)
        case "break-word": return .success(.breakWord)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSTextAlign {
    static func parse(_ input: Parser) -> Result<CSSTextAlign, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "start": return .success(.start)
        case "end": return .success(.end)
        case "left": return .success(.left)
        case "right": return .success(.right)
        case "center": return .success(.center)
        case "justify": return .success(.justify)
        case "match-parent": return .success(.matchParent)
        case "justify-all": return .success(.justifyAll)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSTextAlignLast {
    static func parse(_ input: Parser) -> Result<CSSTextAlignLast, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "auto": return .success(.auto)
        case "start": return .success(.start)
        case "end": return .success(.end)
        case "left": return .success(.left)
        case "right": return .success(.right)
        case "center": return .success(.center)
        case "justify": return .success(.justify)
        case "match-parent": return .success(.matchParent)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSTextJustify {
    static func parse(_ input: Parser) -> Result<CSSTextJustify, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "auto": return .success(.auto)
        case "none": return .success(.none)
        case "inter-word": return .success(.interWord)
        case "inter-character": return .success(.interCharacter)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSSpacing {
    static func parse(_ input: Parser) -> Result<CSSSpacing, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("normal") }).isOK {
            return .success(.normal)
        }
        switch CSSLength.parse(input) {
        case let .success(length):
            return .success(.length(length))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSTextIndent {
    static func parse(_ input: Parser) -> Result<CSSTextIndent, BasicParseError> {
        var value: CSSLengthPercentage?
        var hanging = false
        var eachLine = false

        while true {
            if value == nil {
                if case let .success(val) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
                    value = val
                    continue
                }
            }

            if !hanging {
                if input.tryParse({ $0.expectIdentMatching("hanging") }).isOK {
                    hanging = true
                    continue
                }
            }

            if !eachLine {
                if input.tryParse({ $0.expectIdentMatching("each-line") }).isOK {
                    eachLine = true
                    continue
                }
            }

            break
        }

        guard let value else {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(CSSTextIndent(value: value, hanging: hanging, eachLine: eachLine))
    }
}

extension CSSTextSizeAdjust {
    static func parse(_ input: Parser) -> Result<CSSTextSizeAdjust, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("auto") }).isOK {
            return .success(.auto)
        }
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }
        switch CSSPercentage.parse(input) {
        case let .success(percentage):
            return .success(.percentage(percentage))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSTextDecorationLine {
    static func parse(_ input: Parser) -> Result<CSSTextDecorationLine, BasicParseError> {
        var value: CSSTextDecorationLine = []
        var any = false

        while true {
            let result: Result<CSSTextDecorationLine, BasicParseError> = input.tryParse { input in
                let location = input.currentSourceLocation()
                guard case let .success(ident) = input.expectIdent() else {
                    return .failure(input.newBasicError(.endOfInput))
                }
                switch ident.lowercased() {
                case "none" where value.isEmpty:
                    return .success([])
                case "underline":
                    return .success(.underline)
                case "overline":
                    return .success(.overline)
                case "line-through":
                    return .success(.lineThrough)
                case "blink":
                    return .success(.blink)
                case "spelling-error" where value.isEmpty:
                    return .success(.spellingError)
                case "grammar-error" where value.isEmpty:
                    return .success(.grammarError)
                default:
                    return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
                }
            }

            if case let .success(flag) = result {
                value.insert(flag)
                any = true
            } else {
                break
            }
        }

        if !any {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(value)
    }
}

extension CSSTextDecorationStyle {
    static func parse(_ input: Parser) -> Result<CSSTextDecorationStyle, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "solid": return .success(.solid)
        case "double": return .success(.double)
        case "dotted": return .success(.dotted)
        case "dashed": return .success(.dashed)
        case "wavy": return .success(.wavy)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSTextDecorationThickness {
    static func parse(_ input: Parser) -> Result<CSSTextDecorationThickness, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("auto") }).isOK {
            return .success(.auto)
        }
        if input.tryParse({ $0.expectIdentMatching("from-font") }).isOK {
            return .success(.fromFont)
        }
        switch CSSLengthPercentage.parse(input) {
        case let .success(lp):
            return .success(.lengthPercentage(lp))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSTextDecoration {
    static func parse(_ input: Parser, vendorPrefix: CSSVendorPrefix = .none) -> Result<CSSTextDecoration, BasicParseError> {
        var line: CSSTextDecorationLine?
        var thickness: CSSTextDecorationThickness?
        var style: CSSTextDecorationStyle?
        var color: Color?

        while true {
            if line == nil {
                if case let .success(val) = input.tryParse({ CSSTextDecorationLine.parse($0) }) {
                    line = val
                    continue
                }
            }

            if thickness == nil {
                if case let .success(val) = input.tryParse({ CSSTextDecorationThickness.parse($0) }) {
                    thickness = val
                    continue
                }
            }

            if style == nil {
                if case let .success(val) = input.tryParse({ CSSTextDecorationStyle.parse($0) }) {
                    style = val
                    continue
                }
            }

            if color == nil {
                if case let .success(val) = input.tryParse({ Color.parse($0) }) {
                    color = val
                    continue
                }
            }

            break
        }

        return .success(CSSTextDecoration(
            line: line ?? [],
            thickness: thickness ?? .auto,
            style: style ?? .solid,
            color: color ?? .currentColor,
            vendorPrefix: vendorPrefix
        ))
    }
}

extension CSSTextDecorationSkipInk {
    static func parse(_ input: Parser) -> Result<CSSTextDecorationSkipInk, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "auto": return .success(.auto)
        case "none": return .success(.none)
        case "all": return .success(.all)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSTextEmphasisFillMode {
    static func parse(_ input: Parser) -> Result<CSSTextEmphasisFillMode, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "filled": return .success(.filled)
        case "open": return .success(.open)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSTextEmphasisShape {
    static func parse(_ input: Parser) -> Result<CSSTextEmphasisShape, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "dot": return .success(.dot)
        case "circle": return .success(.circle)
        case "double-circle": return .success(.doubleCircle)
        case "triangle": return .success(.triangle)
        case "sesame": return .success(.sesame)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSTextEmphasisStyle {
    static func parse(_ input: Parser) -> Result<CSSTextEmphasisStyle, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        if case let .success(s) = input.tryParse({ CSSString.parse($0) }) {
            return .success(.string(s))
        }

        var shape = input.tryParse { CSSTextEmphasisShape.parse($0) }
        let fill = input.tryParse { CSSTextEmphasisFillMode.parse($0) }
        if case .failure = shape {
            shape = input.tryParse { CSSTextEmphasisShape.parse($0) }
        }

        if case .failure = shape, case .failure = fill {
            return .failure(input.newBasicError(.endOfInput))
        }

        let fillValue: CSSTextEmphasisFillMode = if case let .success(f) = fill {
            f
        } else {
            .filled
        }

        let shapeValue: CSSTextEmphasisShape? = if case let .success(s) = shape {
            s
        } else {
            nil
        }

        return .success(.keyword(fill: fillValue, shape: shapeValue))
    }
}

extension CSSTextEmphasis {
    static func parse(_ input: Parser, vendorPrefix: CSSVendorPrefix = .none) -> Result<CSSTextEmphasis, BasicParseError> {
        var style: CSSTextEmphasisStyle?
        var color: Color?

        while true {
            if style == nil {
                if case let .success(s) = input.tryParse({ CSSTextEmphasisStyle.parse($0) }) {
                    style = s
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

        return .success(CSSTextEmphasis(
            style: style ?? .none,
            color: color ?? .currentColor,
            vendorPrefix: vendorPrefix
        ))
    }
}

extension CSSTextEmphasisPositionVertical {
    static func parse(_ input: Parser) -> Result<CSSTextEmphasisPositionVertical, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "over": return .success(.over)
        case "under": return .success(.under)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSTextEmphasisPositionHorizontal {
    static func parse(_ input: Parser) -> Result<CSSTextEmphasisPositionHorizontal, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "left": return .success(.left)
        case "right": return .success(.right)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSTextEmphasisPosition {
    static func parse(_ input: Parser) -> Result<CSSTextEmphasisPosition, BasicParseError> {
        if case let .success(horizontal) = input.tryParse({ CSSTextEmphasisPositionHorizontal.parse($0) }) {
            switch CSSTextEmphasisPositionVertical.parse(input) {
            case let .success(vertical):
                return .success(CSSTextEmphasisPosition(vertical: vertical, horizontal: horizontal))
            case let .failure(error):
                return .failure(error)
            }
        } else {
            switch CSSTextEmphasisPositionVertical.parse(input) {
            case let .success(vertical):
                let horizontal: CSSTextEmphasisPositionHorizontal = if case let .success(h) = input.tryParse({ CSSTextEmphasisPositionHorizontal.parse($0) }) {
                    h
                } else {
                    .right
                }
                return .success(CSSTextEmphasisPosition(vertical: vertical, horizontal: horizontal))
            case let .failure(error):
                return .failure(error)
            }
        }
    }
}

extension CSSTextShadow {
    static func parse(_ input: Parser) -> Result<CSSTextShadow, BasicParseError> {
        var color: Color?
        var lengths: (CSSLength, CSSLength, CSSLength, CSSLength)?

        while true {
            if lengths == nil {
                let value = input.tryParse { input -> Result<(CSSLength, CSSLength, CSSLength, CSSLength), BasicParseError> in
                    guard case let .success(horizontal) = CSSLength.parse(input) else {
                        return .failure(input.newBasicError(.endOfInput))
                    }
                    guard case let .success(vertical) = CSSLength.parse(input) else {
                        return .failure(input.newBasicError(.endOfInput))
                    }
                    let blur: CSSLength = if case let .success(b) = input.tryParse({ CSSLength.parse($0) }) {
                        b
                    } else {
                        .zero
                    }
                    let spread: CSSLength = if case let .success(s) = input.tryParse({ CSSLength.parse($0) }) {
                        s
                    } else {
                        .zero
                    }
                    return .success((horizontal, vertical, blur, spread))
                }

                if case let .success(value) = value {
                    lengths = value
                    continue
                }
            }

            if color == nil {
                if case let .success(value) = input.tryParse({ Color.parse($0) }) {
                    color = value
                    continue
                }
            }

            break
        }

        guard let lengths else {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(CSSTextShadow(
            color: color ?? .currentColor,
            xOffset: lengths.0,
            yOffset: lengths.1,
            blur: lengths.2,
            spread: lengths.3
        ))
    }
}

extension CSSBoxDecorationBreak {
    static func parse(_ input: Parser) -> Result<CSSBoxDecorationBreak, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "slice": return .success(.slice)
        case "clone": return .success(.clone)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSDirection {
    static func parse(_ input: Parser) -> Result<CSSDirection, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "ltr": return .success(.ltr)
        case "rtl": return .success(.rtl)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSUnicodeBidi {
    static func parse(_ input: Parser) -> Result<CSSUnicodeBidi, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "normal": return .success(.normal)
        case "embed": return .success(.embed)
        case "isolate": return .success(.isolate)
        case "bidi-override": return .success(.bidiOverride)
        case "isolate-override": return .success(.isolateOverride)
        case "plaintext": return .success(.plaintext)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

// MARK: - ToCss

extension CSSTextTransformCase: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSTextTransformOther: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        var needsSpace = false
        if contains(.fullWidth) {
            dest.write("full-width")
            needsSpace = true
        }
        if contains(.fullSizeKana) {
            if needsSpace {
                dest.write(" ")
            }
            dest.write("full-size-kana")
        }
    }
}

extension CSSTextTransform: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        var needsSpace = false
        if `case` != .none || other.isEmpty {
            `case`.serialize(dest: &dest)
            needsSpace = true
        }

        if !other.isEmpty {
            if needsSpace {
                dest.write(" ")
            }
            other.serialize(dest: &dest)
        }
    }
}

extension CSSWhiteSpace: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSWordBreak: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSLineBreak: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSHyphens: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSOverflowWrap: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSTextAlign: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSTextAlignLast: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSTextJustify: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSSpacing: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .normal:
            dest.write("normal")
        case let .length(length):
            length.serialize(dest: &dest)
        }
    }
}

extension CSSTextIndent: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        value.serialize(dest: &dest)
        if hanging {
            dest.write(" hanging")
        }
        if eachLine {
            dest.write(" each-line")
        }
    }
}

extension CSSTextSizeAdjust: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .auto:
            dest.write("auto")
        case .none:
            dest.write("none")
        case let .percentage(p):
            p.serialize(dest: &dest)
        }
    }
}

extension CSSTextDecorationLine: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if isEmpty {
            dest.write("none")
            return
        }

        if contains(.spellingError) {
            dest.write("spelling-error")
            return
        }

        if contains(.grammarError) {
            dest.write("grammar-error")
            return
        }

        var needsSpace = false
        if contains(.underline) {
            dest.write("underline")
            needsSpace = true
        }
        if contains(.overline) {
            if needsSpace { dest.write(" ") }
            dest.write("overline")
            needsSpace = true
        }
        if contains(.lineThrough) {
            if needsSpace { dest.write(" ") }
            dest.write("line-through")
            needsSpace = true
        }
        if contains(.blink) {
            if needsSpace { dest.write(" ") }
            dest.write("blink")
        }
    }
}

extension CSSTextDecorationStyle: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSTextDecorationThickness: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .auto:
            dest.write("auto")
        case .fromFont:
            dest.write("from-font")
        case let .lengthPercentage(lp):
            lp.serialize(dest: &dest)
        }
    }
}

extension CSSTextDecoration: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        line.serialize(dest: &dest)
        if line.isEmpty {
            return
        }

        var needsSpace = true
        if thickness != .default {
            dest.write(" ")
            thickness.serialize(dest: &dest)
            needsSpace = true
        }

        if style != .default {
            if needsSpace {
                dest.write(" ")
            }
            style.serialize(dest: &dest)
            needsSpace = true
        }

        if color != .currentColor {
            if needsSpace {
                dest.write(" ")
            }
            color.serialize(dest: &dest)
        }
    }
}

extension CSSTextDecorationSkipInk: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSTextEmphasisFillMode: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSTextEmphasisShape: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSTextEmphasisStyle: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case let .string(s):
            s.serialize(dest: &dest)
        case let .keyword(fill, shape):
            var needsSpace = false
            if fill != .filled || shape == nil {
                fill.serialize(dest: &dest)
                needsSpace = true
            }

            if let shape {
                if needsSpace {
                    dest.write(" ")
                }
                shape.serialize(dest: &dest)
            }
        }
    }
}

extension CSSTextEmphasis: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        style.serialize(dest: &dest)

        if style != .none, color != .currentColor {
            dest.write(" ")
            color.serialize(dest: &dest)
        }
    }
}

extension CSSTextEmphasisPositionVertical: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSTextEmphasisPositionHorizontal: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSTextEmphasisPosition: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        vertical.serialize(dest: &dest)
        if horizontal != .right {
            dest.write(" ")
            horizontal.serialize(dest: &dest)
        }
    }
}

extension CSSTextShadow: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        xOffset.serialize(dest: &dest)
        dest.write(" ")
        yOffset.serialize(dest: &dest)

        if !blur.isZero || !spread.isZero {
            dest.write(" ")
            blur.serialize(dest: &dest)

            if !spread.isZero {
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

extension CSSBoxDecorationBreak: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSDirection: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSUnicodeBidi: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}
