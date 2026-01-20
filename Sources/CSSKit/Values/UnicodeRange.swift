// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// https://drafts.csswg.org/css-syntax/#urange

/// One contiguous range of Unicode code points.
struct UnicodeRange: Equatable, Hashable, Sendable {
    /// Inclusive start of the range. In [0, end].
    let start: UInt32

    /// Inclusive end of the range. In [0, 0x10FFFF].
    let end: UInt32

    /// Maximum valid Unicode code point.
    static let maxCodePoint: UInt32 = 0x10FFFF

    /// https://drafts.csswg.org/css-syntax/#urange-syntax
    static func parse(_ input: Parser) -> Result<Self, BasicParseError> {
        // <urange> =
        //   u '+' <ident-token> '?'* |
        //   u <dimension-token> '?'* |
        //   u <number-token> '?'* |
        //   u <number-token> <dimension-token> |
        //   u <number-token> <number-token> |
        //   u '+' '?'+

        guard case .success = input.expectIdentMatching("u") else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let afterU = input.position()

        guard case .success = parseTokens(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // NOTE: Includes comments between tokens, which deviates from spec but
        // is acceptable since comments in unicode-range are extremely rare.
        let concatenatedTokens = input.sliceFrom(afterU)

        guard let range = parseConcatenated(Array(concatenatedTokens.utf8)) else {
            return .failure(input.newBasicUnexpectedTokenError(.ident(Lexeme(concatenatedTokens))))
        }

        if range.end > Self.maxCodePoint || range.start > range.end {
            return .failure(input.newBasicUnexpectedTokenError(.ident(Lexeme(concatenatedTokens))))
        }

        return .success(range)
    }
}

/// Parses the tokens after 'u'.
private func parseTokens(_ input: Parser) -> Result<Void, BasicParseError> {
    switch input.nextIncludingWhitespace() {
    case let .failure(error):
        return .failure(error)

    case .success(.delim("+")):
        switch input.nextIncludingWhitespace() {
        case .success(.ident):
            break
        case .success(.delim("?")):
            break
        case let .success(token):
            return .failure(input.newBasicUnexpectedTokenError(token))
        case let .failure(error):
            return .failure(error)
        }
        parseQuestionMarks(input)
        return .success(())

    case .success(.dimension):
        parseQuestionMarks(input)
        return .success(())

    case .success(.number):
        let afterNumber = input.state()
        switch input.nextIncludingWhitespace() {
        case .success(.delim("?")):
            parseQuestionMarks(input)
        case .success(.dimension):
            break
        case .success(.number):
            break
        default:
            input.reset(afterNumber)
        }
        return .success(())

    case let .success(token):
        return .failure(input.newBasicUnexpectedTokenError(token))
    }
}

/// Consume as many '?' as possible.
private func parseQuestionMarks(_ input: Parser) {
    while true {
        let start = input.state()
        switch input.nextIncludingWhitespace() {
        case .success(.delim("?")):
            continue
        default:
            input.reset(start)
            return
        }
    }
}

/// Parses the concatenated token text.
private func parseConcatenated(_ bytes: [UInt8]) -> UnicodeRange? {
    var text = bytes[...]

    // Must start with '+'
    guard text.first == UInt8(ascii: "+") else {
        return nil
    }
    text = text.dropFirst()

    let (firstHexValue, hexDigitCount) = consumeHex(&text, digitLimit: 6)
    let questionMarks = consumeQuestionMarks(&text)
    let consumed = hexDigitCount + questionMarks

    if consumed == 0 || consumed > 6 {
        return nil
    }

    if questionMarks > 0 {
        if text.isEmpty {
            let start = firstHexValue << (questionMarks * 4)
            let end = ((firstHexValue + 1) << (questionMarks * 4)) - 1
            return UnicodeRange(start: start, end: end)
        }
    } else if text.isEmpty {
        return UnicodeRange(start: firstHexValue, end: firstHexValue)
    } else if text.first == UInt8(ascii: "-") {
        text = text.dropFirst()
        let (secondHexValue, hexDigitCount2) = consumeHex(&text, digitLimit: 6)
        if hexDigitCount2 > 0, hexDigitCount2 <= 6, text.isEmpty {
            return UnicodeRange(start: firstHexValue, end: secondHexValue)
        }
    }

    return nil
}

/// Consume hex digits, returning the value and count.
private func consumeHex(_ text: inout ArraySlice<UInt8>, digitLimit: Int) -> (UInt32, Int) {
    var value: UInt32 = 0
    var digits = 0

    while let byte = text.first, let digitValue = hexDigitValue(byte) {
        if digits == digitLimit {
            // Don't consume more than the limit - let the caller handle it
            break
        }
        value = value * 0x10 + digitValue
        digits += 1
        text = text.dropFirst()
    }

    return (value, digits)
}

/// Consume question marks, returning the count.
private func consumeQuestionMarks(_ text: inout ArraySlice<UInt8>) -> Int {
    var count = 0
    while text.first == UInt8(ascii: "?") {
        count += 1
        text = text.dropFirst()
    }
    return count
}

// MARK: - CustomDebugStringConvertible

extension UnicodeRange: CustomDebugStringConvertible {
    var debugDescription: String {
        string()
    }
}

// MARK: - ToCss

extension UnicodeRange: CSSSerializable {
    func serialize(dest: inout some CSSWriter) {
        dest.write("U+")
        dest.write(String(start, radix: 16, uppercase: true))
        if end != start {
            dest.write("-")
            dest.write(String(end, radix: 16, uppercase: true))
        }
    }
}
