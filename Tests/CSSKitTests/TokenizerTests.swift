// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("Tokenizer Tests")
struct TokenizerTests {
    @Test("Unquoted URL escaping")
    func unquotedUrlEscaping() throws {
        let urlContent = "\u{01}\u{02}\u{03}\u{04}\u{05}\u{06}\u{07}\u{08}\t\n\u{0B}\u{0C}\r\u{0E}\u{0F}\u{10}" +
            "\u{11}\u{12}\u{13}\u{14}\u{15}\u{16}\u{17}\u{18}\u{19}\u{1A}\u{1B}\u{1C}\u{1D}\u{1E}\u{1F} " +
            "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]" +
            "^_`abcdefghijklmnopqrstuvwxyz{|}~\u{7F}é"

        let token = Token.unquotedUrl(Lexeme(urlContent))
        let serialized = token.string

        let expected = "url(" +
            "\\1 \\2 \\3 \\4 \\5 \\6 \\7 \\8 \\9 \\a \\b \\c \\d \\e \\f \\10 " +
            "\\11 \\12 \\13 \\14 \\15 \\16 \\17 \\18 \\19 \\1a \\1b \\1c \\1d \\1e \\1f \\20 " +
            "!\\\"#$%&\\'\\(\\)*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\\\]" +
            "^_`abcdefghijklmnopqrstuvwxyz{|}~\\7f é" +
            ")"

        #expect(serialized == expected)

        // Verify round-trip
        let input = ParserInput(serialized)
        let parser = Parser(input)
        if case let .success(parsedToken) = parser.next() {
            #expect(parsedToken == token)
        } else {
            Issue.record("Failed to parse serialized URL")
        }
    }

    @Test("Roundtrip percentage token")
    func roundtripPercentageToken() throws {
        func testRoundtrip(_ value: String) {
            let input = ParserInput(value)
            let parser = Parser(input)
            if case let .success(token) = parser.next() {
                #expect(token.string == value, "Roundtrip failed for \(value)")
            }
        }

        // Test simple number serialization
        for i in 0 ... 100 {
            testRoundtrip("\(i)%")
            for j in 0 ..< 10 {
                if j != 0 {
                    testRoundtrip("\(i).\(j)%")
                }
                for k in 1 ..< 10 {
                    testRoundtrip("\(i).\(j)\(k)%")
                }
            }
        }
    }
}
