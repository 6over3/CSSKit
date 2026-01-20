// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `@media` rule.
///
/// See: https://drafts.csswg.org/css-conditional-3/#at-media
public struct MediaRule<R: CSSSerializable & Sendable & Equatable>: Sendable, Equatable {
    /// The media query list.
    public let query: MediaList

    /// The rules within the `@media` rule.
    public let rules: [Rule<R>]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a media rule.
    public init(query: MediaList, rules: [Rule<R>], location: SourceLocation = .init()) {
        self.query = query
        self.rules = rules
        self.location = location
    }
}

// MARK: - Serialization

extension MediaRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        // If media query always matches, just output the nested rules
        if query.alwaysMatches {
            for rule in rules {
                rule.serialize(dest: &dest)
                dest.write("\n")
            }
            return
        }

        dest.write("@media ")
        query.serialize(dest: &dest)
        dest.write(" {\n")
        for rule in rules {
            dest.write("  ")
            rule.serialize(dest: &dest)
            dest.write("\n")
        }
        dest.write("}")
    }
}
