// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// https://drafts.csswg.org/css-syntax/#consume-a-stylesheets-contents

/// Iterator for parsing top-level rules in a stylesheet.
final class StyleSheetParser<P>: Sequence, IteratorProtocol
    where
    P: QualifiedRuleParser & AtRuleParsingDelegate,
    P.QualifiedRule == P.AtRule,
    P.QRError == P.AtRuleError
{
    typealias Element = Result<P.AtRule, RuleParseError<P.AtRuleError>>

    /// The parser input.
    let input: Parser

    /// The rule parser.
    var parser: P

    /// Whether any rule has been parsed so far.
    private var anyRuleSoFar = false

    /// Creates a stylesheet parser with the given input and rule parser.
    init(input: Parser, parser: P) {
        self.input = input
        self.parser = parser
    }

    func next() -> Element? {
        while true {
            input.skipCdcAndCdo()
            let start = input.state()

            guard let byte = input.nextByte() else {
                return nil
            }

            var atKeyword: Lexeme?
            if byte == UInt8(ascii: "@") {
                if case let .success(.atKeyword(name)) = input.nextIncludingWhitespaceAndComments() {
                    atKeyword = name
                } else {
                    input.reset(start)
                }
            }

            if let name = atKeyword {
                let firstStylesheetRule = !anyRuleSoFar
                anyRuleSoFar = true

                if firstStylesheetRule, name.eqIgnoreAsciiCase("charset") {
                    let delimiters: Delimiters = .semicolon.union(.curlyBracketBlock)
                    let _: Result<Void, ParseError<Never>> = input.parseUntilAfter(delimiters) { _ in .success(()) }
                } else {
                    return .some(parseAtRuleInternal(start: start, name: name, input: input, parser: &parser))
                }
            } else {
                anyRuleSoFar = true
                let result = parseQualifiedRuleInternal(start: start, input: input, parser: &parser, nested: false)
                return .some(result.mapError { RuleParseError(error: $0, slice: input.sliceFrom(start.sourcePosition())) })
            }
        }
    }
}
