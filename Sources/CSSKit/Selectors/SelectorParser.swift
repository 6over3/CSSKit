// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - SelectorList Parsing

extension SelectorList {
    static func parse(_ input: Parser) -> Result<SelectorList, BasicParseError> {
        SelectorParser.parseList(input, forgiving: false, nesting: .none)
    }

    static func parse(_ input: Parser, nesting: NestingRequirement) -> Result<SelectorList, BasicParseError> {
        SelectorParser.parseList(input, forgiving: false, nesting: nesting)
    }

    static func parseForgiving(_ input: Parser) -> Result<SelectorList, BasicParseError> {
        SelectorParser.parseList(input, forgiving: true, nesting: .none)
    }

    static func parseRelative(_ input: Parser) -> Result<SelectorList, BasicParseError> {
        SelectorParser.parseList(input, forgiving: true, nesting: .none, allowRelative: true)
    }
}

// MARK: - Selector Parsing

extension Selector {
    static func parse(_ input: Parser) -> Result<Selector, BasicParseError> {
        SelectorParser.parseSingle(input, allowRelative: false)
    }

    static func parseRelative(_ input: Parser) -> Result<Selector, BasicParseError> {
        SelectorParser.parseSingle(input, allowRelative: true)
    }
}

// MARK: - Stack-Based Parser

private enum SelectorParser {
    // MARK: - Entry Points

    static func parseList(
        _ input: Parser,
        forgiving: Bool,
        nesting: NestingRequirement,
        allowRelative: Bool = false
    ) -> Result<SelectorList, BasicParseError> {
        var selectors: [Selector] = []

        while true {
            input.skipWhitespace()

            switch parseSelector(input, allowRelative: allowRelative) {
            case var .success(selector):
                switch nesting {
                case .none:
                    break
                case .prefixed:
                    guard selector.startsWithNesting else {
                        if forgiving {
                            skipToNextSelector(input)
                            continue
                        }
                        return .failure(input.newBasicError(.qualifiedRuleInvalid))
                    }
                case .contained:
                    guard selector.hasNesting else {
                        if forgiving {
                            skipToNextSelector(input)
                            continue
                        }
                        return .failure(input.newBasicError(.qualifiedRuleInvalid))
                    }
                case .implicit:
                    if !selector.hasNesting {
                        selector = selector.withNestingPrefix()
                    }
                }
                selectors.append(selector)

            case let .failure(error):
                if forgiving {
                    skipToNextSelector(input)
                } else if selectors.isEmpty {
                    return .failure(error)
                } else {
                    break
                }
            }

            input.skipWhitespace()
            if input.tryParse({ $0.expectComma() }).isSuccess {
                continue
            }
            break
        }

        guard !selectors.isEmpty || forgiving else {
            return .failure(input.newBasicError(.qualifiedRuleInvalid))
        }

        return .success(SelectorList(selectors: selectors))
    }

    static func parseSingle(_ input: Parser, allowRelative: Bool) -> Result<Selector, BasicParseError> {
        parseSelector(input, allowRelative: allowRelative)
    }

    // MARK: - Stack-Based Selector Parsing

    private static func parseSelector(
        _ input: Parser,
        allowRelative: Bool
    ) -> Result<Selector, BasicParseError> {
        var stack: [StackFrame] = []
        var parser = input
        var components: [Component] = []
        var state: SelectorParsingState = allowRelative ? .parsingRelative : []
        var currentAllowRelative = allowRelative
        var collectedSelectors: [Selector] = []
        var forgiving = false

        if allowRelative {
            parser.skipWhitespace()
            if let combinator = parseCombinator(parser) {
                components.append(.combinator(combinator))
            }
        }

        mainLoop: while true {
            parser.skipWhitespace()

            switch parseCompound(parser, state: &state, existingComponents: components) {
            case let .success(compound):
                components = compound

            case let .pushFrame(context, nestedParser, partialComponents):
                stack.append(StackFrame(
                    components: partialComponents,
                    state: state,
                    context: context,
                    outerParser: parser,
                    selectors: collectedSelectors,
                    forgiving: forgiving,
                    allowRelative: currentAllowRelative
                ))
                parser = nestedParser
                components = []
                state = []
                collectedSelectors = []
                forgiving = true

                if case .has = context {
                    currentAllowRelative = true
                    parser.skipWhitespace()
                    if let combinator = parseCombinator(parser) {
                        components.append(.combinator(combinator))
                    }
                } else {
                    currentAllowRelative = false
                }
                continue mainLoop

            case let .failure(error):
                if components.isEmpty {
                    if stack.isEmpty {
                        return .failure(error)
                    }
                    if forgiving {
                        skipToNextInBlock(parser)
                        if parser.tryParse({ $0.expectComma() }).isSuccess {
                            continue mainLoop
                        }
                    }
                }
            }

            let beforeCombinator = parser.state()
            parser.skipWhitespace()

            if let combinator = parseCombinator(parser) {
                components.append(.combinator(combinator))
                continue mainLoop
            }

            let afterWhitespace = parser.state()
            if beforeCombinator.position != afterWhitespace.position {
                let start = parser.state()
                if case let .success(token) = parser.next() {
                    parser.reset(start)
                    if canStartCompound(token) {
                        components.append(.combinator(.descendant))
                        continue mainLoop
                    }
                } else {
                    parser.reset(start)
                }
            }

            if let last = components.last, last.isCombinator {
                components.removeLast()
            }

            if !components.isEmpty {
                collectedSelectors.append(Selector(components: components))
            }

            if stack.isEmpty {
                if let sel = collectedSelectors.first {
                    return .success(sel)
                }
                return .failure(input.newBasicError(.qualifiedRuleInvalid))
            }

            parser.skipWhitespace()
            if parser.tryParse({ $0.expectComma() }).isSuccess {
                components = []
                state = currentAllowRelative ? .parsingRelative : []
                if currentAllowRelative {
                    parser.skipWhitespace()
                    if let combinator = parseCombinator(parser) {
                        components.append(.combinator(combinator))
                    }
                }
                continue mainLoop
            }

            let frame = stack.removeLast()
            let list = SelectorList(selectors: collectedSelectors)
            let selector = collectedSelectors.first

            frame.outerParser.finishNestedBlock(.parenthesis)

            let component = buildComponent(frame.context, list: list, selector: selector, state: &state)

            components = frame.components
            components.append(component)
            parser = frame.outerParser
            state = frame.state
            collectedSelectors = frame.selectors
            forgiving = frame.forgiving
            currentAllowRelative = frame.allowRelative
        }
    }

    // MARK: - Compound Parsing

    private enum CompoundResult {
        case success([Component])
        case pushFrame(NestedContext, Parser, [Component])
        case failure(BasicParseError)
    }

    private static func parseCompound(
        _ input: Parser,
        state: inout SelectorParsingState,
        existingComponents: [Component]
    ) -> CompoundResult {
        var components = existingComponents

        let typeComponents = parseTypeSelector(input)
        components.append(contentsOf: typeComponents)

        while true {
            let startState = input.state()

            switch parseSimple(input, state: &state) {
            case let .success(component):
                components.append(component)

            case let .pushFrame(context, nestedParser):
                return .pushFrame(context, nestedParser, components)

            case .failure:
                input.reset(startState)
            }

            if input.state().position == startState.position {
                break
            }
        }

        if components.isEmpty {
            return .failure(input.newBasicError(.qualifiedRuleInvalid))
        }

        return .success(components)
    }

    // MARK: - Type Selector

    private static func parseTypeSelector(_ input: Parser) -> [Component] {
        let start = input.state()

        guard case let .success(token) = input.next() else {
            input.reset(start)
            return []
        }

        switch token {
        case .delim("*"):
            let afterStar = input.state()
            if case .success(.delim("|")) = input.next() {
                if case let .success(nextToken) = input.next() {
                    switch nextToken {
                    case .delim("*"):
                        return [.explicitAnyNamespace, .universal]
                    case let .ident(ident):
                        return [.explicitAnyNamespace, .type(ident.value)]
                    default:
                        break
                    }
                }
                input.reset(start)
                return []
            }
            input.reset(afterStar)
            return [.universal]

        case .delim("|"):
            if case let .success(nextToken) = input.next() {
                switch nextToken {
                case let .ident(ident):
                    return [.explicitNoNamespace, .type(ident.value)]
                case .delim("*"):
                    return [.explicitNoNamespace, .universal]
                default:
                    break
                }
            }
            input.reset(start)
            return []

        case let .ident(ident):
            let identValue = ident.value
            let afterIdent = input.state()
            if case .success(.delim("|")) = input.next() {
                if case let .success(nextToken) = input.next() {
                    switch nextToken {
                    case .delim("*"):
                        return [.namespace(prefix: identValue, url: ""), .universal]
                    case let .ident(elementIdent):
                        return [.namespace(prefix: identValue, url: ""), .type(elementIdent.value)]
                    default:
                        break
                    }
                }
                input.reset(start)
                return []
            }
            input.reset(afterIdent)
            return [.type(identValue)]

        default:
            input.reset(start)
            return []
        }
    }

    // MARK: - Simple Selector

    private enum SimpleResult {
        case success(Component)
        case pushFrame(NestedContext, Parser)
        case failure(BasicParseError)
    }

    private static func parseSimple(
        _ input: Parser,
        state: inout SelectorParsingState
    ) -> SimpleResult {
        let start = input.state()

        guard case let .success(token) = input.next() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        switch token {
        case let .idHash(value):
            return .success(.id(value.value))

        case .delim("."):
            guard case let .success(.ident(ident)) = input.next() else {
                input.reset(start)
                return .failure(input.newBasicError(.qualifiedRuleInvalid))
            }
            return .success(.class(ident.value))

        case .squareBracketBlock:
            switch parseAttribute(input) {
            case let .success(comp):
                return .success(comp)
            case let .failure(err):
                return .failure(err)
            }

        case .colon:
            return parsePseudo(input, state: &state)

        case .delim("&"):
            state.insert(.afterNesting)
            return .success(.nesting)

        default:
            input.reset(start)
            return .failure(input.newBasicError(.qualifiedRuleInvalid))
        }
    }

    // MARK: - Attribute Selector

    private static func parseAttribute(_ input: Parser) -> Result<Component, BasicParseError> {
        let result: Result<Component, ParseError<Never>> = input.parseNestedBlock { parser in
            parser.skipWhitespace()

            var namespace: NamespaceConstraint?
            var name: String

            guard case let .success(firstToken) = parser.next() else {
                return .failure(parser.newError(.qualifiedRuleInvalid))
            }

            switch firstToken {
            case .delim("*"):
                if case .success(.delim("|")) = parser.next() {
                    namespace = .any
                    guard case let .success(.ident(attrIdent)) = parser.next() else {
                        return .failure(parser.newError(.qualifiedRuleInvalid))
                    }
                    name = attrIdent.value
                } else {
                    return .failure(parser.newError(.qualifiedRuleInvalid))
                }

            case .delim("|"):
                namespace = NamespaceConstraint.none
                guard case let .success(.ident(attrIdent)) = parser.next() else {
                    return .failure(parser.newError(.qualifiedRuleInvalid))
                }
                name = attrIdent.value

            case let .ident(ident):
                let afterIdent = parser.state()
                if case .success(.delim("|")) = parser.next() {
                    namespace = .specific(ident.value)
                    guard case let .success(.ident(attrIdent)) = parser.next() else {
                        return .failure(parser.newError(.qualifiedRuleInvalid))
                    }
                    name = attrIdent.value
                } else {
                    parser.reset(afterIdent)
                    name = ident.value
                }

            default:
                return .failure(parser.newError(.qualifiedRuleInvalid))
            }

            parser.skipWhitespace()

            let opStart = parser.state()
            guard case let .success(opToken) = parser.next() else {
                return .success(.attribute(AttributeSelector(name: name, namespace: namespace)))
            }

            let op: AttributeSelectorOperator
            switch opToken {
            case .delim("="):
                op = .equal
            case .includeMatch:
                op = .includes
            case .dashMatch:
                op = .dashMatch
            case .prefixMatch:
                op = .prefix
            case .suffixMatch:
                op = .suffix
            case .substringMatch:
                op = .substring
            default:
                parser.reset(opStart)
                return .success(.attribute(AttributeSelector(name: name, namespace: namespace)))
            }

            parser.skipWhitespace()

            guard case let .success(valueToken) = parser.next() else {
                return .failure(parser.newError(.qualifiedRuleInvalid))
            }

            let value: String
            switch valueToken {
            case let .ident(v):
                value = v.value
            case let .quotedString(v):
                value = v.value
            default:
                return .failure(parser.newError(.qualifiedRuleInvalid))
            }

            parser.skipWhitespace()

            var caseSensitivity: AttributeCaseSensitivity = .caseSensitiveIfHtmlElement
            let flagStart = parser.state()
            if case let .success(.ident(flag)) = parser.next() {
                let flagValue = flag.value.lowercased()
                if flagValue == "i" {
                    caseSensitivity = .asciiCaseInsensitive
                } else if flagValue == "s" {
                    caseSensitivity = .caseSensitive
                } else {
                    parser.reset(flagStart)
                }
            } else {
                parser.reset(flagStart)
            }

            let operation = AttributeOperation(
                operator: op,
                value: value,
                caseSensitivity: caseSensitivity
            )
            return .success(.attribute(AttributeSelector(
                name: name,
                namespace: namespace,
                operation: operation
            )))
        }
        return result.mapError { $0.basic }
    }

    // MARK: - Pseudo Selector

    private static func parsePseudo(
        _ input: Parser,
        state: inout SelectorParsingState
    ) -> SimpleResult {
        let start = input.state()
        var isPseudoElement = false

        if case .success(.colon) = input.next() {
            isPseudoElement = true
        } else {
            input.reset(start)
        }

        guard case let .success(token) = input.next() else {
            return .failure(input.newBasicError(.qualifiedRuleInvalid))
        }

        switch token {
        case let .ident(ident):
            let name = ident.value.lowercased()

            if !isPseudoElement, isCSS2PseudoElement(name) {
                isPseudoElement = true
            }

            if isPseudoElement {
                switch parsePseudoElement(name, state: &state) {
                case let .success(comp):
                    return .success(comp)
                case let .failure(err):
                    return .failure(err)
                }
            } else {
                switch parsePseudoClass(name, input: input, state: &state) {
                case let .success(comp):
                    return .success(comp)
                case let .failure(err):
                    return .failure(err)
                }
            }

        case let .function(fn):
            let name = fn.value.lowercased()
            if isPseudoElement {
                return parseFunctionalPseudoElement(name, input: input, state: &state)
            } else {
                return parseFunctionalPseudoClass(name, input: input, state: &state)
            }

        default:
            return .failure(input.newBasicError(.qualifiedRuleInvalid))
        }
    }

    // MARK: - Pseudo-class

    private static func parsePseudoClass(
        _ name: String,
        input: Parser,
        state: inout SelectorParsingState
    ) -> Result<Component, BasicParseError> {
        let pseudoClass: PseudoClass = switch name {
        case "root": .root
        case "empty": .empty
        case "scope": .scope
        case "first-child": .nth(.first(ofType: false))
        case "last-child": .nth(.last(ofType: false))
        case "only-child": .nth(.only(ofType: false))
        case "first-of-type": .nth(.first(ofType: true))
        case "last-of-type": .nth(.last(ofType: true))
        case "only-of-type": .nth(.only(ofType: true))
        case "hover": .hover
        case "active": .active
        case "focus": .focus
        case "focus-visible": .focusVisible
        case "focus-within": .focusWithin
        case "link": .link
        case "visited": .visited
        case "any-link": .anyLink
        case "local-link": .localLink
        case "target": .target
        case "target-within": .targetWithin
        case "enabled": .enabled
        case "disabled": .disabled
        case "read-only": .readOnly
        case "read-write": .readWrite
        case "placeholder-shown": .placeholderShown
        case "default": .default
        case "checked": .checked
        case "indeterminate": .indeterminate
        case "blank": .blank
        case "valid": .valid
        case "invalid": .invalid
        case "in-range": .inRange
        case "out-of-range": .outOfRange
        case "required": .required
        case "optional": .optional
        case "user-valid": .userValid
        case "user-invalid": .userInvalid
        case "autofill", "-webkit-autofill": .autofill
        case "defined": .defined
        case "host": .host(nil)
        case "fullscreen", "-webkit-full-screen", "-moz-full-screen", "-ms-fullscreen":
            .fullscreen
        case "modal": .modal
        case "picture-in-picture": .pictureInPicture
        case "playing": .playing
        case "paused": .paused
        case "seeking": .seeking
        case "buffering": .buffering
        case "stalled": .stalled
        case "muted": .muted
        case "volume-locked": .volumeLocked
        case "current": .current
        case "past": .past
        case "future": .future
        case "left": .left
        case "right": .right
        case "first": .firstPage
        case "popover-open": .popoverOpen
        default: .custom(name)
        }

        if state.contains(.afterWebkitScrollbar), !pseudoClass.isValidAfterWebkitScrollbar {
            return .failure(input.newBasicError(.qualifiedRuleInvalid))
        }
        if state.contains(.afterViewTransition), !pseudoClass.isValidAfterViewTransition {
            return .failure(input.newBasicError(.qualifiedRuleInvalid))
        }
        if state.contains(.afterPseudoElement),
           !state.contains(.afterWebkitScrollbar),
           !state.contains(.afterViewTransition),
           !pseudoClass.isValidAfterPseudoElement
        {
            return .failure(input.newBasicError(.qualifiedRuleInvalid))
        }

        return .success(.pseudoClass(pseudoClass))
    }

    // MARK: - Functional Pseudo-class

    private static func parseFunctionalPseudoClass(
        _ name: String,
        input: Parser,
        state _: inout SelectorParsingState
    ) -> SimpleResult {
        guard let (nestedParser, _) = input.enterNestedBlock() else {
            return .failure(input.newBasicError(.qualifiedRuleInvalid))
        }

        nestedParser.skipWhitespace()

        switch name {
        case "not":
            return .pushFrame(.not, nestedParser)

        case "is", "matches":
            return .pushFrame(.is, nestedParser)

        case "-webkit-any", "-moz-any":
            let prefix = name.hasPrefix("-webkit-") ? "-webkit-" : "-moz-"
            return .pushFrame(.any(prefix), nestedParser)

        case "where":
            return .pushFrame(.where, nestedParser)

        case "has":
            return .pushFrame(.has, nestedParser)

        case "host":
            return .pushFrame(.host, nestedParser)

        case "host-context":
            return .pushFrame(.hostContext, nestedParser)

        case "current":
            return .pushFrame(.current, nestedParser)

        case "nth-child":
            return parseNthFunctional(input, nestedParser: nestedParser, type: .child)

        case "nth-last-child":
            return parseNthFunctional(input, nestedParser: nestedParser, type: .lastChild)

        case "nth-of-type":
            return parseNthFunctional(input, nestedParser: nestedParser, type: .ofType)

        case "nth-last-of-type":
            return parseNthFunctional(input, nestedParser: nestedParser, type: .lastOfType)

        case "nth-col":
            return parseNthFunctional(input, nestedParser: nestedParser, type: .col)

        case "nth-last-col":
            return parseNthFunctional(input, nestedParser: nestedParser, type: .lastCol)

        case "lang":
            let result = parseLang(nestedParser)
            input.finishNestedBlock(.parenthesis)
            switch result {
            case let .success(comp): return .success(comp)
            case let .failure(err): return .failure(err)
            }

        case "dir":
            let result = parseDir(nestedParser)
            input.finishNestedBlock(.parenthesis)
            switch result {
            case let .success(comp): return .success(comp)
            case let .failure(err): return .failure(err)
            }

        default:
            let start = nestedParser.position()
            while nestedParser.next().isSuccess {}
            let rawArgs = String(nestedParser.sliceFrom(start))
            input.finishNestedBlock(.parenthesis)
            return .success(.pseudoClass(.customFunction(name, rawArgs)))
        }
    }

    // MARK: - Nth Functional

    private static func parseNthFunctional(
        _ input: Parser,
        nestedParser: Parser,
        type: NthType
    ) -> SimpleResult {
        switch parseNth(nestedParser) {
        case .success(let (a, b)):
            nestedParser.skipWhitespace()

            if type.allowsOfSelector {
                let start = nestedParser.state()
                if case let .success(.ident(ident)) = nestedParser.next(),
                   ident.value.lowercased() == "of"
                {
                    nestedParser.skipWhitespace()
                    let data = NthSelectorData(type: type, a: a, b: b)
                    return .pushFrame(.nthOf(data), nestedParser)
                }
                nestedParser.reset(start)
            }

            input.finishNestedBlock(.parenthesis)
            let data = NthSelectorData(type: type, a: a, b: b)
            return .success(.pseudoClass(.nth(data)))

        case let .failure(error):
            input.finishNestedBlock(.parenthesis)
            return .failure(error)
        }
    }

    // MARK: - Lang

    private static func parseLang(_ parser: Parser) -> Result<Component, BasicParseError> {
        var langs: [String] = []

        while true {
            parser.skipWhitespace()

            let start = parser.state()
            switch parser.next() {
            case let .success(.ident(ident)):
                langs.append(ident.value)
            case let .success(.quotedString(str)):
                langs.append(str.value)
            default:
                parser.reset(start)
            }

            parser.skipWhitespace()

            if parser.tryParse({ $0.expectComma() }).isSuccess {
                continue
            }
            break
        }

        guard !langs.isEmpty else {
            return .failure(parser.newBasicError(.qualifiedRuleInvalid))
        }

        return .success(.pseudoClass(.lang(langs)))
    }

    // MARK: - Dir

    private static func parseDir(_ parser: Parser) -> Result<Component, BasicParseError> {
        guard case let .success(.ident(ident)) = parser.next() else {
            return .failure(parser.newBasicError(.qualifiedRuleInvalid))
        }

        guard let dir = Direction(rawValue: ident.value.lowercased()) else {
            return .failure(parser.newBasicError(.qualifiedRuleInvalid))
        }

        return .success(.pseudoClass(.dir(dir)))
    }

    // MARK: - Pseudo-element

    private static func parsePseudoElement(
        _ name: String,
        state: inout SelectorParsingState
    ) -> Result<Component, BasicParseError> {
        let pseudoElement: PseudoElement = switch name {
        case "before": .before
        case "after": .after
        case "first-line": .firstLine
        case "first-letter": .firstLetter
        case "marker": .marker
        case "placeholder": .placeholder
        case "selection": .selection
        case "backdrop": .backdrop
        case "file-selector-button", "-webkit-file-upload-button":
            .fileSelectorButton
        case "cue": .cue
        case "cue-region": .cueRegion
        case "view-transition": .viewTransition
        case "-webkit-scrollbar": .webkitScrollbar
        case "-webkit-scrollbar-button": .webkitScrollbarButton
        case "-webkit-scrollbar-track": .webkitScrollbarTrack
        case "-webkit-scrollbar-track-piece": .webkitScrollbarTrackPiece
        case "-webkit-scrollbar-thumb": .webkitScrollbarThumb
        case "-webkit-scrollbar-corner": .webkitScrollbarCorner
        case "-webkit-resizer": .webkitResizer
        default: .custom(name)
        }

        state.insert(.afterPseudoElement)
        if pseudoElement.isWebkitScrollbar {
            state.insert(.afterWebkitScrollbar)
        }
        if pseudoElement.isViewTransition {
            state.insert(.afterViewTransition)
        }
        return .success(.pseudoElement(pseudoElement))
    }

    // MARK: - Functional Pseudo-element

    private static func parseFunctionalPseudoElement(
        _ name: String,
        input: Parser,
        state: inout SelectorParsingState
    ) -> SimpleResult {
        guard let (nestedParser, _) = input.enterNestedBlock() else {
            return .failure(input.newBasicError(.qualifiedRuleInvalid))
        }

        nestedParser.skipWhitespace()

        switch name {
        case "slotted":
            state.insert(.afterSlotted)
            state.insert(.afterPseudoElement)
            return .pushFrame(.slotted, nestedParser)

        case "cue":
            state.insert(.afterPseudoElement)
            return .pushFrame(.cue, nestedParser)

        case "cue-region":
            state.insert(.afterPseudoElement)
            return .pushFrame(.cueRegion, nestedParser)

        case "part":
            var names: [String] = []
            while case let .success(.ident(ident)) = nestedParser.next() {
                names.append(ident.value)
                nestedParser.skipWhitespace()
            }
            input.finishNestedBlock(.parenthesis)
            guard !names.isEmpty else {
                return .failure(input.newBasicError(.qualifiedRuleInvalid))
            }
            state.insert(.afterPart)
            state.insert(.afterPseudoElement)
            return .success(.pseudoElement(.part(names)))

        case "view-transition-group":
            let vtName = parseViewTransitionName(nestedParser)
            input.finishNestedBlock(.parenthesis)
            state.insert(.afterPseudoElement)
            state.insert(.afterViewTransition)
            return .success(.pseudoElement(.viewTransitionGroup(vtName)))

        case "view-transition-image-pair":
            let vtName = parseViewTransitionName(nestedParser)
            input.finishNestedBlock(.parenthesis)
            state.insert(.afterPseudoElement)
            state.insert(.afterViewTransition)
            return .success(.pseudoElement(.viewTransitionImagePair(vtName)))

        case "view-transition-old":
            let vtName = parseViewTransitionName(nestedParser)
            input.finishNestedBlock(.parenthesis)
            state.insert(.afterPseudoElement)
            state.insert(.afterViewTransition)
            return .success(.pseudoElement(.viewTransitionOld(vtName)))

        case "view-transition-new":
            let vtName = parseViewTransitionName(nestedParser)
            input.finishNestedBlock(.parenthesis)
            state.insert(.afterPseudoElement)
            state.insert(.afterViewTransition)
            return .success(.pseudoElement(.viewTransitionNew(vtName)))

        default:
            let start = nestedParser.position()
            while nestedParser.next().isSuccess {}
            let rawArgs = String(nestedParser.sliceFrom(start))
            input.finishNestedBlock(.parenthesis)
            state.insert(.afterPseudoElement)
            return .success(.pseudoElement(.customFunction(name, rawArgs)))
        }
    }

    private static func parseViewTransitionName(_ parser: Parser) -> String? {
        let start = parser.state()
        guard case let .success(token) = parser.next() else {
            return nil
        }

        switch token {
        case .delim("*"):
            return nil
        case let .ident(ident):
            return ident.value
        default:
            parser.reset(start)
            return nil
        }
    }

    // MARK: - Build Component

    private static func buildComponent(
        _ context: NestedContext,
        list: SelectorList,
        selector: Selector?,
        state: inout SelectorParsingState
    ) -> Component {
        switch context {
        case .not:
            return .pseudoClass(.not(list))
        case .is:
            return .pseudoClass(.is(list))
        case let .any(prefix):
            return .pseudoClass(.any(prefix, list))
        case .where:
            return .pseudoClass(.where(list))
        case .has:
            return .pseudoClass(.has(list))
        case .host:
            return .pseudoClass(.host(selector))
        case .hostContext:
            return .pseudoClass(.hostContext(selector!))
        case .current:
            return .pseudoClass(.currentSelector(list))
        case let .nthOf(data):
            return .pseudoClass(.nthOf(data, list))
        case .slotted:
            state.insert(.afterSlotted)
            state.insert(.afterPseudoElement)
            return .pseudoElement(.slotted(selector!))
        case .cue:
            state.insert(.afterPseudoElement)
            return .pseudoElement(.cueSelector(selector!))
        case .cueRegion:
            state.insert(.afterPseudoElement)
            return .pseudoElement(.cueRegionSelector(selector!))
        }
    }

    // MARK: - Combinator

    private static func parseCombinator(_ input: Parser) -> Combinator? {
        let start = input.state()

        guard case let .success(token) = input.next() else {
            return nil
        }

        switch token {
        case .delim(">"):
            let afterFirst = input.state()
            if case .success(.delim(">")) = input.next() {
                if case .success(.delim(">")) = input.next() {
                    return .deepDescendant
                }
                input.reset(afterFirst)
            } else {
                input.reset(afterFirst)
            }
            return .child

        case .delim("+"):
            return .nextSibling

        case .delim("~"):
            return .laterSibling

        case .delim("/"):
            if case let .success(.ident(ident)) = input.next(),
               ident.value.lowercased() == "deep"
            {
                if case .success(.delim("/")) = input.next() {
                    return .deep
                }
            }
            input.reset(start)
            return nil

        default:
            input.reset(start)
            return nil
        }
    }

    // MARK: - Helpers

    private static func canStartCompound(_ token: Token) -> Bool {
        switch token {
        case .ident, .idHash, .hash, .function, .squareBracketBlock, .colon:
            true
        case let .delim(char):
            char == "." || char == "*" || char == "|" || char == "&"
        default:
            false
        }
    }

    private static func skipToNextSelector(_ input: Parser) {
        var depth = 0
        while true {
            let start = input.state()
            guard case let .success(token) = input.next() else { break }

            switch token {
            case .parenthesisBlock, .squareBracketBlock, .curlyBracketBlock, .function:
                depth += 1
            case .closeParenthesis, .closeSquareBracket, .closeCurlyBracket:
                if depth > 0 { depth -= 1 }
            case .comma where depth == 0:
                input.reset(start)
                return
            default:
                break
            }
        }
    }

    private static func skipToNextInBlock(_ input: Parser) {
        var depth = 0
        while true {
            let start = input.state()
            guard case let .success(token) = input.next() else { break }

            switch token {
            case .parenthesisBlock, .squareBracketBlock, .curlyBracketBlock, .function:
                depth += 1
            case .closeParenthesis, .closeSquareBracket, .closeCurlyBracket:
                if depth > 0 {
                    depth -= 1
                } else {
                    input.reset(start)
                    return
                }
            case .comma where depth == 0:
                input.reset(start)
                return
            default:
                break
            }
        }
    }
}

// MARK: - Stack Frame

private struct StackFrame {
    var components: [Component]
    var state: SelectorParsingState
    var context: NestedContext
    var outerParser: Parser
    var selectors: [Selector]
    var forgiving: Bool
    var allowRelative: Bool
}

// MARK: - Nested Context

private enum NestedContext {
    case not
    case `is`
    case any(String)
    case `where`
    case has
    case host
    case hostContext
    case current
    case nthOf(NthSelectorData)
    case slotted
    case cue
    case cueRegion
}
