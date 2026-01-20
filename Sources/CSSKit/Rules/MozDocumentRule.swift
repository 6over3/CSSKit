// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `@-moz-document` rule (Firefox-specific).
///
/// Note: Only the `url-prefix()` function with no arguments is supported.
/// This rule is obsolete and only exists for legacy Firefox content.
public struct MozDocumentRule<R: CSSSerializable & Sendable & Equatable>: Sendable, Equatable {
    /// Nested rules within the `@-moz-document` rule.
    public let rules: [Rule<R>]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a -moz-document rule.
    public init(rules: [Rule<R>], location: SourceLocation = .init()) {
        self.rules = rules
        self.location = location
    }
}

// MARK: - Serialization

extension MozDocumentRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@-moz-document url-prefix() {\n")
        for rule in rules {
            dest.write("  ")
            rule.serialize(dest: &dest)
            dest.write("\n")
        }
        dest.write("}")
    }
}
