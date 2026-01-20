// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A captured parser state for use with `Parser.reset(_:)`.
struct ParserState: Equatable, Sendable {
    let position: Int
    let currentLineStartPosition: Int
    let currentLineNumber: UInt32
    let atStartOf: BlockType?
    let sourceFile: String?

    func sourcePosition() -> SourcePosition {
        SourcePosition(position)
    }

    func sourceLocation() -> SourceLocation {
        SourceLocation(
            line: currentLineNumber,
            column: UInt32(position - currentLineStartPosition + 1),
            sourceFile: sourceFile
        )
    }
}

/// Error handling behavior for `parseUntil*` methods.
enum ParseUntilErrorBehavior: Equatable, Sendable {
    /// Consume until we see the relevant delimiter or the end of the stream.
    case consume
    /// Eagerly error.
    case stop
}

/// A CSS parser that uses a `ParserInput` as its source,
/// yields `Token`s, and keeps track of nested blocks and functions.
final class Parser: @unchecked Sendable {
    let input: ParserInput

    var atStartOf: BlockType?
    var stopBefore: Delimiters

    // MARK: - Initialization

    convenience init(css: String, sourceFile: String? = nil) {
        self.init(ParserInput(css, sourceFile: sourceFile))
    }

    init(_ input: ParserInput) {
        self.input = input
        atStartOf = nil
        stopBefore = .none
    }

    init(input: ParserInput, atStartOf: BlockType?, stopBefore: Delimiters) {
        self.input = input
        self.atStartOf = atStartOf
        self.stopBefore = stopBefore
    }

    // MARK: - Position and State

    var currentLine: Substring {
        input.tokenizer.currentSourceLine()
    }

    /// Whether the input is exhausted (ignoring whitespace and comments).
    var isExhausted: Bool {
        expectExhausted().isOK
    }

    func expectExhausted() -> Result<Void, BasicParseError> {
        let start = state()
        let result: Result<Void, BasicParseError> = switch next() {
        case let .failure(error):
            if case .endOfInput = error.kind {
                .success(())
            } else {
                .failure(error)
            }
        case let .success(token):
            .failure(start.sourceLocation().newBasicUnexpectedTokenError(token))
        }
        reset(start)
        return result
    }

    func position() -> SourcePosition {
        input.tokenizer.currentPosition()
    }

    func currentSourceLocation() -> SourceLocation {
        input.tokenizer.currentSourceLocation()
    }

    /// The source map URL extracted from a `/*# sourceMappingURL=... */` comment.
    var currentSourceMapUrl: Substring? {
        input.tokenizer.sourceMapUrl
    }

    /// The source URL extracted from a `/*# sourceURL=... */` comment.
    var currentSourceUrl: Substring? {
        input.tokenizer.sourceUrl
    }

    /// For later restoration via `reset(_:)`.
    func state() -> ParserState {
        let tokState = input.tokenizer.state()
        return ParserState(
            position: tokState.position,
            currentLineStartPosition: tokState.currentLineStartPosition,
            currentLineNumber: tokState.currentLineNumber,
            atStartOf: atStartOf,
            sourceFile: input.tokenizer.sourceFile
        )
    }

    func reset(_ state: ParserState) {
        input.tokenizer.reset(to: TokenizerState(
            position: state.position,
            currentLineStartPosition: state.currentLineStartPosition,
            currentLineNumber: state.currentLineNumber
        ))
        atStartOf = state.atStartOf
    }

    // MARK: - Error Creation

    func newBasicError(_ kind: BasicParseErrorKind) -> BasicParseError {
        currentSourceLocation().newBasicError(kind)
    }

    func newError<E: Equatable>(_ kind: BasicParseErrorKind) -> ParseError<E> {
        currentSourceLocation().newError(kind)
    }

    func newCustomError<E: Equatable>(_ error: E) -> ParseError<E> {
        currentSourceLocation().newCustomError(error)
    }

    func newBasicUnexpectedTokenError(_ token: Token) -> BasicParseError {
        newBasicError(.unexpectedToken(token))
    }

    func newUnexpectedTokenError<E: Equatable>(_ token: Token) -> ParseError<E> {
        newError(.unexpectedToken(token))
    }

    func newErrorForNextToken<E: Equatable>() -> ParseError<E> {
        switch next() {
        case let .success(token):
            newError(.unexpectedToken(token))
        case let .failure(error):
            error.asParseError()
        }
    }

    // MARK: - Whitespace

    private func cleanupPendingBlock() {
        if let blockType = atStartOf {
            atStartOf = nil
            consumeUntilEndOfBlock(blockType)
        }
    }

    func skipWhitespace() {
        cleanupPendingBlock()
        input.tokenizer.skipWhitespace()
    }

    /// Skip whitespace, CDO (<!--), and CDC (-->).
    func skipCdcAndCdo() {
        cleanupPendingBlock()
        input.tokenizer.skipCDCAndCDO()
    }

    func nextByte() -> UInt8? {
        let byte = input.tokenizer.nextByte()
        if stopBefore.containsAny(Delimiters.fromByte(byte)) {
            return nil
        }
        return byte
    }

    // MARK: - Substitution Function Detection

    /// Start looking for `var()`, `env()`, etc. See `seenArbitrarySubstitutionFunctions()`.
    func lookForArbitrarySubstitutionFunctions(_ functions: [String]) {
        input.tokenizer.lookForArbitrarySubstitutionFunctions(functions)
    }

    /// Returns whether a function was seen since `lookForArbitrarySubstitutionFunctions`, and stops looking.
    func seenArbitrarySubstitutionFunctions() -> Bool {
        input.tokenizer.seenArbitrarySubstitutionFunctions()
    }

    // MARK: - Try Parse

    /// On failure, restores parser state to before the call.
    @discardableResult
    func tryParse<T, E>(
        _ closure: (Parser) throws -> Result<T, E>
    ) rethrows -> Result<T, E> {
        let start = state()
        let result = try closure(self)
        if case .failure = result {
            reset(start)
        }
        return result
    }

    /// On throw, restores parser state to before the call.
    @discardableResult
    func tryParseThrows<T>(_ closure: (Parser) throws -> T) throws -> T {
        let start = state()
        do {
            return try closure(self)
        } catch {
            reset(start)
            throw error
        }
    }

    // MARK: - Slicing

    func sliceFrom(_ start: SourcePosition) -> Substring {
        input.tokenizer.sliceFrom(start)
    }

    func slice(_ range: Range<SourcePosition>) -> Substring {
        input.tokenizer.slice(range)
    }

    // MARK: - Token Retrieval

    /// Skips whitespace/comments. After block-opening tokens, use `parseNestedBlock` for contents.
    func next() -> Result<Token, BasicParseError> {
        skipWhitespace()
        return nextIncludingWhitespaceAndComments()
    }

    /// Like `next()` but preserves whitespace.
    func nextIncludingWhitespace() -> Result<Token, BasicParseError> {
        while true {
            switch nextIncludingWhitespaceAndComments() {
            case let .failure(error):
                return .failure(error)
            case let .success(token):
                if case .comment = token {
                    continue
                }
                return .success(token)
            }
        }
    }

    /// Like `next()` but preserves whitespace and comments. For CSS pre-processors.
    func nextIncludingWhitespaceAndComments() -> Result<Token, BasicParseError> {
        cleanupPendingBlock()

        // Check for pending error tokens first
        // These must be returned before any other checks since they don't advance position
        if let errorToken = input.tokenizer.pendingErrorToken {
            // Consume the pending token by calling next() which will clear it
            _ = input.tokenizer.next()
            return .success(errorToken)
        }

        let byte = input.tokenizer.nextByte()
        if stopBefore.containsAny(Delimiters.fromByte(byte)) {
            return .failure(newBasicError(.endOfInput))
        }

        let tokenStartPosition = input.tokenizer.currentPosition()
        let usingCachedToken = if let cachedToken = input.cachedToken,
                                  cachedToken.startPosition == tokenStartPosition
        {
            true
        } else {
            false
        }

        let token: Token
        if usingCachedToken, let cached = input.cachedToken {
            input.tokenizer.reset(to: cached.endState)
            if case let .function(name) = cached.token {
                input.tokenizer.seeFunction(name)
            }
            token = cached.token
        } else {
            guard let newToken = input.tokenizer.next() else {
                return .failure(newBasicError(.endOfInput))
            }
            input.cachedToken = CachedToken(
                token: newToken,
                startPosition: tokenStartPosition,
                endState: input.tokenizer.state()
            )
            token = newToken
        }

        if let blockType = BlockType.opening(token) {
            atStartOf = blockType
        }

        return .success(token)
    }

    // MARK: - Parse Entirely

    /// Fails if any input remains after parsing.
    func parseEntirely<T, E: Equatable>(
        _ parse: (Parser) -> Result<T, ParseError<E>>
    ) -> Result<T, ParseError<E>> {
        switch parse(self) {
        case let .failure(error):
            .failure(error)
        case let .success(value):
            switch expectExhausted() {
            case let .failure(error):
                .failure(error.asParseError())
            case .success:
                .success(value)
            }
        }
    }

    // MARK: - Comma-Separated Parsing

    func parseCommaSeparated<T, E: Equatable>(
        _ parseOne: (Parser) -> Result<T, ParseError<E>>
    ) -> Result<[T], ParseError<E>> {
        parseCommaSeparatedInternal(parseOne, ignoreErrors: false)
    }

    /// Like `parseCommaSeparated` but skips invalid items instead of failing.
    func parseCommaSeparatedIgnoringErrors<T>(
        _ parseOne: (Parser) -> Result<T, ParseError<some Equatable>>
    ) -> [T] {
        switch parseCommaSeparatedInternal(parseOne, ignoreErrors: true) {
        case let .success(values):
            values
        case .failure:
            fatalError("Unreachable: ignoreErrors should prevent failure")
        }
    }

    func parseCommaSeparatedInternal<T, E: Equatable>(
        _ parseOne: (Parser) -> Result<T, ParseError<E>>,
        ignoreErrors: Bool
    ) -> Result<[T], ParseError<E>> {
        var values: [T] = []
        values.reserveCapacity(1)

        while true {
            skipWhitespace()
            switch parseUntilBefore(.comma, parseOne) {
            case let .success(value):
                values.append(value)
            case let .failure(error) where !ignoreErrors:
                return .failure(error)
            case .failure:
                break
            }

            switch next() {
            case .failure:
                return .success(values)
            case .success(.comma):
                continue
            case .success:
                fatalError("Unreachable: parseUntilBefore should stop at comma")
            }
        }
    }

    // MARK: - Nested Block Parsing

    /// Call after a block-opening token (`function`, `parenthesisBlock`, etc.) to parse its contents.
    func parseNestedBlock<T, E: Equatable>(
        _ parse: (Parser) -> Result<T, ParseError<E>>
    ) -> Result<T, ParseError<E>> {
        guard let blockType = atStartOf else {
            fatalError("""
            A nested parser can only be created when a Function, \
            ParenthesisBlock, SquareBracketBlock, or CurlyBracketBlock \
            token was just consumed.
            """)
        }
        atStartOf = nil

        let closingDelimiter: Delimiters = switch blockType {
        case .curlyBracket:
            .closeCurlyBracket
        case .squareBracket:
            .closeSquareBracket
        case .parenthesis:
            .closeParenthesis
        }

        let result: Result<T, ParseError<E>>
        do {
            let nestedParser = Parser(
                input: input,
                atStartOf: nil,
                stopBefore: closingDelimiter
            )
            result = nestedParser.parseEntirely(parse)
            if let innerBlockType = nestedParser.atStartOf {
                nestedParser.consumeUntilEndOfBlock(innerBlockType)
            }
        }

        consumeUntilEndOfBlock(blockType)
        return result
    }

    // MARK: - Parse Until Methods

    /// Parse with a delimited parser that stops before the given delimiter(s).
    func parseUntilBefore<T, E: Equatable>(
        _ delimiters: Delimiters,
        _ parse: (Parser) -> Result<T, ParseError<E>>
    ) -> Result<T, ParseError<E>> {
        parseUntilBeforeInternal(delimiters, errorBehavior: .consume, parse)
    }

    /// Like `parseUntilBefore` but also consumes the delimiter.
    func parseUntilAfter<T, E: Equatable>(
        _ delimiters: Delimiters,
        _ parse: (Parser) -> Result<T, ParseError<E>>
    ) -> Result<T, ParseError<E>> {
        parseUntilAfterInternal(delimiters, errorBehavior: .consume, parse)
    }

    func parseUntilBeforeInternal<T, E: Equatable>(
        _ delimiters: Delimiters,
        errorBehavior: ParseUntilErrorBehavior,
        _ parse: (Parser) -> Result<T, ParseError<E>>
    ) -> Result<T, ParseError<E>> {
        let combinedDelimiters = stopBefore.union(delimiters)
        let result: Result<T, ParseError<E>>

        do {
            let delimitedParser = Parser(
                input: input,
                atStartOf: atStartOf,
                stopBefore: combinedDelimiters
            )
            atStartOf = nil
            result = delimitedParser.parseEntirely(parse)

            if errorBehavior == .stop, case .failure = result {
                return result
            }

            if let blockType = delimitedParser.atStartOf {
                delimitedParser.consumeUntilEndOfBlock(blockType)
            }
        }

        // Consume remaining tokens until delimiter
        while true {
            if combinedDelimiters.containsAny(Delimiters.fromByte(input.tokenizer.nextByte())) {
                break
            }
            if let token = input.tokenizer.next() {
                if let blockType = BlockType.opening(token) {
                    consumeUntilEndOfBlock(blockType)
                }
            } else {
                break
            }
        }

        return result
    }

    func parseUntilAfterInternal<T, E: Equatable>(
        _ delimiters: Delimiters,
        errorBehavior: ParseUntilErrorBehavior,
        _ parse: (Parser) -> Result<T, ParseError<E>>
    ) -> Result<T, ParseError<E>> {
        let result = parseUntilBeforeInternal(delimiters, errorBehavior: errorBehavior, parse)

        if errorBehavior == .stop, case .failure = result {
            return result
        }

        let nextByte = input.tokenizer.nextByte()
        if let byte = nextByte,
           !stopBefore.containsAny(Delimiters.fromByte(byte))
        {
            // We know this byte is ASCII
            input.tokenizer.advance(1)
            if byte == UInt8(ascii: "{") {
                consumeUntilEndOfBlock(.curlyBracket)
            }
        }

        return result
    }

    // MARK: - Block Consumption

    func enterNestedBlock() -> (parser: Parser, blockType: BlockType)? {
        guard let blockType = atStartOf else {
            return nil
        }
        atStartOf = nil

        let closingDelimiter: Delimiters = switch blockType {
        case .curlyBracket:
            .closeCurlyBracket
        case .squareBracket:
            .closeSquareBracket
        case .parenthesis:
            .closeParenthesis
        }

        let nestedParser = Parser(
            input: input,
            atStartOf: nil,
            stopBefore: closingDelimiter
        )

        return (nestedParser, blockType)
    }

    /// Cleans up after processing a nested block opened with `enterNestedBlock()`.
    func finishNestedBlock(_ blockType: BlockType) {
        consumeUntilEndOfBlock(blockType)
    }

    func consumeUntilEndOfBlock(_ blockType: BlockType) {
        var stack: [BlockType] = [blockType]

        while let token = input.tokenizer.next() {
            if let closingType = BlockType.closing(token),
               closingType == stack.last
            {
                stack.removeLast()
                if stack.isEmpty {
                    return
                }
            }

            if let openingType = BlockType.opening(token) {
                stack.append(openingType)
            }
        }
    }
}
