// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `@custom-media` rule for defining reusable media queries.
///
/// See: https://drafts.csswg.org/mediaqueries-5/#custom-mq
public struct CustomMediaRule: Equatable, Sendable, Hashable {
    /// The name of the declared media query (e.g., `--narrow-window`).
    public let name: String

    /// The media query list to declare.
    public let query: MediaList

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a custom-media rule.
    public init(name: String, query: MediaList, location: SourceLocation = .init()) {
        self.name = name
        self.query = query
        self.location = location
    }
}

// MARK: - Serialization

extension CustomMediaRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@custom-media ")
        dest.write(name)
        dest.write(" ")
        query.serialize(dest: &dest)
        dest.write(";")
    }
}
