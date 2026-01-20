// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// CSS selector combinators that define relationships between elements.
public enum Combinator: Equatable, Sendable, Hashable {
    /// Child combinator (>): selects direct children
    case child

    /// Descendant combinator (space): selects any descendant
    case descendant

    /// Next-sibling combinator (+): selects immediately following sibling
    case nextSibling

    /// Subsequent-sibling combinator (~): selects any following sibling
    case laterSibling

    /// Internal combinator for pseudo-elements
    case pseudoElement

    /// Internal combinator for ::slotted()
    case slotAssignment

    /// Internal combinator for ::part()
    case part

    /// Non-standard Vue >>> deep descendant combinator
    case deepDescendant

    /// Non-standard /deep/ combinator
    case deep

    /// Whether this is an ancestor combinator
    public var isAncestor: Bool {
        switch self {
        case .child, .descendant, .pseudoElement, .slotAssignment:
            true
        default:
            false
        }
    }

    /// Whether this is a sibling combinator
    public var isSibling: Bool {
        switch self {
        case .nextSibling, .laterSibling:
            true
        default:
            false
        }
    }

    /// Whether this is a standard tree combinator
    public var isTreeCombinator: Bool {
        switch self {
        case .child, .descendant, .nextSibling, .laterSibling:
            true
        default:
            false
        }
    }
}

// MARK: - Serialization

extension Combinator: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .child:
            dest.write(" > ")
        case .descendant:
            dest.write(" ")
        case .nextSibling:
            dest.write(" + ")
        case .laterSibling:
            dest.write(" ~ ")
        case .pseudoElement, .slotAssignment, .part:
            // Internal combinators - not serialized
            break
        case .deepDescendant:
            dest.write(" >>> ")
        case .deep:
            dest.write(" /deep/ ")
        }
    }
}
