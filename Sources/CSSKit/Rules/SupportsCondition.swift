// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A `<supports-condition>`, as used in `@supports` and `@import` rules.
///
/// See: https://drafts.csswg.org/css-conditional-3/#typedef-supports-condition
public indirect enum SupportsCondition: Equatable, Sendable, Hashable {
    /// A `not` expression.
    case not(Self)
    /// An `and` expression.
    case and([Self])
    /// An `or` expression.
    case or([Self])
    /// A declaration to evaluate (e.g., `display: flex`).
    case declaration(property: String, value: String)
    /// A selector to evaluate (e.g., `selector(:has(*))`).
    case selector(String)
    /// An unknown/unparsed condition.
    case unknown(String)
}

// MARK: - Parsing

private enum SupportsConnective {
    case none
    case and
    case or
}

private struct SupportsParseFrame {
    var parser: Parser
    var blockType: BlockType
    var isNot: Bool
    var connective: SupportsConnective
    var conditions: [SupportsCondition]
}

extension SupportsCondition {
    static func parse(_ input: Parser) -> Result<SupportsCondition, BasicParseError> {
        var stack: [SupportsParseFrame] = []
        var parser = input
        var isNot = false
        var connective: SupportsConnective = .none
        var conditions: [SupportsCondition] = []

        while true {
            // Check for "not" keyword
            if case .success = parser.tryParse({ p in p.expectIdentMatching("not") }) {
                isNot = true
            }

            // Try to parse parenthesized content
            parser.skipWhitespace()

            guard case let .success(token) = parser.next() else {
                return .failure(parser.newBasicError(.endOfInput))
            }

            // Handle selector() function
            if case let .function(name) = token, name.eqIgnoreAsciiCase("selector") {
                guard let (nested, blockType) = parser.enterNestedBlock() else {
                    return .failure(parser.newBasicError(.endOfInput))
                }
                let startPos = nested.position()
                while case .success = nested.next() {}
                let selectorStr = String(nested.sliceFrom(startPos))
                parser.finishNestedBlock(blockType)

                var result: SupportsCondition = .selector(selectorStr)
                if isNot {
                    result = .not(result)
                    isNot = false
                }
                conditions.append(result)
            }
            // Handle parenthesized expression
            else if case .parenthesisBlock = token {
                guard let (nested, blockType) = parser.enterNestedBlock() else {
                    return .failure(parser.newBasicError(.endOfInput))
                }

                // Try to parse as declaration first
                if let declResult = tryParseDeclaration(nested) {
                    parser.finishNestedBlock(blockType)
                    var result = declResult
                    if isNot {
                        result = .not(result)
                        isNot = false
                    }
                    conditions.append(result)
                }
                // Check if it starts with "not" or "(" - indicates nested condition
                else if case .success = nested.tryParse({ p in p.expectIdentMatching("not") }) {
                    // Push current state and descend
                    stack.append(SupportsParseFrame(
                        parser: parser, blockType: blockType, isNot: isNot,
                        connective: connective, conditions: conditions
                    ))
                    parser = nested
                    isNot = true
                    connective = .none
                    conditions = []
                    continue
                } else if case .success = nested.tryParse({ $0.expectParenthesisBlock() }) {
                    nested.reset(nested.state()) // Reset to re-parse the paren
                    // Push current state and descend
                    stack.append(SupportsParseFrame(
                        parser: parser, blockType: blockType, isNot: isNot,
                        connective: connective, conditions: conditions
                    ))
                    parser = nested
                    isNot = false
                    connective = .none
                    conditions = []
                    continue
                } else {
                    // Unknown content
                    let startPos = nested.position()
                    while case .success = nested.next() {}
                    parser.finishNestedBlock(blockType)
                    var result: SupportsCondition = .unknown(String(nested.sliceFrom(startPos)))
                    if isNot {
                        result = .not(result)
                        isNot = false
                    }
                    conditions.append(result)
                }
            } else {
                return .failure(parser.newBasicError(.unexpectedToken(token)))
            }

            // After parsing one condition, check for "and" or "or"
            while true {
                if case let .success(ident) = parser.tryParse({ p in p.expectIdent() }) {
                    let value = ident.value.lowercased()
                    if value == "and" {
                        if case .none = connective { connective = .and } else if case .or = connective { break }
                    } else if value == "or" {
                        if case .none = connective { connective = .or } else if case .and = connective { break }
                    } else {
                        break
                    }

                    // Need to parse next condition
                    isNot = false
                    break
                } else {
                    // No more connectives - finalize current level
                    var result: SupportsCondition = if conditions.count == 1 {
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
                        conditions.append(result)
                        continue
                    }

                    return .success(result)
                }
            }
        }
    }

    private static func tryParseDeclaration(_ input: Parser) -> SupportsCondition? {
        let state = input.state()

        guard case let .success(ident) = input.tryParse({ $0.expectIdent() }),
              case .success = input.tryParse({ $0.expectColon() })
        else {
            input.reset(state)
            return nil
        }

        let property = String(ident.value)
        input.skipWhitespace()

        var tokens: [String] = []
        while case let .success(token) = input.next() {
            var writer = StringCSSWriter()
            token.serialize(dest: &writer)
            tokens.append(writer.result)
        }
        let value = tokens.joined().trimmingCharacters(in: .whitespaces)

        return .declaration(property: property, value: value)
    }

    private static func parseDeclaration(_ input: Parser) -> Result<SupportsCondition, BasicParseError> {
        // Parse property name
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        let property = String(ident.value)

        // Expect colon
        guard case .success = input.expectColon() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        input.skipWhitespace()

        // Collect the rest as the value
        var tokens: [String] = []
        while case let .success(token) = input.next() {
            var writer = StringCSSWriter()
            token.serialize(dest: &writer)
            tokens.append(writer.result)
        }
        let value = tokens.joined().trimmingCharacters(in: .whitespaces)

        return .success(.declaration(property: property, value: value))
    }
}

// MARK: - Serialization

private enum SupportsSerializeWork {
    case condition(SupportsCondition, parent: SupportsCondition?)
    case text(String)
}

extension SupportsCondition: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        var stack: [SupportsSerializeWork] = [.condition(self, parent: nil)]

        while let work = stack.popLast() {
            switch work {
            case let .text(s):
                dest.write(s)

            case let .condition(cond, parent):
                let needsParens = cond.needsParens(parent: parent)
                if needsParens {
                    stack.append(.text(")"))
                }

                switch cond {
                case let .not(inner):
                    stack.append(.condition(inner, parent: cond))
                    if needsParens {
                        dest.write("(not ")
                    } else {
                        dest.write("not ")
                    }

                case let .and(conditions):
                    for (index, c) in conditions.enumerated().reversed() {
                        if index > 0 {
                            stack.append(.text(" and "))
                        }
                        stack.append(.condition(c, parent: cond))
                    }
                    if needsParens { dest.write("(") }

                case let .or(conditions):
                    for (index, c) in conditions.enumerated().reversed() {
                        if index > 0 {
                            stack.append(.text(" or "))
                        }
                        stack.append(.condition(c, parent: cond))
                    }
                    if needsParens { dest.write("(") }

                case let .declaration(property, value):
                    if needsParens {
                        dest.write("((")
                        dest.write(property)
                        dest.write(": ")
                        dest.write(value)
                        dest.write(")")
                    } else {
                        dest.write("(")
                        dest.write(property)
                        dest.write(": ")
                        dest.write(value)
                        dest.write(")")
                        stack.removeLast() // Remove the trailing ")" we added
                    }

                case let .selector(sel):
                    if needsParens {
                        dest.write("(selector(")
                        dest.write(sel)
                        dest.write(")")
                    } else {
                        dest.write("selector(")
                        dest.write(sel)
                        dest.write(")")
                        stack.removeLast()
                    }

                case let .unknown(raw):
                    if needsParens {
                        dest.write("(")
                    } else {
                        stack.removeLast()
                    }
                    dest.write(raw)
                }
            }
        }
    }

    private func needsParens(parent: SupportsCondition?) -> Bool {
        guard let parent else { return false }
        switch self {
        case .not:
            return true
        case .and:
            if case .and = parent { return false }
            return true
        case .or:
            if case .or = parent { return false }
            return true
        default:
            return false
        }
    }
}
