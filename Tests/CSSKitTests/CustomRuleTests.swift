// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

// MARK: - Custom Rule Types

struct TailwindRule: CSSAtRule, Hashable {
    static let name = "tailwind"
    let directive: String

    static func parse(prelude: ParsingContext, context _: AtRuleContext) throws -> Self {
        Self(directive: prelude.collectRemainingTokens())
    }

    func serialize(dest: inout some CSSWriter) {
        dest.write("@tailwind \(directive);")
    }
}

struct ApplyRule: CSSAtRule, Hashable {
    static let name = "apply"
    let classes: [String]

    static func parse(prelude: ParsingContext, context _: AtRuleContext) throws -> Self {
        Self(classes: prelude.collectRemainingTokens().split(separator: " ").map(String.init))
    }

    func serialize(dest: inout some CSSWriter) {
        dest.write("@apply \(classes.joined(separator: " "));")
    }
}

struct ScreenRule: CSSAtRule, Hashable {
    static let name = "screen"
    let breakpoint: String
    let rules: String

    static func parse(prelude _: ParsingContext, context _: AtRuleContext) throws -> Self {
        throw ParsingError(message: "@screen requires a block")
    }

    static func parseBlock(prelude: String, body: ParsingContext, context _: AtRuleContext) throws -> Self? {
        Self(breakpoint: prelude.trimmingCharacters(in: .whitespaces), rules: body.collectRemainingTokens())
    }

    func serialize(dest: inout some CSSWriter) {
        dest.write("@screen \(breakpoint) {\n\(rules)\n}")
    }
}

struct ParsingError: Error {
    let message: String
}

// MARK: - Combined Rule Set

enum TailwindRules: CSSAtRuleSet {
    case tailwind(TailwindRule)
    case apply(ApplyRule)
    case screen(ScreenRule)

    static let handlers: [CSSAtRuleHandler<Self>] = [
        .init(TailwindRule.self) { .tailwind($0) },
        .init(ApplyRule.self) { .apply($0) },
        .init(ScreenRule.self) { .screen($0) },
    ]

    func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .tailwind(r): r.serialize(dest: &dest)
        case let .apply(r): r.serialize(dest: &dest)
        case let .screen(r): r.serialize(dest: &dest)
        }
    }
}

// MARK: - Tests

@Suite("Custom Rule Parsing Tests")
struct CSSAtRuleParsingTests {
    @Test("Parse @tailwind directive")
    func parseTailwindDirective() throws {
        let stylesheet = try CSSParser("@tailwind base;", atRuleParser: TailwindRules.parser).stylesheet
        #expect(stylesheet.rules.count == 1)
        if case let .custom(.tailwind(rule)) = stylesheet.rules[0] {
            #expect(rule.directive == "base")
        } else {
            Issue.record("Expected tailwind rule")
        }
    }

    @Test("Parse @apply with classes")
    func parseApplyClasses() throws {
        let stylesheet = try CSSParser("@apply flex items-center justify-between;", atRuleParser: TailwindRules.parser).stylesheet
        #expect(stylesheet.rules.count == 1)
        if case let .custom(.apply(rule)) = stylesheet.rules[0] {
            #expect(rule.classes == ["flex", "items-center", "justify-between"])
        } else {
            Issue.record("Expected apply rule")
        }
    }

    @Test("Parse @screen with block")
    func parseScreenBlock() throws {
        let css = "@screen md { .container { max-width: 768px; } }"
        let stylesheet = try CSSParser(css, atRuleParser: TailwindRules.parser).stylesheet
        #expect(stylesheet.rules.count == 1)
        if case let .custom(.screen(rule)) = stylesheet.rules[0] {
            #expect(rule.breakpoint == "md")
            #expect(rule.rules.contains("container"))
        } else {
            Issue.record("Expected screen rule")
        }
    }

    @Test("Custom rules work alongside built-in rules")
    func customAndBuiltinRules() throws {
        let css = """
        @tailwind base;
        @tailwind components;
        body { margin: 0; padding: 0; }
        @media screen and (min-width: 768px) { .container { max-width: 768px; } }
        @apply flex items-center;
        """
        let stylesheet = try CSSParser(css, atRuleParser: TailwindRules.parser).stylesheet
        #expect(stylesheet.rules.count == 5)

        for rule in stylesheet.rules {
            switch rule {
            case let .custom(.tailwind(t)) where t.directive == "base": break
            case let .custom(.tailwind(t)) where t.directive == "components": break
            case let .style(s) where s.selectorText == "body": #expect(s.declarations.count == 2)
            case let .media(m): #expect(m.rules.count == 1)
            case let .custom(.apply(a)): #expect(a.classes == ["flex", "items-center"])
            default: break
            }
        }
    }

    @Test("Built-in rules are parsed by default parser")
    func builtinRulesDefaultParser() throws {
        let css = """
        @import url('reset.css');
        @namespace svg url('http://www.w3.org/2000/svg');
        body { color: red; }
        @media print { body { color: black; } }
        @keyframes fade { from { opacity: 0; } to { opacity: 1; } }
        @supports (display: grid) { .grid { display: grid; } }
        """
        let stylesheet: Stylesheet<Never> = try CSSParser(css).stylesheet
        #expect(stylesheet.rules.count == 6)

        for rule in stylesheet.rules {
            switch rule {
            case let .importRule(r): #expect(r.url == "reset.css")
            case let .namespace(r): #expect(r.prefix == "svg")
            case let .style(r): #expect(r.selectorText == "body")
            case let .media(r): #expect(r.rules.count == 1)
            case let .keyframes(r): #expect(r.name == .ident("fade"))
            case let .supports(r): #expect(r.rules.count == 1)
            default: Issue.record("Unexpected rule type")
            }
        }
    }

    @Test("Unknown at-rules fall back to UnknownAtRule")
    func unknownAtRules() throws {
        let stylesheet: Stylesheet<Never> = try CSSParser("@unknown-directive something;").stylesheet
        #expect(stylesheet.rules.count == 1)
        if case let .unknown(rule) = stylesheet.rules[0] {
            #expect(rule.name == "unknown-directive")
            #expect(rule.prelude == "something")
        } else {
            Issue.record("Expected unknown rule")
        }
    }

    @Test("ToCss roundtrip for @tailwind")
    func toCssTailwind() {
        #expect(TailwindRule(directive: "utilities").string() == "@tailwind utilities;")
    }

    @Test("ToCss roundtrip for @apply")
    func toCssApply() {
        #expect(ApplyRule(classes: ["flex", "items-center"]).string() == "@apply flex items-center;")
    }

    @Test("Stylesheet with custom rules serializes correctly")
    func stylesheetToCss() throws {
        let css = "@tailwind base;\nbody { margin: 0; }"
        let stylesheet = try CSSParser(css, atRuleParser: TailwindRules.parser).stylesheet
        let output = stylesheet.string()
        #expect(output.contains("@tailwind base;"))
        #expect(output.contains("body {"))
        #expect(output.contains("margin: 0;"))
    }
}
