// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// Internal protocol for parsing at-rules with customizable handling for prelude and block content.
protocol AtRuleParsingDelegate {
    /// Intermediate representation of an at-rule prelude.
    associatedtype Prelude

    /// Finished representation of an at-rule.
    associatedtype AtRule

    /// Error type for at-rule parsing failures.
    associatedtype AtRuleError: Equatable & Sendable

    /// Parses the prelude of an at-rule with the given name.
    func parsePrelude(
        name: Lexeme,
        input: Parser
    ) -> Result<Prelude, ParseError<AtRuleError>>

    /// Returns the at-rule for a statement (no block), or `nil` if a block is required.
    func ruleWithoutBlock(
        prelude: Prelude,
        start: ParserState
    ) -> AtRule?

    /// Parses the content of a `{ }` block for the at-rule body.
    func parseBlock(
        prelude: Prelude,
        start: ParserState,
        input: Parser
    ) -> Result<AtRule, ParseError<AtRuleError>>
}

// MARK: - Default Implementation

extension AtRuleParsingDelegate {
    /// Rejects all at-rule preludes.
    func parsePrelude(
        name: Lexeme,
        input: Parser
    ) -> Result<Prelude, ParseError<AtRuleError>> {
        .failure(input.newError(.atRuleInvalid(name)))
    }

    /// Rejects at-rules without blocks.
    func ruleWithoutBlock(
        prelude _: Prelude,
        start _: ParserState
    ) -> AtRule? {
        nil
    }

    /// Rejects at-rule blocks.
    func parseBlock(
        prelude _: Prelude,
        start _: ParserState,
        input: Parser
    ) -> Result<AtRule, ParseError<AtRuleError>> {
        .failure(input.newError(.atRuleBodyInvalid))
    }
}
