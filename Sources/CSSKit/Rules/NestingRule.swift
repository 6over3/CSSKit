// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `@nest` rule (legacy nesting syntax).
///
/// See: https://www.w3.org/TR/css-nesting-1/#at-nest
public struct NestingRule<R: CSSSerializable & Sendable & Equatable>: Sendable, Equatable {
    /// The selector for the nested rule.
    public let selectors: SelectorList?

    /// The declarations for this nested rule.
    public let declarations: [Declaration]

    /// Nested rules within this rule.
    public let rules: [Rule<R>]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a nesting rule.
    public init(
        selectors: SelectorList?,
        declarations: [Declaration],
        rules: [Rule<R>] = [],
        location: SourceLocation = .init()
    ) {
        self.selectors = selectors
        self.declarations = declarations
        self.rules = rules
        self.location = location
    }
}

// MARK: - Serialization

extension NestingRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@nest ")
        if let selectors {
            selectors.serialize(dest: &dest)
        }
        dest.write(" {\n")
        for declaration in declarations {
            dest.write("  ")
            declaration.serialize(dest: &dest)
            dest.write("\n")
        }
        for rule in rules {
            dest.write("  ")
            rule.serialize(dest: &dest)
            dest.write("\n")
        }
        dest.write("}")
    }
}

// MARK: - NestedDeclarationsRule

/// A nested declarations rule for declarations that appear after nested rules.
///
/// See: https://drafts.csswg.org/css-nesting/#nested-declarations-rule
public struct NestedDeclarationsRule: Equatable, Sendable {
    /// The declarations.
    public let declarations: [Declaration]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a nested declarations rule.
    public init(declarations: [Declaration], location: SourceLocation = .init()) {
        self.declarations = declarations
        self.location = location
    }
}

extension NestedDeclarationsRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        for declaration in declarations {
            declaration.serialize(dest: &dest)
            dest.write("\n")
        }
    }
}
