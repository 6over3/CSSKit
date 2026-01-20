// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// An overflow keyword value.
/// https://www.w3.org/TR/css-overflow-3/#overflow-properties
public enum CSSOverflowKeyword: String, Equatable, Sendable, Hashable {
    /// Overflowing content is visible.
    case visible
    /// Overflowing content is hidden. Programmatic scrolling is allowed.
    case hidden
    /// Overflowing content is clipped. Programmatic scrolling is not allowed.
    case clip
    /// The element is scrollable.
    case scroll
    /// Overflowing content scrolls if needed.
    case auto
}

/// A value for the `overflow` shorthand property.
/// https://www.w3.org/TR/css-overflow-3/#overflow-properties
public struct CSSOverflow: Equatable, Sendable, Hashable {
    /// The overflow mode for the x direction.
    public let x: CSSOverflowKeyword
    /// The overflow mode for the y direction.
    public let y: CSSOverflowKeyword

    public init(x: CSSOverflowKeyword, y: CSSOverflowKeyword) {
        self.x = x
        self.y = y
    }

    public init(_ both: CSSOverflowKeyword) {
        x = both
        y = both
    }
}

/// A value for the `text-overflow` property.
/// https://www.w3.org/TR/css-overflow-3/#text-overflow
public enum CSSTextOverflow: String, Equatable, Sendable, Hashable {
    /// Overflowing text is clipped.
    case clip
    /// Overflowing text is truncated with an ellipsis.
    case ellipsis
}

// MARK: - Parsing

extension CSSOverflowKeyword {
    static func parse(_ input: Parser) -> Result<CSSOverflowKeyword, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "visible": return .success(.visible)
        case "hidden": return .success(.hidden)
        case "clip": return .success(.clip)
        case "scroll": return .success(.scroll)
        case "auto": return .success(.auto)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSOverflow {
    static func parse(_ input: Parser) -> Result<CSSOverflow, BasicParseError> {
        guard case let .success(x) = CSSOverflowKeyword.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Try to parse second value
        if case let .success(y) = input.tryParse({ CSSOverflowKeyword.parse($0) }) {
            return .success(CSSOverflow(x: x, y: y))
        }

        // Single value applies to both
        return .success(CSSOverflow(x))
    }
}

extension CSSTextOverflow {
    static func parse(_ input: Parser) -> Result<CSSTextOverflow, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "clip": return .success(.clip)
        case "ellipsis": return .success(.ellipsis)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

// MARK: - ToCss

extension CSSOverflowKeyword: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSOverflow: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        x.serialize(dest: &dest)
        if y != x {
            dest.write(" ")
            y.serialize(dest: &dest)
        }
    }
}

extension CSSTextOverflow: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}
