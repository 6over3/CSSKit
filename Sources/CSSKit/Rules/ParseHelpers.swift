// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Parse Important

/// Parses `!important`.
func parseImportant(_ input: Parser) -> Result<Void, BasicParseError> {
    switch input.expectDelim("!") {
    case let .failure(error):
        .failure(error)
    case .success:
        input.expectIdentMatching("important")
    }
}

// MARK: - Single Item Parsing

/// Parses a single declaration, such as an `( /* ... */ )` parenthesis in an `@supports` prelude.
func parseOneDeclaration<P: DeclarationParser>(
    input: Parser,
    parser: inout P
) -> Result<P.Declaration, RuleParseError<P.DeclError>> {
    let start = input.state()
    let startPosition = input.position()

    let result: Result<P.Declaration, ParseError<P.DeclError>> = input.parseEntirely { input in
        guard case let .success(name) = input.expectIdent() else {
            return .failure(input.newError(.endOfInput))
        }
        guard case .success = input.expectColon() else {
            return .failure(input.newError(.endOfInput))
        }
        return parser.parseValue(name: name, input: input, declarationStart: start)
    }

    return result.mapError { RuleParseError(error: $0, slice: input.sliceFrom(startPosition)) }
}

/// Parses a single rule, such as for CSSOM's `CSSStyleSheet.insertRule`.
func parseOneRule<P>(
    input: Parser,
    parser: inout P
) -> Result<P.AtRule, ParseError<P.AtRuleError>>
    where
    P: QualifiedRuleParser & AtRuleParsingDelegate,
    P.QualifiedRule == P.AtRule,
    P.QRError == P.AtRuleError
{
    input.parseEntirely { input in
        input.skipWhitespace()
        let start = input.state()

        var atKeyword: Lexeme?
        if input.nextByte() == UInt8(ascii: "@") {
            if case let .success(.atKeyword(name)) = input.nextIncludingWhitespaceAndComments() {
                atKeyword = name
            } else {
                input.reset(start)
            }
        }

        if let name = atKeyword {
            let atRuleResult = parseAtRuleInternal(start: start, name: name, input: input, parser: &parser)
            return atRuleResult.mapError { $0.error }
        } else {
            return parseQualifiedRuleInternal(start: start, input: input, parser: &parser, nested: false)
        }
    }
}

// MARK: - Internal Parsing Functions

/// Parses an at-rule.
func parseAtRuleInternal<P: AtRuleParsingDelegate>(
    start: ParserState,
    name: Lexeme,
    input: Parser,
    parser: inout P
) -> Result<P.AtRule, RuleParseError<P.AtRuleError>> {
    let delimiters: Delimiters = .semicolon.union(.curlyBracketBlock)
    let result: Result<P.Prelude, ParseError<P.AtRuleError>> = input.parseUntilBefore(delimiters) { input in
        parser.parsePrelude(name: name, input: input)
    }

    switch result {
    case let .success(prelude):
        let ruleResult: Result<P.AtRule, ParseError<P.AtRuleError>>

        switch input.next() {
        case .success(.semicolon), .failure:
            if let atRule = parser.ruleWithoutBlock(prelude: prelude, start: start) {
                ruleResult = .success(atRule)
            } else {
                ruleResult = .failure(input.newUnexpectedTokenError(.semicolon))
            }

        case .success(.curlyBracketBlock):
            ruleResult = input.parseNestedBlock { input in
                parser.parseBlock(prelude: prelude, start: start, input: input)
            }

        case .success:
            fatalError("Unreachable: parseUntilBefore should stop at semicolon or curly bracket")
        }

        return ruleResult.mapError { RuleParseError(error: $0, slice: input.sliceFrom(start.sourcePosition())) }

    case let .failure(error):
        let endPosition = input.position()
        // Consume the semicolon or block
        switch input.next() {
        case .success(.curlyBracketBlock), .success(.semicolon), .failure:
            break
        case .success:
            fatalError("Unreachable")
        }
        return .failure(RuleParseError(error: error, slice: input.slice(start.sourcePosition() ..< endPosition)))
    }
}

/// Checks if the rule looks like a custom property (starts with `--`).
func looksLikeCustomProperty(_ input: Parser) -> Bool {
    guard case let .success(ident) = input.expectIdent() else {
        return false
    }
    return ident.value.hasPrefix("--") && input.expectColon().isOK
}

/// Parses a qualified rule.
/// https://drafts.csswg.org/css-syntax/#consume-a-qualified-rule
func parseQualifiedRuleInternal<P: QualifiedRuleParser>(
    start: ParserState,
    input: Parser,
    parser: inout P,
    nested: Bool
) -> Result<P.QualifiedRule, ParseError<P.QRError>> {
    input.skipWhitespace()

    let prelude: Result<P.QRPrelude, ParseError<P.QRError>>
    do {
        let state = input.state()
        if looksLikeCustomProperty(input) {
            let delimiters: Delimiters = nested ? .semicolon : .curlyBracketBlock
            let _: Result<Void, ParseError<Never>> = input.parseUntilAfter(delimiters) { _ in .success(()) }
            return .failure(state.sourceLocation().newError(.qualifiedRuleInvalid))
        }

        let delims: Delimiters = nested
            ? .semicolon.union(.curlyBracketBlock)
            : .curlyBracketBlock
        input.reset(state)
        prelude = input.parseUntilBefore(delims) { input in
            parser.parsePrelude(input: input)
        }
    }

    guard case .success = input.expectCurlyBracketBlock() else {
        if case let .failure(error) = prelude {
            return .failure(error)
        }
        return .failure(input.newError(.qualifiedRuleInvalid))
    }

    guard case let .success(preludeValue) = prelude else {
        // Prelude failed but we found a block - consume the block for error recovery
        let _: Result<Void, ParseError<Never>> = input.parseNestedBlock { nested in
            while case .success = nested.next() {}
            return .success(())
        }
        guard case let .failure(error) = prelude else {
            fatalError("Unreachable: Result can only be .success or .failure")
        }
        return .failure(error)
    }

    return input.parseNestedBlock { input in
        parser.parseBlock(prelude: preludeValue, start: start, input: input)
    }
}
