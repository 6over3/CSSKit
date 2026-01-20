// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - PageRule

/// A `@page` rule.
///
/// See: https://www.w3.org/TR/css-page-3/#at-page-rule
public struct PageRule: Equatable, Sendable {
    /// A list of page selectors.
    public let selectors: [PageSelector]

    /// The declarations within the `@page` rule.
    public let declarations: [Declaration]

    /// The nested margin rules.
    public let marginRules: [PageMarginRule]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a page rule.
    public init(
        selectors: [PageSelector],
        declarations: [Declaration],
        marginRules: [PageMarginRule] = [],
        location: SourceLocation = .init()
    ) {
        self.selectors = selectors
        self.declarations = declarations
        self.marginRules = marginRules
        self.location = location
    }
}

// MARK: - PageSelector

/// A page selector within a `@page` rule.
///
/// Either a name or at least one pseudo class is required.
public struct PageSelector: Equatable, Sendable, Hashable {
    /// An optional named page type.
    public let name: String?

    /// A list of page pseudo classes.
    public let pseudoClasses: [PagePseudoClass]

    /// Creates a page selector.
    public init(name: String?, pseudoClasses: [PagePseudoClass]) {
        self.name = name
        self.pseudoClasses = pseudoClasses
    }
}

extension PageSelector: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if let name {
            dest.write(name)
        }
        for pseudo in pseudoClasses {
            dest.write(":")
            pseudo.serialize(dest: &dest)
        }
    }
}

// MARK: - PagePseudoClass

/// A page pseudo class within a `@page` selector.
public enum PagePseudoClass: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The `:left` pseudo class.
    case left
    /// The `:right` pseudo class.
    case right
    /// The `:first` pseudo class.
    case first
    /// The `:last` pseudo class.
    case last
    /// The `:blank` pseudo class.
    case blank
}

extension PagePseudoClass: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

// MARK: - PageMarginBox

/// A page margin box.
///
/// See: https://www.w3.org/TR/css-page-3/#margin-boxes
public enum PageMarginBox: String, Equatable, Sendable, Hashable, CaseIterable {
    case topLeftCorner = "top-left-corner"
    case topLeft = "top-left"
    case topCenter = "top-center"
    case topRight = "top-right"
    case topRightCorner = "top-right-corner"
    case leftTop = "left-top"
    case leftMiddle = "left-middle"
    case leftBottom = "left-bottom"
    case rightTop = "right-top"
    case rightMiddle = "right-middle"
    case rightBottom = "right-bottom"
    case bottomLeftCorner = "bottom-left-corner"
    case bottomLeft = "bottom-left"
    case bottomCenter = "bottom-center"
    case bottomRight = "bottom-right"
    case bottomRightCorner = "bottom-right-corner"
}

extension PageMarginBox: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

// MARK: - PageMarginRule

/// A page margin rule.
///
/// See: https://www.w3.org/TR/css-page-3/#margin-at-rules
public struct PageMarginRule: Equatable, Sendable {
    /// The margin box identifier for this rule.
    public let marginBox: PageMarginBox

    /// The declarations within the rule.
    public let declarations: [Declaration]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a page margin rule.
    public init(marginBox: PageMarginBox, declarations: [Declaration], location: SourceLocation = .init()) {
        self.marginBox = marginBox
        self.declarations = declarations
        self.location = location
    }
}

extension PageMarginRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@")
        marginBox.serialize(dest: &dest)
        dest.write(" {\n")
        for declaration in declarations {
            dest.write("    ")
            declaration.serialize(dest: &dest)
            dest.write("\n")
        }
        dest.write("  }")
    }
}

// MARK: - PageRule Serialization

extension PageRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@page")

        if !selectors.isEmpty {
            dest.write(" ")
            for (index, selector) in selectors.enumerated() {
                if index > 0 {
                    dest.write(", ")
                }
                selector.serialize(dest: &dest)
            }
        }

        dest.write(" {\n")

        for declaration in declarations {
            dest.write("  ")
            declaration.serialize(dest: &dest)
            dest.write("\n")
        }

        for marginRule in marginRules {
            dest.write("  ")
            marginRule.serialize(dest: &dest)
            dest.write("\n")
        }

        dest.write("}")
    }
}
