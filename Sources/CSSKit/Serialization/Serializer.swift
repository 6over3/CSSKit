// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - ToCss Protocol

/// A type that can serialize itself to CSS syntax.
public protocol CSSSerializable {
    /// Serialize `self` in CSS syntax, writing to `dest`.
    func serialize(dest: inout some CSSWriter)
}

// MARK: - CssWriter Protocol

/// A destination for CSS output.
public protocol CSSWriter {
    /// Writes a string to the output.
    mutating func write(_ string: String)

    /// Writes a character to the output.
    mutating func write(_ character: Character)
}

public extension CSSWriter {
    mutating func write(_ char: Character) {
        write(String(char))
    }
}

// MARK: - StringCSSWriter

/// A CSS writer that accumulates output into a string.
public struct StringCSSWriter: CSSWriter {
    /// The accumulated result.
    public var result: String = ""

    public init() {}

    public mutating func write(_ str: String) {
        result += str
    }

    public mutating func write(_ char: Character) {
        result.append(char)
    }
}

// MARK: - Serialization Helpers

/// Writes a hex escape for a byte.
func hexEscape(byte: UInt8, dest: inout some CSSWriter) {
    let hexDigits: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
    dest.write("\\")
    if byte > 0x0F {
        let high = Int(byte >> 4)
        let low = Int(byte & 0x0F)
        dest.write(hexDigits[high])
        dest.write(hexDigits[low])
    } else {
        dest.write(hexDigits[Int(byte)])
    }
    dest.write(" ")
}

/// Writes a character escape.
func charEscape(byte: UInt8, dest: inout some CSSWriter) {
    dest.write("\\")
    dest.write(Character(UnicodeScalar(byte)))
}

/// Writes a numeric value.
func writeNumeric(value: Double, intValue: Int32?, hasSign: Bool, dest: inout some CSSWriter) {
    if value == 0.0, value.sign == .minus {
        dest.write("-0")
        return
    }

    if hasSign, value >= 0.0 {
        dest.write("+")
    }

    if let intVal = intValue {
        dest.write(String(intVal))
        return
    }

    let str = formatDouble(value)
    dest.write(str)

    if value.truncatingRemainder(dividingBy: 1) == 0, !str.contains("."), !str.contains("e"), !str.contains("E") {
        dest.write(".0")
    }
}

/// Returns a minimal CSS representation of a double.
func formatDouble(_ value: Double) -> String {
    if value.isNaN {
        return "NaN"
    }
    if value.isInfinite {
        return value > 0 ? "infinity" : "-infinity"
    }
    if value == 0 {
        return "0"
    }

    var result = String(format: "%.15g", value)

    if result.contains("."), !result.contains("e") {
        while result.hasSuffix("0") {
            result.removeLast()
        }
        if result.hasSuffix(".") {
            result.removeLast()
        }
    }

    return result
}

// MARK: - Identifier Serialization

/// Writes a CSS identifier, escaping characters as necessary.
public func serializeIdentifier(_ value: String, dest: inout some CSSWriter) {
    if value.isEmpty {
        return
    }

    if value.hasPrefix("--") {
        dest.write("--")
        serializeName(String(value.dropFirst(2)), dest: &dest)
        return
    }

    if value == "-" {
        dest.write("\\-")
        return
    }

    var remaining = value
    let bytes = Array(value.utf8)
    var index = 0

    if bytes[0] == UInt8(ascii: "-") {
        dest.write("-")
        remaining = String(value.dropFirst())
        index = 1
    }

    if index < bytes.count {
        let firstByte = bytes[index]
        if firstByte >= UInt8(ascii: "0"), firstByte <= UInt8(ascii: "9") {
            hexEscape(byte: firstByte, dest: &dest)
            remaining = String(remaining.dropFirst())
        }
    }

    serializeName(remaining, dest: &dest)
}

/// Writes a CSS name, such as a custom property name.
public func serializeName(_ value: String, dest: inout some CSSWriter) {
    var chunkStart = value.startIndex

    for (i, byte) in value.utf8.enumerated() {
        let escaped: String?
        switch byte {
        case UInt8(ascii: "0") ... UInt8(ascii: "9"),
             UInt8(ascii: "A") ... UInt8(ascii: "Z"),
             UInt8(ascii: "a") ... UInt8(ascii: "z"),
             UInt8(ascii: "_"),
             UInt8(ascii: "-"):
            continue
        case 0x00:
            escaped = "\u{FFFD}"
        default:
            if byte >= 0x80 {
                // Non-ASCII, pass through
                continue
            }
            escaped = nil
        }

        let currentIndex = value.utf8.index(value.startIndex, offsetBy: i)
        if chunkStart < currentIndex {
            dest.write(String(value[chunkStart ..< currentIndex]))
        }

        if let esc = escaped {
            dest.write(esc)
        } else if byte >= 0x01 && byte <= 0x1F || byte == 0x7F {
            hexEscape(byte: byte, dest: &dest)
        } else {
            charEscape(byte: byte, dest: &dest)
        }

        chunkStart = value.utf8.index(after: currentIndex)
    }

    if chunkStart < value.endIndex {
        dest.write(String(value[chunkStart...]))
    }
}

/// URL serialization escape type.
private enum UrlEscapeType {
    case hex
    case char
}

/// Serializes an unquoted URL value.
public func serializeUnquotedUrl(_ value: String, dest: inout some CSSWriter) {
    var chunkStart = value.startIndex

    for (i, byte) in value.utf8.enumerated() {
        let escapeType: UrlEscapeType
        switch byte {
        case 0x00 ... 0x20, 0x7F:
            escapeType = .hex
        case UInt8(ascii: "("), UInt8(ascii: ")"), UInt8(ascii: "\""), UInt8(ascii: "'"), UInt8(ascii: "\\"):
            escapeType = .char
        default:
            continue
        }

        let currentIndex = value.utf8.index(value.startIndex, offsetBy: i)
        if chunkStart < currentIndex {
            dest.write(String(value[chunkStart ..< currentIndex]))
        }

        switch escapeType {
        case .hex:
            hexEscape(byte: byte, dest: &dest)
        case .char:
            charEscape(byte: byte, dest: &dest)
        }

        chunkStart = value.utf8.index(after: currentIndex)
    }

    if chunkStart < value.endIndex {
        dest.write(String(value[chunkStart...]))
    }
}

/// Writes a double-quoted CSS string token, escaping content as necessary.
public func serializeString(_ value: String, dest: inout some CSSWriter) {
    dest.write("\"")
    serializeStringContents(value, dest: &dest)
    dest.write("\"")
}

/// Serializes string contents without quotes, escaping as necessary.
func serializeStringContents(_ value: String, dest: inout some CSSWriter) {
    var chunkStart = value.startIndex

    for (i, byte) in value.utf8.enumerated() {
        let escaped: String?
        switch byte {
        case UInt8(ascii: "\""):
            escaped = "\\\""
        case UInt8(ascii: "\\"):
            escaped = "\\\\"
        case 0x00:
            escaped = "\u{FFFD}"
        case 0x01 ... 0x1F, 0x7F:
            escaped = nil
        default:
            continue
        }

        let currentIndex = value.utf8.index(value.startIndex, offsetBy: i)
        if chunkStart < currentIndex {
            dest.write(String(value[chunkStart ..< currentIndex]))
        }

        if let esc = escaped {
            dest.write(esc)
        } else {
            hexEscape(byte: byte, dest: &dest)
        }

        chunkStart = value.utf8.index(after: currentIndex)
    }

    if chunkStart < value.endIndex {
        dest.write(String(value[chunkStart...]))
    }
}

// MARK: - Token ToCss

extension Token: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .ident(value):
            serializeIdentifier(value.value, dest: &dest)

        case let .atKeyword(value):
            dest.write("@")
            serializeIdentifier(value.value, dest: &dest)

        case let .hash(value):
            dest.write("#")
            serializeName(value.value, dest: &dest)

        case let .idHash(value):
            dest.write("#")
            serializeIdentifier(value.value, dest: &dest)

        case let .quotedString(value):
            serializeString(value.value, dest: &dest)

        case let .unquotedUrl(value):
            dest.write("url(")
            serializeUnquotedUrl(value.value, dest: &dest)
            dest.write(")")

        case let .delim(char):
            dest.write(char)

        case let .number(numeric):
            dest.write(numeric.repr.value)

        case let .percentage(numeric):
            dest.write(numeric.repr.value)
            dest.write("%")

        case let .dimension(numeric, unit):
            dest.write(numeric.repr.value)
            // Disambiguate with scientific notation
            let unitStr = unit.value
            if unitStr == "e" || unitStr == "E" || unitStr.hasPrefix("e-") || unitStr.hasPrefix("E-") {
                dest.write("\\65 ")
                serializeName(String(unitStr.dropFirst()), dest: &dest)
            } else {
                serializeIdentifier(unitStr, dest: &dest)
            }

        case let .whiteSpace(content):
            dest.write(String(content))

        case let .comment(content):
            dest.write("/*")
            dest.write(String(content))
            dest.write("*/")

        case .colon:
            dest.write(":")

        case .semicolon:
            dest.write(";")

        case .comma:
            dest.write(",")

        case .includeMatch:
            dest.write("~=")

        case .dashMatch:
            dest.write("|=")

        case .prefixMatch:
            dest.write("^=")

        case .suffixMatch:
            dest.write("$=")

        case .substringMatch:
            dest.write("*=")

        case .cdo:
            dest.write("<!--")

        case .cdc:
            dest.write("-->")

        case .column:
            dest.write("||")

        case let .function(name):
            serializeIdentifier(name.value, dest: &dest)
            dest.write("(")

        case .parenthesisBlock:
            dest.write("(")

        case .squareBracketBlock:
            dest.write("[")

        case .curlyBracketBlock:
            dest.write("{")

        case let .badUrl(contents):
            dest.write("url(")
            dest.write(contents.value)
            dest.write(")")

        case let .badString(value):
            // BadString ends without closing quote
            dest.write("\"")
            serializeStringContents(value.value, dest: &dest)

        case .closeParenthesis:
            dest.write(")")

        case .closeSquareBracket:
            dest.write("]")

        case .closeCurlyBracket:
            dest.write("}")

        case let .unicodeRange(start, end):
            dest.write("U+")
            dest.write(String(start, radix: 16, uppercase: true))
            if end != start {
                dest.write("-")
                dest.write(String(end, radix: 16, uppercase: true))
            }

        case .eofInString, .eofInUrl:
            // Error tokens don't serialize to anything - they are markers for parse errors
            break
        }
    }
}

// MARK: - Token Serialization Type

/// Token category for separator insertion.
enum TokenSerializationType: Equatable, Sendable {
    /// No token serialization type.
    case nothing

    /// Whitespace token.
    case whiteSpace

    /// At-keyword or hash token.
    case atKeywordOrHash

    /// Number token.
    case number

    /// Dimension token.
    case dimension

    /// Percentage token.
    case percentage

    /// URL or bad URL token.
    case urlOrBadUrl

    /// Function token.
    case function

    /// Ident token.
    case ident

    /// CDC (-->) token.
    case cdc

    /// Dash match (|=) token.
    case dashMatch

    /// Substring match (*=) token.
    case substringMatch

    /// Open parenthesis token.
    case openParen

    /// # delimiter token.
    case delimHash

    /// @ delimiter token.
    case delimAt

    /// . or + delimiter token.
    case delimDotOrPlus

    /// - delimiter token.
    case delimMinus

    /// ? delimiter token.
    case delimQuestion

    /// $, ^, or ~ delimiter token.
    case delimAssorted

    /// = delimiter token.
    case delimEquals

    /// | delimiter token.
    case delimBar

    /// / delimiter token.
    case delimSlash

    /// * delimiter token.
    case delimStar

    /// % delimiter token.
    case delimPercent

    /// Unicode-range token.
    case unicodeRange

    /// Any other token.
    case other

    /// Sets the value if it is currently `.nothing`.
    mutating func setIfNothing(_ newValue: Self) {
        if self == .nothing {
            self = newValue
        }
    }

    /// Returns whether a `/**/` separator is needed before a token of the given type.
    func needsSeparatorWhenBefore(_ other: Self) -> Bool {
        switch self {
        case .ident:
            switch other {
            case .ident, .function, .urlOrBadUrl, .delimMinus, .number, .percentage, .dimension, .cdc, .openParen:
                true
            default:
                false
            }

        case .atKeywordOrHash, .dimension:
            switch other {
            case .ident, .function, .urlOrBadUrl, .delimMinus, .number, .percentage, .dimension, .cdc:
                true
            default:
                false
            }

        case .delimHash, .delimMinus:
            switch other {
            case .ident, .function, .urlOrBadUrl, .delimMinus, .number, .percentage, .dimension:
                true
            default:
                false
            }

        case .number:
            switch other {
            case .ident, .function, .urlOrBadUrl, .delimMinus, .number, .percentage, .delimPercent, .dimension:
                true
            default:
                false
            }

        case .delimAt:
            switch other {
            case .ident, .function, .urlOrBadUrl, .delimMinus:
                true
            default:
                false
            }

        case .delimDotOrPlus:
            switch other {
            case .number, .percentage, .dimension:
                true
            default:
                false
            }

        case .delimAssorted, .delimStar:
            other == .delimEquals

        case .delimBar:
            switch other {
            case .delimEquals, .delimBar, .dashMatch:
                true
            default:
                false
            }

        case .delimSlash:
            switch other {
            case .delimStar, .substringMatch:
                true
            default:
                false
            }

        case .unicodeRange:
            // Unicode-range can be followed by hex digits, which could be confused with the range end
            switch other {
            case .ident, .function, .urlOrBadUrl, .number, .percentage, .dimension:
                true
            default:
                false
            }

        case .nothing, .whiteSpace, .percentage, .urlOrBadUrl, .function, .cdc, .openParen,
             .dashMatch, .substringMatch, .delimQuestion, .delimEquals, .delimPercent, .other:
            false
        }
    }
}

extension Token {
    /// The serialization type category for separator insertion.
    var serializationType: TokenSerializationType {
        switch self {
        case .ident:
            .ident
        case .atKeyword, .hash, .idHash:
            .atKeywordOrHash
        case .unquotedUrl, .badUrl:
            .urlOrBadUrl
        case let .delim(char):
            switch char {
            case "#":
                .delimHash
            case "@":
                .delimAt
            case ".", "+":
                .delimDotOrPlus
            case "-":
                .delimMinus
            case "?":
                .delimQuestion
            case "$", "^", "~":
                .delimAssorted
            case "%":
                .delimPercent
            case "=":
                .delimEquals
            case "|":
                .delimBar
            case "/":
                .delimSlash
            case "*":
                .delimStar
            default:
                .other
            }
        case .number:
            .number
        case .percentage:
            .percentage
        case .dimension:
            .dimension
        case .whiteSpace:
            .whiteSpace
        case .comment:
            .delimSlash
        case .dashMatch:
            .dashMatch
        case .substringMatch:
            .substringMatch
        case .cdc:
            .cdc
        case .function:
            .function
        case .parenthesisBlock:
            .openParen
        case .unicodeRange:
            .unicodeRange
        case .squareBracketBlock, .curlyBracketBlock, .closeParenthesis, .closeSquareBracket,
             .closeCurlyBracket, .quotedString, .badString, .colon, .semicolon, .comma, .cdo,
             .includeMatch, .prefixMatch, .suffixMatch, .column, .eofInString, .eofInUrl:
            .other
        }
    }
}

// MARK: - ToCss for Basic Types

extension Int: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(String(self))
    }
}

extension Int32: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(String(self))
    }
}

extension UInt32: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(String(self))
    }
}

extension Double: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(formatDouble(self))
    }
}
