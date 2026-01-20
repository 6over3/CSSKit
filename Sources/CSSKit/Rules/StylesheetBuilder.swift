// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - StylesheetBuilder

/// Builds a stylesheet by parsing CSS rules, declarations, and at-rules.
final class StylesheetBuilder<P: AtRuleParser>: DeclarationParser,
    AtRuleParsingDelegate,
    QualifiedRuleParser,
    RuleBodyItemParser
{
    // MARK: Type Aliases

    typealias Declaration = Rule<P.AtRule>
    typealias Prelude = StylesheetPrelude<P.AtRule>
    typealias AtRule = Rule<P.AtRule>
    typealias QRPrelude = StylesheetPrelude<P.AtRule>
    typealias QualifiedRule = Rule<P.AtRule>
    typealias DeclError = Never
    typealias AtRuleError = Never
    typealias QRError = Never

    // MARK: Properties

    let ruleParser: P
    var parseDeclarations: Bool { true }
    var parseQualified: Bool { true }

    // MARK: Initialization

    init(ruleParser: P) {
        self.ruleParser = ruleParser
    }
}

// MARK: - DeclarationParser

extension StylesheetBuilder {
    func parseValue(
        name: Lexeme,
        input: Parser,
        declarationStart: ParserState
    ) -> Result<Rule<P.AtRule>, ParseError<Never>> {
        let context = ParsingContext(parser: input)
        let ruleContext = AtRuleContext(location: declarationStart.sourceLocation())

        do {
            if let customDecl = try ruleParser.parseDeclaration(
                name: name.value,
                value: context,
                context: ruleContext
            ) {
                return .success(.style(StyleRule(
                    selectors: nil,
                    declarations: [customDecl],
                    location: declarationStart.sourceLocation()
                )))
            }
        } catch {}

        input.reset(declarationStart)
        _ = input.expectIdent()
        _ = input.expectColon()

        var valueTokens: [String] = []
        var isImportant = false

        tokenLoop: while true {
            let beforeToken = input.state()
            switch input.nextIncludingWhitespace() {
            case let .success(token):
                if case .delim("!") = token {
                    input.reset(beforeToken)
                    if case .success = parseImportant(input), input.isExhausted {
                        isImportant = true
                        break tokenLoop
                    }
                    input.reset(beforeToken)
                    if case let .success(nextToken) = input.nextIncludingWhitespace() {
                        valueTokens.append(nextToken.cssString)
                    }
                    continue
                }
                valueTokens.append(token.cssString)
            case .failure:
                break tokenLoop
            }
        }

        let value = valueTokens.joined().trimmingCharacters(in: .whitespaces)
        let (vendorPrefix, unprefixedName) = CSSVendorPrefix.extract(from: name.value)
        let valueParser = Parser(css: value)

        guard case let .success(parsedValue) = parseCSSProperty(
            name: unprefixedName,
            input: valueParser,
            vendorPrefix: vendorPrefix
        ) else {
            assertionFailure("parseCSSProperty should always succeed with .unparsed fallback")
            return .failure(input.newError(.endOfInput))
        }

        let declaration = CSSKit.Declaration(
            name: name.value,
            value: parsedValue,
            isImportant: isImportant,
            location: declarationStart.sourceLocation()
        )

        return .success(.style(StyleRule(
            selectors: nil,
            declarations: [declaration],
            location: declarationStart.sourceLocation()
        )))
    }
}

// MARK: - AtRuleParsingDelegate

extension StylesheetBuilder {
    func parsePrelude(
        name: Lexeme,
        input: Parser
    ) -> Result<StylesheetPrelude<P.AtRule>, ParseError<Never>> {
        let startState = input.state()
        let context = ParsingContext(parser: input)
        let ruleContext = AtRuleContext(location: startState.sourceLocation())

        do {
            if let result = try ruleParser.parseAtRule(
                name: name.value,
                prelude: context,
                context: ruleContext
            ) {
                return .success(.custom(result))
            }
        } catch {}

        input.reset(startState)
        let prelude = collectTokensAsString(input)
        return .success(.atRule(name: name.value, prelude: prelude))
    }

    func ruleWithoutBlock(
        prelude: StylesheetPrelude<P.AtRule>,
        start: ParserState
    ) -> Rule<P.AtRule>? {
        switch prelude {
        case let .atRule(name, preludeText):
            parseStatementAtRule(name: name, prelude: preludeText, location: start.sourceLocation())
        case .qualifiedRule:
            nil
        case let .custom(result):
            result.asRule
        }
    }

    func parseBlock(
        prelude: StylesheetPrelude<P.AtRule>,
        start: ParserState,
        input: Parser
    ) -> Result<Rule<P.AtRule>, ParseError<Never>> {
        switch prelude {
        case let .atRule(name, preludeText):
            let context = ParsingContext(parser: input)
            let ruleContext = AtRuleContext(location: start.sourceLocation())

            do {
                if let result = try ruleParser.parseAtRuleBlock(
                    name: name,
                    prelude: preludeText,
                    body: context,
                    context: ruleContext
                ) {
                    return .success(result.asRule)
                }
            } catch {}

            let rule = parseBlockAtRule(
                name: name,
                prelude: preludeText,
                input: input,
                location: start.sourceLocation()
            )
            return .success(rule)

        case let .qualifiedRule(selectors):
            let (declarations, nestedRules) = parseBlockContents(input)
            return .success(.style(StyleRule(
                selectors: selectors,
                declarations: declarations,
                rules: nestedRules,
                location: start.sourceLocation()
            )))

        case let .custom(result):
            return .success(result.asRule)
        }
    }
}

// MARK: - QualifiedRuleParser

extension StylesheetBuilder {
    func parsePrelude(input: Parser) -> Result<StylesheetPrelude<P.AtRule>, ParseError<Never>> {
        let selectors: SelectorList? = if case let .success(parsed) = SelectorList.parse(input) {
            parsed
        } else {
            nil
        }
        return .success(.qualifiedRule(selectors: selectors))
    }
}

// MARK: - Token Collection

extension StylesheetBuilder {
    private func collectValueToken(_ token: Token, into tokens: inout [String], parser: Parser) {
        switch token {
        case .function, .parenthesisBlock, .squareBracketBlock:
            tokens.append(token.cssString)
            guard let (nested, blockType) = parser.enterNestedBlock() else { return }
            collectNestedTokens(nested, into: &tokens)
            parser.finishNestedBlock(blockType)
            switch token {
            case .function: tokens.append(")")
            case .parenthesisBlock: tokens.append(")")
            case .squareBracketBlock: tokens.append("]")
            default: break
            }

        default:
            tokens.append(token.cssString)
        }
    }

    private func collectNestedTokens(_ parser: Parser, into tokens: inout [String]) {
        var stack: [(Parser, BlockType, String)] = []
        var current = parser

        while true {
            switch current.nextIncludingWhitespace() {
            case let .success(token):
                switch token {
                case .function, .parenthesisBlock:
                    tokens.append(token.cssString)
                    if let (nested, blockType) = current.enterNestedBlock() {
                        stack.append((current, blockType, ")"))
                        current = nested
                    }

                case .squareBracketBlock:
                    tokens.append(token.cssString)
                    if let (nested, blockType) = current.enterNestedBlock() {
                        stack.append((current, blockType, "]"))
                        current = nested
                    }

                default:
                    tokens.append(token.cssString)
                }

            case .failure:
                guard let (parent, blockType, suffix) = stack.popLast() else { return }
                tokens.append(suffix)
                parent.finishNestedBlock(blockType)
                current = parent
            }
        }
    }

    private func collectTokensAsString(_ input: Parser) -> String {
        var stack: [TokenCollectionFrame] = []
        var currentParser = input
        var currentTokens: [String] = []

        while true {
            switch currentParser.nextIncludingWhitespace() {
            case let .success(token):
                switch token {
                case let .function(name):
                    if let (nested, blockType) = currentParser.enterNestedBlock() {
                        stack.append(TokenCollectionFrame(
                            parser: currentParser,
                            tokens: currentTokens,
                            prefix: String(name.value) + "(",
                            suffix: ")",
                            blockType: blockType
                        ))
                        currentParser = nested
                        currentTokens = []
                    } else {
                        currentTokens.append(token.cssString)
                    }

                case .parenthesisBlock:
                    if let (nested, blockType) = currentParser.enterNestedBlock() {
                        stack.append(TokenCollectionFrame(
                            parser: currentParser,
                            tokens: currentTokens,
                            prefix: "(",
                            suffix: ")",
                            blockType: blockType
                        ))
                        currentParser = nested
                        currentTokens = []
                    } else {
                        currentTokens.append(token.cssString)
                    }

                case .squareBracketBlock:
                    if let (nested, blockType) = currentParser.enterNestedBlock() {
                        stack.append(TokenCollectionFrame(
                            parser: currentParser,
                            tokens: currentTokens,
                            prefix: "[",
                            suffix: "]",
                            blockType: blockType
                        ))
                        currentParser = nested
                        currentTokens = []
                    } else {
                        currentTokens.append(token.cssString)
                    }

                default:
                    currentTokens.append(token.cssString)
                }

            case .failure:
                if let frame = stack.popLast() {
                    let blockContent = frame.prefix + currentTokens.joined() + frame.suffix
                    frame.parser.finishNestedBlock(frame.blockType)
                    currentParser = frame.parser
                    currentTokens = frame.tokens
                    currentTokens.append(blockContent)
                } else {
                    return currentTokens.joined().trimmingCharacters(in: .whitespaces)
                }
            }
        }
    }
}

// MARK: - Statement At-Rules

extension StylesheetBuilder {
    private func parseStatementAtRule(
        name: String,
        prelude: String,
        location: SourceLocation
    ) -> Rule<P.AtRule> {
        let lowercaseName = name.lowercased()
        let preludeParser = Parser(css: prelude)

        switch lowercaseName {
        case "import":
            if case let .success(rule) = ImportRule.parse(preludeParser) {
                return .importRule(rule)
            }

        case "namespace":
            if case let .success(rule) = NamespaceRule.parse(preludeParser) {
                return .namespace(rule)
            }

        case "layer":
            var names: [LayerName] = []
            while case let .success(ident) = preludeParser.tryParse({ $0.expectIdent() }) {
                var parts = [String(ident.value)]
                while case .success = preludeParser.tryParse({ $0.expectDelim(".") }),
                      case let .success(part) = preludeParser.tryParse({ $0.expectIdent() })
                {
                    parts.append(String(part.value))
                }
                names.append(LayerName(parts: parts))
                _ = preludeParser.tryParse { $0.expectComma() }
            }
            return .layerStatement(LayerStatementRule(names: names, location: location))

        case "custom-media":
            if case let .success(ident) = preludeParser.tryParse({ $0.expectIdent() }) {
                let mediaName = String(ident.value)
                if case let .success(mediaList) = MediaList.parse(preludeParser) {
                    return .customMedia(CustomMediaRule(name: mediaName, query: mediaList, location: location))
                }
            }

        default:
            break
        }

        return .unknown(UnknownAtRule(name: name, prelude: prelude, block: nil, location: location))
    }
}

// MARK: - Block At-Rules

extension StylesheetBuilder {
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    private func parseBlockAtRule(
        name: String,
        prelude: String,
        input: Parser,
        location: SourceLocation
    ) -> Rule<P.AtRule> {
        let lowercaseName = name.lowercased()

        switch lowercaseName {
        case "media":
            return parseMediaRule(prelude: prelude, input: input, location: location)

        case "supports":
            return parseSupportsRule(prelude: prelude, input: input, location: location)

        case "keyframes", "-webkit-keyframes", "-moz-keyframes", "-o-keyframes":
            return parseKeyframesRule(name: name, prelude: prelude, input: input, location: location)

        case "font-face":
            let (declarations, _) = parseBlockContents(input)
            return .fontFace(FontFaceRule(declarations: declarations, location: location))

        case "font-feature-values":
            let families = prelude.split(separator: ",")
                .map { String($0.trimmingCharacters(in: .whitespaces)) }
            let blocks = parseFontFeatureValueBlocks(input)
            return .fontFeatureValues(FontFeatureValuesRule(
                fontFamilies: families,
                blocks: blocks,
                location: location
            ))

        case "font-palette-values":
            let (declarations, _) = parseBlockContents(input)
            return .fontPaletteValues(FontPaletteValuesRule(
                name: prelude,
                declarations: declarations,
                location: location
            ))

        case "counter-style":
            let (declarations, _) = parseBlockContents(input)
            return .counterStyle(CounterStyleRule(
                name: prelude,
                declarations: declarations,
                location: location
            ))

        case "page":
            let selectors = parsePageSelectors(prelude)
            let (declarations, _) = parseBlockContents(input)
            return .page(PageRule(
                selectors: selectors,
                declarations: declarations,
                marginRules: [],
                location: location
            ))

        case "layer":
            return parseLayerBlockRule(prelude: prelude, input: input, location: location)

        case "container":
            return parseContainerRule(prelude: prelude, input: input, location: location)

        case "scope":
            return parseScopeRule(prelude: prelude, input: input, location: location)

        case "property":
            return parsePropertyRule(prelude: prelude, input: input, location: location)

        case "starting-style":
            let (_, nestedRules) = parseBlockContents(input)
            return .startingStyle(StartingStyleRule(rules: nestedRules, location: location))

        case "viewport", "-ms-viewport":
            let (declarations, _) = parseBlockContents(input)
            let vendorPrefix: CSSVendorPrefix = name.hasPrefix("-ms-") ? .ms : .none
            return .viewport(ViewportRule(
                vendorPrefix: vendorPrefix,
                declarations: declarations,
                location: location
            ))

        case "view-transition":
            let (declarations, _) = parseBlockContents(input)
            return .viewTransition(ViewTransitionRule(declarations: declarations, location: location))

        case "-moz-document":
            let (_, nestedRules) = parseBlockContents(input)
            return .mozDocument(MozDocumentRule(rules: nestedRules, location: location))

        case "nest":
            let (declarations, nestedRules) = parseBlockContents(input)
            let selectors = prelude.isEmpty ? nil : try? SelectorList.parse(Parser(css: prelude)).get()
            return .nesting(NestingRule(
                selectors: selectors,
                declarations: declarations,
                rules: nestedRules,
                location: location
            ))

        default:
            return parseUnknownAtRule(name: name, prelude: prelude, input: input, location: location)
        }
    }

    private func parseMediaRule(
        prelude: String,
        input: Parser,
        location: SourceLocation
    ) -> Rule<P.AtRule> {
        let preludeParser = Parser(css: prelude)
        let mediaList: MediaList = if case let .success(list) = MediaList.parse(preludeParser) {
            list
        } else {
            MediaList(queries: [])
        }
        let (_, nestedRules) = parseBlockContents(input)
        return .media(MediaRule(query: mediaList, rules: nestedRules, location: location))
    }

    private func parseSupportsRule(
        prelude: String,
        input: Parser,
        location: SourceLocation
    ) -> Rule<P.AtRule> {
        let preludeParser = Parser(css: prelude)
        let condition: SupportsCondition = if case let .success(cond) = SupportsCondition.parse(preludeParser) {
            cond
        } else {
            .unknown(prelude)
        }
        let (_, nestedRules) = parseBlockContents(input)
        return .supports(SupportsRule(condition: condition, rules: nestedRules, location: location))
    }

    private func parseKeyframesRule(
        name: String,
        prelude: String,
        input: Parser,
        location: SourceLocation
    ) -> Rule<P.AtRule> {
        let preludeParser = Parser(css: prelude)
        let keyframeName: KeyframesName = switch KeyframesName.parse(preludeParser) {
        case let .success(parsed):
            parsed
        case .failure:
            .ident("")
        }

        let keyframes = parseKeyframes(input)

        let vendorPrefix: CSSVendorPrefix = if name.hasPrefix("-webkit-") {
            .webkit
        } else if name.hasPrefix("-moz-") {
            .moz
        } else if name.hasPrefix("-o-") {
            .o
        } else {
            .none
        }

        return .keyframes(KeyframesRule(
            name: keyframeName,
            keyframes: keyframes,
            vendorPrefix: vendorPrefix,
            location: location
        ))
    }

    private func parseLayerBlockRule(
        prelude: String,
        input: Parser,
        location: SourceLocation
    ) -> Rule<P.AtRule> {
        let layerName: LayerName? = if prelude.isEmpty {
            nil
        } else {
            LayerName(parts: prelude.split(separator: ".").map(String.init))
        }
        let (_, nestedRules) = parseBlockContents(input)
        return .layerBlock(LayerBlockRule(name: layerName, rules: nestedRules, location: location))
    }

    private func parseContainerRule(
        prelude: String,
        input: Parser,
        location: SourceLocation
    ) -> Rule<P.AtRule> {
        let trimmed = prelude.trimmingCharacters(in: .whitespaces)
        let containerName: String?
        let conditionStr: String

        let startsWithCondition = trimmed.hasPrefix("(") ||
            trimmed.lowercased().hasPrefix("not") ||
            trimmed.lowercased().hasPrefix("style(")

        if !startsWithCondition, let spaceIdx = trimmed.firstIndex(of: " ") {
            containerName = String(trimmed[..<spaceIdx])
            conditionStr = String(trimmed[trimmed.index(after: spaceIdx)...])
        } else {
            containerName = nil
            conditionStr = trimmed
        }

        let condition = conditionStr.isEmpty ? nil : try? ContainerCondition.parse(Parser(css: conditionStr)).get()

        let (_, nestedRules) = parseBlockContents(input)
        return .container(ContainerRule(
            name: containerName,
            condition: condition,
            rules: nestedRules,
            location: location
        ))
    }

    private func parseScopeRule(
        prelude: String,
        input: Parser,
        location: SourceLocation
    ) -> Rule<P.AtRule> {
        var startStr: String?
        var endStr: String?

        if let toIndex = prelude.range(of: " to ", options: .caseInsensitive) {
            startStr = String(prelude[..<toIndex.lowerBound]).trimmingCharacters(in: .whitespaces)
            endStr = String(prelude[toIndex.upperBound...]).trimmingCharacters(in: .whitespaces)
        } else if !prelude.isEmpty {
            startStr = prelude
        }

        func parseSelector(_ str: String?) -> SelectorList? {
            guard let str, !str.isEmpty else { return nil }
            var s = str
            if s.hasPrefix("("), s.hasSuffix(")") {
                s = String(s.dropFirst().dropLast())
            }
            return try? SelectorList.parse(Parser(css: s)).get()
        }

        let (_, nestedRules) = parseBlockContents(input)
        return .scope(ScopeRule(
            scopeStart: parseSelector(startStr),
            scopeEnd: parseSelector(endStr),
            rules: nestedRules,
            location: location
        ))
    }

    private func parsePropertyRule(
        prelude: String,
        input: Parser,
        location: SourceLocation
    ) -> Rule<P.AtRule> {
        let (declarations, _) = parseBlockContents(input)
        var syntaxStr = "*"
        var inherits = false
        var initialStr: String?

        for decl in declarations {
            switch decl.name.lowercased() {
            case "syntax":
                let s = decl.rawValue
                if (s.hasPrefix("\"") && s.hasSuffix("\"")) || (s.hasPrefix("'") && s.hasSuffix("'")) {
                    syntaxStr = String(s.dropFirst().dropLast())
                } else {
                    syntaxStr = s
                }
            case "inherits":
                inherits = decl.rawValue.lowercased() == "true"
            case "initial-value":
                initialStr = decl.rawValue
            default:
                break
            }
        }

        let syntax = (try? CSSSyntaxString.parse(string: syntaxStr).get()) ?? .universal

        var initialValue: CSSParsedComponent?
        if let str = initialStr {
            initialValue = try? syntax.parseValue(Parser(css: str)).get()
        }

        return .property(PropertyRule(
            name: prelude,
            syntax: syntax,
            inherits: inherits,
            initialValue: initialValue,
            location: location
        ))
    }

    private func parseUnknownAtRule(
        name: String,
        prelude: String,
        input: Parser,
        location: SourceLocation
    ) -> Rule<P.AtRule> {
        var blockContent = ""
        var depth = 0

        while case let .success(token) = input.nextIncludingWhitespace() {
            if case .curlyBracketBlock = token {
                depth += 1
            } else if case .closeCurlyBracket = token {
                if depth == 0 {
                    break
                }
                depth -= 1
            }
            blockContent += token.cssString
        }

        return .unknown(UnknownAtRule(
            name: name,
            prelude: prelude,
            block: blockContent.isEmpty ? nil : blockContent,
            location: location
        ))
    }
}

// MARK: - Specialized Block Parsers

extension StylesheetBuilder {
    private func parseKeyframes(_ input: Parser) -> [Keyframe] {
        var keyframes: [Keyframe] = []

        while !input.isExhausted {
            input.skipWhitespace()

            var selectors: [KeyframeSelector] = []

            selectorLoop: while true {
                if case .success = input.tryParse({ $0.expectIdentMatching("from") }) {
                    selectors.append(.from)
                } else if case .success = input.tryParse({ $0.expectIdentMatching("to") }) {
                    selectors.append(.to)
                } else if case let .success(pct) = input.tryParse({ $0.expectPercentage() }) {
                    selectors.append(.percentage(pct))
                } else {
                    break selectorLoop
                }

                if case .failure = input.tryParse({ $0.expectComma() }) {
                    break selectorLoop
                }
            }

            if selectors.isEmpty {
                _ = input.next()
                continue
            }

            if case .success = input.tryParse({ $0.expectCurlyBracketBlock() }) {
                if let (nested, blockType) = input.enterNestedBlock() {
                    let (declarations, _) = parseBlockContents(nested)
                    input.finishNestedBlock(blockType)
                    keyframes.append(Keyframe(selectors: selectors, declarations: declarations))
                }
            }
        }

        return keyframes
    }

    private func parseFontFeatureValueBlocks(_ input: Parser) -> [FontFeatureValueBlock] {
        var blocks: [FontFeatureValueBlock] = []

        while !input.isExhausted {
            input.skipWhitespace()

            guard case let .success(token) = input.next(),
                  case let .atKeyword(atKeyword) = token,
                  let featureType = FontFeatureType(rawValue: atKeyword.value.lowercased())
            else {
                continue
            }

            if case .success = input.tryParse({ $0.expectCurlyBracketBlock() }) {
                if let (nested, blockType) = input.enterNestedBlock() {
                    var values: [FontFeatureValue] = []

                    while !nested.isExhausted {
                        nested.skipWhitespace()

                        guard case let .success(ident) = nested.tryParse({ $0.expectIdent() }) else {
                            _ = nested.next()
                            continue
                        }

                        guard case .success = nested.tryParse({ $0.expectColon() }) else {
                            continue
                        }

                        var indices: [Int] = []
                        while case let .success(num) = nested.tryParse({ $0.expectInteger() }) {
                            indices.append(Int(num))
                        }
                        _ = nested.tryParse { $0.expectSemicolon() }
                        values.append(FontFeatureValue(name: String(ident.value), indices: indices))
                    }

                    input.finishNestedBlock(blockType)
                    blocks.append(FontFeatureValueBlock(featureType: featureType, values: values))
                }
            }
        }

        return blocks
    }

    private func parsePageSelectors(_ prelude: String) -> [PageSelector] {
        guard !prelude.isEmpty else {
            return []
        }

        var selectors: [PageSelector] = []

        for part in prelude.split(separator: ",") {
            let trimmed = part.trimmingCharacters(in: .whitespaces)
            var name: String?
            var pseudoClasses: [PagePseudoClass] = []

            let components = trimmed.components(separatedBy: ":")
            if !components.isEmpty, !components[0].isEmpty, !components[0].hasPrefix(":") {
                name = components[0]
            }

            for index in 1 ..< components.count {
                if let pseudo = PagePseudoClass(rawValue: components[index].lowercased()) {
                    pseudoClasses.append(pseudo)
                }
            }

            selectors.append(PageSelector(name: name, pseudoClasses: pseudoClasses))
        }

        return selectors
    }
}

// MARK: - Block Parsing

extension StylesheetBuilder {
    private func parseBlockContents(_ input: Parser) -> ([CSSKit.Declaration], [Rule<P.AtRule>]) {
        typealias Frame = RuleParsingFrame<P.AtRule>

        var stack: [Frame] = []
        var current = Frame(parser: input, blockType: nil, pendingRule: .topLevel)

        while true {
            current.parser.skipWhitespace()

            guard case let .success(token) = current.parser.nextIncludingWhitespaceAndComments() else {
                let assembledRule = assembleRule(
                    pendingRule: current.pendingRule,
                    declarations: current.declarations,
                    nestedRules: current.nestedRules
                )

                if let blockType = current.blockType {
                    current.parser.finishNestedBlock(blockType)
                }

                if var parent = stack.popLast() {
                    if let rule = assembledRule {
                        parent.nestedRules.append(rule)
                    } else {
                        parent.declarations.append(contentsOf: current.declarations)
                        parent.nestedRules.append(contentsOf: current.nestedRules)
                    }
                    current = parent
                    continue
                } else {
                    return (current.declarations, current.nestedRules)
                }
            }

            switch token {
            case .closeCurlyBracket, .whiteSpace, .semicolon, .comment:
                continue

            case let .atKeyword(name):
                processAtKeyword(name: name, current: &current, stack: &stack)

            case let .ident(name):
                processIdent(name: name, current: &current, stack: &stack)

            default:
                processDefault(token: token, current: &current, stack: &stack)
            }
        }
    }

    private func processAtKeyword(
        name: Lexeme,
        current: inout RuleParsingFrame<P.AtRule>,
        stack: inout [RuleParsingFrame<P.AtRule>]
    ) {
        let start = current.parser.state()
        let prelude = collectTokensAsString(current.parser)

        if case .success = current.parser.tryParse({ $0.expectCurlyBracketBlock() }) {
            if let (nested, blockType) = current.parser.enterNestedBlock() {
                if let pending = classifyBlockAtRule(
                    name: String(name.value),
                    prelude: prelude,
                    location: start.sourceLocation()
                ) {
                    stack.append(current)
                    current = RuleParsingFrame(
                        parser: nested,
                        blockType: blockType,
                        pendingRule: pending
                    )
                    return
                } else {
                    var blockContent = ""
                    while case let .success(token) = nested.nextIncludingWhitespace() {
                        blockContent += token.cssString
                    }
                    current.parser.finishNestedBlock(blockType)
                    current.nestedRules.append(.unknown(UnknownAtRule(
                        name: String(name.value),
                        prelude: prelude,
                        block: blockContent.isEmpty ? nil : blockContent,
                        location: start.sourceLocation()
                    )))
                }
            }
        } else {
            let rule = parseStatementAtRule(
                name: String(name.value),
                prelude: prelude,
                location: start.sourceLocation()
            )
            current.nestedRules.append(rule)
        }
    }

    private func processIdent(
        name: Lexeme,
        current: inout RuleParsingFrame<P.AtRule>,
        stack: inout [RuleParsingFrame<P.AtRule>]
    ) {
        let start = current.parser.state()

        if case .success = current.parser.tryParse({ $0.expectColon() }) {
            var valueTokens: [String] = []
            var isImportant = false

            declLoop: while true {
                let beforeToken = current.parser.state()
                switch current.parser.nextIncludingWhitespace() {
                case let .success(token):
                    if case .delim("!") = token {
                        current.parser.reset(beforeToken)
                        if case .success = parseImportant(current.parser) {
                            isImportant = true
                            break declLoop
                        }
                        current.parser.reset(beforeToken)
                        if case let .success(nextToken) = current.parser.nextIncludingWhitespace() {
                            collectValueToken(nextToken, into: &valueTokens, parser: current.parser)
                        }
                        continue
                    }
                    if case .semicolon = token {
                        break declLoop
                    }
                    if case .curlyBracketBlock = token {
                        current.parser.reset(start)
                        break declLoop
                    }
                    collectValueToken(token, into: &valueTokens, parser: current.parser)
                case .failure:
                    break declLoop
                }
            }

            let value = valueTokens.joined().trimmingCharacters(in: .whitespaces)
            if !value.isEmpty {
                let (vendorPrefix, unprefixedName) = CSSVendorPrefix.extract(from: name.value)
                let valueParser = Parser(css: value)
                if case let .success(parsedValue) = parseCSSProperty(
                    name: unprefixedName,
                    input: valueParser,
                    vendorPrefix: vendorPrefix
                ) {
                    let declaration = CSSKit.Declaration(
                        name: String(name.value),
                        value: parsedValue,
                        isImportant: isImportant,
                        location: start.sourceLocation()
                    )
                    current.declarations.append(declaration)
                    return
                }
            }
        }

        current.parser.reset(start)
        processAsQualifiedRule(current: &current, stack: &stack)
    }

    private func processDefault(
        token _: Token,
        current: inout RuleParsingFrame<P.AtRule>,
        stack: inout [RuleParsingFrame<P.AtRule>]
    ) {
        processAsQualifiedRule(current: &current, stack: &stack)
    }

    private func processAsQualifiedRule(
        current: inout RuleParsingFrame<P.AtRule>,
        stack: inout [RuleParsingFrame<P.AtRule>]
    ) {
        let start = current.parser.state()

        let selectors: SelectorList? = if case let .success(parsed) = SelectorList.parse(current.parser) {
            parsed
        } else {
            nil
        }

        if case .success = current.parser.tryParse({ $0.expectCurlyBracketBlock() }) {
            if let (nested, blockType) = current.parser.enterNestedBlock() {
                stack.append(current)
                current = RuleParsingFrame(
                    parser: nested,
                    blockType: blockType,
                    pendingRule: .styleRule(selectors: selectors, location: start.sourceLocation())
                )
                return
            }
        }

        while case let .success(token) = current.parser.nextIncludingWhitespace() {
            if case .semicolon = token {
                break
            }
        }
    }
}

// MARK: - Rule Classification and Assembly

extension StylesheetBuilder {
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    private func classifyBlockAtRule(
        name: String,
        prelude: String,
        location: SourceLocation
    ) -> PendingAtRule? {
        let lowercaseName = name.lowercased()

        switch lowercaseName {
        case "media":
            let preludeParser = Parser(css: prelude)
            let mediaList: MediaList = if case let .success(list) = MediaList.parse(preludeParser) {
                list
            } else {
                MediaList(queries: [])
            }
            return .media(query: mediaList, location: location)

        case "supports":
            let preludeParser = Parser(css: prelude)
            let condition: SupportsCondition = if case let .success(cond) = SupportsCondition.parse(preludeParser) {
                cond
            } else {
                .unknown(prelude)
            }
            return .supports(condition: condition, location: location)

        case "layer":
            let layerName: LayerName? = if prelude.isEmpty {
                nil
            } else {
                LayerName(parts: prelude.split(separator: ".").map(String.init))
            }
            return .layerBlock(name: layerName, location: location)

        case "container":
            let trimmed = prelude.trimmingCharacters(in: .whitespaces)
            let containerName: String?
            let conditionStr: String

            let startsWithCondition = trimmed.hasPrefix("(") ||
                trimmed.lowercased().hasPrefix("not") ||
                trimmed.lowercased().hasPrefix("style(")

            if !startsWithCondition, let spaceIdx = trimmed.firstIndex(of: " ") {
                containerName = String(trimmed[..<spaceIdx])
                conditionStr = String(trimmed[trimmed.index(after: spaceIdx)...])
            } else {
                containerName = nil
                conditionStr = trimmed
            }
            let condition = conditionStr.isEmpty ? nil : try? ContainerCondition.parse(Parser(css: conditionStr)).get()
            return .container(name: containerName, condition: condition, location: location)

        case "scope":
            func parseSelector(_ str: String) -> SelectorList? {
                var s = str.trimmingCharacters(in: .whitespaces)
                if s.hasPrefix("("), s.hasSuffix(")") {
                    s = String(s.dropFirst().dropLast())
                }
                guard !s.isEmpty else { return nil }
                return try? SelectorList.parse(Parser(css: s)).get()
            }

            let scopeStart: SelectorList?
            let scopeEnd: SelectorList?
            if let toIndex = prelude.range(of: " to ", options: .caseInsensitive) {
                scopeStart = parseSelector(String(prelude[..<toIndex.lowerBound]))
                scopeEnd = parseSelector(String(prelude[toIndex.upperBound...]))
            } else if !prelude.isEmpty {
                scopeStart = parseSelector(prelude)
                scopeEnd = nil
            } else {
                scopeStart = nil
                scopeEnd = nil
            }
            return .scope(scopeStart: scopeStart, scopeEnd: scopeEnd, location: location)

        case "starting-style":
            return .startingStyle(location: location)

        case "-moz-document":
            return .mozDocument(location: location)

        case "nest":
            let selectors = prelude.isEmpty ? nil : try? SelectorList.parse(Parser(css: prelude)).get()
            return .nest(selectors: selectors, location: location)

        case "font-face":
            return .fontFace(location: location)

        case "font-palette-values":
            return .fontPaletteValues(name: prelude, families: [], location: location)

        case "counter-style":
            return .counterStyle(name: prelude, location: location)

        case "page":
            let selectors = parsePageSelectors(prelude)
            return .page(selectors: selectors, location: location)

        case "property":
            return .property(name: prelude, location: location)

        case "viewport", "-ms-viewport":
            let vendorPrefix: CSSVendorPrefix = name.hasPrefix("-ms-") ? .ms : .none
            return .viewport(vendorPrefix: vendorPrefix, location: location)

        case "view-transition":
            return .viewTransition(location: location)

        default:
            return nil
        }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    private func assembleRule(
        pendingRule: PendingAtRule,
        declarations: [CSSKit.Declaration],
        nestedRules: [Rule<P.AtRule>]
    ) -> Rule<P.AtRule>? {
        switch pendingRule {
        case .topLevel:
            return nil

        case let .media(query, location):
            return .media(MediaRule(query: query, rules: nestedRules, location: location))

        case let .supports(condition, location):
            return .supports(SupportsRule(condition: condition, rules: nestedRules, location: location))

        case let .layerBlock(name, location):
            return .layerBlock(LayerBlockRule(name: name, rules: nestedRules, location: location))

        case let .container(name, condition, location):
            return .container(ContainerRule(
                name: name,
                condition: condition,
                rules: nestedRules,
                location: location
            ))

        case let .scope(scopeStart, scopeEnd, location):
            return .scope(ScopeRule(
                scopeStart: scopeStart,
                scopeEnd: scopeEnd,
                rules: nestedRules,
                location: location
            ))

        case let .startingStyle(location):
            return .startingStyle(StartingStyleRule(rules: nestedRules, location: location))

        case let .mozDocument(location):
            return .mozDocument(MozDocumentRule(rules: nestedRules, location: location))

        case let .nest(selectors, location):
            return .nesting(NestingRule(
                selectors: selectors,
                declarations: declarations,
                rules: nestedRules,
                location: location
            ))

        case let .styleRule(selectors, location):
            return .style(StyleRule(
                selectors: selectors,
                declarations: declarations,
                rules: nestedRules,
                location: location
            ))

        case let .fontFace(location):
            return .fontFace(FontFaceRule(declarations: declarations, location: location))

        case let .fontPaletteValues(name, _, location):
            return .fontPaletteValues(FontPaletteValuesRule(
                name: name,
                declarations: declarations,
                location: location
            ))

        case let .counterStyle(name, location):
            return .counterStyle(CounterStyleRule(
                name: name,
                declarations: declarations,
                location: location
            ))

        case let .page(selectors, location):
            return .page(PageRule(
                selectors: selectors,
                declarations: declarations,
                marginRules: [],
                location: location
            ))

        case let .property(name, location):
            var syntaxStr = "*"
            var inherits = false
            var initialStr: String?

            for decl in declarations {
                switch decl.name.lowercased() {
                case "syntax":
                    let s = decl.rawValue
                    if (s.hasPrefix("\"") && s.hasSuffix("\"")) || (s.hasPrefix("'") && s.hasSuffix("'")) {
                        syntaxStr = String(s.dropFirst().dropLast())
                    } else {
                        syntaxStr = s
                    }
                case "inherits":
                    inherits = decl.rawValue.lowercased() == "true"
                case "initial-value":
                    initialStr = decl.rawValue
                default:
                    break
                }
            }

            let syntax = (try? CSSSyntaxString.parse(string: syntaxStr).get()) ?? .universal

            var initialValue: CSSParsedComponent?
            if let str = initialStr {
                initialValue = try? syntax.parseValue(Parser(css: str)).get()
            }

            return .property(PropertyRule(
                name: name,
                syntax: syntax,
                inherits: inherits,
                initialValue: initialValue,
                location: location
            ))

        case let .viewport(vendorPrefix, location):
            return .viewport(ViewportRule(
                vendorPrefix: vendorPrefix,
                declarations: declarations,
                location: location
            ))

        case let .viewTransition(location):
            return .viewTransition(ViewTransitionRule(declarations: declarations, location: location))

        case let .keyframes(name, vendorPrefix, location):
            return .keyframes(KeyframesRule(
                name: name,
                keyframes: [],
                vendorPrefix: vendorPrefix,
                location: location
            ))
        }
    }
}

// MARK: - Supporting Types

/// Prelude types for stylesheet parsing.
enum StylesheetPrelude<R: CSSSerializable & Sendable & Equatable> {
    case atRule(name: String, prelude: String)
    case qualifiedRule(selectors: SelectorList?)
    case custom(AtRuleParseResult<R>)
}

private struct TokenCollectionFrame {
    let parser: Parser
    var tokens: [String]
    let prefix: String
    let suffix: String
    let blockType: BlockType
}

private enum PendingAtRule {
    case topLevel
    case media(query: MediaList, location: SourceLocation)
    case supports(condition: SupportsCondition, location: SourceLocation)
    case layerBlock(name: LayerName?, location: SourceLocation)
    case container(name: String?, condition: ContainerCondition?, location: SourceLocation)
    case scope(scopeStart: SelectorList?, scopeEnd: SelectorList?, location: SourceLocation)
    case startingStyle(location: SourceLocation)
    case mozDocument(location: SourceLocation)
    case nest(selectors: SelectorList?, location: SourceLocation)
    case styleRule(selectors: SelectorList?, location: SourceLocation)
    case fontFace(location: SourceLocation)
    case fontPaletteValues(name: String, families: [String], location: SourceLocation)
    case counterStyle(name: String, location: SourceLocation)
    case page(selectors: [PageSelector], location: SourceLocation)
    case property(name: String, location: SourceLocation)
    case viewport(vendorPrefix: CSSVendorPrefix, location: SourceLocation)
    case viewTransition(location: SourceLocation)
    case keyframes(name: KeyframesName, vendorPrefix: CSSVendorPrefix, location: SourceLocation)
}

private struct RuleParsingFrame<R: CSSSerializable & Sendable & Equatable> {
    var parser: Parser
    var blockType: BlockType?
    var pendingRule: PendingAtRule
    var declarations: [CSSKit.Declaration] = []
    var nestedRules: [Rule<R>] = []
}
