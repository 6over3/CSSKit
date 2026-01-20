// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A value for the `visibility` property.
/// https://drafts.csswg.org/css-display-3/#visibility
public enum CSSVisibility: String, Equatable, Sendable, Hashable {
    /// The element is visible.
    case visible
    /// The element is hidden.
    case hidden
    /// The element is collapsed.
    case collapse
}

/// A value for the `box-sizing` property.
/// https://www.w3.org/TR/css-sizing-3/#box-sizing
public enum CSSBoxSizing: String, Equatable, Sendable, Hashable {
    /// The width and height refer to the content box.
    case contentBox = "content-box"
    /// The width and height refer to the border box.
    case borderBox = "border-box"
}

// MARK: - Parsing

extension CSSVisibility {
    static func parse(_ input: Parser) -> Result<CSSVisibility, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "visible": return .success(.visible)
        case "hidden": return .success(.hidden)
        case "collapse": return .success(.collapse)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSBoxSizing {
    static func parse(_ input: Parser) -> Result<CSSBoxSizing, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "content-box": return .success(.contentBox)
        case "border-box": return .success(.borderBox)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

// MARK: - ToCss

extension CSSVisibility: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSBoxSizing: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}
