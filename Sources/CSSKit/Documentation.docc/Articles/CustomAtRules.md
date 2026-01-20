# Custom at-rules

Handle non-standard or custom at-rules.

## The AtRuleParser protocol

Implement `AtRuleParser` to handle custom at-rules:

```swift
public protocol AtRuleParser<AtRule> {
    associatedtype AtRule: CSSSerializable & Sendable & Equatable

    func parseAtRule(
        name: String,
        prelude: ParsingContext,
        context: AtRuleContext
    ) throws -> AtRuleParseResult<AtRule>?

    func parseAtRuleBlock(
        name: String,
        prelude: String,
        body: ParsingContext,
        context: AtRuleContext
    ) throws -> AtRuleParseResult<AtRule>?

    func parseDeclaration(
        name: String,
        value: ParsingContext,
        context: AtRuleContext
    ) throws -> CSSDeclaration?
}
```

## Implementing a custom parser

```swift
struct TailwindRule: CSSSerializable, Sendable, Equatable {
    let directive: String
    let classes: [String]

    func serialize<W: CSSWriter>(dest: inout W) {
        dest.write("@apply ")
        dest.write(classes.joined(separator: " "))
        dest.write(";")
    }
}

struct TailwindParser: AtRuleParser {
    typealias AtRule = TailwindRule

    func parseAtRule(
        name: String,
        prelude: ParsingContext,
        context: AtRuleContext
    ) throws -> AtRuleParseResult<TailwindRule>? {
        guard name == "apply" else { return nil }

        var classes: [String] = []
        while let ident = try? prelude.expectIdent() {
            classes.append(ident)
        }

        return .custom(TailwindRule(directive: name, classes: classes))
    }
}
```

## Using your parser

```swift
let css = """
.button {
    @apply px-4 py-2 bg-blue-500;
}
"""

let parser = CSSParser(css, atRuleParser: TailwindParser())
for rule in parser.rules {
    if case .custom(let tailwind) = rule {
        print("Applied: \(tailwind.classes)")
    }
}
```

## AtRuleContext

The context provides location info:

```swift
public struct AtRuleContext: Sendable {
    public let location: SourceLocation
}
```

## AtRuleParseResult

Return values from your parser:

```swift
public enum AtRuleParseResult<R> {
    case rule(CSSRule<R>)
    case custom(R)
}
```

## DefaultAtRuleParser

When you don't need custom at-rules, use `DefaultAtRuleParser` (the default):

```swift
let parser = CSSParser(css)
// Uses DefaultAtRuleParser which handles standard at-rules only
```
