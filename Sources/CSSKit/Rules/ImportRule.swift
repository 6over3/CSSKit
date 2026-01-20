// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `@import` rule for importing external stylesheets.
///
/// See: https://drafts.csswg.org/css-cascade/#at-import
public struct ImportRule: Equatable, Sendable, Hashable {
    /// The URL to import.
    public let url: String

    /// An optional cascade layer name, or empty string for anonymous layer.
    /// `nil` means no layer specified.
    public let layer: LayerSpecifier?

    /// An optional `supports()` condition.
    public let supports: SupportsCondition?

    /// A media query list (empty if no media query specified).
    public let media: MediaList

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates an import rule.
    public init(
        url: String,
        layer: LayerSpecifier? = nil,
        supports: SupportsCondition? = nil,
        media: MediaList = MediaList(queries: []),
        location: SourceLocation = .init()
    ) {
        self.url = url
        self.layer = layer
        self.supports = supports
        self.media = media
        self.location = location
    }
}

/// Specifies how a layer is declared in an `@import` rule.
public enum LayerSpecifier: Equatable, Sendable, Hashable {
    /// An anonymous layer (`layer` keyword without a name).
    case anonymous
    /// A named layer (`layer(name)`).
    case named(LayerName)
}

// MARK: - Parsing

extension ImportRule {
    /// Parses a `@import` rule prelude.
    static func parse(_ input: Parser) -> Result<ImportRule, BasicParseError> {
        let location = input.currentSourceLocation()

        // Parse URL (either url() or string)
        let url: String
        if case let .success(urlValue) = input.tryParse({ p in CSSUrl.parse(p) }) {
            url = urlValue.url
        } else if case let .success(str) = input.expectString() {
            url = String(str.value)
        } else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Parse optional layer
        var layer: LayerSpecifier?
        if case .success = input.tryParse({ p in p.expectIdentMatching("layer") }) {
            // Check for layer name in parentheses
            if case let .success(name) = input.tryParse({ p -> Result<LayerName, BasicParseError> in
                guard case .success = p.expectParenthesisBlock() else {
                    return .failure(p.newBasicError(.endOfInput))
                }
                let result: Result<LayerName, ParseError<BasicParseErrorKind>> = p.parseNestedBlock { nested in
                    LayerName.parse(nested).mapError { $0.asParseError() }
                }
                return result.mapError { $0.basic }
            }) {
                layer = .named(name)
            } else {
                layer = .anonymous
            }
        }

        // Parse optional supports condition
        var supports: SupportsCondition?
        if case .success = input.tryParse({ p in p.expectIdentMatching("supports") }) {
            if case .success = input.expectParenthesisBlock() {
                let result: Result<SupportsCondition, ParseError<BasicParseErrorKind>> = input.parseNestedBlock { nested in
                    SupportsCondition.parse(nested).mapError { $0.asParseError() }
                }
                if case let .success(cond) = result {
                    supports = cond
                }
            }
        }

        // Parse optional media query
        let media: MediaList = if input.isExhausted {
            MediaList(queries: [])
        } else {
            switch MediaList.parse(input) {
            case let .success(m):
                m
            case .failure:
                MediaList(queries: [])
            }
        }

        return .success(ImportRule(
            url: url,
            layer: layer,
            supports: supports,
            media: media,
            location: location
        ))
    }
}

// MARK: - Serialization

extension ImportRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@import ")
        // Serialize URL as a string
        dest.write("\"")
        dest.write(url)
        dest.write("\"")

        if let layer {
            dest.write(" layer")
            if case let .named(name) = layer {
                dest.write("(")
                name.serialize(dest: &dest)
                dest.write(")")
            }
        }

        if let supports {
            dest.write(" supports")
            if case .declaration = supports {
                supports.serialize(dest: &dest)
            } else {
                dest.write("(")
                supports.serialize(dest: &dest)
                dest.write(")")
            }
        }

        if !media.queries.isEmpty {
            dest.write(" ")
            media.serialize(dest: &dest)
        }

        dest.write(";")
    }
}

extension LayerSpecifier: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .anonymous:
            dest.write("layer")
        case let .named(name):
            dest.write("layer(")
            name.serialize(dest: &dest)
            dest.write(")")
        }
    }
}
