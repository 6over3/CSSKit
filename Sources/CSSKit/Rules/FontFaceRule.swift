// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `@font-face` rule.
///
/// See: https://drafts.csswg.org/css-fonts/#font-face-rule
public struct FontFaceRule: Equatable, Sendable {
    /// Declarations in the `@font-face` rule.
    public let declarations: [Declaration]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a font-face rule.
    public init(declarations: [Declaration], location: SourceLocation = .init()) {
        self.declarations = declarations
        self.location = location
    }
}

// MARK: - Serialization

extension FontFaceRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@font-face {\n")
        for declaration in declarations {
            dest.write("  ")
            declaration.serialize(dest: &dest)
            dest.write("\n")
        }
        dest.write("}")
    }
}
