// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Transition Property ID

/// A property identifier used in `transition-property`.
/// Can be `none`, `all`, or a specific property ID.
public enum CSSTransitionPropertyId: Equatable, Sendable, Hashable {
    /// The `none` keyword - no properties will transition.
    case none
    /// The `all` keyword - all animatable properties will transition.
    case all
    /// A specific property, potentially with vendor prefix.
    case property(CSSPropertyId, CSSVendorPrefix)

    /// Creates a property ID without vendor prefix.
    public static func property(_ id: CSSPropertyId) -> Self {
        .property(id, .none)
    }

    /// Returns the vendor prefix, if any.
    public var prefix: CSSVendorPrefix {
        switch self {
        case .none, .all:
            .none
        case let .property(_, prefix):
            prefix
        }
    }

    /// Returns a copy with the given vendor prefix.
    public func withPrefix(_ prefix: CSSVendorPrefix) -> Self {
        switch self {
        case .none:
            .none
        case .all:
            .all
        case let .property(id, _):
            .property(id, prefix)
        }
    }
}

// MARK: - Transition

/// A single transition value for the `transition` shorthand property.
/// https://www.w3.org/TR/css-transitions-1/#transition-shorthand-property
public struct CSSTransition: Equatable, Sendable, Hashable {
    /// The property to transition.
    public var property: CSSTransitionPropertyId
    /// The duration of the transition.
    public var duration: CSSTime
    /// The delay before the transition starts.
    public var delay: CSSTime
    /// The easing function for the transition.
    public var timingFunction: CSSEasingFunction
    /// The vendor prefix for the transition property itself.
    public var vendorPrefix: CSSVendorPrefix

    public init(
        property: CSSTransitionPropertyId = .all,
        duration: CSSTime = .seconds(0),
        delay: CSSTime = .seconds(0),
        timingFunction: CSSEasingFunction = .ease,
        vendorPrefix: CSSVendorPrefix = .none
    ) {
        self.property = property
        self.duration = duration
        self.delay = delay
        self.timingFunction = timingFunction
        self.vendorPrefix = vendorPrefix
    }

    /// The default transition value.
    public static var `default`: Self {
        Self(property: .all, duration: .seconds(0), delay: .seconds(0), timingFunction: .ease, vendorPrefix: .none)
    }
}

/// A value for the `transition` property (list of transitions).
/// https://www.w3.org/TR/css-transitions-1/#transition-shorthand-property
public struct CSSTransitionList: Equatable, Sendable, Hashable {
    /// The list of transitions.
    public var transitions: [CSSTransition]
    /// The vendor prefix for this transition declaration.
    public var vendorPrefix: CSSVendorPrefix

    public init(transitions: [CSSTransition], vendorPrefix: CSSVendorPrefix = .none) {
        self.transitions = transitions
        self.vendorPrefix = vendorPrefix
    }

    /// Creates a transition list with the `none` value.
    public static func none(vendorPrefix: CSSVendorPrefix = .none) -> Self {
        Self(transitions: [], vendorPrefix: vendorPrefix)
    }

    /// The default value.
    public static var `default`: Self {
        Self(transitions: [], vendorPrefix: .none)
    }
}

// MARK: - View Transition Name

/// A value for the `view-transition-name` property.
/// https://drafts.csswg.org/css-view-transitions-1/#view-transition-name-prop
public enum CSSViewTransitionName: Equatable, Sendable, Hashable {
    /// The element will not participate independently in a view transition.
    case none
    /// The `auto` keyword.
    case auto
    /// A custom name.
    case custom(CSSCustomIdent)

    /// The default value (none).
    public static var `default`: Self { .none }
}

// MARK: - View Transition Group

/// A value for the `view-transition-group` property.
/// https://drafts.csswg.org/css-view-transitions-2/#view-transition-group-prop
public enum CSSViewTransitionGroup: Equatable, Sendable, Hashable {
    /// The `normal` keyword.
    case normal
    /// The `contain` keyword.
    case contain
    /// The `nearest` keyword.
    case nearest
    /// A custom group name.
    case custom(CSSCustomIdent)

    /// The default value (normal).
    public static var `default`: Self { .normal }
}

// MARK: - Parsing

extension CSSTransitionPropertyId {
    static func parse(_ input: Parser) -> Result<CSSTransitionPropertyId, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }
        if input.tryParse({ $0.expectIdentMatching("all") }).isOK {
            return .success(.all)
        }

        // Try to parse as a property ID
        if case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
            let name = ident.value
            let lowercased = name.lowercased()

            // Check for vendor prefixes
            var prefix = CSSVendorPrefix.none
            var propertyName = lowercased

            if lowercased.hasPrefix("-webkit-") {
                prefix = .webkit
                propertyName = String(lowercased.dropFirst(8))
            } else if lowercased.hasPrefix("-moz-") {
                prefix = .moz
                propertyName = String(lowercased.dropFirst(5))
            } else if lowercased.hasPrefix("-ms-") {
                prefix = .ms
                propertyName = String(lowercased.dropFirst(4))
            } else if lowercased.hasPrefix("-o-") {
                prefix = .o
                propertyName = String(lowercased.dropFirst(3))
            }

            // Parse property ID
            let propertyId = CSSPropertyId(propertyName)
            return .success(.property(propertyId, prefix))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSTransition {
    static func parse(_ input: Parser, vendorPrefix: CSSVendorPrefix = .none) -> Result<CSSTransition, BasicParseError> {
        var property: CSSTransitionPropertyId?
        var duration: CSSTime?
        var delay: CSSTime?
        var timingFunction: CSSEasingFunction?

        // Order doesn't matter (mostly), parse in any order
        // Note: duration must come before delay if both are times
        while true {
            if duration == nil {
                if case let .success(time) = input.tryParse({ CSSTime.parse($0) }) {
                    duration = time
                    continue
                }
            }

            if timingFunction == nil {
                if case let .success(easing) = input.tryParse({ CSSEasingFunction.parse($0) }) {
                    timingFunction = easing
                    continue
                }
            }

            if delay == nil, duration != nil {
                if case let .success(time) = input.tryParse({ CSSTime.parse($0) }) {
                    delay = time
                    continue
                }
            }

            if property == nil {
                if case let .success(prop) = input.tryParse({ CSSTransitionPropertyId.parse($0) }) {
                    property = prop
                    continue
                }
            }

            break
        }

        return .success(CSSTransition(
            property: property ?? .all,
            duration: duration ?? .seconds(0),
            delay: delay ?? .seconds(0),
            timingFunction: timingFunction ?? .ease,
            vendorPrefix: vendorPrefix
        ))
    }
}

extension CSSTransitionList {
    static func parse(_ input: Parser, vendorPrefix: CSSVendorPrefix = .none) -> Result<CSSTransitionList, BasicParseError> {
        // Try none keyword
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none(vendorPrefix: vendorPrefix))
        }

        // Parse comma-separated list of transitions
        var transitions: [CSSTransition] = []

        guard case let .success(first) = CSSTransition.parse(input, vendorPrefix: vendorPrefix) else {
            return .failure(input.newBasicError(.endOfInput))
        }
        transitions.append(first)

        while input.tryParse({ $0.expectComma() }).isOK {
            guard case let .success(transition) = CSSTransition.parse(input, vendorPrefix: vendorPrefix) else {
                return .failure(input.newBasicError(.endOfInput))
            }
            transitions.append(transition)
        }

        return .success(CSSTransitionList(transitions: transitions, vendorPrefix: vendorPrefix))
    }
}

extension CSSViewTransitionName {
    static func parse(_ input: Parser) -> Result<CSSViewTransitionName, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }
        if input.tryParse({ $0.expectIdentMatching("auto") }).isOK {
            return .success(.auto)
        }
        if case let .success(ident) = CSSCustomIdent.parse(input) {
            return .success(.custom(ident))
        }
        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSViewTransitionGroup {
    static func parse(_ input: Parser) -> Result<CSSViewTransitionGroup, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("normal") }).isOK {
            return .success(.normal)
        }
        if input.tryParse({ $0.expectIdentMatching("contain") }).isOK {
            return .success(.contain)
        }
        if input.tryParse({ $0.expectIdentMatching("nearest") }).isOK {
            return .success(.nearest)
        }
        if case let .success(ident) = CSSCustomIdent.parse(input) {
            return .success(.custom(ident))
        }
        return .failure(input.newBasicError(.endOfInput))
    }
}

// MARK: - ToCss

extension CSSTransitionPropertyId: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case .all:
            dest.write("all")
        case let .property(id, prefix):
            prefix.serialize(dest: &dest)
            id.serialize(dest: &dest)
        }
    }
}

extension CSSTransition: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        property.serialize(dest: &dest)

        let isZeroDuration = duration == .seconds(0) || duration == .milliseconds(0)
        let isZeroDelay = delay == .seconds(0) || delay == .milliseconds(0)

        if !isZeroDuration || !isZeroDelay {
            dest.write(" ")
            duration.serialize(dest: &dest)
        }

        if timingFunction != .ease {
            dest.write(" ")
            timingFunction.serialize(dest: &dest)
        }

        if !isZeroDelay {
            dest.write(" ")
            delay.serialize(dest: &dest)
        }
    }
}

extension CSSTransitionList: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if transitions.isEmpty {
            dest.write("none")
            return
        }

        var first = true
        for transition in transitions {
            if first {
                first = false
            } else {
                dest.write(", ")
            }
            transition.serialize(dest: &dest)
        }
    }
}

extension CSSViewTransitionName: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case .auto:
            dest.write("auto")
        case let .custom(ident):
            ident.serialize(dest: &dest)
        }
    }
}

extension CSSViewTransitionGroup: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .normal:
            dest.write("normal")
        case .contain:
            dest.write("contain")
        case .nearest:
            dest.write("nearest")
        case let .custom(ident):
            ident.serialize(dest: &dest)
        }
    }
}
