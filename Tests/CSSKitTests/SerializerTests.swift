// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("Serializer Tests")
struct SerializerTests {
    @Test("Serializer not preserving comments")
    func serializerNotPreservingComments() throws {
        try runSerializerTest(preserveComments: false)
    }

    @Test("Serializer preserving comments")
    func serializerPreservingComments() throws {
        try runSerializerTest(preserveComments: true)
    }

    private func runSerializerTest(preserveComments: Bool) throws {
        let testData = try loadTestData("component_value_list")
        runJsonTests(testData) { input in
            var serialized = ""
            var previousToken = TokenSerializationType.nothing
            writeTokens(
                previousToken: &previousToken,
                input: input,
                string: &serialized,
                preserveComments: preserveComments
            )

            let newInput = ParserInput(serialized)
            let newParser = Parser(newInput)
            return .array(componentValuesToJson(newParser))
        }
    }

    @discardableResult
    private func writeTokens(
        previousToken: inout TokenSerializationType,
        input: Parser,
        string: inout String,
        preserveComments: Bool
    ) -> Bool {
        var sawEofTerminated = false

        while true {
            let tokenResult = preserveComments
                ? input.nextIncludingWhitespaceAndComments()
                : input.nextIncludingWhitespace()

            guard case let .success(token) = tokenResult else { break }

            if case .eofInString = token {
                sawEofTerminated = true
                continue
            }
            if case .eofInUrl = token {
                sawEofTerminated = true
                continue
            }

            let tokenType = token.serializationType
            if previousToken.needsSeparatorWhenBefore(tokenType) {
                string += "/**/"
            }
            previousToken = tokenType

            switch token {
            case let .quotedString(value):
                if input.input.tokenizer.pendingErrorToken == .eofInString {
                    string += "\""
                    var writer = StringCSSWriter()
                    serializeStringContents(value.value, dest: &writer)
                    string += writer.result
                } else {
                    var writer = StringCSSWriter()
                    token.serialize(dest: &writer)
                    string += writer.result
                }

            case let .unquotedUrl(value):
                if input.input.tokenizer.pendingErrorToken == .eofInUrl {
                    string += "url("
                    var writer = StringCSSWriter()
                    serializeUnquotedUrl(value.value, dest: &writer)
                    string += writer.result
                } else {
                    var writer = StringCSSWriter()
                    token.serialize(dest: &writer)
                    string += writer.result
                }

            default:
                var writer = StringCSSWriter()
                token.serialize(dest: &writer)
                string += writer.result
            }

            let closingToken: Token? = switch token {
            case .function, .parenthesisBlock:
                .closeParenthesis
            case .squareBracketBlock:
                .closeSquareBracket
            case .curlyBracketBlock:
                .closeCurlyBracket
            default:
                nil
            }

            if let closing = closingToken {
                var nestedSawEof = false
                let _: Result<Void, ParseError<Never>> = input.parseNestedBlock { nested in
                    nestedSawEof = writeTokens(
                        previousToken: &previousToken,
                        input: nested,
                        string: &string,
                        preserveComments: preserveComments
                    )
                    return .success(())
                }
                if !nestedSawEof {
                    var writer = StringCSSWriter()
                    closing.serialize(dest: &writer)
                    string += writer.result
                } else {
                    sawEofTerminated = true
                }
            }
        }

        return sawEofTerminated
    }

    @Test("Serialize bad tokens")
    func serializeBadTokens() throws {
        let input = ParserInput("url(foo\\) b\\)ar)'ba\\'\"z\n4")
        let parser = Parser(input)

        if case let .success(token) = parser.next() {
            if case .badUrl = token {
                #expect(token.string() == "url(foo\\) b\\)ar)")
            } else {
                Issue.record("Expected BadUrl token")
            }
        }

        if case let .success(token) = parser.next() {
            if case .badString = token {
                #expect(token.string() == "\"ba'\\\"z")
            } else {
                Issue.record("Expected BadString token")
            }
        }

        if case let .success(token) = parser.next() {
            if case .number = token {
                #expect(token.string() == "4")
            } else {
                Issue.record("Expected Number token")
            }
        }

        #expect(parser.next().isFailure)
    }

    @Test("Identifier serialization")
    func identifierSerialization() throws {
        #expect(Token.ident(Lexeme("\0")).string() == "\u{FFFD}")
        #expect(Token.ident(Lexeme("a\0")).string() == "a\u{FFFD}")
        #expect(Token.ident(Lexeme("\0b")).string() == "\u{FFFD}b")
        #expect(Token.ident(Lexeme("a\0b")).string() == "a\u{FFFD}b")

        #expect(Token.ident(Lexeme("\u{FFFD}")).string() == "\u{FFFD}")
        #expect(Token.ident(Lexeme("a\u{FFFD}")).string() == "a\u{FFFD}")
        #expect(Token.ident(Lexeme("\u{FFFD}b")).string() == "\u{FFFD}b")
        #expect(Token.ident(Lexeme("a\u{FFFD}b")).string() == "a\u{FFFD}b")

        #expect(Token.ident(Lexeme("0a")).string() == "\\30 a")
        #expect(Token.ident(Lexeme("1a")).string() == "\\31 a")
        #expect(Token.ident(Lexeme("2a")).string() == "\\32 a")
        #expect(Token.ident(Lexeme("3a")).string() == "\\33 a")
        #expect(Token.ident(Lexeme("4a")).string() == "\\34 a")
        #expect(Token.ident(Lexeme("5a")).string() == "\\35 a")
        #expect(Token.ident(Lexeme("6a")).string() == "\\36 a")
        #expect(Token.ident(Lexeme("7a")).string() == "\\37 a")
        #expect(Token.ident(Lexeme("8a")).string() == "\\38 a")
        #expect(Token.ident(Lexeme("9a")).string() == "\\39 a")

        #expect(Token.ident(Lexeme("a0b")).string() == "a0b")

        #expect(Token.ident(Lexeme("-0a")).string() == "-\\30 a")
        #expect(Token.ident(Lexeme("-1a")).string() == "-\\31 a")

        #expect(Token.ident(Lexeme("--a")).string() == "--a")
    }
}
