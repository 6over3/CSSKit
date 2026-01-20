// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Font Weight

/// An absolute font weight value.
/// https://www.w3.org/TR/css-fonts-4/#font-weight-absolute-values
public enum CSSAbsoluteFontWeight: Equatable, Sendable, Hashable {
    /// An explicit numeric weight (1-1000).
    case weight(Double)
    /// Same as `400`.
    case normal
    /// Same as `700`.
    case bold

    /// The default value (normal).
    public static var `default`: Self { .normal }

    /// Returns the numeric value.
    public var numericValue: Double {
        switch self {
        case let .weight(w): w
        case .normal: 400
        case .bold: 700
        }
    }
}

/// A value for the `font-weight` property.
/// https://www.w3.org/TR/css-fonts-4/#font-weight-prop
public enum CSSFontWeight: Equatable, Sendable, Hashable {
    /// An absolute font weight.
    case absolute(CSSAbsoluteFontWeight)
    /// The `bolder` keyword.
    case bolder
    /// The `lighter` keyword.
    case lighter

    /// The default value (normal).
    public static var `default`: Self { .absolute(.normal) }
}

// MARK: - Font Size

/// An absolute font size keyword.
/// https://www.w3.org/TR/css-fonts-3/#absolute-size-value
public enum CSSAbsoluteFontSize: String, Equatable, Sendable, Hashable, CaseIterable {
    case xxSmall = "xx-small"
    case xSmall = "x-small"
    case small
    case medium
    case large
    case xLarge = "x-large"
    case xxLarge = "xx-large"
    case xxxLarge = "xxx-large"

    /// The default value (medium).
    public static var `default`: Self { .medium }
}

/// A relative font size keyword.
/// https://www.w3.org/TR/css-fonts-3/#relative-size-value
public enum CSSRelativeFontSize: String, Equatable, Sendable, Hashable, CaseIterable {
    case smaller
    case larger
}

/// A value for the `font-size` property.
/// https://www.w3.org/TR/css-fonts-4/#font-size-prop
public enum CSSFontSize: Equatable, Sendable, Hashable {
    /// An explicit length or percentage.
    case lengthPercentage(CSSLengthPercentage)
    /// An absolute font size keyword.
    case absolute(CSSAbsoluteFontSize)
    /// A relative font size keyword.
    case relative(CSSRelativeFontSize)

    /// The default value (medium).
    public static var `default`: Self { .absolute(.medium) }
}

// MARK: - Font Stretch

/// A font stretch keyword.
/// https://www.w3.org/TR/css-fonts-4/#font-stretch-prop
public enum CSSFontStretchKeyword: String, Equatable, Sendable, Hashable, CaseIterable {
    /// 100%
    case normal
    /// 50%
    case ultraCondensed = "ultra-condensed"
    /// 62.5%
    case extraCondensed = "extra-condensed"
    /// 75%
    case condensed
    /// 87.5%
    case semiCondensed = "semi-condensed"
    /// 112.5%
    case semiExpanded = "semi-expanded"
    /// 125%
    case expanded
    /// 150%
    case extraExpanded = "extra-expanded"
    /// 200%
    case ultraExpanded = "ultra-expanded"

    /// The default value (normal).
    public static var `default`: Self { .normal }

    /// Returns the percentage value.
    public var percentage: CSSPercentage {
        switch self {
        case .ultraCondensed: CSSPercentage(0.5)
        case .extraCondensed: CSSPercentage(0.625)
        case .condensed: CSSPercentage(0.75)
        case .semiCondensed: CSSPercentage(0.875)
        case .normal: CSSPercentage(1.0)
        case .semiExpanded: CSSPercentage(1.125)
        case .expanded: CSSPercentage(1.25)
        case .extraExpanded: CSSPercentage(1.5)
        case .ultraExpanded: CSSPercentage(2.0)
        }
    }
}

/// A value for the `font-stretch` property.
/// https://www.w3.org/TR/css-fonts-4/#font-stretch-prop
public enum CSSFontStretch: Equatable, Sendable, Hashable {
    /// A font stretch keyword.
    case keyword(CSSFontStretchKeyword)
    /// A percentage value.
    case percentage(CSSPercentage)

    /// The default value (normal).
    public static var `default`: Self { .keyword(.normal) }

    /// Returns the percentage value.
    public var percentage: CSSPercentage {
        switch self {
        case let .keyword(kw): kw.percentage
        case let .percentage(p): p
        }
    }
}

// MARK: - Font Family

/// A generic font family name.
/// https://www.w3.org/TR/css-fonts-4/#generic-font-families
public enum CSSGenericFontFamily: String, Equatable, Sendable, Hashable, CaseIterable {
    case serif
    case sansSerif = "sans-serif"
    case cursive
    case fantasy
    case monospace
    case systemUI = "system-ui"
    case emoji
    case math
    case fangsong
    case uiSerif = "ui-serif"
    case uiSansSerif = "ui-sans-serif"
    case uiMonospace = "ui-monospace"
    case uiRounded = "ui-rounded"

    // CSS wide keywords - must be parsed as identifiers
    case initial
    case inherit
    case unset
    case `default`
    case revert
    case revertLayer = "revert-layer"
}

/// A custom font family name.
public struct CSSFamilyName: Equatable, Sendable, Hashable {
    /// The font family name.
    public let name: String

    public init(_ name: String) {
        self.name = name
    }
}

/// A value for the `font-family` property.
/// https://www.w3.org/TR/css-fonts-4/#font-family-prop
public enum CSSFontFamily: Equatable, Sendable, Hashable {
    /// A generic family name.
    case generic(CSSGenericFontFamily)
    /// A custom family name.
    case familyName(CSSFamilyName)
}

// MARK: - Font Style

/// A value for the `font-style` property.
/// https://www.w3.org/TR/css-fonts-4/#font-style-prop
public enum CSSFontStyle: Equatable, Sendable, Hashable {
    /// Normal font style.
    case normal
    /// Italic font style.
    case italic
    /// Oblique font style with an optional angle.
    case oblique(CSSAngle)

    /// The default value (normal).
    public static var `default`: Self { .normal }

    /// The default oblique angle (14deg).
    public static var defaultObliqueAngle: CSSAngle { .deg(14.0) }
}

// MARK: - Font Variant Caps

/// A value for the `font-variant-caps` property.
/// https://www.w3.org/TR/css-fonts-4/#font-variant-caps-prop
public enum CSSFontVariantCaps: String, Equatable, Sendable, Hashable, CaseIterable {
    /// No special capitalization features.
    case normal
    /// Small capitals for lower case letters.
    case smallCaps = "small-caps"
    /// Small capitals for both upper and lower case letters.
    case allSmallCaps = "all-small-caps"
    /// Petite capitals.
    case petiteCaps = "petite-caps"
    /// Petite capitals for both upper and lower case letters.
    case allPetiteCaps = "all-petite-caps"
    /// Mixture of small capitals for uppercase letters with normal lowercase.
    case unicase
    /// Titling capitals.
    case titlingCaps = "titling-caps"

    /// The default value (normal).
    public static var `default`: Self { .normal }

    /// Whether this is a CSS 2.1 value (normal or small-caps).
    public var isCss2: Bool {
        self == .normal || self == .smallCaps
    }
}

// MARK: - Line Height

/// A value for the `line-height` property.
/// https://www.w3.org/TR/css-inline-3/#propdef-line-height
public enum CSSLineHeight: Equatable, Sendable, Hashable {
    /// The UA sets the line height based on the font.
    case normal
    /// A multiple of the element's font size.
    case number(Double)
    /// An explicit height.
    case lengthPercentage(CSSLengthPercentage)

    /// The default value (normal).
    public static var `default`: Self { .normal }
}

// MARK: - Vertical Align

/// A keyword for the `vertical-align` property.
/// https://drafts.csswg.org/css2/#propdef-vertical-align
public enum CSSVerticalAlignKeyword: String, Equatable, Sendable, Hashable, CaseIterable {
    /// Align the baseline of the box with the baseline of the parent box.
    case baseline
    /// Lower the baseline of the box to the proper position for subscripts.
    case sub
    /// Raise the baseline of the box to the proper position for superscripts.
    case `super`
    /// Align the top of the aligned subtree with the top of the line box.
    case top
    /// Align the top of the box with the top of the parent's content area.
    case textTop = "text-top"
    /// Align the vertical midpoint of the box with the baseline plus half the x-height.
    case middle
    /// Align the bottom of the aligned subtree with the bottom of the line box.
    case bottom
    /// Align the bottom of the box with the bottom of the parent's content area.
    case textBottom = "text-bottom"
}

/// A value for the `vertical-align` property.
/// https://drafts.csswg.org/css2/#propdef-vertical-align
public enum CSSVerticalAlign: Equatable, Sendable, Hashable {
    /// A vertical align keyword.
    case keyword(CSSVerticalAlignKeyword)
    /// An explicit length.
    case lengthPercentage(CSSLengthPercentage)
}

// MARK: - Font Shorthand

/// A value for the `font` shorthand property.
/// https://www.w3.org/TR/css-fonts-4/#font-prop
public struct CSSFont: Equatable, Sendable, Hashable {
    /// The font family.
    public var family: [CSSFontFamily]
    /// The font size.
    public var size: CSSFontSize
    /// The font style.
    public var style: CSSFontStyle
    /// The font weight.
    public var weight: CSSFontWeight
    /// The font stretch.
    public var stretch: CSSFontStretch
    /// The line height.
    public var lineHeight: CSSLineHeight
    /// How the text should be capitalized (CSS 2.1 values only in shorthand).
    public var variantCaps: CSSFontVariantCaps

    public init(
        family: [CSSFontFamily],
        size: CSSFontSize = .default,
        style: CSSFontStyle = .default,
        weight: CSSFontWeight = .default,
        stretch: CSSFontStretch = .default,
        lineHeight: CSSLineHeight = .default,
        variantCaps: CSSFontVariantCaps = .default
    ) {
        self.family = family
        self.size = size
        self.style = style
        self.weight = weight
        self.stretch = stretch
        self.lineHeight = lineHeight
        self.variantCaps = variantCaps
    }
}

// MARK: - Parsing

extension CSSAbsoluteFontWeight {
    static func parse(_ input: Parser) -> Result<CSSAbsoluteFontWeight, BasicParseError> {
        // Try keywords first
        if input.tryParse({ $0.expectIdentMatching("normal") }).isOK {
            return .success(.normal)
        }
        if input.tryParse({ $0.expectIdentMatching("bold") }).isOK {
            return .success(.bold)
        }

        // Try number
        let location = input.currentSourceLocation()
        switch input.next() {
        case let .success(token):
            if case let .number(num) = token {
                return .success(.weight(num.value))
            }
            return .failure(location.newBasicUnexpectedTokenError(token))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSFontWeight {
    static func parse(_ input: Parser) -> Result<CSSFontWeight, BasicParseError> {
        // Try relative keywords first
        if input.tryParse({ $0.expectIdentMatching("bolder") }).isOK {
            return .success(.bolder)
        }
        if input.tryParse({ $0.expectIdentMatching("lighter") }).isOK {
            return .success(.lighter)
        }

        // Try absolute
        switch CSSAbsoluteFontWeight.parse(input) {
        case let .success(absolute):
            return .success(.absolute(absolute))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSAbsoluteFontSize {
    static func parse(_ input: Parser) -> Result<CSSAbsoluteFontSize, BasicParseError> {
        if case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
            let lower = ident.lowercased()
            if let size = CSSAbsoluteFontSize.allCases.first(where: { $0.rawValue == lower }) {
                return .success(size)
            }
        }
        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSRelativeFontSize {
    static func parse(_ input: Parser) -> Result<CSSRelativeFontSize, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("smaller") }).isOK {
            return .success(.smaller)
        }
        if input.tryParse({ $0.expectIdentMatching("larger") }).isOK {
            return .success(.larger)
        }
        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSFontSize {
    static func parse(_ input: Parser) -> Result<CSSFontSize, BasicParseError> {
        // Try absolute keywords
        if case let .success(absolute) = input.tryParse({ CSSAbsoluteFontSize.parse($0) }) {
            return .success(.absolute(absolute))
        }

        // Try relative keywords
        if case let .success(relative) = input.tryParse({ CSSRelativeFontSize.parse($0) }) {
            return .success(.relative(relative))
        }

        // Try length-percentage
        switch CSSLengthPercentage.parse(input) {
        case let .success(lp):
            return .success(.lengthPercentage(lp))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSFontStretchKeyword {
    static func parse(_ input: Parser) -> Result<CSSFontStretchKeyword, BasicParseError> {
        if case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
            let lower = ident.lowercased()
            if let keyword = CSSFontStretchKeyword.allCases.first(where: { $0.rawValue == lower }) {
                return .success(keyword)
            }
        }
        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSFontStretch {
    static func parse(_ input: Parser) -> Result<CSSFontStretch, BasicParseError> {
        // Try keyword
        if case let .success(keyword) = input.tryParse({ CSSFontStretchKeyword.parse($0) }) {
            return .success(.keyword(keyword))
        }

        // Try percentage
        switch CSSPercentage.parse(input) {
        case let .success(pct):
            return .success(.percentage(pct))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSGenericFontFamily {
    static func parse(_ input: Parser) -> Result<CSSGenericFontFamily, BasicParseError> {
        if case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
            let lower = ident.lowercased()
            if let family = CSSGenericFontFamily.allCases.first(where: { $0.rawValue == lower }) {
                return .success(family)
            }
        }
        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSFamilyName {
    static func parse(_ input: Parser) -> Result<CSSFamilyName, BasicParseError> {
        // Try quoted string first
        if case let .success(token) = input.tryParse({ $0.next() }) {
            if case let .quotedString(s) = token {
                return .success(CSSFamilyName(s.value))
            }
        }

        // Parse as sequence of idents
        switch input.expectIdent() {
        case let .success(firstIdent):
            var name = firstIdent.value

            // Collect additional idents
            while case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
                name += " "
                name += ident.value
            }

            return .success(CSSFamilyName(name))

        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSFontFamily {
    static func parse(_ input: Parser) -> Result<CSSFontFamily, BasicParseError> {
        // Try generic first
        if case let .success(generic) = input.tryParse({ CSSGenericFontFamily.parse($0) }) {
            return .success(.generic(generic))
        }

        // Try family name
        switch CSSFamilyName.parse(input) {
        case let .success(name):
            return .success(.familyName(name))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSFontStyle {
    static func parse(_ input: Parser) -> Result<CSSFontStyle, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("normal") }).isOK {
            return .success(.normal)
        }
        if input.tryParse({ $0.expectIdentMatching("italic") }).isOK {
            return .success(.italic)
        }
        if input.tryParse({ $0.expectIdentMatching("oblique") }).isOK {
            // Try to parse angle, default to 14deg
            let angle: CSSAngle = if case let .success(a) = input.tryParse({ CSSAngle.parse($0) }) {
                a
            } else {
                CSSFontStyle.defaultObliqueAngle
            }
            return .success(.oblique(angle))
        }
        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSFontVariantCaps {
    static func parse(_ input: Parser) -> Result<CSSFontVariantCaps, BasicParseError> {
        if case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
            let lower = ident.lowercased()
            if let caps = CSSFontVariantCaps.allCases.first(where: { $0.rawValue == lower }) {
                return .success(caps)
            }
        }
        return .failure(input.newBasicError(.endOfInput))
    }

    /// Parse only CSS 2.1 values (normal, small-caps).
    static func parseCss2(_ input: Parser) -> Result<CSSFontVariantCaps, BasicParseError> {
        switch parse(input) {
        case let .success(caps) where caps.isCss2:
            .success(caps)
        case .success:
            .failure(input.newBasicError(.endOfInput))
        case let .failure(error):
            .failure(error)
        }
    }
}

extension CSSLineHeight {
    static func parse(_ input: Parser) -> Result<CSSLineHeight, BasicParseError> {
        // Try normal keyword
        if input.tryParse({ $0.expectIdentMatching("normal") }).isOK {
            return .success(.normal)
        }

        // Try number
        if case let .success(token) = input.tryParse({ $0.next() }) {
            if case let .number(num) = token {
                return .success(.number(num.value))
            }
        }

        // Try length-percentage
        switch CSSLengthPercentage.parse(input) {
        case let .success(lp):
            return .success(.lengthPercentage(lp))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSVerticalAlignKeyword {
    static func parse(_ input: Parser) -> Result<CSSVerticalAlignKeyword, BasicParseError> {
        if case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
            let lower = ident.lowercased()
            if let keyword = CSSVerticalAlignKeyword.allCases.first(where: { $0.rawValue == lower }) {
                return .success(keyword)
            }
        }
        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSVerticalAlign {
    static func parse(_ input: Parser) -> Result<CSSVerticalAlign, BasicParseError> {
        // Try keyword
        if case let .success(keyword) = input.tryParse({ CSSVerticalAlignKeyword.parse($0) }) {
            return .success(.keyword(keyword))
        }

        // Try length-percentage
        switch CSSLengthPercentage.parse(input) {
        case let .success(lp):
            return .success(.lengthPercentage(lp))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSFont {
    static func parse(_ input: Parser) -> Result<CSSFont, BasicParseError> {
        var style: CSSFontStyle?
        var weight: CSSFontWeight?
        var stretch: CSSFontStretch?
        var variantCaps: CSSFontVariantCaps?
        var count = 0

        // Parse optional properties before size
        while true {
            // Skip "normal" since it's valid for several properties
            if input.tryParse({ $0.expectIdentMatching("normal") }).isOK {
                count += 1
                continue
            }

            if style == nil {
                if case let .success(s) = input.tryParse({ CSSFontStyle.parse($0) }) {
                    style = s
                    count += 1
                    continue
                }
            }

            if weight == nil {
                if case let .success(w) = input.tryParse({ CSSFontWeight.parse($0) }) {
                    weight = w
                    count += 1
                    continue
                }
            }

            if variantCaps == nil {
                if case let .success(v) = input.tryParse({ CSSFontVariantCaps.parseCss2($0) }) {
                    variantCaps = v
                    count += 1
                    continue
                }
            }

            if stretch == nil {
                if case let .success(kw) = input.tryParse({ CSSFontStretchKeyword.parse($0) }) {
                    stretch = .keyword(kw)
                    count += 1
                    continue
                }
            }

            break
        }

        // Too many values before size
        if count > 4 {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Parse required size
        guard case let .success(size) = CSSFontSize.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Parse optional line-height after /
        var lineHeight: CSSLineHeight = .default
        if input.tryParse({ $0.expectDelim("/") }).isOK {
            guard case let .success(lh) = CSSLineHeight.parse(input) else {
                return .failure(input.newBasicError(.endOfInput))
            }
            lineHeight = lh
        }

        // Parse required comma-separated font-family list
        var families: [CSSFontFamily] = []
        guard case let .success(first) = CSSFontFamily.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }
        families.append(first)

        while input.tryParse({ $0.expectComma() }).isOK {
            guard case let .success(family) = CSSFontFamily.parse(input) else {
                return .failure(input.newBasicError(.endOfInput))
            }
            families.append(family)
        }

        return .success(CSSFont(
            family: families,
            size: size,
            style: style ?? .default,
            weight: weight ?? .default,
            stretch: stretch ?? .default,
            lineHeight: lineHeight,
            variantCaps: variantCaps ?? .default
        ))
    }
}

// MARK: - ToCss

extension CSSAbsoluteFontWeight: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .weight(val):
            val.serialize(dest: &dest)
        case .normal:
            dest.write("normal")
        case .bold:
            dest.write("bold")
        }
    }
}

extension CSSFontWeight: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .absolute(abs):
            abs.serialize(dest: &dest)
        case .bolder:
            dest.write("bolder")
        case .lighter:
            dest.write("lighter")
        }
    }
}

extension CSSAbsoluteFontSize: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSRelativeFontSize: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSFontSize: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .lengthPercentage(lp):
            lp.serialize(dest: &dest)
        case let .absolute(abs):
            abs.serialize(dest: &dest)
        case let .relative(rel):
            rel.serialize(dest: &dest)
        }
    }
}

extension CSSFontStretchKeyword: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSFontStretch: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .keyword(kw):
            kw.serialize(dest: &dest)
        case let .percentage(pct):
            pct.serialize(dest: &dest)
        }
    }
}

extension CSSGenericFontFamily: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSFamilyName: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        // Check if name needs quoting
        let lower = name.lowercased()

        // Generic family names and CSS wide keywords must be quoted
        let needsQuotes = CSSGenericFontFamily.allCases.contains { $0.rawValue == lower }
            || name.contains("  ") // Multiple consecutive spaces

        if needsQuotes || name.isEmpty {
            serializeString(name, dest: &dest)
        } else {
            // Try to serialize as idents
            let parts = name.split(separator: " ")
            var first = true
            for part in parts {
                if first {
                    first = false
                } else {
                    dest.write(" ")
                }
                serializeIdentifier(String(part), dest: &dest)
            }
        }
    }
}

extension CSSFontFamily: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .generic(gen):
            gen.serialize(dest: &dest)
        case let .familyName(name):
            name.serialize(dest: &dest)
        }
    }
}

extension CSSFontStyle: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .normal:
            dest.write("normal")
        case .italic:
            dest.write("italic")
        case let .oblique(angle):
            dest.write("oblique")
            if angle != CSSFontStyle.defaultObliqueAngle {
                dest.write(" ")
                angle.serialize(dest: &dest)
            }
        }
    }
}

extension CSSFontVariantCaps: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSLineHeight: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .normal:
            dest.write("normal")
        case let .number(n):
            n.serialize(dest: &dest)
        case let .lengthPercentage(lp):
            lp.serialize(dest: &dest)
        }
    }
}

extension CSSVerticalAlignKeyword: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSVerticalAlign: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .keyword(kw):
            kw.serialize(dest: &dest)
        case let .lengthPercentage(lp):
            lp.serialize(dest: &dest)
        }
    }
}

extension CSSFont: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        // Output non-default style
        if style != .default {
            style.serialize(dest: &dest)
            dest.write(" ")
        }

        // Output non-default variant-caps
        if variantCaps != .default, variantCaps.isCss2 {
            variantCaps.serialize(dest: &dest)
            dest.write(" ")
        }

        // Output non-default weight
        if weight != .default {
            weight.serialize(dest: &dest)
            dest.write(" ")
        }

        // Output non-default stretch
        if stretch != .default {
            stretch.serialize(dest: &dest)
            dest.write(" ")
        }

        // Output required size
        size.serialize(dest: &dest)

        // Output line-height if not default
        if lineHeight != .default {
            dest.write("/")
            lineHeight.serialize(dest: &dest)
        }

        // Output required font-family
        dest.write(" ")
        var first = true
        for fam in family {
            if first {
                first = false
            } else {
                dest.write(", ")
            }
            fam.serialize(dest: &dest)
        }
    }
}
