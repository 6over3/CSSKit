# CSSKit

A Swift library for parsing CSS. Conforms to [CSS Syntax Level 3](https://drafts.csswg.org/css-syntax/).

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/6over3/CSSKit.git", from: "1.0.0")
]
```

## Usage

```swift
import CSSKit

let css = """
.button {
    color: oklch(70% 0.15 200);
    padding: 10px 20px;
}
"""

let parser = CSSParser(css)

for rule in parser.rules {
    if case .style(let style) = rule {
        print(style.selectorText)  // ".button"
        for decl in style.declarations {
            print("  \(decl.name): \(decl.rawValue)")
        }
    }
}
```

### Parse errors

CSSKit recovers from errors like browsers do. Invalid rules are skipped, valid ones are kept.

```swift
let parser = CSSParser(css)

for error in parser.errors {
    print("\(error.location.line):\(error.location.column) \(error.message)")
}
```

### Typed values

Property values are parsed into Swift types:

```swift
for decl in style.declarations {
    switch decl.value {
    case .color(let color):
        // Color with oklch, lab, rgb, hex, named colors...
        print("Color: \(color)")
    case .fontWeight(let fw):
        // CSSFontWeight with .absolute, .bolder, .lighter
        if case .absolute(let abs) = fw {
            print("Weight: \(abs.numericValue)")  // 400, 700, etc.
        }
    case .lengthPercentage(let lp):
        print("Length: \(lp)")
    case .unparsed(let raw):
        // Fallback for unrecognized properties
        print("Raw: \(raw.value)")
    default:
        break
    }
}
```

### Source file tracking

Track which file rules came from when parsing multiple stylesheets:

```swift
let base = CSSParser(baseCSS, sourceFile: "base.css")
let theme = CSSParser(themeCSS, sourceFile: "theme.css")

let merged = base.stylesheet.merged(with: theme.stylesheet)

for rule in merged.rules {
    if case .style(let s) = rule {
        print(s.location.sourceFile)  // "base.css" or "theme.css"
    }
}
```

### Declarations from style attributes

```swift
let parser = CSSParser("color: red; margin: 10px")
let declarations = try parser.declarations
```

### Individual values

```swift
let parser = CSSParser("oklch(70% 0.15 200)")
let color = try parser.value
```

## Cascade resolution

CSSKit provides the building blocks for implementing CSS cascade. Here's how they fit together.

### Specificity

Every selector has specificity:

```swift
if let selectors = style.selectors {
    for selector in selectors.selectors {
        let spec = selector.specificity
        print("(\(spec.ids), \(spec.classes), \(spec.elements))")
    }
}
```

### CascadeWeight and CascadeResolver

`CascadeWeight` captures everything that determines which declaration wins:

```swift
let weight = CascadeWeight(
    origin: .author,           // .userAgent, .user, or .author
    isImportant: decl.isImportant,
    layer: layer,              // @layer order
    specificity: selector.specificity,
    order: declarationOrder    // source order
)
```

`CascadeResolver` picks the winner:

```swift
let resolver = CascadeResolver()

var candidates: [(value: Declaration, weight: CascadeWeight)] = []
for (rule, weight) in matchingRules {
    for decl in rule.declarations where decl.name == "color" {
        candidates.append((decl, weight))
    }
}

if let winner = resolver.resolve(candidates) {
    print("color: \(winner.rawValue)")
}
```

### Property inheritance

Some CSS properties inherit from parent elements. `CSSPropertyId` knows which:

```swift
let propertyId = CSSPropertyId("font-family")
if propertyId.inherits {
    // Walk up the DOM tree to find inherited value
}
```

When a declaration uses a CSS-wide keyword, the value holds both the keyword and which property it applies to:

```swift
if case .wideKeyword(let keyword, let propertyId) = decl.value {
    switch keyword {
    case .inherit:
        // Use parent's computed value
    case .initial:
        // Use spec-defined initial value
    case .unset:
        // inherit if property inherits, otherwise initial
    case .revert:
        // Roll back to user-agent stylesheet
    case .revertLayer:
        // Roll back to previous @layer
    }
}
```

### Initial values

Most value types conform to `CSSInitialValue`:

```swift
CSSFontWeight.initial    // .absolute(.normal) = 400
CSSDisplay.initial       // .pair(outside: .inline, inside: .flow)
CSSVisibility.initial    // .visible
```

## Example: HTML to Markdown via CSS

The `CSSKitExample` target shows how to combine CSSKit with [SwiftSoup](https://github.com/scinfu/SwiftSoup) to convert non-semantic HTML into Markdown by resolving CSS styles.

Given HTML like:
```html
<div class="title">Heading</div>
<div class="block"><span class="strong">Bold text</span></div>
```

With CSS:
```css
.title { font-size: 2em; font-weight: bold; }
.strong { font-weight: bold; }
```

The example resolves styles per-element and converts to Markdown:
```markdown
# Heading
**Bold text**
```

It demonstrates:
- Selector matching against a DOM tree
- Specificity-based cascade resolution
- Property inheritance walking up the tree
- Typed value access (`decl.value` as `CSSFontWeight`, `Color`, etc.)

Run it with:
```bash
swift run CSSKitExample
```

## What's supported

**Parsing**
- CSS Syntax Level 3
- Nested rules (CSS Nesting)
- All standard at-rules (@media, @supports, @keyframes, @container, @layer, @scope, @property, etc.)
- Error recovery per spec

**Colors** (Level 4 and 5)
- Named, hex, rgb(), hsl(), hwb()
- lab(), lch(), oklab(), oklch()
- color() with predefined spaces
- color-mix()
- Relative color syntax

**Selectors** (Level 4)
- All combinators
- :is(), :where(), :has(), :not()
- :nth-child(), :nth-of-type(), etc.
- Attribute selectors
- Pseudo-elements

**Values**
- 200+ typed CSS properties
- Lengths, percentages, angles, times
- calc(), min(), max(), clamp()
- Gradients (linear, radial, conic)
- var(), env()

**Cascade**
- Specificity calculation
- CascadeWeight with origin, importance, layers
- CascadeResolver for picking winners
- Property inheritance flags

## License

MPL-2.0
