// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `@property` rule for registering custom CSS properties.
///
/// See: https://drafts.css-houdini.org/css-properties-values-api/#at-property-rule
public struct PropertyRule: Equatable, Sendable, Hashable {
    /// The name of the custom property (e.g., `--my-color`).
    public let name: String

    /// The parsed syntax definition for the custom property.
    public let syntax: CSSSyntaxString

    /// Whether the custom property is inherited.
    public let inherits: Bool

    /// The initial value for the custom property
    public let initialValue: CSSParsedComponent?

    /// Whether the rule has all required descriptors and valid descriptor values.
    ///
    /// Invalid rules remain in the parsed stylesheet so tooling can inspect
    /// their source location, but consumers must not register them.
    public let isValid: Bool

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a property rule.
    public init(
        name: String,
        syntax: CSSSyntaxString,
        inherits: Bool,
        initialValue: CSSParsedComponent?,
        isValid: Bool = true,
        location: SourceLocation = .init()
    ) {
        self.name = name
        self.syntax = syntax
        self.inherits = inherits
        self.initialValue = initialValue
        self.isValid = isValid
        self.location = location
    }
}

// MARK: - Serialization

extension PropertyRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@property ")
        dest.write(name)
        dest.write(" {\n")
        dest.write("  syntax: ")
        syntax.serialize(dest: &dest)
        dest.write(";\n")
        dest.write("  inherits: ")
        dest.write(inherits ? "true" : "false")
        dest.write(";\n")

        if let initialValue {
            dest.write("  initial-value: ")
            initialValue.serialize(dest: &dest)
            dest.write(";\n")
        }

        dest.write("}")
    }
}
