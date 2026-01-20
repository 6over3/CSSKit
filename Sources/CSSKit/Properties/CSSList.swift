// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - List Style Type

/// A value for the `list-style-type` property.
/// https://www.w3.org/TR/2020/WD-css-lists-3-20201117/#text-markers
public enum CSSListStyleType: Equatable, Sendable, Hashable {
    /// No marker.
    case none
    /// An explicit marker string.
    case string(CSSString)
    /// A named counter style.
    case counterStyle(CSSCounterStyle)

    /// The default value (disc).
    public static var `default`: Self {
        .counterStyle(.predefined(.disc))
    }
}

// MARK: - Counter Style

/// A counter-style name.
/// https://www.w3.org/TR/css-counter-styles-3/#typedef-counter-style
public enum CSSCounterStyle: Equatable, Sendable, Hashable {
    /// A predefined counter style name.
    case predefined(CSSPredefinedCounterStyle)
    /// A custom counter style name.
    case name(CSSCustomIdent)
    /// An inline symbols() definition.
    case symbols(system: CSSSymbolsType, symbols: [CSSSymbol])
}

// MARK: - Predefined Counter Style

/// A predefined counter style.
/// https://www.w3.org/TR/css-counter-styles-3/#predefined-counters
public enum CSSPredefinedCounterStyle: String, Equatable, Sendable, Hashable, CaseIterable {
    // https://www.w3.org/TR/css-counter-styles-3/#simple-numeric
    case decimal
    case decimalLeadingZero = "decimal-leading-zero"
    case arabicIndic = "arabic-indic"
    case armenian
    case upperArmenian = "upper-armenian"
    case lowerArmenian = "lower-armenian"
    case bengali
    case cambodian
    case khmer
    case cjkDecimal = "cjk-decimal"
    case devanagari
    case georgian
    case gujarati
    case gurmukhi
    case hebrew
    case kannada
    case lao
    case malayalam
    case mongolian
    case myanmar
    case oriya
    case persian
    case lowerRoman = "lower-roman"
    case upperRoman = "upper-roman"
    case tamil
    case telugu
    case thai
    case tibetan

    // https://www.w3.org/TR/css-counter-styles-3/#simple-alphabetic
    case lowerAlpha = "lower-alpha"
    case lowerLatin = "lower-latin"
    case upperAlpha = "upper-alpha"
    case upperLatin = "upper-latin"
    case lowerGreek = "lower-greek"
    case hiragana
    case hiraganaIroha = "hiragana-iroha"
    case katakana
    case katakanaIroha = "katakana-iroha"

    // https://www.w3.org/TR/css-counter-styles-3/#simple-symbolic
    case disc
    case circle
    case square
    case disclosureOpen = "disclosure-open"
    case disclosureClosed = "disclosure-closed"

    // https://www.w3.org/TR/css-counter-styles-3/#simple-fixed
    case cjkEarthlyBranch = "cjk-earthly-branch"
    case cjkHeavenlyStem = "cjk-heavenly-stem"

    // https://www.w3.org/TR/css-counter-styles-3/#complex-cjk
    case japaneseInformal = "japanese-informal"
    case japaneseFormal = "japanese-formal"
    case koreanHangulFormal = "korean-hangul-formal"
    case koreanHanjaInformal = "korean-hanja-informal"
    case koreanHanjaFormal = "korean-hanja-formal"
    case simpChineseInformal = "simp-chinese-informal"
    case simpChineseFormal = "simp-chinese-formal"
    case tradChineseInformal = "trad-chinese-informal"
    case tradChineseFormal = "trad-chinese-formal"
    case ethiopicNumeric = "ethiopic-numeric"
}

// MARK: - Symbols Type

/// A symbols-type value for the symbols() function.
/// https://www.w3.org/TR/css-counter-styles-3/#typedef-symbols-type
public enum CSSSymbolsType: String, Equatable, Sendable, Hashable, CaseIterable {
    case cyclic
    case numeric
    case alphabetic
    case symbolic
    case fixed

    /// The default value (symbolic).
    public static var `default`: Self { .symbolic }
}

// MARK: - Symbol

/// A single symbol for the symbols() function.
/// https://www.w3.org/TR/css-counter-styles-3/#funcdef-symbols
public enum CSSSymbol: Equatable, Sendable, Hashable {
    /// A string.
    case string(CSSString)
    /// An image.
    case image(CSSImage)
}

// MARK: - List Style Position

/// A value for the `list-style-position` property.
/// https://www.w3.org/TR/2020/WD-css-lists-3-20201117/#list-style-position-property
public enum CSSListStylePosition: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The list marker is placed inside the element.
    case inside
    /// The list marker is placed outside the element.
    case outside

    /// The default value (outside).
    public static var `default`: Self { .outside }
}

// MARK: - Marker Side

/// A value for the `marker-side` property.
/// https://www.w3.org/TR/2020/WD-css-lists-3-20201117/#marker-side
public enum CSSMarkerSide: String, Equatable, Sendable, Hashable, CaseIterable {
    case matchSelf = "match-self"
    case matchParent = "match-parent"
}

// MARK: - List Style

/// A value for the `list-style` shorthand property.
/// https://www.w3.org/TR/2020/WD-css-lists-3-20201117/#list-style-property
public struct CSSListStyle: Equatable, Sendable, Hashable {
    /// The position of the list marker.
    public var position: CSSListStylePosition
    /// The list marker image.
    public var image: CSSImage
    /// The list style type.
    public var listStyleType: CSSListStyleType

    public init(
        position: CSSListStylePosition = .outside,
        image: CSSImage = .none,
        listStyleType: CSSListStyleType = .counterStyle(.predefined(.disc))
    ) {
        self.position = position
        self.image = image
        self.listStyleType = listStyleType
    }

    /// The default list style value.
    public static var `default`: Self {
        Self(
            position: .outside,
            image: .none,
            listStyleType: .counterStyle(.predefined(.disc))
        )
    }
}

// MARK: - Parsing

extension CSSListStyleType {
    static func parse(_ input: Parser) -> Result<CSSListStyleType, BasicParseError> {
        // Try none keyword
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        // Try string
        if case let .success(str) = input.tryParse({ CSSString.parse($0) }) {
            return .success(.string(str))
        }

        // Try counter style
        if case let .success(counterStyle) = CSSCounterStyle.parse(input) {
            return .success(.counterStyle(counterStyle))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSCounterStyle {
    static func parse(_ input: Parser) -> Result<CSSCounterStyle, BasicParseError> {
        // Try predefined counter style
        if case let .success(predefined) = input.tryParse({ CSSPredefinedCounterStyle.parse($0) }) {
            return .success(.predefined(predefined))
        }

        // Try symbols() function
        if input.tryParse({ $0.expectFunctionMatching("symbols") }).isOK {
            let result: Result<CSSCounterStyle, ParseError<Never>> = input.parseNestedBlock { args in
                // Parse optional symbols type, default to symbolic
                var symbolsType: CSSSymbolsType = .symbolic
                if case let .success(st) = args.tryParse({ CSSSymbolsType.parse($0) }) {
                    symbolsType = st
                }

                var symbols: [CSSSymbol] = []
                while case let .success(symbol) = args.tryParse({ CSSSymbol.parse($0) }) {
                    symbols.append(symbol)
                }

                return .success(.symbols(system: symbolsType, symbols: symbols))
            }
            switch result {
            case let .success(counterStyle):
                return .success(counterStyle)
            case let .failure(error):
                return .failure(error.basic)
            }
        }

        // Try custom ident
        if case let .success(name) = CSSCustomIdent.parse(input) {
            return .success(.name(name))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSPredefinedCounterStyle {
    static func parse(_ input: Parser) -> Result<CSSPredefinedCounterStyle, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let value = ident.value.lowercased()
        if let style = CSSPredefinedCounterStyle.allCases.first(where: { $0.rawValue == value }) {
            return .success(style)
        }

        return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
    }
}

extension CSSSymbolsType {
    static func parse(_ input: Parser) -> Result<CSSSymbolsType, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let value = ident.value.lowercased()
        if let type = CSSSymbolsType.allCases.first(where: { $0.rawValue == value }) {
            return .success(type)
        }

        return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
    }
}

extension CSSSymbol {
    static func parse(_ input: Parser) -> Result<CSSSymbol, BasicParseError> {
        // Try string first
        if case let .success(str) = input.tryParse({ CSSString.parse($0) }) {
            return .success(.string(str))
        }

        // Try image
        if case let .success(image) = CSSImage.parse(input) {
            return .success(.image(image))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSListStylePosition {
    static func parse(_ input: Parser) -> Result<CSSListStylePosition, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let value = ident.value.lowercased()
        if let position = CSSListStylePosition.allCases.first(where: { $0.rawValue == value }) {
            return .success(position)
        }

        return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
    }
}

extension CSSMarkerSide {
    static func parse(_ input: Parser) -> Result<CSSMarkerSide, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let value = ident.value.lowercased()
        if let side = CSSMarkerSide.allCases.first(where: { $0.rawValue == value }) {
            return .success(side)
        }

        return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
    }
}

extension CSSListStyle {
    static func parse(_ input: Parser) -> Result<CSSListStyle, BasicParseError> {
        var position: CSSListStylePosition?
        var image: CSSImage?
        var listStyleType: CSSListStyleType?
        var nones = 0

        // Parse components in any order
        while true {
            // `none` is ambiguous - both list-style-image and list-style-type support it
            if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
                nones += 1
                if nones > 2 {
                    return .failure(input.newBasicError(.endOfInput))
                }
                continue
            }

            if image == nil {
                if case let .success(val) = input.tryParse({ CSSImage.parse($0) }) {
                    image = val
                    continue
                }
            }

            if position == nil {
                if case let .success(val) = input.tryParse({ CSSListStylePosition.parse($0) }) {
                    position = val
                    continue
                }
            }

            if listStyleType == nil {
                if case let .success(val) = input.tryParse({ CSSListStyleType.parse($0) }) {
                    listStyleType = val
                    continue
                }
            }

            break
        }

        // Assign the `none` to the opposite property from the one we have a value for,
        // or both in case neither list-style-image or list-style-type have a value.
        switch (nones, image, listStyleType) {
        case (2, nil, nil), (1, nil, nil):
            return .success(CSSListStyle(
                position: position ?? .outside,
                image: .none,
                listStyleType: .none
            ))
        case (1, let img?, nil):
            return .success(CSSListStyle(
                position: position ?? .outside,
                image: img,
                listStyleType: .none
            ))
        case (1, nil, let type?):
            return .success(CSSListStyle(
                position: position ?? .outside,
                image: .none,
                listStyleType: type
            ))
        case let (0, img, type):
            return .success(CSSListStyle(
                position: position ?? .outside,
                image: img ?? .none,
                listStyleType: type ?? .counterStyle(.predefined(.disc))
            ))
        default:
            return .failure(input.newBasicError(.endOfInput))
        }
    }
}

// MARK: - ToCss

extension CSSListStyleType: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case let .string(str):
            str.serialize(dest: &dest)
        case let .counterStyle(counterStyle):
            counterStyle.serialize(dest: &dest)
        }
    }
}

extension CSSCounterStyle: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .predefined(style):
            style.serialize(dest: &dest)
        case let .name(name):
            name.serialize(dest: &dest)
        case let .symbols(system, symbols):
            dest.write("symbols(")
            var needsSpace = false
            if system != .symbolic {
                system.serialize(dest: &dest)
                needsSpace = true
            }

            for symbol in symbols {
                if needsSpace {
                    dest.write(" ")
                }
                symbol.serialize(dest: &dest)
                needsSpace = true
            }
            dest.write(")")
        }
    }
}

extension CSSPredefinedCounterStyle: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSSymbolsType: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSSymbol: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .string(str):
            str.serialize(dest: &dest)
        case let .image(image):
            image.serialize(dest: &dest)
        }
    }
}

extension CSSListStylePosition: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSMarkerSide: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSListStyle: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        var needsSpace = false

        if position != .default {
            position.serialize(dest: &dest)
            needsSpace = true
        }

        if image != .none {
            if needsSpace { dest.write(" ") }
            image.serialize(dest: &dest)
            needsSpace = true
        }

        if listStyleType != .default {
            if needsSpace { dest.write(" ") }
            listStyleType.serialize(dest: &dest)
            needsSpace = true
        }

        // If nothing was written, write the default position
        if !needsSpace {
            position.serialize(dest: &dest)
        }
    }
}
