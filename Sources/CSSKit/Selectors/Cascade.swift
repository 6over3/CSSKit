// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Cascade Origin

/// The origin of a CSS rule in the cascade.
public enum CascadeOrigin: Int, Comparable, Sendable {
    case userAgent = 0
    case user = 1
    case author = 2

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Cascade Layer

public struct CascadeLayer: Equatable, Sendable, Hashable {
    public let parts: [String]
    public let order: Int

    public init(parts: [String], order: Int) {
        self.parts = parts
        self.order = order
    }

    public static let implicit = Self(parts: [], order: Int.max)

    public var name: String {
        parts.joined(separator: ".")
    }
}

// MARK: - Cascade Weight

public struct CascadeWeight: Comparable, Sendable {
    public let origin: CascadeOrigin
    public let isImportant: Bool
    public let isInlineStyle: Bool
    public let layer: CascadeLayer?
    public let specificity: SelectorSpecificity
    public let order: Int

    public init(
        origin: CascadeOrigin = .author,
        isImportant: Bool = false,
        isInlineStyle: Bool = false,
        layer: CascadeLayer? = nil,
        specificity: SelectorSpecificity = .zero,
        order: Int = 0
    ) {
        self.origin = origin
        self.isImportant = isImportant
        self.isInlineStyle = isInlineStyle
        self.layer = layer
        self.specificity = specificity
        self.order = order
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        let lhsOriginScore = lhs.effectiveOriginScore
        let rhsOriginScore = rhs.effectiveOriginScore
        if lhsOriginScore != rhsOriginScore {
            return lhsOriginScore < rhsOriginScore
        }

        if lhs.isInlineStyle != rhs.isInlineStyle {
            return !lhs.isInlineStyle
        }

        let lhsLayerScore = lhs.layerScore
        let rhsLayerScore = rhs.layerScore
        if lhsLayerScore != rhsLayerScore {
            return lhsLayerScore < rhsLayerScore
        }

        if lhs.specificity != rhs.specificity {
            return lhs.specificity < rhs.specificity
        }

        return lhs.order < rhs.order
    }

    private var effectiveOriginScore: Int {
        if isImportant {
            3 + (2 - origin.rawValue)
        } else {
            origin.rawValue
        }
    }

    private var layerScore: Int {
        guard let layer else {
            return Int.max
        }
        if isImportant {
            return -layer.order
        } else {
            return layer.order
        }
    }
}

// MARK: - Cascade Resolver

public struct CascadeResolver {
    public init() {}

    public func resolve<T>(_ candidates: [(value: T, weight: CascadeWeight)]) -> T? {
        candidates.max(by: { $0.weight < $1.weight })?.value
    }

    public func sorted<T>(_ candidates: [(value: T, weight: CascadeWeight)]) -> [(value: T, weight: CascadeWeight)] {
        candidates.sorted(by: { $0.weight < $1.weight })
    }
}
