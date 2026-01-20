// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Nesting Requirement

/// Requirements for the nesting selector (&) in selectors.
public enum NestingRequirement: Equatable, Sendable {
    /// No nesting requirement - standard top-level selectors.
    case none

    /// Selector must explicitly start with & (deprecated @nest rule).
    /// Parser will raise error if & is not at the start.
    case prefixed

    /// Selector must contain & somewhere (deprecated @nest rule).
    /// Less strict than prefixed - & can be anywhere.
    case contained

    /// Implicit nesting - if no & is written, one is automatically
    /// prepended with a descendant combinator.
    /// Used for nested style rules: `div { .child { } }` becomes `div { & .child { } }`
    case implicit
}

// MARK: - Parsing State

/// Parsing state flags for tracking selector parsing context.
struct SelectorParsingState: OptionSet, Sendable {
    let rawValue: UInt16

    init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    // MARK: - Pseudo-element tracking

    /// After any pseudo-element
    static let afterPseudoElement = Self(rawValue: 1 << 0)

    /// After ::slotted()
    static let afterSlotted = Self(rawValue: 1 << 1)

    /// After ::part()
    static let afterPart = Self(rawValue: 1 << 2)

    /// After a WebKit scrollbar pseudo-element
    static let afterWebkitScrollbar = Self(rawValue: 1 << 3)

    /// After a view transition pseudo-element
    static let afterViewTransition = Self(rawValue: 1 << 4)

    // MARK: - Other state

    /// After nesting selector
    static let afterNesting = Self(rawValue: 1 << 5)

    /// Parsing inside :has() - relative selectors allowed
    static let insideHas = Self(rawValue: 1 << 6)

    /// Currently parsing a relative selector
    static let parsingRelative = Self(rawValue: 1 << 7)

    // MARK: - Computed properties

    /// Whether pseudo-classes are allowed in current state.
    var allowsPseudoClasses: Bool {
        // After most pseudo-elements, no pseudo-classes allowed
        // Exception: webkit scrollbar pseudo-elements accept state pseudo-classes
        if contains(.afterPseudoElement), !contains(.afterWebkitScrollbar), !contains(.afterViewTransition) {
            return false
        }
        return true
    }

    /// Whether we're in a context that allows relative selectors.
    var allowsRelativeSelectors: Bool {
        contains(.insideHas)
    }
}

// MARK: - CSS2 Pseudo-Elements

/// CSS2 pseudo-elements that can use single-colon syntax for backward compatibility.
private let css2PseudoElements: Set<String> = [
    "before", "after", "first-line", "first-letter",
]

/// Check if a name is a CSS2 pseudo-element (allows single-colon syntax).
public func isCSS2PseudoElement(_ name: String) -> Bool {
    css2PseudoElements.contains(name.lowercased())
}
