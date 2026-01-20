// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("CSS Wide Keyword Tests")
struct CSSWideKeywordTests {
    // MARK: - Basic Keyword Parsing

    @Test("Parse all CSS-wide keywords")
    func parseAllKeywords() {
        let cases: [(String, CSSWideKeyword)] = [
            ("initial", .initial),
            ("inherit", .inherit),
            ("unset", .unset),
            ("revert", .revert),
            ("revert-layer", .revertLayer),
        ]

        for (input, expected) in cases {
            let parser = Parser(css: input)
            let result = CSSWideKeyword.parse(parser)
            guard case let .success(keyword) = result else {
                Issue.record("Failed to parse '\(input)'")
                continue
            }
            #expect(keyword == expected, "Expected \(expected) for '\(input)'")
        }
    }

    @Test("CSS-wide keywords are case insensitive")
    func caseInsensitive() {
        let cases = ["INHERIT", "Inherit", "InHeRiT", "INITIAL", "UNSET", "REVERT", "REVERT-LAYER"]

        for input in cases {
            let parser = Parser(css: input)
            let result = CSSWideKeyword.parse(parser)
            #expect(result.isSuccess, "Should parse '\(input)' case-insensitively")
        }
    }

    // MARK: - Property Value Parsing

    @Test("color: inherit parses as wideKeyword")
    func colorInherit() {
        let css = ".test { color: inherit; }"
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .style(rule) = stylesheet.rules.first else {
            Issue.record("Expected style rule")
            return
        }

        let decl = rule.declarations.first!
        #expect(decl.name == "color")

        if case let .wideKeyword(keyword, propertyId) = decl.value {
            #expect(keyword == .inherit)
            #expect(propertyId.name == "color")
        } else {
            Issue.record("Expected .wideKeyword, got \(decl.value)")
        }
    }

    @Test("font-size: initial parses as wideKeyword")
    func fontSizeInitial() {
        let css = "p { font-size: initial; }"
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .style(rule) = stylesheet.rules.first else {
            Issue.record("Expected style rule")
            return
        }

        let decl = rule.declarations.first!
        if case let .wideKeyword(keyword, _) = decl.value {
            #expect(keyword == .initial)
        } else {
            Issue.record("Expected .wideKeyword(.initial)")
        }
    }

    @Test("margin: unset parses as wideKeyword")
    func marginUnset() {
        let css = "div { margin: unset; }"
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .style(rule) = stylesheet.rules.first else {
            Issue.record("Expected style rule")
            return
        }

        let decl = rule.declarations.first!
        if case let .wideKeyword(keyword, _) = decl.value {
            #expect(keyword == .unset)
        } else {
            Issue.record("Expected .wideKeyword(.unset)")
        }
    }

    @Test("border: revert parses as wideKeyword")
    func borderRevert() {
        let css = ".card { border: revert; }"
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .style(rule) = stylesheet.rules.first else {
            Issue.record("Expected style rule")
            return
        }

        let decl = rule.declarations.first!
        if case let .wideKeyword(keyword, _) = decl.value {
            #expect(keyword == .revert)
        } else {
            Issue.record("Expected .wideKeyword(.revert)")
        }
    }

    @Test("background: revert-layer parses as wideKeyword")
    func backgroundRevertLayer() {
        let css = "@layer base { .bg { background: revert-layer; } }"
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .layerBlock(layer) = stylesheet.rules.first else {
            Issue.record("Expected layer rule")
            return
        }

        guard case let .style(rule) = layer.rules.first else {
            Issue.record("Expected style rule inside layer")
            return
        }

        let decl = rule.declarations.first!
        if case let .wideKeyword(keyword, _) = decl.value {
            #expect(keyword == .revertLayer)
        } else {
            Issue.record("Expected .wideKeyword(.revertLayer)")
        }
    }

    // MARK: - Real-World Usage Patterns

    @Test("Sidebar inherits parent color - common pattern")
    func sidebarInheritsColor() {
        let css = """
        #sidebar h2 {
            color: inherit;
        }
        """
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .style(rule) = stylesheet.rules.first else {
            Issue.record("Expected style rule")
            return
        }

        let decl = rule.declarations.first!
        if case let .wideKeyword(keyword, _) = decl.value {
            #expect(keyword == .inherit)
        } else {
            Issue.record("Expected color: inherit to parse as wideKeyword")
        }
    }

    @Test("Child inherits border from parent")
    func childInheritsBorder() {
        let css = """
        .child {
            border: inherit;
        }
        """
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .style(rule) = stylesheet.rules.first else {
            Issue.record("Expected style rule")
            return
        }

        let decl = rule.declarations.first!
        if case let .wideKeyword(keyword, _) = decl.value {
            #expect(keyword == .inherit)
        } else {
            Issue.record("Expected border: inherit to parse as wideKeyword")
        }
    }

    @Test("Reset all properties with unset")
    func resetWithUnset() {
        let css = """
        .reset {
            margin: unset;
            padding: unset;
            border: unset;
            background: unset;
        }
        """
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .style(rule) = stylesheet.rules.first else {
            Issue.record("Expected style rule")
            return
        }

        for decl in rule.declarations {
            if case let .wideKeyword(keyword, _) = decl.value {
                #expect(keyword == .unset, "\(decl.name) should be unset")
            } else {
                Issue.record("\(decl.name): unset should parse as wideKeyword")
            }
        }
    }

    @Test("Revert to user-agent styles")
    func revertToUserAgent() {
        // Note: appearance has vendor prefixes, use properties without vendor prefix requirements
        let css = """
        button {
            background: revert;
            border: revert;
            padding: revert;
            color: revert;
        }
        """
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .style(rule) = stylesheet.rules.first else {
            Issue.record("Expected style rule")
            return
        }

        for decl in rule.declarations {
            if case let .wideKeyword(keyword, _) = decl.value {
                #expect(keyword == .revert)
            } else {
                Issue.record("\(decl.name): revert should parse as wideKeyword")
            }
        }
    }

    @Test("Initial values for form reset")
    func formResetInitial() {
        let css = """
        input[type="text"] {
            font: initial;
            color: initial;
            background: initial;
        }
        """
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .style(rule) = stylesheet.rules.first else {
            Issue.record("Expected style rule")
            return
        }

        for decl in rule.declarations {
            if case let .wideKeyword(keyword, _) = decl.value {
                #expect(keyword == .initial)
            } else {
                Issue.record("\(decl.name): initial should parse as wideKeyword")
            }
        }
    }

    // MARK: - Serialization

    @Test("CSS-wide keywords serialize correctly")
    func serializeKeywords() {
        let cases: [(CSSWideKeyword, String)] = [
            (.initial, "initial"),
            (.inherit, "inherit"),
            (.unset, "unset"),
            (.revert, "revert"),
            (.revertLayer, "revert-layer"),
        ]

        for (keyword, expected) in cases {
            #expect(keyword.string == expected)
        }
    }

    @Test("Round-trip: parse and serialize")
    func roundTrip() {
        let css = ".test { color: inherit; margin: initial; padding: unset; }"
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .style(rule) = stylesheet.rules.first else {
            Issue.record("Expected style rule")
            return
        }

        // Check each declaration round-trips
        for decl in rule.declarations {
            if case let .wideKeyword(keyword, _) = decl.value {
                let serialized = keyword.string
                let reparsed = CSSWideKeyword(rawValue: serialized)
                #expect(reparsed == keyword, "Round-trip failed for \(decl.name)")
            }
        }
    }

    // MARK: - Property Inheritance Flag

    @Test("Inheriting properties have inherits flag set")
    func inheritingPropertiesFlag() {
        let css = """
        .test {
            color: red;
            font-size: 16px;
            font-weight: bold;
            line-height: 1.5;
            text-align: center;
            visibility: hidden;
            cursor: pointer;
        }
        """
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .style(rule) = stylesheet.rules.first else {
            Issue.record("Expected style rule")
            return
        }

        let inheritingProps = ["color", "font-size", "font-weight", "line-height", "text-align", "visibility", "cursor"]

        for decl in rule.declarations {
            if inheritingProps.contains(decl.name) {
                #expect(decl.value.inherits == true, "\(decl.name) should have inherits=true")
            }
        }
    }

    @Test("Non-inheriting properties have inherits flag false")
    func nonInheritingPropertiesFlag() {
        let css = """
        .test {
            margin: 10px;
            padding: 10px;
            border: 1px solid black;
            width: 100px;
            height: 100px;
            display: block;
            position: absolute;
        }
        """
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .style(rule) = stylesheet.rules.first else {
            Issue.record("Expected style rule")
            return
        }

        let nonInheritingProps = ["margin", "padding", "border", "width", "height", "display", "position"]

        for decl in rule.declarations {
            if nonInheritingProps.contains(decl.name) {
                #expect(decl.value.inherits == false, "\(decl.name) should have inherits=false")
            }
        }
    }

    @Test("Wide keyword inherits flag delegates to property ID")
    func wideKeywordInheritsFlag() {
        let css = """
        .test {
            color: inherit;
            margin: inherit;
            font-size: initial;
            padding: initial;
        }
        """
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .style(rule) = stylesheet.rules.first else {
            Issue.record("Expected style rule")
            return
        }

        for decl in rule.declarations {
            guard case .wideKeyword = decl.value else {
                Issue.record("\(decl.name) should be wideKeyword")
                continue
            }

            switch decl.name {
            case "color", "font-size":
                #expect(decl.value.inherits == true, "\(decl.name): inherit/initial should have inherits=true")
            case "margin", "padding":
                #expect(decl.value.inherits == false, "\(decl.name): inherit/initial should have inherits=false")
            default:
                break
            }
        }
    }

    // MARK: - Edge Cases

    @Test("CSS-wide keyword with !important")
    func keywordWithImportant() {
        let css = ".override { color: inherit !important; }"
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .style(rule) = stylesheet.rules.first else {
            Issue.record("Expected style rule")
            return
        }

        let decl = rule.declarations.first!
        #expect(decl.isImportant == true)

        if case let .wideKeyword(keyword, _) = decl.value {
            #expect(keyword == .inherit)
        } else {
            Issue.record("Expected wideKeyword even with !important")
        }
    }

    @Test("CSS-wide keywords don't match as custom idents")
    func keywordsNotCustomIdents() {
        let reservedKeywords = CSSWideKeyword.allCases.map(\.rawValue)

        for keyword in reservedKeywords {
            #expect(CSSCustomIdent.isValid(keyword) == false, "\(keyword) should not be valid custom ident")
        }
    }

    @Test("Keyframes name cannot be CSS-wide keyword unquoted")
    func keyframesNameReserved() {
        let css = "@keyframes inherit { from { opacity: 0; } }"
        let parser = CSSParser(css)
        let result = parser.result

        // Unquoted "inherit" is rejected as a name - the rule parses but name becomes empty
        guard case let .keyframes(kf) = result.rules.first else {
            Issue.record("Expected keyframes rule")
            return
        }

        // Name should be empty
        if case let .ident(name) = kf.name {
            #expect(name.isEmpty, "Reserved keyword 'inherit' should be rejected, name should be empty")
        } else {
            Issue.record("Expected .ident name")
        }
    }

    @Test("Keyframes name can be CSS-wide keyword when quoted")
    func keyframesNameQuoted() {
        let css = #"@keyframes "inherit" { from { opacity: 0; } to { opacity: 1; } }"#
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .keyframes(kf) = stylesheet.rules.first else {
            Issue.record("Expected keyframes rule, got \(String(describing: stylesheet.rules.first))")
            return
        }

        guard case let .string(name) = kf.name else {
            Issue.record("Expected .string name, got \(kf.name)")
            return
        }
        #expect(name == "inherit")
    }

    // MARK: - @property Rule

    @Test("@property rule parses inherits: false")
    func propertyRuleInheritsFalse() {
        let css = """
        @property --my-color {
          syntax: "<color>";
          inherits: false;
          initial-value: #c0ffee;
        }
        """
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .property(prop) = stylesheet.rules.first else {
            Issue.record("Expected @property rule, got \(String(describing: stylesheet.rules.first))")
            return
        }

        #expect(prop.name == "--my-color")
        #expect(prop.inherits == false)
        #expect(prop.syntax == .components([CSSSyntaxComponent(kind: .color, multiplier: .none)]))

        guard case let .color(color) = prop.initialValue else {
            Issue.record("Expected color initial value, got \(String(describing: prop.initialValue))")
            return
        }
        // #c0ffee = rgb(192, 255, 238)
        if case let .rgba(rgba) = color {
            #expect(rgba.red == 192)
            #expect(rgba.green == 255)
            #expect(rgba.blue == 238)
        } else {
            Issue.record("Expected rgba color")
        }
    }

    @Test("@property rule parses inherits: true")
    func propertyRuleInheritsTrue() {
        let css = """
        @property --theme-font {
          syntax: "*";
          inherits: true;
        }
        """
        let parser = CSSParser(css)
        let stylesheet = parser.stylesheet

        guard case let .property(prop) = stylesheet.rules.first else {
            Issue.record("Expected @property rule")
            return
        }

        #expect(prop.name == "--theme-font")
        #expect(prop.inherits == true)
        #expect(prop.syntax == .universal)
        #expect(prop.initialValue == nil)
    }
}
