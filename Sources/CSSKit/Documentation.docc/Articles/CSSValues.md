# CSS values

Typed CSS values from parsed declarations.

## Property values

When you parse a stylesheet, declarations have typed `value` properties:

```swift
let parser = CSSParser(".box { color: red; margin: 10px; }")

for rule in parser.rules {
    if case .style(let style) = rule {
        for decl in style.declarations {
            switch decl.value {
            case .color(let color):
                print("Color: \(color)")
            case .margin(let margin):
                print("Margin: \(margin)")
            case .unparsed(let unparsed):
                print("Raw: \(unparsed.value)")
            default:
                break
            }
        }
    }
}
```

## Colors

CSSKit supports colors through Level 5:

```swift
// From declarations
if case .color(let color) = decl.value {
    switch color {
    case .oklch(let oklch):
        print("L: \(oklch.lightness), C: \(oklch.chroma), H: \(oklch.hue)")
    case .rgba(let rgba):
        print("RGB: \(rgba.red), \(rgba.green), \(rgba.blue)")
    case .named(let name, _):
        print("Named: \(name)")
    default:
        break
    }
}
```

Formats:
- Named colors (red, rebeccapurple)
- Hex (#rgb, #rrggbb, #rrggbbaa)
- rgb() and rgba()
- hsl() and hsla()
- hwb()
- lab() and lch()
- oklab() and oklch()
- color() with predefined color spaces
- color-mix()
- Relative color syntax

## Lengths

```swift
if case .width(let size) = decl.value,
   case .lengthPercentage(let lp) = size,
   case .length(let length) = lp {
    print("\(length.value)\(length.unit.rawValue)")
}
```

Units: px, em, rem, %, vw, vh, ch, and all others from CSS Values 4.

## calc() and math functions

```swift
if case .width(let size) = decl.value,
   case .lengthPercentage(let lp) = size,
   case .calc(let calc) = lp {
    print(calc)
}
```

Supported: calc(), min(), max(), clamp(), round(), mod(), rem(), abs(), sign(), and trig functions.

## Gradients

```swift
if case .backgroundImage(let img) = decl.value,
   case .gradient(let gradient) = img {
    switch gradient {
    case .linear(let linear):
        print("Linear with \(linear.items.count) stops")
    case .radial(let radial):
        print("Radial gradient")
    case .conic(let conic):
        print("Conic gradient")
    default:
        break
    }
}
```

## Raw value fallback

Unknown properties fall back to token lists:

```swift
if case .unparsed(let unparsed) = decl.value {
    print("Property: \(unparsed.propertyId)")
    print("Tokens: \(unparsed.value)")
}
```

## Serialization

Turn any value back to CSS:

```swift
var writer = StringCSSWriter()
decl.value.serialize(dest: &writer)
print(writer.result)
```
