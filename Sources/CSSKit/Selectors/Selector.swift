// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A single CSS selector component (simple selector or combinator).
public indirect enum Component: Equatable, Sendable, Hashable {
    // MARK: - Combinators

    /// A combinator
    case combinator(Combinator)

    // MARK: - Namespace

    /// Explicit any namespace
    case explicitAnyNamespace

    /// Explicit no namespace
    case explicitNoNamespace

    /// Default namespace
    case defaultNamespace(String)

    /// Named namespace
    case namespace(prefix: String, url: String)

    // MARK: - Type selectors

    /// Universal selector
    case universal

    /// Type/element selector
    case type(String)

    // MARK: - Simple selectors

    /// ID selector
    case id(String)

    /// Class selector
    case `class`(String)

    /// Attribute selector
    case attribute(AttributeSelector)

    /// Pseudo-class (:hover, :nth-child(), etc.)
    case pseudoClass(PseudoClass)

    /// Pseudo-element
    case pseudoElement(PseudoElement)

    /// Nesting selector
    case nesting

    public var isCombinator: Bool {
        if case .combinator = self { return true }
        return false
    }

    public var asCombinator: Combinator? {
        if case let .combinator(c) = self { return c }
        return nil
    }

    /// The specificity contribution of this component
    public var specificity: SelectorSpecificity {
        switch self {
        case .combinator, .explicitAnyNamespace, .explicitNoNamespace,
             .defaultNamespace, .namespace, .universal, .nesting:
            return .zero

        case .id:
            return SelectorSpecificity(ids: 1, classes: 0, elements: 0)

        case .class, .attribute:
            return SelectorSpecificity(ids: 0, classes: 1, elements: 0)

        case let .pseudoClass(pc):
            switch pc {
            case .where:
                // :where() has zero specificity
                return .zero
            case .has:
                // :has() has zero specificity
                return .zero
            case let .not(selectors), let .is(selectors), let .any(_, selectors):
                // Specificity is the max of the selector list
                var maxSpec = SelectorSpecificity.zero
                for sel in selectors.selectors {
                    maxSpec = SelectorSpecificity.max(maxSpec, sel.specificity)
                }
                return maxSpec
            case let .nthOf(_, selectors):
                // Pseudo-class + max specificity of selectors
                var maxSpec = SelectorSpecificity.zero
                for sel in selectors.selectors {
                    maxSpec = SelectorSpecificity.max(maxSpec, sel.specificity)
                }
                return SelectorSpecificity(ids: 0, classes: 1, elements: 0) + maxSpec
            case let .host(selector):
                var spec = SelectorSpecificity(ids: 0, classes: 1, elements: 0)
                if let sel = selector {
                    spec += sel.specificity
                }
                return spec
            case let .hostContext(selector):
                return SelectorSpecificity(ids: 0, classes: 1, elements: 0) + selector.specificity
            default:
                return SelectorSpecificity(ids: 0, classes: 1, elements: 0)
            }

        case .type:
            return SelectorSpecificity(ids: 0, classes: 0, elements: 1)

        case let .pseudoElement(pe):
            switch pe {
            case let .slotted(selector):
                return SelectorSpecificity(ids: 0, classes: 0, elements: 1) + selector.specificity
            default:
                return SelectorSpecificity(ids: 0, classes: 0, elements: 1)
            }
        }
    }
}

// MARK: - Serialization

extension Component: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .combinator(c):
            c.serialize(dest: &dest)
        case .explicitAnyNamespace:
            dest.write("*|")
        case .explicitNoNamespace:
            dest.write("|")
        case .defaultNamespace:
            // Not serialized
            break
        case let .namespace(prefix, _):
            dest.write(prefix)
            dest.write("|")
        case .universal:
            dest.write("*")
        case let .type(name):
            dest.write(name)
        case let .id(name):
            dest.write("#")
            dest.write(name)
        case let .class(name):
            dest.write(".")
            dest.write(name)
        case let .attribute(attr):
            attr.serialize(dest: &dest)
        case let .pseudoClass(pc):
            pc.serialize(dest: &dest)
        case let .pseudoElement(pe):
            pe.serialize(dest: &dest)
        case .nesting:
            dest.write("&")
        }
    }
}

// MARK: - Selector

/// A CSS selector (sequence of components).
public struct Selector: Equatable, Sendable, Hashable {
    /// The components of this selector, stored in parse order
    public var components: [Component]

    public let specificity: SelectorSpecificity
    public let hasPseudoElement: Bool
    public let hasSlotted: Bool
    public let hasPart: Bool

    public init(components: [Component]) {
        self.components = components

        // Calculate specificity
        var spec = SelectorSpecificity.zero
        var hasPseudo = false
        var hasSlot = false
        var hasPrt = false

        for component in components {
            if case .combinator = component { continue }
            spec += component.specificity

            if case let .pseudoElement(pe) = component {
                hasPseudo = true
                if case .slotted = pe { hasSlot = true }
                if case .part = pe { hasPrt = true }
            }
        }

        specificity = spec
        hasPseudoElement = hasPseudo
        hasSlotted = hasSlot
        hasPart = hasPrt
    }

    public init(_ component: Component) {
        self.init(components: [component])
    }

    public var hasCombinator: Bool {
        components.contains { $0.isCombinator }
    }

    public var hasNesting: Bool {
        components.contains { if case .nesting = $0 { true } else { false } }
    }

    public var startsWithNesting: Bool {
        guard let first = components.first else { return false }
        if case .nesting = first { return true }
        return false
    }

    /// Prepends `&` with descendant combinator for implicit nesting.
    public func withNestingPrefix() -> Self {
        var newComponents = [Component.nesting, Component.combinator(.descendant)]
        newComponents.append(contentsOf: components)
        return Self(components: newComponents)
    }

    public var compoundSelectors: CompoundSelectorIterator {
        CompoundSelectorIterator(components: components)
    }

    public var text: String {
        var writer = StringCSSWriter()
        serialize(dest: &writer)
        return writer.result
    }
}

/// Iterator that yields compound selectors
public struct CompoundSelectorIterator: IteratorProtocol {
    private var components: ArraySlice<Component>

    init(components: [Component]) {
        self.components = components[...]
    }

    public mutating func next() -> (compound: [Component], combinator: Combinator?)? {
        guard !components.isEmpty else { return nil }

        var compound: [Component] = []
        var combinator: Combinator?

        while let component = components.first {
            components = components.dropFirst()
            if case let .combinator(c) = component {
                combinator = c
                break
            } else {
                compound.append(component)
            }
        }

        if compound.isEmpty, combinator == nil {
            return nil
        }

        return (compound, combinator)
    }
}

// MARK: - Selector Serialization

extension Selector: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        for component in components {
            component.serialize(dest: &dest)
        }
    }
}

// MARK: - SelectorList

/// A comma-separated list of selectors.
public struct SelectorList: Equatable, Sendable, Hashable {
    public var selectors: [Selector]

    public init(selectors: [Selector]) {
        self.selectors = selectors
    }

    public init(_ selector: Selector) {
        selectors = [selector]
    }

    public var maxSpecificity: SelectorSpecificity {
        selectors.reduce(.zero) { SelectorSpecificity.max($0, $1.specificity) }
    }

    public var isEmpty: Bool {
        selectors.isEmpty
    }

    public var hasNesting: Bool {
        selectors.contains { $0.hasNesting }
    }

    public func withNestingPrefix() -> Self {
        Self(selectors: selectors.map { $0.withNestingPrefix() })
    }

    public var text: String {
        var writer = StringCSSWriter()
        serialize(dest: &writer)
        return writer.result
    }
}

// MARK: - SelectorList Serialization

extension SelectorList: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        for (i, selector) in selectors.enumerated() {
            if i > 0 {
                dest.write(", ")
            }
            selector.serialize(dest: &dest)
        }
    }
}
