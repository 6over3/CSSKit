// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `<display-outside>` value.
/// https://drafts.csswg.org/css-display-3/#typedef-display-outside
public enum CSSDisplayOutside: String, Equatable, Sendable, Hashable {
    case block
    case inline
    case runIn = "run-in"
}

/// A `<display-inside>` value.
/// https://drafts.csswg.org/css-display-3/#typedef-display-inside
public enum CSSDisplayInside: Equatable, Sendable, Hashable {
    case flow
    case flowRoot
    case table
    /// Standard flex display (and prefixed variants).
    case flex(CSSVendorPrefix)
    /// Legacy 2009 box display (webkit/moz).
    case box(CSSVendorPrefix)
    case grid
    case ruby

    /// Standard flex with no vendor prefix.
    public static var flex: Self { .flex(.none) }

    /// Checks if two display-inside values are equivalent
    /// (e.g., flex and box are considered equivalent for prefixing purposes).
    public func isEquivalent(to other: Self) -> Bool {
        switch (self, other) {
        case (.flex, .flex), (.box, .box): true
        case (.flex, .box), (.box, .flex): true
        default: self == other
        }
    }
}

/// A display keyword value.
/// https://drafts.csswg.org/css-display-3/#the-display-properties
public enum CSSDisplayKeyword: String, Equatable, Sendable, Hashable {
    case none
    case contents
    case tableRowGroup = "table-row-group"
    case tableHeaderGroup = "table-header-group"
    case tableFooterGroup = "table-footer-group"
    case tableRow = "table-row"
    case tableCell = "table-cell"
    case tableColumnGroup = "table-column-group"
    case tableColumn = "table-column"
    case tableCaption = "table-caption"
    case rubyBase = "ruby-base"
    case rubyText = "ruby-text"
    case rubyBaseContainer = "ruby-base-container"
    case rubyTextContainer = "ruby-text-container"
}

/// A display pair value combining inside and outside display types.
public struct CSSDisplayPair: Equatable, Sendable, Hashable {
    /// The outside display value.
    public let outside: CSSDisplayOutside
    /// The inside display value.
    public let inside: CSSDisplayInside
    /// Whether this is a list item.
    public let isListItem: Bool

    public init(outside: CSSDisplayOutside, inside: CSSDisplayInside, isListItem: Bool = false) {
        self.outside = outside
        self.inside = inside
        self.isListItem = isListItem
    }
}

/// A value for the `display` property.
/// https://drafts.csswg.org/css-display-3/#the-display-properties
public enum CSSDisplay: Equatable, Sendable, Hashable {
    /// A display keyword value.
    case keyword(CSSDisplayKeyword)
    /// A display pair (inside/outside) value.
    case pair(CSSDisplayPair)
}

// MARK: - Parsing

extension CSSDisplayOutside {
    static func parse(_ input: Parser) -> Result<CSSDisplayOutside, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "block": return .success(.block)
        case "inline": return .success(.inline)
        case "run-in": return .success(.runIn)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSDisplayInside {
    static func parse(_ input: Parser) -> Result<CSSDisplayInside, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "flow": return .success(.flow)
        case "flow-root": return .success(.flowRoot)
        case "table": return .success(.table)
        case "flex": return .success(.flex(.none))
        case "-webkit-flex": return .success(.flex(.webkit))
        case "-ms-flexbox": return .success(.flex(.ms))
        case "-webkit-box": return .success(.box(.webkit))
        case "-moz-box": return .success(.box(.moz))
        case "grid": return .success(.grid)
        case "ruby": return .success(.ruby)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSDisplayKeyword {
    static func parse(_ input: Parser) -> Result<CSSDisplayKeyword, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "none": return .success(.none)
        case "contents": return .success(.contents)
        case "table-row-group": return .success(.tableRowGroup)
        case "table-header-group": return .success(.tableHeaderGroup)
        case "table-footer-group": return .success(.tableFooterGroup)
        case "table-row": return .success(.tableRow)
        case "table-cell": return .success(.tableCell)
        case "table-column-group": return .success(.tableColumnGroup)
        case "table-column": return .success(.tableColumn)
        case "table-caption": return .success(.tableCaption)
        case "ruby-base": return .success(.rubyBase)
        case "ruby-text": return .success(.rubyText)
        case "ruby-base-container": return .success(.rubyBaseContainer)
        case "ruby-text-container": return .success(.rubyTextContainer)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSDisplayPair {
    static func parse(_ input: Parser) -> Result<CSSDisplayPair, BasicParseError> {
        var listItem = false
        var outside: CSSDisplayOutside?
        var inside: CSSDisplayInside?

        // Parse components in any order
        while true {
            // Try list-item
            if input.tryParse({ $0.expectIdentMatching("list-item") }).isOK {
                listItem = true
                continue
            }

            // Try outside
            if outside == nil {
                if case let .success(o) = input.tryParse({ CSSDisplayOutside.parse($0) }) {
                    outside = o
                    continue
                }
            }

            // Try inside
            if inside == nil {
                if case let .success(i) = input.tryParse({ CSSDisplayInside.parse($0) }) {
                    inside = i
                    continue
                }
            }

            break
        }

        if listItem || inside != nil || outside != nil {
            let resolvedInside = inside ?? .flow
            let resolvedOutside = outside ?? (resolvedInside == .ruby ? .inline : .block)

            // list-item is only valid with flow or flow-root
            if listItem, resolvedInside != .flow, resolvedInside != .flowRoot {
                return .failure(input.newBasicError(.endOfInput))
            }

            return .success(CSSDisplayPair(
                outside: resolvedOutside,
                inside: resolvedInside,
                isListItem: listItem
            ))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSDisplay {
    /// Parses a `display` property value.
    static func parse(_ input: Parser) -> Result<CSSDisplay, BasicParseError> {
        let state = input.state()

        // Try display keywords first
        if case let .success(keyword) = input.tryParse({ CSSDisplayKeyword.parse($0) }) {
            return .success(.keyword(keyword))
        }

        input.reset(state)

        // Try combined shorthand values
        if case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
            switch ident.value.lowercased() {
            case "inline-block":
                return .success(.pair(CSSDisplayPair(outside: .inline, inside: .flowRoot)))
            case "inline-table":
                return .success(.pair(CSSDisplayPair(outside: .inline, inside: .table)))
            case "inline-flex":
                return .success(.pair(CSSDisplayPair(outside: .inline, inside: .flex(.none))))
            case "-webkit-inline-flex":
                return .success(.pair(CSSDisplayPair(outside: .inline, inside: .flex(.webkit))))
            case "-ms-inline-flexbox":
                return .success(.pair(CSSDisplayPair(outside: .inline, inside: .flex(.ms))))
            case "-webkit-inline-box":
                return .success(.pair(CSSDisplayPair(outside: .inline, inside: .box(.webkit))))
            case "-moz-inline-box":
                return .success(.pair(CSSDisplayPair(outside: .inline, inside: .box(.moz))))
            case "inline-grid":
                return .success(.pair(CSSDisplayPair(outside: .inline, inside: .grid)))
            default:
                break
            }
        }

        input.reset(state)

        // Try display pair
        if case let .success(pair) = CSSDisplayPair.parse(input) {
            return .success(.pair(pair))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

// MARK: - ToCss

extension CSSDisplayOutside: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSDisplayInside: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .flow: dest.write("flow")
        case .flowRoot: dest.write("flow-root")
        case .table: dest.write("table")
        case let .flex(prefix):
            prefix.serialize(dest: &dest)
            if prefix == .ms {
                dest.write("flexbox")
            } else {
                dest.write("flex")
            }
        case let .box(prefix):
            prefix.serialize(dest: &dest)
            dest.write("box")
        case .grid: dest.write("grid")
        case .ruby: dest.write("ruby")
        }
    }
}

extension CSSDisplayKeyword: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSDisplayPair: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        // Use shorthand forms when possible
        switch (outside, inside, isListItem) {
        case (.inline, .flowRoot, false):
            dest.write("inline-block")
        case (.inline, .table, false):
            dest.write("inline-table")
        case (.inline, let .flex(prefix), false):
            prefix.serialize(dest: &dest)
            if prefix == .ms {
                dest.write("inline-flexbox")
            } else {
                dest.write("inline-flex")
            }
        case (.inline, let .box(prefix), false):
            prefix.serialize(dest: &dest)
            dest.write("inline-box")
        case (.inline, .grid, false):
            dest.write("inline-grid")
        default:
            let defaultOutside: CSSDisplayOutside = inside == .ruby ? .inline : .block
            var needsSpace = false

            if outside != defaultOutside || (inside == .flow && !isListItem) {
                outside.serialize(dest: &dest)
                needsSpace = true
            }

            if inside != .flow {
                if needsSpace {
                    dest.write(" ")
                }
                inside.serialize(dest: &dest)
                needsSpace = true
            }

            if isListItem {
                if needsSpace {
                    dest.write(" ")
                }
                dest.write("list-item")
            }
        }
    }
}

extension CSSDisplay: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .keyword(keyword):
            keyword.serialize(dest: &dest)
        case let .pair(pair):
            pair.serialize(dest: &dest)
        }
    }
}
