// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `@font-feature-values` rule for defining named font feature values.
///
/// See: https://drafts.csswg.org/css-fonts/#font-feature-values
public struct FontFeatureValuesRule: Equatable, Sendable {
    /// The list of font families this rule applies to.
    public let fontFamilies: [String]

    /// The feature value blocks within this rule.
    public let blocks: [FontFeatureValueBlock]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a font-feature-values rule.
    public init(
        fontFamilies: [String],
        blocks: [FontFeatureValueBlock],
        location: SourceLocation = .init()
    ) {
        self.fontFamilies = fontFamilies
        self.blocks = blocks
        self.location = location
    }
}

/// A feature value block within a `@font-feature-values` rule.
public struct FontFeatureValueBlock: Equatable, Sendable {
    /// The type of font feature (e.g., `stylistic`, `swash`, `ornaments`).
    public let featureType: FontFeatureType

    /// The named values in this block.
    public let values: [FontFeatureValue]

    /// Creates a font feature value block.
    public init(featureType: FontFeatureType, values: [FontFeatureValue]) {
        self.featureType = featureType
        self.values = values
    }
}

/// The type of font feature in a `@font-feature-values` block.
public enum FontFeatureType: String, Equatable, Sendable, Hashable, CaseIterable {
    case stylistic
    case styleset
    case characterVariant = "character-variant"
    case swash
    case ornaments
    case annotation
}

/// A named font feature value.
public struct FontFeatureValue: Equatable, Sendable {
    /// The name of the feature value.
    public let name: String

    /// The indices for this feature.
    public let indices: [Int]

    /// Creates a font feature value.
    public init(name: String, indices: [Int]) {
        self.name = name
        self.indices = indices
    }
}

// MARK: - Serialization

extension FontFeatureValuesRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@font-feature-values ")
        for (index, family) in fontFamilies.enumerated() {
            if index > 0 {
                dest.write(", ")
            }
            dest.write(family)
        }
        dest.write(" {\n")
        for block in blocks {
            block.serialize(dest: &dest)
        }
        dest.write("}")
    }
}

extension FontFeatureValueBlock: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("  @")
        dest.write(featureType.rawValue)
        dest.write(" {\n")
        for value in values {
            value.serialize(dest: &dest)
        }
        dest.write("  }\n")
    }
}

extension FontFeatureValue: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("    ")
        dest.write(name)
        dest.write(": ")
        for (index, idx) in indices.enumerated() {
            if index > 0 {
                dest.write(" ")
            }
            dest.write(String(idx))
        }
        dest.write(";\n")
    }
}
