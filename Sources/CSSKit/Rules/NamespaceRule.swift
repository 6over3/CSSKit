// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `@namespace` rule for declaring XML namespaces.
///
/// See: https://drafts.csswg.org/css-namespaces/#declaration
public struct NamespaceRule: Equatable, Sendable, Hashable {
    /// An optional namespace prefix, or `nil` for the default namespace.
    public let prefix: String?

    /// The namespace URL.
    public let url: CSSString

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a namespace rule.
    public init(prefix: String?, url: CSSString, location: SourceLocation = .init()) {
        self.prefix = prefix
        self.url = url
        self.location = location
    }
}

// MARK: - Parsing

extension NamespaceRule {
    /// Parses a `@namespace` rule prelude.
    static func parse(_ input: Parser) -> Result<NamespaceRule, BasicParseError> {
        let location = input.currentSourceLocation()

        // Try to parse optional prefix
        var prefix: String?
        if case let .success(ident) = input.tryParse({ p in p.expectIdent() }) {
            prefix = String(ident.value)
        }

        // Parse URL (either url() or string)
        let url: CSSString
        if case let .success(urlValue) = input.tryParse({ p in CSSUrl.parse(p) }) {
            url = CSSString(urlValue.url)
        } else if case let .success(str) = CSSString.parse(input) {
            url = str
        } else {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(NamespaceRule(prefix: prefix, url: url, location: location))
    }
}

// MARK: - Serialization

extension NamespaceRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@namespace ")
        if let prefix {
            dest.write(prefix)
            dest.write(" ")
        }
        url.serialize(dest: &dest)
        dest.write(";")
    }
}
