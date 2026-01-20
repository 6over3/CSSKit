# Selector parsing

Inspect CSS selectors from parsed rules.

## Get selectors from a rule

Selectors come from parsing stylesheets. Each style rule has a `selectors` property:

```swift
let parser = CSSParser(".button:hover, a[href^='https'] {}")

for rule in parser.rules {
    if case .style(let style) = rule,
       let selectors = style.selectors {
        for selector in selectors.selectors {
            print(selector.text)
        }
    }
}
```

## Selector structure

A `Selector` is a list of `Component` values. Use `compoundSelectors` to walk through it:

```swift
for selector in selectorList.selectors {
    var iter = selector.compoundSelectors
    while let (compound, combinator) = iter.next() {
        print("Compound: \(compound)")
        if let c = combinator {
            print("Combinator: \(c)")
        }
    }
}
```

Combinators:
- `.descendant` (space)
- `.child` (`>`)
- `.nextSibling` (`+`)
- `.subsequentSibling` (`~`)

## Components

Each component in a selector is a `Component`:

```swift
for component in selector.components {
    switch component {
    case .type(let name):
        print("Type: \(name)")
    case .id(let id):
        print("ID: #\(id)")
    case .class(let cls):
        print("Class: .\(cls)")
    case .attribute(let attr):
        print("Attribute: [\(attr.name)]")
    case .pseudoClass(let pseudo):
        print("Pseudo-class: \(pseudo)")
    case .pseudoElement(let pseudo):
        print("Pseudo-element: \(pseudo)")
    case .universal:
        print("Universal: *")
    case .nesting:
        print("Nesting: &")
    case .combinator(let c):
        print("Combinator: \(c)")
    default:
        break
    }
}
```

## Pseudo-classes

The `PseudoClass` enum covers all standard pseudo-classes:

```swift
switch pseudoClass {
case .hover, .active, .focus, .visited:
    print("User action")
case .firstChild, .lastChild, .onlyChild:
    print("Tree-structural")
case .nthChild(let nth):
    print("nth-child(\(nth))")
case .not(let selectors):
    print(":not(\(selectors.text))")
case .is(let selectors), .where(let selectors):
    print("Forgiving selector list")
case .has(let selectors):
    print(":has(\(selectors.text))")
default:
    break
}
```

## Specificity

```swift
let specificity = selectorList.maxSpecificity
print("IDs: \(specificity.ids)")
print("Classes: \(specificity.classes)")
print("Elements: \(specificity.elements)")

// Compare
if selectorA.specificity > selectorB.specificity {
    print("A wins")
}
```

## Attribute selectors

```swift
let attr: AttributeSelector = ...

print("Attribute: \(attr.name)")

if let op = attr.operation {
    switch op.operator {
    case .equal:       print("[attr=value]")
    case .includes:    print("[attr~=value]")
    case .dashMatch:   print("[attr|=value]")
    case .prefix:      print("[attr^=value]")
    case .suffix:      print("[attr$=value]")
    case .substring:   print("[attr*=value]")
    }

    if case .asciiCaseInsensitive = op.caseSensitivity {
        print("Case-insensitive")
    }
}
```
