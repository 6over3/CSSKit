// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `@starting-style` rule for defining before-change styles in transitions.
///
/// See: https://drafts.csswg.org/css-transitions-2/#defining-before-change-style
public struct StartingStyleRule<R: CSSSerializable & Sendable & Equatable>: Sendable, Equatable {
    /// Nested rules within the `@starting-style` rule.
    public let rules: [Rule<R>]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a starting-style rule.
    public init(rules: [Rule<R>], location: SourceLocation = .init()) {
        self.rules = rules
        self.location = location
    }
}

// MARK: - Serialization

extension StartingStyleRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@starting-style {\n")
        for rule in rules {
            dest.write("  ")
            rule.serialize(dest: &dest)
            dest.write("\n")
        }
        dest.write("}")
    }
}
