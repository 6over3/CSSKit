// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Parseable Protocol

/// A type that can be parsed from CSS syntax.
public protocol Parseable {
    /// Parses an instance from CSS tokens.
    static func parse(_ context: ParsingContext) throws -> Self
}

// MARK: - ParsingContext

/// Context for parsing CSS, providing access to tokens and helper methods.
public final class ParsingContext {
    /// The underlying parser.
    let parser: Parser

    /// Creates a parsing context wrapping a parser.
    init(parser: Parser) {
        self.parser = parser
    }

    // MARK: - Position and Location

    /// The current source location.
    public var location: SourceLocation {
        parser.currentSourceLocation()
    }

    /// The current position in the source.
    public var position: SourcePosition {
        parser.position()
    }

    /// Whether the parser has reached the end of input.
    public var isExhausted: Bool {
        parser.isExhausted
    }

    // MARK: - Token Access

    /// Returns the next token, skipping whitespace and comments.
    public func next() throws -> Token {
        switch parser.next() {
        case let .success(token):
            return token
        case let .failure(error):
            throw error
        }
    }

    /// Returns the next token, including whitespace.
    public func nextIncludingWhitespace() throws -> Token {
        switch parser.nextIncludingWhitespace() {
        case let .success(token):
            return token
        case let .failure(error):
            throw error
        }
    }

    /// Skips whitespace tokens.
    public func skipWhitespace() {
        parser.skipWhitespace()
    }

    /// Returns a slice of the source from the given position to current.
    public func sliceFrom(_ start: SourcePosition) -> String {
        String(parser.sliceFrom(start))
    }

    // MARK: - State Management

    /// Saves the current parser state.
    public func saveState() -> ParsingState {
        ParsingState(parser.state())
    }

    /// Restores a previously saved state.
    public func restoreState(_ state: ParsingState) {
        parser.reset(state.inner)
    }

    /// Attempts to parse, restoring state on failure.
    public func tryParse<T>(_ parse: (ParsingContext) throws -> T) -> T? {
        let state = saveState()
        do {
            return try parse(self)
        } catch {
            restoreState(state)
            return nil
        }
    }

    // MARK: - Expect Methods

    /// Expects and returns an identifier token.
    public func expectIdent() throws -> String {
        switch parser.expectIdent() {
        case let .success(ident):
            return ident.value
        case let .failure(error):
            throw error
        }
    }

    /// Expects a specific identifier (case-insensitive).
    public func expectIdentMatching(_ expected: String) throws {
        switch parser.expectIdentMatching(expected) {
        case .success:
            break
        case let .failure(error):
            throw error
        }
    }

    /// Expects and returns a string token.
    public func expectString() throws -> String {
        switch parser.expectString() {
        case let .success(str):
            return str.value
        case let .failure(error):
            throw error
        }
    }

    /// Expects and returns a URL token (quoted or unquoted).
    public func expectUrl() throws -> String {
        switch parser.expectUrl() {
        case let .success(url):
            return url.value
        case let .failure(error):
            throw error
        }
    }

    /// Expects and returns a URL token or a quoted string.
    public func expectUrlOrString() throws -> String {
        switch parser.expectUrlOrString() {
        case let .success(value):
            return value.value
        case let .failure(error):
            throw error
        }
    }

    /// Expects and returns a number token.
    public func expectNumber() throws -> Double {
        switch parser.next() {
        case let .success(.number(numeric)):
            return numeric.value
        case let .success(token):
            throw parser.newBasicUnexpectedTokenError(token)
        case let .failure(error):
            throw error
        }
    }

    /// Expects and returns an integer.
    public func expectInteger() throws -> Int32 {
        switch parser.next() {
        case let .success(.number(numeric)):
            guard let int = numeric.intValue else {
                throw parser.newBasicError(.endOfInput)
            }
            return int
        case let .success(token):
            throw parser.newBasicUnexpectedTokenError(token)
        case let .failure(error):
            throw error
        }
    }

    /// Expects and returns a percentage token.
    public func expectPercentage() throws -> Double {
        switch parser.expectPercentage() {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }

    /// Expects a colon token.
    public func expectColon() throws {
        switch parser.expectColon() {
        case .success:
            break
        case let .failure(error):
            throw error
        }
    }

    /// Expects a semicolon token.
    public func expectSemicolon() throws {
        switch parser.expectSemicolon() {
        case .success:
            break
        case let .failure(error):
            throw error
        }
    }

    /// Expects a comma token.
    public func expectComma() throws {
        switch parser.expectComma() {
        case .success:
            break
        case let .failure(error):
            throw error
        }
    }

    /// Expects a function token and returns its name.
    public func expectFunction() throws -> String {
        switch parser.expectFunction() {
        case let .success(name):
            return name.value
        case let .failure(error):
            throw error
        }
    }

    /// Expects a specific function name (case-insensitive).
    public func expectFunction(_ name: String) throws {
        let fnName = try expectFunction()
        guard fnName.lowercased() == name.lowercased() else {
            throw parser.newBasicUnexpectedTokenError(.function(Lexeme(fnName)))
        }
    }

    /// Expects an opening parenthesis.
    public func expectParenthesisBlock() throws {
        switch parser.expectParenthesisBlock() {
        case .success:
            break
        case let .failure(error):
            throw error
        }
    }

    /// Expects an opening curly brace.
    public func expectCurlyBracketBlock() throws {
        switch parser.expectCurlyBracketBlock() {
        case .success:
            break
        case let .failure(error):
            throw error
        }
    }

    /// Expects a closing parenthesis.
    public func expectCloseParen() throws {
        switch parser.next() {
        case .success(.closeParenthesis):
            break
        case let .success(token):
            throw parser.newBasicUnexpectedTokenError(token)
        case let .failure(error):
            throw error
        }
    }

    // MARK: - Parsing Helpers

    /// Parses comma-separated values.
    public func parseCommaSeparated<T>(_ parse: (ParsingContext) throws -> T) throws -> [T] {
        var results: [T] = []

        try results.append(parse(self))

        while tryParse({ ctx in try ctx.expectComma() }) != nil {
            try results.append(parse(self))
        }

        return results
    }

    /// Parses the contents of a nested block.
    public func parseNestedBlock<T>(_ parse: (ParsingContext) throws -> T) throws -> T {
        let result: Result<T, ParseError<Never>> = parser.parseNestedBlock { innerParser in
            let innerContext = ParsingContext(parser: innerParser)
            do {
                return try .success(parse(innerContext))
            } catch let error as BasicParseError {
                return .failure(ParseError(basic: error.kind, location: error.location))
            } catch {
                return .failure(innerParser.newError(.endOfInput))
            }
        }

        switch result {
        case let .success(value):
            return value
        case let .failure(error):
            throw error.basic
        }
    }

    /// Collects all remaining tokens as a string.
    public func collectRemainingTokens() -> String {
        let start = position
        while case .success = parser.nextIncludingWhitespace() {}
        return sliceFrom(start).trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - ParsingState

/// A saved parser state that can be restored.
public struct ParsingState: Sendable {
    let inner: ParserState

    init(_ state: ParserState) {
        inner = state
    }
}
