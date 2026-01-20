// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A CSS `url()` value.
/// https://www.w3.org/TR/css-values-4/#urls
public struct CSSUrl: Equatable, Sendable, Hashable {
    /// The URL string.
    public let url: String

    /// Creates a URL value.
    public init(_ url: String) {
        self.url = url
    }
}

// MARK: - Parsing

extension CSSUrl {
    /// Parses a `url()` or `<string>` value.
    static func parse(_ input: Parser) -> Result<CSSUrl, BasicParseError> {
        let location = input.currentSourceLocation()

        switch input.next() {
        case let .success(token):
            switch token {
            case let .unquotedUrl(value):
                return .success(CSSUrl(value.value))

            case let .quotedString(value):
                return .success(CSSUrl(value.value))

            case let .function(name) where name.eqIgnoreAsciiCase("url"):
                let result: Result<CSSUrl, ParseError<Never>> = input.parseNestedBlock { args in
                    switch args.expectString() {
                    case let .success(value):
                        .success(CSSUrl(value.value))
                    case let .failure(error):
                        .failure(error.asParseError())
                    }
                }
                switch result {
                case let .success(url):
                    return .success(url)
                case let .failure(error):
                    return .failure(error.basic)
                }

            default:
                return .failure(location.newBasicUnexpectedTokenError(token))
            }

        case let .failure(error):
            return .failure(error)
        }
    }
}

// MARK: - ToCss

extension CSSUrl: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("url(")
        serializeString(url, dest: &dest)
        dest.write(")")
    }
}
