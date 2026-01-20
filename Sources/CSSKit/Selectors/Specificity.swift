// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// CSS selector specificity following the (a, b, c) model where:
/// - a = count of ID selectors
/// - b = count of class selectors, attribute selectors, and pseudo-classes
/// - c = count of type selectors and pseudo-elements
///
/// See: https://www.w3.org/TR/selectors/#specificity
public struct SelectorSpecificity: Equatable, Sendable, Hashable, Comparable {
    /// Count of ID selectors
    public var ids: UInt16

    /// Count of class selectors (.class), attribute selectors ([attr]), and pseudo-classes
    public var classes: UInt16

    /// Count of type selectors (div) and pseudo-elements
    public var elements: UInt16

    public init(ids: UInt16 = 0, classes: UInt16 = 0, elements: UInt16 = 0) {
        self.ids = ids
        self.classes = classes
        self.elements = elements
    }

    /// Zero specificity
    public static let zero = Self(ids: 0, classes: 0, elements: 0)

    /// Maximum value for each component
    private static let max10Bit: UInt32 = (1 << 10) - 1

    /// Packed 32-bit representation for efficient comparison.
    /// Format: [unused:2][ids:10][classes:10][elements:10]
    public var packed: UInt32 {
        let a = min(UInt32(ids), Self.max10Bit)
        let b = min(UInt32(classes), Self.max10Bit)
        let c = min(UInt32(elements), Self.max10Bit)
        return (a << 20) | (b << 10) | c
    }

    /// Creates specificity from a packed 32-bit value
    public init(packed: UInt32) {
        ids = UInt16((packed >> 20) & Self.max10Bit)
        classes = UInt16((packed >> 10) & Self.max10Bit)
        elements = UInt16(packed & Self.max10Bit)
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.packed < rhs.packed
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(
            ids: lhs.ids + rhs.ids,
            classes: lhs.classes + rhs.classes,
            elements: lhs.elements + rhs.elements
        )
    }

    public static func += (lhs: inout Self, rhs: Self) {
        lhs.ids += rhs.ids
        lhs.classes += rhs.classes
        lhs.elements += rhs.elements
    }

    /// Returns the maximum of two specificities
    public static func max(_ a: Self, _ b: Self) -> Self {
        a > b ? a : b
    }
}

extension SelectorSpecificity: CustomStringConvertible {
    public var description: String {
        "(\(ids),\(classes),\(elements))"
    }
}
