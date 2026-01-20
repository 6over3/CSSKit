// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `@supports` rule.
///
/// See: https://drafts.csswg.org/css-conditional-3/#at-supports
public struct SupportsRule<R: CSSSerializable & Sendable & Equatable>: Sendable, Equatable {
    /// The supports condition.
    public let condition: SupportsCondition

    /// The rules within the `@supports` rule.
    public let rules: [Rule<R>]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a supports rule.
    public init(condition: SupportsCondition, rules: [Rule<R>], location: SourceLocation = .init()) {
        self.condition = condition
        self.rules = rules
        self.location = location
    }
}

// MARK: - Serialization

extension SupportsRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@supports ")
        condition.serialize(dest: &dest)
        dest.write(" {\n")
        for rule in rules {
            dest.write("  ")
            rule.serialize(dest: &dest)
            dest.write("\n")
        }
        dest.write("}")
    }
}
