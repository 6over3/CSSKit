// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A value for the `position` property.
/// https://www.w3.org/TR/css-position-3/#position-property
public enum CSSPositionProperty: Equatable, Sendable, Hashable {
    /// The box is laid in the document flow.
    case `static`
    /// The box is laid out in the document flow and offset from the resulting position.
    case relative
    /// The box is taken out of document flow and positioned in reference to its relative ancestor.
    case absolute
    /// Similar to relative but adjusted according to the ancestor scrollable element.
    /// Includes vendor prefix support for `-webkit-sticky`.
    case sticky(CSSVendorPrefix)
    /// The box is taken out of the document flow and positioned in reference to the page viewport.
    case fixed

    /// Standard sticky without vendor prefix.
    public static var sticky: Self { .sticky(.none) }
}

/// A value for the `z-index` property.
/// https://drafts.csswg.org/css2/#z-index
public enum CSSZIndex: Equatable, Sendable, Hashable {
    /// The `auto` keyword.
    case auto
    /// An integer value.
    case integer(Int)
}

// MARK: - Parsing

extension CSSPositionProperty {
    static func parse(_ input: Parser) -> Result<CSSPositionProperty, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "static": return .success(.static)
        case "relative": return .success(.relative)
        case "absolute": return .success(.absolute)
        case "fixed": return .success(.fixed)
        case "sticky": return .success(.sticky(.none))
        case "-webkit-sticky": return .success(.sticky(.webkit))
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSZIndex {
    static func parse(_ input: Parser) -> Result<CSSZIndex, BasicParseError> {
        let state = input.state()

        // Try auto keyword
        if input.tryParse({ $0.expectIdentMatching("auto") }).isOK {
            return .success(.auto)
        }

        input.reset(state)

        // Try integer
        if case let .success(int) = input.parseInteger() {
            return .success(.integer(int))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

// MARK: - ToCss

extension CSSPositionProperty: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .static: dest.write("static")
        case .relative: dest.write("relative")
        case .absolute: dest.write("absolute")
        case .fixed: dest.write("fixed")
        case let .sticky(prefix):
            prefix.serialize(dest: &dest)
            dest.write("sticky")
        }
    }
}

extension CSSZIndex: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .auto:
            dest.write("auto")
        case let .integer(value):
            dest.write(String(value))
        }
    }
}
