// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - CSSParseResult

/// The result of parsing CSS with error recovery.
public struct CSSParseResult<R: CSSSerializable & Sendable & Equatable>: Sendable {
    public let rules: [Rule<R>]
    public let errors: [CSSParseError]
    public let sourceMapUrl: String?
    public let sourceUrl: String?

    public var stylesheet: Stylesheet<R> {
        Stylesheet(rules: rules, sourceMapUrl: sourceMapUrl, sourceUrl: sourceUrl)
    }
}

/// A CSS parse error with location information.
public struct CSSParseError: Error, Sendable, CustomStringConvertible {
    public let message: String
    public let location: SourceLocation
    public let invalidText: String

    public var description: String {
        if let file = location.sourceFile {
            return "\(file):\(location.line):\(location.column): \(message)"
        }
        return "line \(location.line), column \(location.column): \(message)"
    }
}

// MARK: - CSSParser

/// A CSS parser conforming to CSS Syntax Level 3.
public struct CSSParser<P: AtRuleParser>: Sendable where P: Sendable {
    public let source: String
    public let sourceFile: String?
    public let atRuleParser: P

    private let cache: ParseCache<P.AtRule>

    public init(_ source: String, sourceFile: String? = nil, atRuleParser: P) {
        self.source = source
        self.sourceFile = sourceFile
        self.atRuleParser = atRuleParser
        cache = ParseCache()
    }

    // MARK: - Computed Properties

    /// The parsed stylesheet.
    public var stylesheet: Stylesheet<P.AtRule> {
        result.stylesheet
    }

    /// Parse errors encountered. Empty if parsing succeeded without errors.
    public var errors: [CSSParseError] {
        result.errors
    }

    /// The parsed rules.
    public var rules: [Rule<P.AtRule>] {
        result.rules
    }

    /// The parsed value (for single-value input). Throws if parsing fails.
    public var value: CSSValue {
        get throws {
            let input = ParserInput(source, sourceFile: sourceFile)
            let parser = Parser(input)
            switch parseCSSValue(input: parser) {
            case let .success(value):
                return value
            case let .failure(error):
                throw error
            }
        }
    }

    /// The parsed declarations (for declaration list input like style attributes).
    public var declarations: [CSSDeclaration] {
        get throws {
            try parseDeclarations()
        }
    }

    /// The full parse result with stylesheet, errors, and source map info.
    public var result: CSSParseResult<P.AtRule> {
        if let cached = cache.result {
            return cached
        }
        let parsed = performStylesheetParse()
        cache.result = parsed
        return parsed
    }

    // MARK: - Tokenization

    public func tokenize() -> CSSTokenSequence {
        CSSTokenSequence(source: source)
    }

    // MARK: - Private

    private func parseDeclarations() throws -> [CSSDeclaration] {
        let input = ParserInput(source, sourceFile: sourceFile)
        let parser = Parser(input)

        var declarations: [CSSDeclaration] = []

        while !parser.isExhausted {
            parser.skipWhitespace()

            guard case let .success(ident) = parser.tryParse({ $0.expectIdent() }) else {
                while case let .success(token) = parser.next() {
                    if case .semicolon = token { break }
                }
                continue
            }

            guard case .success = parser.expectColon() else {
                continue
            }

            let name = String(ident.value)
            let valueLocation = parser.currentSourceLocation()

            var valueTokens: [String] = []
            var important = false

            loop: while true {
                let beforeToken = parser.state()
                switch parser.nextIncludingWhitespace() {
                case let .success(token):
                    if case .semicolon = token { break loop }
                    if case .delim("!") = token {
                        parser.reset(beforeToken)
                        if case .success = parseImportant(parser), parser.isExhausted || parser.tryParse({ $0.expectSemicolon() }).isOK {
                            important = true
                            break loop
                        }
                        parser.reset(beforeToken)
                        if case let .success(token) = parser.nextIncludingWhitespace() {
                            valueTokens.append(token.cssString)
                        }
                        continue
                    }
                    valueTokens.append(token.cssString)
                case .failure:
                    break loop
                }
            }

            let rawValue = valueTokens.joined().trimmingCharacters(in: .whitespaces)
            let (vendorPrefix, unprefixedName) = CSSVendorPrefix.extract(from: name)
            let valueParser = Parser(css: rawValue)

            if case let .success(parsedValue) = parseCSSProperty(name: unprefixedName, input: valueParser, vendorPrefix: vendorPrefix) {
                declarations.append(CSSDeclaration(
                    name: name,
                    value: parsedValue,
                    isImportant: important,
                    location: valueLocation
                ))
            }
        }

        return declarations
    }

    private func performStylesheetParse() -> CSSParseResult<P.AtRule> {
        let input = ParserInput(source, sourceFile: sourceFile)
        let parser = Parser(input)

        let builder = StylesheetBuilder(ruleParser: atRuleParser)
        let stylesheetParser = StyleSheetParser(input: parser, parser: builder)

        var rules: [CSSRule<P.AtRule>] = []
        var errors: [CSSParseError] = []

        for parseResult in stylesheetParser {
            switch parseResult {
            case let .success(rule):
                rules.append(rule)
            case let .failure(error):
                let parseError = CSSParseError(
                    message: String(describing: error.error.basic.kind),
                    location: error.error.basic.location,
                    invalidText: String(error.slice)
                )
                errors.append(parseError)
            }
        }

        return CSSParseResult(
            rules: rules,
            errors: errors,
            sourceMapUrl: parser.currentSourceMapUrl.map { String($0) },
            sourceUrl: parser.currentSourceUrl.map { String($0) }
        )
    }
}

// MARK: - Parse Cache

private final class ParseCache<R: CSSSerializable & Sendable & Equatable>: @unchecked Sendable {
    var result: CSSParseResult<R>?
}

// MARK: - Convenience for Default Parser

public extension CSSParser where P == DefaultAtRuleParser {
    init(_ source: String, sourceFile: String? = nil) {
        self.source = source
        self.sourceFile = sourceFile
        atRuleParser = DefaultAtRuleParser()
        cache = ParseCache()
    }
}

// MARK: - Token Sequence

public struct CSSTokenSequence: Sequence {
    private let source: String

    init(source: String) {
        self.source = source
    }

    public func makeIterator() -> CSSTokenIterator {
        CSSTokenIterator(tokenizer: Tokenizer(source))
    }
}

// MARK: - Token Iterator

public final class CSSTokenIterator: IteratorProtocol {
    private let tokenizer: Tokenizer

    init(tokenizer: Tokenizer) {
        self.tokenizer = tokenizer
    }

    public func next() -> Token? {
        tokenizer.next()
    }
}
