// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A container query condition.
///
/// See: https://drafts.csswg.org/css-contain-3/#container-condition
public indirect enum ContainerCondition: Equatable, Sendable, Hashable {
    /// A negated condition.
    case not(Self)
    /// A conjunction of conditions.
    case and([Self])
    /// A disjunction of conditions.
    case or([Self])
    /// A size feature query (e.g., `(min-width: 400px)`).
    case sizeFeature(ContainerSizeFeature)
    /// A style query (e.g., `style(--theme: dark)`).
    case style(ContainerStyleQuery)
    /// An unknown/unparsed condition.
    case unknown(String)
}

/// A container size feature.
public struct ContainerSizeFeature: Equatable, Sendable, Hashable {
    public let name: String
    public let comparison: ContainerComparison?
    public let value: ContainerSizeValue?

    public init(name: String, comparison: ContainerComparison? = nil, value: ContainerSizeValue? = nil) {
        self.name = name
        self.comparison = comparison
        self.value = value
    }
}

/// A comparison operator for container queries.
public enum ContainerComparison: Equatable, Sendable, Hashable {
    case equal
    case lessThan
    case lessThanOrEqual
    case greaterThan
    case greaterThanOrEqual
}

/// A value in a container size feature.
public enum ContainerSizeValue: Equatable, Sendable, Hashable {
    case length(CSSLength)
    case ratio(CSSRatio)
    case ident(String)
    case number(Double)
}

/// A container style query.
public struct ContainerStyleQuery: Equatable, Sendable, Hashable {
    public let property: String
    public let value: String?

    public init(property: String, value: String? = nil) {
        self.property = property
        self.value = value
    }
}

// MARK: - Parsing

private enum ContainerConnective {
    case none
    case and
    case or
}

private struct ContainerParseFrame {
    var parser: Parser
    var blockType: BlockType
    var isNot: Bool
    var connective: ContainerConnective
    var conditions: [ContainerCondition]
}

extension ContainerCondition {
    static func parse(_ input: Parser) -> Result<ContainerCondition, BasicParseError> {
        var stack: [ContainerParseFrame] = []
        var parser = input
        var isNot = false
        var connective: ContainerConnective = .none
        var conditions: [ContainerCondition] = []

        while true {
            parser.skipWhitespace()

            if case .success = parser.tryParse({ $0.expectIdentMatching("not") }) {
                isNot = true
                parser.skipWhitespace()
            }

            guard case let .success(token) = parser.next() else {
                return .failure(parser.newBasicError(.endOfInput))
            }

            if case let .function(name) = token, name.eqIgnoreAsciiCase("style") {
                guard let (nested, blockType) = parser.enterNestedBlock() else {
                    return .failure(parser.newBasicError(.endOfInput))
                }
                let styleQuery = parseStyleQuery(nested)
                parser.finishNestedBlock(blockType)

                var result: ContainerCondition = .style(styleQuery)
                if isNot {
                    result = .not(result)
                    isNot = false
                }
                conditions.append(result)
            } else if case .parenthesisBlock = token {
                guard let (nested, blockType) = parser.enterNestedBlock() else {
                    return .failure(parser.newBasicError(.endOfInput))
                }

                nested.skipWhitespace()
                let state = nested.state()

                if case .success = nested.tryParse({ $0.expectIdentMatching("not") }) {
                    stack.append(ContainerParseFrame(
                        parser: parser,
                        blockType: blockType,
                        isNot: isNot,
                        connective: connective,
                        conditions: conditions
                    ))
                    parser = nested
                    isNot = true
                    connective = .none
                    conditions = []
                    continue
                }

                nested.reset(state)

                if let feature = parseSizeFeature(nested) {
                    parser.finishNestedBlock(blockType)

                    var result: ContainerCondition = .sizeFeature(feature)
                    if isNot {
                        result = .not(result)
                        isNot = false
                    }
                    conditions.append(result)
                } else {
                    nested.reset(state)
                    let startPos = nested.position()
                    while case .success = nested.next() {}
                    let raw = String(nested.sliceFrom(startPos))
                    parser.finishNestedBlock(blockType)

                    var result: ContainerCondition = .unknown(raw)
                    if isNot {
                        result = .not(result)
                        isNot = false
                    }
                    conditions.append(result)
                }
            } else {
                return .failure(parser.newBasicError(.unexpectedToken(token)))
            }

            parser.skipWhitespace()

            let nextConnective: ContainerConnective = if case .success = parser.tryParse({ $0.expectIdentMatching("and") }) {
                .and
            } else if case .success = parser.tryParse({ $0.expectIdentMatching("or") }) {
                .or
            } else {
                .none
            }

            if nextConnective == .none {
                var result = buildCondition(conditions, connective)

                while let frame = stack.popLast() {
                    if frame.isNot {
                        result = .not(result)
                    }
                    var frameConditions = frame.conditions
                    frameConditions.append(result)
                    frame.parser.finishNestedBlock(frame.blockType)
                    parser = frame.parser

                    parser.skipWhitespace()
                    if case .success = parser.tryParse({ $0.expectIdentMatching("and") }) {
                        connective = .and
                        conditions = frameConditions
                        break
                    } else if case .success = parser.tryParse({ $0.expectIdentMatching("or") }) {
                        connective = .or
                        conditions = frameConditions
                        break
                    } else {
                        result = buildCondition(frameConditions, frame.connective)
                    }
                }

                if stack.isEmpty, nextConnective == .none {
                    return .success(result)
                }
            } else {
                connective = nextConnective
            }
        }
    }

    private static func buildCondition(_ conditions: [ContainerCondition], _ connective: ContainerConnective) -> ContainerCondition {
        if conditions.count == 1 {
            return conditions[0]
        }
        switch connective {
        case .and:
            return .and(conditions)
        case .or:
            return .or(conditions)
        case .none:
            return conditions.first ?? .unknown("")
        }
    }

    private static func parseSizeFeature(_ parser: Parser) -> ContainerSizeFeature? {
        parser.skipWhitespace()

        guard case let .success(token) = parser.next() else { return nil }
        guard case let .ident(name) = token else { return nil }

        let featureName = String(name.value)
        parser.skipWhitespace()

        if parser.isExhausted {
            return ContainerSizeFeature(name: featureName)
        }

        var comparison: ContainerComparison?
        if case let .success(next) = parser.next() {
            switch next {
            case .colon:
                comparison = .equal
            case let .delim(c) where c == "<":
                if case .success = parser.tryParse({ $0.expectDelim("=") }) {
                    comparison = .lessThanOrEqual
                } else {
                    comparison = .lessThan
                }
            case let .delim(c) where c == ">":
                if case .success = parser.tryParse({ $0.expectDelim("=") }) {
                    comparison = .greaterThanOrEqual
                } else {
                    comparison = .greaterThan
                }
            case let .delim(c) where c == "=":
                comparison = .equal
            default:
                return nil
            }
        }

        parser.skipWhitespace()

        let value: ContainerSizeValue? = if case let .success(valToken) = parser.next() {
            switch valToken {
            case let .dimension(num, unit):
                if let length = CSSLength(value: num.value, unit: String(unit.value)) {
                    .length(length)
                } else {
                    nil
                }
            case let .number(num):
                .number(num.value)
            case let .ident(ident):
                .ident(String(ident.value))
            default:
                nil
            }
        } else {
            nil
        }

        return ContainerSizeFeature(name: featureName, comparison: comparison, value: value)
    }

    private static func parseStyleQuery(_ parser: Parser) -> ContainerStyleQuery {
        parser.skipWhitespace()

        var property = ""
        var value: String?

        if case let .success(token) = parser.next() {
            if case let .ident(name) = token {
                property = String(name.value)
            } else if case .delim("-") = token {
                if case let .success(next) = parser.next(), case .delim("-") = next {
                    if case let .success(nameToken) = parser.next(), case let .ident(name) = nameToken {
                        property = "--\(name.value)"
                    }
                }
            }
        }

        parser.skipWhitespace()

        if case .success = parser.tryParse({ $0.expectColon() }) {
            parser.skipWhitespace()
            let valueStart = parser.position()
            while case .success = parser.next() {}
            value = String(parser.sliceFrom(valueStart)).trimmingCharacters(in: .whitespaces)
        }

        return ContainerStyleQuery(property: property, value: value)
    }
}

// MARK: - Serialization

extension ContainerCondition: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .not(condition):
            dest.write("not ")
            condition.serialize(dest: &dest)

        case let .and(conditions):
            for (i, condition) in conditions.enumerated() {
                if i > 0 {
                    dest.write(" and ")
                }
                condition.serialize(dest: &dest)
            }

        case let .or(conditions):
            for (i, condition) in conditions.enumerated() {
                if i > 0 {
                    dest.write(" or ")
                }
                condition.serialize(dest: &dest)
            }

        case let .sizeFeature(feature):
            dest.write("(")
            feature.serialize(dest: &dest)
            dest.write(")")

        case let .style(query):
            dest.write("style(")
            query.serialize(dest: &dest)
            dest.write(")")

        case let .unknown(raw):
            dest.write("(")
            dest.write(raw)
            dest.write(")")
        }
    }
}

extension ContainerSizeFeature: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(name)
        if let comparison, let value {
            switch comparison {
            case .equal:
                dest.write(": ")
            case .lessThan:
                dest.write(" < ")
            case .lessThanOrEqual:
                dest.write(" <= ")
            case .greaterThan:
                dest.write(" > ")
            case .greaterThanOrEqual:
                dest.write(" >= ")
            }
            value.serialize(dest: &dest)
        }
    }
}

extension ContainerSizeValue: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .length(l):
            l.serialize(dest: &dest)
        case let .ratio(r):
            r.serialize(dest: &dest)
        case let .ident(s):
            dest.write(s)
        case let .number(n):
            dest.write(formatDouble(n))
        }
    }
}

extension ContainerStyleQuery: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(property)
        if let value {
            dest.write(": ")
            dest.write(value)
        }
    }
}
