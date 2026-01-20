// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Margin

/// A value for the `margin` shorthand property.
/// https://drafts.csswg.org/css-box-4/#propdef-margin
public struct CSSMargin: Equatable, Sendable, Hashable {
    public var top: CSSLengthPercentageOrAuto
    public var right: CSSLengthPercentageOrAuto
    public var bottom: CSSLengthPercentageOrAuto
    public var left: CSSLengthPercentageOrAuto

    public init(top: CSSLengthPercentageOrAuto, right: CSSLengthPercentageOrAuto, bottom: CSSLengthPercentageOrAuto, left: CSSLengthPercentageOrAuto) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }

    public init(all: CSSLengthPercentageOrAuto) {
        top = all
        right = all
        bottom = all
        left = all
    }

    public init(vertical: CSSLengthPercentageOrAuto, horizontal: CSSLengthPercentageOrAuto) {
        top = vertical
        right = horizontal
        bottom = vertical
        left = horizontal
    }
}

/// A value for the `margin-block` shorthand property.
/// https://drafts.csswg.org/css-logical/#propdef-margin-block
public struct CSSMarginBlock: Equatable, Sendable, Hashable {
    public var start: CSSLengthPercentageOrAuto
    public var end: CSSLengthPercentageOrAuto

    public init(start: CSSLengthPercentageOrAuto, end: CSSLengthPercentageOrAuto) {
        self.start = start
        self.end = end
    }

    public init(_ both: CSSLengthPercentageOrAuto) {
        start = both
        end = both
    }
}

/// A value for the `margin-inline` shorthand property.
/// https://drafts.csswg.org/css-logical/#propdef-margin-inline
public struct CSSMarginInline: Equatable, Sendable, Hashable {
    public var start: CSSLengthPercentageOrAuto
    public var end: CSSLengthPercentageOrAuto

    public init(start: CSSLengthPercentageOrAuto, end: CSSLengthPercentageOrAuto) {
        self.start = start
        self.end = end
    }

    public init(_ both: CSSLengthPercentageOrAuto) {
        start = both
        end = both
    }
}

// MARK: - Padding

/// A value for the `padding` shorthand property.
/// https://drafts.csswg.org/css-box-4/#propdef-padding
public struct CSSPadding: Equatable, Sendable, Hashable {
    public var top: CSSLengthPercentageOrAuto
    public var right: CSSLengthPercentageOrAuto
    public var bottom: CSSLengthPercentageOrAuto
    public var left: CSSLengthPercentageOrAuto

    public init(top: CSSLengthPercentageOrAuto, right: CSSLengthPercentageOrAuto, bottom: CSSLengthPercentageOrAuto, left: CSSLengthPercentageOrAuto) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }

    public init(all: CSSLengthPercentageOrAuto) {
        top = all
        right = all
        bottom = all
        left = all
    }

    public init(vertical: CSSLengthPercentageOrAuto, horizontal: CSSLengthPercentageOrAuto) {
        top = vertical
        right = horizontal
        bottom = vertical
        left = horizontal
    }
}

/// A value for the `padding-block` shorthand property.
/// https://drafts.csswg.org/css-logical/#propdef-padding-block
public struct CSSPaddingBlock: Equatable, Sendable, Hashable {
    public var start: CSSLengthPercentageOrAuto
    public var end: CSSLengthPercentageOrAuto

    public init(start: CSSLengthPercentageOrAuto, end: CSSLengthPercentageOrAuto) {
        self.start = start
        self.end = end
    }

    public init(_ both: CSSLengthPercentageOrAuto) {
        start = both
        end = both
    }
}

/// A value for the `padding-inline` shorthand property.
/// https://drafts.csswg.org/css-logical/#propdef-padding-inline
public struct CSSPaddingInline: Equatable, Sendable, Hashable {
    public var start: CSSLengthPercentageOrAuto
    public var end: CSSLengthPercentageOrAuto

    public init(start: CSSLengthPercentageOrAuto, end: CSSLengthPercentageOrAuto) {
        self.start = start
        self.end = end
    }

    public init(_ both: CSSLengthPercentageOrAuto) {
        start = both
        end = both
    }
}

// MARK: - Scroll Margin

/// A value for the `scroll-margin` shorthand property.
/// https://drafts.csswg.org/css-scroll-snap/#scroll-margin
public struct CSSScrollMargin: Equatable, Sendable, Hashable {
    public var top: CSSLengthPercentageOrAuto
    public var right: CSSLengthPercentageOrAuto
    public var bottom: CSSLengthPercentageOrAuto
    public var left: CSSLengthPercentageOrAuto

    public init(top: CSSLengthPercentageOrAuto, right: CSSLengthPercentageOrAuto, bottom: CSSLengthPercentageOrAuto, left: CSSLengthPercentageOrAuto) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }

    public init(all: CSSLengthPercentageOrAuto) {
        top = all
        right = all
        bottom = all
        left = all
    }

    public init(vertical: CSSLengthPercentageOrAuto, horizontal: CSSLengthPercentageOrAuto) {
        top = vertical
        right = horizontal
        bottom = vertical
        left = horizontal
    }
}

/// A value for the `scroll-margin-block` shorthand property.
/// https://drafts.csswg.org/css-scroll-snap/#propdef-scroll-margin-block
public struct CSSScrollMarginBlock: Equatable, Sendable, Hashable {
    public var start: CSSLengthPercentageOrAuto
    public var end: CSSLengthPercentageOrAuto

    public init(start: CSSLengthPercentageOrAuto, end: CSSLengthPercentageOrAuto) {
        self.start = start
        self.end = end
    }

    public init(_ both: CSSLengthPercentageOrAuto) {
        start = both
        end = both
    }
}

/// A value for the `scroll-margin-inline` shorthand property.
/// https://drafts.csswg.org/css-scroll-snap/#propdef-scroll-margin-inline
public struct CSSScrollMarginInline: Equatable, Sendable, Hashable {
    public var start: CSSLengthPercentageOrAuto
    public var end: CSSLengthPercentageOrAuto

    public init(start: CSSLengthPercentageOrAuto, end: CSSLengthPercentageOrAuto) {
        self.start = start
        self.end = end
    }

    public init(_ both: CSSLengthPercentageOrAuto) {
        start = both
        end = both
    }
}

// MARK: - Scroll Padding

/// A value for the `scroll-padding` shorthand property.
/// https://drafts.csswg.org/css-scroll-snap/#scroll-padding
public struct CSSScrollPadding: Equatable, Sendable, Hashable {
    public var top: CSSLengthPercentageOrAuto
    public var right: CSSLengthPercentageOrAuto
    public var bottom: CSSLengthPercentageOrAuto
    public var left: CSSLengthPercentageOrAuto

    public init(top: CSSLengthPercentageOrAuto, right: CSSLengthPercentageOrAuto, bottom: CSSLengthPercentageOrAuto, left: CSSLengthPercentageOrAuto) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }

    public init(all: CSSLengthPercentageOrAuto) {
        top = all
        right = all
        bottom = all
        left = all
    }

    public init(vertical: CSSLengthPercentageOrAuto, horizontal: CSSLengthPercentageOrAuto) {
        top = vertical
        right = horizontal
        bottom = vertical
        left = horizontal
    }
}

/// A value for the `scroll-padding-block` shorthand property.
/// https://drafts.csswg.org/css-scroll-snap/#propdef-scroll-padding-block
public struct CSSScrollPaddingBlock: Equatable, Sendable, Hashable {
    public var start: CSSLengthPercentageOrAuto
    public var end: CSSLengthPercentageOrAuto

    public init(start: CSSLengthPercentageOrAuto, end: CSSLengthPercentageOrAuto) {
        self.start = start
        self.end = end
    }

    public init(_ both: CSSLengthPercentageOrAuto) {
        start = both
        end = both
    }
}

/// A value for the `scroll-padding-inline` shorthand property.
/// https://drafts.csswg.org/css-scroll-snap/#propdef-scroll-padding-inline
public struct CSSScrollPaddingInline: Equatable, Sendable, Hashable {
    public var start: CSSLengthPercentageOrAuto
    public var end: CSSLengthPercentageOrAuto

    public init(start: CSSLengthPercentageOrAuto, end: CSSLengthPercentageOrAuto) {
        self.start = start
        self.end = end
    }

    public init(_ both: CSSLengthPercentageOrAuto) {
        start = both
        end = both
    }
}

// MARK: - Inset

/// A value for the `inset` shorthand property.
/// https://drafts.csswg.org/css-logical/#propdef-inset
public struct CSSInset: Equatable, Sendable, Hashable {
    public var top: CSSLengthPercentageOrAuto
    public var right: CSSLengthPercentageOrAuto
    public var bottom: CSSLengthPercentageOrAuto
    public var left: CSSLengthPercentageOrAuto

    public init(top: CSSLengthPercentageOrAuto, right: CSSLengthPercentageOrAuto, bottom: CSSLengthPercentageOrAuto, left: CSSLengthPercentageOrAuto) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }

    public init(all: CSSLengthPercentageOrAuto) {
        top = all
        right = all
        bottom = all
        left = all
    }

    public init(vertical: CSSLengthPercentageOrAuto, horizontal: CSSLengthPercentageOrAuto) {
        top = vertical
        right = horizontal
        bottom = vertical
        left = horizontal
    }
}

/// A value for the `inset-block` shorthand property.
/// https://drafts.csswg.org/css-logical/#propdef-inset-block
public struct CSSInsetBlock: Equatable, Sendable, Hashable {
    public var start: CSSLengthPercentageOrAuto
    public var end: CSSLengthPercentageOrAuto

    public init(start: CSSLengthPercentageOrAuto, end: CSSLengthPercentageOrAuto) {
        self.start = start
        self.end = end
    }

    public init(_ both: CSSLengthPercentageOrAuto) {
        start = both
        end = both
    }
}

/// A value for the `inset-inline` shorthand property.
/// https://drafts.csswg.org/css-logical/#propdef-inset-inline
public struct CSSInsetInline: Equatable, Sendable, Hashable {
    public var start: CSSLengthPercentageOrAuto
    public var end: CSSLengthPercentageOrAuto

    public init(start: CSSLengthPercentageOrAuto, end: CSSLengthPercentageOrAuto) {
        self.start = start
        self.end = end
    }

    public init(_ both: CSSLengthPercentageOrAuto) {
        start = both
        end = both
    }
}

// MARK: - Parsing

extension CSSMargin {
    static func parse(_ input: Parser) -> Result<CSSMargin, BasicParseError> {
        parseRect(input).map { CSSMargin(top: $0.top, right: $0.right, bottom: $0.bottom, left: $0.left) }
    }
}

extension CSSMarginBlock {
    static func parse(_ input: Parser) -> Result<CSSMarginBlock, BasicParseError> {
        parseSize(input).map { CSSMarginBlock(start: $0.0, end: $0.1) }
    }
}

extension CSSMarginInline {
    static func parse(_ input: Parser) -> Result<CSSMarginInline, BasicParseError> {
        parseSize(input).map { CSSMarginInline(start: $0.0, end: $0.1) }
    }
}

extension CSSPadding {
    static func parse(_ input: Parser) -> Result<CSSPadding, BasicParseError> {
        parseRect(input).map { CSSPadding(top: $0.top, right: $0.right, bottom: $0.bottom, left: $0.left) }
    }
}

extension CSSPaddingBlock {
    static func parse(_ input: Parser) -> Result<CSSPaddingBlock, BasicParseError> {
        parseSize(input).map { CSSPaddingBlock(start: $0.0, end: $0.1) }
    }
}

extension CSSPaddingInline {
    static func parse(_ input: Parser) -> Result<CSSPaddingInline, BasicParseError> {
        parseSize(input).map { CSSPaddingInline(start: $0.0, end: $0.1) }
    }
}

extension CSSScrollMargin {
    static func parse(_ input: Parser) -> Result<CSSScrollMargin, BasicParseError> {
        parseRect(input).map { CSSScrollMargin(top: $0.top, right: $0.right, bottom: $0.bottom, left: $0.left) }
    }
}

extension CSSScrollMarginBlock {
    static func parse(_ input: Parser) -> Result<CSSScrollMarginBlock, BasicParseError> {
        parseSize(input).map { CSSScrollMarginBlock(start: $0.0, end: $0.1) }
    }
}

extension CSSScrollMarginInline {
    static func parse(_ input: Parser) -> Result<CSSScrollMarginInline, BasicParseError> {
        parseSize(input).map { CSSScrollMarginInline(start: $0.0, end: $0.1) }
    }
}

extension CSSScrollPadding {
    static func parse(_ input: Parser) -> Result<CSSScrollPadding, BasicParseError> {
        parseRect(input).map { CSSScrollPadding(top: $0.top, right: $0.right, bottom: $0.bottom, left: $0.left) }
    }
}

extension CSSScrollPaddingBlock {
    static func parse(_ input: Parser) -> Result<CSSScrollPaddingBlock, BasicParseError> {
        parseSize(input).map { CSSScrollPaddingBlock(start: $0.0, end: $0.1) }
    }
}

extension CSSScrollPaddingInline {
    static func parse(_ input: Parser) -> Result<CSSScrollPaddingInline, BasicParseError> {
        parseSize(input).map { CSSScrollPaddingInline(start: $0.0, end: $0.1) }
    }
}

extension CSSInset {
    static func parse(_ input: Parser) -> Result<CSSInset, BasicParseError> {
        parseRect(input).map { CSSInset(top: $0.top, right: $0.right, bottom: $0.bottom, left: $0.left) }
    }
}

extension CSSInsetBlock {
    static func parse(_ input: Parser) -> Result<CSSInsetBlock, BasicParseError> {
        parseSize(input).map { CSSInsetBlock(start: $0.0, end: $0.1) }
    }
}

extension CSSInsetInline {
    static func parse(_ input: Parser) -> Result<CSSInsetInline, BasicParseError> {
        parseSize(input).map { CSSInsetInline(start: $0.0, end: $0.1) }
    }
}

// MARK: - Parsing Helpers

private func parseRect(_ input: Parser) -> Result<CSSRect<CSSLengthPercentageOrAuto>, BasicParseError> {
    guard case let .success(first) = CSSLengthPercentageOrAuto.parse(input) else {
        return .failure(input.newBasicError(.endOfInput))
    }

    guard case let .success(second) = input.tryParse({ CSSLengthPercentageOrAuto.parse($0) }) else {
        return .success(CSSRect(all: first))
    }

    guard case let .success(third) = input.tryParse({ CSSLengthPercentageOrAuto.parse($0) }) else {
        return .success(CSSRect(vertical: first, horizontal: second))
    }

    if case let .success(fourth) = input.tryParse({ CSSLengthPercentageOrAuto.parse($0) }) {
        return .success(CSSRect(top: first, right: second, bottom: third, left: fourth))
    }

    return .success(CSSRect(top: first, horizontal: second, bottom: third))
}

private func parseSize(_ input: Parser) -> Result<(CSSLengthPercentageOrAuto, CSSLengthPercentageOrAuto), BasicParseError> {
    guard case let .success(first) = CSSLengthPercentageOrAuto.parse(input) else {
        return .failure(input.newBasicError(.endOfInput))
    }

    if case let .success(second) = input.tryParse({ CSSLengthPercentageOrAuto.parse($0) }) {
        return .success((first, second))
    }

    return .success((first, first))
}

// MARK: - ToCss

extension CSSMargin: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        CSSRect(top: top, right: right, bottom: bottom, left: left).serialize(dest: &dest)
    }
}

extension CSSMarginBlock: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if end != start {
            dest.write(" ")
            end.serialize(dest: &dest)
        }
    }
}

extension CSSMarginInline: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if end != start {
            dest.write(" ")
            end.serialize(dest: &dest)
        }
    }
}

extension CSSPadding: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        CSSRect(top: top, right: right, bottom: bottom, left: left).serialize(dest: &dest)
    }
}

extension CSSPaddingBlock: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if end != start {
            dest.write(" ")
            end.serialize(dest: &dest)
        }
    }
}

extension CSSPaddingInline: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if end != start {
            dest.write(" ")
            end.serialize(dest: &dest)
        }
    }
}

extension CSSScrollMargin: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        CSSRect(top: top, right: right, bottom: bottom, left: left).serialize(dest: &dest)
    }
}

extension CSSScrollMarginBlock: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if end != start {
            dest.write(" ")
            end.serialize(dest: &dest)
        }
    }
}

extension CSSScrollMarginInline: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if end != start {
            dest.write(" ")
            end.serialize(dest: &dest)
        }
    }
}

extension CSSScrollPadding: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        CSSRect(top: top, right: right, bottom: bottom, left: left).serialize(dest: &dest)
    }
}

extension CSSScrollPaddingBlock: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if end != start {
            dest.write(" ")
            end.serialize(dest: &dest)
        }
    }
}

extension CSSScrollPaddingInline: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if end != start {
            dest.write(" ")
            end.serialize(dest: &dest)
        }
    }
}

extension CSSInset: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        CSSRect(top: top, right: right, bottom: bottom, left: left).serialize(dest: &dest)
    }
}

extension CSSInsetBlock: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if end != start {
            dest.write(" ")
            end.serialize(dest: &dest)
        }
    }
}

extension CSSInsetInline: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if end != start {
            dest.write(" ")
            end.serialize(dest: &dest)
        }
    }
}
