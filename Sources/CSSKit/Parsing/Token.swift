// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// Numeric value data shared by number, percentage, and dimension tokens.
public struct NumericValue: Equatable, Sendable, Hashable {
    /// Whether the number had a `+` or `-` sign.
    public let hasSign: Bool

    /// The numeric value as a double.
    public let value: Double

    /// If the source did not include a fractional part, the value as an integer.
    public let intValue: Int32?

    /// The original text representation from the source.
    public let repr: Lexeme

    public init(hasSign: Bool, value: Double, intValue: Int32?, repr: Lexeme) {
        self.hasSign = hasSign
        self.value = value
        self.intValue = intValue
        self.repr = repr
    }
}

/// A CSS token from the input stream.
public enum Token: Equatable, Sendable, Hashable {
    /// A [`<ident-token>`](https://drafts.csswg.org/css-syntax/#ident-token-diagram)
    case ident(Lexeme)

    /// A [`<at-keyword-token>`](https://drafts.csswg.org/css-syntax/#at-keyword-token-diagram)
    ///
    /// The value does not include the `@` marker.
    case atKeyword(Lexeme)

    /// A [`<hash-token>`](https://drafts.csswg.org/css-syntax/#hash-token-diagram)
    /// with the type flag set to "unrestricted"
    ///
    /// The value does not include the `#` marker.
    case hash(Lexeme)

    /// A [`<hash-token>`](https://drafts.csswg.org/css-syntax/#hash-token-diagram)
    /// with the type flag set to "id"
    ///
    /// Hash that is a valid ID selector. The value does not include the `#` marker.
    case idHash(Lexeme)

    /// A [`<string-token>`](https://drafts.csswg.org/css-syntax/#string-token-diagram)
    ///
    /// The value does not include the quotes.
    case quotedString(Lexeme)

    /// A [`<url-token>`](https://drafts.csswg.org/css-syntax/#url-token-diagram)
    ///
    /// The value does not include the `url(` `)` markers.
    /// `url( <string-token> )` is represented by a `function` token.
    case unquotedUrl(Lexeme)

    /// A `<delim-token>`
    case delim(Character)

    /// A [`<number-token>`](https://drafts.csswg.org/css-syntax/#number-token-diagram)
    case number(NumericValue)

    /// A [`<percentage-token>`](https://drafts.csswg.org/css-syntax/#percentage-token-diagram)
    ///
    /// The `value` is divided by 100 so that the nominal range is 0.0 to 1.0.
    /// The `intValue` is NOT divided by 100.
    case percentage(NumericValue)

    /// A [`<dimension-token>`](https://drafts.csswg.org/css-syntax/#dimension-token-diagram)
    case dimension(NumericValue, unit: Lexeme)

    /// A [`<whitespace-token>`](https://drafts.csswg.org/css-syntax/#whitespace-token-diagram)
    case whiteSpace(Substring)

    /// A comment.
    ///
    /// The CSS Syntax spec does not generate tokens for comments,
    /// but we do because borrowed Substring makes it cheap.
    ///
    /// The value does not include the `/*` `*/` markers.
    case comment(Substring)

    /// A `:` `<colon-token>`
    case colon

    /// A `;` `<semicolon-token>`
    case semicolon

    /// A `,` `<comma-token>`
    case comma

    /// A `~=` [`<include-match-token>`](https://drafts.csswg.org/css-syntax/#include-match-token-diagram)
    case includeMatch

    /// A `|=` [`<dash-match-token>`](https://drafts.csswg.org/css-syntax/#dash-match-token-diagram)
    case dashMatch

    /// A `^=` [`<prefix-match-token>`](https://drafts.csswg.org/css-syntax/#prefix-match-token-diagram)
    case prefixMatch

    /// A `$=` [`<suffix-match-token>`](https://drafts.csswg.org/css-syntax/#suffix-match-token-diagram)
    case suffixMatch

    /// A `*=` [`<substring-match-token>`](https://drafts.csswg.org/css-syntax/#substring-match-token-diagram)
    case substringMatch

    /// A `<!--` [`<CDO-token>`](https://drafts.csswg.org/css-syntax/#CDO-token-diagram)
    case cdo

    /// A `-->` [`<CDC-token>`](https://drafts.csswg.org/css-syntax/#CDC-token-diagram)
    case cdc

    /// A `||` [`<column-token>`](https://drafts.csswg.org/css-syntax/#column-token-diagram)
    case column

    /// A [`<function-token>`](https://drafts.csswg.org/css-syntax/#function-token-diagram)
    ///
    /// The value (name) does not include the `(` marker.
    case function(Lexeme)

    /// A `<(-token>`
    case parenthesisBlock

    /// A `<[-token>`
    case squareBracketBlock

    /// A `<{-token>`
    case curlyBracketBlock

    /// A `<bad-url-token>`. Indicates a parse error.
    case badUrl(Lexeme)

    /// A `<bad-string-token>`. Indicates a parse error.
    case badString(Lexeme)

    /// A `<)-token>`
    ///
    /// When obtained from one of the `Parser.next*` methods,
    /// this token is always unmatched and indicates a parse error.
    case closeParenthesis

    /// A `<]-token>`
    ///
    /// When obtained from one of the `Parser.next*` methods,
    /// this token is always unmatched and indicates a parse error.
    case closeSquareBracket

    /// A `<}-token>`
    ///
    /// When obtained from one of the `Parser.next*` methods,
    /// this token is always unmatched and indicates a parse error.
    case closeCurlyBracket

    /// A `<unicode-range-token>`
    ///
    /// Represents a range of Unicode code points.
    case unicodeRange(start: UInt32, end: UInt32)

    /// Error token emitted after a string terminated by EOF rather than a closing quote.
    case eofInString

    /// Error token emitted after a URL terminated by EOF rather than a closing parenthesis.
    case eofInUrl
}

// MARK: - Token Properties

public extension Token {
    /// Whether this token represents a parse error.
    ///
    /// `badUrl` and `badString` are tokenizer-level parse errors.
    /// `closeParenthesis`, `closeSquareBracket`, and `closeCurlyBracket` are unmatched
    /// and therefore parse errors when returned by one of the `Parser.next*` methods.
    var isParseError: Bool {
        switch self {
        case .badUrl, .badString, .closeParenthesis, .closeSquareBracket, .closeCurlyBracket,
             .eofInString, .eofInUrl:
            true
        default:
            false
        }
    }

    /// The identifier name, or `nil` if not an ident token.
    var identValue: Lexeme? {
        if case let .ident(value) = self {
            return value
        }
        return nil
    }

    /// The function name, or `nil` if not a function token.
    var functionName: Lexeme? {
        if case let .function(name) = self {
            return name
        }
        return nil
    }

    /// The string value, or `nil` if not a quoted string token.
    var stringValue: Lexeme? {
        if case let .quotedString(value) = self {
            return value
        }
        return nil
    }

    /// The numeric value, or `nil` if not a number token.
    var numberValue: Double? {
        if case let .number(numeric) = self {
            return numeric.value
        }
        return nil
    }

    /// The integer value, or `nil` if not a number token with an integer value.
    var integerValue: Int32? {
        if case let .number(numeric) = self {
            return numeric.intValue
        }
        return nil
    }

    /// The unit value, or `nil` if not a percentage token.
    var percentageValue: Double? {
        if case let .percentage(numeric) = self {
            return numeric.value
        }
        return nil
    }

    /// The dimension value and unit, or `nil` if not a dimension token.
    var dimensionValue: (value: Double, unit: Lexeme)? {
        if case let .dimension(numeric, unit) = self {
            return (numeric.value, unit)
        }
        return nil
    }

    /// The CSS string representation of this token.
    var cssString: String {
        switch self {
        case let .ident(value): return value.value
        case let .atKeyword(value): return "@" + value.value
        case let .hash(value), let .idHash(value): return "#" + value.value
        case let .quotedString(value): return "\"" + value.value + "\""
        case let .unquotedUrl(value): return "url(" + value.value + ")"
        case let .delim(char): return String(char)
        case let .number(numeric): return numeric.repr.value
        case let .percentage(numeric): return numeric.repr.value + "%"
        case let .dimension(numeric, unit): return numeric.repr.value + unit.value
        case .whiteSpace: return " "
        case .comment: return ""
        case .colon: return ":"
        case .semicolon: return ";"
        case .comma: return ","
        case .includeMatch: return "~="
        case .dashMatch: return "|="
        case .prefixMatch: return "^="
        case .suffixMatch: return "$="
        case .substringMatch: return "*="
        case .cdo: return "<!--"
        case .cdc: return "-->"
        case .column: return "||"
        case let .function(name): return name.value + "("
        case .parenthesisBlock: return "("
        case .squareBracketBlock: return "["
        case .curlyBracketBlock: return "{"
        case .closeParenthesis: return ")"
        case .closeSquareBracket: return "]"
        case .closeCurlyBracket: return "}"
        case let .badUrl(value): return "url(" + value.value + ")"
        case let .badString(value): return "\"" + value.value
        case let .unicodeRange(start, end):
            if start == end { return "U+\(String(start, radix: 16, uppercase: true))" }
            return "U+\(String(start, radix: 16, uppercase: true))-\(String(end, radix: 16, uppercase: true))"
        case .eofInString, .eofInUrl: return ""
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension Token: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .ident(value):
            "ident(\(value))"
        case let .atKeyword(value):
            "atKeyword(\(value))"
        case let .hash(value):
            "hash(\(value))"
        case let .idHash(value):
            "idHash(\(value))"
        case let .quotedString(value):
            "quotedString(\(value))"
        case let .unquotedUrl(value):
            "unquotedUrl(\(value))"
        case let .delim(char):
            "delim(\(char))"
        case let .number(numeric):
            "number(\(numeric))"
        case let .percentage(numeric):
            "percentage(\(numeric))"
        case let .dimension(numeric, unit):
            "dimension(\(numeric), unit: \(unit))"
        case let .whiteSpace(content):
            "whiteSpace(\(content.debugDescription))"
        case let .comment(content):
            "comment(\(content.debugDescription))"
        case .colon:
            "colon"
        case .semicolon:
            "semicolon"
        case .comma:
            "comma"
        case .includeMatch:
            "includeMatch"
        case .dashMatch:
            "dashMatch"
        case .prefixMatch:
            "prefixMatch"
        case .suffixMatch:
            "suffixMatch"
        case .substringMatch:
            "substringMatch"
        case .cdo:
            "cdo"
        case .cdc:
            "cdc"
        case .column:
            "column"
        case let .function(name):
            "function(\(name))"
        case .parenthesisBlock:
            "parenthesisBlock"
        case .squareBracketBlock:
            "squareBracketBlock"
        case .curlyBracketBlock:
            "curlyBracketBlock"
        case let .badUrl(contents):
            "badUrl(\(contents))"
        case let .badString(value):
            "badString(\(value))"
        case .closeParenthesis:
            "closeParenthesis"
        case .closeSquareBracket:
            "closeSquareBracket"
        case .closeCurlyBracket:
            "closeCurlyBracket"
        case let .unicodeRange(start, end):
            "unicodeRange(start: \(start), end: \(end))"
        case .eofInString:
            "eofInString"
        case .eofInUrl:
            "eofInUrl"
        }
    }
}
