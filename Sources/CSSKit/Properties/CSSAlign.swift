// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Base Types

/// A `<baseline-position>` value.
/// https://www.w3.org/TR/css-align-3/#typedef-baseline-position
public enum CSSBaselinePosition: Equatable, Sendable, Hashable {
    /// The first baseline.
    case first
    /// The last baseline.
    case last
}

/// A `<content-distribution>` value.
/// https://www.w3.org/TR/css-align-3/#typedef-content-distribution
public enum CSSContentDistribution: String, Equatable, Sendable, Hashable {
    case spaceBetween = "space-between"
    case spaceAround = "space-around"
    case spaceEvenly = "space-evenly"
    case stretch
}

/// A `<content-position>` value.
/// https://www.w3.org/TR/css-align-3/#typedef-content-position
public enum CSSContentPosition: String, Equatable, Sendable, Hashable {
    case center
    case start
    case end
    case flexStart = "flex-start"
    case flexEnd = "flex-end"
}

/// A `<self-position>` value.
/// https://www.w3.org/TR/css-align-3/#typedef-self-position
public enum CSSSelfPosition: String, Equatable, Sendable, Hashable {
    case center
    case start
    case end
    case selfStart = "self-start"
    case selfEnd = "self-end"
    case flexStart = "flex-start"
    case flexEnd = "flex-end"
}

/// An `<overflow-position>` value.
/// https://www.w3.org/TR/css-align-3/#typedef-overflow-position
public enum CSSOverflowPosition: String, Equatable, Sendable, Hashable {
    case safe
    case unsafe
}

// MARK: - Content Alignment

/// A value for the `align-content` property.
/// https://www.w3.org/TR/css-align-3/#propdef-align-content
public enum CSSAlignContent: Equatable, Sendable, Hashable {
    /// The `normal` keyword.
    case normal
    /// A baseline position.
    case baseline(CSSBaselinePosition)
    /// A content distribution value.
    case contentDistribution(CSSContentDistribution)
    /// A content position value with optional overflow position.
    case contentPosition(CSSOverflowPosition?, CSSContentPosition)
}

/// A value for the `justify-content` property.
/// https://www.w3.org/TR/css-align-3/#propdef-justify-content
public enum CSSJustifyContent: Equatable, Sendable, Hashable {
    /// The `normal` keyword.
    case normal
    /// A content distribution value.
    case contentDistribution(CSSContentDistribution)
    /// A content position value with optional overflow position.
    case contentPosition(CSSOverflowPosition?, CSSContentPosition)
    /// The `left` keyword with optional overflow position.
    case left(CSSOverflowPosition?)
    /// The `right` keyword with optional overflow position.
    case right(CSSOverflowPosition?)
}

/// A value for the `place-content` shorthand property.
/// https://www.w3.org/TR/css-align-3/#place-content
public struct CSSPlaceContent: Equatable, Sendable, Hashable {
    /// The content alignment.
    public var align: CSSAlignContent
    /// The content justification.
    public var justify: CSSJustifyContent

    public init(align: CSSAlignContent, justify: CSSJustifyContent) {
        self.align = align
        self.justify = justify
    }
}

// MARK: - Self Alignment

/// A value for the `align-self` property.
/// https://www.w3.org/TR/css-align-3/#propdef-align-self
public enum CSSAlignSelf: Equatable, Sendable, Hashable {
    /// The `auto` keyword.
    case auto
    /// The `normal` keyword.
    case normal
    /// The `stretch` keyword.
    case stretch
    /// A baseline position.
    case baseline(CSSBaselinePosition)
    /// A self position value with optional overflow position.
    case selfPosition(CSSOverflowPosition?, CSSSelfPosition)
}

/// A value for the `justify-self` property.
/// https://www.w3.org/TR/css-align-3/#propdef-justify-self
public enum CSSJustifySelf: Equatable, Sendable, Hashable {
    /// The `auto` keyword.
    case auto
    /// The `normal` keyword.
    case normal
    /// The `stretch` keyword.
    case stretch
    /// A baseline position.
    case baseline(CSSBaselinePosition)
    /// A self position value with optional overflow position.
    case selfPosition(CSSOverflowPosition?, CSSSelfPosition)
    /// The `left` keyword with optional overflow position.
    case left(CSSOverflowPosition?)
    /// The `right` keyword with optional overflow position.
    case right(CSSOverflowPosition?)
}

/// A value for the `place-self` shorthand property.
/// https://www.w3.org/TR/css-align-3/#place-self-property
public struct CSSPlaceSelf: Equatable, Sendable, Hashable {
    /// The item alignment.
    public var align: CSSAlignSelf
    /// The item justification.
    public var justify: CSSJustifySelf

    public init(align: CSSAlignSelf, justify: CSSJustifySelf) {
        self.align = align
        self.justify = justify
    }
}

// MARK: - Items Alignment

/// A value for the `align-items` property.
/// https://www.w3.org/TR/css-align-3/#propdef-align-items
public enum CSSAlignItems: Equatable, Sendable, Hashable {
    /// The `normal` keyword.
    case normal
    /// The `stretch` keyword.
    case stretch
    /// A baseline position.
    case baseline(CSSBaselinePosition)
    /// A self position value with optional overflow position.
    case selfPosition(CSSOverflowPosition?, CSSSelfPosition)
}

/// A legacy justification keyword for `justify-items`.
public enum CSSLegacyJustify: String, Equatable, Sendable, Hashable {
    case left
    case right
    case center
}

/// A value for the `justify-items` property.
/// https://www.w3.org/TR/css-align-3/#propdef-justify-items
public enum CSSJustifyItems: Equatable, Sendable, Hashable {
    /// The `normal` keyword.
    case normal
    /// The `stretch` keyword.
    case stretch
    /// A baseline position.
    case baseline(CSSBaselinePosition)
    /// A self position value with optional overflow position.
    case selfPosition(CSSOverflowPosition?, CSSSelfPosition)
    /// The `left` keyword with optional overflow position.
    case left(CSSOverflowPosition?)
    /// The `right` keyword with optional overflow position.
    case right(CSSOverflowPosition?)
    /// A legacy justification keyword.
    case legacy(CSSLegacyJustify)
}

/// A value for the `place-items` shorthand property.
/// https://www.w3.org/TR/css-align-3/#place-items-property
public struct CSSPlaceItems: Equatable, Sendable, Hashable {
    /// The item alignment.
    public var align: CSSAlignItems
    /// The item justification.
    public var justify: CSSJustifyItems

    public init(align: CSSAlignItems, justify: CSSJustifyItems) {
        self.align = align
        self.justify = justify
    }
}

// MARK: - Gap

/// A gap value (for `row-gap`, `column-gap`).
/// https://www.w3.org/TR/css-align-3/#column-row-gap
public enum CSSGapValue: Equatable, Sendable, Hashable {
    /// The `normal` keyword.
    case normal
    /// A length or percentage value.
    case lengthPercentage(CSSLengthPercentage)
}

/// A value for the `gap` shorthand property.
/// https://www.w3.org/TR/css-align-3/#propdef-gap
public struct CSSGap: Equatable, Sendable, Hashable {
    /// The row gap.
    public var row: CSSGapValue
    /// The column gap.
    public var column: CSSGapValue

    public init(row: CSSGapValue, column: CSSGapValue) {
        self.row = row
        self.column = column
    }

    public init(_ both: CSSGapValue) {
        row = both
        column = both
    }
}

// MARK: - Parsing: Base Types

extension CSSBaselinePosition {
    static func parse(_ input: Parser) -> Result<CSSBaselinePosition, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "baseline":
            return .success(.first)
        case "first":
            guard input.tryParse({ $0.expectIdentMatching("baseline") }).isOK else {
                return .failure(input.newBasicError(.endOfInput))
            }
            return .success(.first)
        case "last":
            guard input.tryParse({ $0.expectIdentMatching("baseline") }).isOK else {
                return .failure(input.newBasicError(.endOfInput))
            }
            return .success(.last)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSContentDistribution {
    static func parse(_ input: Parser) -> Result<CSSContentDistribution, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "space-between": return .success(.spaceBetween)
        case "space-around": return .success(.spaceAround)
        case "space-evenly": return .success(.spaceEvenly)
        case "stretch": return .success(.stretch)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSContentPosition {
    static func parse(_ input: Parser) -> Result<CSSContentPosition, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "center": return .success(.center)
        case "start": return .success(.start)
        case "end": return .success(.end)
        case "flex-start": return .success(.flexStart)
        case "flex-end": return .success(.flexEnd)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSSelfPosition {
    static func parse(_ input: Parser) -> Result<CSSSelfPosition, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "center": return .success(.center)
        case "start": return .success(.start)
        case "end": return .success(.end)
        case "self-start": return .success(.selfStart)
        case "self-end": return .success(.selfEnd)
        case "flex-start": return .success(.flexStart)
        case "flex-end": return .success(.flexEnd)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSOverflowPosition {
    static func parse(_ input: Parser) -> Result<CSSOverflowPosition, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "safe": return .success(.safe)
        case "unsafe": return .success(.unsafe)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

// MARK: - Parsing: Content Alignment

extension CSSAlignContent {
    static func parse(_ input: Parser) -> Result<CSSAlignContent, BasicParseError> {
        let state = input.state()

        // Try normal
        if input.tryParse({ $0.expectIdentMatching("normal") }).isOK {
            return .success(.normal)
        }

        // Try baseline
        if case let .success(baseline) = input.tryParse({ CSSBaselinePosition.parse($0) }) {
            return .success(.baseline(baseline))
        }

        // Try content distribution
        if case let .success(dist) = input.tryParse({ CSSContentDistribution.parse($0) }) {
            return .success(.contentDistribution(dist))
        }

        input.reset(state)

        // Try overflow position + content position
        var overflow: CSSOverflowPosition?
        if case let .success(o) = input.tryParse({ CSSOverflowPosition.parse($0) }) {
            overflow = o
        }
        if case let .success(pos) = CSSContentPosition.parse(input) {
            return .success(.contentPosition(overflow, pos))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSJustifyContent {
    static func parse(_ input: Parser) -> Result<CSSJustifyContent, BasicParseError> {
        let state = input.state()

        // Try normal
        if input.tryParse({ $0.expectIdentMatching("normal") }).isOK {
            return .success(.normal)
        }

        // Try content distribution
        if case let .success(dist) = input.tryParse({ CSSContentDistribution.parse($0) }) {
            return .success(.contentDistribution(dist))
        }

        input.reset(state)

        // Try overflow position + content position or left/right
        var overflow: CSSOverflowPosition?
        if case let .success(o) = input.tryParse({ CSSOverflowPosition.parse($0) }) {
            overflow = o
        }

        if case let .success(pos) = input.tryParse({ CSSContentPosition.parse($0) }) {
            return .success(.contentPosition(overflow, pos))
        }

        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        switch ident.value.lowercased() {
        case "left": return .success(.left(overflow))
        case "right": return .success(.right(overflow))
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSPlaceContent {
    static func parse(_ input: Parser) -> Result<CSSPlaceContent, BasicParseError> {
        guard case let .success(align) = CSSAlignContent.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Try to parse justify, or default based on align
        if case let .success(justify) = input.tryParse({ CSSJustifyContent.parse($0) }) {
            return .success(CSSPlaceContent(align: align, justify: justify))
        }

        // Default justify based on align per spec
        let justify: CSSJustifyContent = switch align {
        case .baseline:
            .contentPosition(nil, .start)
        case .normal:
            .normal
        case let .contentDistribution(dist):
            .contentDistribution(dist)
        case let .contentPosition(overflow, pos):
            .contentPosition(overflow, pos)
        }

        return .success(CSSPlaceContent(align: align, justify: justify))
    }
}

// MARK: - Parsing: Self Alignment

extension CSSAlignSelf {
    static func parse(_ input: Parser) -> Result<CSSAlignSelf, BasicParseError> {
        let state = input.state()

        // Try keywords
        if input.tryParse({ $0.expectIdentMatching("auto") }).isOK {
            return .success(.auto)
        }
        if input.tryParse({ $0.expectIdentMatching("normal") }).isOK {
            return .success(.normal)
        }
        if input.tryParse({ $0.expectIdentMatching("stretch") }).isOK {
            return .success(.stretch)
        }

        // Try baseline
        if case let .success(baseline) = input.tryParse({ CSSBaselinePosition.parse($0) }) {
            return .success(.baseline(baseline))
        }

        input.reset(state)

        // Try overflow position + self position
        var overflow: CSSOverflowPosition?
        if case let .success(o) = input.tryParse({ CSSOverflowPosition.parse($0) }) {
            overflow = o
        }
        if case let .success(pos) = CSSSelfPosition.parse(input) {
            return .success(.selfPosition(overflow, pos))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSJustifySelf {
    static func parse(_ input: Parser) -> Result<CSSJustifySelf, BasicParseError> {
        let state = input.state()

        // Try keywords
        if input.tryParse({ $0.expectIdentMatching("auto") }).isOK {
            return .success(.auto)
        }
        if input.tryParse({ $0.expectIdentMatching("normal") }).isOK {
            return .success(.normal)
        }
        if input.tryParse({ $0.expectIdentMatching("stretch") }).isOK {
            return .success(.stretch)
        }

        // Try baseline
        if case let .success(baseline) = input.tryParse({ CSSBaselinePosition.parse($0) }) {
            return .success(.baseline(baseline))
        }

        input.reset(state)

        // Try overflow position + self position or left/right
        var overflow: CSSOverflowPosition?
        if case let .success(o) = input.tryParse({ CSSOverflowPosition.parse($0) }) {
            overflow = o
        }

        if case let .success(pos) = input.tryParse({ CSSSelfPosition.parse($0) }) {
            return .success(.selfPosition(overflow, pos))
        }

        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        switch ident.value.lowercased() {
        case "left": return .success(.left(overflow))
        case "right": return .success(.right(overflow))
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSPlaceSelf {
    static func parse(_ input: Parser) -> Result<CSSPlaceSelf, BasicParseError> {
        guard case let .success(align) = CSSAlignSelf.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Try to parse justify, or default based on align
        if case let .success(justify) = input.tryParse({ CSSJustifySelf.parse($0) }) {
            return .success(CSSPlaceSelf(align: align, justify: justify))
        }

        // Default justify based on align per spec
        let justify: CSSJustifySelf = switch align {
        case .auto:
            .auto
        case .normal:
            .normal
        case .stretch:
            .stretch
        case let .baseline(pos):
            .baseline(pos)
        case let .selfPosition(overflow, pos):
            .selfPosition(overflow, pos)
        }

        return .success(CSSPlaceSelf(align: align, justify: justify))
    }
}

// MARK: - Parsing: Items Alignment

extension CSSAlignItems {
    static func parse(_ input: Parser) -> Result<CSSAlignItems, BasicParseError> {
        let state = input.state()

        // Try keywords
        if input.tryParse({ $0.expectIdentMatching("normal") }).isOK {
            return .success(.normal)
        }
        if input.tryParse({ $0.expectIdentMatching("stretch") }).isOK {
            return .success(.stretch)
        }

        // Try baseline
        if case let .success(baseline) = input.tryParse({ CSSBaselinePosition.parse($0) }) {
            return .success(.baseline(baseline))
        }

        input.reset(state)

        // Try overflow position + self position
        var overflow: CSSOverflowPosition?
        if case let .success(o) = input.tryParse({ CSSOverflowPosition.parse($0) }) {
            overflow = o
        }
        if case let .success(pos) = CSSSelfPosition.parse(input) {
            return .success(.selfPosition(overflow, pos))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSLegacyJustify {
    static func parse(_ input: Parser) -> Result<CSSLegacyJustify, BasicParseError> {
        guard case let .success(ident1) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        switch ident1.value.lowercased() {
        case "legacy":
            // legacy <value>
            guard case let .success(ident2) = input.expectIdent() else {
                return .failure(input.newBasicError(.endOfInput))
            }
            switch ident2.value.lowercased() {
            case "left": return .success(.left)
            case "right": return .success(.right)
            case "center": return .success(.center)
            default:
                return .failure(input.newBasicError(.unexpectedToken(.ident(ident2))))
            }
        case "left":
            // left legacy
            guard input.tryParse({ $0.expectIdentMatching("legacy") }).isOK else {
                return .failure(input.newBasicError(.endOfInput))
            }
            return .success(.left)
        case "right":
            // right legacy
            guard input.tryParse({ $0.expectIdentMatching("legacy") }).isOK else {
                return .failure(input.newBasicError(.endOfInput))
            }
            return .success(.right)
        case "center":
            // center legacy
            guard input.tryParse({ $0.expectIdentMatching("legacy") }).isOK else {
                return .failure(input.newBasicError(.endOfInput))
            }
            return .success(.center)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident1))))
        }
    }
}

extension CSSJustifyItems {
    static func parse(_ input: Parser) -> Result<CSSJustifyItems, BasicParseError> {
        let state = input.state()

        // Try keywords
        if input.tryParse({ $0.expectIdentMatching("normal") }).isOK {
            return .success(.normal)
        }
        if input.tryParse({ $0.expectIdentMatching("stretch") }).isOK {
            return .success(.stretch)
        }

        // Try baseline
        if case let .success(baseline) = input.tryParse({ CSSBaselinePosition.parse($0) }) {
            return .success(.baseline(baseline))
        }

        // Try legacy
        if case let .success(legacy) = input.tryParse({ CSSLegacyJustify.parse($0) }) {
            return .success(.legacy(legacy))
        }

        input.reset(state)

        // Try overflow position + self position or left/right
        var overflow: CSSOverflowPosition?
        if case let .success(o) = input.tryParse({ CSSOverflowPosition.parse($0) }) {
            overflow = o
        }

        if case let .success(pos) = input.tryParse({ CSSSelfPosition.parse($0) }) {
            return .success(.selfPosition(overflow, pos))
        }

        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        switch ident.value.lowercased() {
        case "left": return .success(.left(overflow))
        case "right": return .success(.right(overflow))
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSPlaceItems {
    static func parse(_ input: Parser) -> Result<CSSPlaceItems, BasicParseError> {
        guard case let .success(align) = CSSAlignItems.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Try to parse justify, or default based on align
        if case let .success(justify) = input.tryParse({ CSSJustifyItems.parse($0) }) {
            return .success(CSSPlaceItems(align: align, justify: justify))
        }

        // Default justify based on align per spec
        let justify: CSSJustifyItems = switch align {
        case .normal:
            .normal
        case .stretch:
            .stretch
        case let .baseline(pos):
            .baseline(pos)
        case let .selfPosition(overflow, pos):
            .selfPosition(overflow, pos)
        }

        return .success(CSSPlaceItems(align: align, justify: justify))
    }
}

// MARK: - Parsing: Gap

extension CSSGapValue {
    static func parse(_ input: Parser) -> Result<CSSGapValue, BasicParseError> {
        let state = input.state()

        // Try normal keyword
        if input.tryParse({ $0.expectIdentMatching("normal") }).isOK {
            return .success(.normal)
        }

        input.reset(state)

        // Try length-percentage
        if case let .success(lp) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
            return .success(.lengthPercentage(lp))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSGap {
    static func parse(_ input: Parser) -> Result<CSSGap, BasicParseError> {
        guard case let .success(row) = CSSGapValue.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Try to parse second value
        if case let .success(column) = input.tryParse({ CSSGapValue.parse($0) }) {
            return .success(CSSGap(row: row, column: column))
        }

        // Single value applies to both
        return .success(CSSGap(row))
    }
}

// MARK: - ToCss: Base Types

extension CSSBaselinePosition: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .first:
            dest.write("baseline")
        case .last:
            dest.write("last baseline")
        }
    }
}

extension CSSContentDistribution: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSContentPosition: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSSelfPosition: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSOverflowPosition: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

// MARK: - ToCss: Content Alignment

extension CSSAlignContent: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .normal:
            dest.write("normal")
        case let .baseline(pos):
            pos.serialize(dest: &dest)
        case let .contentDistribution(dist):
            dist.serialize(dest: &dest)
        case let .contentPosition(overflow, pos):
            if let overflow {
                overflow.serialize(dest: &dest)
                dest.write(" ")
            }
            pos.serialize(dest: &dest)
        }
    }
}

extension CSSJustifyContent: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .normal:
            dest.write("normal")
        case let .contentDistribution(dist):
            dist.serialize(dest: &dest)
        case let .contentPosition(overflow, pos):
            if let overflow {
                overflow.serialize(dest: &dest)
                dest.write(" ")
            }
            pos.serialize(dest: &dest)
        case let .left(overflow):
            if let overflow {
                overflow.serialize(dest: &dest)
                dest.write(" ")
            }
            dest.write("left")
        case let .right(overflow):
            if let overflow {
                overflow.serialize(dest: &dest)
                dest.write(" ")
            }
            dest.write("right")
        }
    }
}

extension CSSPlaceContent: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        align.serialize(dest: &dest)

        // Check if justify can be omitted
        let isEqual = switch (align, justify) {
        case (.normal, .normal):
            true
        case let (.contentDistribution(a), .contentDistribution(j)) where a == j:
            true
        case let (.contentPosition(ao, ap), .contentPosition(jo, jp)) where ao == jo && ap == jp:
            true
        default:
            false
        }

        if !isEqual {
            dest.write(" ")
            justify.serialize(dest: &dest)
        }
    }
}

// MARK: - ToCss: Self Alignment

extension CSSAlignSelf: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .auto:
            dest.write("auto")
        case .normal:
            dest.write("normal")
        case .stretch:
            dest.write("stretch")
        case let .baseline(pos):
            pos.serialize(dest: &dest)
        case let .selfPosition(overflow, pos):
            if let overflow {
                overflow.serialize(dest: &dest)
                dest.write(" ")
            }
            pos.serialize(dest: &dest)
        }
    }
}

extension CSSJustifySelf: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .auto:
            dest.write("auto")
        case .normal:
            dest.write("normal")
        case .stretch:
            dest.write("stretch")
        case let .baseline(pos):
            pos.serialize(dest: &dest)
        case let .selfPosition(overflow, pos):
            if let overflow {
                overflow.serialize(dest: &dest)
                dest.write(" ")
            }
            pos.serialize(dest: &dest)
        case let .left(overflow):
            if let overflow {
                overflow.serialize(dest: &dest)
                dest.write(" ")
            }
            dest.write("left")
        case let .right(overflow):
            if let overflow {
                overflow.serialize(dest: &dest)
                dest.write(" ")
            }
            dest.write("right")
        }
    }
}

extension CSSPlaceSelf: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        align.serialize(dest: &dest)

        // Check if justify can be omitted
        let isEqual = switch (align, justify) {
        case (.auto, .auto):
            true
        case (.normal, .normal):
            true
        case (.stretch, .stretch):
            true
        case let (.baseline(a), .baseline(j)) where a == j:
            true
        case let (.selfPosition(ao, ap), .selfPosition(jo, jp)) where ao == jo && ap == jp:
            true
        default:
            false
        }

        if !isEqual {
            dest.write(" ")
            justify.serialize(dest: &dest)
        }
    }
}

// MARK: - ToCss: Items Alignment

extension CSSAlignItems: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .normal:
            dest.write("normal")
        case .stretch:
            dest.write("stretch")
        case let .baseline(pos):
            pos.serialize(dest: &dest)
        case let .selfPosition(overflow, pos):
            if let overflow {
                overflow.serialize(dest: &dest)
                dest.write(" ")
            }
            pos.serialize(dest: &dest)
        }
    }
}

extension CSSLegacyJustify: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("legacy ")
        dest.write(rawValue)
    }
}

extension CSSJustifyItems: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .normal:
            dest.write("normal")
        case .stretch:
            dest.write("stretch")
        case let .baseline(pos):
            pos.serialize(dest: &dest)
        case let .legacy(legacy):
            legacy.serialize(dest: &dest)
        case let .selfPosition(overflow, pos):
            if let overflow {
                overflow.serialize(dest: &dest)
                dest.write(" ")
            }
            pos.serialize(dest: &dest)
        case let .left(overflow):
            if let overflow {
                overflow.serialize(dest: &dest)
                dest.write(" ")
            }
            dest.write("left")
        case let .right(overflow):
            if let overflow {
                overflow.serialize(dest: &dest)
                dest.write(" ")
            }
            dest.write("right")
        }
    }
}

extension CSSPlaceItems: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        align.serialize(dest: &dest)

        // Check if justify can be omitted
        let isEqual = switch (align, justify) {
        case (.normal, .normal):
            true
        case (.stretch, .stretch):
            true
        case let (.baseline(a), .baseline(j)) where a == j:
            true
        case let (.selfPosition(ao, ap), .selfPosition(jo, jp)) where ao == jo && ap == jp:
            true
        default:
            false
        }

        if !isEqual {
            dest.write(" ")
            justify.serialize(dest: &dest)
        }
    }
}

// MARK: - ToCss: Gap

extension CSSGapValue: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .normal:
            dest.write("normal")
        case let .lengthPercentage(lp):
            lp.serialize(dest: &dest)
        }
    }
}

extension CSSGap: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        row.serialize(dest: &dest)
        if column != row {
            dest.write(" ")
            column.serialize(dest: &dest)
        }
    }
}
