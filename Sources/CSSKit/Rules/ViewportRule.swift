// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `@viewport` rule (deprecated).
///
/// Note: This rule is deprecated and only supported for legacy content.
public struct ViewportRule: Equatable, Sendable {
    /// The vendor prefix for this rule.
    public let vendorPrefix: CSSVendorPrefix

    /// The declarations within the `@viewport` rule.
    public let declarations: [Declaration]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a viewport rule.
    public init(
        vendorPrefix: CSSVendorPrefix = .none,
        declarations: [Declaration],
        location: SourceLocation = .init()
    ) {
        self.vendorPrefix = vendorPrefix
        self.declarations = declarations
        self.location = location
    }
}

// MARK: - Serialization

extension ViewportRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@")
        vendorPrefix.serialize(dest: &dest)
        dest.write("viewport {\n")
        for declaration in declarations {
            dest.write("  ")
            declaration.serialize(dest: &dest)
            dest.write("\n")
        }
        dest.write("}")
    }
}
