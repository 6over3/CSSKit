// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Track Breadth

/// A track breadth value.
/// https://drafts.csswg.org/css-grid-2/#typedef-track-breadth
public enum CSSTrackBreadth: Equatable, Sendable, Hashable {
    /// An explicit length or percentage.
    case length(CSSLengthPercentage)
    /// A flex factor (e.g., `1fr`).
    case flex(Double)
    /// The `min-content` keyword.
    case minContent
    /// The `max-content` keyword.
    case maxContent
    /// The `auto` keyword.
    case auto
}

// MARK: - Track Size

/// A track size value.
/// https://drafts.csswg.org/css-grid-2/#typedef-track-size
public enum CSSTrackSize: Equatable, Sendable, Hashable {
    /// An explicit track breadth.
    case trackBreadth(CSSTrackBreadth)
    /// The `minmax()` function.
    case minmax(min: CSSTrackBreadth, max: CSSTrackBreadth)
    /// The `fit-content()` function.
    case fitContent(CSSLengthPercentage)

    /// The default value (auto).
    public static var `default`: Self { .trackBreadth(.auto) }
}

// MARK: - Repeat Count

/// A repeat count for the `repeat()` function.
/// https://drafts.csswg.org/css-grid-2/#typedef-track-repeat
public enum CSSRepeatCount: Equatable, Sendable, Hashable {
    /// A specific number of repetitions.
    case number(Int)
    /// The `auto-fill` keyword.
    case autoFill
    /// The `auto-fit` keyword.
    case autoFit
}

// MARK: - Track Repeat

/// A `repeat()` function value.
/// https://drafts.csswg.org/css-grid-2/#typedef-track-repeat
public struct CSSTrackRepeat: Equatable, Sendable, Hashable {
    /// The repeat count.
    public var count: CSSRepeatCount
    /// The line names to repeat.
    public var lineNames: [[CSSCustomIdent]]
    /// The track sizes to repeat.
    public var trackSizes: [CSSTrackSize]

    public init(count: CSSRepeatCount, lineNames: [[CSSCustomIdent]], trackSizes: [CSSTrackSize]) {
        self.count = count
        self.lineNames = lineNames
        self.trackSizes = trackSizes
    }
}

// MARK: - Track List Item

/// Either a track size or `repeat()` function.
public enum CSSTrackListItem: Equatable, Sendable, Hashable {
    /// A track size.
    case trackSize(CSSTrackSize)
    /// A `repeat()` function.
    case trackRepeat(CSSTrackRepeat)
}

// MARK: - Track List

/// A track list for grid rows/columns.
/// https://drafts.csswg.org/css-grid-2/#typedef-track-list
public struct CSSTrackList: Equatable, Sendable, Hashable {
    /// A list of line names.
    public var lineNames: [[CSSCustomIdent]]
    /// A list of grid track items.
    public var items: [CSSTrackListItem]

    public init(lineNames: [[CSSCustomIdent]], items: [CSSTrackListItem]) {
        self.lineNames = lineNames
        self.items = items
    }

    /// Whether this track list contains only explicit track sizes (no repeat).
    public var isExplicit: Bool {
        items.allSatisfy { item in
            if case .trackSize = item { return true }
            return false
        }
    }
}

// MARK: - Track Sizing

/// A track sizing value for `grid-template-rows` and `grid-template-columns`.
/// https://drafts.csswg.org/css-grid-2/#track-sizing
public enum CSSTrackSizing: Equatable, Sendable, Hashable {
    /// No explicit grid tracks.
    case none
    /// A list of grid tracks.
    case trackList(CSSTrackList)

    /// Whether this track sizing is explicit (no repeat).
    public var isExplicit: Bool {
        switch self {
        case .none: true
        case let .trackList(list): list.isExplicit
        }
    }
}

// MARK: - Track Size List

/// A list of track sizes for `grid-auto-rows` and `grid-auto-columns`.
/// https://drafts.csswg.org/css-grid-2/#auto-tracks
public struct CSSTrackSizeList: Equatable, Sendable, Hashable {
    /// The track sizes.
    public var sizes: [CSSTrackSize]

    public init(_ sizes: [CSSTrackSize] = []) {
        self.sizes = sizes
    }

    /// The default value (auto).
    public static var `default`: Self { Self([]) }
}

// MARK: - Grid Template Areas

/// A value for the `grid-template-areas` property.
/// https://drafts.csswg.org/css-grid-2/#grid-template-areas-property
public enum CSSGridTemplateAreas: Equatable, Sendable, Hashable {
    /// No named grid areas.
    case none
    /// Defines the list of named grid areas.
    case areas(columns: Int, areas: [String?])
}

// MARK: - Grid Auto Flow

/// A value for the `grid-auto-flow` property.
/// https://drafts.csswg.org/css-grid-2/#grid-auto-flow-property
public struct CSSGridAutoFlow: OptionSet, Equatable, Sendable, Hashable {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    /// Row flow (default).
    public static let row = Self([])
    /// Column flow.
    public static let column = Self(rawValue: 0b01)
    /// Dense packing algorithm.
    public static let dense = Self(rawValue: 0b10)

    /// The default value (row).
    public static var `default`: Self { .row }

    /// Returns the direction (row or column).
    public var direction: Self {
        Self(rawValue: rawValue & 0b01)
    }
}

// MARK: - Grid Line

/// A grid line value for placement properties.
/// https://drafts.csswg.org/css-grid-2/#typedef-grid-row-start-grid-line
public enum CSSGridLine: Equatable, Sendable, Hashable {
    /// Automatic placement.
    case auto
    /// A named grid area.
    case area(CSSCustomIdent)
    /// The Nth grid line, optionally filtered by line name.
    case line(index: Int, name: CSSCustomIdent?)
    /// A span from the opposite edge.
    case span(index: Int, name: CSSCustomIdent?)

    /// Returns the default end value based on start.
    public func defaultEndValue() -> Self {
        switch self {
        case .area: self
        default: .auto
        }
    }

    /// Whether the end value can be omitted.
    public func canOmitEnd(_ end: Self) -> Bool {
        switch self {
        case let .area(startId):
            if case let .area(endId) = end, startId == endId {
                return true
            }
            return false
        default:
            return end == .auto
        }
    }
}

// MARK: - Grid Row/Column

/// A value for the `grid-row` shorthand property.
/// https://drafts.csswg.org/css-grid-2/#propdef-grid-row
public struct CSSGridRow: Equatable, Sendable, Hashable {
    /// The starting line.
    public var start: CSSGridLine
    /// The ending line.
    public var end: CSSGridLine

    public init(start: CSSGridLine, end: CSSGridLine) {
        self.start = start
        self.end = end
    }
}

/// A value for the `grid-column` shorthand property.
/// https://drafts.csswg.org/css-grid-2/#propdef-grid-column
public struct CSSGridColumn: Equatable, Sendable, Hashable {
    /// The starting line.
    public var start: CSSGridLine
    /// The ending line.
    public var end: CSSGridLine

    public init(start: CSSGridLine, end: CSSGridLine) {
        self.start = start
        self.end = end
    }
}

// MARK: - Grid Area

/// A value for the `grid-area` shorthand property.
/// https://drafts.csswg.org/css-grid-2/#propdef-grid-area
public struct CSSGridArea: Equatable, Sendable, Hashable {
    /// The grid row start placement.
    public var rowStart: CSSGridLine
    /// The grid column start placement.
    public var columnStart: CSSGridLine
    /// The grid row end placement.
    public var rowEnd: CSSGridLine
    /// The grid column end placement.
    public var columnEnd: CSSGridLine

    public init(rowStart: CSSGridLine, columnStart: CSSGridLine, rowEnd: CSSGridLine, columnEnd: CSSGridLine) {
        self.rowStart = rowStart
        self.columnStart = columnStart
        self.rowEnd = rowEnd
        self.columnEnd = columnEnd
    }
}

// MARK: - Grid Template

/// A value for the `grid-template` shorthand property.
/// https://drafts.csswg.org/css-grid-2/#explicit-grid-shorthand
public struct CSSGridTemplate: Equatable, Sendable, Hashable {
    /// The grid template rows.
    public var rows: CSSTrackSizing
    /// The grid template columns.
    public var columns: CSSTrackSizing
    /// The named grid areas.
    public var areas: CSSGridTemplateAreas

    public init(rows: CSSTrackSizing = .none, columns: CSSTrackSizing = .none, areas: CSSGridTemplateAreas = .none) {
        self.rows = rows
        self.columns = columns
        self.areas = areas
    }

    /// Whether this template is valid for the shorthand.
    public static func isValid(rows: CSSTrackSizing, columns: CSSTrackSizing, areas: CSSGridTemplateAreas) -> Bool {
        if case .none = areas { return true }
        if case .none = rows { return false }
        return rows.isExplicit && columns.isExplicit
    }
}

// MARK: - Grid

/// A value for the `grid` shorthand property.
/// https://drafts.csswg.org/css-grid-2/#grid-shorthand
public struct CSSGrid: Equatable, Sendable, Hashable {
    /// Explicit grid template rows.
    public var rows: CSSTrackSizing
    /// Explicit grid template columns.
    public var columns: CSSTrackSizing
    /// Explicit grid template areas.
    public var areas: CSSGridTemplateAreas
    /// The grid auto rows.
    public var autoRows: CSSTrackSizeList
    /// The grid auto columns.
    public var autoColumns: CSSTrackSizeList
    /// The grid auto flow.
    public var autoFlow: CSSGridAutoFlow

    public init(
        rows: CSSTrackSizing = .none,
        columns: CSSTrackSizing = .none,
        areas: CSSGridTemplateAreas = .none,
        autoRows: CSSTrackSizeList = .default,
        autoColumns: CSSTrackSizeList = .default,
        autoFlow: CSSGridAutoFlow = .default
    ) {
        self.rows = rows
        self.columns = columns
        self.areas = areas
        self.autoRows = autoRows
        self.autoColumns = autoColumns
        self.autoFlow = autoFlow
    }
}

// MARK: - Parsing

extension CSSTrackBreadth {
    static func parse(_ input: Parser, allowFlex: Bool = true) -> Result<CSSTrackBreadth, BasicParseError> {
        // Try length-percentage
        if case let .success(lp) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
            return .success(.length(lp))
        }

        // Try flex
        if allowFlex {
            if case let .success(flex) = input.tryParse({ parseFlex($0) }) {
                return .success(.flex(flex))
            }
        }

        // Try keywords
        if input.tryParse({ $0.expectIdentMatching("auto") }).isOK {
            return .success(.auto)
        }
        if input.tryParse({ $0.expectIdentMatching("min-content") }).isOK {
            return .success(.minContent)
        }
        if input.tryParse({ $0.expectIdentMatching("max-content") }).isOK {
            return .success(.maxContent)
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

private func parseFlex(_ input: Parser) -> Result<Double, BasicParseError> {
    let location = input.currentSourceLocation()
    switch input.next() {
    case let .success(token):
        if case let .dimension(numeric, unit) = token {
            if unit.value.lowercased() == "fr", numeric.value >= 0 {
                return .success(numeric.value)
            }
        }
        return .failure(location.newBasicUnexpectedTokenError(token))
    case let .failure(error):
        return .failure(error)
    }
}

extension CSSTrackSize {
    static func parse(_ input: Parser) -> Result<CSSTrackSize, BasicParseError> {
        // Try track breadth
        if case let .success(breadth) = input.tryParse({ CSSTrackBreadth.parse($0) }) {
            return .success(.trackBreadth(breadth))
        }

        // Try minmax()
        if input.tryParse({ $0.expectFunctionMatching("minmax") }).isOK {
            let result: Result<CSSTrackSize, ParseError<BasicParseErrorKind>> = input.parseNestedBlock { inner in
                switch CSSTrackBreadth.parse(inner, allowFlex: false) {
                case let .success(min):
                    guard inner.expectComma().isOK else {
                        return .failure(ParseError(kind: .basic(.endOfInput), location: inner.currentSourceLocation()))
                    }
                    switch CSSTrackBreadth.parse(inner) {
                    case let .success(max):
                        return .success(.minmax(min: min, max: max))
                    case let .failure(error):
                        return .failure(ParseError(kind: .basic(error.kind), location: error.location))
                    }
                case let .failure(error):
                    return .failure(ParseError(kind: .basic(error.kind), location: error.location))
                }
            }
            switch result {
            case let .success(size): return .success(size)
            case let .failure(error): return .failure(error.basic)
            }
        }

        // Try fit-content()
        if input.tryParse({ $0.expectFunctionMatching("fit-content") }).isOK {
            let result: Result<CSSTrackSize, ParseError<BasicParseErrorKind>> = input.parseNestedBlock { inner in
                switch CSSLengthPercentage.parse(inner) {
                case let .success(lp):
                    .success(.fitContent(lp))
                case let .failure(error):
                    .failure(ParseError(kind: .basic(error.kind), location: error.location))
                }
            }
            switch result {
            case let .success(size): return .success(size)
            case let .failure(error): return .failure(error.basic)
            }
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSRepeatCount {
    static func parse(_ input: Parser) -> Result<CSSRepeatCount, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("auto-fill") }).isOK {
            return .success(.autoFill)
        }
        if input.tryParse({ $0.expectIdentMatching("auto-fit") }).isOK {
            return .success(.autoFit)
        }

        // Try integer
        let location = input.currentSourceLocation()
        switch input.next() {
        case let .success(token):
            if case let .number(numeric) = token, let intVal = numeric.intValue {
                return .success(.number(Int(intVal)))
            }
            return .failure(location.newBasicUnexpectedTokenError(token))
        case let .failure(error):
            return .failure(error)
        }
    }
}

private func parseLineNames(_ input: Parser) -> Result<[CSSCustomIdent], BasicParseError> {
    guard input.expectSquareBracketBlock().isOK else {
        return .failure(input.newBasicError(.endOfInput))
    }

    let result: Result<[CSSCustomIdent], ParseError<BasicParseErrorKind>> = input.parseNestedBlock { inner in
        var names: [CSSCustomIdent] = []
        while case let .success(ident) = inner.tryParse({ CSSCustomIdent.parse($0) }) {
            names.append(ident)
        }
        return .success(names)
    }

    switch result {
    case let .success(names): return .success(names)
    case let .failure(error): return .failure(error.basic)
    }
}

extension CSSTrackRepeat {
    static func parse(_ input: Parser) -> Result<CSSTrackRepeat, BasicParseError> {
        guard input.expectFunctionMatching("repeat").isOK else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let result: Result<CSSTrackRepeat, ParseError<BasicParseErrorKind>> = input.parseNestedBlock { inner in
            switch CSSRepeatCount.parse(inner) {
            case let .failure(error):
                return .failure(ParseError(kind: .basic(error.kind), location: error.location))
            case let .success(count):
                guard inner.expectComma().isOK else {
                    return .failure(ParseError(kind: .basic(.endOfInput), location: inner.currentSourceLocation()))
                }

                var lineNames: [[CSSCustomIdent]] = []
                var trackSizes: [CSSTrackSize] = []

                while true {
                    if case let .success(names) = inner.tryParse({ parseLineNames($0) }) {
                        lineNames.append(names)
                    } else {
                        lineNames.append([])
                    }

                    if case let .success(size) = inner.tryParse({ CSSTrackSize.parse($0) }) {
                        trackSizes.append(size)
                    } else {
                        break
                    }
                }

                return .success(CSSTrackRepeat(count: count, lineNames: lineNames, trackSizes: trackSizes))
            }
        }

        switch result {
        case let .success(repeat_): return .success(repeat_)
        case let .failure(error): return .failure(error.basic)
        }
    }
}

extension CSSTrackList {
    static func parse(_ input: Parser) -> Result<CSSTrackList, BasicParseError> {
        var lineNames: [[CSSCustomIdent]] = []
        var items: [CSSTrackListItem] = []

        while true {
            if case let .success(names) = input.tryParse({ parseLineNames($0) }) {
                lineNames.append(names)
            } else {
                lineNames.append([])
            }

            if case let .success(size) = input.tryParse({ CSSTrackSize.parse($0) }) {
                items.append(.trackSize(size))
            } else if case let .success(repeat_) = input.tryParse({ CSSTrackRepeat.parse($0) }) {
                items.append(.trackRepeat(repeat_))
            } else {
                break
            }
        }

        if items.isEmpty {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(CSSTrackList(lineNames: lineNames, items: items))
    }
}

extension CSSTrackSizing {
    static func parse(_ input: Parser) -> Result<CSSTrackSizing, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        switch CSSTrackList.parse(input) {
        case let .success(list):
            return .success(.trackList(list))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSTrackSizeList {
    static func parse(_ input: Parser) -> Result<CSSTrackSizeList, BasicParseError> {
        var sizes: [CSSTrackSize] = []
        while case let .success(size) = input.tryParse({ CSSTrackSize.parse($0) }) {
            sizes.append(size)
        }

        // If only default auto, return empty
        if sizes.count == 1, sizes[0] == .default {
            sizes.removeAll()
        }

        return .success(CSSTrackSizeList(sizes))
    }
}

extension CSSGridAutoFlow {
    static func parse(_ input: Parser) -> Result<CSSGridAutoFlow, BasicParseError> {
        var flow = CSSGridAutoFlow.row

        if input.tryParse({ $0.expectIdentMatching("row") }).isOK {
            if input.tryParse({ $0.expectIdentMatching("dense") }).isOK {
                flow.insert(.dense)
            }
        } else if input.tryParse({ $0.expectIdentMatching("column") }).isOK {
            flow = .column
            if input.tryParse({ $0.expectIdentMatching("dense") }).isOK {
                flow.insert(.dense)
            }
        } else if input.tryParse({ $0.expectIdentMatching("dense") }).isOK {
            flow.insert(.dense)
            if input.tryParse({ $0.expectIdentMatching("row") }).isOK {
                // Already row
            } else if input.tryParse({ $0.expectIdentMatching("column") }).isOK {
                flow.insert(.column)
            }
        } else {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(flow)
    }
}

extension CSSGridLine {
    static func parse(_ input: Parser) -> Result<CSSGridLine, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("auto") }).isOK {
            return .success(.auto)
        }

        if input.tryParse({ $0.expectIdentMatching("span") }).isOK {
            // Parse span
            if case let .success(token) = input.tryParse({ $0.next() }) {
                if case let .number(numeric) = token, let intVal = numeric.intValue {
                    let index = Int(intVal)
                    if index == 0 {
                        return .failure(input.newBasicError(.endOfInput))
                    }
                    var name: CSSCustomIdent?
                    if case let .success(n) = input.tryParse({ CSSCustomIdent.parse($0) }) {
                        name = n
                    }
                    return .success(.span(index: index, name: name))
                }
            }

            if case let .success(ident) = input.tryParse({ CSSCustomIdent.parse($0) }) {
                var index = 1
                if case let .success(token) = input.tryParse({ $0.next() }) {
                    if case let .number(numeric) = token, let intVal = numeric.intValue {
                        index = Int(intVal)
                    }
                }
                if index == 0 {
                    return .failure(input.newBasicError(.endOfInput))
                }
                return .success(.span(index: index, name: ident))
            }

            return .failure(input.newBasicError(.endOfInput))
        }

        // Try integer
        if case let .success(token) = input.tryParse({ $0.next() }) {
            if case let .number(numeric) = token, let intVal = numeric.intValue {
                let index = Int(intVal)
                if index == 0 {
                    return .failure(input.newBasicError(.endOfInput))
                }
                var name: CSSCustomIdent?
                if case let .success(n) = input.tryParse({ CSSCustomIdent.parse($0) }) {
                    name = n
                }
                return .success(.line(index: index, name: name))
            }
        }

        // Try ident
        if case let .success(name) = CSSCustomIdent.parse(input) {
            // Check if followed by integer
            if case let .success(token) = input.tryParse({ $0.next() }) {
                if case let .number(numeric) = token, let intVal = numeric.intValue {
                    let index = Int(intVal)
                    if index == 0 {
                        return .failure(input.newBasicError(.endOfInput))
                    }
                    return .success(.line(index: index, name: name))
                }
            }
            return .success(.area(name))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSGridRow {
    static func parse(_ input: Parser) -> Result<CSSGridRow, BasicParseError> {
        guard case let .success(start) = CSSGridLine.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let end: CSSGridLine
        if input.tryParse({ $0.expectDelim("/") }).isOK {
            guard case let .success(e) = CSSGridLine.parse(input) else {
                return .failure(input.newBasicError(.endOfInput))
            }
            end = e
        } else {
            end = start.defaultEndValue()
        }

        return .success(CSSGridRow(start: start, end: end))
    }
}

extension CSSGridColumn {
    static func parse(_ input: Parser) -> Result<CSSGridColumn, BasicParseError> {
        guard case let .success(start) = CSSGridLine.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let end: CSSGridLine
        if input.tryParse({ $0.expectDelim("/") }).isOK {
            guard case let .success(e) = CSSGridLine.parse(input) else {
                return .failure(input.newBasicError(.endOfInput))
            }
            end = e
        } else {
            end = start.defaultEndValue()
        }

        return .success(CSSGridColumn(start: start, end: end))
    }
}

extension CSSGridArea {
    static func parse(_ input: Parser) -> Result<CSSGridArea, BasicParseError> {
        guard case let .success(rowStart) = CSSGridLine.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        guard input.tryParse({ $0.expectDelim("/") }).isOK else {
            let opposite = rowStart.defaultEndValue()
            return .success(CSSGridArea(rowStart: rowStart, columnStart: opposite, rowEnd: opposite, columnEnd: opposite))
        }

        guard case let .success(columnStart) = CSSGridLine.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        guard input.tryParse({ $0.expectDelim("/") }).isOK else {
            let rowEnd = rowStart.defaultEndValue()
            let columnEnd = columnStart.defaultEndValue()
            return .success(CSSGridArea(rowStart: rowStart, columnStart: columnStart, rowEnd: rowEnd, columnEnd: columnEnd))
        }

        guard case let .success(rowEnd) = CSSGridLine.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        guard input.tryParse({ $0.expectDelim("/") }).isOK else {
            let columnEnd = columnStart.defaultEndValue()
            return .success(CSSGridArea(rowStart: rowStart, columnStart: columnStart, rowEnd: rowEnd, columnEnd: columnEnd))
        }

        guard case let .success(columnEnd) = CSSGridLine.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(CSSGridArea(rowStart: rowStart, columnStart: columnStart, rowEnd: rowEnd, columnEnd: columnEnd))
    }
}

extension CSSGridTemplateAreas {
    static func parse(_ input: Parser) -> Result<CSSGridTemplateAreas, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        var tokens: [String?] = []
        var row = 0
        var columns = 0

        while case let .success(s) = input.tryParse({ (p: Parser) -> Result<Lexeme, BasicParseError> in p.expectString() }) {
            let parsedColumns = parseGridString(s.value, tokens: &tokens)
            if row == 0 {
                columns = parsedColumns
            } else if parsedColumns != columns {
                return .failure(input.newBasicError(.qualifiedRuleInvalid))
            }
            row += 1
        }

        if row == 0 {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(.areas(columns: columns, areas: tokens))
    }
}

private func parseGridString(_ string: String, tokens: inout [String?]) -> Int {
    var remaining = string
    var column = 0

    while !remaining.isEmpty {
        // Trim leading whitespace
        remaining = String(remaining.drop(while: { $0.isWhitespace }))
        if remaining.isEmpty {
            break
        }

        column += 1

        // Check for null cell token "."
        if remaining.hasPrefix(".") {
            remaining = String(remaining.drop(while: { $0 == "." }))
            tokens.append(nil)
            continue
        }

        // Parse named area
        var endIndex = remaining.startIndex
        for char in remaining {
            if char.isLetter || char.isNumber || char == "_" || char == "-" || char.unicodeScalars.first!.value >= 0x80 {
                endIndex = remaining.index(after: endIndex)
            } else {
                break
            }
        }

        if endIndex == remaining.startIndex {
            // Invalid character
            break
        }

        let token = String(remaining[..<endIndex])
        tokens.append(token)
        remaining = String(remaining[endIndex...])
    }

    return column
}

extension CSSGridTemplate {
    static func parse(_ input: Parser) -> Result<CSSGridTemplate, BasicParseError> {
        // Try "none"
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(CSSGridTemplate(rows: .none, columns: .none, areas: .none))
        }

        let start = input.state()
        var lineNames: [[CSSCustomIdent]] = []
        var items: [CSSTrackListItem] = []
        var columns = 0
        var row = 0
        var tokens: [String?] = []

        // Try to parse the areas syntax:
        // [ <line-names>? <string> <track-size>? <line-names>? ]+ [ / <explicit-track-list> ]?
        while true {
            // Try to parse leading line names
            if case let .success(names) = input.tryParse({ parseLineNames($0) }) {
                // Merge with existing last line names or start new
                if let lastIndex = lineNames.indices.last, !names.isEmpty {
                    lineNames[lastIndex].append(contentsOf: names)
                } else if !lineNames.isEmpty {
                    // Append empty entry later when we know we have a string
                } else {
                    lineNames.append(names)
                }
            } else if lineNames.isEmpty {
                lineNames.append([])
            }

            // Try to parse a string
            if case let .success(s) = input.tryParse({ (p: Parser) -> Result<Lexeme, BasicParseError> in p.expectString() }) {
                let parsedColumns = parseGridString(s.value, tokens: &tokens)

                if row == 0 {
                    columns = parsedColumns
                } else if parsedColumns != columns {
                    // Column count mismatch - invalid
                    return .failure(input.newBasicError(.qualifiedRuleInvalid))
                }

                row += 1

                // Parse optional track size
                let trackSize: CSSTrackSize = if case let .success(size) = input.tryParse({ CSSTrackSize.parse($0) }) {
                    size
                } else {
                    .default
                }
                items.append(.trackSize(trackSize))

                // Parse optional trailing line names
                if case let .success(names) = input.tryParse({ parseLineNames($0) }) {
                    lineNames.append(names)
                } else {
                    lineNames.append([])
                }
            } else {
                break
            }
        }

        // If we parsed any area strings, build the template with areas
        if !tokens.isEmpty {
            // Ensure line_names length matches items + 1
            while lineNames.count <= items.count {
                lineNames.append([])
            }

            let areas = CSSGridTemplateAreas.areas(columns: columns, areas: tokens)
            let rows = CSSTrackSizing.trackList(CSSTrackList(lineNames: lineNames, items: items))

            // Optionally parse "/" followed by explicit column track list
            let columnsResult: CSSTrackSizing
            if input.tryParse({ $0.expectDelim("/") }).isOK {
                if case let .success(list) = CSSTrackList.parse(input) {
                    if !list.isExplicit {
                        return .failure(input.newBasicError(.qualifiedRuleInvalid))
                    }
                    columnsResult = .trackList(list)
                } else {
                    return .failure(input.newBasicError(.endOfInput))
                }
            } else {
                columnsResult = .none
            }

            return .success(CSSGridTemplate(rows: rows, columns: columnsResult, areas: areas))
        }

        // Fall back to simple rows / columns syntax
        input.reset(start)
        if case let .success(rows) = CSSTrackSizing.parse(input) {
            if input.tryParse({ $0.expectDelim("/") }).isOK {
                if case let .success(cols) = CSSTrackSizing.parse(input) {
                    return .success(CSSGridTemplate(rows: rows, columns: cols, areas: .none))
                }
                return .failure(input.newBasicError(.endOfInput))
            }
            // Just rows, no columns
            return .success(CSSGridTemplate(rows: rows, columns: .none, areas: .none))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

/// Helper to parse `auto-flow && dense?` with a given base flow direction.
private func parseGridAutoFlow(_ input: Parser, baseFlow: CSSGridAutoFlow) -> Result<CSSGridAutoFlow, BasicParseError> {
    // Try "auto-flow [dense]"
    if input.tryParse({ $0.expectIdentMatching("auto-flow") }).isOK {
        var flow = baseFlow
        if input.tryParse({ $0.expectIdentMatching("dense") }).isOK {
            flow.insert(.dense)
        }
        return .success(flow)
    }

    // Try "dense auto-flow"
    if input.tryParse({ $0.expectIdentMatching("dense") }).isOK {
        if input.tryParse({ $0.expectIdentMatching("auto-flow") }).isOK {
            var flow = baseFlow
            flow.insert(.dense)
            return .success(flow)
        }
        return .failure(input.newBasicError(.endOfInput))
    }

    return .failure(input.newBasicError(.endOfInput))
}

extension CSSGrid {
    static func parse(_ input: Parser) -> Result<CSSGrid, BasicParseError> {
        // Try <'grid-template'> first
        if case let .success(template) = input.tryParse({ CSSGridTemplate.parse($0) }) {
            return .success(CSSGrid(
                rows: template.rows,
                columns: template.columns,
                areas: template.areas,
                autoRows: .default,
                autoColumns: .default,
                autoFlow: .default
            ))
        }

        // Try <'grid-template-rows'> / [ auto-flow && dense? ] <'grid-auto-columns'>?
        if case let .success(rows) = input.tryParse({ CSSTrackSizing.parse($0) }) {
            if input.tryParse({ $0.expectDelim("/") }).isOK {
                if case let .success(autoFlow) = parseGridAutoFlow(input, baseFlow: .column) {
                    var autoColumns = CSSTrackSizeList.default
                    if case let .success(cols) = input.tryParse({ CSSTrackSizeList.parse($0) }) {
                        autoColumns = cols
                    }
                    return .success(CSSGrid(
                        rows: rows,
                        columns: .none,
                        areas: .none,
                        autoRows: .default,
                        autoColumns: autoColumns,
                        autoFlow: autoFlow
                    ))
                }
            }
            // Reset not needed - tryParse handles it
        }

        // Try [ auto-flow && dense? ] <'grid-auto-rows'>? / <'grid-template-columns'>
        if case let .success(autoFlow) = parseGridAutoFlow(input, baseFlow: .row) {
            var autoRows = CSSTrackSizeList.default
            if case let .success(r) = input.tryParse({ CSSTrackSizeList.parse($0) }) {
                autoRows = r
            }

            guard input.tryParse({ $0.expectDelim("/") }).isOK else {
                return .failure(input.newBasicError(.endOfInput))
            }

            guard case let .success(columns) = CSSTrackSizing.parse(input) else {
                return .failure(input.newBasicError(.endOfInput))
            }

            return .success(CSSGrid(
                rows: .none,
                columns: columns,
                areas: .none,
                autoRows: autoRows,
                autoColumns: .default,
                autoFlow: autoFlow
            ))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

// MARK: - ToCss

extension CSSTrackBreadth: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .auto:
            dest.write("auto")
        case .minContent:
            dest.write("min-content")
        case .maxContent:
            dest.write("max-content")
        case let .length(lp):
            lp.serialize(dest: &dest)
        case let .flex(fr):
            serializeDimension(value: fr, unit: "fr", dest: &dest)
        }
    }
}

extension CSSTrackSize: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .trackBreadth(breadth):
            breadth.serialize(dest: &dest)
        case let .minmax(min, max):
            dest.write("minmax(")
            min.serialize(dest: &dest)
            dest.write(", ")
            max.serialize(dest: &dest)
            dest.write(")")
        case let .fitContent(lp):
            dest.write("fit-content(")
            lp.serialize(dest: &dest)
            dest.write(")")
        }
    }
}

extension CSSRepeatCount: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .number(n):
            dest.write(String(n))
        case .autoFill:
            dest.write("auto-fill")
        case .autoFit:
            dest.write("auto-fit")
        }
    }
}

private func serializeLineNames(_ names: [CSSCustomIdent], dest: inout some CSSWriter) {
    dest.write("[")
    var first = true
    for name in names {
        if first {
            first = false
        } else {
            dest.write(" ")
        }
        name.serialize(dest: &dest)
    }
    dest.write("]")
}

extension CSSTrackRepeat: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("repeat(")
        count.serialize(dest: &dest)
        dest.write(", ")

        var trackSizesIter = trackSizes.makeIterator()
        var first = true
        for names in lineNames {
            if !names.isEmpty {
                serializeLineNames(names, dest: &dest)
            }

            if let size = trackSizesIter.next() {
                if !names.isEmpty {
                    dest.write(" ")
                } else if !first {
                    dest.write(" ")
                }
                size.serialize(dest: &dest)
            }

            first = false
        }

        dest.write(")")
    }
}

extension CSSTrackList: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        var itemsIter = items.makeIterator()
        var first = true

        for names in lineNames {
            if !names.isEmpty {
                serializeLineNames(names, dest: &dest)
            }

            if let item = itemsIter.next() {
                if !names.isEmpty {
                    dest.write(" ")
                } else if !first {
                    dest.write(" ")
                }

                switch item {
                case let .trackSize(size):
                    size.serialize(dest: &dest)
                case let .trackRepeat(repeat_):
                    repeat_.serialize(dest: &dest)
                }
            }

            first = false
        }
    }
}

extension CSSTrackSizing: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case let .trackList(list):
            list.serialize(dest: &dest)
        }
    }
}

extension CSSTrackSizeList: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if sizes.isEmpty {
            dest.write("auto")
            return
        }

        var first = true
        for size in sizes {
            if first {
                first = false
            } else {
                dest.write(" ")
            }
            size.serialize(dest: &dest)
        }
    }
}

extension CSSGridTemplateAreas: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case let .areas(columns, areas):
            var iter = areas.makeIterator()
            var row = 0
            let rowCount = areas.count / columns

            while row < rowCount {
                if row > 0 {
                    dest.write(" ")
                }

                dest.write("\"")
                for col in 0 ..< columns {
                    if col > 0 {
                        dest.write(" ")
                    }
                    if let name = iter.next() {
                        if let n = name {
                            dest.write(n)
                        } else {
                            dest.write(".")
                        }
                    }
                }
                dest.write("\"")

                row += 1
            }
        }
    }
}

extension CSSGridAutoFlow: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if self == .row {
            dest.write("row")
        } else if self == .column {
            dest.write("column")
        } else if self == [.row, .dense] {
            dest.write("row dense")
        } else if self == [.column, .dense] {
            dest.write("column dense")
        }
    }
}

extension CSSGridLine: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .auto:
            dest.write("auto")
        case let .area(name):
            name.serialize(dest: &dest)
        case let .line(index, name):
            dest.write(String(index))
            if let n = name {
                dest.write(" ")
                n.serialize(dest: &dest)
            }
        case let .span(index, name):
            dest.write("span ")
            if index != 1 || name == nil {
                dest.write(String(index))
                if name != nil {
                    dest.write(" ")
                }
            }
            if let n = name {
                n.serialize(dest: &dest)
            }
        }
    }
}

extension CSSGridRow: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if !start.canOmitEnd(end) {
            dest.write(" / ")
            end.serialize(dest: &dest)
        }
    }
}

extension CSSGridColumn: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)
        if !start.canOmitEnd(end) {
            dest.write(" / ")
            end.serialize(dest: &dest)
        }
    }
}

extension CSSGridArea: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        rowStart.serialize(dest: &dest)

        let canOmitColumnEnd = columnStart.canOmitEnd(columnEnd)
        let canOmitRowEnd = canOmitColumnEnd && rowStart.canOmitEnd(rowEnd)
        let canOmitColumnStart = canOmitRowEnd && rowStart.canOmitEnd(columnStart)

        if !canOmitColumnStart {
            dest.write(" / ")
            columnStart.serialize(dest: &dest)
        }

        if !canOmitRowEnd {
            dest.write(" / ")
            rowEnd.serialize(dest: &dest)
        }

        if !canOmitColumnEnd {
            dest.write(" / ")
            columnEnd.serialize(dest: &dest)
        }
    }
}

extension CSSGridTemplate: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch areas {
        case .none:
            if case .none = rows, case .none = columns {
                dest.write("none")
            } else {
                rows.serialize(dest: &dest)
                dest.write(" / ")
                columns.serialize(dest: &dest)
            }
        case let .areas(columnCount, tokens):
            // Output the combined areas + rows syntax
            guard case let .trackList(trackList) = rows else {
                // Should not happen if parsing is correct, but fallback
                dest.write("none")
                return
            }

            var tokenIndex = 0
            var lineNamesIter = trackList.lineNames.makeIterator()
            var itemsIter = trackList.items.makeIterator()
            var rowIndex = 0
            let rowCount = tokens.count / max(columnCount, 1)

            while rowIndex < rowCount {
                if rowIndex > 0 {
                    dest.write(" ")
                }

                // Leading line names
                if let names = lineNamesIter.next(), !names.isEmpty {
                    serializeLineNames(names, dest: &dest)
                    dest.write(" ")
                }

                // Area string for this row
                dest.write("\"")
                for col in 0 ..< columnCount {
                    if col > 0 {
                        dest.write(" ")
                    }
                    if tokenIndex < tokens.count {
                        if let name = tokens[tokenIndex] {
                            dest.write(name)
                        } else {
                            dest.write(".")
                        }
                        tokenIndex += 1
                    }
                }
                dest.write("\"")

                // Track size
                if let item = itemsIter.next() {
                    if case let .trackSize(size) = item, size != .default {
                        dest.write(" ")
                        size.serialize(dest: &dest)
                    }
                }

                rowIndex += 1
            }

            // Trailing line names
            if let names = lineNamesIter.next(), !names.isEmpty {
                dest.write(" ")
                serializeLineNames(names, dest: &dest)
            }

            // Columns
            if case let .trackList(colList) = columns {
                dest.write(" / ")
                colList.serialize(dest: &dest)
            }
        }
    }
}

extension CSSGrid: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        let isAutoInitial = autoRows == .default && autoColumns == .default && autoFlow == .default

        if case .none = areas, isAutoInitial {
            // Simple template form
            let template = CSSGridTemplate(rows: rows, columns: columns, areas: .none)
            template.serialize(dest: &dest)
        } else if autoFlow.direction == .column {
            // rows / auto-flow [dense] [auto-columns]
            rows.serialize(dest: &dest)
            dest.write(" / auto-flow")
            if autoFlow.contains(.dense) {
                dest.write(" dense")
            }
            if autoColumns != .default {
                dest.write(" ")
                autoColumns.serialize(dest: &dest)
            }
        } else {
            // auto-flow [dense] [auto-rows] / columns
            dest.write("auto-flow")
            if autoFlow.contains(.dense) {
                dest.write(" dense")
            }
            if autoRows != .default {
                dest.write(" ")
                autoRows.serialize(dest: &dest)
            }
            dest.write(" / ")
            columns.serialize(dest: &dest)
        }
    }
}
