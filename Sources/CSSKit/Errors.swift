// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// Details about a `BasicParseError`.
public enum BasicParseErrorKind: Equatable, Sendable {
    /// An unexpected token was encountered.
    case unexpectedToken(Token)

    /// The end of the input was encountered unexpectedly.
    case endOfInput

    /// An `@` rule was encountered that was invalid.
    case atRuleInvalid(Lexeme)

    /// The body of an '@' rule was invalid.
    case atRuleBodyInvalid

    /// A qualified rule was encountered that was invalid.
    case qualifiedRuleInvalid
}

extension BasicParseErrorKind: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .unexpectedToken(token):
            "unexpected token: \(token)"
        case .endOfInput:
            "unexpected end of input"
        case let .atRuleInvalid(rule):
            "invalid @ rule encountered: '@\(rule)'"
        case .atRuleBodyInvalid:
            "invalid @ rule body encountered"
        case .qualifiedRuleInvalid:
            "invalid qualified rule encountered"
        }
    }
}

/// The fundamental parsing errors that can be triggered by built-in parsing routines.
public struct BasicParseError: Error, Equatable, Sendable {
    /// Details of this error.
    public var kind: BasicParseErrorKind

    /// Location where this error occurred.
    public var location: SourceLocation

    public init(kind: BasicParseErrorKind, location: SourceLocation) {
        self.kind = kind
        self.location = location
    }
}

extension BasicParseError: CustomStringConvertible {
    public var description: String {
        "\(kind) at line \(location.line), column \(location.column)"
    }
}

/// Details of a `ParseError`.
public enum ParseErrorKind<CustomError>: Equatable where CustomError: Equatable {
    /// A fundamental parse error from a built-in parsing routine.
    case basic(BasicParseErrorKind)

    /// A parse error reported by downstream consumer code.
    case custom(CustomError)
}

extension ParseErrorKind: Sendable where CustomError: Sendable {}

extension ParseErrorKind: CustomStringConvertible where CustomError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .basic(basic):
            basic.description
        case let .custom(custom):
            custom.description
        }
    }
}

/// Extensible parse errors that can be encountered by client parsing implementations.
public struct ParseError<CustomError>: Error, Equatable where CustomError: Equatable {
    /// Details of this error.
    public var kind: ParseErrorKind<CustomError>

    /// Location where this error occurred.
    public var location: SourceLocation

    public init(kind: ParseErrorKind<CustomError>, location: SourceLocation) {
        self.kind = kind
        self.location = location
    }

    /// Creates a basic parse error.
    public init(basic: BasicParseErrorKind, location: SourceLocation) {
        kind = .basic(basic)
        self.location = location
    }

    /// Creates a custom parse error.
    public init(custom: CustomError, location: SourceLocation) {
        kind = .custom(custom)
        self.location = location
    }

    /// Creates a ParseError from a BasicParseError.
    public init(_ error: BasicParseError) {
        kind = .basic(error.kind)
        location = error.location
    }

    /// The underlying basic parse error, or crashes if this is a custom error.
    public var basic: BasicParseError {
        switch kind {
        case let .basic(basicKind):
            BasicParseError(kind: basicKind, location: location)
        case .custom:
            fatalError("Not a basic parse error")
        }
    }

    /// Convert this error to a different custom error type.
    public func mapCustom<NewError: Equatable>(_ transform: (CustomError) -> NewError) -> ParseError<NewError> {
        switch kind {
        case let .basic(basicKind):
            ParseError<NewError>(basic: basicKind, location: location)
        case let .custom(customError):
            ParseError<NewError>(custom: transform(customError), location: location)
        }
    }
}

extension ParseError: Sendable where CustomError: Sendable {}

extension ParseError: CustomStringConvertible where CustomError: CustomStringConvertible {
    public var description: String {
        "\(kind) at line \(location.line), column \(location.column)"
    }
}

// MARK: - Conversion from BasicParseError to ParseError

public extension BasicParseError {
    /// Convert to a ParseError with any custom error type.
    func asParseError<CustomError>() -> ParseError<CustomError> {
        ParseError(basic: kind, location: location)
    }
}

// MARK: - SourceLocation Error Creation Helpers

public extension SourceLocation {
    /// Creates a new BasicParseError at this location for an unexpected token.
    func newBasicUnexpectedTokenError(_ token: Token) -> BasicParseError {
        BasicParseError(kind: .unexpectedToken(token), location: self)
    }

    /// Creates a new BasicParseError at this location.
    func newBasicError(_ kind: BasicParseErrorKind) -> BasicParseError {
        BasicParseError(kind: kind, location: self)
    }

    /// Creates a new ParseError at this location for an unexpected token.
    func newUnexpectedTokenError<E>(_ token: Token) -> ParseError<E> {
        ParseError(basic: .unexpectedToken(token), location: self)
    }

    /// Creates a new basic ParseError at this location.
    func newError<E>(_ kind: BasicParseErrorKind) -> ParseError<E> {
        ParseError(basic: kind, location: self)
    }

    /// Creates a new custom ParseError at this location.
    func newCustomError<E: Equatable>(_ error: E) -> ParseError<E> {
        ParseError(custom: error, location: self)
    }
}

/// A type alias for parse errors with no custom error type.
public typealias BasicOnlyParseError = ParseError<Never>
