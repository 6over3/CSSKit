// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A value for the `float` property.
/// https://drafts.csswg.org/css2/#propdef-float
public enum CSSFloat: String, Equatable, Sendable, Hashable {
    case none
    case left
    case right
    case inlineStart = "inline-start"
    case inlineEnd = "inline-end"
}

/// A value for the `clear` property.
/// https://drafts.csswg.org/css2/#propdef-clear
public enum CSSClear: String, Equatable, Sendable, Hashable {
    case none
    case left
    case right
    case both
    case inlineStart = "inline-start"
    case inlineEnd = "inline-end"
}

extension CSSFloat {
    static func parse(_ input: Parser) -> Result<CSSFloat, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        guard let value = CSSFloat(rawValue: ident.value.lowercased()) else {
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
        return .success(value)
    }
}

extension CSSClear {
    static func parse(_ input: Parser) -> Result<CSSClear, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        guard let value = CSSClear(rawValue: ident.value.lowercased()) else {
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
        return .success(value)
    }
}

extension CSSFloat: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSClear: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}
