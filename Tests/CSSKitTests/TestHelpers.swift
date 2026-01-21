// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Foundation
import Testing

// MARK: - JSON Value Type

/// Represents a JSON value for test parsing.
indirect enum JSONValue: Equatable, CustomStringConvertible {
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case array([Self])

    var description: String {
        switch self {
        case .null: "null"
        case let .bool(b): b ? "true" : "false"
        case let .int(i): "\(i)"
        case let .double(d): "\(d)"
        case let .string(s): "\"\(s)\""
        case let .array(arr): "[\(arr.map(\.description).joined(separator: ", "))]"
        }
    }
}

extension JSONValue {
    init(_ any: Any?) {
        if any == nil || any is NSNull {
            self = .null
        } else if let n = any as? NSNumber {
            #if canImport(Darwin)
                if CFGetTypeID(n) == CFBooleanGetTypeID() {
                    self = .bool(n.boolValue)
                } else if n.doubleValue.truncatingRemainder(dividingBy: 1) == 0,
                          n.doubleValue >= Double(Int.min), n.doubleValue <= Double(Int.max)
                {
                    self = .int(n.intValue)
                } else {
                    self = .double(n.doubleValue)
                }
            #else
                // On Linux, check objCType to distinguish booleans
                if n.objCType.pointee == 0x42 /* 'B' */ || n.objCType.pointee == 0x63 /* 'c' */ {
                    self = .bool(n.boolValue)
                } else if n.doubleValue.truncatingRemainder(dividingBy: 1) == 0,
                          n.doubleValue >= Double(Int.min), n.doubleValue <= Double(Int.max)
                {
                    self = .int(n.intValue)
                } else {
                    self = .double(n.doubleValue)
                }
            #endif
        } else if let s = any as? String {
            self = .string(s)
        } else if let arr = any as? [Any] {
            self = .array(arr.map { JSONValue($0) })
        } else {
            self = .null
        }
    }
}

// MARK: - Test Resource Loading

func loadTestData(_ filename: String) throws -> [JSONValue] {
    let bundle = Bundle.module
    guard let url = bundle.url(forResource: filename, withExtension: "json", subdirectory: "css-parsing-tests") else {
        throw TestError.fileNotFound(filename)
    }
    let data = try Data(contentsOf: url)
    let json = try JSONSerialization.jsonObject(with: data)
    guard let array = json as? [Any] else {
        throw TestError.invalidFormat
    }
    return array.map { JSONValue($0) }
}

enum TestError: Error {
    case fileNotFound(String)
    case invalidFormat
}

// MARK: - JSON Comparison

func almostEquals(_ a: JSONValue, _ b: JSONValue) -> Bool {
    switch (a, b) {
    case (.null, .null):
        true
    case let (.bool(a), .bool(b)):
        a == b
    case let (.string(a), .string(b)):
        a == b
    case let (.int(a), .int(b)):
        a == b
    case let (.double(a), .double(b)):
        abs(a - b) <= abs(a) * 1e-6
    case let (.int(a), .double(b)):
        abs(Double(a) - b) <= abs(Double(a)) * 1e-6
    case let (.double(a), .int(b)):
        abs(a - Double(b)) <= abs(a) * 1e-6
    case let (.array(a), .array(b)):
        a.count == b.count && zip(a, b).allSatisfy { almostEquals($0, $1) }
    default:
        false
    }
}

func normalize(_ json: inout JSONValue) {
    switch json {
    case var .array(list):
        for i in list.indices {
            normalize(&list[i])
        }
        json = .array(list)
    case let .string(s):
        if s == "extra-input" || s == "empty" {
            json = .string("invalid")
        }
    default:
        break
    }
}

/// Check if a JSONValue is an EOF error token (eof-in-string or eof-in-url).
/// These tokens don't survive serializer round-trips since the serializer
/// properly closes strings/URLs.
func isEofError(_ json: JSONValue) -> Bool {
    if case let .array(arr) = json, arr.count == 2 {
        if case .string("error") = arr[0] {
            if case let .string(errorType) = arr[1] {
                return errorType == "eof-in-string" || errorType == "eof-in-url"
            }
        }
    }
    return false
}

/// Normalize for serializer round-trip tests by removing EOF error tokens
/// that can't survive the round-trip.
func normalizeForSerializer(_ json: inout JSONValue) {
    switch json {
    case var .array(list):
        // First normalize children
        for i in list.indices {
            normalizeForSerializer(&list[i])
        }
        // Then filter out EOF errors from the end
        // EOF errors only appear at the end of token streams
        while let last = list.last, isEofError(last) {
            list.removeLast()
        }
        json = .array(list)
    case let .string(s):
        if s == "extra-input" || s == "empty" {
            json = .string("invalid")
        }
    default:
        break
    }
}

func assertJsonEq(_ results: JSONValue, _ expected: JSONValue, _ message: String) {
    var expected = expected
    normalize(&expected)
    if !almostEquals(results, expected) {
        Issue.record("JSON mismatch for \(message):\n  Got: \(results)\n  Expected: \(expected)")
    }
}

// MARK: - JSON Test Runner

func runJsonTests(_ jsonData: [JSONValue], parse: (Parser) -> JSONValue) {
    var i = 0
    while i < jsonData.count - 1 {
        guard case let .string(input) = jsonData[i] else {
            i += 1
            continue
        }
        let expected = jsonData[i + 1]
        i += 2

        let parserInput = ParserInput(input)
        let parser = Parser(parserInput)
        let result = parse(parser)
        assertJsonEq(result, expected, input)
    }
}

// MARK: - Component Value to JSON Conversion

func componentValuesToJson(_ input: Parser) -> [JSONValue] {
    var values: [JSONValue] = []
    while case let .success(token) = input.nextIncludingWhitespace() {
        values.append(oneComponentValueToJson(token, input))
    }
    return values
}

func oneComponentValueToJson(_ token: Token, _ input: Parser) -> JSONValue {
    func numeric(_ n: NumericValue) -> [JSONValue] {
        let numValue: JSONValue = n.intValue.map { .int(Int($0)) } ?? .double(n.value)
        let typeStr: JSONValue = n.intValue != nil ? .string("integer") : .string("number")
        return [.string(n.repr.value), numValue, typeStr]
    }

    func nested(_ input: Parser) -> [JSONValue] {
        let result: Result<[JSONValue], ParseError<Never>> = input.parseNestedBlock { inner in
            .success(componentValuesToJson(inner))
        }
        return (try? result.get()) ?? []
    }

    switch token {
    case let .ident(value):
        return .array([.string("ident"), .string(value.value)])

    case let .atKeyword(value):
        return .array([.string("at-keyword"), .string(value.value)])

    case let .hash(value):
        return .array([.string("hash"), .string(value.value), .string("unrestricted")])

    case let .idHash(value):
        return .array([.string("hash"), .string(value.value), .string("id")])

    case let .quotedString(value):
        return .array([.string("string"), .string(value.value)])

    case let .unquotedUrl(value):
        return .array([.string("url"), .string(value.value)])

    case let .delim(char):
        if char == "\\" {
            return .string("\\")
        }
        return .string(String(char))

    case let .number(n):
        var v: [JSONValue] = [.string("number")]
        v.append(contentsOf: numeric(n))
        return .array(v)

    case let .percentage(n):
        // For percentage, the NumericValue stores the original repr
        // and the value is already divided by 100. For JSON output, we need the
        // original value (intValue or value * 100).
        let numValue: JSONValue = n.intValue.map { .int(Int($0)) } ?? .double(n.value * 100)
        let typeStr: JSONValue = n.intValue != nil ? .string("integer") : .string("number")
        let v: [JSONValue] = [.string("percentage"), .string(n.repr.value), numValue, typeStr]
        return .array(v)

    case let .dimension(n, unit):
        var v: [JSONValue] = [.string("dimension")]
        v.append(contentsOf: numeric(n))
        v.append(.string(unit.value))
        return .array(v)

    case .whiteSpace:
        return .string(" ")

    case .comment:
        return .string("/**/")

    case .colon:
        return .string(":")

    case .semicolon:
        return .string(";")

    case .comma:
        return .string(",")

    case .includeMatch:
        return .string("~=")

    case .dashMatch:
        return .string("|=")

    case .prefixMatch:
        return .string("^=")

    case .suffixMatch:
        return .string("$=")

    case .substringMatch:
        return .string("*=")

    case .cdo:
        return .string("<!--")

    case .cdc:
        return .string("-->")

    case .column:
        return .string("||")

    case let .function(name):
        var v: [JSONValue] = [.string("function"), .string(name.value)]
        v.append(contentsOf: nested(input))
        return .array(v)

    case .parenthesisBlock:
        var v: [JSONValue] = [.string("()")]
        v.append(contentsOf: nested(input))
        return .array(v)

    case .squareBracketBlock:
        var v: [JSONValue] = [.string("[]")]
        v.append(contentsOf: nested(input))
        return .array(v)

    case .curlyBracketBlock:
        var v: [JSONValue] = [.string("{}")]
        v.append(contentsOf: nested(input))
        return .array(v)

    case .badUrl:
        return .array([.string("error"), .string("bad-url")])

    case .badString:
        return .array([.string("error"), .string("bad-string")])

    case .closeParenthesis:
        return .array([.string("error"), .string(")")])

    case .closeSquareBracket:
        return .array([.string("error"), .string("]")])

    case .closeCurlyBracket:
        return .array([.string("error"), .string("}")])

    case let .unicodeRange(start, end):
        return .array([.string("unicode-range"), .int(Int(start)), .int(Int(end))])

    case .eofInString:
        return .array([.string("error"), .string("eof-in-string")])

    case .eofInUrl:
        return .array([.string("error"), .string("eof-in-url")])
    }
}

// MARK: - JSON Parser Protocol Implementation

/// Distinguishes at-rules from qualified rules.
enum JsonPrelude {
    case atRule(name: String, prelude: [JSONValue])
    case qualifiedRule(prelude: [JSONValue])
}

/// Parser for JSON test output.
final class JsonParser: DeclarationParser, AtRuleParsingDelegate, QualifiedRuleParser, RuleBodyItemParser {
    typealias Declaration = JSONValue
    typealias Prelude = JsonPrelude
    typealias AtRule = JSONValue
    typealias QRPrelude = JsonPrelude
    typealias QualifiedRule = JSONValue
    typealias DeclError = Never
    typealias AtRuleError = Never
    typealias QRError = Never

    // DeclarationParser
    func parseValue(name: Lexeme, input: Parser, declarationStart _: ParserState) -> Result<JSONValue, ParseError<Never>> {
        var value: [JSONValue] = []
        var important = false

        loop: while true {
            let start = input.state()
            switch input.nextIncludingWhitespace() {
            case let .success(token):
                // Hack to deal with css-parsing-tests assuming that
                // `!important` in the middle of a declaration value is OK.
                // Check if this looks like the start of !important at the end.
                if case .delim("!") = token {
                    input.reset(start)
                    if case .success = parseImportant(input), input.isExhausted {
                        important = true
                        break loop
                    }
                    // Not !important at end, consume the ! as a regular token
                    input.reset(start)
                    if case let .success(t) = input.nextIncludingWhitespace() {
                        value.append(oneComponentValueToJson(t, input))
                    }
                } else {
                    value.append(oneComponentValueToJson(token, input))
                }
            case .failure:
                break loop
            }
        }

        return .success(.array([
            .string("declaration"),
            .string(name.value),
            .array(value),
            .bool(important),
        ]))
    }

    // AtRuleParser
    func parsePrelude(name: Lexeme, input: Parser) -> Result<JsonPrelude, ParseError<Never>> {
        // @charset is invalid
        if name.value.lowercased() == "charset" {
            return .failure(input.newBasicError(.atRuleInvalid(Lexeme(name.value))).asParseError())
        }

        let preludeValues = componentValuesToJson(input)
        return .success(.atRule(name: name.value, prelude: preludeValues))
    }

    func ruleWithoutBlock(prelude: JsonPrelude, start _: ParserState) -> JSONValue? {
        switch prelude {
        case let .atRule(name, preludeValues):
            .array([
                .string("at-rule"),
                .string(name),
                .array(preludeValues),
                .null,
            ])
        case .qualifiedRule:
            // Qualified rules require a block
            nil
        }
    }

    // Shared parseBlock for both AtRuleParser and QualifiedRuleParser
    func parseBlock(prelude: JsonPrelude, start _: ParserState, input: Parser) -> Result<JSONValue, ParseError<Never>> {
        let blockValues = componentValuesToJson(input)

        switch prelude {
        case let .atRule(name, preludeValues):
            return .success(.array([
                .string("at-rule"),
                .string(name),
                .array(preludeValues),
                .array(blockValues),
            ]))
        case let .qualifiedRule(preludeValues):
            return .success(.array([
                .string("qualified rule"),
                .array(preludeValues),
                .array(blockValues),
            ]))
        }
    }

    // QualifiedRuleParser
    func parsePrelude(input: Parser) -> Result<JsonPrelude, ParseError<Never>> {
        let preludeValues = componentValuesToJson(input)
        return .success(.qualifiedRule(prelude: preludeValues))
    }

    // RuleBodyItemParser
    var parseQualified: Bool { true }
    var parseDeclarations: Bool { true }
}

// MARK: - Helper Extensions

extension Result {
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    var isFailure: Bool {
        if case .failure = self { return true }
        return false
    }
}

func tokenEquals(_ a: Result<Token, BasicParseError>, _ b: Result<Token, BasicParseError>) -> Bool {
    switch (a, b) {
    case let (.success(ta), .success(tb)):
        ta == tb
    case (.failure, .failure):
        true
    default:
        false
    }
}
