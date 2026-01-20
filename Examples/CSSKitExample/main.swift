/// CSSKit + SwiftSoup: Style-Based HTML to Markdown
///
/// Converts non-semantic HTML to Markdown by resolving CSS styles.

import CSSKit
import SwiftSoup

// MARK: - ANSI

enum A {
    static let reset = "\u{001B}[0m"
    static let bold = "\u{001B}[1m"
    static let dim = "\u{001B}[2m"

    static let red = "\u{001B}[31m"
    static let green = "\u{001B}[32m"
    static let yellow = "\u{001B}[33m"
    static let blue = "\u{001B}[34m"
    static let magenta = "\u{001B}[35m"
    static let cyan = "\u{001B}[36m"
    static let white = "\u{001B}[37m"
    static let gray = "\u{001B}[90m"
}

// MARK: - Sample HTML

let html = """
<!DOCTYPE html>
<html>
<head>
<style>
.title { font-size: 2em; font-weight: bold; }
.section-header { font-size: 1.5em; font-weight: 700; }
.subheader { font-size: 1.2em; font-weight: 600; }
.emphasis { font-style: italic; }
.strong { font-weight: bold; }
.code { font-family: "Courier New", monospace; background: #f4f4f4; }
.quote { font-style: italic; border-left: 3px solid #ccc; padding-left: 1em; }
.link { text-decoration: underline; color: oklch(50% 0.2 250); }
.warning { font-weight: bold; font-style: italic; color: rgb(255, 150, 0); }
.muted { font-weight: 300; color: hsl(0, 0%, 50%); }
.highlight { background-color: yellow; font-weight: 600; }
.strike { text-decoration: line-through; }
.block { display: block; }
.codeblock { font-family: monospace; display: block; white-space: pre; }
div.block > span.strong { color: inherit; }
.link:hover { text-decoration: none; }
#main .content p:first-child { margin-top: 0; }
.emphasis { font-weight: 400; }
div .emphasis { font-weight: 500; }
.strong.emphasis { font-weight: 700; }
</style>
</head>
<body>
<div class="title">CSSKit Documentation</div>
<div class="muted block">A modern CSS parser for Swift</div>

<div class="section-header block">Getting Started</div>
<div class="block">CSSKit parses CSS into <span class="strong">typed structures</span>. It handles <span class="emphasis">modern CSS features</span> like <span class="code">oklch()</span> and <span class="code">color-mix()</span>.</div>

<div class="subheader block">Key Features</div>
<div class="block">The library provides <span class="strong">full selector parsing</span> with <span class="emphasis">specificity calculation</span> and <span class="strong emphasis">cascade resolution</span>.</div>

<div class="block">Some <span class="highlight">important text</span> and some <span class="strike">removed text</span> for variety.</div>

<div class="quote block">CSSKit follows the CSS specification for error recovery, making it robust for real-world stylesheets.</div>

<div class="block"><span class="warning">Note:</span> All formatting derived from CSS, not HTML tags.</div>

<div class="strong block">This parent is bold, and <span class="nested">this child inherits it</span> via cascade.</div>

<div class="block">See <span class="link" data-href="https://github.com/6over3/CSSKit">the repository</span> for source code.</div>

<div class="codeblock">let parser = CSSParser(css)
let rules = parser.stylesheet.rules
for rule in rules {
    print(rule)
}</div>
</body>
</html>
"""

// MARK: - Parsed Rule

struct ParsedRule {
    let selector: Selector
    let declarations: [Declaration]
    let order: Int
}

// MARK: - Style Resolver

struct StyleResolver {
    let rules: [ParsedRule]
    let cascadeResolver = CascadeResolver()

    init(cssRules: [DefaultRule]) {
        var parsed: [ParsedRule] = []
        var order = 0

        for rule in cssRules {
            guard case let .style(style) = rule,
                  let selectors = style.selectors else { continue }

            for selector in selectors.selectors {
                parsed.append(ParsedRule(
                    selector: selector,
                    declarations: style.declarations,
                    order: order
                ))
                order += 1
            }
        }

        rules = parsed
    }

    func matchingRules(for element: Element) -> [(ParsedRule, CascadeWeight)] {
        var matches: [(ParsedRule, CascadeWeight)] = []

        for rule in rules {
            let selectorText = rule.selector.text

            do {
                let selected = try element.ownerDocument()?.select(selectorText) ?? Elements()
                guard selected.contains(element) else { continue }

                let weight = CascadeWeight(
                    origin: .author,
                    specificity: rule.selector.specificity,
                    order: rule.order
                )
                matches.append((rule, weight))
            } catch {
                continue
            }
        }

        return matches
    }

    func resolveProperty(_ name: String, for element: Element, inherit: Bool = true) -> Declaration? {
        let matches = matchingRules(for: element)
        var candidates: [(value: Declaration, weight: CascadeWeight)] = []

        for (rule, weight) in matches {
            for decl in rule.declarations where decl.name == name {
                let declWeight = CascadeWeight(
                    origin: weight.origin,
                    isImportant: decl.isImportant,
                    specificity: weight.specificity,
                    order: weight.order
                )
                candidates.append((decl, declWeight))
            }
        }

        if let resolved = cascadeResolver.resolve(candidates) {
            return resolved
        }

        // Inherit from parent if property is inheritable
        if inherit,
           CSSPropertyId(name).inherits,
           let parent = element.parent(), parent.tagName() != "#root"
        {
            return resolveProperty(name, for: parent, inherit: true)
        }

        return nil
    }

    func isBold(_ element: Element) -> Bool {
        guard let decl = resolveProperty("font-weight", for: element) else {
            return false
        }

        switch decl.value {
        case let .fontWeight(fw):
            switch fw {
            case let .absolute(abs): return abs.numericValue >= 600
            case .bolder: return true
            case .lighter: return false
            }
        default:
            let raw = decl.rawValue.lowercased()
            return raw == "bold" || raw == "bolder" || (Int(raw) ?? 0) >= 600
        }
    }

    func isItalic(_ element: Element) -> Bool {
        guard let decl = resolveProperty("font-style", for: element) else {
            return false
        }
        let raw = decl.rawValue.lowercased()
        return raw == "italic" || raw == "oblique"
    }

    func isMonospace(_ element: Element) -> Bool {
        guard let decl = resolveProperty("font-family", for: element) else {
            return false
        }
        return decl.rawValue.lowercased().contains("monospace")
    }

    func isUnderline(_ element: Element) -> Bool {
        guard let decl = resolveProperty("text-decoration", for: element) else {
            return false
        }
        return decl.rawValue.lowercased().contains("underline")
    }

    func isStrikethrough(_ element: Element) -> Bool {
        guard let decl = resolveProperty("text-decoration", for: element) else {
            return false
        }
        return decl.rawValue.lowercased().contains("line-through")
    }

    func headingLevel(_ element: Element) -> Int? {
        guard let decl = resolveProperty("font-size", for: element) else {
            return nil
        }
        let raw = decl.rawValue.lowercased()
        if raw == "2em" { return 1 }
        if raw == "1.5em" { return 2 }
        if raw == "1.2em" { return 3 }
        return nil
    }

    func isBlockquote(_ element: Element) -> Bool {
        resolveProperty("border-left", for: element) != nil
    }

    func isCodeBlock(_ element: Element) -> Bool {
        guard let display = resolveProperty("display", for: element) else {
            return false
        }
        return display.rawValue == "block" && isMonospace(element)
    }
}

// MARK: - Markdown Converter

struct MarkdownConverter {
    let resolver: StyleResolver

    func convert(_ element: Element) throws -> String {
        var output = ""
        try convertElement(element, to: &output)
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func convertElement(_ element: Element, to output: inout String) throws {
        let tag = element.tagName().lowercased()

        if tag == "style" || tag == "head" { return }

        if tag == "body" || tag == "html" {
            try convertChildren(of: element, to: &output)
            return
        }

        if resolver.isCodeBlock(element) {
            output += "\n```\n"
            output += try element.text()
            output += "\n```\n"
            return
        }

        if let level = resolver.headingLevel(element), resolver.isBold(element) {
            output += "\n" + String(repeating: "#", count: level) + " "
            try convertChildrenInline(of: element, to: &output)
            output += "\n\n"
            return
        }

        if resolver.isBlockquote(element) {
            output += "> "
            try convertChildrenInline(of: element, to: &output)
            output += "\n\n"
            return
        }

        let bold = resolver.isBold(element)
        let italic = resolver.isItalic(element)
        let mono = resolver.isMonospace(element)
        let underline = resolver.isUnderline(element)
        let strike = resolver.isStrikethrough(element)
        let isBlock = tag == "div"

        if mono, !isBlock {
            output += "`"
            try convertChildrenInline(of: element, to: &output)
            output += "`"
        } else if strike {
            output += "~~"
            try convertChildren(of: element, to: &output)
            output += "~~"
        } else if underline {
            output += "["
            try convertChildren(of: element, to: &output)
            output += "]"
            if let href = try? element.attr("data-href"), !href.isEmpty {
                output += "(\(href))"
            }
        } else if bold, italic {
            output += "**_"
            try convertChildren(of: element, to: &output)
            output += "_**"
        } else if bold {
            output += "**"
            try convertChildren(of: element, to: &output)
            output += "**"
        } else if italic {
            output += "_"
            try convertChildren(of: element, to: &output)
            output += "_"
        } else {
            try convertChildren(of: element, to: &output)
        }

        if isBlock { output += "\n" }
    }

    private func convertChildren(of element: Element, to output: inout String) throws {
        for node in element.getChildNodes() {
            if let text = node as? TextNode {
                let content = text.getWholeText()
                if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    output += content
                }
            } else if let child = node as? Element {
                try convertElement(child, to: &output)
            }
        }
    }

    private func convertChildrenInline(of element: Element, to output: inout String) throws {
        for node in element.getChildNodes() {
            if let text = node as? TextNode {
                output += text.getWholeText()
            } else if let child = node as? Element {
                try convertElement(child, to: &output)
            }
        }
    }
}

// MARK: - Color Display

func colorString(_ decl: Declaration) -> String {
    switch decl.value {
    case let .color(color):
        color.string
    default:
        decl.rawValue
    }
}

// MARK: - Selector Component Display

func componentDescription(_ component: Component) -> String {
    switch component {
    case let .type(name):
        "type(\(name))"
    case let .class(name):
        "class(\(name))"
    case let .id(name):
        "id(\(name))"
    case let .attribute(attr):
        "attr(\(attr.name))"
    case let .pseudoClass(pc):
        ":\(pseudoClassName(pc))"
    case let .pseudoElement(pe):
        "::\(pseudoElementName(pe))"
    case let .combinator(c):
        switch c {
        case .descendant: "▸"
        case .child: ">"
        case .nextSibling: "+"
        case .laterSibling: "~"
        default: String(describing: c)
        }
    case .universal:
        "*"
    case .nesting:
        "&"
    default:
        "?"
    }
}

func pseudoClassName(_ pc: PseudoClass) -> String {
    switch pc {
    case .hover: return "hover"
    case .active: return "active"
    case .focus: return "focus"
    case .root: return "root"
    case .empty: return "empty"
    case let .nth(data):
        let typeName: String = switch data.type {
        case .child: data.a == 0 && data.b == 1 ? "first-child" : "nth-child"
        case .lastChild: data.a == 0 && data.b == 1 ? "last-child" : "nth-last-child"
        case .onlyChild: "only-child"
        case .ofType: data.a == 0 && data.b == 1 ? "first-of-type" : "nth-of-type"
        case .lastOfType: data.a == 0 && data.b == 1 ? "last-of-type" : "nth-last-of-type"
        case .onlyOfType: "only-of-type"
        case .col: "nth-col"
        case .lastCol: "nth-last-col"
        }
        if data.a == 0, data.b == 1 {
            return typeName
        }
        return "\(typeName)(\(data.a)n+\(data.b))"
    case .not: return "not(...)"
    case .is: return "is(...)"
    case .where: return "where(...)"
    default:
        let str = String(describing: pc)
        return str.components(separatedBy: "(").first ?? "?"
    }
}

func pseudoElementName(_ pe: PseudoElement) -> String {
    switch pe {
    case .before: return "before"
    case .after: return "after"
    case .firstLine: return "first-line"
    case .firstLetter: return "first-letter"
    case .selection: return "selection"
    case .placeholder: return "placeholder"
    default:
        let str = String(describing: pe)
        return str.components(separatedBy: "(").first ?? "?"
    }
}

// MARK: - Main

do {
    print()
    print("\(A.bold)\(A.magenta)CSSKit\(A.reset) Style Resolution Demo")
    print("\(A.gray)Converting non-semantic HTML to Markdown via CSS\(A.reset)")
    print()

    let document = try SwiftSoup.parse(html)

    var allRules: [DefaultRule] = []
    for style in try document.select("style") {
        let css = try style.html()
        allRules.append(contentsOf: CSSParser(css).rules)
    }

    let resolver = StyleResolver(cssRules: allRules)

    // Style resolution table
    print("\(A.bold)Style Resolution\(A.reset)")
    print()
    print("  \(A.gray)CLASS            RESOLVED → MARKDOWN\(A.reset)")

    let testClasses = [
        ("title", "# heading"),
        ("section-header", "## heading"),
        ("subheader", "### heading"),
        ("strong", "**bold**"),
        ("emphasis", "_italic_"),
        ("code", "`code`"),
        ("quote", "> blockquote"),
        ("link", "[link](url)"),
        ("warning", "**_bold italic_**"),
        ("strike", "~~strikethrough~~"),
        ("highlight", "**bold**"),
    ]

    for (cls, md) in testClasses {
        guard let el = try document.select(".\(cls)").first() else { continue }

        var styles: [String] = []
        if resolver.isBold(el) { styles.append("bold") }
        if resolver.isItalic(el) { styles.append("italic") }
        if resolver.isMonospace(el) { styles.append("mono") }
        if resolver.isUnderline(el) { styles.append("underline") }
        if resolver.isStrikethrough(el) { styles.append("strike") }
        if let h = resolver.headingLevel(el) { styles.append("h\(h)") }
        if resolver.isBlockquote(el) { styles.append("quote") }

        let styleStr = styles.joined(separator: "+")
        print("  \(A.cyan).\(cls.padding(toLength: 15, withPad: " ", startingAt: 0))\(A.reset) \(styleStr.padding(toLength: 14, withPad: " ", startingAt: 0)) → \(A.green)\(md)\(A.reset)")
    }

    // Selector parsing
    print()
    print("\(A.bold)Selector Parsing\(A.reset)")
    print()

    let interestingSelectors = resolver.rules.filter { rule in
        let text = rule.selector.text
        return text.contains(">") || text.contains(":") || text.contains("#") || text.contains(" ")
    }.prefix(4)

    let simpleSelectors = resolver.rules.filter { rule in
        let text = rule.selector.text
        return !text.contains(">") && !text.contains(":") && !text.contains("#") && !text.contains(" ")
    }.prefix(3)

    for rule in Array(simpleSelectors) + Array(interestingSelectors) {
        let sel = rule.selector
        let spec = sel.specificity

        var parts: [String] = []
        for component in sel.components {
            parts.append(componentDescription(component))
        }
        let desc = parts.joined(separator: " ")

        print("  \(A.cyan)\(sel.text.padding(toLength: 28, withPad: " ", startingAt: 0))\(A.reset)")
        print("    \(A.dim)components:\(A.reset) \(desc)")
        print("    \(A.yellow)specificity: (\(spec.ids),\(spec.classes),\(spec.elements))\(A.reset)")
        print()
    }

    // Color parsing
    print()
    print("\(A.bold)Color Parsing\(A.reset)")
    print()

    let colorClasses = ["link", "warning", "muted"]
    for cls in colorClasses {
        guard let el = try document.select(".\(cls)").first(),
              let decl = resolver.resolveProperty("color", for: el) else { continue }
        print("  \(A.cyan).\(cls.padding(toLength: 10, withPad: " ", startingAt: 0))\(A.reset) color: \(A.yellow)\(colorString(decl))\(A.reset)")
    }

    // Cascade visualization
    print()
    print("\(A.bold)Cascade Resolution\(A.reset)")
    print()

    // Show cascade for an element with multiple matching rules
    if let el = try document.select(".strong.emphasis").first() {
        print("  \(A.cyan)<span class=\"strong emphasis\">\(A.reset)")
        print()

        // Group declarations by property
        let matches = resolver.matchingRules(for: el)
        var byProperty: [String: [(decl: Declaration, weight: CascadeWeight, selector: String)]] = [:]

        for (rule, weight) in matches {
            for decl in rule.declarations {
                let declWeight = CascadeWeight(
                    origin: weight.origin,
                    isImportant: decl.isImportant,
                    specificity: weight.specificity,
                    order: weight.order
                )
                byProperty[decl.name, default: []].append((decl, declWeight, rule.selector.text))
            }
        }

        // Show each property's cascade
        for (property, candidates) in byProperty.sorted(by: { $0.key < $1.key }) {
            let sorted = candidates.sorted { $0.weight < $1.weight }

            print("  \(A.white)\(property)\(A.reset)")
            for (i, candidate) in sorted.enumerated() {
                let spec = candidate.weight.specificity
                let isWinner = i == sorted.count - 1
                let prefix = isWinner ? "\(A.green)✓\(A.reset)" : "\(A.dim)│\(A.reset)"
                let value = isWinner ? "\(A.green)\(candidate.decl.rawValue)\(A.reset)" : "\(A.dim)\(candidate.decl.rawValue)\(A.reset)"
                let specStr = "(\(spec.ids),\(spec.classes),\(spec.elements))"
                print("    \(prefix) \(A.yellow)\(specStr)\(A.reset) \(candidate.selector.padding(toLength: 12, withPad: " ", startingAt: 0)) → \(value)")
            }
            print()
        }
    }

    // Inheritance visualization
    print("\(A.bold)Style Inheritance\(A.reset)")
    print()

    if let nested = try document.select(".nested").first() {
        print("  \(A.cyan)<span class=\"nested\">\(A.reset) inside \(A.cyan)<div class=\"strong\">\(A.reset)")
        print()

        let directMatches = resolver.matchingRules(for: nested)
        print("  \(A.dim)Direct rules: \(directMatches.count)\(A.reset)")

        // Show inheritance chain for font-weight
        print("  \(A.white)font-weight\(A.reset) inheritance chain:")

        var current: Element? = nested
        var depth = 0
        while let el = current {
            let indent = String(repeating: "  ", count: depth + 2)
            let tag = el.tagName()
            let cls = (try? el.className()) ?? ""
            let label = cls.isEmpty ? "<\(tag)>" : "<\(tag) class=\"\(cls)\">"

            let directFW = resolver.matchingRules(for: el).flatMap { rule, weight in
                rule.declarations.filter { $0.name == "font-weight" }.map { ($0, weight, rule.selector.text) }
            }

            if let (decl, _, sel) = directFW.first {
                print("\(indent)\(A.green)●\(A.reset) \(A.cyan)\(label)\(A.reset)")
                print("\(indent)  └─ \(sel): \(A.green)\(decl.rawValue)\(A.reset)")
                break
            } else {
                print("\(indent)\(A.dim)○\(A.reset) \(A.cyan)\(label)\(A.reset) \(A.dim)(no font-weight)\(A.reset)")
            }

            current = el.parent()
            depth += 1
            if depth > 5 || tag == "body" { break }
        }

        if let fw = resolver.resolveProperty("font-weight", for: nested) {
            print()
            print("  \(A.green)→\(A.reset) Resolved: font-weight = \(A.white)\(fw.rawValue)\(A.reset)")
        }
    }

    // Markdown output
    print()
    print("\(A.bold)Markdown Output\(A.reset)")
    print()

    let body = document.body() ?? document
    let converter = MarkdownConverter(resolver: resolver)
    let markdown = try converter.convert(body)

    for line in markdown.split(separator: "\n", omittingEmptySubsequences: false) {
        print("  \(A.white)\(line)\(A.reset)")
    }

    print()
    print("\(A.gray)─────────────────────────────────────────────────────────\(A.reset)")
    print("\(A.green)✓\(A.reset) \(resolver.rules.count) CSS rules parsed")
    print("\(A.green)✓\(A.reset) All formatting derived from CSS styles, not HTML tags")
    print()

} catch {
    print("\(A.red)Error:\(A.reset) \(error)")
}
