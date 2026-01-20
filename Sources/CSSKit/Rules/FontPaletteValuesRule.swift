// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `@font-palette-values` rule for defining custom font color palettes.
///
/// See: https://drafts.csswg.org/css-fonts/#font-palette-values
public struct FontPaletteValuesRule: Equatable, Sendable {
    /// The name of the palette (e.g., `--my-palette`).
    public let name: String

    /// The declarations within the rule.
    public let declarations: [Declaration]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a font-palette-values rule.
    public init(name: String, declarations: [Declaration], location: SourceLocation = .init()) {
        self.name = name
        self.declarations = declarations
        self.location = location
    }
}

// MARK: - Serialization

extension FontPaletteValuesRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@font-palette-values ")
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
