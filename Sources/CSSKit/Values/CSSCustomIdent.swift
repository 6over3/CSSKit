// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A CSS `<custom-ident>` value. https://www.w3.org/TR/css-values-4/#custom-idents
public struct CSSCustomIdent: Equatable, Sendable, Hashable {
    /// The identifier string.
    public let value: String

    /// Creates a custom identifier.
    public init(_ value: String) {
        self.value = value
    }

    /// Reserved CSS-wide keywords that cannot be custom identifiers.
    public static let reservedKeywords: Set<String> = Set(
        CSSWideKeyword.allCases.map(\.rawValue)
    ).union(["default"])

    /// Returns whether the given string is a valid custom identifier.
    public static func isValid(_ value: String) -> Bool {
        let lower = value.lowercased()
        return !reservedKeywords.contains(lower)
    }
}

// MARK: - Parsing

extension CSSCustomIdent {
    /// Parses a `<custom-ident>` value.
    static func parse(_ input: Parser) -> Result<CSSCustomIdent, BasicParseError> {
        let location = input.currentSourceLocation()

        switch input.expectIdent() {
        case let .success(ident):
            let value = ident.value
            if CSSCustomIdent.isValid(value) {
                return .success(CSSCustomIdent(value))
            }
            return .failure(location.newBasicError(.endOfInput))
        case let .failure(error):
            return .failure(error)
        }
    }

    /// Parses a `<custom-ident>`, excluding additional keywords.
    static func parseExcluding(_ input: Parser, keywords: Set<String>) -> Result<CSSCustomIdent, BasicParseError> {
        let location = input.currentSourceLocation()

        switch input.expectIdent() {
        case let .success(ident):
            let value = ident.value
            let lower = value.lowercased()
            if CSSCustomIdent.isValid(value), !keywords.contains(lower) {
                return .success(CSSCustomIdent(value))
            }
            return .failure(location.newBasicError(.endOfInput))
        case let .failure(error):
            return .failure(error)
        }
    }
}

// MARK: - ToCss

extension CSSCustomIdent: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        serializeIdentifier(value, dest: &dest)
    }
}

// MARK: - ExpressibleByStringLiteral

extension CSSCustomIdent: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

// MARK: - CSSDashedIdent

/// A dashed identifier (--custom-property). https://www.w3.org/TR/css-variables-1/
public struct CSSDashedIdent: Equatable, Sendable, Hashable {
    /// The identifier including the leading dashes.
    public let value: String

    /// Creates a dashed identifier.
    public init(_ value: String) {
        self.value = value
    }

    /// Returns the identifier without the leading dashes.
    public var withoutDashes: String {
        if value.hasPrefix("--") {
            return String(value.dropFirst(2))
        }
        return value
    }
}

extension CSSDashedIdent {
    /// Parses a dashed identifier.
    static func parse(_ input: Parser) -> Result<CSSDashedIdent, BasicParseError> {
        let location = input.currentSourceLocation()

        switch input.expectIdent() {
        case let .success(ident):
            let value = ident.value
            if value.hasPrefix("--") {
                return .success(CSSDashedIdent(value))
            }
            return .failure(location.newBasicError(.endOfInput))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSDashedIdent: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        serializeIdentifier(value, dest: &dest)
    }
}
