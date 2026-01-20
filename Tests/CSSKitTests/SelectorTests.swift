// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

// MARK: - Basic Selector Parsing

@Suite("Selector Parsing")
struct SelectorParsingTests {
    // MARK: - Type Selectors

    @Test("Type selector")
    func typeSelector() throws {
        let list = try parse("div")
        #expect(list.selectors.count == 1)
        #expect(list.text == "div")
    }

    @Test("Universal selector")
    func universalSelector() throws {
        let list = try parse("*")
        #expect(list.text == "*")
    }

    @Test("Universal with explicit any namespace")
    func universalAnyNamespace() throws {
        let list = try parse("*|*")
        #expect(list.selectors.count == 1)
        #expect(list.text == "*|*")
    }

    @Test("Type selector with explicit no namespace")
    func typeNoNamespace() throws {
        let list = try parse("|div")
        #expect(list.selectors.count == 1)
        #expect(list.text == "|div")
    }

    // MARK: - Class & ID Selectors

    @Test("Class selector")
    func classSelector() throws {
        let list = try parse(".foo")
        #expect(list.text == ".foo")
    }

    @Test("ID selector")
    func idSelector() throws {
        let list = try parse("#bar")
        #expect(list.text == "#bar")
    }

    @Test("Compound selector")
    func compoundSelector() throws {
        let list = try parse("div.foo#bar")
        #expect(list.text == "div.foo#bar")
    }

    @Test("Multiple classes")
    func multipleClasses() throws {
        let list = try parse(".a.b.c")
        #expect(list.text == ".a.b.c")
    }

    // MARK: - Combinators

    @Test("Descendant combinator")
    func descendantCombinator() throws {
        let list = try parse("div p")
        #expect(list.text == "div p")
        #expect(list.selectors[0].hasCombinator)
    }

    @Test("Child combinator")
    func childCombinator() throws {
        let list = try parse("div > p")
        #expect(list.text == "div > p")
    }

    @Test("Adjacent sibling combinator")
    func adjacentSiblingCombinator() throws {
        let list = try parse("div + p")
        #expect(list.text == "div + p")
    }

    @Test("General sibling combinator")
    func generalSiblingCombinator() throws {
        let list = try parse("div ~ p")
        #expect(list.text == "div ~ p")
    }

    @Test("Complex combinator chain")
    func complexCombinatorChain() throws {
        let list = try parse("div > p + span ~ a")
        #expect(list.selectors.count == 1)
    }

    // MARK: - Selector Lists

    @Test("Selector list")
    func selectorList() throws {
        let list = try parse("div, p, span")
        #expect(list.selectors.count == 3)
        #expect(list.text == "div, p, span")
    }

    @Test("Selector list with complex selectors")
    func selectorListComplex() throws {
        let list = try parse("div.foo, #bar > p, .a.b")
        #expect(list.selectors.count == 3)
    }

    // MARK: - Attribute Selectors

    @Test("Attribute selector existence")
    func attributeExistence() throws {
        let list = try parse("[disabled]")
        #expect(list.text == "[disabled]")
    }

    @Test("Attribute selector equals")
    func attributeEquals() throws {
        let list = try parse("[type=\"text\"]")
        #expect(list.text == "[type=\"text\"]")
    }

    @Test("Attribute selector contains word")
    func attributeContainsWord() throws {
        let list = try parse("[class~=\"foo\"]")
        #expect(list.text == "[class~=\"foo\"]")
    }

    @Test("Attribute selector dash match")
    func attributeDashMatch() throws {
        let list = try parse("[lang|=\"en\"]")
        #expect(list.text == "[lang|=\"en\"]")
    }

    @Test("Attribute selector starts with")
    func attributeStartsWith() throws {
        let list = try parse("[href^=\"https\"]")
        #expect(list.text == "[href^=\"https\"]")
    }

    @Test("Attribute selector ends with")
    func attributeEndsWith() throws {
        let list = try parse("[src$=\".png\"]")
        #expect(list.text == "[src$=\".png\"]")
    }

    @Test("Attribute selector contains")
    func attributeContains() throws {
        let list = try parse("[title*=\"hello\"]")
        #expect(list.text == "[title*=\"hello\"]")
    }

    @Test("Attribute selector case insensitive")
    func attributeCaseInsensitive() throws {
        let list = try parse("[type=\"text\" i]")
        #expect(list.text == "[type=\"text\" i]")
    }

    @Test("Attribute selector case sensitive")
    func attributeCaseSensitive() throws {
        let list = try parse("[type=\"text\" s]")
        #expect(list.text == "[type=\"text\" s]")
    }

    // MARK: - Pseudo-classes: Tree-structural

    @Test(":root")
    func pseudoClassRoot() throws {
        let list = try parse(":root")
        #expect(list.text == ":root")
    }

    @Test(":empty")
    func pseudoClassEmpty() throws {
        let list = try parse(":empty")
        #expect(list.text == ":empty")
    }

    @Test(":first-child")
    func pseudoClassFirstChild() throws {
        let list = try parse("li:first-child")
        #expect(list.text == "li:first-child")
    }

    @Test(":last-child")
    func pseudoClassLastChild() throws {
        let list = try parse("li:last-child")
        #expect(list.text == "li:last-child")
    }

    @Test(":only-child")
    func pseudoClassOnlyChild() throws {
        let list = try parse("p:only-child")
        #expect(list.text == "p:only-child")
    }

    @Test(":first-of-type")
    func pseudoClassFirstOfType() throws {
        let list = try parse("p:first-of-type")
        #expect(list.text == "p:first-of-type")
    }

    @Test(":last-of-type")
    func pseudoClassLastOfType() throws {
        let list = try parse("p:last-of-type")
        #expect(list.text == "p:last-of-type")
    }

    @Test(":only-of-type")
    func pseudoClassOnlyOfType() throws {
        let list = try parse("p:only-of-type")
        #expect(list.text == "p:only-of-type")
    }

    // MARK: - Pseudo-classes: nth-* with An+B

    @Test(":nth-child(n)")
    func nthChildN() throws {
        let list = try parse("li:nth-child(n)")
        #expect(list.text == "li:nth-child(n)")
    }

    @Test(":nth-child(2n)")
    func nthChild2n() throws {
        let list = try parse("li:nth-child(2n)")
        #expect(list.text == "li:nth-child(2n)")
    }

    @Test(":nth-child(odd)")
    func nthChildOdd() throws {
        let list = try parse("li:nth-child(odd)")
        #expect(list.text == "li:nth-child(odd)")
    }

    @Test(":nth-child(2n+1) serializes as odd")
    func nthChild2nPlus1() throws {
        let list = try parse("li:nth-child(2n+1)")
        #expect(list.text == "li:nth-child(odd)")
    }

    @Test(":nth-child(even)")
    func nthChildEven() throws {
        let list = try parse("li:nth-child(even)")
        #expect(list.text == "li:nth-child(2n)")
    }

    @Test(":nth-child(3)")
    func nthChild3() throws {
        let list = try parse("li:nth-child(3)")
        #expect(list.text == "li:nth-child(3)")
    }

    @Test(":nth-child(3n+2)")
    func nthChild3nPlus2() throws {
        let list = try parse("li:nth-child(3n+2)")
        #expect(list.text == "li:nth-child(3n+2)")
    }

    @Test(":nth-child(-n+3)")
    func nthChildNegativeNPlus3() throws {
        let list = try parse("li:nth-child(-n+3)")
        #expect(list.text == "li:nth-child(-n+3)")
    }

    @Test(":nth-last-child(2)")
    func nthLastChild() throws {
        let list = try parse("li:nth-last-child(2)")
        #expect(list.text == "li:nth-last-child(2)")
    }

    @Test(":nth-of-type(2n)")
    func nthOfType() throws {
        let list = try parse("p:nth-of-type(2n)")
        #expect(list.text == "p:nth-of-type(2n)")
    }

    @Test(":nth-last-of-type(2)")
    func nthLastOfType() throws {
        let list = try parse("p:nth-last-of-type(2)")
        #expect(list.text == "p:nth-last-of-type(2)")
    }

    // MARK: - Pseudo-classes: Logical

    @Test(":not() with class")
    func pseudoClassNotClass() throws {
        let list = try parse("div:not(.hidden)")
        #expect(list.text == "div:not(.hidden)")
    }

    @Test(":not() with id")
    func pseudoClassNotId() throws {
        let list = try parse(":not(#provel.old)")
        #expect(list.text.contains(":not("))
    }

    @Test(":not() with type")
    func pseudoClassNotType() throws {
        let list = try parse(":not(div)")
        #expect(list.text == ":not(div)")
    }

    @Test(":not() with universal")
    func pseudoClassNotUniversal() throws {
        let list = try parse(":not(*)")
        #expect(list.text == ":not(*)")
    }

    @Test(":not() with selector list")
    func pseudoClassNotList() throws {
        let list = try parse(":not(div, .foo)")
        #expect(list.text.contains(":not("))
    }

    @Test(":is() with selector list")
    func pseudoClassIs() throws {
        let list = try parse(":is(h1, h2, h3)")
        #expect(list.text == ":is(h1, h2, h3)")
    }

    @Test(":where() with selector list")
    func pseudoClassWhere() throws {
        let list = try parse(":where(h1, h2)")
        #expect(list.text == ":where(h1, h2)")
    }

    @Test(":has() with child combinator")
    func pseudoClassHasChild() throws {
        let list = try parse("div:has(> p)")
        #expect(list.text.contains(":has("))
    }

    @Test(":has() with descendant")
    func pseudoClassHasDescendant() throws {
        let list = try parse("div:has(p)")
        #expect(list.text.contains(":has("))
    }

    @Test(":has() with sibling combinator")
    func pseudoClassHasSibling() throws {
        let list = try parse("div:has(+ p)")
        #expect(list.text.contains(":has("))
    }

    // MARK: - Pseudo-classes: User Action

    @Test(":hover")
    func pseudoClassHover() throws {
        let list = try parse("a:hover")
        #expect(list.text == "a:hover")
    }

    @Test(":active")
    func pseudoClassActive() throws {
        let list = try parse("button:active")
        #expect(list.text == "button:active")
    }

    @Test(":focus")
    func pseudoClassFocus() throws {
        let list = try parse("input:focus")
        #expect(list.text == "input:focus")
    }

    @Test(":focus-visible")
    func pseudoClassFocusVisible() throws {
        let list = try parse("input:focus-visible")
        #expect(list.text == "input:focus-visible")
    }

    @Test(":focus-within")
    func pseudoClassFocusWithin() throws {
        let list = try parse("form:focus-within")
        #expect(list.text == "form:focus-within")
    }

    // MARK: - Pseudo-classes: Link

    @Test(":link")
    func pseudoClassLink() throws {
        let list = try parse("a:link")
        #expect(list.text == "a:link")
    }

    @Test(":visited")
    func pseudoClassVisited() throws {
        let list = try parse("a:visited")
        #expect(list.text == "a:visited")
    }

    @Test(":any-link")
    func pseudoClassAnyLink() throws {
        let list = try parse("a:any-link")
        #expect(list.text == "a:any-link")
    }

    @Test(":target")
    func pseudoClassTarget() throws {
        let list = try parse(":target")
        #expect(list.text == ":target")
    }

    // MARK: - Pseudo-classes: Input

    @Test(":enabled")
    func pseudoClassEnabled() throws {
        let list = try parse("input:enabled")
        #expect(list.text == "input:enabled")
    }

    @Test(":disabled")
    func pseudoClassDisabled() throws {
        let list = try parse("input:disabled")
        #expect(list.text == "input:disabled")
    }

    @Test(":checked")
    func pseudoClassChecked() throws {
        let list = try parse("input:checked")
        #expect(list.text == "input:checked")
    }

    @Test(":indeterminate")
    func pseudoClassIndeterminate() throws {
        let list = try parse("input:indeterminate")
        #expect(list.text == "input:indeterminate")
    }

    @Test(":valid")
    func pseudoClassValid() throws {
        let list = try parse("input:valid")
        #expect(list.text == "input:valid")
    }

    @Test(":invalid")
    func pseudoClassInvalid() throws {
        let list = try parse("input:invalid")
        #expect(list.text == "input:invalid")
    }

    @Test(":required")
    func pseudoClassRequired() throws {
        let list = try parse("input:required")
        #expect(list.text == "input:required")
    }

    @Test(":optional")
    func pseudoClassOptional() throws {
        let list = try parse("input:optional")
        #expect(list.text == "input:optional")
    }

    @Test(":read-only")
    func pseudoClassReadOnly() throws {
        let list = try parse("input:read-only")
        #expect(list.text == "input:read-only")
    }

    @Test(":read-write")
    func pseudoClassReadWrite() throws {
        let list = try parse("input:read-write")
        #expect(list.text == "input:read-write")
    }

    @Test(":placeholder-shown")
    func pseudoClassPlaceholderShown() throws {
        let list = try parse("input:placeholder-shown")
        #expect(list.text == "input:placeholder-shown")
    }

    // MARK: - Pseudo-classes: Language

    @Test(":lang(en)")
    func pseudoClassLang() throws {
        let list = try parse(":lang(en)")
        #expect(list.text == ":lang(en)")
    }

    @Test(":lang(en-US)")
    func pseudoClassLangEnUS() throws {
        let list = try parse(":lang(en-US)")
        #expect(list.text == ":lang(en-US)")
    }

    @Test(":dir(ltr)")
    func pseudoClassDirLtr() throws {
        let list = try parse(":dir(ltr)")
        #expect(list.text == ":dir(ltr)")
    }

    @Test(":dir(rtl)")
    func pseudoClassDirRtl() throws {
        let list = try parse(":dir(rtl)")
        #expect(list.text == ":dir(rtl)")
    }

    // MARK: - Pseudo-classes: Shadow DOM

    @Test(":host")
    func pseudoClassHost() throws {
        let list = try parse(":host")
        #expect(list.text == ":host")
    }

    @Test(":host() with selector")
    func pseudoClassHostSelector() throws {
        let list = try parse(":host(.active)")
        #expect(list.text == ":host(.active)")
    }

    @Test(":host-context() with selector")
    func pseudoClassHostContext() throws {
        let list = try parse(":host-context(.dark)")
        #expect(list.text == ":host-context(.dark)")
    }

    // MARK: - Pseudo-elements: Standard

    @Test("::before")
    func pseudoElementBefore() throws {
        let list = try parse("p::before")
        #expect(list.text == "p::before")
        #expect(list.selectors[0].hasPseudoElement)
    }

    @Test("::after")
    func pseudoElementAfter() throws {
        let list = try parse("p::after")
        #expect(list.text == "p::after")
    }

    @Test("::first-line")
    func pseudoElementFirstLine() throws {
        let list = try parse("p::first-line")
        #expect(list.text == "p::first-line")
    }

    @Test("::first-letter")
    func pseudoElementFirstLetter() throws {
        let list = try parse("p::first-letter")
        #expect(list.text == "p::first-letter")
    }

    @Test("::marker")
    func pseudoElementMarker() throws {
        let list = try parse("li::marker")
        #expect(list.text == "li::marker")
    }

    @Test("::placeholder")
    func pseudoElementPlaceholder() throws {
        let list = try parse("input::placeholder")
        #expect(list.text == "input::placeholder")
    }

    @Test("::selection")
    func pseudoElementSelection() throws {
        let list = try parse("::selection")
        #expect(list.text == "::selection")
    }

    @Test("::backdrop")
    func pseudoElementBackdrop() throws {
        let list = try parse("dialog::backdrop")
        #expect(list.text == "dialog::backdrop")
    }

    // MARK: - Pseudo-elements: CSS2 single colon

    @Test(":before (CSS2 syntax)")
    func css2Before() throws {
        let list = try parse("p:before")
        #expect(list.selectors[0].hasPseudoElement)
    }

    @Test(":after (CSS2 syntax)")
    func css2After() throws {
        let list = try parse("p:after")
        #expect(list.selectors[0].hasPseudoElement)
    }

    @Test(":first-line (CSS2 syntax)")
    func css2FirstLine() throws {
        let list = try parse("p:first-line")
        #expect(list.selectors[0].hasPseudoElement)
    }

    @Test(":first-letter (CSS2 syntax)")
    func css2FirstLetter() throws {
        let list = try parse("p:first-letter")
        #expect(list.selectors[0].hasPseudoElement)
    }

    // MARK: - Pseudo-elements: Shadow DOM

    @Test("::slotted() with selector")
    func pseudoElementSlotted() throws {
        let list = try parse("::slotted(div)")
        #expect(list.text == "::slotted(div)")
        #expect(list.selectors[0].hasSlotted)
    }

    @Test("::part() with name")
    func pseudoElementPart() throws {
        let list = try parse("::part(button)")
        #expect(list.text == "::part(button)")
        #expect(list.selectors[0].hasPart)
    }

    @Test("::part() with multiple names")
    func pseudoElementPartMultiple() throws {
        let list = try parse("::part(foo bar)")
        #expect(list.text == "::part(foo bar)")
    }

    // MARK: - Pseudo-elements: View Transitions

    @Test("::view-transition")
    func pseudoElementViewTransition() throws {
        let list = try parse("::view-transition")
        #expect(list.text == "::view-transition")
    }

    @Test("::view-transition-group(name)")
    func pseudoElementViewTransitionGroup() throws {
        let list = try parse("::view-transition-group(header)")
        #expect(list.text == "::view-transition-group(header)")
    }

    // MARK: - Pseudo-elements: WebKit Scrollbar

    @Test("::-webkit-scrollbar")
    func webkitScrollbar() throws {
        let list = try parse("::-webkit-scrollbar")
        #expect(list.text == "::-webkit-scrollbar")
    }

    @Test("::-webkit-scrollbar-thumb")
    func webkitScrollbarThumb() throws {
        let list = try parse("::-webkit-scrollbar-thumb")
        #expect(list.text == "::-webkit-scrollbar-thumb")
    }

    @Test("::-webkit-scrollbar:hover")
    func webkitScrollbarHover() throws {
        let list = try parse("::-webkit-scrollbar:hover")
        #expect(list.text.contains("::-webkit-scrollbar"))
    }

    // MARK: - Nesting Selector

    @Test("Nesting selector &")
    func nestingSelector() throws {
        let list = try parse("& .child")
        #expect(list.selectors[0].hasNesting)
        #expect(list.selectors[0].startsWithNesting)
    }

    @Test("Nesting in middle")
    func nestingInMiddle() throws {
        let list = try parse(".parent & .child")
        #expect(list.selectors[0].hasNesting)
        #expect(!list.selectors[0].startsWithNesting)
    }

    // MARK: - Complex Selectors

    @Test("Complex selector")
    func complexSelector() throws {
        let list = try parse("div.container > ul.list li:nth-child(odd):not(:last-child) a:hover")
        #expect(list.selectors.count == 1)
    }

    @Test(":not(:hover) ~ label")
    func notHoverSiblingLabel() throws {
        let list = try parse(":not(:hover) ~ label")
        #expect(list.text.contains(":not("))
        #expect(list.text.contains("~ label"))
    }

    @Test("foo:where(div, foo, .bar baz)")
    func whereComplex() throws {
        let list = try parse("foo:where(div, foo, .bar baz)")
        #expect(list.text.contains(":where("))
    }

    private func parse(_ css: String) throws -> SelectorList {
        let parser = Parser(css: css)
        guard case let .success(list) = SelectorList.parse(parser) else {
            throw BasicParseError(kind: .unexpectedToken(.ident(Lexeme(""))), location: .init())
        }
        return list
    }
}

// MARK: - Specificity Tests

@Suite("Selector Specificity")
struct SelectorSpecificityTests {
    @Test("Universal selector has zero specificity")
    func universalZero() throws {
        let spec = specificity("*")
        #expect(spec == SelectorSpecificity.zero)
    }

    @Test("Type selector")
    func typeSpecificity() throws {
        let spec = specificity("div")
        #expect(spec == SelectorSpecificity(ids: 0, classes: 0, elements: 1))
    }

    @Test("Class selector")
    func classSpecificity() throws {
        let spec = specificity(".foo")
        #expect(spec == SelectorSpecificity(ids: 0, classes: 1, elements: 0))
    }

    @Test("ID selector")
    func idSpecificity() throws {
        let spec = specificity("#bar")
        #expect(spec == SelectorSpecificity(ids: 1, classes: 0, elements: 0))
    }

    @Test("Compound selector adds up")
    func compoundAdds() throws {
        let spec = specificity("div.foo#bar")
        #expect(spec == SelectorSpecificity(ids: 1, classes: 1, elements: 1))
    }

    @Test("Multiple classes")
    func multipleClasses() throws {
        let spec = specificity(".a.b.c")
        #expect(spec == SelectorSpecificity(ids: 0, classes: 3, elements: 0))
    }

    @Test("Attribute selector counts as class")
    func attributeAsClass() throws {
        let spec = specificity("[type=\"text\"]")
        #expect(spec == SelectorSpecificity(ids: 0, classes: 1, elements: 0))
    }

    @Test("Pseudo-class counts as class")
    func pseudoClassAsClass() throws {
        let spec = specificity(":hover")
        #expect(spec == SelectorSpecificity(ids: 0, classes: 1, elements: 0))
    }

    @Test("Pseudo-element counts as element")
    func pseudoElementAsElement() throws {
        let spec = specificity("::before")
        #expect(spec == SelectorSpecificity(ids: 0, classes: 0, elements: 1))
    }

    @Test(":where() has zero specificity")
    func whereZero() throws {
        let spec = specificity(":where(.foo, #bar)")
        #expect(spec == SelectorSpecificity.zero)
    }

    @Test(":is() takes max specificity")
    func isMaxSpecificity() throws {
        let spec = specificity(":is(.foo, #bar)")
        #expect(spec == SelectorSpecificity(ids: 1, classes: 0, elements: 0))
    }

    @Test(":not() takes max specificity")
    func notMaxSpecificity() throws {
        let spec = specificity(":not(.a, .b.c)")
        #expect(spec == SelectorSpecificity(ids: 0, classes: 2, elements: 0))
    }

    @Test("Complex selector specificity")
    func complexSpecificity() throws {
        // div.foo > p#main:hover::before
        // = 1 element + 1 class + 1 element + 1 id + 1 class + 1 element
        // =
        let spec = specificity("div.foo > p#main:hover::before")
        #expect(spec == SelectorSpecificity(ids: 1, classes: 2, elements: 3))
    }

    @Test("Specificity comparison: classes beat elements")
    func classesBeatsElements() {
        let a = SelectorSpecificity(ids: 0, classes: 0, elements: 10)
        let b = SelectorSpecificity(ids: 0, classes: 1, elements: 0)
        #expect(a < b)
    }

    @Test("Specificity comparison: ids beat classes")
    func idsBeatsClasses() {
        let a = SelectorSpecificity(ids: 0, classes: 10, elements: 10)
        let b = SelectorSpecificity(ids: 1, classes: 0, elements: 0)
        #expect(a < b)
    }

    @Test("Nested :not() specificity")
    func nestedNotSpecificity() throws {
        // :not(:not(.foo)) = 1 class
        let spec = specificity(":not(:not(.foo))")
        #expect(spec == SelectorSpecificity(ids: 0, classes: 1, elements: 0))
    }

    private func specificity(_ css: String) -> SelectorSpecificity {
        let parser = Parser(css: css)
        guard case let .success(list) = SelectorList.parse(parser) else {
            return .zero
        }
        return list.selectors[0].specificity
    }
}

// MARK: - Cascade Weight Tests

@Suite("Cascade Weight")
struct CascadeWeightTests {
    @Test("Author beats user beats user-agent")
    func originOrder() {
        let ua = CascadeWeight(origin: .userAgent)
        let user = CascadeWeight(origin: .user)
        let author = CascadeWeight(origin: .author)

        #expect(ua < user)
        #expect(user < author)
    }

    @Test("!important reverses origin order")
    func importantReversesOrigin() {
        let authorImportant = CascadeWeight(origin: .author, isImportant: true)
        let userImportant = CascadeWeight(origin: .user, isImportant: true)
        let uaImportant = CascadeWeight(origin: .userAgent, isImportant: true)

        #expect(authorImportant < userImportant)
        #expect(userImportant < uaImportant)
    }

    @Test("!important beats normal")
    func importantBeatsNormal() {
        let normal = CascadeWeight(origin: .author)
        let important = CascadeWeight(origin: .userAgent, isImportant: true)

        #expect(normal < important)
    }

    @Test("Inline style beats non-inline")
    func inlineBeatsNonInline() {
        let nonInline = CascadeWeight(specificity: SelectorSpecificity(ids: 10, classes: 10, elements: 10))
        let inline = CascadeWeight(isInlineStyle: true)

        #expect(nonInline < inline)
    }

    @Test("Higher specificity wins")
    func specificityWins() {
        let low = CascadeWeight(specificity: SelectorSpecificity(ids: 0, classes: 1, elements: 0))
        let high = CascadeWeight(specificity: SelectorSpecificity(ids: 1, classes: 0, elements: 0))

        #expect(low < high)
    }

    @Test("Later source order wins")
    func sourceOrderWins() {
        let early = CascadeWeight(order: 0)
        let late = CascadeWeight(order: 100)

        #expect(early < late)
    }

    @Test("Unlayered beats layered")
    func unlayeredBeatsLayered() {
        let layered = CascadeWeight(layer: CascadeLayer(parts: ["base"], order: 0))
        let unlayered = CascadeWeight()

        #expect(layered < unlayered)
    }

    @Test("Later layer wins for normal rules")
    func laterLayerWins() {
        let early = CascadeWeight(layer: CascadeLayer(parts: ["a"], order: 0))
        let late = CascadeWeight(layer: CascadeLayer(parts: ["b"], order: 1))

        #expect(early < late)
    }

    @Test("Earlier layer wins for !important")
    func earlierLayerWinsImportant() {
        let early = CascadeWeight(isImportant: true, layer: CascadeLayer(parts: ["a"], order: 0))
        let late = CascadeWeight(isImportant: true, layer: CascadeLayer(parts: ["b"], order: 1))

        #expect(late < early)
    }

    @Test("Full cascade order: !important author beats normal inline")
    func fullCascadeOrder() {
        let normalInline = CascadeWeight(isInlineStyle: true)
        let importantAuthor = CascadeWeight(origin: .author, isImportant: true)

        #expect(normalInline < importantAuthor)
    }
}

// MARK: - Cascade Resolver Tests

@Suite("Cascade Resolver")
struct CascadeResolverTests {
    @Test("Resolves to highest weight")
    func resolvesHighest() {
        let resolver = CascadeResolver()
        let candidates = [
            (value: "low", weight: CascadeWeight(specificity: SelectorSpecificity(ids: 0, classes: 1, elements: 0))),
            (value: "high", weight: CascadeWeight(specificity: SelectorSpecificity(ids: 1, classes: 0, elements: 0))),
            (value: "medium", weight: CascadeWeight(specificity: SelectorSpecificity(ids: 0, classes: 2, elements: 0))),
        ]

        let winner = resolver.resolve(candidates)
        #expect(winner == "high")
    }

    @Test("Returns nil for empty candidates")
    func emptyReturnsNil() {
        let resolver = CascadeResolver()
        let candidates: [(value: String, weight: CascadeWeight)] = []

        let winner = resolver.resolve(candidates)
        #expect(winner == nil)
    }

    @Test("Sorts by weight ascending")
    func sortsByWeight() {
        let resolver = CascadeResolver()
        let candidates = [
            (value: "c", weight: CascadeWeight(order: 2)),
            (value: "a", weight: CascadeWeight(order: 0)),
            (value: "b", weight: CascadeWeight(order: 1)),
        ]

        let sorted = resolver.sorted(candidates)
        #expect(sorted.map(\.value) == ["a", "b", "c"])
    }
}

// MARK: - Selector List Tests

@Suite("Selector List")
struct SelectorListTests {
    @Test("Max specificity from list")
    func maxSpecificity() throws {
        let parser = Parser(css: ".a, #b, div")
        guard case let .success(list) = SelectorList.parse(parser) else {
            Issue.record("Parse failed")
            return
        }
        #expect(list.maxSpecificity == SelectorSpecificity(ids: 1, classes: 0, elements: 0))
    }

    @Test("isEmpty property")
    func isEmpty() {
        let empty = SelectorList(selectors: [])
        let nonEmpty = SelectorList(Selector(components: [.universal]))

        #expect(empty.isEmpty)
        #expect(!nonEmpty.isEmpty)
    }

    @Test("hasNesting property")
    func hasNesting() {
        let withNesting = SelectorList(Selector(components: [.nesting, .combinator(.descendant), .class("foo")]))
        let withoutNesting = SelectorList(Selector(components: [.class("foo")]))

        #expect(withNesting.hasNesting)
        #expect(!withoutNesting.hasNesting)
    }

    @Test("withNestingPrefix adds & descendant")
    func withNestingPrefix() {
        let list = SelectorList(Selector(components: [.class("foo")]))
        let prefixed = list.withNestingPrefix()

        #expect(prefixed.selectors[0].startsWithNesting)
        #expect(prefixed.text == "& .foo")
    }
}

// MARK: - Cascade Layer Tests

@Suite("Cascade Layer")
struct CascadeLayerTests {
    @Test("Name from parts")
    func nameFromParts() {
        let layer = CascadeLayer(parts: ["framework", "base"], order: 0)
        #expect(layer.name == "framework.base")
    }

    @Test("Empty name for single part")
    func singlePart() {
        let layer = CascadeLayer(parts: ["utilities"], order: 0)
        #expect(layer.name == "utilities")
    }

    @Test("Implicit layer has empty parts")
    func implicitLayer() {
        #expect(CascadeLayer.implicit.parts.isEmpty)
        #expect(CascadeLayer.implicit.order == Int.max)
    }
}

// MARK: - Compound Selector Iterator Tests

@Suite("Compound Selector Iterator")
struct CompoundSelectorIteratorTests {
    @Test("Iterates compound selectors")
    func iteratesCompounds() {
        let selector = Selector(components: [
            .class("a"),
            .combinator(.child),
            .class("b"),
            .id("c"),
            .combinator(.descendant),
            .type("div"),
        ])

        var iterator = selector.compoundSelectors

        let first = iterator.next()
        #expect(first?.compound.count == 1) // .a
        #expect(first?.combinator == .child)

        let second = iterator.next()
        #expect(second?.compound.count == 2) // .b#c
        #expect(second?.combinator == .descendant)

        let third = iterator.next()
        #expect(third?.compound.count == 1) // div
        #expect(third?.combinator == nil)

        let fourth = iterator.next()
        #expect(fourth == nil)
    }
}
