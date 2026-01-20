// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A value for the CSS Modules `composes` property.
/// https://github.com/css-modules/css-modules/#dependencies
public struct CSSComposes: Equatable, Sendable, Hashable {
    /// A list of class names to compose.
    public let names: [CSSCustomIdent]

    /// Where the class names are composed from.
    public let from: CSSComposesSpecifier?

    /// The source location of the `composes` property.
    public let location: SourceLocation

    /// Creates a composes value.
    public init(names: [CSSCustomIdent], from: CSSComposesSpecifier? = nil, location: SourceLocation) {
        self.names = names
        self.from = from
        self.location = location
    }
}

/// Defines where the class names referenced in the `composes` property are located.
public enum CSSComposesSpecifier: Equatable, Sendable, Hashable {
    /// The referenced name is global.
    case global

    /// The referenced name comes from the specified file.
    case file(String)

    /// The referenced name comes from a source index (used during bundling).
    case sourceIndex(UInt32)
}

// MARK: - Parsing

extension CSSComposes {
    /// Parses a composes value.
    static func parse(_ input: Parser) -> Result<CSSComposes, BasicParseError> {
        let location = input.currentSourceLocation()
        var names: [CSSCustomIdent] = []

        // Parse class names until we hit "from" or end
        while let name = parseOneIdent(input) {
            names.append(name)
        }

        if names.isEmpty {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Try to parse "from <specifier>"
        var from: CSSComposesSpecifier?
        if input.tryParse({ $0.expectIdentMatching("from") }).isOK {
            switch CSSComposesSpecifier.parse(input) {
            case let .success(specifier):
                from = specifier
            case let .failure(error):
                return .failure(error)
            }
        }

        return .success(CSSComposes(
            names: names,
            from: from,
            location: location
        ))
    }
}

/// Parses a single identifier, returning nil if it's "from" or not an identifier.
private func parseOneIdent(_ input: Parser) -> CSSCustomIdent? {
    let result: Result<CSSCustomIdent, BasicParseError> = input.tryParse { p in
        switch CSSCustomIdent.parse(p) {
        case let .success(ident):
            // "from" is a reserved word in this context
            if ident.value.lowercased() == "from" {
                return .failure(p.newBasicError(.endOfInput))
            }
            return .success(ident)
        case let .failure(error):
            return .failure(error)
        }
    }

    switch result {
    case let .success(ident):
        return ident
    case .failure:
        return nil
    }
}

extension CSSComposesSpecifier {
    /// Parses a composes specifier.
    static func parse(_ input: Parser) -> Result<CSSComposesSpecifier, BasicParseError> {
        // Try string first
        if case let .success(str) = input.tryParse({ CSSString.parse($0) }) {
            return .success(.file(str.value))
        }

        // Try "global" keyword
        if input.tryParse({ $0.expectIdentMatching("global") }).isOK {
            return .success(.global)
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

// MARK: - Serialization

extension CSSComposes: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        for (i, name) in names.enumerated() {
            if i > 0 {
                dest.write(" ")
            }
            name.serialize(dest: &dest)
        }

        if let from {
            dest.write(" from ")
            from.serialize(dest: &dest)
        }
    }
}

extension CSSComposesSpecifier: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .global:
            dest.write("global")
        case let .file(file):
            dest.write("\"")
            dest.write(file)
            dest.write("\"")
        case .sourceIndex:
            // Source indices are not serialized
            break
        }
    }
}
