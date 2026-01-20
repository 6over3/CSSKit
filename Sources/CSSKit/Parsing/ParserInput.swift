// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// The owned input for a parser, wrapping a tokenizer with caching.
final class ParserInput: @unchecked Sendable {
    /// The underlying tokenizer.
    let tokenizer: Tokenizer

    /// Cached token for lookahead.
    var cachedToken: CachedToken?

    /// Creates a new parser input from a CSS string.
    init(_ input: String, sourceFile: String? = nil) {
        tokenizer = Tokenizer(input, sourceFile: sourceFile)
        cachedToken = nil
    }

    /// Returns the cached token reference.
    /// - Precondition: `cachedToken` must not be nil.
    func cachedTokenRef() -> Token {
        guard let cached = cachedToken else {
            preconditionFailure("cachedTokenRef called when cachedToken is nil")
        }
        return cached.token
    }
}

/// A cached token with position information.
struct CachedToken: Sendable {
    let token: Token
    let startPosition: SourcePosition
    let endState: TokenizerState
}

/// The type of block we're inside.
enum BlockType: Equatable, Sendable {
    case parenthesis
    case squareBracket
    case curlyBracket

    /// Returns the block type for an opening token.
    static func opening(_ token: Token) -> Self? {
        switch token {
        case .function, .parenthesisBlock:
            .parenthesis
        case .squareBracketBlock:
            .squareBracket
        case .curlyBracketBlock:
            .curlyBracket
        default:
            nil
        }
    }

    /// Returns the block type for a closing token.
    static func closing(_ token: Token) -> Self? {
        switch token {
        case .closeParenthesis:
            .parenthesis
        case .closeSquareBracket:
            .squareBracket
        case .closeCurlyBracket:
            .curlyBracket
        default:
            nil
        }
    }
}
