# Working with stylesheets

Navigate parsed CSS and implement cascade resolution.

## Rule types

A `Stylesheet` contains `Rule` values:

```swift
for rule in stylesheet.rules {
    switch rule {
    case .style(let style):
        handleStyleRule(style)

    case .media(let media):
        print("@media \(media.query)")
        for nested in media.rules {
            // handle nested rules
        }

    case .supports(let supports):
        print("@supports \(supports.condition)")

    case .keyframes(let keyframes):
        print("@keyframes \(keyframes.name)")

    case .fontFace(let fontFace):
        for decl in fontFace.declarations {
            print("\(decl.name): \(decl.rawValue)")
        }

    case .container(let container):
        // container.condition is typed ContainerCondition
        print("@container \(container.name ?? "") \(container.condition)")

    case .scope(let scope):
        // scope.scopeStart and scopeEnd are typed SelectorList?
        print("@scope")

    case .property(let prop):
        // @property with typed syntax and initialValue
        print("@property \(prop.name)")
        print("  syntax: \(prop.syntax)")
        print("  inherits: \(prop.inherits)")

    case .layerBlock(let layer):
        print("@layer \(layer.name?.description ?? "anonymous")")

    case .unknown(let unknown):
        print("@\(unknown.name)")

    default:
        break
    }
}
```

## Style rules

```swift
func handleStyleRule(_ rule: StyleRule<Never>) {
    if let selectors = rule.selectors {
        print("Selector: \(selectors.text)")
        print("Specificity: \(selectors.maxSpecificity)")
    }

    for decl in rule.declarations {
        print("\(decl.name): \(decl.rawValue)")
        if decl.isImportant {
            print("  !important")
        }
    }

    // CSS nesting
    for nested in rule.rules {
        print("Nested: \(nested)")
    }
}
```

## Merge stylesheets

Combine multiple stylesheets:

```swift
let base = CSSParser(baseCSS, sourceFile: "base.css").stylesheet
let theme = CSSParser(themeCSS, sourceFile: "theme.css").stylesheet

let combined = base.merged(with: theme)
```

Rules keep their `sourceFile` so you can tell where they came from.

## Cascade resolution

CSSKit provides building blocks for CSS cascade. You supply the DOM matching.

### Specificity

Each selector has specificity as (ids, classes, elements):

```swift
if let selectors = style.selectors {
    for selector in selectors.selectors {
        let spec = selector.specificity
        // spec.ids, spec.classes, spec.elements
    }
}
```

### CascadeWeight

`CascadeWeight` captures everything that determines which declaration wins:

```swift
let weight = CascadeWeight(
    origin: .author,
    isImportant: decl.isImportant,
    layer: layer,
    specificity: selector.specificity,
    order: sourceOrder
)
```

Origins are `.userAgent`, `.user`, and `.author`. Layer order matters for `@layer` rules.

### CascadeResolver

Given candidates for a property, the resolver picks the winner:

```swift
let resolver = CascadeResolver()

var candidates: [(value: Declaration, weight: CascadeWeight)] = []
for (rule, weight) in matchingRules {
    for decl in rule.declarations where decl.name == propertyName {
        let declWeight = CascadeWeight(
            origin: weight.origin,
            isImportant: decl.isImportant,
            specificity: weight.specificity,
            order: weight.order
        )
        candidates.append((decl, declWeight))
    }
}

if let winner = resolver.resolve(candidates) {
    return winner
}
```

### Property inheritance

`CSSPropertyId` knows which properties inherit:

```swift
let propertyId = CSSPropertyId(propertyName)
if propertyId.inherits {
    // font-family, color, etc. inherit from parent
    return resolveProperty(propertyName, for: parent)
}
```

### CSS-wide keywords

When a value is `inherit`, `initial`, `unset`, `revert`, or `revert-layer`:

```swift
switch decl.value {
case .wideKeyword(let keyword, let propertyId):
    switch keyword {
    case .inherit:
        return getComputedValue(propertyId, from: parent)
    case .initial:
        return getInitialValue(propertyId)
    case .unset:
        if propertyId.inherits {
            return getComputedValue(propertyId, from: parent)
        }
        return getInitialValue(propertyId)
    case .revert:
        // Use user-agent stylesheet value
    case .revertLayer:
        // Use previous @layer value
    }
default:
    // Regular typed value
}
```

### Initial values

Most value types have a spec-defined initial:

```swift
CSSFontWeight.initial    // .absolute(.normal)
CSSDisplay.initial       // .pair(outside: .inline, inside: .flow)
CSSVisibility.initial    // .visible
CSSCursor.initial        // CSSCursor(keyword: .auto)
```

## Serialization

Turn a stylesheet back into CSS:

```swift
let css = stylesheet.string

// Or with a writer for more control
var writer = StringCSSWriter()
stylesheet.serialize(dest: &writer)
print(writer.result)
```

## Resolve @import

CSSKit parses @import rules but doesn't fetch files. Handle that yourself:

```swift
func resolveImports(
    _ stylesheet: Stylesheet<Never>,
    fetch: (String) -> String?
) -> Stylesheet<Never> {
    var resolved: [Rule<Never>] = []

    for rule in stylesheet.rules {
        if case .importRule(let imp) = rule {
            if let css = fetch(imp.url) {
                let imported = CSSParser(css, sourceFile: imp.url).stylesheet
                let nested = resolveImports(imported, fetch: fetch)
                resolved.append(contentsOf: nested.rules)
            }
        } else {
            resolved.append(rule)
        }
    }

    return Stylesheet(rules: resolved)
}
```
