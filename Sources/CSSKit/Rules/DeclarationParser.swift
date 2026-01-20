// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// Parses declaration values with customizable handling.
protocol DeclarationParser {
    /// Finished representation of a declaration.
    associatedtype Declaration

    /// Error type for declaration parsing failures.
    associatedtype DeclError: Equatable

    /// Parses the value of a declaration with the given name.
    func parseValue(
        name: Lexeme,
        input: Parser,
        declarationStart: ParserState
    ) -> Result<Declaration, ParseError<DeclError>>
}

// MARK: - Default Implementation

extension DeclarationParser {
    /// Rejects all declarations.
    func parseValue(
        name: Lexeme,
        input: Parser,
        declarationStart _: ParserState
    ) -> Result<Declaration, ParseError<DeclError>> {
        .failure(input.newError(.unexpectedToken(.ident(name))))
    }
}
