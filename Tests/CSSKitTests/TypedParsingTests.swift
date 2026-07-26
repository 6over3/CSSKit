// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("Typed Parsing Tests")
struct TypedParsingTests {
    @Test("line-height preserves number and length-percentage grammars")
    func lineHeightTyped() throws {
        let declarations = try CSSParser(
            """
            line-height: 1.5;
            line-height: 2rlh;
            line-height: 125%;
            """
        ).declarations

        guard case let .lineHeight(.number(number)) = declarations[0].value,
              case let .lineHeight(.lengthPercentage(.dimension(length))) =
              declarations[1].value,
              case let .lineHeight(.lengthPercentage(.percentage(percent))) =
              declarations[2].value
        else {
            Issue.record(
                "Expected typed line-height values: \(String(reflecting: declarations.map(\.value)))"
            )
            return
        }

        #expect(number == 1.5)
        #expect(length == CSSLength(2, .rlh))
        #expect(percent == CSSPercentage(percent: 125))
    }

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

    @Test("@property validates required descriptors and initial value")
    func propertyValidity() {
        let css = """
        @property --valid {
          syntax: "<length>";
          inherits: false;
          initial-value: 8px;
        }
        @property --missing-inherits {
          syntax: "<length>";
          initial-value: 8px;
        }
        @property --dependent {
          syntax: "<length>";
          inherits: false;
          initial-value: 1rem;
        }
        @property --trailing {
          syntax: "<length>";
          inherits: false;
          initial-value: 8px junk;
        }
        @property not-custom {
          syntax: "*";
          inherits: true;
        }
        @property --last-descriptor-wins {
          syntax: nope;
          syntax: "<length>";
          inherits: maybe;
          inherits: false;
          initial-value: 2px;
        }
        """
        let properties: [PropertyRule] = CSSParser(css).stylesheet.rules.compactMap { rule in
            guard case let .property(property) = rule else {
                return nil
            }
            return property
        }

        #expect(properties.map(\.isValid) == [
            true, false, false, false, false, true,
        ])
    }

    @Test("registered syntax parses a complete public string value")
    func propertySyntaxParsesCompleteStringValue() throws {
        let syntax = try CSSSyntaxString.parse(string: "<length>").get()

        #expect(try syntax.parseValue("12px").get() == .length(.px(12)))
        #expect(syntax.parseValue("12px junk").isFailure)

        let alternatives = try CSSSyntaxString.parse(
            string: "<custom-ident> | <transform-list>"
        ).get()
        #expect((try? alternatives.parseValue("translateX(12px)").get()) != nil)
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

    @Test("MediaFeature normalizes value-first ranges")
    func mediaFeatureValueFirstRange() {
        let parser = CSSParser(
            "@media (400px < width) { div { color: blue; } }"
        )
        guard case let .media(media) = parser.stylesheet.rules.first,
              case let .feature(feature) = media.query.queries.first?.condition,
              case let .range(name, comparison, value) = feature
        else {
            Issue.record("Expected range media feature")
            return
        }

        #expect(name == "width")
        #expect(comparison == .greaterThan)
        #expect(value == .length(.px(400)))
        #expect(parser.stylesheet.string().contains("width > 400px"))
    }

    @Test("MediaFeature preserves inclusive interval bounds")
    func mediaFeatureIntervalBounds() {
        let parser = CSSParser(
            "@media (400px < width <= 800px) { div { color: blue; } }"
        )
        guard case let .media(media) = parser.stylesheet.rules.first,
              case let .feature(feature) = media.query.queries.first?.condition,
              case let .interval(
                  name,
                  lower,
                  lowerComparison,
                  upper,
                  upperComparison
              ) = feature
        else {
            Issue.record("Expected interval media feature")
            return
        }

        #expect(name == "width")
        #expect(lower == .length(.px(400)))
        #expect(lowerComparison == .greaterThan)
        #expect(upper == .length(.px(800)))
        #expect(upperComparison == .lessThanOrEqual)
        #expect(
            parser.stylesheet.string()
                .contains("400px < width <= 800px")
        )
    }

    @Test("MediaFeature normalizes descending intervals")
    func mediaFeatureDescendingInterval() {
        let parser = CSSParser(
            "@media (800px >= width > 400px) { div { color: blue; } }"
        )
        guard case let .media(media) = parser.stylesheet.rules.first,
              case let .feature(feature) = media.query.queries.first?.condition,
              case let .interval(
                  name,
                  lower,
                  lowerComparison,
                  upper,
                  upperComparison
              ) = feature
        else {
            Issue.record("Expected interval media feature")
            return
        }

        #expect(name == "width")
        #expect(lower == .length(.px(400)))
        #expect(lowerComparison == .greaterThan)
        #expect(upper == .length(.px(800)))
        #expect(upperComparison == .lessThanOrEqual)
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

    @Test("Root supports leaf conditions serialize without trapping")
    func rootSupportsLeavesSerialize() {
        let declarations = CSSParser(
            "@supports (display: grid) { div { display: grid; } }"
        ).stylesheet.string()
        let selector = CSSParser(
            "@supports selector(:has(*)) { div { display: block; } }"
        ).stylesheet.string()
        let unknown = SupportsCondition.unknown("font-tech(color-COLRv1)")
        var writer = StringCSSWriter()
        unknown.serialize(dest: &writer)

        #expect(declarations.contains("@supports (display: grid)"))
        #expect(selector.contains("@supports selector(:has(*))"))
        #expect(writer.result == "font-tech(color-COLRv1)")
    }

    @Test("Writing mode parses as a typed inherited property")
    func writingModeProperty() throws {
        let declarations = try CSSParser(
            "writing-mode: vertical-rl"
        ).declarations
        let declaration = try #require(declarations.first)

        guard case let .writingMode(mode) = declaration.value else {
            Issue.record("Expected typed writing-mode")
            return
        }
        #expect(mode == .verticalRightToLeft)
        #expect(declaration.value.inherits)
        #expect(CSSPropertyId("writing-mode") == .writingMode)
        #expect(CSSPropertyId.writingMode.name == "writing-mode")
        #expect(CSSPropertyId.writingMode.inherits)
        #expect(CSSWritingMode.initial == .horizontalTopToBottom)
    }

    @Test("Logical overflow longhands parse as typed properties")
    func logicalOverflowProperties() throws {
        let declarations = try CSSParser(
            "overflow-block: clip; overflow-inline: auto"
        ).declarations

        guard case .overflowBlock(.clip) = declarations[0].value else {
            Issue.record("Expected typed overflow-block")
            return
        }
        guard case .overflowInline(.auto) = declarations[1].value else {
            Issue.record("Expected typed overflow-inline")
            return
        }
        #expect(CSSPropertyId("overflow-block") == .overflowBlock)
        #expect(CSSPropertyId("overflow-inline") == .overflowInline)
    }

    @Test("Underline controls parse as typed inherited properties")
    func underlineControlProperties() throws {
        let declarations = try CSSParser(
            """
            text-underline-offset: 12.5%;
            text-underline-position: right under;
            """
        ).declarations

        guard case let .textUnderlineOffset(.lengthPercentage(.percentage(offset))) =
            declarations[0].value
        else {
            Issue.record("Expected typed text-underline-offset")
            return
        }
        guard case let .textUnderlinePosition(position) = declarations[1].value else {
            Issue.record("Expected typed text-underline-position")
            return
        }

        #expect(offset == CSSPercentage(percent: 12.5))
        #expect(position == .init(mode: .under, side: .right))
        #expect(declarations[0].value.inherits)
        #expect(declarations[1].value.inherits)
        #expect(CSSPropertyId("text-underline-offset") == .textUnderlineOffset)
        #expect(CSSPropertyId.textUnderlineOffset.name == "text-underline-offset")
        #expect(CSSPropertyId.textUnderlineOffset.inherits)
        #expect(CSSPropertyId("text-underline-position") == .textUnderlinePosition)
        #expect(CSSPropertyId.textUnderlinePosition.name == "text-underline-position")
        #expect(CSSPropertyId.textUnderlinePosition.inherits)
        #expect(CSSTextUnderlineOffset.initial == .auto)
        #expect(CSSTextUnderlinePosition.initial == .init())

        var offsetWriter = StringCSSWriter()
        declarations[0].value.serialize(dest: &offsetWriter)
        var positionWriter = StringCSSWriter()
        declarations[1].value.serialize(dest: &positionWriter)
        #expect(offsetWriter.result == "12.5%")
        #expect(positionWriter.result == "under right")
    }

    @Test("Underline position accepts its order-independent grammar")
    func underlinePositionGrammar() throws {
        let declarations = try CSSParser(
            """
            text-underline-position: auto;
            text-underline-position: left;
            text-underline-position: from-font right;
            text-underline-position: left under;
            """
        ).declarations

        let positions = declarations.compactMap { declaration -> CSSTextUnderlinePosition? in
            guard case let .textUnderlinePosition(position) = declaration.value else {
                return nil
            }
            return position
        }

        #expect(positions == [
            .init(),
            .init(side: .left),
            .init(mode: .fromFont, side: .right),
            .init(mode: .under, side: .left),
        ])
        let serialized = declarations.map { declaration in
            var writer = StringCSSWriter()
            declaration.value.serialize(dest: &writer)
            return writer.result
        }
        #expect(serialized == [
            "auto",
            "left",
            "from-font right",
            "under left",
        ])
    }

    @Test("Underline position rejects conflicting grammar components")
    func invalidUnderlinePositionGrammar() throws {
        let declarations = try CSSParser(
            """
            text-underline-position: auto left;
            text-underline-position: under auto;
            text-underline-position: left right;
            """
        ).declarations

        #expect(declarations.count == 3)
        for declaration in declarations {
            guard case .textUnderlinePosition = declaration.value else {
                continue
            }
            Issue.record("Expected conflicting underline position to remain unparsed")
        }
    }
}
