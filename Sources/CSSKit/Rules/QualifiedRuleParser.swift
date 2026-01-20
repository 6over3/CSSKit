// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// Parser for qualified rules (style rules, keyframe rules, etc.).
protocol QualifiedRuleParser {
    /// The intermediate representation of a qualified rule prelude.
    associatedtype QRPrelude

    /// The finished representation of a qualified rule.
    associatedtype QualifiedRule

    /// The error type that is included in the ParseError value that can be returned.
    associatedtype QRError: Equatable

    /// Parses the prelude of a qualified rule. For style rules, this is a Selector list.
    ///
    /// Returns the representation of the prelude,
    /// or a failure to ignore the entire qualified rule as invalid.
    ///
    /// The prelude is the part before the `{ /* ... */ }` block.
    ///
    /// The given `input` is a "delimited" parser
    /// that ends where the prelude should end (before the next `{`).
    func parsePrelude(
        input: Parser
    ) -> Result<QRPrelude, ParseError<QRError>>

    /// Parses the content of a `{ /* ... */ }` block for the body of the qualified rule.
    ///
    /// The location passed in is source location of the start of the prelude.
    ///
    /// Returns the finished representation of the qualified rule
    /// as returned by `StyleSheetParser.next()`,
    /// or a failure to ignore the entire qualified rule as invalid.
    func parseBlock(
        prelude: QRPrelude,
        start: ParserState,
        input: Parser
    ) -> Result<QualifiedRule, ParseError<QRError>>
}

// MARK: - Default Implementation

extension QualifiedRuleParser {
    /// Default implementation that rejects all qualified rule preludes.
    func parsePrelude(
        input: Parser
    ) -> Result<QRPrelude, ParseError<QRError>> {
        .failure(input.newError(.qualifiedRuleInvalid))
    }

    /// Default implementation that rejects all qualified rule blocks.
    func parseBlock(
        prelude _: QRPrelude,
        start _: ParserState,
        input: Parser
    ) -> Result<QualifiedRule, ParseError<QRError>> {
        .failure(input.newError(.qualifiedRuleInvalid))
    }
}
