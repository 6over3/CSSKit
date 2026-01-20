// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// https://drafts.csswg.org/css-syntax/#tokenization

import Foundation

/// A CSS tokenizer that produces tokens from an input string.
///
/// The tokenizer operates on UTF-8 byte positions for efficiency while
/// maintaining correct line/column tracking for source locations.
final class Tokenizer: @unchecked Sendable {
    /// The input string being tokenized.
    let input: String

    /// The UTF-8 view of the input for byte-level operations.

    let utf8: String.UTF8View

    /// Current position in bytes, from 0.

    var position: Int

    /// The position at the start of the current line (adjusted for UTF-16 column counting).

    var currentLineStartPosition: Int

    /// The current line number (0-indexed).

    var currentLineNumber: UInt32

    /// Source map URL if found in a comment.
    private(set) var sourceMapUrl: Substring?

    /// Source URL if found in a comment.
    private(set) var sourceUrl: Substring?

    /// The source file name for this input, used in error reporting.
    let sourceFile: String?

    /// Functions to look for (e.g., "var", "env") for arbitrary substitution detection.

    var lookingForFunctions: [String]?

    /// Whether we've seen any of the functions we're looking for.

    var seenFunction: Bool = false

    /// A pending error token to be returned on the next call to next().
    /// This is used to emit error tokens (like eofInString) after the main token.
    private(set) var pendingErrorToken: Token?

    // MARK: - Initialization

    /// Creates a new tokenizer for the given CSS input string.
    init(_ input: String, sourceFile: String? = nil) {
        self.input = input
        utf8 = input.utf8
        position = 0
        currentLineStartPosition = 0
        currentLineNumber = 0
        sourceMapUrl = nil
        sourceUrl = nil
        self.sourceFile = sourceFile
        lookingForFunctions = nil
        seenFunction = false
    }

    // MARK: - Public API

    /// Returns the next token, or nil if at end of input.

    func next() -> Token? {
        nextToken()
    }

    /// Returns the current source position.

    func currentPosition() -> SourcePosition {
        SourcePosition(position)
    }

    /// Returns the current source location (line and column).

    func currentSourceLocation() -> SourceLocation {
        SourceLocation(
            line: currentLineNumber,
            column: UInt32(position - currentLineStartPosition + 1),
            sourceFile: sourceFile
        )
    }

    /// Returns the current line being parsed.
    func currentSourceLine() -> Substring {
        let currentPos = position
        let beforeCurrent = input.utf8.prefix(currentPos)
        let afterCurrent = input.utf8.dropFirst(currentPos)

        // Find start of line
        var startIdx = input.startIndex
        if let lastNewline = beforeCurrent.lastIndex(where: { isNewline($0) }) {
            startIdx = input.utf8.index(after: lastNewline)
        }

        // Find end of line
        var endIdx = input.endIndex
        if let nextNewline = afterCurrent.firstIndex(where: { isNewline($0) }) {
            endIdx = nextNewline
        }

        return input[startIdx ..< endIdx]
    }

    /// Returns the state for later restoration.

    func state() -> TokenizerState {
        TokenizerState(
            position: position,
            currentLineStartPosition: currentLineStartPosition,
            currentLineNumber: currentLineNumber
        )
    }

    /// Reset to a previously saved state.

    func reset(to state: TokenizerState) {
        position = state.position
        currentLineStartPosition = state.currentLineStartPosition
        currentLineNumber = state.currentLineNumber
    }

    /// Returns a slice of the input from a position to the current position.

    func sliceFrom(_ start: SourcePosition) -> Substring {
        slice(start ..< currentPosition())
    }

    /// Returns a slice of the input for a range of positions.

    func slice(_ range: Range<SourcePosition>) -> Substring {
        let startIndex = input.utf8.index(input.startIndex, offsetBy: range.lowerBound.byteIndex)
        let endIndex = input.utf8.index(input.startIndex, offsetBy: range.upperBound.byteIndex)
        return input[startIndex ..< endIndex]
    }

    /// Start looking for arbitrary substitution functions like var() or env().
    func lookForArbitrarySubstitutionFunctions(_ functions: [String]) {
        lookingForFunctions = functions
        seenFunction = false
    }

    /// Checks if we've seen any of the functions we're looking for, and stops looking.
    func seenArbitrarySubstitutionFunctions() -> Bool {
        let result = seenFunction
        lookingForFunctions = nil
        seenFunction = false
        return result
    }

    /// Record that we've seen a function (called during tokenization).

    func seeFunction(_ name: Lexeme) {
        if let functions = lookingForFunctions {
            let nameStr = name.value.lowercased()
            if functions.contains(where: { nameStr == $0.lowercased() }) {
                seenFunction = true
            }
        }
    }

    /// Returns the next byte without consuming it.

    func nextByte() -> UInt8? {
        guard position < utf8.count else { return nil }
        let idx = utf8.index(utf8.startIndex, offsetBy: position)
        return utf8[idx]
    }

    /// Skip whitespace (and comments).
    func skipWhitespace() {
        while !isEOF() {
            switch nextByteUnchecked() {
            case UInt8(ascii: " "), UInt8(ascii: "\t"):
                advance(1)
            case UInt8(ascii: "\n"), UInt8(ascii: "\r"), 0x0C:
                consumeNewline()
            case UInt8(ascii: "/"):
                if startsWith("/*") {
                    _ = consumeComment()
                } else {
                    return
                }
            default:
                return
            }
        }
    }

    /// Skip whitespace, CDO (<!--), and CDC (-->).
    func skipCDCAndCDO() {
        while !isEOF() {
            switch nextByteUnchecked() {
            case UInt8(ascii: " "), UInt8(ascii: "\t"):
                advance(1)
            case UInt8(ascii: "\n"), UInt8(ascii: "\r"), 0x0C:
                consumeNewline()
            case UInt8(ascii: "/"):
                if startsWith("/*") {
                    _ = consumeComment()
                } else {
                    return
                }
            case UInt8(ascii: "<"):
                if startsWith("<!--") {
                    advance(4)
                } else {
                    return
                }
            case UInt8(ascii: "-"):
                if startsWith("-->") {
                    advance(3)
                } else {
                    return
                }
            default:
                return
            }
        }
    }

    // MARK: - Internal Position Helpers

    func isEOF() -> Bool {
        position >= utf8.count
    }

    func hasAtLeast(_ count: Int) -> Bool {
        position + count < utf8.count
    }

    func nextByteUnchecked() -> UInt8 {
        let idx = utf8.index(utf8.startIndex, offsetBy: position)
        return utf8[idx]
    }

    func byteAt(_ offset: Int) -> UInt8 {
        let idx = utf8.index(utf8.startIndex, offsetBy: position + offset)
        return utf8[idx]
    }

    func advance(_ count: Int) {
        position += count
    }

    func consumeNewline() {
        let byte = nextByteUnchecked()
        position += 1
        // Handle \r\n as single newline
        if byte == UInt8(ascii: "\r"), nextByte() == UInt8(ascii: "\n") {
            position += 1
        }
        currentLineStartPosition = position
        currentLineNumber += 1
    }

    func hasNewlineAt(_ offset: Int) -> Bool {
        guard position + offset < utf8.count else { return false }
        let byte = byteAt(offset)
        return byte == UInt8(ascii: "\n") || byte == UInt8(ascii: "\r") || byte == 0x0C
    }

    func startsWith(_ needle: String) -> Bool {
        let needleBytes = needle.utf8
        guard position + needleBytes.count <= utf8.count else { return false }
        for (i, byte) in needleBytes.enumerated() where byteAt(i) != byte {
            return false
        }
        return true
    }

    func nextChar() -> Character {
        let startIdx = utf8.index(utf8.startIndex, offsetBy: position)
        return input[startIdx]
    }

    func consumeChar() -> Character {
        let char = nextChar()
        let len = char.utf8.count
        position += len
        // Adjust for UTF-16 column counting
        currentLineStartPosition = currentLineStartPosition &+ (len - char.utf16.count)
        return char
    }

    /// Consume a known byte (not a newline).

    func consumeKnownByte(_ byte: UInt8) {
        position += 1
        // Adjust for multi-byte sequences
        if byte & 0xF0 == 0xF0 {
            // 4-byte UTF-8 intro
            currentLineStartPosition = currentLineStartPosition &- 1
        } else if byte & 0xC0 == 0x80 {
            // Continuation byte
            currentLineStartPosition = currentLineStartPosition &+ 1
        }
    }

    // MARK: - Token Consumption

    func nextToken() -> Token? {
        // Return pending error token first
        if let errorToken = pendingErrorToken {
            pendingErrorToken = nil
            return errorToken
        }

        guard !isEOF() else { return nil }

        let byte = nextByteUnchecked()

        switch byte {
        case UInt8(ascii: " "), UInt8(ascii: "\t"):
            return consumeWhitespace(newline: false)

        case UInt8(ascii: "\n"), UInt8(ascii: "\r"), 0x0C:
            return consumeWhitespace(newline: true)

        case UInt8(ascii: "\""):
            return consumeString(singleQuote: false)

        case UInt8(ascii: "#"):
            advance(1)
            if isIdentStart() {
                return .idHash(consumeName())
            } else if !isEOF() {
                let next = nextByteUnchecked()
                if (next >= UInt8(ascii: "0") && next <= UInt8(ascii: "9")) || next == UInt8(ascii: "-") {
                    return .hash(consumeName())
                }
            }
            return .delim("#")

        case UInt8(ascii: "$"):
            if startsWith("$=") {
                advance(2)
                return .suffixMatch
            }
            advance(1)
            return .delim("$")

        case UInt8(ascii: "'"):
            return consumeString(singleQuote: true)

        case UInt8(ascii: "("):
            advance(1)
            return .parenthesisBlock

        case UInt8(ascii: ")"):
            advance(1)
            return .closeParenthesis

        case UInt8(ascii: "*"):
            if startsWith("*=") {
                advance(2)
                return .substringMatch
            }
            advance(1)
            return .delim("*")

        case UInt8(ascii: "+"):
            if (hasAtLeast(1) && byteAt(1).isAsciiDigit) ||
                (hasAtLeast(2) && byteAt(1) == UInt8(ascii: ".") && byteAt(2).isAsciiDigit)
            {
                return consumeNumeric()
            }
            advance(1)
            return .delim("+")

        case UInt8(ascii: ","):
            advance(1)
            return .comma

        case UInt8(ascii: "-"):
            if (hasAtLeast(1) && byteAt(1).isAsciiDigit) ||
                (hasAtLeast(2) && byteAt(1) == UInt8(ascii: ".") && byteAt(2).isAsciiDigit)
            {
                return consumeNumeric()
            }
            if startsWith("-->") {
                advance(3)
                return .cdc
            }
            if isIdentStart() {
                return consumeIdentLike()
            }
            advance(1)
            return .delim("-")

        case UInt8(ascii: "."):
            if hasAtLeast(1), byteAt(1).isAsciiDigit {
                return consumeNumeric()
            }
            advance(1)
            return .delim(".")

        case UInt8(ascii: "/"):
            if startsWith("/*") {
                return .comment(consumeComment())
            }
            advance(1)
            return .delim("/")

        case UInt8(ascii: "0") ... UInt8(ascii: "9"):
            return consumeNumeric()

        case UInt8(ascii: ":"):
            advance(1)
            return .colon

        case UInt8(ascii: ";"):
            advance(1)
            return .semicolon

        case UInt8(ascii: "<"):
            if startsWith("<!--") {
                advance(4)
                return .cdo
            }
            advance(1)
            return .delim("<")

        case UInt8(ascii: "@"):
            advance(1)
            if isIdentStart() {
                return .atKeyword(consumeName())
            }
            return .delim("@")

        case UInt8(ascii: "a") ... UInt8(ascii: "z"),
             UInt8(ascii: "A") ... UInt8(ascii: "Z"),
             UInt8(ascii: "_"),
             0x00:
            return consumeIdentLike()

        case UInt8(ascii: "["):
            advance(1)
            return .squareBracketBlock

        case UInt8(ascii: "\\"):
            if !hasNewlineAt(1) {
                return consumeIdentLike()
            }
            advance(1)
            return .delim("\\")

        case UInt8(ascii: "]"):
            advance(1)
            return .closeSquareBracket

        case UInt8(ascii: "^"):
            if startsWith("^=") {
                advance(2)
                return .prefixMatch
            }
            advance(1)
            return .delim("^")

        case UInt8(ascii: "{"):
            advance(1)
            return .curlyBracketBlock

        case UInt8(ascii: "|"):
            if startsWith("||") {
                advance(2)
                return .column
            }
            if startsWith("|=") {
                advance(2)
                return .dashMatch
            }
            advance(1)
            return .delim("|")

        case UInt8(ascii: "}"):
            advance(1)
            return .closeCurlyBracket

        case UInt8(ascii: "~"):
            if startsWith("~=") {
                advance(2)
                return .includeMatch
            }
            advance(1)
            return .delim("~")

        default:
            if !byte.isASCII {
                return consumeIdentLike()
            }
            advance(1)
            return .delim(Character(UnicodeScalar(byte)))
        }
    }

    // MARK: - Token Consumers

    func consumeWhitespace(newline: Bool) -> Token {
        let startPos = currentPosition()
        if newline {
            consumeNewline()
        } else {
            advance(1)
        }

        while !isEOF() {
            switch nextByteUnchecked() {
            case UInt8(ascii: " "), UInt8(ascii: "\t"):
                advance(1)
            case UInt8(ascii: "\n"), UInt8(ascii: "\r"), 0x0C:
                consumeNewline()
            default:
                return .whiteSpace(sliceFrom(startPos))
            }
        }
        return .whiteSpace(sliceFrom(startPos))
    }

    func consumeComment() -> Substring {
        advance(2) // consume "/*"
        let startPos = currentPosition()

        while !isEOF() {
            let byte = nextByteUnchecked()
            switch byte {
            case UInt8(ascii: "*"):
                let endPos = currentPosition()
                advance(1)
                if nextByte() == UInt8(ascii: "/") {
                    advance(1)
                    let contents = slice(startPos ..< endPos)
                    checkForSourceMap(contents)
                    return contents
                }
            case UInt8(ascii: "\n"), UInt8(ascii: "\r"), 0x0C:
                consumeNewline()
            case 0x80 ... 0xBF:
                // Continuation byte
                currentLineStartPosition = currentLineStartPosition &+ 1
                position += 1
            case 0xF0 ... 0xFF:
                // 4-byte intro
                currentLineStartPosition = currentLineStartPosition &- 1
                position += 1
            default:
                advance(1)
            }
        }

        let contents = sliceFrom(startPos)
        checkForSourceMap(contents)
        return contents
    }

    func checkForSourceMap(_ contents: Substring) {
        let directive = "# sourceMappingURL="
        let directiveOld = "@ sourceMappingURL="

        if contents.hasPrefix(directive) || contents.hasPrefix(directiveOld) {
            let rest = contents.dropFirst(directive.count)
            sourceMapUrl = rest.prefix(while: { !$0.isWhitespace })
        }

        let sourceDirective = "# sourceURL="
        let sourceDirectiveOld = "@ sourceURL="

        if contents.hasPrefix(sourceDirective) || contents.hasPrefix(sourceDirectiveOld) {
            let rest = contents.dropFirst(sourceDirective.count)
            sourceUrl = rest.prefix(while: { !$0.isWhitespace })
        }
    }

    func consumeString(singleQuote: Bool) -> Token {
        switch consumeQuotedString(singleQuote: singleQuote) {
        case let .success(value):
            return .quotedString(value)
        case let .eofTerminated(value):
            pendingErrorToken = .eofInString
            return .quotedString(value)
        case let .failure(value):
            return .badString(value)
        }
    }

    enum QuotedStringResult {
        case success(Lexeme)
        case failure(Lexeme)
        case eofTerminated(Lexeme)
    }

    func consumeQuotedString(singleQuote: Bool) -> QuotedStringResult {
        advance(1) // Skip initial quote
        let startPos = currentPosition()

        // Fast path: try to find end without escapes
        while !isEOF() {
            let byte = nextByteUnchecked()
            switch byte {
            case UInt8(ascii: "\"") where !singleQuote:
                let value = sliceFrom(startPos)
                advance(1)
                return .success(Lexeme(value))

            case UInt8(ascii: "'") where singleQuote:
                let value = sliceFrom(startPos)
                advance(1)
                return .success(Lexeme(value))

            case UInt8(ascii: "\\"), 0x00:
                // Need to handle escapes - switch to slow path
                var stringBytes = Array(sliceFrom(startPos).utf8)
                return consumeQuotedStringSlow(singleQuote: singleQuote, bytes: &stringBytes)

            case UInt8(ascii: "\n"), UInt8(ascii: "\r"), 0x0C:
                // Unescaped newline in string - bad string
                return .failure(Lexeme(sliceFrom(startPos)))

            case 0x80 ... 0xBF:
                // Continuation byte
                currentLineStartPosition = currentLineStartPosition &+ 1
                position += 1

            case 0xF0 ... 0xFF:
                // 4-byte intro
                currentLineStartPosition = currentLineStartPosition &- 1
                position += 1

            default:
                advance(1)
            }
        }

        // EOF reached without closing quote
        return .eofTerminated(Lexeme(sliceFrom(startPos)))
    }

    func consumeQuotedStringSlow(singleQuote: Bool, bytes: inout [UInt8]) -> QuotedStringResult {
        while !isEOF() {
            let byte = nextByteUnchecked()
            switch byte {
            case UInt8(ascii: "\n"), UInt8(ascii: "\r"), 0x0C:
                return .failure(Lexeme(owned: String(decoding: bytes, as: UTF8.self)))

            case UInt8(ascii: "\"") where !singleQuote:
                advance(1)
                return .success(Lexeme(owned: String(decoding: bytes, as: UTF8.self)))

            case UInt8(ascii: "'") where singleQuote:
                advance(1)
                return .success(Lexeme(owned: String(decoding: bytes, as: UTF8.self)))

            case UInt8(ascii: "\\"):
                advance(1)
                if !isEOF() {
                    let next = nextByteUnchecked()
                    if next == UInt8(ascii: "\n") || next == UInt8(ascii: "\r") || next == 0x0C {
                        // Escaped newline - skip it
                        consumeNewline()
                    } else {
                        // Consume escape and append
                        consumeEscapeAndWrite(into: &bytes)
                    }
                }
                continue

            case 0x00:
                advance(1)
                bytes.append(contentsOf: "\u{FFFD}".utf8)
                continue

            case 0x80 ... 0xBF:
                currentLineStartPosition = currentLineStartPosition &+ 1
                position += 1
                bytes.append(byte)

            case 0xF0 ... 0xFF:
                currentLineStartPosition = currentLineStartPosition &- 1
                position += 1
                bytes.append(byte)

            default:
                advance(1)
                bytes.append(byte)
            }
        }

        // EOF reached without closing quote
        return .eofTerminated(Lexeme(owned: String(decoding: bytes, as: UTF8.self)))
    }

    func isIdentStart() -> Bool {
        guard !isEOF() else { return false }

        let byte = nextByteUnchecked()
        switch byte {
        case UInt8(ascii: "a") ... UInt8(ascii: "z"),
             UInt8(ascii: "A") ... UInt8(ascii: "Z"),
             UInt8(ascii: "_"),
             0x00:
            return true

        case UInt8(ascii: "-"):
            guard hasAtLeast(1) else { return false }
            let next = byteAt(1)
            switch next {
            case UInt8(ascii: "a") ... UInt8(ascii: "z"),
                 UInt8(ascii: "A") ... UInt8(ascii: "Z"),
                 UInt8(ascii: "-"),
                 UInt8(ascii: "_"),
                 0x00:
                return true
            case UInt8(ascii: "\\"):
                return !hasNewlineAt(2)
            default:
                return !next.isASCII
            }

        case UInt8(ascii: "\\"):
            return !hasNewlineAt(1)

        default:
            return !byte.isASCII
        }
    }

    func consumeIdentLike() -> Token {
        let value = consumeName()

        if value.value == "u" || value.value == "U", !isEOF(), nextByteUnchecked() == UInt8(ascii: "+") {
            if let unicodeRange = consumeUnicodeRange() {
                return unicodeRange
            }
        }

        if !isEOF(), nextByteUnchecked() == UInt8(ascii: "(") {
            advance(1)
            if value.eqIgnoreAsciiCase("url") {
                if let urlToken = consumeUnquotedUrl() {
                    return urlToken
                }
            }
            seeFunction(value)
            return .function(value)
        }

        return .ident(value)
    }

    /// Attempts to consume a unicode-range token starting after 'u' or 'U'.
    /// Returns nil if not a valid unicode-range (leaves position unchanged except for the '+').
    func consumeUnicodeRange() -> Token? {
        let beforePlus = position

        advance(1)

        guard !isEOF() else {
            position = beforePlus
            return nil
        }

        let firstByte = nextByteUnchecked()

        // Must be hex digit or '?'
        guard firstByte.isAsciiHexDigit || firstByte == UInt8(ascii: "?") else {
            position = beforePlus
            return nil
        }

        // Consume first part: hex digits
        var firstValue: UInt32 = 0
        var hexCount = 0

        while !isEOF(), hexCount < 6 {
            let byte = nextByteUnchecked()
            if let digit = byte.hexDigitValue {
                firstValue = firstValue * 16 + UInt32(digit)
                hexCount += 1
                advance(1)
            } else {
                break
            }
        }

        // Consume question marks
        var questionMarks = 0
        while !isEOF(), questionMarks + hexCount < 6, nextByteUnchecked() == UInt8(ascii: "?") {
            questionMarks += 1
            advance(1)
        }

        // If there are question marks, compute the range
        if questionMarks > 0 {
            let start = firstValue << (UInt32(questionMarks) * 4)
            let end = ((firstValue + 1) << (UInt32(questionMarks) * 4)) - 1
            return .unicodeRange(start: start, end: end)
        }

        // No question marks and no hex digits means invalid
        if hexCount == 0 {
            position = beforePlus
            return nil
        }

        if !isEOF(), nextByteUnchecked() == UInt8(ascii: "-") {
            let beforeDash = position
            advance(1)

            if !isEOF(), nextByteUnchecked().isAsciiHexDigit {
                var secondValue: UInt32 = 0
                var secondHexCount = 0

                while !isEOF(), secondHexCount < 6 {
                    let byte = nextByteUnchecked()
                    if let digit = byte.hexDigitValue {
                        secondValue = secondValue * 16 + UInt32(digit)
                        secondHexCount += 1
                        advance(1)
                    } else {
                        break
                    }
                }

                if secondHexCount > 0 {
                    return .unicodeRange(start: firstValue, end: secondValue)
                }
            }

            // Not a valid range, restore position to before dash
            position = beforeDash
        }

        // Single value
        return .unicodeRange(start: firstValue, end: firstValue)
    }

    func consumeName() -> Lexeme {
        let startPos = currentPosition()

        // Fast path: ASCII identifier without escapes
        while !isEOF() {
            let byte = nextByteUnchecked()
            switch byte {
            case UInt8(ascii: "a") ... UInt8(ascii: "z"),
                 UInt8(ascii: "A") ... UInt8(ascii: "Z"),
                 UInt8(ascii: "0") ... UInt8(ascii: "9"),
                 UInt8(ascii: "_"),
                 UInt8(ascii: "-"):
                advance(1)

            case UInt8(ascii: "\\"), 0x00:
                // Switch to slow path for escapes
                var valueBytes = Array(sliceFrom(startPos).utf8)
                return consumeNameSlow(bytes: &valueBytes)

            case 0x80 ... 0xBF:
                currentLineStartPosition = currentLineStartPosition &+ 1
                position += 1

            case 0xC0 ... 0xEF:
                advance(1)

            case 0xF0 ... 0xFF:
                currentLineStartPosition = currentLineStartPosition &- 1
                position += 1

            default:
                return Lexeme(sliceFrom(startPos))
            }
        }

        return Lexeme(sliceFrom(startPos))
    }

    func consumeNameSlow(bytes: inout [UInt8]) -> Lexeme {
        loop: while !isEOF() {
            let byte = nextByteUnchecked()
            switch byte {
            case UInt8(ascii: "a") ... UInt8(ascii: "z"),
                 UInt8(ascii: "A") ... UInt8(ascii: "Z"),
                 UInt8(ascii: "0") ... UInt8(ascii: "9"),
                 UInt8(ascii: "_"),
                 UInt8(ascii: "-"):
                advance(1)
                bytes.append(byte)

            case UInt8(ascii: "\\"):
                if hasNewlineAt(1) { break loop }
                advance(1)
                consumeEscapeAndWrite(into: &bytes)

            case 0x00:
                advance(1)
                bytes.append(contentsOf: "\u{FFFD}".utf8)

            case 0x80 ... 0xBF:
                currentLineStartPosition = currentLineStartPosition &+ 1
                position += 1
                bytes.append(byte)

            case 0xC0 ... 0xEF:
                advance(1)
                bytes.append(byte)

            case 0xF0 ... 0xFF:
                currentLineStartPosition = currentLineStartPosition &- 1
                position += 1
                bytes.append(byte)

            default:
                break loop
            }
        }

        return Lexeme(owned: String(decoding: bytes, as: UTF8.self))
    }

    func consumeNumeric() -> Token {
        let startPos = position
        var hasSign = false
        var isInteger = true

        let byte = nextByteUnchecked()
        if byte == UInt8(ascii: "-") {
            hasSign = true
            advance(1)
        } else if byte == UInt8(ascii: "+") {
            hasSign = true
            advance(1)
        }

        // Consume integral part
        while !isEOF(), nextByteUnchecked().isAsciiDigit {
            advance(1)
        }

        // Check for decimal point followed by digits
        if hasAtLeast(1), nextByteUnchecked() == UInt8(ascii: "."), byteAt(1).isAsciiDigit {
            isInteger = false
            advance(1) // consume '.'
            while !isEOF(), nextByteUnchecked().isAsciiDigit {
                advance(1)
            }
        }

        // Check for exponent
        if hasAtLeast(1) {
            let expByte = nextByteUnchecked()
            if expByte == UInt8(ascii: "e") || expByte == UInt8(ascii: "E") {
                let next = byteAt(1)
                if next.isAsciiDigit ||
                    (hasAtLeast(2) && (next == UInt8(ascii: "+") || next == UInt8(ascii: "-")) && byteAt(2).isAsciiDigit)
                {
                    isInteger = false
                    advance(1) // consume 'e' or 'E'
                    if nextByteUnchecked() == UInt8(ascii: "-") || nextByteUnchecked() == UInt8(ascii: "+") {
                        advance(1)
                    }
                    while !isEOF(), nextByteUnchecked().isAsciiDigit {
                        advance(1)
                    }
                }
            }
        }

        // Extract the numeric string and parse it
        let numericEndPos = position
        let startIndex = input.utf8.index(input.startIndex, offsetBy: startPos)
        let endIndex = input.utf8.index(input.startIndex, offsetBy: numericEndPos)
        let numericString = String(input[startIndex ..< endIndex])

        let value = Double(numericString) ?? 0.0

        // Clamp integer value to Int32 bounds, being careful about overflow
        let intValue: Int32? = if isInteger {
            if value >= Double(Int32.max) {
                Int32.max
            } else if value <= Double(Int32.min) {
                Int32.min
            } else {
                Int32(value)
            }
        } else {
            nil
        }

        let repr = Lexeme(numericString)

        // Check for percentage
        if !isEOF(), nextByteUnchecked() == UInt8(ascii: "%") {
            advance(1)
            let numeric = NumericValue(hasSign: hasSign, value: value / 100.0, intValue: intValue, repr: repr)
            return .percentage(numeric)
        }

        // Check for dimension
        if isIdentStart() {
            let unit = consumeName()
            let numeric = NumericValue(hasSign: hasSign, value: value, intValue: intValue, repr: repr)
            return .dimension(numeric, unit: unit)
        }

        let numeric = NumericValue(hasSign: hasSign, value: value, intValue: intValue, repr: repr)
        return .number(numeric)
    }

    func consumeUnquotedUrl() -> Token? {
        // Called after "url("
        let startPosition = position

        // Skip whitespace before URL content
        var newlines: UInt32 = 0
        var lastNewline = 0

        while !isEOF() {
            let byte = nextByteUnchecked()
            switch byte {
            case UInt8(ascii: " "), UInt8(ascii: "\t"):
                advance(1)

            case UInt8(ascii: "\n"), 0x0C:
                newlines += 1
                lastNewline = position
                advance(1)

            case UInt8(ascii: "\r"):
                newlines += 1
                advance(1)
                if nextByte() == UInt8(ascii: "\n") {
                    advance(1)
                }
                lastNewline = position - 1 // Position of the last newline character

            case UInt8(ascii: "\""), UInt8(ascii: "'"):
                // Quoted URL - return nil to fall back to function token
                position = startPosition
                return nil

            case UInt8(ascii: ")"):
                advance(1)
                if newlines > 0 {
                    currentLineNumber += newlines
                    currentLineStartPosition = lastNewline + 1
                }
                return .unquotedUrl(Lexeme(""))

            default:
                if newlines > 0 {
                    currentLineNumber += newlines
                    currentLineStartPosition = lastNewline + 1
                }
                return consumeUnquotedUrlInternal()
            }
        }

        if newlines > 0 {
            currentLineNumber += newlines
            currentLineStartPosition = lastNewline + 1
        }
        pendingErrorToken = .eofInUrl
        return .unquotedUrl(Lexeme(""))
    }

    func consumeUnquotedUrlInternal() -> Token {
        let startPos = currentPosition()

        // Fast path
        while !isEOF() {
            let byte = nextByteUnchecked()
            switch byte {
            case UInt8(ascii: " "), UInt8(ascii: "\t"),
                 UInt8(ascii: "\n"), UInt8(ascii: "\r"), 0x0C:
                let value = sliceFrom(startPos)
                return consumeUrlEnd(startPos: startPos, value: Lexeme(value))

            case UInt8(ascii: ")"):
                let value = sliceFrom(startPos)
                advance(1)
                return .unquotedUrl(Lexeme(value))

            case 0x01 ... 0x08, 0x0B, 0x0E ... 0x1F, 0x7F,
                 UInt8(ascii: "\""), UInt8(ascii: "'"), UInt8(ascii: "("):
                advance(1)
                return consumeBadUrl(startPos: startPos)

            case UInt8(ascii: "\\"), 0x00:
                var stringBytes = Array(sliceFrom(startPos).utf8)
                return consumeUnquotedUrlSlow(startPos: startPos, bytes: &stringBytes)

            case 0x80 ... 0xBF:
                currentLineStartPosition = currentLineStartPosition &+ 1
                position += 1

            case 0xF0 ... 0xFF:
                currentLineStartPosition = currentLineStartPosition &- 1
                position += 1

            default:
                advance(1)
            }
        }

        pendingErrorToken = .eofInUrl
        return .unquotedUrl(Lexeme(sliceFrom(startPos)))
    }

    func consumeUnquotedUrlSlow(startPos: SourcePosition, bytes: inout [UInt8]) -> Token {
        while !isEOF() {
            let byte = nextByteUnchecked()
            switch byte {
            case UInt8(ascii: " "), UInt8(ascii: "\t"),
                 UInt8(ascii: "\n"), UInt8(ascii: "\r"), 0x0C:
                let string = Lexeme(owned: String(decoding: bytes, as: UTF8.self))
                return consumeUrlEnd(startPos: startPos, value: string)

            case UInt8(ascii: ")"):
                advance(1)
                return .unquotedUrl(Lexeme(owned: String(decoding: bytes, as: UTF8.self)))

            case 0x01 ... 0x08, 0x0B, 0x0E ... 0x1F, 0x7F,
                 UInt8(ascii: "\""), UInt8(ascii: "'"), UInt8(ascii: "("):
                advance(1)
                return consumeBadUrl(startPos: startPos)

            case UInt8(ascii: "\\"):
                advance(1)
                if hasNewlineAt(0) {
                    return consumeBadUrl(startPos: startPos)
                }
                consumeEscapeAndWrite(into: &bytes)

            case 0x00:
                advance(1)
                bytes.append(contentsOf: "\u{FFFD}".utf8)

            case 0x80 ... 0xBF:
                currentLineStartPosition = currentLineStartPosition &+ 1
                position += 1
                bytes.append(byte)

            case 0xF0 ... 0xFF:
                currentLineStartPosition = currentLineStartPosition &- 1
                position += 1
                bytes.append(byte)

            default:
                advance(1)
                bytes.append(byte)
            }
        }

        pendingErrorToken = .eofInUrl
        return .unquotedUrl(Lexeme(owned: String(decoding: bytes, as: UTF8.self)))
    }

    func consumeUrlEnd(startPos: SourcePosition, value: Lexeme) -> Token {
        while !isEOF() {
            let byte = nextByteUnchecked()
            switch byte {
            case UInt8(ascii: ")"):
                advance(1)
                return .unquotedUrl(value)

            case UInt8(ascii: " "), UInt8(ascii: "\t"):
                advance(1)

            case UInt8(ascii: "\n"), UInt8(ascii: "\r"), 0x0C:
                consumeNewline()

            default:
                consumeKnownByte(byte)
                return consumeBadUrl(startPos: startPos)
            }
        }

        pendingErrorToken = .eofInUrl
        return .unquotedUrl(value)
    }

    func consumeBadUrl(startPos: SourcePosition) -> Token {
        while !isEOF() {
            let byte = nextByteUnchecked()
            switch byte {
            case UInt8(ascii: ")"):
                let contents = sliceFrom(startPos)
                advance(1)
                return .badUrl(Lexeme(contents))

            case UInt8(ascii: "\\"):
                advance(1)
                if let next = nextByte(), next == UInt8(ascii: ")") || next == UInt8(ascii: "\\") {
                    advance(1)
                }

            case UInt8(ascii: "\n"), UInt8(ascii: "\r"), 0x0C:
                consumeNewline()

            default:
                consumeKnownByte(byte)
            }
        }

        return .badUrl(Lexeme(sliceFrom(startPos)))
    }

    // MARK: - Escape Handling

    func consumeEscapeAndWrite(into bytes: inout [UInt8]) {
        var buf = [UInt8](repeating: 0, count: 4)
        let char = consumeEscape()
        let len = char.utf8.count
        _ = char.utf8.withContiguousStorageIfAvailable { utf8Bytes in
            for i in 0 ..< len {
                buf[i] = utf8Bytes[i]
            }
        }
        bytes.append(contentsOf: buf.prefix(len))
    }

    func consumeEscape() -> Character {
        guard !isEOF() else { return "\u{FFFD}" }

        let byte = nextByteUnchecked()
        switch byte {
        case UInt8(ascii: "0") ... UInt8(ascii: "9"),
             UInt8(ascii: "A") ... UInt8(ascii: "F"),
             UInt8(ascii: "a") ... UInt8(ascii: "f"):
            let (codePoint, _) = consumeHexDigits()

            // Consume optional whitespace after hex escape
            if !isEOF() {
                let next = nextByteUnchecked()
                if next == UInt8(ascii: " ") || next == UInt8(ascii: "\t") {
                    advance(1)
                } else if next == UInt8(ascii: "\n") || next == UInt8(ascii: "\r") || next == 0x0C {
                    consumeNewline()
                }
            }

            if codePoint != 0, let scalar = UnicodeScalar(codePoint) {
                return Character(scalar)
            }
            return "\u{FFFD}"

        case 0x00:
            advance(1)
            return "\u{FFFD}"

        default:
            return consumeChar()
        }
    }

    func consumeHexDigits() -> (UInt32, Int) {
        var value: UInt32 = 0
        var digits = 0

        while digits < 6, !isEOF() {
            let byte = nextByteUnchecked()
            if let digit = hexDigitValue(byte) {
                value = value * 16 + digit
                digits += 1
                advance(1)
            } else {
                break
            }
        }

        return (value, digits)
    }
}

// MARK: - TokenizerState

/// Saved state of the tokenizer for backtracking.
struct TokenizerState: Equatable, Sendable {
    let position: Int

    let currentLineStartPosition: Int

    let currentLineNumber: UInt32
}

// MARK: - Helper Functions

func isNewline(_ byte: UInt8) -> Bool {
    byte == UInt8(ascii: "\n") || byte == UInt8(ascii: "\r") || byte == 0x0C
}

func hexDigitValue(_ byte: UInt8) -> UInt32? {
    switch byte {
    case UInt8(ascii: "0") ... UInt8(ascii: "9"):
        UInt32(byte - UInt8(ascii: "0"))
    case UInt8(ascii: "a") ... UInt8(ascii: "f"):
        UInt32(byte - UInt8(ascii: "a") + 10)
    case UInt8(ascii: "A") ... UInt8(ascii: "F"):
        UInt32(byte - UInt8(ascii: "A") + 10)
    default:
        nil
    }
}

// MARK: - UInt8 Extensions

extension UInt8 {
    var isASCII: Bool {
        self < 0x80
    }

    var isAsciiDigit: Bool {
        self >= UInt8(ascii: "0") && self <= UInt8(ascii: "9")
    }

    var isAsciiHexDigit: Bool {
        (self >= UInt8(ascii: "0") && self <= UInt8(ascii: "9")) ||
            (self >= UInt8(ascii: "a") && self <= UInt8(ascii: "f")) ||
            (self >= UInt8(ascii: "A") && self <= UInt8(ascii: "F"))
    }

    var hexDigitValue: UInt32? {
        switch self {
        case UInt8(ascii: "0") ... UInt8(ascii: "9"):
            UInt32(self - UInt8(ascii: "0"))
        case UInt8(ascii: "a") ... UInt8(ascii: "f"):
            UInt32(self - UInt8(ascii: "a") + 10)
        case UInt8(ascii: "A") ... UInt8(ascii: "F"):
            UInt32(self - UInt8(ascii: "A") + 10)
        default:
            nil
        }
    }
}
