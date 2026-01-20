// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - LayerName

/// A layer name within a `@layer` or `@import` rule.
///
/// Nested layers are represented using an array of identifiers.
/// In CSS syntax, these are dot-separated (e.g., `framework.theme`).
public struct LayerName: Equatable, Sendable, Hashable {
    /// The parts of the layer name (dot-separated in CSS).
    public let parts: [String]

    /// Creates a layer name from parts.
    public init(parts: [String]) {
        self.parts = parts
    }

    /// Creates a layer name from a dot-separated string.
    public init(_ name: String) {
        parts = name.split(separator: ".").map(String.init)
    }
}

extension LayerName {
    /// Parses a layer name.
    static func parse(_ input: Parser) -> Result<LayerName, BasicParseError> {
        var parts: [String] = []

        // First part is required
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        parts.append(String(ident.value))

        // Parse additional dot-separated parts
        while case .success = input.tryParse({ p -> Result<Void, BasicParseError> in
            guard case .success = p.expectDelim(".") else {
                return .failure(p.newBasicError(.endOfInput))
            }
            guard case let .success(ident) = p.expectIdent() else {
                return .failure(p.newBasicError(.endOfInput))
            }
            parts.append(String(ident.value))
            return .success(())
        }) {
            // Continue parsing
        }

        return .success(LayerName(parts: parts))
    }
}

extension LayerName: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        for (index, part) in parts.enumerated() {
            if index > 0 {
                dest.write(".")
            }
            dest.write(part)
        }
    }
}

// MARK: - LayerStatementRule

/// A `@layer` statement rule that declares layer names without any rules.
///
/// Example: `@layer theme, utilities;`
///
/// See: https://drafts.csswg.org/css-cascade-5/#layer-empty
public struct LayerStatementRule: Equatable, Sendable, Hashable {
    /// The layer names to declare.
    public let names: [LayerName]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a layer statement rule.
    public init(names: [LayerName], location: SourceLocation = .init()) {
        self.names = names
        self.location = location
    }
}

extension LayerStatementRule {
    /// Parses a `@layer` statement rule prelude.
    static func parse(_ input: Parser) -> Result<LayerStatementRule, BasicParseError> {
        let location = input.currentSourceLocation()

        var names: [LayerName] = []

        // Parse comma-separated layer names
        while !input.isExhausted {
            switch LayerName.parse(input) {
            case let .success(name):
                names.append(name)
            case let .failure(error):
                if names.isEmpty {
                    return .failure(error)
                }
            }

            // Check for comma
            if case .failure = input.tryParse({ p in p.expectComma() }) {
                break
            }
        }

        guard !names.isEmpty else {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(LayerStatementRule(names: names, location: location))
    }
}

extension LayerStatementRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@layer ")
        for (index, name) in names.enumerated() {
            if index > 0 {
                dest.write(", ")
            }
            name.serialize(dest: &dest)
        }
        dest.write(";")
    }
}

// MARK: - LayerBlockRule

/// A `@layer` block rule that contains nested rules.
///
/// Example: `@layer theme { ... }`
///
/// See: https://drafts.csswg.org/css-cascade-5/#layer-block
public struct LayerBlockRule<R: CSSSerializable & Sendable & Equatable>: Sendable, Equatable {
    /// The name of the layer, or `nil` for an anonymous layer.
    public let name: LayerName?

    /// The rules within the `@layer` block.
    public let rules: [Rule<R>]

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a layer block rule.
    public init(name: LayerName?, rules: [Rule<R>], location: SourceLocation = .init()) {
        self.name = name
        self.rules = rules
        self.location = location
    }
}

extension LayerBlockRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@layer")
        if let name {
            dest.write(" ")
            name.serialize(dest: &dest)
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
