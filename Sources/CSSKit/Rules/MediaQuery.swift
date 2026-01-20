// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - MediaList

/// A list of media queries.
///
/// Example: `screen and (min-width: 768px), print`
public struct MediaList: Equatable, Sendable, Hashable {
    /// The media queries in the list.
    public let queries: [MediaQuery]

    /// Creates a media list.
    public init(queries: [MediaQuery]) {
        self.queries = queries
    }

    /// Whether this media list always matches (empty list or only `all`).
    public var alwaysMatches: Bool {
        queries.isEmpty || (queries.count == 1 && queries[0].alwaysMatches)
    }

    /// Whether this media list never matches.
    public var neverMatches: Bool {
        !queries.isEmpty && queries.allSatisfy(\.neverMatches)
    }
}

extension MediaList {
    /// Parses a media query list.
    static func parse(_ input: Parser) -> Result<MediaList, BasicParseError> {
        var queries: [MediaQuery] = []

        while !input.isExhausted {
            switch MediaQuery.parse(input) {
            case let .success(query):
                queries.append(query)
            case let .failure(error):
                if queries.isEmpty {
                    return .failure(error)
                }
            }

            // Check for comma
            if case .failure = input.tryParse({ p in p.expectComma() }) {
                break
            }
        }

        return .success(MediaList(queries: queries))
    }
}

extension MediaList: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        for (index, query) in queries.enumerated() {
            if index > 0 {
                dest.write(", ")
            }
            query.serialize(dest: &dest)
        }
    }
}

// MARK: - MediaQuery

/// A single media query.
///
/// Example: `screen and (min-width: 768px)`
public struct MediaQuery: Equatable, Sendable, Hashable {
    /// The qualifier (e.g., `not`, `only`).
    public let qualifier: MediaQueryQualifier?

    /// The media type (e.g., `screen`, `print`, `all`).
    public let mediaType: MediaType?

    /// The condition (feature expressions combined with `and`/`or`/`not`).
    public let condition: MediaCondition?

    /// Creates a media query.
    public init(
        qualifier: MediaQueryQualifier? = nil,
        mediaType: MediaType? = nil,
        condition: MediaCondition? = nil
    ) {
        self.qualifier = qualifier
        self.mediaType = mediaType
        self.condition = condition
    }

    /// Whether this query always matches.
    public var alwaysMatches: Bool {
        qualifier == nil && (mediaType == nil || mediaType == .all) && condition == nil
    }

    /// Whether this query never matches.
    public var neverMatches: Bool {
        qualifier == .not && (mediaType == nil || mediaType == .all) && condition == nil
    }
}

extension MediaQuery {
    /// Parses a media query.
    static func parse(_ input: Parser) -> Result<MediaQuery, BasicParseError> {
        // Try to parse condition-only query first (e.g., "(min-width: 768px)")
        if case let .success(condition) = input.tryParse({ p in MediaCondition.parse(p, allowOr: true) }) {
            return .success(MediaQuery(condition: condition))
        }

        // Parse optional qualifier
        var qualifier: MediaQueryQualifier?
        if case let .success(ident) = input.tryParse({ p in p.expectIdent() }) {
            let value = ident.value.lowercased()
            if value == "not" {
                qualifier = .not
            } else if value == "only" {
                qualifier = .only
            } else {
                // It's actually the media type
                let mediaType = MediaType(rawValue: value) ?? .custom(String(ident.value))
                // Check for "and" + condition
                var condition: MediaCondition?
                if case .success = input.tryParse({ p in p.expectIdentMatching("and") }) {
                    if case let .success(cond) = MediaCondition.parse(input, allowOr: false) {
                        condition = cond
                    }
                }
                return .success(MediaQuery(qualifier: nil, mediaType: mediaType, condition: condition))
            }
        }

        // Parse media type
        var mediaType: MediaType?
        if case let .success(ident) = input.tryParse({ p in p.expectIdent() }) {
            mediaType = MediaType(rawValue: ident.value.lowercased()) ?? .custom(String(ident.value))
        }

        // Parse optional "and" + condition
        var condition: MediaCondition?
        if case .success = input.tryParse({ p in p.expectIdentMatching("and") }) {
            if case let .success(cond) = MediaCondition.parse(input, allowOr: false) {
                condition = cond
            }
        }

        return .success(MediaQuery(qualifier: qualifier, mediaType: mediaType, condition: condition))
    }
}

extension MediaQuery: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if let qualifier {
            qualifier.serialize(dest: &dest)
            dest.write(" ")
        }

        if let mediaType {
            mediaType.serialize(dest: &dest)
            if condition != nil {
                dest.write(" and ")
            }
        }

        if let condition {
            condition.serialize(dest: &dest)
        }
    }
}

// MARK: - MediaQueryQualifier

/// A media query qualifier (`not` or `only`).
public enum MediaQueryQualifier: String, Equatable, Sendable, Hashable {
    case not
    case only
}

extension MediaQueryQualifier: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

// MARK: - MediaType

/// A media type.
public enum MediaType: Equatable, Sendable, Hashable {
    case all
    case print
    case screen
    case custom(String)

    init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "all": self = .all
        case "print": self = .print
        case "screen": self = .screen
        default: self = .custom(rawValue)
        }
    }
}

extension MediaType: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .all: dest.write("all")
        case .print: dest.write("print")
        case .screen: dest.write("screen")
        case let .custom(name): dest.write(name)
        }
    }
}

// MARK: - MediaCondition

/// A media condition (feature expressions combined with and/or/not).
public indirect enum MediaCondition: Equatable, Sendable, Hashable {
    /// A `not` condition.
    case not(Self)
    /// An `and` condition.
    case and([Self])
    /// An `or` condition.
    case or([Self])
    /// A media feature.
    case feature(MediaFeature)
}

private enum MediaConnective {
    case none
    case and
    case or
}

private struct MediaParseFrame {
    var parser: Parser
    var blockType: BlockType
    var isNot: Bool
    var connective: MediaConnective
    var conditions: [MediaCondition]
    var allowOr: Bool
}

extension MediaCondition {
    /// Parses a media condition.
    static func parse(_ input: Parser, allowOr: Bool) -> Result<MediaCondition, BasicParseError> {
        var stack: [MediaParseFrame] = []
        var parser = input
        var isNot = false
        var connective: MediaConnective = .none
        var conditions: [MediaCondition] = []
        var currentAllowOr = allowOr

        while true {
            // Check for "not" keyword
            if case .success = parser.tryParse({ p in p.expectIdentMatching("not") }) {
                isNot = true
            }

            // Expect parenthesis
            guard case .success = parser.expectParenthesisBlock() else {
                return .failure(parser.newBasicError(.endOfInput))
            }

            guard let (nested, blockType) = parser.enterNestedBlock() else {
                return .failure(parser.newBasicError(.endOfInput))
            }

            // Check if this is a nested condition
            let nestedState = nested.state()
            let isNestedCondition: Bool
            if case .success = nested.tryParse({ p in p.expectIdentMatching("not") }) {
                isNestedCondition = true
                nested.reset(nestedState)
            } else if case .success = nested.tryParse({ $0.expectParenthesisBlock() }) {
                isNestedCondition = true
                nested.reset(nestedState)
            } else {
                isNestedCondition = false
            }

            if isNestedCondition {
                // Push current state and descend
                stack.append(MediaParseFrame(
                    parser: parser, blockType: blockType, isNot: isNot,
                    connective: connective, conditions: conditions, allowOr: currentAllowOr
                ))
                parser = nested
                isNot = false
                connective = .none
                conditions = []
                currentAllowOr = true
                continue
            }

            // Parse as feature
            switch MediaFeature.parse(nested) {
            case let .success(feature):
                parser.finishNestedBlock(blockType)
                var result: MediaCondition = .feature(feature)
                if isNot {
                    result = .not(result)
                    isNot = false
                }
                conditions.append(result)
            case let .failure(error):
                return .failure(error)
            }

            // After parsing one condition, check for "and" or "or"
            while true {
                if case let .success(ident) = parser.tryParse({ p in p.expectIdent() }) {
                    let value = ident.value.lowercased()
                    if value == "and" {
                        if case .none = connective { connective = .and } else if case .or = connective { break }
                    } else if value == "or", currentAllowOr {
                        if case .none = connective { connective = .or } else if case .and = connective { break }
                    } else {
                        break
                    }

                    isNot = false
                    break
                } else {
                    // No more connectives - finalize current level
                    var result: MediaCondition = if conditions.count == 1 {
                        conditions[0]
                    } else if case .and = connective {
                        .and(conditions)
                    } else {
                        .or(conditions)
                    }

                    // Pop stack if any
                    if let frame = stack.popLast() {
                        if frame.isNot {
                            result = .not(result)
                        }
                        frame.parser.finishNestedBlock(frame.blockType)
                        parser = frame.parser
                        connective = frame.connective
                        conditions = frame.conditions
                        currentAllowOr = frame.allowOr
                        conditions.append(result)
                        continue
                    }

                    return .success(result)
                }
            }
        }
    }
}

private enum MediaConditionSerializeWork {
    case condition(MediaCondition)
    case text(String)
}

extension MediaCondition: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        var stack: [MediaConditionSerializeWork] = [.condition(self)]

        while let work = stack.popLast() {
            switch work {
            case let .text(s):
                dest.write(s)

            case let .condition(cond):
                switch cond {
                case let .not(inner):
                    stack.append(.text(")"))
                    stack.append(.condition(inner))
                    dest.write("not (")

                case let .and(conditions):
                    for (index, c) in conditions.enumerated().reversed() {
                        if index < conditions.count - 1 {
                            stack.append(.text(") and ("))
                        } else {
                            stack.append(.text(")"))
                        }
                        stack.append(.condition(c))
                    }
                    dest.write("(")

                case let .or(conditions):
                    for (index, c) in conditions.enumerated().reversed() {
                        if index < conditions.count - 1 {
                            stack.append(.text(") or ("))
                        } else {
                            stack.append(.text(")"))
                        }
                        stack.append(.condition(c))
                    }
                    dest.write("(")

                case let .feature(feature):
                    feature.serialize(dest: &dest)
                }
            }
        }
    }
}

// MARK: - MediaFeatureValue

/// A typed value for media features.
public enum MediaFeatureValue: Equatable, Sendable, Hashable {
    /// A length value (e.g., `768px`, `50em`).
    case length(CSSLength)
    /// A number value.
    case number(Double)
    /// An integer value.
    case integer(Int)
    /// A ratio value (e.g., `16/9`).
    case ratio(CSSRatio)
    /// A resolution value (e.g., `2dppx`).
    case resolution(CSSResolution)
    /// An identifier value (e.g., `landscape`, `dark`).
    case ident(String)
}

extension MediaFeatureValue: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .length(l): l.serialize(dest: &dest)
        case let .number(n): dest.write(formatDouble(n))
        case let .integer(i): dest.write(String(i))
        case let .ratio(r): r.serialize(dest: &dest)
        case let .resolution(r): r.serialize(dest: &dest)
        case let .ident(s): dest.write(s)
        }
    }
}

// MARK: - MediaFeatureComparison

/// A comparison operator for range media features.
public enum MediaFeatureComparison: Equatable, Sendable, Hashable {
    case equal
    case lessThan
    case lessThanOrEqual
    case greaterThan
    case greaterThanOrEqual
}

extension MediaFeatureComparison: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .equal: dest.write(": ")
        case .lessThan: dest.write(" < ")
        case .lessThanOrEqual: dest.write(" <= ")
        case .greaterThan: dest.write(" > ")
        case .greaterThanOrEqual: dest.write(" >= ")
        }
    }
}

// MARK: - MediaFeature

/// A media feature expression.
///
/// Example: `min-width: 768px`, `color`, `aspect-ratio: 16/9`, `width > 400px`
public enum MediaFeature: Equatable, Sendable, Hashable {
    /// A boolean feature (e.g., `(color)`, `(hover)`).
    case boolean(name: String)
    /// A plain feature with colon syntax (e.g., `(min-width: 768px)`).
    case plain(name: String, value: MediaFeatureValue)
    /// A range feature (e.g., `(width > 400px)`).
    case range(name: String, comparison: MediaFeatureComparison, value: MediaFeatureValue)
    /// An interval feature (e.g., `(400px < width < 800px)`).
    case interval(name: String, lower: MediaFeatureValue, upper: MediaFeatureValue)
}

extension MediaFeature {
    static func parse(_ input: Parser) -> Result<MediaFeature, BasicParseError> {
        input.skipWhitespace()

        // Check for interval syntax like `400px < width < 800px`
        // Interval starts with dimension/number, not ident
        let state = input.state()
        if let leadingValue = tryParseDimensionOrNumber(input) {
            input.skipWhitespace()
            if case .success = input.tryParse({ $0.expectDelim("<") }) {
                let leq = input.tryParse { $0.expectDelim("=") }.isSuccess
                input.skipWhitespace()

                guard case let .success(nameIdent) = input.expectIdent() else {
                    return .failure(input.newBasicError(.endOfInput))
                }
                let name = String(nameIdent.value)
                input.skipWhitespace()

                if case .success = input.tryParse({ $0.expectDelim("<") }) {
                    _ = input.tryParse { $0.expectDelim("=") }
                    input.skipWhitespace()
                    if let upperValue = tryParseValue(input) {
                        return .success(.interval(name: name, lower: leadingValue, upper: upperValue))
                    }
                }
                // Single comparison: value < name
                return .success(.range(name: name, comparison: leq ? .lessThanOrEqual : .lessThan, value: leadingValue))
            }
            // Not interval syntax, reset and parse normally
            input.reset(state)
        }

        // Parse feature name
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        let name = String(ident.value)
        input.skipWhitespace()

        // Check for colon
        if case .success = input.tryParse({ $0.expectColon() }) {
            input.skipWhitespace()
            if let value = tryParseValue(input) {
                return .success(.plain(name: name, value: value))
            }
            return .success(.boolean(name: name))
        }

        // Check for comparison operators
        if case .success = input.tryParse({ $0.expectDelim("<") }) {
            let leq = input.tryParse { $0.expectDelim("=") }.isSuccess
            input.skipWhitespace()
            if let value = tryParseValue(input) {
                return .success(.range(name: name, comparison: leq ? .lessThanOrEqual : .lessThan, value: value))
            }
        }

        if case .success = input.tryParse({ $0.expectDelim(">") }) {
            let geq = input.tryParse { $0.expectDelim("=") }.isSuccess
            input.skipWhitespace()
            if let value = tryParseValue(input) {
                return .success(.range(name: name, comparison: geq ? .greaterThanOrEqual : .greaterThan, value: value))
            }
        }

        if case .success = input.tryParse({ $0.expectDelim("=") }) {
            input.skipWhitespace()
            if let value = tryParseValue(input) {
                return .success(.range(name: name, comparison: .equal, value: value))
            }
        }

        return .success(.boolean(name: name))
    }

    private static func tryParseDimensionOrNumber(_ input: Parser) -> MediaFeatureValue? {
        let state = input.state()

        if case let .success(len) = CSSLength.parse(input) {
            return .length(len)
        }
        input.reset(state)

        if case let .success(res) = CSSResolution.parse(input) {
            return .resolution(res)
        }
        input.reset(state)

        if case let .success(token) = input.next(), case let .number(num) = token {
            if let intVal = num.intValue {
                return .integer(Int(intVal))
            }
            return .number(num.value)
        }

        input.reset(state)
        return nil
    }

    private static func tryParseValue(_ input: Parser) -> MediaFeatureValue? {
        let state = input.state()

        // Try ratio first
        if case let .success(ratio) = CSSRatio.parse(input) {
            return .ratio(ratio)
        }
        input.reset(state)

        // Try resolution
        if case let .success(res) = CSSResolution.parse(input) {
            return .resolution(res)
        }
        input.reset(state)

        // Try length
        if case let .success(len) = CSSLength.parse(input) {
            return .length(len)
        }
        input.reset(state)

        // Try number/integer/ident
        if case let .success(token) = input.next() {
            if case let .number(num) = token {
                if let intVal = num.intValue {
                    return .integer(Int(intVal))
                }
                return .number(num.value)
            } else if case let .ident(id) = token {
                return .ident(String(id.value))
            }
        }

        input.reset(state)
        return nil
    }
}

extension MediaFeature: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .boolean(name):
            dest.write(name)

        case let .plain(name, value):
            dest.write(name)
            dest.write(": ")
            value.serialize(dest: &dest)

        case let .range(name, comparison, value):
            dest.write(name)
            comparison.serialize(dest: &dest)
            value.serialize(dest: &dest)

        case let .interval(name, lower, upper):
            lower.serialize(dest: &dest)
            dest.write(" < ")
            dest.write(name)
            dest.write(" < ")
            upper.serialize(dest: &dest)
        }
    }
}
