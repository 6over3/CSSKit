// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A CSS syntax string used to define the grammar for a registered custom property.
/// https://drafts.css-houdini.org/css-properties-values-api/#syntax-strings
public enum CSSSyntaxString: Equatable, Sendable, Hashable {
    /// A list of syntax components separated by `|`.
    case components([CSSSyntaxComponent])

    /// The universal syntax definition (`*`), which accepts any valid token stream.
    case universal
}

// MARK: - Syntax Component

/// A syntax component within a syntax string.
/// https://drafts.css-houdini.org/css-properties-values-api/#syntax-component
public struct CSSSyntaxComponent: Equatable, Sendable, Hashable {
    /// The kind of component.
    public let kind: CSSSyntaxComponentKind

    /// A multiplier for the component.
    public let multiplier: CSSSyntaxMultiplier

    /// Creates a syntax component.
    public init(kind: CSSSyntaxComponentKind, multiplier: CSSSyntaxMultiplier = .none) {
        self.kind = kind
        self.multiplier = multiplier
    }
}

// MARK: - Syntax Component Kind

/// A syntax component name.
/// https://drafts.css-houdini.org/css-properties-values-api/#supported-names
public enum CSSSyntaxComponentKind: Equatable, Sendable, Hashable {
    /// A `<length>` component.
    case length

    /// A `<number>` component.
    case number

    /// A `<percentage>` component.
    case percentage

    /// A `<length-percentage>` component.
    case lengthPercentage

    /// A `<string>` component.
    case string

    /// A `<color>` component.
    case color

    /// An `<image>` component.
    case image

    /// A `<url>` component.
    case url

    /// An `<integer>` component.
    case integer

    /// An `<angle>` component.
    case angle

    /// A `<time>` component.
    case time

    /// A `<resolution>` component.
    case resolution

    /// A `<transform-function>` component.
    case transformFunction

    /// A `<transform-list>` component.
    case transformList

    /// A `<custom-ident>` component.
    case customIdent

    /// A literal identifier component.
    case literal(String)
}

// MARK: - Multiplier

/// A multiplier for a syntax component.
/// https://drafts.css-houdini.org/css-properties-values-api/#multipliers
public enum CSSSyntaxMultiplier: Equatable, Sendable, Hashable {
    /// The component may not be repeated.
    case none

    /// The component may repeat one or more times, separated by spaces (`+`).
    case space

    /// The component may repeat one or more times, separated by commas (`#`).
    case comma
}

// MARK: - Parsed Component

/// A parsed value for a syntax component.
public enum CSSParsedComponent: Equatable, Sendable, Hashable {
    /// A `<length>` value.
    case length(CSSLength)

    /// A `<number>` value.
    case number(Double)

    /// A `<percentage>` value.
    case percentage(CSSPercentage)

    /// A `<length-percentage>` value.
    case lengthPercentage(CSSLengthPercentage)

    /// A `<string>` value.
    case string(CSSString)

    /// A `<color>` value.
    case color(Color)

    /// An `<image>` value.
    case image(CSSImage)

    /// A `<url>` value.
    case url(CSSUrl)

    /// An `<integer>` value.
    case integer(Int)

    /// An `<angle>` value.
    case angle(CSSAngle)

    /// A `<time>` value.
    case time(CSSTime)

    /// A `<resolution>` value.
    case resolution(CSSResolution)

    /// A `<transform-function>` value.
    case transformFunction(CSSTransform)

    /// A `<transform-list>` value.
    case transformList(CSSTransformList)

    /// A `<custom-ident>` value.
    case customIdent(CSSCustomIdent)

    /// A literal identifier value.
    case literal(String)

    /// A repeated component value.
    case repeated([Self], CSSSyntaxMultiplier)

    /// A raw token list (for universal syntax).
    case tokenList(String)
}

// MARK: - Parsing Syntax Strings

extension CSSSyntaxString {
    /// Parses a syntax string from its string representation.
    /// https://drafts.css-houdini.org/css-properties-values-api/#parsing-syntax
    public static func parse(string input: String) -> Result<CSSSyntaxString, SyntaxParseError> {
        var input = input.trimmingCharacters(in: .whitespaces)

        if input.isEmpty {
            return .failure(.empty)
        }

        if input == "*" {
            return .success(.universal)
        }

        var components: [CSSSyntaxComponent] = []

        while true {
            switch CSSSyntaxComponent.parse(string: &input) {
            case let .success(component):
                components.append(component)
            case let .failure(error):
                return .failure(error)
            }

            input = input.trimmingCharacters(in: .whitespaces)

            if input.isEmpty {
                break
            }

            if input.hasPrefix("|") {
                input.removeFirst()
                continue
            }

            return .failure(.unexpectedCharacter)
        }

        return .success(.components(components))
    }

    /// Parses a value according to this syntax grammar.
    func parseValue(_ input: Parser) -> Result<CSSParsedComponent, BasicParseError> {
        switch self {
        case .universal:
            // For universal, collect all tokens as a string
            let start = input.state()
            while !input.isExhausted {
                _ = input.next()
            }
            let slice = input.sliceFrom(start.sourcePosition())
            return .success(.tokenList(String(slice)))

        case let .components(components):
            // Loop through each component and return the first one that parses successfully
            for component in components {
                let state = input.state()

                switch component.parseValue(input) {
                case let .success(value):
                    return .success(value)
                case .failure:
                    input.reset(state)
                    continue
                }
            }

            return .failure(input.newBasicError(.endOfInput))
        }
    }
}

/// Errors that can occur when parsing a syntax string.
public enum SyntaxParseError: Error, Equatable, Sendable {
    /// The syntax string is empty.
    case empty

    /// An unexpected character was encountered.
    case unexpectedCharacter

    /// An invalid data type name was encountered.
    case invalidDataType

    /// Missing closing angle bracket.
    case missingClosingBracket
}

extension CSSSyntaxComponent {
    /// Parses a syntax component from a string.
    static func parse(string input: inout String) -> Result<CSSSyntaxComponent, SyntaxParseError> {
        input = input.trimmingCharacters(in: .whitespaces)

        switch CSSSyntaxComponentKind.parse(string: &input) {
        case let .success(kind):
            // Pre-multiplied types cannot have multipliers
            if kind == .transformList {
                return .success(CSSSyntaxComponent(kind: kind, multiplier: .none))
            }

            let multiplier: CSSSyntaxMultiplier
            if input.hasPrefix("+") {
                input.removeFirst()
                multiplier = .space
            } else if input.hasPrefix("#") {
                input.removeFirst()
                multiplier = .comma
            } else {
                multiplier = .none
            }

            return .success(CSSSyntaxComponent(kind: kind, multiplier: multiplier))

        case let .failure(error):
            return .failure(error)
        }
    }

    /// Parses a value according to this component.
    func parseValue(_ input: Parser) -> Result<CSSParsedComponent, BasicParseError> {
        var parsed: [CSSParsedComponent] = []

        loop: while true {
            let valueResult: Result<CSSParsedComponent, BasicParseError> = input.tryParse { p in
                switch self.kind {
                case .length:
                    return CSSLength.parse(p).map { .length($0) }
                case .number:
                    return CSSNumber.parse(p).map { .number($0) }
                case .percentage:
                    return CSSPercentage.parse(p).map { .percentage($0) }
                case .lengthPercentage:
                    return CSSLengthPercentage.parse(p).map { .lengthPercentage($0) }
                case .string:
                    return CSSString.parse(p).map { .string($0) }
                case .color:
                    return Color.parse(p).map { .color($0) }.mapError { $0.basic }
                case .image:
                    return CSSImage.parse(p).map { .image($0) }
                case .url:
                    return CSSUrl.parse(p).map { .url($0) }
                case .integer:
                    return Int.parse(p).map { .integer($0) }
                case .angle:
                    return CSSAngle.parse(p).map { .angle($0) }
                case .time:
                    return CSSTime.parse(p).map { .time($0) }
                case .resolution:
                    return CSSResolution.parse(p).map { .resolution($0) }
                case .transformFunction:
                    return CSSTransform.parse(p).map { .transformFunction($0) }
                case .transformList:
                    return CSSTransformList.parse(p).map { .transformList($0) }
                case .customIdent:
                    return CSSCustomIdent.parse(p).map { .customIdent($0) }
                case let .literal(expected):
                    let location = p.currentSourceLocation()
                    switch p.expectIdent() {
                    case let .success(ident):
                        if ident.value.lowercased() == expected.lowercased() {
                            return .success(.literal(String(ident.value)))
                        } else {
                            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
                        }
                    case let .failure(error):
                        return .failure(error)
                    }
                }
            }

            switch valueResult {
            case let .success(value):
                switch multiplier {
                case .none:
                    return .success(value)
                case .space:
                    parsed.append(value)
                    if input.isExhausted {
                        return .success(.repeated(parsed, multiplier))
                    }
                case .comma:
                    parsed.append(value)
                    if case .success = input.tryParse({ $0.expectComma() }) {
                        continue loop
                    } else {
                        return .success(.repeated(parsed, multiplier))
                    }
                }
            case .failure:
                break loop
            }
        }

        if !parsed.isEmpty {
            return .success(.repeated(parsed, multiplier))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSSyntaxComponentKind {
    /// Parses a syntax component kind from a string.
    static func parse(string input: inout String) -> Result<CSSSyntaxComponentKind, SyntaxParseError> {
        input = input.trimmingCharacters(in: .whitespaces)

        if input.hasPrefix("<") {
            // Parse data type name
            guard let endIndex = input.firstIndex(of: ">") else {
                return .failure(.missingClosingBracket)
            }

            let startIndex = input.index(after: input.startIndex)
            let name = String(input[startIndex ..< endIndex]).lowercased()

            let component: CSSSyntaxComponentKind
            switch name {
            case "length":
                component = .length
            case "number":
                component = .number
            case "percentage":
                component = .percentage
            case "length-percentage":
                component = .lengthPercentage
            case "string":
                component = .string
            case "color":
                component = .color
            case "image":
                component = .image
            case "url":
                component = .url
            case "integer":
                component = .integer
            case "angle":
                component = .angle
            case "time":
                component = .time
            case "resolution":
                component = .resolution
            case "transform-function":
                component = .transformFunction
            case "transform-list":
                component = .transformList
            case "custom-ident":
                component = .customIdent
            default:
                return .failure(.invalidDataType)
            }

            input = String(input[input.index(after: endIndex)...])
            return .success(component)
        } else if let firstChar = input.first, isIdentStart(firstChar) {
            // Parse literal identifier
            var endIndex = input.startIndex
            for char in input {
                if isNameCodePoint(char) {
                    endIndex = input.index(after: endIndex)
                } else {
                    break
                }
            }

            let name = String(input[..<endIndex])
            input = String(input[endIndex...])
            return .success(.literal(name))
        } else {
            return .failure(.unexpectedCharacter)
        }
    }
}

// MARK: - Character Classification

private func isIdentStart(_ c: Character) -> Bool {
    // https://drafts.csswg.org/css-syntax-3/#ident-start-code-point
    (c >= "A" && c <= "Z") ||
        (c >= "a" && c <= "z") ||
        c.unicodeScalars.first!.value >= 0x80 ||
        c == "_"
}

private func isNameCodePoint(_ c: Character) -> Bool {
    // https://drafts.csswg.org/css-syntax-3/#ident-code-point
    isIdentStart(c) || (c >= "0" && c <= "9") || c == "-"
}

// MARK: - Serialization

extension CSSSyntaxString: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("\"")
        switch self {
        case .universal:
            dest.write("*")
        case let .components(components):
            for (i, component) in components.enumerated() {
                if i > 0 {
                    dest.write(" | ")
                }
                component.serialize(dest: &dest)
            }
        }
        dest.write("\"")
    }
}

extension CSSSyntaxComponent: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        kind.serialize(dest: &dest)
        switch multiplier {
        case .none:
            break
        case .space:
            dest.write("+")
        case .comma:
            dest.write("#")
        }
    }
}

extension CSSSyntaxComponentKind: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .length:
            dest.write("<length>")
        case .number:
            dest.write("<number>")
        case .percentage:
            dest.write("<percentage>")
        case .lengthPercentage:
            dest.write("<length-percentage>")
        case .string:
            dest.write("<string>")
        case .color:
            dest.write("<color>")
        case .image:
            dest.write("<image>")
        case .url:
            dest.write("<url>")
        case .integer:
            dest.write("<integer>")
        case .angle:
            dest.write("<angle>")
        case .time:
            dest.write("<time>")
        case .resolution:
            dest.write("<resolution>")
        case .transformFunction:
            dest.write("<transform-function>")
        case .transformList:
            dest.write("<transform-list>")
        case .customIdent:
            dest.write("<custom-ident>")
        case let .literal(value):
            dest.write(value)
        }
    }
}

extension CSSParsedComponent: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .length(v):
            v.serialize(dest: &dest)
        case let .number(v):
            dest.write(formatDouble(v))
        case let .percentage(v):
            v.serialize(dest: &dest)
        case let .lengthPercentage(v):
            v.serialize(dest: &dest)
        case let .string(v):
            v.serialize(dest: &dest)
        case let .color(v):
            v.serialize(dest: &dest)
        case let .image(v):
            v.serialize(dest: &dest)
        case let .url(v):
            v.serialize(dest: &dest)
        case let .integer(v):
            dest.write(String(v))
        case let .angle(v):
            v.serialize(dest: &dest)
        case let .time(v):
            v.serialize(dest: &dest)
        case let .resolution(v):
            v.serialize(dest: &dest)
        case let .transformFunction(v):
            v.serialize(dest: &dest)
        case let .transformList(v):
            v.serialize(dest: &dest)
        case let .customIdent(v):
            v.serialize(dest: &dest)
        case let .literal(v):
            dest.write(v)
        case let .repeated(components, multiplier):
            for (i, component) in components.enumerated() {
                if i > 0 {
                    switch multiplier {
                    case .comma:
                        dest.write(", ")
                    case .space:
                        dest.write(" ")
                    case .none:
                        break
                    }
                }
                component.serialize(dest: &dest)
            }
        case let .tokenList(tokens):
            dest.write(tokens)
        }
    }
}
