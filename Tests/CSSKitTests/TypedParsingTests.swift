// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("Typed Parsing Tests")
struct TypedParsingTests {
    // MARK: - @property Rule

    @Test("@property parses syntax as CSSSyntaxString")
    func propertySyntaxTyped() {
        let css = """
        @property --spacing {
          syntax: "<length>";
          inherits: false;
          initial-value: 8px;
        }
        """
        let parser = CSSParser(css)
        guard case let .property(prop) = parser.stylesheet.rules.first else {
            Issue.record("Expected @property rule")
            return
        }

        #expect(prop.syntax == .components([CSSSyntaxComponent(kind: .length)]))
    }

    @Test("@property parses initial-value as typed CSSParsedComponent")
    func propertyInitialValueTyped() {
        let css = """
        @property --gap {
          syntax: "<length-percentage>";
          inherits: true;
          initial-value: 1.5rem;
        }
        """
        let parser = CSSParser(css)
        guard case let .property(prop) = parser.stylesheet.rules.first else {
            Issue.record("Expected @property rule")
            return
        }

        guard case let .lengthPercentage(lp) = prop.initialValue else {
            Issue.record("Expected lengthPercentage, got \(String(describing: prop.initialValue))")
            return
        }

        if case let .dimension(length) = lp {
            #expect(length.value == 1.5)
            #expect(length.unit == .rem)
        } else {
            Issue.record("Expected dimension")
        }
    }

    @Test("@property parses color initial-value")
    func propertyColorInitialValue() {
        let css = """
        @property --accent {
          syntax: "<color>";
          inherits: true;
          initial-value: oklch(70% 0.15 200);
        }
        """
        let parser = CSSParser(css)
        guard case let .property(prop) = parser.stylesheet.rules.first else {
            Issue.record("Expected @property rule")
            return
        }

        guard case .color = prop.initialValue else {
            Issue.record("Expected color, got \(String(describing: prop.initialValue))")
            return
        }
    }

    // MARK: - @scope Rule

    @Test("@scope parses scopeStart as SelectorList")
    func scopeStartTyped() {
        let css = "@scope (.card) { p { color: red; } }"
        let parser = CSSParser(css)
        guard case let .scope(scope) = parser.stylesheet.rules.first else {
            Issue.record("Expected @scope rule")
            return
        }

        guard let selectors = scope.scopeStart else {
            Issue.record("Expected scopeStart")
            return
        }

        #expect(selectors.selectors.count == 1)
        let first = selectors.selectors[0]
        if case let .class(name) = first.components.first {
            #expect(name == "card")
        } else {
            Issue.record("Expected .card selector")
        }
    }

    @Test("@scope parses scopeEnd as SelectorList")
    func scopeEndTyped() {
        let css = "@scope (.card) to (.card-footer) { p { margin: 0; } }"
        let parser = CSSParser(css)
        guard case let .scope(scope) = parser.stylesheet.rules.first else {
            Issue.record("Expected @scope rule")
            return
        }

        guard let endSelectors = scope.scopeEnd else {
            Issue.record("Expected scopeEnd")
            return
        }

        if case let .class(name) = endSelectors.selectors[0].components.first {
            #expect(name == "card-footer")
        } else {
            Issue.record("Expected .card-footer selector")
        }
    }

    // MARK: - @nest Rule

    @Test("@nest parses selector as SelectorList")
    func nestSelectorTyped() {
        let css = "@nest .child { color: blue; }"
        let parser = CSSParser(css)

        guard case let .nesting(nest) = parser.stylesheet.rules.first else {
            Issue.record("Expected @nest rule, got \(String(describing: parser.stylesheet.rules.first))")
            return
        }

        guard let selectors = nest.selectors else {
            Issue.record("Expected selectors")
            return
        }

        #expect(selectors.selectors.count == 1)
        if case let .class(name) = selectors.selectors[0].components.first {
            #expect(name == "child")
        } else {
            Issue.record("Expected .child selector")
        }
    }

    // MARK: - @container Rule

    @Test("ContainerCondition.parse works directly")
    func containerConditionParseDirect() {
        let result = ContainerCondition.parse(Parser(css: "(min-width: 400px)"))
        guard case let .success(condition) = result else {
            Issue.record("Parse failed: \(result)")
            return
        }

        if case let .sizeFeature(feature) = condition {
            #expect(feature.name == "min-width")
        } else {
            Issue.record("Expected sizeFeature, got \(condition)")
        }
    }

    @Test("@container parses condition as ContainerCondition")
    func containerConditionTyped() {
        let css = "@container (min-width: 400px) { .card { display: grid; } }"
        let parser = CSSParser(css)
        guard case let .container(container) = parser.stylesheet.rules.first else {
            Issue.record("Expected @container rule")
            return
        }

        guard let condition = container.condition else {
            Issue.record("Expected condition")
            return
        }

        if case let .sizeFeature(feature) = condition {
            #expect(feature.name == "min-width")
            if case let .length(len) = feature.value {
                #expect(len.value == 400)
                #expect(len.unit == .px)
            } else {
                Issue.record("Expected length value")
            }
        } else {
            Issue.record("Expected sizeFeature, got \(condition)")
        }
    }

    @Test("@container with name parses correctly")
    func containerWithName() {
        let css = "@container sidebar (width > 300px) { nav { flex-direction: column; } }"
        let parser = CSSParser(css)
        guard case let .container(container) = parser.stylesheet.rules.first else {
            Issue.record("Expected @container rule")
            return
        }

        #expect(container.name == "sidebar")

        guard let condition = container.condition else {
            Issue.record("Expected condition")
            return
        }

        if case let .sizeFeature(feature) = condition {
            #expect(feature.name == "width")
            #expect(feature.comparison == .greaterThan)
        } else {
            Issue.record("Expected sizeFeature")
        }
    }

    @Test("@container with and/or parses as compound condition")
    func containerCompoundCondition() {
        let css = "@container (min-width: 400px) and (max-width: 800px) { .card { padding: 1rem; } }"
        let parser = CSSParser(css)
        guard case let .container(container) = parser.stylesheet.rules.first else {
            Issue.record("Expected @container rule")
            return
        }

        guard let condition = container.condition else {
            Issue.record("Expected condition")
            return
        }

        if case let .and(conditions) = condition {
            #expect(conditions.count == 2)
        } else {
            Issue.record("Expected and condition, got \(condition)")
        }
    }

    @Test("@container style() query parses")
    func containerStyleQuery() {
        let css = "@container style(--theme: dark) { .card { background: #333; } }"
        let parser = CSSParser(css)
        guard case let .container(container) = parser.stylesheet.rules.first else {
            Issue.record("Expected @container rule")
            return
        }

        guard let condition = container.condition else {
            Issue.record("Expected condition")
            return
        }

        if case let .style(query) = condition {
            #expect(query.property == "--theme")
            #expect(query.value == "dark")
        } else {
            Issue.record("Expected style query, got \(condition)")
        }
    }

    // MARK: - Deep Nesting

    @Test("Deeply nested @container conditions don't overflow")
    func deeplyNestedContainerConditions() {
        var css = "@container "
        for i in 0 ..< 100 {
            css += "(width > \(i)px) and "
        }
        css += "(width > 100px) { .x { color: red; } }"

        let parser = CSSParser(css)
        guard case let .container(container) = parser.stylesheet.rules.first else {
            Issue.record("Expected @container rule")
            return
        }

        #expect(container.condition != nil)
    }

    // MARK: - MediaFeature

    @Test("MediaFeature parses plain syntax")
    func mediaFeaturePlain() {
        let css = "@media (min-width: 768px) { div { color: red; } }"
        let parser = CSSParser(css)
        guard case let .media(media) = parser.stylesheet.rules.first else {
            Issue.record("Expected @media rule")
            return
        }

        guard let condition = media.query.queries.first?.condition else {
            Issue.record("Expected condition")
            return
        }

        if case let .feature(feature) = condition {
            if case let .plain(name, value) = feature {
                #expect(name == "min-width")
                if case let .length(len) = value {
                    #expect(len.value == 768)
                    #expect(len.unit == .px)
                }
            } else {
                Issue.record("Expected plain feature, got \(feature)")
            }
        } else {
            Issue.record("Expected feature, got \(condition)")
        }
    }

    @Test("MediaFeature parses range syntax")
    func mediaFeatureRange() {
        let css = "@media (width > 400px) { div { color: blue; } }"
        let parser = CSSParser(css)
        guard case let .media(media) = parser.stylesheet.rules.first else {
            Issue.record("Expected @media rule")
            return
        }

        guard let condition = media.query.queries.first?.condition else {
            Issue.record("Expected condition")
            return
        }

        if case let .feature(feature) = condition {
            if case let .range(name, comparison, value) = feature {
                #expect(name == "width")
                #expect(comparison == .greaterThan)
                if case let .length(len) = value {
                    #expect(len.value == 400)
                }
            } else {
                Issue.record("Expected range feature, got \(feature)")
            }
        } else {
            Issue.record("Expected feature, got \(condition)")
        }
    }

    @Test("MediaFeature parses boolean syntax")
    func mediaFeatureBoolean() {
        let css = "@media (hover) { a { text-decoration: underline; } }"
        let parser = CSSParser(css)
        guard case let .media(media) = parser.stylesheet.rules.first else {
            Issue.record("Expected @media rule")
            return
        }

        guard let condition = media.query.queries.first?.condition else {
            Issue.record("Expected condition")
            return
        }

        if case let .feature(feature) = condition {
            if case let .boolean(name) = feature {
                #expect(name == "hover")
            } else {
                Issue.record("Expected boolean feature, got \(feature)")
            }
        } else {
            Issue.record("Expected feature, got \(condition)")
        }
    }

    @Test("Nested media not conditions serialize correctly")
    func nestedMediaNot() {
        let css = "@media not (min-width: 100px) { div { color: red; } }"
        let parser = CSSParser(css)
        let output = parser.stylesheet.string()
        #expect(output.contains("@media"))
        #expect(output.contains("min-width"))
    }
}
