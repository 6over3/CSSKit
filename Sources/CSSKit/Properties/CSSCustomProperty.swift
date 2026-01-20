// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Custom Property

/// A CSS custom property, representing any unknown property.
public struct CSSCustomProperty: Equatable, Sendable, Hashable {
    /// The name of the property.
    public let name: CSSCustomPropertyName

    /// The property value, stored as a raw token list.
    public let value: CSSTokenList

    /// Creates a custom property.
    public init(name: CSSCustomPropertyName, value: CSSTokenList) {
        self.name = name
        self.value = value
    }
}

// MARK: - Custom Property Name

/// A CSS custom property name.
public enum CSSCustomPropertyName: Equatable, Sendable, Hashable {
    /// An author-defined CSS custom property (starts with `--`).
    case custom(CSSDashedIdent)

    /// An unknown CSS property.
    case unknown(String)

    /// Creates a custom property name from a string.
    public init(_ name: String) {
        if name.hasPrefix("--") {
            self = .custom(CSSDashedIdent(name))
        } else {
            self = .unknown(name)
        }
    }

    /// The name as a string.
    public var name: String {
        switch self {
        case let .custom(ident):
            ident.value
        case let .unknown(name):
            name
        }
    }
}

// MARK: - Unparsed Property

/// A known property with an unparsed value.
///
/// This type is used when the value of a known property could not
/// be parsed, e.g. when `var()` references are encountered.
/// In this case, the raw tokens are stored instead.
public struct CSSUnparsedProperty: Equatable, Sendable, Hashable {
    /// The id of the property.
    public let propertyId: CSSPropertyId

    /// The property value, stored as a raw token list.
    public let value: CSSTokenList

    /// Creates an unparsed property.
    public init(propertyId: CSSPropertyId, value: CSSTokenList) {
        self.propertyId = propertyId
        self.value = value
    }
}

// MARK: - Token List

/// A raw list of CSS tokens, with embedded parsed values.
public struct CSSTokenList: Equatable, Sendable, Hashable {
    /// The tokens in this list.
    public let tokens: [CSSTokenOrValue]

    /// Creates a token list.
    public init(tokens: [CSSTokenOrValue]) {
        self.tokens = tokens
    }

    /// An empty token list.
    public static var empty: Self {
        Self(tokens: [])
    }

    /// Whether the token list is empty.
    public var isEmpty: Bool {
        tokens.isEmpty
    }

    /// Whether the token list starts with whitespace.
    public var startsWithWhitespace: Bool {
        guard let first = tokens.first else { return false }
        if case let .token(token) = first {
            if case .whiteSpace = token {
                return true
            }
        }
        return false
    }
}

// MARK: - Token Or Value

/// A raw CSS token, or a parsed value.
public enum CSSTokenOrValue: Equatable, Sendable, Hashable {
    /// A raw token.
    case token(Token)

    /// A parsed CSS color.
    case color(Color)

    /// A parsed CSS url.
    case url(CSSUrl)

    /// A CSS variable reference.
    case variable(CSSVariable)

    /// A CSS environment variable reference.
    case environment(CSSEnvironmentVariable)

    /// A custom CSS function.
    case function(CSSFunction)

    /// A length value.
    case length(CSSLength)

    /// An angle value.
    case angle(CSSAngle)

    /// A time value.
    case time(CSSTime)

    /// A resolution value.
    case resolution(CSSResolution)

    /// A dashed identifier.
    case dashedIdent(CSSDashedIdent)

    /// Whether this is whitespace.
    public var isWhitespace: Bool {
        if case let .token(token) = self {
            if case .whiteSpace = token {
                return true
            }
        }
        return false
    }
}

// MARK: - Variable

/// A CSS `var()` function reference.
public struct CSSVariable: Equatable, Sendable, Hashable {
    /// The variable name (including the `--` prefix).
    public let name: CSSDashedIdent

    /// The fallback value if the variable is not defined.
    public let fallback: CSSTokenList?

    /// Creates a variable reference.
    public init(name: CSSDashedIdent, fallback: CSSTokenList? = nil) {
        self.name = name
        self.fallback = fallback
    }
}

// MARK: - Environment Variable

/// A CSS `env()` function reference.
public struct CSSEnvironmentVariable: Equatable, Sendable, Hashable {
    /// The environment variable name.
    public let name: CSSEnvironmentVariableName

    /// Optional indices for accessing array values.
    public let indices: [CSSInteger]

    /// The fallback value if the variable is not defined.
    public let fallback: CSSTokenList?

    /// Creates an environment variable reference.
    public init(
        name: CSSEnvironmentVariableName,
        indices: [CSSInteger] = [],
        fallback: CSSTokenList? = nil
    ) {
        self.name = name
        self.indices = indices
        self.fallback = fallback
    }
}

/// Known environment variable names.
public enum CSSEnvironmentVariableName: Equatable, Sendable, Hashable {
    /// Safe area inset from the top.
    case safeAreaInsetTop

    /// Safe area inset from the right.
    case safeAreaInsetRight

    /// Safe area inset from the bottom.
    case safeAreaInsetBottom

    /// Safe area inset from the left.
    case safeAreaInsetLeft

    /// Viewport segment width.
    case viewportSegmentWidth

    /// Viewport segment height.
    case viewportSegmentHeight

    /// Viewport segment top.
    case viewportSegmentTop

    /// Viewport segment left.
    case viewportSegmentLeft

    /// Viewport segment bottom.
    case viewportSegmentBottom

    /// Viewport segment right.
    case viewportSegmentRight

    /// Title bar area x position.
    case titlebarAreaX

    /// Title bar area y position.
    case titlebarAreaY

    /// Title bar area width.
    case titlebarAreaWidth

    /// Title bar area height.
    case titlebarAreaHeight

    /// A custom/unknown environment variable.
    case custom(String)
}

// MARK: - Function

/// A custom CSS function with arguments.
public struct CSSFunction: Equatable, Sendable, Hashable {
    /// The function name.
    public let name: String

    /// The function arguments as a token list.
    public let arguments: CSSTokenList

    /// Creates a function.
    public init(name: String, arguments: CSSTokenList) {
        self.name = name
        self.arguments = arguments
    }
}

// MARK: - Parsing

extension CSSCustomProperty {
    /// Parses a custom property with the given name.
    static func parse(name: CSSCustomPropertyName, input: Parser) -> Result<CSSCustomProperty, BasicParseError> {
        switch CSSTokenList.parse(input) {
        case let .success(value):
            .success(CSSCustomProperty(name: name, value: value))
        case let .failure(error):
            .failure(error)
        }
    }
}

extension CSSUnparsedProperty {
    /// Parses a property with the given id as a token list.
    static func parse(propertyId: CSSPropertyId, input: Parser) -> Result<CSSUnparsedProperty, BasicParseError> {
        switch CSSTokenList.parse(input) {
        case let .success(value):
            .success(CSSUnparsedProperty(propertyId: propertyId, value: value))
        case let .failure(error):
            .failure(error)
        }
    }
}

extension CSSTokenList {
    static func parse(_ input: Parser) -> Result<CSSTokenList, BasicParseError> {
        TokenListParser.parse(input)
    }
}

// MARK: - Token List Parser

private enum TokenListParser {
    struct StackFrame {
        var tokens: [CSSTokenOrValue]
        var parser: Parser
        var blockType: BlockType
        var context: FrameContext
    }

    enum FrameContext {
        case variable(name: CSSDashedIdent?)
        case environment(name: CSSEnvironmentVariableName?, indices: [CSSInteger])
        case function(name: String)
        case block(openToken: Token)
    }

    static func parse(_ input: Parser) -> Result<CSSTokenList, BasicParseError> {
        var stack: [StackFrame] = []
        var tokens: [CSSTokenOrValue] = []
        var parser = input

        mainLoop: while true {
            while !parser.isExhausted {
                let stateBeforeToken = parser.state()
                guard case let .success(token) = parser.nextIncludingWhitespace() else {
                    break
                }

                switch token {
                case let .function(name):
                    let funcName = name.value.lowercased()

                    if funcName == "var" {
                        guard let (nestedParser, blockType) = parser.enterNestedBlock() else {
                            tokens.append(.token(token))
                            continue
                        }
                        stack.append(StackFrame(
                            tokens: tokens,
                            parser: parser,
                            blockType: blockType,
                            context: .variable(name: nil)
                        ))
                        tokens = []
                        parser = nestedParser
                        continue
                    } else if funcName == "env" {
                        guard let (nestedParser, blockType) = parser.enterNestedBlock() else {
                            tokens.append(.token(token))
                            continue
                        }
                        stack.append(StackFrame(
                            tokens: tokens,
                            parser: parser,
                            blockType: blockType,
                            context: .environment(name: nil, indices: [])
                        ))
                        tokens = []
                        parser = nestedParser
                        continue
                    } else if funcName == "url" {
                        parser.reset(stateBeforeToken)
                        if case let .success(url) = parser.tryParse({ CSSUrl.parse($0) }) {
                            tokens.append(.url(url))
                            continue
                        }
                        // Parsing failed - re-consume the function token and fall through to nested block handling
                        _ = parser.nextIncludingWhitespace()
                        guard let (nestedParser, blockType) = parser.enterNestedBlock() else {
                            tokens.append(.token(token))
                            continue
                        }
                        stack.append(StackFrame(
                            tokens: tokens,
                            parser: parser,
                            blockType: blockType,
                            context: .function(name: String(name.value))
                        ))
                        tokens = []
                        parser = nestedParser
                        continue
                    } else if isColorFunction(funcName) {
                        parser.reset(stateBeforeToken)
                        if case let .success(color) = parser.tryParse({ Color.parse($0) }) {
                            tokens.append(.color(color))
                            continue
                        }
                        // Parsing failed - re-consume the function token and fall through to nested block handling
                        _ = parser.nextIncludingWhitespace()
                        guard let (nestedParser, blockType) = parser.enterNestedBlock() else {
                            tokens.append(.token(token))
                            continue
                        }
                        stack.append(StackFrame(
                            tokens: tokens,
                            parser: parser,
                            blockType: blockType,
                            context: .function(name: String(name.value))
                        ))
                        tokens = []
                        parser = nestedParser
                        continue
                    } else {
                        guard let (nestedParser, blockType) = parser.enterNestedBlock() else {
                            tokens.append(.token(token))
                            continue
                        }
                        stack.append(StackFrame(
                            tokens: tokens,
                            parser: parser,
                            blockType: blockType,
                            context: .function(name: String(name.value))
                        ))
                        tokens = []
                        parser = nestedParser
                        continue
                    }

                case let .dimension(numeric, unit):
                    if let length = CSSLength(value: numeric.value, unit: String(unit.value)) {
                        tokens.append(.length(length))
                    } else if let angle = CSSAngle(value: numeric.value, unit: String(unit.value)) {
                        tokens.append(.angle(angle))
                    } else if let time = CSSTime(value: numeric.value, unit: String(unit.value)) {
                        tokens.append(.time(time))
                    } else if let resolution = CSSResolution(value: numeric.value, unit: String(unit.value)) {
                        tokens.append(.resolution(resolution))
                    } else {
                        tokens.append(.token(token))
                    }

                case let .hash(value), let .idHash(value):
                    if let color = Color.fromHex(String(value.value)) {
                        tokens.append(.color(color))
                    } else {
                        tokens.append(.token(token))
                    }

                case let .ident(value) where value.value.hasPrefix("--"):
                    tokens.append(.dashedIdent(CSSDashedIdent(String(value.value))))

                case .parenthesisBlock, .squareBracketBlock, .curlyBracketBlock:
                    tokens.append(.token(token))
                    guard let (nestedParser, blockType) = parser.enterNestedBlock() else {
                        continue
                    }
                    stack.append(StackFrame(
                        tokens: tokens,
                        parser: parser,
                        blockType: blockType,
                        context: .block(openToken: token)
                    ))
                    tokens = []
                    parser = nestedParser
                    continue

                default:
                    tokens.append(.token(token))
                }
            }

            if stack.isEmpty {
                break mainLoop
            }

            let frame = stack.removeLast()
            let completedTokens = tokens
            frame.parser.finishNestedBlock(frame.blockType)

            switch frame.context {
            case let .variable(existingName):
                let variable = buildVariable(from: completedTokens, existingName: existingName)
                tokens = frame.tokens
                tokens.append(.variable(variable))
                parser = frame.parser

            case let .environment(existingName, indices):
                let env = buildEnvironment(from: completedTokens, existingName: existingName, indices: indices)
                tokens = frame.tokens
                tokens.append(.environment(env))
                parser = frame.parser

            case let .function(name):
                let trimmed = trimWhitespace(completedTokens)
                let function = CSSFunction(name: name, arguments: CSSTokenList(tokens: trimmed))
                tokens = frame.tokens
                tokens.append(.function(function))
                parser = frame.parser

            case let .block(openToken):
                tokens = frame.tokens
                tokens.append(contentsOf: completedTokens)
                switch openToken {
                case .parenthesisBlock:
                    tokens.append(.token(.closeParenthesis))
                case .squareBracketBlock:
                    tokens.append(.token(.closeSquareBracket))
                case .curlyBracketBlock:
                    tokens.append(.token(.closeCurlyBracket))
                default:
                    break
                }
                parser = frame.parser
            }
        }

        let result = trimWhitespace(tokens)
        return .success(CSSTokenList(tokens: result))
    }

    private static func buildVariable(
        from tokens: [CSSTokenOrValue],
        existingName: CSSDashedIdent?
    ) -> CSSVariable {
        var remaining = tokens[...]

        while let first = remaining.first, first.isWhitespace {
            remaining = remaining.dropFirst()
        }

        let name: CSSDashedIdent
        if let existing = existingName {
            name = existing
        } else if let first = remaining.first {
            if case let .dashedIdent(ident) = first {
                name = ident
                remaining = remaining.dropFirst()
            } else if case let .token(.ident(lexeme)) = first, lexeme.value.hasPrefix("--") {
                name = CSSDashedIdent(String(lexeme.value))
                remaining = remaining.dropFirst()
            } else {
                return CSSVariable(name: CSSDashedIdent("--"), fallback: nil)
            }
        } else {
            return CSSVariable(name: CSSDashedIdent("--"), fallback: nil)
        }

        while let first = remaining.first, first.isWhitespace {
            remaining = remaining.dropFirst()
        }

        var fallback: CSSTokenList?
        if let first = remaining.first, case .token(.comma) = first {
            remaining = remaining.dropFirst()
            while let first = remaining.first, first.isWhitespace {
                remaining = remaining.dropFirst()
            }
            if !remaining.isEmpty {
                let fallbackTokens = trimWhitespace(Array(remaining))
                fallback = CSSTokenList(tokens: fallbackTokens)
            }
        }

        return CSSVariable(name: name, fallback: fallback)
    }

    private static func buildEnvironment(
        from tokens: [CSSTokenOrValue],
        existingName: CSSEnvironmentVariableName?,
        indices: [CSSInteger]
    ) -> CSSEnvironmentVariable {
        var remaining = tokens[...]

        while let first = remaining.first, first.isWhitespace {
            remaining = remaining.dropFirst()
        }

        let name: CSSEnvironmentVariableName
        if let existing = existingName {
            name = existing
        } else if let first = remaining.first, case let .token(.ident(lexeme)) = first {
            name = CSSEnvironmentVariableName.from(String(lexeme.value))
            remaining = remaining.dropFirst()
        } else {
            return CSSEnvironmentVariable(name: .custom(""), indices: [], fallback: nil)
        }

        var collectedIndices = indices
        while !remaining.isEmpty {
            while let first = remaining.first, first.isWhitespace {
                remaining = remaining.dropFirst()
            }
            guard let first = remaining.first else { break }

            if case let .token(.number(numeric)) = first, let intVal = numeric.intValue {
                collectedIndices.append(Int(intVal))
                remaining = remaining.dropFirst()
                continue
            }

            if case .token(.comma) = first {
                remaining = remaining.dropFirst()
                break
            }

            break
        }

        var fallback: CSSTokenList?
        if !remaining.isEmpty {
            let fallbackTokens = trimWhitespace(Array(remaining))
            if !fallbackTokens.isEmpty {
                fallback = CSSTokenList(tokens: fallbackTokens)
            }
        }

        return CSSEnvironmentVariable(name: name, indices: collectedIndices, fallback: fallback)
    }

    private static func trimWhitespace(_ tokens: [CSSTokenOrValue]) -> [CSSTokenOrValue] {
        guard tokens.count >= 2 else { return tokens }
        var result = tokens
        if result.first?.isWhitespace == true {
            result.removeFirst()
        }
        if result.last?.isWhitespace == true {
            result.removeLast()
        }
        return result
    }
}

/// Returns whether a function name is a color function.
private func isColorFunction(_ name: String) -> Bool {
    switch name {
    case "rgb", "rgba", "hsl", "hsla", "hwb", "lab", "lch", "oklab", "oklch",
         "color", "color-mix", "light-dark":
        true
    default:
        false
    }
}

extension CSSVariable {
    /// Parses a variable reference (inside var() function).
    static func parse(_ input: Parser) -> Result<CSSVariable, BasicParseError> {
        // Parse the variable name
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        guard ident.value.hasPrefix("--") else {
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }

        let name = CSSDashedIdent(String(ident.value))

        // Try to parse fallback after comma
        var fallback: CSSTokenList?
        if input.tryParse({ $0.expectComma() }).isOK {
            switch CSSTokenList.parse(input) {
            case let .success(list):
                fallback = list
            case .failure:
                break
            }
        }

        return .success(CSSVariable(name: name, fallback: fallback))
    }
}

extension CSSEnvironmentVariable {
    /// Parses an environment variable reference (inside env() function).
    static func parse(_ input: Parser) -> Result<CSSEnvironmentVariable, BasicParseError> {
        // Parse the variable name
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let name = CSSEnvironmentVariableName.from(String(ident.value))

        // Parse optional indices
        var indices: [CSSInteger] = []
        while case let .success(idx) = input.tryParse({ Int.parse($0) }) {
            indices.append(idx)
        }

        // Try to parse fallback after comma
        var fallback: CSSTokenList?
        if input.tryParse({ $0.expectComma() }).isOK {
            switch CSSTokenList.parse(input) {
            case let .success(list):
                fallback = list
            case .failure:
                break
            }
        }

        return .success(CSSEnvironmentVariable(name: name, indices: indices, fallback: fallback))
    }
}

extension CSSEnvironmentVariableName {
    /// Creates an environment variable name from a string.
    static func from(_ string: String) -> CSSEnvironmentVariableName {
        switch string.lowercased() {
        case "safe-area-inset-top":
            .safeAreaInsetTop
        case "safe-area-inset-right":
            .safeAreaInsetRight
        case "safe-area-inset-bottom":
            .safeAreaInsetBottom
        case "safe-area-inset-left":
            .safeAreaInsetLeft
        case "viewport-segment-width":
            .viewportSegmentWidth
        case "viewport-segment-height":
            .viewportSegmentHeight
        case "viewport-segment-top":
            .viewportSegmentTop
        case "viewport-segment-left":
            .viewportSegmentLeft
        case "viewport-segment-bottom":
            .viewportSegmentBottom
        case "viewport-segment-right":
            .viewportSegmentRight
        case "titlebar-area-x":
            .titlebarAreaX
        case "titlebar-area-y":
            .titlebarAreaY
        case "titlebar-area-width":
            .titlebarAreaWidth
        case "titlebar-area-height":
            .titlebarAreaHeight
        default:
            .custom(string)
        }
    }
}

// MARK: - Serialization

extension CSSCustomProperty: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        name.serialize(dest: &dest)
        dest.write(": ")
        value.serialize(dest: &dest, isCustomProperty: true)
    }
}

extension CSSCustomPropertyName: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(name)
    }
}

extension CSSUnparsedProperty: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        // Only serialize the value, not the property name
        //
        value.serialize(dest: &dest, isCustomProperty: false)
    }
}

public extension CSSTokenList {
    /// Serializes the token list.
    func serialize(dest: inout some CSSWriter, isCustomProperty: Bool) {
        for token in tokens {
            token.serialize(dest: &dest, isCustomProperty: isCustomProperty)
        }
    }
}

extension CSSTokenList: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        serialize(dest: &dest, isCustomProperty: false)
    }
}

public extension CSSTokenOrValue {
    /// Serializes the token or value.
    func serialize(dest: inout some CSSWriter, isCustomProperty: Bool) {
        switch self {
        case let .token(token):
            token.serialize(dest: &dest)
        case let .color(color):
            color.serialize(dest: &dest)
        case let .url(url):
            url.serialize(dest: &dest)
        case let .variable(variable):
            variable.serialize(dest: &dest, isCustomProperty: isCustomProperty)
        case let .environment(env):
            env.serialize(dest: &dest, isCustomProperty: isCustomProperty)
        case let .function(function):
            function.serialize(dest: &dest, isCustomProperty: isCustomProperty)
        case let .length(length):
            // In custom properties, always serialize with unit to not break calc()
            if isCustomProperty {
                length.serializeWithUnit(dest: &dest)
            } else {
                length.serialize(dest: &dest)
            }
        case let .angle(angle):
            angle.serialize(dest: &dest)
        case let .time(time):
            time.serialize(dest: &dest)
        case let .resolution(resolution):
            resolution.serialize(dest: &dest)
        case let .dashedIdent(ident):
            ident.serialize(dest: &dest)
        }
    }
}

extension CSSTokenOrValue: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        serialize(dest: &dest, isCustomProperty: false)
    }
}

public extension CSSVariable {
    /// Serializes the variable reference.
    func serialize(dest: inout some CSSWriter, isCustomProperty: Bool) {
        dest.write("var(")
        name.serialize(dest: &dest)
        if let fallback {
            dest.write(", ")
            fallback.serialize(dest: &dest, isCustomProperty: isCustomProperty)
        }
        dest.write(")")
    }
}

extension CSSVariable: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        serialize(dest: &dest, isCustomProperty: false)
    }
}

public extension CSSEnvironmentVariable {
    /// Serializes the environment variable reference.
    func serialize(dest: inout some CSSWriter, isCustomProperty: Bool) {
        dest.write("env(")
        name.serialize(dest: &dest)
        for idx in indices {
            dest.write(" ")
            dest.write(String(idx))
        }
        if let fallback {
            dest.write(", ")
            fallback.serialize(dest: &dest, isCustomProperty: isCustomProperty)
        }
        dest.write(")")
    }
}

extension CSSEnvironmentVariable: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        serialize(dest: &dest, isCustomProperty: false)
    }
}

extension CSSEnvironmentVariableName: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .safeAreaInsetTop:
            dest.write("safe-area-inset-top")
        case .safeAreaInsetRight:
            dest.write("safe-area-inset-right")
        case .safeAreaInsetBottom:
            dest.write("safe-area-inset-bottom")
        case .safeAreaInsetLeft:
            dest.write("safe-area-inset-left")
        case .viewportSegmentWidth:
            dest.write("viewport-segment-width")
        case .viewportSegmentHeight:
            dest.write("viewport-segment-height")
        case .viewportSegmentTop:
            dest.write("viewport-segment-top")
        case .viewportSegmentLeft:
            dest.write("viewport-segment-left")
        case .viewportSegmentBottom:
            dest.write("viewport-segment-bottom")
        case .viewportSegmentRight:
            dest.write("viewport-segment-right")
        case .titlebarAreaX:
            dest.write("titlebar-area-x")
        case .titlebarAreaY:
            dest.write("titlebar-area-y")
        case .titlebarAreaWidth:
            dest.write("titlebar-area-width")
        case .titlebarAreaHeight:
            dest.write("titlebar-area-height")
        case let .custom(name):
            dest.write(name)
        }
    }
}

public extension CSSFunction {
    /// Serializes the function.
    func serialize(dest: inout some CSSWriter, isCustomProperty: Bool) {
        dest.write(name)
        dest.write("(")
        arguments.serialize(dest: &dest, isCustomProperty: isCustomProperty)
        dest.write(")")
    }
}

extension CSSFunction: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        serialize(dest: &dest, isCustomProperty: false)
    }
}

// MARK: - CSSLength Extensions

extension CSSLength {
    /// Creates a length from a value and unit string.
    init?(value: Double, unit: String) {
        guard let lengthUnit = CSSLengthUnit(string: unit) else {
            return nil
        }
        self.init(value, lengthUnit)
    }

    /// Serializes the length with its unit (never as unitless zero).
    func serializeWithUnit(dest: inout some CSSWriter) {
        dest.write(formatDouble(value))
        dest.write(unit.rawValue)
    }
}

// MARK: - CSSAngle Extensions

extension CSSAngle {
    /// Creates an angle from a value and unit string.
    init?(value: Double, unit: String) {
        switch unit.lowercased() {
        case "deg":
            self = .deg(value)
        case "rad":
            self = .rad(value)
        case "grad":
            self = .grad(value)
        case "turn":
            self = .turn(value)
        default:
            return nil
        }
    }
}

// MARK: - CSSTime Extensions

extension CSSTime {
    /// Creates a time from a value and unit string.
    init?(value: Double, unit: String) {
        switch unit.lowercased() {
        case "s":
            self = .seconds(value)
        case "ms":
            self = .milliseconds(value)
        default:
            return nil
        }
    }
}

// MARK: - CSSResolution Extensions

extension CSSResolution {
    /// Creates a resolution from a value and unit string.
    init?(value: Double, unit: String) {
        switch unit.lowercased() {
        case "dpi":
            self = .dpi(value)
        case "dpcm":
            self = .dpcm(value)
        case "dppx", "x":
            self = .dppx(value)
        default:
            return nil
        }
    }
}

// MARK: - Color Extensions

extension Color {
    /// Creates a color from a hex string (without the # prefix).
    static func fromHex(_ hex: String) -> Color? {
        let hex = hex.lowercased()
        let length = hex.count

        guard length == 3 || length == 4 || length == 6 || length == 8 else {
            return nil
        }

        var chars = Array(hex)

        // Expand 3/4 char hex to 6/8
        if length == 3 || length == 4 {
            var expanded: [Character] = []
            for c in chars {
                expanded.append(c)
                expanded.append(c)
            }
            chars = expanded
        }

        guard let r = hexValue(chars[0], chars[1]),
              let g = hexValue(chars[2], chars[3]),
              let b = hexValue(chars[4], chars[5])
        else {
            return nil
        }

        let a: Double
        if chars.count == 8 {
            guard let alpha = hexValue(chars[6], chars[7]) else {
                return nil
            }
            a = alpha / 255.0
        } else {
            a = 1.0
        }

        return .rgba(RgbaLegacy(red: r, green: g, blue: b, alpha: a))
    }
}

private func hexValue(_ high: Character, _ low: Character) -> Double? {
    guard let h = high.hexDigitValue, let l = low.hexDigitValue else {
        return nil
    }
    return Double(h * 16 + l)
}
