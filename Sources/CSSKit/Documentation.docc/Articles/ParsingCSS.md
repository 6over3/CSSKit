# Parsing CSS

Different ways to parse CSS.

## Stylesheets

Parse a whole stylesheet:

```swift
let parser = CSSParser(css)
let stylesheet = parser.stylesheet
```

## Track source files

When parsing multiple files, pass the filename so you know where each rule came from:

```swift
let base = CSSParser(baseCSS, sourceFile: "base.css")
let theme = CSSParser(themeCSS, sourceFile: "theme.css")

let merged = base.stylesheet.merged(with: theme.stylesheet)

for rule in merged.rules {
    if case .style(let style) = rule {
        print(style.location.sourceFile ?? "unknown")
    }
}
```

## Rules only

If you just need the rules:

```swift
let parser = CSSParser(".button { color: red; }")
let rules = parser.rules
```

## Declarations

Parse declaration lists like inline styles:

```swift
let parser = CSSParser("color: red; font-size: 16px;")
let declarations = try parser.declarations

for decl in declarations {
    print("\(decl.name): \(decl.rawValue)")
}
```

## Single values

Parse one CSS value:

```swift
let parser = CSSParser("10px")
let value = try parser.value
```

## Errors

The parser skips invalid rules and keeps parsing. Access errors afterward:

```swift
let css = """
.valid { color: red; }
.broken { color: }
.also-valid { color: blue; }
"""

let parser = CSSParser(css)
print(parser.rules.count)   // 2
print(parser.errors.count)  // 1
```

## Full result

Get everything at once:

```swift
let parser = CSSParser(css)
let result = parser.result

// result.rules, result.errors, result.sourceMapUrl, result.sourceUrl
```

## Tokens

For low-level access:

```swift
let parser = CSSParser(css)
for token in parser.tokenize() {
    switch token {
    case .ident(let name):
        print("Identifier: \(name.value)")
    case .number(let num):
        print("Number: \(num.value)")
    case .hash(let hash):
        print("Hash: #\(hash.value)")
    default:
        break
    }
}
```
