// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Parser Expect Methods

extension Parser {
    func expectWhitespace() -> Result<Substring, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch nextIncludingWhitespace() {
        case let .failure(error):
            return .failure(error)
        case let .success(.whiteSpace(value)):
            return .success(value)
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    func expectIdent() -> Result<Lexeme, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case let .success(.ident(value)):
            return .success(value)
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    /// Matches case-insensitively.
    func expectIdentMatching(_ expected: String) -> Result<Void, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case let .success(.ident(value)) where value.eqIgnoreAsciiCase(expected):
            return .success(())
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    func expectString() -> Result<Lexeme, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case let .success(.quotedString(value)):
            return .success(value)
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    func expectIdentOrString() -> Result<Lexeme, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case let .success(.ident(value)):
            return .success(value)
        case let .success(.quotedString(value)):
            return .success(value)
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    func expectUrl() -> Result<Lexeme, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case let .success(.unquotedUrl(value)):
            return .success(value)
        case let .success(.function(name)) where name.eqIgnoreAsciiCase("url"):
            let result: Result<Lexeme, ParseError<Never>> = parseNestedBlock { input in
                input.expectString().mapError { $0.asParseError() }
            }
            switch result {
            case let .success(value):
                return .success(value)
            case let .failure(error):
                return .failure(error.basic)
            }
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    func expectUrlOrString() -> Result<Lexeme, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case let .success(.unquotedUrl(value)):
            return .success(value)
        case let .success(.quotedString(value)):
            return .success(value)
        case let .success(.function(name)) where name.eqIgnoreAsciiCase("url"):
            let result: Result<Lexeme, ParseError<Never>> = parseNestedBlock { input in
                input.expectString().mapError { $0.asParseError() }
            }
            switch result {
            case let .success(value):
                return .success(value)
            case let .failure(error):
                return .failure(error.basic)
            }
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    func expectNumber() -> Result<Double, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case let .success(.number(numeric)):
            return .success(numeric.value)
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    func expectInteger() -> Result<Int32, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case let .success(.number(numeric)):
            if let intValue = numeric.intValue {
                return .success(intValue)
            }
            return .failure(startLocation.newBasicError(.endOfInput))
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    /// `0%` and `100%` map to `0.0` and `1.0` (not `100.0`), respectively.
    func expectPercentage() -> Result<Double, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case let .success(.percentage(numeric)):
            return .success(numeric.value)
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    func expectColon() -> Result<Void, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case .success(.colon):
            return .success(())
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    func expectSemicolon() -> Result<Void, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case .success(.semicolon):
            return .success(())
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    func expectComma() -> Result<Void, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case .success(.comma):
            return .success(())
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    func expectDelim(_ expected: Character) -> Result<Void, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case let .success(.delim(value)) where value == expected:
            return .success(())
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    /// On success, call `parseNestedBlock` to parse the block contents.
    func expectCurlyBracketBlock() -> Result<Void, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case .success(.curlyBracketBlock):
            return .success(())
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    /// On success, call `parseNestedBlock` to parse the block contents.
    func expectSquareBracketBlock() -> Result<Void, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case .success(.squareBracketBlock):
            return .success(())
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    /// On success, call `parseNestedBlock` to parse the block contents.
    func expectParenthesisBlock() -> Result<Void, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case .success(.parenthesisBlock):
            return .success(())
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    /// On success, call `parseNestedBlock` to parse the function arguments.
    func expectFunction() -> Result<Lexeme, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case let .success(.function(name)):
            return .success(name)
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    /// Matches case-insensitively. On success, call `parseNestedBlock` to parse the function arguments.
    func expectFunctionMatching(_ expected: String) -> Result<Void, BasicParseError> {
        let startLocation = currentSourceLocation()
        switch next() {
        case let .failure(error):
            return .failure(error)
        case let .success(.function(name)) where name.eqIgnoreAsciiCase(expected):
            return .success(())
        case let .success(token):
            return .failure(startLocation.newBasicUnexpectedTokenError(token))
        }
    }

    func expectNoErrorToken() -> Result<Void, BasicParseError> {
        while true {
            switch nextIncludingWhitespaceAndComments() {
            case .failure:
                return .success(())
            case let .success(token):
                switch token {
                case .function, .parenthesisBlock, .squareBracketBlock, .curlyBracketBlock:
                    let result: Result<Void, ParseError<Never>> = parseNestedBlock { input in
                        input.expectNoErrorToken().mapError { $0.asParseError() }
                    }
                    if case let .failure(error) = result {
                        return .failure(error.basic)
                    }
                default:
                    if token.isParseError {
                        return .failure(newBasicUnexpectedTokenError(token))
                    }
                }
            }
        }
    }
}
