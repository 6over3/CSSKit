# ``CSSKit``

Parse CSS into typed Swift structures.

## Overview

CSSKit turns CSS text into Swift types you can inspect and modify. It follows CSS Syntax Level 3.

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
        print(style.selectorText ?? "")
    }
}
```

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:ParsingCSS>

### Stylesheets

- <doc:WorkingWithStylesheets>
- ``CSSParser``
- ``Stylesheet``
- ``Rule``
- ``StyleRule``
- ``Declaration``

### Values

- <doc:CSSValues>
- ``Color``
- ``CSSLength``
- ``CSSAngle``
- ``CSSGradient``

### Selectors

- <doc:SelectorParsing>
- ``SelectorList``
- ``Selector``
- ``Component``
- ``SelectorSpecificity``

### At-rules

- <doc:CustomAtRules>
- ``MediaRule``
- ``SupportsRule``
- ``KeyframesRule``
- ``FontFaceRule``
- ``ContainerRule``

### Cascade

- ``CascadeWeight``
- ``CascadeResolver``
- ``CascadeOrigin``
- ``CSSPropertyId``
- ``CSSWideKeyword``
- ``CSSInitialValue``

### Serialization

- ``CSSSerializable``

### Source tracking

- ``SourceLocation``
