// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Standard Flex Properties

/// A value for the `flex-direction` property.
/// https://www.w3.org/TR/css-flexbox-1/#flex-direction-property
public enum CSSFlexDirection: String, Equatable, Sendable, Hashable, CaseIterable {
    /// Items are placed in a row.
    case row
    /// Items are placed in a row, reversed.
    case rowReverse = "row-reverse"
    /// Items are placed in a column.
    case column
    /// Items are placed in a column, reversed.
    case columnReverse = "column-reverse"

    /// The default value.
    public static var `default`: Self { .row }
}

/// A value for the `flex-wrap` property.
/// https://www.w3.org/TR/css-flexbox-1/#flex-wrap-property
public enum CSSFlexWrap: String, Equatable, Sendable, Hashable, CaseIterable {
    /// Items are laid out in a single line.
    case nowrap
    /// Items wrap onto multiple lines.
    case wrap
    /// Items wrap onto multiple lines, reversed.
    case wrapReverse = "wrap-reverse"

    /// The default value.
    public static var `default`: Self { .nowrap }
}

/// A value for the `flex-flow` shorthand property.
/// https://www.w3.org/TR/css-flexbox-1/#flex-flow-property
public struct CSSFlexFlow: Equatable, Sendable, Hashable {
    /// The flex direction.
    public var direction: CSSFlexDirection
    /// The flex wrap.
    public var wrap: CSSFlexWrap

    public init(direction: CSSFlexDirection = .row, wrap: CSSFlexWrap = .nowrap) {
        self.direction = direction
        self.wrap = wrap
    }

    /// The default value.
    public static var `default`: Self {
        Self(direction: .row, wrap: .nowrap)
    }
}

/// A value for the `flex` shorthand property.
/// https://www.w3.org/TR/css-flexbox-1/#flex-property
public struct CSSFlex: Equatable, Sendable, Hashable {
    /// The flex-grow value.
    public var grow: Double
    /// The flex-shrink value.
    public var shrink: Double
    /// The flex-basis value.
    public var basis: CSSLengthPercentageOrAuto

    public init(grow: Double = 0, shrink: Double = 1, basis: CSSLengthPercentageOrAuto = .auto) {
        self.grow = grow
        self.shrink = shrink
        self.basis = basis
    }

    /// The `flex: none` value (0 0 auto).
    public static var none: Self {
        Self(grow: 0, shrink: 0, basis: .auto)
    }

    /// The `flex: auto` value (1 1 auto).
    public static var auto: Self {
        Self(grow: 1, shrink: 1, basis: .auto)
    }

    /// The `flex: initial` value (0 1 auto) - the default.
    public static var initial: Self {
        Self(grow: 0, shrink: 1, basis: .auto)
    }

    /// Creates a CSSFlex with only grow specified.
    /// When only `<flex-grow>` is specified, the default is (grow, 1, 0%).
    public init(grow: Double) {
        self.grow = grow
        shrink = 1
        basis = .lengthPercentage(.percentage(CSSPercentage(0)))
    }
}

// MARK: - Legacy 2009 Spec Properties

/// A value for the legacy `box-orient` property.
/// https://www.w3.org/TR/2009/WD-css3-flexbox-20090723/#orientation
/// Partially equivalent to `flex-direction` in the standard syntax.
public enum CSSBoxOrient: String, Equatable, Sendable, Hashable {
    /// Items are laid out horizontally.
    case horizontal
    /// Items are laid out vertically.
    case vertical
    /// Items are laid out along the inline axis, according to the writing direction.
    case inlineAxis = "inline-axis"
    /// Items are laid out along the block axis, according to the writing direction.
    case blockAxis = "block-axis"
}

/// A value for the legacy `box-direction` property.
/// https://www.w3.org/TR/2009/WD-css3-flexbox-20090723/#displayorder
/// Partially equivalent to the `flex-direction` property in the standard syntax.
public enum CSSBoxDirection: String, Equatable, Sendable, Hashable {
    /// Items flow in the natural direction.
    case normal
    /// Items flow in the reverse direction.
    case reverse
}

/// A value for the legacy `box-align` property.
/// https://www.w3.org/TR/2009/WD-css3-flexbox-20090723/#alignment
/// Equivalent to the `align-items` property in the standard syntax.
public enum CSSBoxAlign: String, Equatable, Sendable, Hashable {
    /// Items are aligned to the start.
    case start
    /// Items are aligned to the end.
    case end
    /// Items are centered.
    case center
    /// Items are aligned to the baseline.
    case baseline
    /// Items are stretched.
    case stretch
}

/// A value for the legacy `box-pack` property.
/// https://www.w3.org/TR/2009/WD-css3-flexbox-20090723/#packing
/// Equivalent to the `justify-content` property in the standard syntax.
public enum CSSBoxPack: String, Equatable, Sendable, Hashable {
    /// Items are justified to the start.
    case start
    /// Items are justified to the end.
    case end
    /// Items are centered.
    case center
    /// Items are justified to the start and end.
    case justify
}

/// A value for the legacy `box-lines` property.
/// https://www.w3.org/TR/2009/WD-css3-flexbox-20090723/#multiple
/// Equivalent to the `flex-wrap` property in the standard syntax.
public enum CSSBoxLines: String, Equatable, Sendable, Hashable {
    /// Items are laid out in a single line.
    case single
    /// Items may wrap into multiple lines.
    case multiple
}

// MARK: - Legacy 2012 Spec Properties

/// A value for the legacy `flex-pack` property.
/// https://www.w3.org/TR/2012/WD-css3-flexbox-20120322/#flex-pack
/// Equivalent to the `justify-content` property in the standard syntax.
public enum CSSFlexPack: String, Equatable, Sendable, Hashable {
    /// Items are justified to the start.
    case start
    /// Items are justified to the end.
    case end
    /// Items are centered.
    case center
    /// Items are justified to the start and end.
    case justify
    /// Items are distributed evenly, with half size spaces on either end.
    case distribute
}

/// A value for the legacy `flex-item-align` property.
/// https://www.w3.org/TR/2012/WD-css3-flexbox-20120322/#flex-align
/// Equivalent to the `align-self` property in the standard syntax.
public enum CSSFlexItemAlign: String, Equatable, Sendable, Hashable {
    /// Equivalent to the value of `flex-align`.
    case auto
    /// The item is aligned to the start.
    case start
    /// The item is aligned to the end.
    case end
    /// The item is centered.
    case center
    /// The item is aligned to the baseline.
    case baseline
    /// The item is stretched.
    case stretch
}

/// A value for the legacy `flex-line-pack` property.
/// https://www.w3.org/TR/2012/WD-css3-flexbox-20120322/#flex-line-pack
/// Equivalent to the `align-content` property in the standard syntax.
public enum CSSFlexLinePack: String, Equatable, Sendable, Hashable {
    /// Content is aligned to the start.
    case start
    /// Content is aligned to the end.
    case end
    /// Content is centered.
    case center
    /// Content is justified.
    case justify
    /// Content is distributed evenly, with half size spaces on either end.
    case distribute
    /// Content is stretched.
    case stretch
}

// MARK: - Conversions

public extension CSSFlexDirection {
    /// Converts to legacy 2009 box-orient and box-direction values.
    func to2009() -> (orient: CSSBoxOrient, direction: CSSBoxDirection) {
        switch self {
        case .row: (.horizontal, .normal)
        case .column: (.vertical, .normal)
        case .rowReverse: (.horizontal, .reverse)
        case .columnReverse: (.vertical, .reverse)
        }
    }
}

public extension CSSBoxAlign {
    /// Creates from standard `align-items` value if possible.
    init?(alignItems items: CSSAlignItems) {
        switch items {
        case .selfPosition(nil, .start), .selfPosition(nil, .flexStart):
            self = .start
        case .selfPosition(nil, .end), .selfPosition(nil, .flexEnd):
            self = .end
        case .selfPosition(nil, .center):
            self = .center
        case .stretch:
            self = .stretch
        case .baseline(.first):
            self = .baseline
        default:
            return nil
        }
    }
}

public extension CSSBoxPack {
    /// Creates from standard `justify-content` value if possible.
    init?(justifyContent content: CSSJustifyContent) {
        switch content {
        case .contentDistribution(.spaceBetween):
            self = .justify
        case .contentPosition(nil, .start), .contentPosition(nil, .flexStart):
            self = .start
        case .contentPosition(nil, .end), .contentPosition(nil, .flexEnd):
            self = .end
        case .contentPosition(nil, .center):
            self = .center
        default:
            return nil
        }
    }
}

public extension CSSBoxLines {
    /// Creates from standard `flex-wrap` value if possible.
    init?(flexWrap wrap: CSSFlexWrap) {
        switch wrap {
        case .nowrap: self = .single
        case .wrap: self = .multiple
        case .wrapReverse: return nil // No equivalent in 2009 spec
        }
    }
}

public extension CSSFlexPack {
    /// Creates from standard `justify-content` value if possible.
    init?(justifyContent content: CSSJustifyContent) {
        switch content {
        case .contentDistribution(.spaceBetween):
            self = .justify
        case .contentDistribution(.spaceAround):
            self = .distribute
        case .contentPosition(nil, .start), .contentPosition(nil, .flexStart):
            self = .start
        case .contentPosition(nil, .end), .contentPosition(nil, .flexEnd):
            self = .end
        case .contentPosition(nil, .center):
            self = .center
        default:
            return nil
        }
    }
}

public extension CSSFlexItemAlign {
    /// Creates from standard `align-self` value if possible.
    init?(alignSelf: CSSAlignSelf) {
        switch alignSelf {
        case .auto:
            self = .auto
        case .stretch:
            self = .stretch
        case .selfPosition(nil, .start), .selfPosition(nil, .flexStart):
            self = .start
        case .selfPosition(nil, .end), .selfPosition(nil, .flexEnd):
            self = .end
        case .selfPosition(nil, .center):
            self = .center
        case .baseline(.first):
            self = .baseline
        default:
            return nil
        }
    }
}

public extension CSSFlexLinePack {
    /// Creates from standard `align-content` value if possible.
    init?(alignContent content: CSSAlignContent) {
        switch content {
        case .contentDistribution(.spaceBetween):
            self = .justify
        case .contentDistribution(.spaceAround):
            self = .distribute
        case .contentDistribution(.stretch):
            self = .stretch
        case .contentPosition(nil, .start), .contentPosition(nil, .flexStart):
            self = .start
        case .contentPosition(nil, .end), .contentPosition(nil, .flexEnd):
            self = .end
        case .contentPosition(nil, .center):
            self = .center
        default:
            return nil
        }
    }
}

// MARK: - Parsing

extension CSSFlexDirection {
    static func parse(_ input: Parser) -> Result<CSSFlexDirection, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "row": return .success(.row)
        case "row-reverse": return .success(.rowReverse)
        case "column": return .success(.column)
        case "column-reverse": return .success(.columnReverse)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSFlexWrap {
    static func parse(_ input: Parser) -> Result<CSSFlexWrap, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "nowrap": return .success(.nowrap)
        case "wrap": return .success(.wrap)
        case "wrap-reverse": return .success(.wrapReverse)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSFlexFlow {
    static func parse(_ input: Parser) -> Result<CSSFlexFlow, BasicParseError> {
        var direction: CSSFlexDirection?
        var wrap: CSSFlexWrap?

        // Parse components in any order
        while true {
            if direction == nil {
                if case let .success(d) = input.tryParse({ CSSFlexDirection.parse($0) }) {
                    direction = d
                    continue
                }
            }

            if wrap == nil {
                if case let .success(w) = input.tryParse({ CSSFlexWrap.parse($0) }) {
                    wrap = w
                    continue
                }
            }

            break
        }

        // At least one component must be present, or we use defaults
        return .success(CSSFlexFlow(
            direction: direction ?? .default,
            wrap: wrap ?? .default
        ))
    }
}

extension CSSFlex {
    static func parse(_ input: Parser) -> Result<CSSFlex, BasicParseError> {
        let state = input.state()

        // Try `none` keyword first
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        var grow: Double?
        var shrink: Double?
        var basis: CSSLengthPercentageOrAuto?

        // Parse components
        while true {
            if grow == nil {
                if case let .success(g) = input.tryParse({ $0.expectNumber() }) {
                    grow = g
                    // Try shrink immediately after grow
                    if case let .success(s) = input.tryParse({ $0.expectNumber() }) {
                        shrink = s
                    }
                    continue
                }
            }

            if basis == nil {
                if case let .success(b) = input.tryParse({ CSSLengthPercentageOrAuto.parse($0) }) {
                    basis = b
                    continue
                }
            }

            break
        }

        // If nothing was parsed, this is invalid
        if grow == nil, basis == nil {
            input.reset(state)
            return .failure(input.newBasicError(.endOfInput))
        }

        // Apply defaults per spec:
        // - If only grow is specified: shrink defaults to 1, basis defaults to 0%
        // - If only basis is specified: grow defaults to 1, shrink defaults to 1
        return .success(CSSFlex(
            grow: grow ?? 1.0,
            shrink: shrink ?? 1.0,
            basis: basis ?? .lengthPercentage(.percentage(CSSPercentage(0)))
        ))
    }
}

extension CSSBoxOrient {
    static func parse(_ input: Parser) -> Result<CSSBoxOrient, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "horizontal": return .success(.horizontal)
        case "vertical": return .success(.vertical)
        case "inline-axis": return .success(.inlineAxis)
        case "block-axis": return .success(.blockAxis)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSBoxDirection {
    static func parse(_ input: Parser) -> Result<CSSBoxDirection, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "normal": return .success(.normal)
        case "reverse": return .success(.reverse)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSBoxAlign {
    static func parse(_ input: Parser) -> Result<CSSBoxAlign, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "start": return .success(.start)
        case "end": return .success(.end)
        case "center": return .success(.center)
        case "baseline": return .success(.baseline)
        case "stretch": return .success(.stretch)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSBoxPack {
    static func parse(_ input: Parser) -> Result<CSSBoxPack, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "start": return .success(.start)
        case "end": return .success(.end)
        case "center": return .success(.center)
        case "justify": return .success(.justify)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSBoxLines {
    static func parse(_ input: Parser) -> Result<CSSBoxLines, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "single": return .success(.single)
        case "multiple": return .success(.multiple)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSFlexPack {
    static func parse(_ input: Parser) -> Result<CSSFlexPack, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "start": return .success(.start)
        case "end": return .success(.end)
        case "center": return .success(.center)
        case "justify": return .success(.justify)
        case "distribute": return .success(.distribute)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSFlexItemAlign {
    static func parse(_ input: Parser) -> Result<CSSFlexItemAlign, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "auto": return .success(.auto)
        case "start": return .success(.start)
        case "end": return .success(.end)
        case "center": return .success(.center)
        case "baseline": return .success(.baseline)
        case "stretch": return .success(.stretch)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSFlexLinePack {
    static func parse(_ input: Parser) -> Result<CSSFlexLinePack, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "start": return .success(.start)
        case "end": return .success(.end)
        case "center": return .success(.center)
        case "justify": return .success(.justify)
        case "distribute": return .success(.distribute)
        case "stretch": return .success(.stretch)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

// MARK: - ToCss

/// Helper enum for CSSFlex serialization
private enum FlexBasisZeroKind {
    case nonZero
    case length // 0px, 0em, etc. - unitless zero
    case percentage // 0%
}

extension CSSFlexDirection: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSFlexWrap: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSFlexFlow: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        var needsSpace = false

        // Only output direction if non-default or wrap is default
        if direction != .default || wrap == .default {
            direction.serialize(dest: &dest)
            needsSpace = true
        }

        // Only output wrap if non-default
        if wrap != .default {
            if needsSpace {
                dest.write(" ")
            }
            wrap.serialize(dest: &dest)
        }
    }
}

extension CSSFlex: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        // Use `none` shorthand when possible
        if grow == 0 && shrink == 0 && basis == .auto {
            dest.write("none")
            return
        }

        // Determine if basis is a zero value and what kind
        let basisKind: FlexBasisZeroKind = switch basis {
        case let .lengthPercentage(lp):
            switch lp {
            case let .dimension(l) where l.value == 0:
                .length
            case let .percentage(p) where p.value == 0:
                .percentage
            default:
                .nonZero
            }
        default:
            .nonZero
        }

        // Output logic per spec serialization rules
        if grow != 1.0 || shrink != 1.0 || basisKind != .nonZero {
            dest.write(formatDouble(grow))
            if shrink != 1.0 || basisKind == .length {
                dest.write(" ")
                dest.write(formatDouble(shrink))
            }
        }

        if basisKind != .percentage {
            if grow != 1.0 || shrink != 1.0 || basisKind == .length {
                dest.write(" ")
            }
            basis.serialize(dest: &dest)
        }
    }
}

extension CSSBoxOrient: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSBoxDirection: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSBoxAlign: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSBoxPack: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSBoxLines: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSFlexPack: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSFlexItemAlign: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSFlexLinePack: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}
