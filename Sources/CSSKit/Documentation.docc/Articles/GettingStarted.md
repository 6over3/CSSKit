# Getting started

Add CSSKit to your project and parse CSS.

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/6over3/CSSKit.git", from: "1.0.0")
]
```

Then add to your target:

```swift
.target(name: "MyApp", dependencies: ["CSSKit"])
```

## Parse a stylesheet

```swift
import CSSKit

let css = """
body {
    margin: 0;
    font-family: system-ui, sans-serif;
}
"""

let parser = CSSParser(css)
let stylesheet = parser.stylesheet
```

## Inspect rules

```swift
for rule in parser.rules {
    switch rule {
    case .style(let style):
        print("Selector: \(style.selectorText ?? "")")
        for decl in style.declarations {
            print("  \(decl.name): \(decl.rawValue)")
        }
    case .media(let media):
        print("@media \(media.query)")
    default:
        break
    }
}
```

## Check for errors

CSSKit recovers from errors like browsers do. Invalid rules get skipped:

```swift
let parser = CSSParser(css)

for error in parser.errors {
    print("Line \(error.location.line): \(error.message)")
}

// The stylesheet has all valid rules
let stylesheet = parser.stylesheet
```

## Next

- <doc:ParsingCSS> covers different parsing modes
- <doc:CSSValues> explains the typed value system
- <doc:SelectorParsing> shows selector inspection
