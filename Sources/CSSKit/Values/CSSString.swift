// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A CSS `<string>` value.
/// https://www.w3.org/TR/css-values-4/#strings
public struct CSSString: Equatable, Sendable, Hashable {
    /// The string content.
    public let value: String

    /// Creates a CSS string.
    public init(_ value: String) {
        self.value = value
    }
}

// MARK: - Parsing

extension CSSString {
    /// Parses a `<string>` token.
    static func parse(_ input: Parser) -> Result<CSSString, BasicParseError> {
        input.expectString().map { CSSString($0.value) }
    }
}

// MARK: - ToCss

extension CSSString: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        serializeString(value, dest: &dest)
    }
}

// MARK: - ExpressibleByStringLiteral

extension CSSString: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}
