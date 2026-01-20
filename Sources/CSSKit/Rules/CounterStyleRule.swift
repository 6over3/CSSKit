// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `@counter-style` rule.
///
/// See: https://drafts.csswg.org/css-counter-styles/#the-counter-style-rule
public struct CounterStyleRule: Equatable, Sendable {
    /// The name of the counter style to declare.
    public let name: String

    /// Declarations in the `@counter-style` rule.
    public let declarations: [Declaration]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a counter-style rule.
    public init(name: String, declarations: [Declaration], location: SourceLocation = .init()) {
        self.name = name
        self.declarations = declarations
        self.location = location
    }
}

// MARK: - Serialization

extension CounterStyleRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@counter-style ")
        dest.write(name)
        dest.write(" {\n")
        for declaration in declarations {
            dest.write("  ")
            declaration.serialize(dest: &dest)
            dest.write("\n")
        }
        dest.write("}")
    }
}
