// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// https://drafts.csswg.org/css-syntax/#consume-a-blocks-contents

/// Iterator for parsing rule bodies and declaration lists within a `{ }` block.
final class RuleBodyParser<P: RuleBodyItemParser>: Sequence, IteratorProtocol {
    typealias Element = Result<P.AtRule, RuleParseError<P.AtRuleError>>

    /// The parser input.
    let input: Parser

    /// The rule body item parser.
    var parser: P

    /// Creates a rule body parser with the given input and item parser.
    init(input: Parser, parser: P) {
        self.input = input
        self.parser = parser
    }

    func next() -> Element? {
        while true {
            input.skipWhitespace()
            let start = input.state()

            guard case let .success(token) = input.nextIncludingWhitespaceAndComments() else {
                return nil
            }

            switch token {
            case .closeCurlyBracket, .whiteSpace, .semicolon, .comment:
                continue

            case let .atKeyword(name):
                return .some(parseAtRuleInternal(start: start, name: name, input: input, parser: &parser))

            case let .ident(name) where parser.parseDeclarations:
                let parseQual = parser.parseQualified
                let errorBehavior: ParseUntilErrorBehavior = parseQual ? .stop : .consume
                // When qualified rules are allowed, also stop at '{' so that qualified rules
                // like "a:hover {c:1}" aren't parsed as declarations with block values
                let delimiters: Delimiters = parseQual ? .semicolon.union(.curlyBracketBlock) : .semicolon

                var result: Result<P.AtRule, ParseError<P.AtRuleError>> = input.parseUntilBeforeInternal(
                    delimiters,
                    errorBehavior: errorBehavior
                ) { input -> Result<P.AtRule, ParseError<P.AtRuleError>> in
                    switch input.expectColon() {
                    case let .failure(error):
                        return .failure(error.asParseError())
                    case .success:
                        return parser.parseValue(name: name, input: input, declarationStart: start)
                    }
                }

                // Check what delimiter we stopped at
                let nextByte = input.input.tokenizer.nextByte()
                if parseQual, nextByte == UInt8(ascii: "{") {
                    // Stopped at '{' - this is a qualified rule, not a declaration
                    // Don't consume the '{', just mark as error so qualified rule fallback triggers
                    result = .failure(start.sourceLocation().newBasicError(.endOfInput).asParseError())
                } else if let byte = nextByte, !input.stopBefore.containsAny(Delimiters.fromByte(byte)) {
                    // Consume the delimiter (';') and any trailing content
                    input.input.tokenizer.advance(1)
                }

                if case .failure = result, parseQual {
                    input.reset(start)
                    // We ignore the resulting error here. The property declaration parse error
                    // is likely to be more relevant.
                    if case let .success(qual) = parseQualifiedRuleInternal(
                        start: start,
                        input: input,
                        parser: &parser,
                        nested: true
                    ) {
                        return .success(qual)
                    }
                }

                return .some(result.mapError { RuleParseError(error: $0, slice: input.sliceFrom(start.sourcePosition())) })

            default:
                let result: Result<P.AtRule, ParseError<P.AtRuleError>>
                if parser.parseQualified {
                    input.reset(start)
                    let nested = parser.parseDeclarations
                    result = parseQualifiedRuleInternal(start: start, input: input, parser: &parser, nested: nested)
                } else {
                    let tokenCopy = token
                    result = input.parseUntilAfter(.semicolon) { _ in
                        .failure(start.sourceLocation().newUnexpectedTokenError(tokenCopy))
                    }
                }
                return .some(result.mapError { RuleParseError(error: $0, slice: input.sliceFrom(start.sourcePosition())) })
            }
        }
    }
}
