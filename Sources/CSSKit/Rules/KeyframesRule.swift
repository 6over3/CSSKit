// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - KeyframesRule

/// A `@keyframes` rule.
///
/// See: https://drafts.csswg.org/css-animations/#keyframes
public struct KeyframesRule: Equatable, Sendable {
    /// The animation name.
    public let name: KeyframesName

    /// A list of keyframes in the animation.
    public let keyframes: [Keyframe]

    /// A vendor prefix for the rule (e.g., `-webkit-`, `-moz-`).
    public let vendorPrefix: CSSVendorPrefix

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates a keyframes rule.
    public init(
        name: KeyframesName,
        keyframes: [Keyframe],
        vendorPrefix: CSSVendorPrefix = .none,
        location: SourceLocation = .init()
    ) {
        self.name = name
        self.keyframes = keyframes
        self.vendorPrefix = vendorPrefix
        self.location = location
    }
}

// MARK: - KeyframesName

/// The name of a `@keyframes` animation.
///
/// Can be a custom identifier or a quoted string.
public enum KeyframesName: Equatable, Sendable, Hashable {
    /// A custom identifier (e.g., `slide-in`).
    case ident(String)
    /// A quoted string (e.g., `"slide-in"`).
    case string(String)
}

extension KeyframesName {
    /// Parses a keyframes name.
    static func parse(_ input: Parser) -> Result<KeyframesName, BasicParseError> {
        if case let .success(str) = input.tryParse({ p in p.expectString() }) {
            return .success(.string(String(str.value)))
        }

        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // CSS-wide keywords and "none"/"default" are not allowed as unquoted names
        let value = ident.value.lowercased()
        if value == "none" || value == "default" || CSSWideKeyword(rawValue: value) != nil {
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
        return .success(.ident(String(ident.value)))
    }
}

extension KeyframesName: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .ident(name):
            dest.write(name)
        case let .string(name):
            // CSS-wide keywords and "none"/"default" must be quoted
            let lower = name.lowercased()
            if lower == "none" || lower == "default" || CSSWideKeyword(rawValue: lower) != nil {
                dest.write("\"")
                dest.write(name)
                dest.write("\"")
            } else {
                dest.write(name)
            }
        }
    }
}

// MARK: - KeyframeSelector

/// A keyframe selector within an `@keyframes` rule.
public enum KeyframeSelector: Equatable, Sendable, Hashable {
    /// An explicit percentage (e.g., `50%`).
    case percentage(Double)
    /// The `from` keyword (equivalent to `0%`).
    case from
    /// The `to` keyword (equivalent to `100%`).
    case to
}

extension KeyframeSelector {
    /// Parses a keyframe selector.
    static func parse(_ input: Parser) -> Result<KeyframeSelector, BasicParseError> {
        if case let .success(ident) = input.tryParse({ p in p.expectIdent() }) {
            let value = ident.value.lowercased()
            switch value {
            case "from":
                return .success(.from)
            case "to":
                return .success(.to)
            default:
                return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
            }
        }

        guard case let .success(pct) = input.expectPercentage() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(.percentage(pct))
    }

    /// The percentage value of this selector.
    public var percentageValue: Double {
        switch self {
        case let .percentage(p): p
        case .from: 0.0
        case .to: 1.0
        }
    }
}

extension KeyframeSelector: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .percentage(p):
            if p == 1.0 {
                dest.write("to")
            } else {
                let percentage = p * 100
                if percentage == percentage.rounded() {
                    dest.write(String(format: "%.0f%%", percentage))
                } else {
                    dest.write(String(format: "%g%%", percentage))
                }
            }
        case .from:
            dest.write("from")
        case .to:
            dest.write("to")
        }
    }
}

// MARK: - Keyframe

/// An individual keyframe within an `@keyframes` rule.
public struct Keyframe: Equatable, Sendable {
    /// A list of keyframe selectors for this keyframe.
    public let selectors: [KeyframeSelector]

    /// The declarations for this keyframe.
    public let declarations: [Declaration]

    /// Creates a keyframe.
    public init(selectors: [KeyframeSelector], declarations: [Declaration]) {
        self.selectors = selectors
        self.declarations = declarations
    }
}

extension Keyframe: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        for (index, selector) in selectors.enumerated() {
            if index > 0 {
                dest.write(", ")
            }
            selector.serialize(dest: &dest)
        }
        dest.write(" {\n")
        for declaration in declarations {
            dest.write("    ")
            declaration.serialize(dest: &dest)
            dest.write("\n")
        }
        dest.write("  }")
    }
}

// MARK: - KeyframesRule Serialization

extension KeyframesRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@")
        vendorPrefix.serialize(dest: &dest)
        dest.write("keyframes ")
        name.serialize(dest: &dest)
        dest.write(" {\n")
        for keyframe in keyframes {
            dest.write("  ")
            keyframe.serialize(dest: &dest)
            dest.write("\n")
        }
        dest.write("}")
    }
}
