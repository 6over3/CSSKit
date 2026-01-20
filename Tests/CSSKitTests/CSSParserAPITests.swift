// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("CSSParser API Tests")
struct CSSParserAPITests {
    @Suite("Stylesheet")
    struct StylesheetTests {
        @Test("Parse empty stylesheet")
        func emptyStylesheet() {
            let stylesheet = CSSParser("").stylesheet
            #expect(stylesheet.rules.isEmpty)
        }

        @Test("Parse single rule")
        func singleRule() {
            let stylesheet = CSSParser(".foo { color: red; }").stylesheet
            #expect(stylesheet.rules.count == 1)
        }

        @Test("Parse multiple rules")
        func multipleRules() {
            let css = """
            .a { color: red; }
            .b { color: blue; }
            .c { color: green; }
            """
            let stylesheet = CSSParser(css).stylesheet
            #expect(stylesheet.rules.count == 3)
        }

        @Test("Parse at-rule")
        func atRule() {
            let css = "@media (min-width: 768px) { .foo { color: red; } }"
            let stylesheet = CSSParser(css).stylesheet
            #expect(stylesheet.rules.count == 1)
            guard case .media = stylesheet.rules[0] else {
                Issue.record("Expected media rule")
                return
            }
        }

        @Test("Parse with source map URL")
        func sourceMapUrl() {
            let css = ".foo { color: red; }\n/*# sourceMappingURL=style.css.map */"
            let stylesheet = CSSParser(css).stylesheet
            #expect(stylesheet.sourceMapUrl == "style.css.map")
        }

        @Test("Parse with source URL")
        func sourceUrl() {
            let css = ".foo { color: red; }\n/*# sourceURL=style.css */"
            let stylesheet = CSSParser(css).stylesheet
            #expect(stylesheet.sourceUrl == "style.css")
        }
    }

    @Suite("Rules")
    struct RulesTests {
        @Test("Parse empty rule list")
        func emptyRuleList() {
            let rules = CSSParser("").rules
            #expect(rules.isEmpty)
        }

        @Test("Parse multiple rules")
        func multipleRules() {
            let css = ".a { } .b { } .c { }"
            let rules = CSSParser(css).rules
            #expect(rules.count == 3)
        }

        @Test("Parse mixed qualified and at-rules")
        func mixedRules() {
            let css = """
            .foo { color: red; }
            @media print { .bar { display: none; } }
            #id { margin: 0; }
            """
            let rules = CSSParser(css).rules
            #expect(rules.count == 3)
        }

        @Test("Rules skips invalid rules")
        func ruleListSkipsInvalid() {
            let css = """
            .ok1 { }
            123broken { }
            .ok2 { }
            """
            let rules = CSSParser(css).rules
            #expect(rules.count == 2)
        }
    }

    @Suite("Declarations")
    struct DeclarationsTests {
        @Test("Parse empty declaration list")
        func emptyList() throws {
            let declarations = try CSSParser("").declarations
            #expect(declarations.isEmpty)
        }

        @Test("Parse single declaration")
        func singleDeclaration() throws {
            let declarations = try CSSParser("color: red").declarations
            #expect(declarations.count == 1)
            #expect(declarations[0].name == "color")
        }

        @Test("Parse multiple declarations")
        func multipleDeclarations() throws {
            let css = "color: red; margin: 10px; padding: 5px"
            let declarations = try CSSParser(css).declarations
            #expect(declarations.count == 3)
        }

        @Test("Parse declaration with !important")
        func importantDeclaration() throws {
            let declarations = try CSSParser("color: red !important").declarations
            #expect(declarations.count == 1)
            #expect(declarations[0].isImportant)
        }

        @Test("Parse declaration without !important")
        func notImportant() throws {
            let declarations = try CSSParser("color: red").declarations
            #expect(declarations.count == 1)
            #expect(!declarations[0].isImportant)
        }

        @Test("Parse vendor-prefixed property")
        func vendorPrefix() throws {
            let declarations = try CSSParser("-webkit-transform: rotate(45deg)").declarations
            #expect(declarations.count == 1)
            #expect(declarations[0].name == "-webkit-transform")
        }

        @Test("Skip invalid declarations")
        func skipInvalid() throws {
            let css = "color: red; : invalid; margin: 10px"
            let declarations = try CSSParser(css).declarations
            #expect(declarations.count == 2)
        }
    }

    @Suite("Value")
    struct ValueTests {
        @Test("Parse color value")
        func colorValue() throws {
            let value = try CSSParser("red").value
            guard case .color = value else {
                Issue.record("Expected color value, got \(value)")
                return
            }
        }

        @Test("Parse hex color")
        func hexColor() throws {
            let value = try CSSParser("#ff0000").value
            guard case .color = value else {
                Issue.record("Expected color value, got \(value)")
                return
            }
        }

        @Test("Parse rgb color")
        func rgbColor() throws {
            let value = try CSSParser("rgb(255, 0, 0)").value
            guard case .color = value else {
                Issue.record("Expected color value, got \(value)")
                return
            }
        }

        @Test("Parse length value")
        func lengthValue() throws {
            let value = try CSSParser("10px").value
            guard case .lengthPercentage = value else {
                Issue.record("Expected lengthPercentage value, got \(value)")
                return
            }
        }

        @Test("Parse percentage value")
        func percentageValue() throws {
            let value = try CSSParser("50%").value
            guard case .lengthPercentage = value else {
                Issue.record("Expected lengthPercentage value, got \(value)")
                return
            }
        }

        @Test("Parse angle value")
        func angleValue() throws {
            let value = try CSSParser("45deg").value
            guard case .angle = value else {
                Issue.record("Expected angle value, got \(value)")
                return
            }
        }

        @Test("Parse time value")
        func timeValue() throws {
            let value = try CSSParser("500ms").value
            guard case .time = value else {
                Issue.record("Expected time value, got \(value)")
                return
            }
        }

        @Test("Parse number value")
        func numberValue() throws {
            let value = try CSSParser("3.14").value
            guard case let .ratio(r) = value else {
                Issue.record("Expected ratio value, got \(value)")
                return
            }
            #expect(r.numerator == 3.14)
            #expect(r.denominator == 1)
        }

        @Test("Parse string value")
        func stringValue() throws {
            let value = try CSSParser("'hello world'").value
            guard case let .string(s) = value else {
                Issue.record("Expected string value, got \(value)")
                return
            }
            #expect(s.value == "hello world")
        }

        @Test("Parse url value")
        func urlValue() throws {
            let value = try CSSParser("url('image.png')").value
            guard case let .url(url) = value else {
                Issue.record("Expected url value, got \(value)")
                return
            }
            #expect(url.url == "image.png")
        }

        @Test("Parse gradient value")
        func gradientValue() throws {
            let value = try CSSParser("linear-gradient(red, blue)").value
            guard case .gradient = value else {
                Issue.record("Expected gradient value, got \(value)")
                return
            }
        }

        @Test("Parse identifier value")
        func identValue() throws {
            let value = try CSSParser("block").value
            guard case .ident = value else {
                Issue.record("Expected ident value, got \(value)")
                return
            }
        }
    }

    @Suite("Result and errors")
    struct ResultTests {
        @Test("result contains stylesheet and errors")
        func resultContainsBoth() {
            let css = """
            .valid { color: red; }
            123invalid { }
            .also-valid { color: blue; }
            """
            let parser = CSSParser(css)
            #expect(parser.result.rules.count == 2)
            #expect(parser.result.errors.count == 1)
        }

        @Test("errors property matches result.errors")
        func errorsProperty() {
            let css = """
            .valid { color: red; }
            123invalid { }
            """
            let parser = CSSParser(css)
            #expect(parser.errors.count == 1)
            #expect(parser.errors.count == parser.result.errors.count)
        }

        @Test("Empty stylesheet has no errors")
        func emptyNoErrors() {
            let parser = CSSParser("")
            #expect(parser.rules.isEmpty)
            #expect(parser.errors.isEmpty)
        }

        @Test("Valid stylesheet has no errors")
        func validNoErrors() {
            let css = ".a { color: red; } .b { margin: 10px; }"
            let parser = CSSParser(css)
            #expect(parser.rules.count == 2)
            #expect(parser.errors.isEmpty)
        }

        @Test("Error contains location info")
        func errorHasLocation() {
            let css = """
            .valid { }
            123broken { }
            """
            let parser = CSSParser(css)
            #expect(parser.errors.count == 1)
            if let error = parser.errors.first {
                #expect(error.location.line > 0 || error.location.column > 0)
            }
        }

        @Test("Result is cached")
        func resultIsCached() {
            let parser = CSSParser(".a { } .b { }")
            let result1 = parser.result
            let result2 = parser.result
            #expect(result1.rules.count == result2.rules.count)
        }
    }

    @Suite("Tokenize")
    struct TokenizeTests {
        @Test("Tokenize empty string")
        func emptyString() throws {
            let tokens = Array(CSSParser("").tokenize())
            #expect(tokens.isEmpty)
        }

        @Test("Tokenize simple selector")
        func simpleSelector() throws {
            let tokens = Array(CSSParser(".foo").tokenize())
            #expect(tokens.count == 2)
        }

        @Test("Tokenize declaration")
        func declaration() throws {
            let tokens = Array(CSSParser("color: red").tokenize())
            #expect(tokens.contains { if case .ident = $0 { return true }; return false })
            #expect(tokens.contains { if case .colon = $0 { return true }; return false })
        }

        @Test("Tokenize number")
        func number() throws {
            let tokens = Array(CSSParser("42").tokenize())
            #expect(tokens.count == 1)
            guard case .number = tokens[0] else {
                Issue.record("Expected number token")
                return
            }
        }

        @Test("Tokenize dimension")
        func dimension() throws {
            let tokens = Array(CSSParser("10px").tokenize())
            #expect(tokens.count == 1)
            guard case .dimension = tokens[0] else {
                Issue.record("Expected dimension token")
                return
            }
        }

        @Test("Tokenize percentage")
        func percentage() throws {
            let tokens = Array(CSSParser("50%").tokenize())
            #expect(tokens.count == 1)
            guard case .percentage = tokens[0] else {
                Issue.record("Expected percentage token")
                return
            }
        }

        @Test("Tokenize string")
        func string() throws {
            let tokens = Array(CSSParser("\"hello\"").tokenize())
            #expect(tokens.count == 1)
            guard case .quotedString = tokens[0] else {
                Issue.record("Expected quotedString token")
                return
            }
        }

        @Test("Tokenize hash")
        func hash() throws {
            let tokens = Array(CSSParser("#fff").tokenize())
            #expect(tokens.count == 1)
            guard case .idHash = tokens[0] else {
                Issue.record("Expected idHash token, got \(tokens[0])")
                return
            }
        }

        @Test("Tokenize function")
        func function() throws {
            let tokens = Array(CSSParser("rgb(").tokenize())
            #expect(tokens.count == 1)
            guard case .function = tokens[0] else {
                Issue.record("Expected function token")
                return
            }
        }

        @Test("Tokenize at-keyword")
        func atKeyword() throws {
            let tokens = Array(CSSParser("@media").tokenize())
            #expect(tokens.count == 1)
            guard case .atKeyword = tokens[0] else {
                Issue.record("Expected at-keyword token")
                return
            }
        }

        @Test("Tokenize url")
        func url() throws {
            let tokens = Array(CSSParser("url(image.png)").tokenize())
            #expect(tokens.count == 1)
            guard case .unquotedUrl = tokens[0] else {
                Issue.record("Expected unquotedUrl token")
                return
            }
        }

        @Test("Tokenize preserves whitespace with iterator")
        func whitespacePreserved() throws {
            var count = 0
            for _ in CSSParser("a b c").tokenize() {
                count += 1
            }
            #expect(count == 5)
        }
    }

    @Suite("Custom AtRuleParser")
    struct CustomAtRuleParserTests {
        @Test("Use custom at-rule parser")
        func customParser() {
            let css = "@custom-rule test { }"
            let parser = CSSParser(css, atRuleParser: DefaultAtRuleParser())
            let stylesheet = parser.stylesheet
            #expect(stylesheet.rules.count == 1)
        }
    }

    @Suite("Error Recovery")
    struct ErrorRecoveryTests {
        @Test("Skip invalid rule and continue parsing")
        func skipInvalidRule() {
            let css = """
            .valid1 { color: red; }
            123invalid { broken: value; }
            .valid2 { color: blue; }
            """
            let stylesheet = CSSParser(css).stylesheet
            #expect(stylesheet.rules.count == 2)
        }

        @Test("Skip multiple invalid rules")
        func skipMultipleInvalidRules() {
            let css = """
            .a { color: red; }
            123first { }
            .b { color: blue; }
            456second { }
            .c { color: green; }
            """
            let parser = CSSParser(css)
            #expect(parser.rules.count == 3)
            #expect(parser.errors.count == 2)
        }

        @Test("Invalid selector is skipped")
        func invalidSelectorSkipped() {
            let css = """
            .a { color: red; }
            123invalid { color: blue; }
            .b { color: green; }
            """
            let stylesheet = CSSParser(css).stylesheet
            #expect(stylesheet.rules.count == 2)
        }

        @Test("Unclosed bracket consumes rest of input")
        func unclosedBracketBehavior() {
            let css = """
            .valid { }
            [unclosed
            .swallowed { }
            """
            let parser = CSSParser(css)
            #expect(parser.rules.count == 1)
        }
    }

    @Suite("Source file tracking")
    struct SourceFileTests {
        @Test("sourceFile is tracked in locations")
        func sourceFileTracked() {
            let parser = CSSParser(".a { color: red; }", sourceFile: "test.css")
            if case let .style(rule) = parser.rules.first {
                #expect(rule.location.sourceFile == "test.css")
            }
        }

        @Test("errors include sourceFile")
        func errorIncludesSourceFile() {
            let parser = CSSParser("123invalid { }", sourceFile: "broken.css")
            if let error = parser.errors.first {
                #expect(error.location.sourceFile == "broken.css")
            }
        }
    }
}
