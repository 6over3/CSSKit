// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// CSS-wide keywords that can be used as the value of any property.
///
/// See: https://drafts.csswg.org/css-cascade-5/#defaulting-keywords
public enum CSSWideKeyword: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The property's initial value.
    case initial
    /// The property's computed value on the parent element.
    case inherit
    /// Either inherit or initial depending on whether the property is inherited.
    case unset
    /// Rolls back the cascade to the cascaded value of the earlier origin.
    case revert
    /// Rolls back the cascade to the value of the previous cascade layer.
    case revertLayer = "revert-layer"
}

// MARK: - Parsing

extension CSSWideKeyword: CSSParseable {
    static func parse(_ input: Parser) -> Result<Self, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(location.newBasicUnexpectedTokenError(.ident("")))
        }

        switch ident.lowercased() {
        case "initial": return .success(.initial)
        case "inherit": return .success(.inherit)
        case "unset": return .success(.unset)
        case "revert": return .success(.revert)
        case "revert-layer": return .success(.revertLayer)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

// MARK: - Serialization

extension CSSWideKeyword: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}
