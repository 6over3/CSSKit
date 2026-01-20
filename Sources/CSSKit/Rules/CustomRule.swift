// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Custom At-Rule Protocol

/// Protocol for defining custom CSS at-rules.
///
/// Implement this protocol to parse custom at-rules like `@tailwind` or `@apply`.
///
/// ```swift
/// struct TailwindDirective: CSSAtRule {
///   static let name = "tailwind"
///   let directive: String
///
///   static func parse(prelude: ParsingContext, context: AtRuleContext) throws -> Self {
///     let directive = try prelude.expectIdent()
///     return TailwindDirective(directive: directive)
///   }
/// }
/// ```
public protocol CSSAtRule: CSSSerializable & Sendable & Equatable {
    /// The at-rule name without the `@` prefix (e.g., "tailwind" for `@tailwind`).
    static var name: String { get }

    /// Parses the at-rule prelude (the part after `@name` and before `{` or `;`).
    static func parse(prelude: ParsingContext, context: AtRuleContext) throws -> Self

    /// Parses an at-rule with a block body.
    /// Return `nil` if this at-rule doesn't support blocks.
    static func parseBlock(prelude: String, body: ParsingContext, context: AtRuleContext) throws -> Self?
}

public extension CSSAtRule {
    static func parseBlock(prelude _: String, body _: ParsingContext, context _: AtRuleContext) throws -> Self? { nil }
}

// MARK: - At-Rule Set

/// A collection of custom at-rules that can be parsed together.
///
/// ```swift
/// enum MyAtRules: CSSAtRuleSet {
///   case tailwind(TailwindDirective)
///   case apply(ApplyDirective)
///
///   static var handlers: [CSSAtRuleHandler<Self>] {
///     [
///       CSSAtRuleHandler(TailwindDirective.self, wrap: Self.tailwind),
///       CSSAtRuleHandler(ApplyDirective.self, wrap: Self.apply),
///     ]
///   }
/// }
/// ```
public protocol CSSAtRuleSet: CSSSerializable & Sendable & Equatable {
    static var handlers: [CSSAtRuleHandler<Self>] { get }
}

public extension CSSAtRuleSet {
    static var parser: AtRuleSetParser<Self> { AtRuleSetParser() }
}

// MARK: - At-Rule Handler

/// Type-erased handler for a specific custom at-rule type.
public struct CSSAtRuleHandler<R: CSSAtRuleSet>: Sendable {
    public let name: String
    private let _parse: @Sendable (ParsingContext, AtRuleContext) throws -> R?
    private let _parseBlock: @Sendable (String, ParsingContext, AtRuleContext) throws -> R?

    public init<T: CSSAtRule>(_: T.Type, wrap: @escaping @Sendable (T) -> R) {
        name = T.name.lowercased()
        _parse = { prelude, context in
            try wrap(T.parse(prelude: prelude, context: context))
        }
        _parseBlock = { prelude, body, context in
            try T.parseBlock(prelude: prelude, body: body, context: context).map(wrap)
        }
    }

    func parse(prelude: ParsingContext, context: AtRuleContext) throws -> R? {
        try _parse(prelude, context)
    }

    func parseBlock(prelude: String, body: ParsingContext, context: AtRuleContext) throws -> R? {
        try _parseBlock(prelude, body, context)
    }
}

// MARK: - At-Rule Parser Protocol

/// Low-level protocol for custom at-rule parsing.
///
/// Most users should use `CSSAtRule` and `CSSAtRuleSet` instead.
public protocol AtRuleParser<AtRule> {
    associatedtype AtRule: CSSSerializable & Sendable & Equatable

    func parseAtRule(name: String, prelude: ParsingContext, context: AtRuleContext) throws -> AtRuleParseResult<AtRule>?
    func parseAtRuleBlock(name: String, prelude: String, body: ParsingContext, context: AtRuleContext) throws -> AtRuleParseResult<AtRule>?
    func parseDeclaration(name: String, value: ParsingContext, context: AtRuleContext) throws -> CSSDeclaration?
}

public extension AtRuleParser {
    func parseAtRule(name _: String, prelude _: ParsingContext, context _: AtRuleContext) throws -> AtRuleParseResult<AtRule>? { nil }
    func parseAtRuleBlock(name _: String, prelude _: String, body _: ParsingContext, context _: AtRuleContext) throws -> AtRuleParseResult<AtRule>? { nil }
    func parseDeclaration(name _: String, value _: ParsingContext, context _: AtRuleContext) throws -> CSSDeclaration? { nil }
}

// MARK: - At-Rule Parse Result

public enum AtRuleParseResult<R: CSSSerializable & Sendable & Equatable>: Sendable, Equatable {
    case rule(CSSRule<R>)
    case custom(R)

    public var asRule: CSSRule<R> {
        switch self {
        case let .rule(rule): rule
        case let .custom(rule): .custom(rule)
        }
    }
}

// MARK: - At-Rule Context

/// Context provided when parsing at-rules.
public struct AtRuleContext: Sendable {
    /// The source location where the at-rule starts.
    public let location: SourceLocation

    public init(location: SourceLocation) {
        self.location = location
    }
}

// MARK: - Default At-Rule Parser

/// The default at-rule parser that handles only built-in CSS at-rules.
public struct DefaultAtRuleParser: AtRuleParser, Sendable {
    public typealias AtRule = Never
    public init() {}
}

// MARK: - At-Rule Set Parser

/// A parser for a set of custom at-rules.
public struct AtRuleSetParser<R: CSSAtRuleSet>: AtRuleParser, Sendable {
    public typealias AtRule = R

    private let handlersByName: [String: CSSAtRuleHandler<R>]

    public init() {
        var dict: [String: CSSAtRuleHandler<R>] = [:]
        for handler in R.handlers {
            dict[handler.name] = handler
        }
        handlersByName = dict
    }

    public func parseAtRule(name: String, prelude: ParsingContext, context: AtRuleContext) throws -> AtRuleParseResult<R>? {
        guard let handler = handlersByName[name.lowercased()] else { return nil }
        return try handler.parse(prelude: prelude, context: context).map { .custom($0) }
    }

    public func parseAtRuleBlock(name: String, prelude: String, body: ParsingContext, context: AtRuleContext) throws -> AtRuleParseResult<R>? {
        guard let handler = handlersByName[name.lowercased()] else { return nil }
        return try handler.parseBlock(prelude: prelude, body: body, context: context).map { .custom($0) }
    }
}

// MARK: - Never: CSSSerializable

extension Never: CSSSerializable {
    public func serialize(dest _: inout some CSSWriter) {}
}
