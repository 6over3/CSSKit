// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A CSS `<position>` value.
/// https://www.w3.org/TR/css-values-4/#position
public struct CSSPosition: Equatable, Sendable, Hashable {
    /// The horizontal position component.
    public let horizontal: CSSHorizontalPosition

    /// The vertical position component.
    public let vertical: CSSVerticalPosition

    /// Creates a position with the given horizontal and vertical components.
    public init(horizontal: CSSHorizontalPosition, vertical: CSSVerticalPosition) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

    /// The center position (50% 50%).
    public static var center: Self {
        Self(
            horizontal: .keyword(.center),
            vertical: .keyword(.center)
        )
    }
}

/// Horizontal position keywords.
public enum CSSHorizontalPositionKeyword: String, Equatable, Sendable, Hashable {
    case left
    case center
    case right
}

/// Vertical position keywords.
public enum CSSVerticalPositionKeyword: String, Equatable, Sendable, Hashable {
    case top
    case center
    case bottom
}

/// A horizontal position component.
public enum CSSHorizontalPosition: Equatable, Sendable, Hashable {
    /// A keyword position.
    case keyword(CSSHorizontalPositionKeyword)

    /// A length or percentage offset from the left.
    case lengthPercentage(CSSLengthPercentage)

    /// A keyword with an offset (e.g., "left 10px").
    case side(CSSHorizontalPositionKeyword, CSSLengthPercentage)
}

/// A vertical position component.
public enum CSSVerticalPosition: Equatable, Sendable, Hashable {
    /// A keyword position.
    case keyword(CSSVerticalPositionKeyword)

    /// A length or percentage offset from the top.
    case lengthPercentage(CSSLengthPercentage)

    /// A keyword with an offset (e.g., "top 10px").
    case side(CSSVerticalPositionKeyword, CSSLengthPercentage)
}

// MARK: - Parsing

extension CSSPosition {
    /// Parses a `<position>` value.
    static func parse(_ input: Parser) -> Result<CSSPosition, BasicParseError> {
        // Try to parse horizontal and vertical keywords/values

        // First value
        let state = input.state()

        // Try keyword first
        if case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
            switch ident.value.lowercased() {
            case "left":
                return parseAfterHorizontalKeyword(input, keyword: .left)
            case "right":
                return parseAfterHorizontalKeyword(input, keyword: .right)
            case "top":
                return parseAfterVerticalKeyword(input, keyword: .top)
            case "bottom":
                return parseAfterVerticalKeyword(input, keyword: .bottom)
            case "center":
                return parseAfterCenter(input)
            default:
                break
            }
        }

        // Reset and try length-percentage
        input.reset(state)

        if case let .success(lp) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
            // Got horizontal length-percentage, try to get vertical
            if case let .success(vertical) = parseVerticalPosition(input) {
                return .success(CSSPosition(
                    horizontal: .lengthPercentage(lp),
                    vertical: vertical
                ))
            }
            // Just horizontal, default vertical to center
            return .success(CSSPosition(
                horizontal: .lengthPercentage(lp),
                vertical: .keyword(.center)
            ))
        }

        return .failure(input.newBasicError(.endOfInput))
    }

    private static func parseAfterHorizontalKeyword(
        _ input: Parser,
        keyword: CSSHorizontalPositionKeyword
    ) -> Result<CSSPosition, BasicParseError> {
        // Try to get offset
        if case let .success(offset) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
            // "left 10px" style - now parse vertical
            if case let .success(vertical) = parseVerticalPosition(input) {
                return .success(CSSPosition(
                    horizontal: .side(keyword, offset),
                    vertical: vertical
                ))
            }
            // Just horizontal with offset
            return .success(CSSPosition(
                horizontal: .side(keyword, offset),
                vertical: .keyword(.center)
            ))
        }

        // Try to get vertical keyword
        if case let .success(vertical) = parseVerticalPosition(input) {
            return .success(CSSPosition(
                horizontal: .keyword(keyword),
                vertical: vertical
            ))
        }

        // Just keyword
        return .success(CSSPosition(
            horizontal: .keyword(keyword),
            vertical: .keyword(.center)
        ))
    }

    private static func parseAfterVerticalKeyword(
        _ input: Parser,
        keyword: CSSVerticalPositionKeyword
    ) -> Result<CSSPosition, BasicParseError> {
        // If we see a vertical keyword first, it means: center <vertical>
        // Try to get offset
        if case let .success(offset) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
            return .success(CSSPosition(
                horizontal: .keyword(.center),
                vertical: .side(keyword, offset)
            ))
        }

        // Just vertical keyword with center horizontal
        return .success(CSSPosition(
            horizontal: .keyword(.center),
            vertical: .keyword(keyword)
        ))
    }

    private static func parseAfterCenter(_ input: Parser) -> Result<CSSPosition, BasicParseError> {
        // "center" - try to get second value
        if case let .success(vertical) = parseVerticalPosition(input) {
            return .success(CSSPosition(
                horizontal: .keyword(.center),
                vertical: vertical
            ))
        }

        // Just "center" = center center
        return .success(CSSPosition.center)
    }

    private static func parseVerticalPosition(_ input: Parser) -> Result<CSSVerticalPosition, BasicParseError> {
        let state = input.state()

        // Try keyword
        if case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
            switch ident.value.lowercased() {
            case "top":
                // Try to get offset
                if case let .success(offset) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
                    return .success(.side(.top, offset))
                }
                return .success(.keyword(.top))
            case "bottom":
                // Try to get offset
                if case let .success(offset) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
                    return .success(.side(.bottom, offset))
                }
                return .success(.keyword(.bottom))
            case "center":
                return .success(.keyword(.center))
            default:
                break
            }
        }

        // Reset and try length-percentage
        input.reset(state)

        if case let .success(lp) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
            return .success(.lengthPercentage(lp))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

// MARK: - ToCss

extension CSSPosition: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        horizontal.serialize(dest: &dest)
        dest.write(" ")
        vertical.serialize(dest: &dest)
    }
}

extension CSSHorizontalPosition: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .keyword(k):
            dest.write(k.rawValue)
        case let .lengthPercentage(lp):
            lp.serialize(dest: &dest)
        case let .side(k, offset):
            dest.write(k.rawValue)
            dest.write(" ")
            offset.serialize(dest: &dest)
        }
    }
}

extension CSSVerticalPosition: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .keyword(k):
            dest.write(k.rawValue)
        case let .lengthPercentage(lp):
            lp.serialize(dest: &dest)
        case let .side(k, offset):
            dest.write(k.rawValue)
            dest.write(" ")
            offset.serialize(dest: &dest)
        }
    }
}
