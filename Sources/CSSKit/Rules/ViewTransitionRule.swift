// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `@view-transition` rule for configuring cross-document view transitions.
///
/// See: https://drafts.csswg.org/css-view-transitions-2/#view-transition-rule
public struct ViewTransitionRule: Equatable, Sendable {
    /// Declarations in the `@view-transition` rule.
    public let declarations: [Declaration]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a view-transition rule.
    public init(declarations: [Declaration], location: SourceLocation = .init()) {
        self.declarations = declarations
        self.location = location
    }
}

// MARK: - Serialization

extension ViewTransitionRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@view-transition {\n")
        for declaration in declarations {
            dest.write("  ")
            declaration.serialize(dest: &dest)
            dest.write("\n")
        }
        dest.write("}")
    }
}
