// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Stylesheet

/// A parsed CSS stylesheet containing rules.
public struct Stylesheet<R: CSSSerializable & Sendable & Equatable>: Sendable, Equatable {
    /// The list of top-level rules in the stylesheet.
    public let rules: [Rule<R>]

    /// Source map URL from a `/*# sourceMappingURL=... */` comment.
    public let sourceMapUrl: String?

    /// Source URL from a `/*# sourceURL=... */` comment.
    public let sourceUrl: String?

    /// Creates a stylesheet with the given rules.
    public init(
        rules: [Rule<R>],
        sourceMapUrl: String? = nil,
        sourceUrl: String? = nil
    ) {
        self.rules = rules
        self.sourceMapUrl = sourceMapUrl
        self.sourceUrl = sourceUrl
    }

    /// Returns a new stylesheet with rules from both stylesheets concatenated.
    ///
    /// Source map URLs are invalidated since positions change after merge.
    /// Each rule retains its original `SourceLocation` including `sourceFile`,
    /// so you can still trace rules back to their origin.
    public func merged(with other: Stylesheet<R>) -> Stylesheet<R> {
        Self(
            rules: rules + other.rules,
            sourceMapUrl: nil,
            sourceUrl: nil
        )
    }
}

/// A stylesheet with no custom rules.
public typealias DefaultStylesheet = Stylesheet<Never>

// MARK: - Rule

/// A CSS rule: style rule, at-rule, or custom rule.
public enum Rule<R: CSSSerializable & Sendable & Equatable>: Sendable, Equatable {
    /// A style rule with selectors and declarations.
    case style(StyleRule<R>)

    // MARK: - Typed At-Rules

    /// An `@import` rule.
    case importRule(ImportRule)

    /// A `@namespace` rule.
    case namespace(NamespaceRule)

    /// A `@media` rule.
    case media(MediaRule<R>)

    /// A `@supports` rule.
    case supports(SupportsRule<R>)

    /// A `@keyframes` rule.
    case keyframes(KeyframesRule)

    /// A `@font-face` rule.
    case fontFace(FontFaceRule)

    /// A `@font-feature-values` rule.
    case fontFeatureValues(FontFeatureValuesRule)

    /// A `@font-palette-values` rule.
    case fontPaletteValues(FontPaletteValuesRule)

    /// A `@counter-style` rule.
    case counterStyle(CounterStyleRule)

    /// A `@page` rule.
    case page(PageRule)

    /// A `@layer` statement rule (no block).
    case layerStatement(LayerStatementRule)

    /// A `@layer` block rule.
    case layerBlock(LayerBlockRule<R>)

    /// A `@container` rule.
    case container(ContainerRule<R>)

    /// A `@scope` rule.
    case scope(ScopeRule<R>)

    /// A `@property` rule.
    case property(PropertyRule)

    /// A `@custom-media` rule.
    case customMedia(CustomMediaRule)

    /// A `@starting-style` rule.
    case startingStyle(StartingStyleRule<R>)

    /// A `@viewport` rule (deprecated).
    case viewport(ViewportRule)

    /// A `@view-transition` rule.
    case viewTransition(ViewTransitionRule)

    /// A `@nest` rule (legacy nesting syntax).
    case nesting(NestingRule<R>)

    /// Nested declarations rule.
    case nestedDeclarations(NestedDeclarationsRule)

    /// A `@-moz-document` rule (Firefox-specific).
    case mozDocument(MozDocumentRule<R>)

    /// An unknown at-rule stored as raw tokens.
    case unknown(UnknownAtRule)

    /// A custom rule parsed by a user-provided RuleParser.
    case custom(R)
}

/// A rule with no custom rules.
public typealias DefaultRule = Rule<Never>

/// Alias for Rule (browser API naming).
public typealias CSSRule = Rule

/// Alias for Declaration (browser API naming).
public typealias CSSDeclaration = Declaration

// MARK: - StyleRule

/// A CSS style rule containing a selector and declarations.
public struct StyleRule<R: CSSSerializable & Sendable & Equatable>: Sendable, Equatable {
    public let selectors: SelectorList?

    public let declarations: [Declaration]
    public let rules: [Rule<R>]
    public let location: SourceLocation

    public init(
        selectors: SelectorList?,
        declarations: [Declaration],
        rules: [Rule<R>] = [],
        location: SourceLocation = SourceLocation(line: 0, column: 0)
    ) {
        self.selectors = selectors
        self.declarations = declarations
        self.rules = rules
        self.location = location
    }

    public var selectorText: String? {
        selectors?.text
    }
}

/// A style rule with no custom rules.
public typealias DefaultStyleRule = StyleRule<Never>

// MARK: - Declaration

public struct Declaration: Sendable, Equatable {
    public let name: String
    public let value: CSSProperty
    public let isImportant: Bool
    public let location: SourceLocation

    public init(
        name: String,
        value: CSSProperty,
        isImportant: Bool = false,
        location: SourceLocation = .init()
    ) {
        self.name = name
        self.value = value
        self.isImportant = isImportant
        self.location = location
    }

    public init(
        name: String,
        rawValue: String,
        isImportant: Bool = false,
        location: SourceLocation = .init()
    ) {
        self.name = name
        let propertyId = CSSPropertyId(name)
        let tokenList = CSSTokenList(tokens: [.token(.ident(Lexeme(rawValue)))])
        value = .unparsed(CSSUnparsedProperty(propertyId: propertyId, value: tokenList))
        self.isImportant = isImportant
        self.location = location
    }

    public var rawValue: String {
        var writer = StringCSSWriter()
        value.serialize(dest: &writer)
        return writer.result
    }
}

// MARK: - CustomStringConvertible

extension Stylesheet: CustomStringConvertible {
    public var description: String {
        rules.map(\.description).joined(separator: "\n")
    }
}

extension Rule: CustomStringConvertible {
    public var description: String {
        var writer = StringCSSWriter()
        serialize(dest: &writer)
        return writer.result
    }
}

extension StyleRule: CustomStringConvertible {
    public var description: String {
        let decls = declarations.map { "  \($0.description)" }.joined(separator: "\n")
        let nested = rules.isEmpty ? "" : "\n" + rules.map { "  \($0.description)" }.joined(separator: "\n")
        return "\(selectorText ?? "") {\n\(decls)\(nested)\n}"
    }
}

extension Declaration: CustomStringConvertible {
    public var description: String {
        let importantStr = isImportant ? " !important" : ""
        return "\(name): \(rawValue)\(importantStr);"
    }
}

// MARK: - ToCss Conformance

extension Stylesheet: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        for (index, rule) in rules.enumerated() {
            if index > 0 {
                dest.write("\n")
            }
            rule.serialize(dest: &dest)
        }
    }
}

extension Rule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .style(rule):
            rule.serialize(dest: &dest)
        case let .importRule(rule):
            rule.serialize(dest: &dest)
        case let .namespace(rule):
            rule.serialize(dest: &dest)
        case let .media(rule):
            rule.serialize(dest: &dest)
        case let .supports(rule):
            rule.serialize(dest: &dest)
        case let .keyframes(rule):
            rule.serialize(dest: &dest)
        case let .fontFace(rule):
            rule.serialize(dest: &dest)
        case let .fontFeatureValues(rule):
            rule.serialize(dest: &dest)
        case let .fontPaletteValues(rule):
            rule.serialize(dest: &dest)
        case let .counterStyle(rule):
            rule.serialize(dest: &dest)
        case let .page(rule):
            rule.serialize(dest: &dest)
        case let .layerStatement(rule):
            rule.serialize(dest: &dest)
        case let .layerBlock(rule):
            rule.serialize(dest: &dest)
        case let .container(rule):
            rule.serialize(dest: &dest)
        case let .scope(rule):
            rule.serialize(dest: &dest)
        case let .property(rule):
            rule.serialize(dest: &dest)
        case let .customMedia(rule):
            rule.serialize(dest: &dest)
        case let .startingStyle(rule):
            rule.serialize(dest: &dest)
        case let .viewport(rule):
            rule.serialize(dest: &dest)
        case let .viewTransition(rule):
            rule.serialize(dest: &dest)
        case let .nesting(rule):
            rule.serialize(dest: &dest)
        case let .nestedDeclarations(rule):
            rule.serialize(dest: &dest)
        case let .mozDocument(rule):
            rule.serialize(dest: &dest)
        case let .unknown(rule):
            rule.serialize(dest: &dest)
        case let .custom(rule):
            rule.serialize(dest: &dest)
        }
    }
}

extension StyleRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if let selectors {
            selectors.serialize(dest: &dest)
        }
        dest.write(" {\n")
        for decl in declarations {
            dest.write("  ")
            decl.serialize(dest: &dest)
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

extension Declaration: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(name)
        dest.write(": ")
        value.serialize(dest: &dest)
        if isImportant {
            dest.write(" !important")
        }
        dest.write(";")
    }
}
