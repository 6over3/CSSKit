// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A set of delimiter characters, used with the `Parser.parseUntil*` methods.
///
/// The union of two sets can be obtained with the `|` operator. Example:
/// ```swift
/// parser.parseUntilBefore(.curlyBracketBlock | .semicolon)
/// ```
struct Delimiters: OptionSet, Equatable, Hashable, Sendable {
    var rawValue: UInt8

    /// The empty delimiter set.
    static let none = Self([])

    /// The delimiter set with only the `{` opening curly bracket.
    static let curlyBracketBlock = Self(rawValue: 1 << 1)

    /// The delimiter set with only the `;` semicolon.
    static let semicolon = Self(rawValue: 1 << 2)

    /// The delimiter set with only the `!` exclamation point.
    static let bang = Self(rawValue: 1 << 3)

    /// The delimiter set with only the `,` comma.
    static let comma = Self(rawValue: 1 << 4)

    // Internal closing delimiters
    static let closeCurlyBracket = Self(rawValue: 1 << 5)

    static let closeSquareBracket = Self(rawValue: 1 << 6)

    static let closeParenthesis = Self(rawValue: 1 << 7)
}

extension Delimiters {
    /// Creates a Delimiters set from a byte character.

    static func fromByte(_ byte: UInt8?) -> Delimiters {
        guard let byte else { return .none }
        switch byte {
        case UInt8(ascii: ";"):
            return .semicolon
        case UInt8(ascii: "!"):
            return .bang
        case UInt8(ascii: ","):
            return .comma
        case UInt8(ascii: "{"):
            return .curlyBracketBlock
        case UInt8(ascii: "}"):
            return .closeCurlyBracket
        case UInt8(ascii: "]"):
            return .closeSquareBracket
        case UInt8(ascii: ")"):
            return .closeParenthesis
        default:
            return .none
        }
    }

    /// Checks if this set contains any of the delimiters in another set.

    func containsAny(_ other: Delimiters) -> Bool {
        !isDisjoint(with: other)
    }
}

/// Combine two delimiter sets.
func | (lhs: Delimiters, rhs: Delimiters) -> Delimiters {
    lhs.union(rhs)
}
