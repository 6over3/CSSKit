// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("Parser Tests")
struct ParserTests {
    @Test("Expect no error token")
    func expectNoErrorToken() throws {
        let input1 = ParserInput("foo 4px ( / { !bar }")
        let parser1 = Parser(input1)
        #expect(parser1.expectNoErrorToken().isSuccess)

        let input2 = ParserInput(")")
        let parser2 = Parser(input2)
        #expect(parser2.expectNoErrorToken().isFailure)

        let input3 = ParserInput("}")
        let parser3 = Parser(input3)
        #expect(parser3.expectNoErrorToken().isFailure)

        let input4 = ParserInput("(a){]")
        let parser4 = Parser(input4)
        #expect(parser4.expectNoErrorToken().isFailure)

        let input5 = ParserInput("'\n'")
        let parser5 = Parser(input5)
        #expect(parser5.expectNoErrorToken().isFailure)

        let input6 = ParserInput("url('\n'")
        let parser6 = Parser(input6)
        #expect(parser6.expectNoErrorToken().isFailure)

        let input7 = ParserInput("url(a b)")
        let parser7 = Parser(input7)
        #expect(parser7.expectNoErrorToken().isFailure)

        let input8 = ParserInput("url(\u{7F}))")
        let parser8 = Parser(input8)
        #expect(parser8.expectNoErrorToken().isFailure)
    }

    @Test("Outer block end consumed")
    func outerBlockEndConsumed() throws {
        let input = ParserInput("(calc(true))")
        let parser = Parser(input)

        #expect(parser.expectParenthesisBlock().isSuccess)

        let result: Result<Void, ParseError<Never>> = parser.parseNestedBlock { inner in
            inner.expectFunctionMatching("calc").mapError { $0.asParseError() }.map { _ in () }
        }
        #expect(result.isSuccess)

        #expect(parser.next().isFailure)
    }

    @Test("Bad URL slice out of bounds")
    func badUrlSliceOutOfBounds() throws {
        let input = ParserInput("url(\u{1}\\")
        let parser = Parser(input)

        if case let .success(token) = parser.nextIncludingWhitespaceAndComments() {
            if case let .badUrl(value) = token {
                #expect(value.value == "\u{1}\\")
            } else {
                Issue.record("Expected BadUrl token")
            }
        } else {
            Issue.record("Expected token")
        }
    }

    @Test("Bad URL slice not at char boundary")
    func badUrlSliceNotAtCharBoundary() throws {
        let input = ParserInput("url(9\n۰")
        let parser = Parser(input)

        if case let .success(token) = parser.nextIncludingWhitespaceAndComments() {
            if case let .badUrl(value) = token {
                #expect(value.value == "9\n۰")
            } else {
                Issue.record("Expected BadUrl token")
            }
        } else {
            Issue.record("Expected token")
        }
    }

    @Test("Expect URL")
    func testExpectUrl() throws {
        func parse(_ s: String) -> Result<Lexeme, BasicParseError> {
            let input = ParserInput(s)
            return Parser(input).expectUrl()
        }

        #expect((try? parse("url()").get())?.value == "")
        #expect((try? parse("url( ").get())?.value == "")
        #expect((try? parse("url( abc").get())?.value == "abc")
        #expect((try? parse("url( abc \t)").get())?.value == "abc")
        #expect((try? parse("url( 'abc' \t)").get())?.value == "abc")
        #expect(parse("url(abc more stuff)").isFailure)
        #expect(parse("url('abc' more stuff)").isFailure)
    }

    @Test("Line numbers")
    func lineNumbers() throws {
        let css = "fo\\30\r\n0o bar/*\n*/baz\r\n\nurl(\r\n  u \r\n)\"a\\\r\nb\""
        let input = ParserInput(css)
        let parser = Parser(input)

        #expect(parser.currentSourceLocation() == SourceLocation(line: 0, column: 1))

        if case let .success(.ident(v)) = parser.nextIncludingWhitespace() {
            #expect(v.value == "fo00o")
        }
        #expect(parser.currentSourceLocation() == SourceLocation(line: 1, column: 3))

        if case .success(.whiteSpace) = parser.nextIncludingWhitespace() {}
        #expect(parser.currentSourceLocation() == SourceLocation(line: 1, column: 4))

        if case let .success(.ident(v)) = parser.nextIncludingWhitespace() {
            #expect(v.value == "bar")
        }
        #expect(parser.currentSourceLocation() == SourceLocation(line: 1, column: 7))

        if case .success(.comment) = parser.nextIncludingWhitespaceAndComments() {}
        #expect(parser.currentSourceLocation() == SourceLocation(line: 2, column: 3))

        if case let .success(.ident(v)) = parser.nextIncludingWhitespace() {
            #expect(v.value == "baz")
        }
        #expect(parser.currentSourceLocation() == SourceLocation(line: 2, column: 6))

        let state = parser.state()

        if case .success(.whiteSpace) = parser.nextIncludingWhitespace() {}
        #expect(parser.currentSourceLocation() == SourceLocation(line: 4, column: 1))

        #expect(state.sourceLocation() == SourceLocation(line: 2, column: 6))

        if case let .success(.unquotedUrl(v)) = parser.nextIncludingWhitespace() {
            #expect(v.value == "u")
        }
        #expect(parser.currentSourceLocation() == SourceLocation(line: 6, column: 2))

        if case let .success(.quotedString(v)) = parser.nextIncludingWhitespace() {
            #expect(v.value == "ab")
        }
        #expect(parser.currentSourceLocation() == SourceLocation(line: 7, column: 3))

        #expect(parser.nextIncludingWhitespace().isFailure)
    }

    @Test("Overflow")
    func overflow() throws {
        let css = """
        2147483646
        2147483647
        2147483648
        10000000000000
        1000000000000000000000000000000000000000
        1\(String(repeating: "0", count: 309))

        -2147483647
        -2147483648
        -2147483649
        -10000000000000
        -1000000000000000000000000000000000000000
        -1\(String(repeating: "0", count: 309))

        3.30282347e+38
        1.7976931348623157e+308
        1.8e+308

        -3.30282347e+38
        -1.7976931348623157e+308
        -1.8e+308
        """
        let input = ParserInput(css)
        let parser = Parser(input)

        #expect((try? parser.expectInteger().get()) == 2_147_483_646)
        #expect((try? parser.expectInteger().get()) == 2_147_483_647)
        #expect((try? parser.expectInteger().get()) == 2_147_483_647) // Clamp on overflow
        #expect((try? parser.expectInteger().get()) == 2_147_483_647)
        #expect((try? parser.expectInteger().get()) == 2_147_483_647)
        #expect((try? parser.expectInteger().get()) == 2_147_483_647)

        #expect((try? parser.expectInteger().get()) == -2_147_483_647)
        #expect((try? parser.expectInteger().get()) == -2_147_483_648)
        #expect((try? parser.expectInteger().get()) == -2_147_483_648) // Clamp on overflow
        #expect((try? parser.expectInteger().get()) == -2_147_483_648)
        #expect((try? parser.expectInteger().get()) == -2_147_483_648)
        #expect((try? parser.expectInteger().get()) == -2_147_483_648)

        #expect((try? parser.expectNumber().get()) == 3.30282347e38)
        #expect((try? parser.expectNumber().get()) == Double.greatestFiniteMagnitude)
        #expect((try? parser.expectNumber().get()) == Double.infinity)

        #expect((try? parser.expectNumber().get()) == -3.30282347e38)
        #expect((try? parser.expectNumber().get()) == -Double.greatestFiniteMagnitude)
        #expect((try? parser.expectNumber().get()) == -Double.infinity)
    }

    @Test("Line delimited")
    func lineDelimited() throws {
        let input = ParserInput(" { foo ; bar } baz;,")
        let parser = Parser(input)

        #expect(parser.next() == .success(.curlyBracketBlock))

        let result: Result<Int, ParseError<Never>> = parser.parseUntilAfter(.semicolon) { _ in .success(42) }
        #expect(result.isFailure)

        #expect(parser.next() == .success(.comma))
        #expect(parser.next().isFailure)
    }

    @Test("Parse until before stops at delimiter or end of input")
    func parseUntilBeforeStopsAtDelimiterOrEndOfInput() throws {
        let inputs: [(Delimiters, [String])] = [
            ([.bang, .semicolon], ["token stream;extra", "token stream!", "token stream"]),
            ([.bang, .semicolon], [";", "!", ""]),
        ]

        for equivalent in inputs {
            for (j, x) in equivalent.1.enumerated() {
                for y in equivalent.1[(j + 1)...] {
                    let ix = ParserInput(x)
                    let parserX = Parser(ix)

                    let iy = ParserInput(y)
                    let parserY = Parser(iy)

                    let _: Result<Void, ParseError<Never>> = parserX.parseUntilBefore(equivalent.0) { px in
                        let _: Result<Void, ParseError<Never>> = parserY.parseUntilBefore(equivalent.0) { py in
                            while true {
                                let ox = px.next()
                                let oy = py.next()
                                #expect(tokenEquals(ox, oy))
                                if ox.isFailure { break }
                            }
                            return .success(())
                        }
                        return .success(())
                    }
                }
            }
        }
    }

    @Test("CDC regression test")
    func cdcRegressionTest() throws {
        let input = ParserInput("-->x")
        let parser = Parser(input)
        parser.skipCdcAndCdo()
        #expect(parser.next() == .success(.ident(Lexeme("x"))))
        #expect(parser.next().isFailure)
    }

    @Test("UTF-16 columns")
    func utf16Columns() throws {
        let tests: [(String, UInt32)] = [
            ("", 1),
            ("ascii", 6),
            ("/*QΡ✈🆒*/", 10),
            ("'QΡ✈🆒*'", 9),
            ("\"\\\"'QΡ✈🆒*'", 12),
            ("\\Q\\Ρ\\✈\\🆒", 10),
            ("QΡ✈🆒", 6),
            ("QΡ✈🆒\\Q\\Ρ\\✈\\🆒", 15),
            ("newline\r\nQΡ✈🆒", 6),
            ("url(QΡ✈🆒\\Q\\Ρ\\✈\\🆒)", 20),
            ("url(QΡ✈🆒)", 11),
            ("url(\r\nQΡ✈🆒\\Q\\Ρ\\✈\\🆒)", 16),
            ("url(\r\nQΡ✈🆒\\Q\\Ρ\\✈\\🆒", 15),
            ("url(\r\nQΡ✈🆒\\Q\\Ρ\\✈\\🆒 x", 17),
            ("QΡ✈🆒()", 8),
            ("🆒", 3),
        ]

        for (css, expectedColumn) in tests {
            let input = ParserInput(css)
            let parser = Parser(input)
            while case .success = parser.next() {}
            #expect(parser.currentSourceLocation().column == expectedColumn,
                    "Column mismatch for '\(css)': expected \(expectedColumn), got \(parser.currentSourceLocation().column)")
        }
    }

    @Test("No stack overflow with multiple nested blocks")
    func noStackOverflowMultipleNestedBlocks() throws {
        var css = "{{"
        for _ in 0 ..< 20 {
            css += css
        }

        let input = ParserInput(css)
        let parser = Parser(input)
        while case .success = parser.next() {}
    }

    @Test("Parse comma separated ignoring errors")
    func parseCommaSeparatedIgnoringErrors() throws {
        let css = "red, green something, yellow, whatever, blue"
        let input = ParserInput(css)
        let parser = Parser(input)

        let result: [RGBColor] = parser.parseCommaSeparatedIgnoringErrors { (p: Parser) -> Result<RGBColor, ParseError<Never>> in
            let loc = p.currentSourceLocation()
            switch p.expectIdent() {
            case let .success(ident):
                if let color = parseNamedColor(ident.value) {
                    return .success(color)
                } else {
                    return .failure(loc.newBasicUnexpectedTokenError(.ident(ident)).asParseError())
                }
            case let .failure(err):
                return .failure(err.asParseError())
            }
        }

        #expect(result.count == 3)
        #expect(result[0] == RGBColor(red: 255, green: 0, blue: 0)) // red
        #expect(result[1] == RGBColor(red: 255, green: 255, blue: 0)) // yellow
        #expect(result[2] == RGBColor(red: 0, green: 0, blue: 255)) // blue
    }

    @Test("Parse entirely reports first error")
    func parseEntirelyReportsFirstError() throws {
        enum TestError: Equatable {
            case foo
        }

        let input = ParserInput("ident")
        let parser = Parser(input)

        let result: Result<Void, ParseError<TestError>> = parser.parseEntirely { p in
            .failure(ParseError(kind: .custom(TestError.foo), location: p.currentSourceLocation()))
        }

        switch result {
        case .success:
            Issue.record("Expected failure")
        case let .failure(error):
            #expect(error.kind == .custom(TestError.foo))
            #expect(error.location == SourceLocation(line: 0, column: 1))
        }
    }

    @Test("Parser maintains current line")
    func parserMaintainsCurrentLine() throws {
        let input = ParserInput("ident ident;\nident ident ident;\nident")
        let parser = Parser(input)

        #expect(parser.currentLine == "ident ident;")
        #expect(parser.next() == .success(.ident(Lexeme("ident"))))
        #expect(parser.next() == .success(.ident(Lexeme("ident"))))
        #expect(parser.next() == .success(.semicolon))

        #expect(parser.next() == .success(.ident(Lexeme("ident"))))
        #expect(parser.currentLine == "ident ident ident;")
        #expect(parser.next() == .success(.ident(Lexeme("ident"))))
        #expect(parser.next() == .success(.ident(Lexeme("ident"))))
        #expect(parser.next() == .success(.semicolon))

        #expect(parser.next() == .success(.ident(Lexeme("ident"))))
        #expect(parser.currentLine == "ident")
    }
}

@Suite("Malicious Input Tests", .serialized)
struct MaliciousInputTests {
    @Test("No stack overflow with deeply nested media rules")
    func noStackOverflowDeeplyNestedMediaRules() {
        let depth = 1000
        var css = String(repeating: "@media screen { ", count: depth)
        css += "div { color: red; }"
        css += String(repeating: " }", count: depth)

        let stylesheet: Stylesheet<Never> = CSSParser(css).stylesheet
        #expect(stylesheet.rules.count >= 1)
    }

    @Test("No stack overflow with deeply nested supports rules")
    func noStackOverflowDeeplyNestedSupportsRules() {
        let depth = 1000
        var css = String(repeating: "@supports (display: flex) { ", count: depth)
        css += "div { display: flex; }"
        css += String(repeating: " }", count: depth)

        let stylesheet: Stylesheet<Never> = CSSParser(css).stylesheet
        #expect(stylesheet.rules.count >= 1)
    }

    @Test("No stack overflow with deeply nested supports conditions")
    func noStackOverflowDeeplyNestedSupportsConditions() {
        let depth = 1000
        var condition = "(display: flex)"
        for _ in 0 ..< depth {
            condition = "(not \(condition))"
        }
        let css = "@supports \(condition) { div { display: flex; } }"

        let stylesheet: Stylesheet<Never> = CSSParser(css).stylesheet
        #expect(stylesheet.rules.count == 1)
    }

    @Test("No stack overflow with deeply nested media conditions")
    func noStackOverflowDeeplyNestedMediaConditions() {
        let depth = 1000
        var condition = "(min-width: 100px)"
        for _ in 0 ..< depth {
            condition = "(not \(condition))"
        }
        let css = "@media \(condition) { div { color: red; } }"

        let stylesheet: Stylesheet<Never> = CSSParser(css).stylesheet
        #expect(stylesheet.rules.count == 1)

        // Also test serialization doesn't overflow
        let output = stylesheet.string()
        #expect(output.contains("@media"))
    }

    @Test("No stack overflow serializing deeply nested supports")
    func noStackOverflowDeeplyNestedSupportsSerialize() {
        let depth = 1000
        var condition = "(display: flex)"
        for _ in 0 ..< depth {
            condition = "(not \(condition))"
        }
        let css = "@supports \(condition) { div { display: flex; } }"

        let stylesheet: Stylesheet<Never> = CSSParser(css).stylesheet
        #expect(stylesheet.rules.count == 1)

        // Test serialization doesn't overflow
        let output = stylesheet.string()
        #expect(output.contains("@supports"))
    }

    @Test("No stack overflow simplifying deeply nested calc")
    func noStackOverflowDeeplyNestedCalcSimplify() {
        // Build deeply nested calc: calc(calc(calc(...calc(1 + 1)... + 1) + 1) + 1)
        var calc: CSSCalc<Double> = .number(1)
        for _ in 0 ..< 1000 {
            calc = .sum(calc, .number(1))
        }
        // Should simplify to 1001 without stack overflow
        let simplified = calc.simplified()
        if case let .number(n) = simplified {
            #expect(n == 1001)
        } else {
            Issue.record("Expected simplified to be a number")
        }
    }

    @Test("No stack overflow with deeply nested style rules")
    func noStackOverflowDeeplyNestedStyleRules() {
        let depth = 1000
        var css = "div { "
        css += String(repeating: "& span { ", count: depth)
        css += "color: red;"
        css += String(repeating: " }", count: depth)
        css += " }"

        let stylesheet: Stylesheet<Never> = CSSParser(css).stylesheet
        #expect(stylesheet.rules.count >= 1)
    }

    @Test("No stack overflow with deeply nested calc")
    func noStackOverflowDeeplyNestedCalc() {
        let depth = 1000
        var value = "1px"
        for _ in 0 ..< depth {
            value = "calc(\(value) + 1px)"
        }
        let css = "div { width: \(value); }"

        let stylesheet: Stylesheet<Never> = CSSParser(css).stylesheet
        #expect(stylesheet.rules.count == 1)
    }

    @Test("No stack overflow with deeply nested parentheses in selector")
    func noStackOverflowDeeplyNestedParenthesesInSelector() {
        let depth = 100
        var selector = "div"
        for _ in 0 ..< depth {
            selector = ":not(\(selector))"
        }
        let css = "\(selector) { color: red; }"

        let stylesheet: Stylesheet<Never> = CSSParser(css).stylesheet
        #expect(stylesheet.rules.count == 1)
    }

    @Test("No stack overflow with deeply nested functions in value")
    func noStackOverflowDeeplyNestedFunctionsInValue() {
        let depth = 1000
        var value = "red"
        for i in 0 ..< depth {
            value = "var(--prop\(i), \(value))"
        }
        let css = "div { color: \(value); }"

        let stylesheet: Stylesheet<Never> = CSSParser(css).stylesheet
        #expect(stylesheet.rules.count == 1)
    }

    @Test("No stack overflow with mixed deep nesting")
    func noStackOverflowMixedDeepNesting() {
        let depth = 1000
        var css = ""
        for i in 0 ..< depth {
            switch i % 3 {
            case 0: css += "@media screen { "
            case 1: css += "@supports (display: flex) { "
            default: css += "div { "
            }
        }
        css += "span { color: red; }"
        css += String(repeating: " }", count: depth)

        let stylesheet: Stylesheet<Never> = CSSParser(css).stylesheet
        #expect(stylesheet.rules.count >= 1)
    }

    @Test("Handles very long selector")
    func handlesVeryLongSelector() {
        let selectorParts = (0 ..< 1000).map { ".class\($0)" }
        let selector = selectorParts.joined(separator: " ")
        let css = "\(selector) { color: red; }"

        let stylesheet: Stylesheet<Never> = CSSParser(css).stylesheet
        #expect(stylesheet.rules.count == 1)
    }

    @Test("Handles very long property value")
    func handlesVeryLongPropertyValue() {
        let shadows = (0 ..< 1000).map { _ in "0 0 1px red" }
        let value = shadows.joined(separator: ", ")
        let css = "div { box-shadow: \(value); }"

        let stylesheet: Stylesheet<Never> = CSSParser(css).stylesheet
        #expect(stylesheet.rules.count == 1)
    }

    @Test("Handles malformed deeply nested unbalanced brackets")
    func handlesMalformedDeeplyNestedUnbalancedBrackets() {
        let css = String(repeating: "@media screen { ", count: 1000)
        let stylesheet: Stylesheet<Never> = CSSParser(css).stylesheet
        #expect(stylesheet.rules.count <= 2)
    }

    @Test("Handles deeply nested layer rules")
    func handlesDeeplyNestedLayerRules() {
        let depth = 1000
        var css = String(repeating: "@layer foo { ", count: depth)
        css += "div { color: red; }"
        css += String(repeating: " }", count: depth)

        let stylesheet: Stylesheet<Never> = CSSParser(css).stylesheet
        #expect(stylesheet.rules.count >= 1)
    }

    @Test("Handles deeply nested container rules")
    func handlesDeeplyNestedContainerRules() {
        let depth = 1000
        var css = String(repeating: "@container (min-width: 100px) { ", count: depth)
        css += "div { color: red; }"
        css += String(repeating: " }", count: depth)

        let stylesheet: Stylesheet<Never> = CSSParser(css).stylesheet
        #expect(stylesheet.rules.count >= 1)
    }
}
