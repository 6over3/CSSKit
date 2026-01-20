// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `@container` rule.
///
/// See: https://drafts.csswg.org/css-contain-3/#container-rule
public struct ContainerRule<R: CSSSerializable & Sendable & Equatable>: Sendable, Equatable {
    /// The name of the container (optional).
    public let name: String?

    /// The container condition.
    public let condition: ContainerCondition?

    /// The rules within the `@container` rule.
    public let rules: [Rule<R>]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a container rule.
    public init(
        name: String?,
        condition: ContainerCondition?,
        rules: [Rule<R>],
        location: SourceLocation = .init()
    ) {
        self.name = name
        self.condition = condition
        self.rules = rules
        self.location = location
    }
}

// MARK: - Serialization

extension ContainerRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@container ")

        if let name {
            dest.write(name)
            if condition != nil {
                dest.write(" ")
            }
        }

        if let condition {
            condition.serialize(dest: &dest)
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
