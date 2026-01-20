// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `@scope` rule.
///
/// See: https://drafts.csswg.org/css-cascade-6/#scope-atrule
public struct ScopeRule<R: CSSSerializable & Sendable & Equatable>: Sendable, Equatable {
    /// A selector list used to identify the scoping root(s).
    public let scopeStart: SelectorList?

    /// A selector list used to identify any scoping limits.
    public let scopeEnd: SelectorList?

    /// Nested rules within the `@scope` rule.
    public let rules: [Rule<R>]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a scope rule.
    public init(
        scopeStart: SelectorList?,
        scopeEnd: SelectorList?,
        rules: [Rule<R>],
        location: SourceLocation = .init()
    ) {
        self.scopeStart = scopeStart
        self.scopeEnd = scopeEnd
        self.rules = rules
        self.location = location
    }
}

// MARK: - Serialization

extension ScopeRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@scope")

        if let scopeStart {
            dest.write(" (")
            scopeStart.serialize(dest: &dest)
            dest.write(")")
        }

        if let scopeEnd {
            dest.write(" to (")
            scopeEnd.serialize(dest: &dest)
            dest.write(")")
        }

        dest.write(" {\n")
        for rule in rules {
            dest.write("  ")
            rule.serialize(dest: &dest)
            dest.write("\n")
        }
        dest.write("}")
    }
}
