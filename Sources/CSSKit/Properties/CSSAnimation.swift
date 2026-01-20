// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Animation Name

/// A value for the `animation-name` property.
/// https://drafts.csswg.org/css-animations/#animation-name
public enum CSSAnimationName: Equatable, Sendable, Hashable {
    /// The `none` keyword.
    case none
    /// An identifier of a `@keyframes` rule.
    case ident(CSSCustomIdent)
    /// A `<string>` name of a `@keyframes` rule.
    case string(CSSString)

    /// The default value (none).
    public static var `default`: Self { .none }
}

// MARK: - Animation Iteration Count

/// A value for the `animation-iteration-count` property.
/// https://drafts.csswg.org/css-animations/#animation-iteration-count
public enum CSSAnimationIterationCount: Equatable, Sendable, Hashable {
    /// The animation will repeat the specified number of times.
    case number(Double)
    /// The animation will repeat forever.
    case infinite

    /// The default value (1).
    public static var `default`: Self { .number(1.0) }
}

// MARK: - Animation Direction

/// A value for the `animation-direction` property.
/// https://drafts.csswg.org/css-animations/#animation-direction
public enum CSSAnimationDirection: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The animation is played as specified.
    case normal
    /// The animation is played in reverse.
    case reverse
    /// The animation iterations alternate between forward and reverse.
    case alternate
    /// The animation iterations alternate between forward and reverse, with reverse occurring first.
    case alternateReverse = "alternate-reverse"

    /// The default value (normal).
    public static var `default`: Self { .normal }
}

// MARK: - Animation Play State

/// A value for the `animation-play-state` property.
/// https://drafts.csswg.org/css-animations/#animation-play-state
public enum CSSAnimationPlayState: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The animation is playing.
    case running
    /// The animation is paused.
    case paused

    /// The default value (running).
    public static var `default`: Self { .running }
}

// MARK: - Animation Fill Mode

/// A value for the `animation-fill-mode` property.
/// https://drafts.csswg.org/css-animations/#animation-fill-mode
public enum CSSAnimationFillMode: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The animation has no effect while not playing.
    case none
    /// After the animation, the ending values are applied.
    case forwards
    /// Before the animation, the starting values are applied.
    case backwards
    /// Both forwards and backwards apply.
    case both

    /// The default value (none).
    public static var `default`: Self { .none }
}

// MARK: - Animation Composition

/// A value for the `animation-composition` property.
/// https://drafts.csswg.org/css-animations-2/#animation-composition
public enum CSSAnimationComposition: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The result of compositing the effect value with the underlying value is simply the effect value.
    case replace
    /// The effect value is added to the underlying value.
    case add
    /// The effect value is accumulated onto the underlying value.
    case accumulate

    /// The default value (replace).
    public static var `default`: Self { .replace }
}

// MARK: - Scroller

/// A scroller, used in the `scroll()` function.
/// https://drafts.csswg.org/scroll-animations-1/#scroll-notation
public enum CSSScroller: String, Equatable, Sendable, Hashable, CaseIterable {
    /// Specifies to use the document viewport as the scroll container.
    case root
    /// Specifies to use the nearest ancestor scroll container.
    case nearest
    /// Specifies to use the element's own principal box as the scroll container.
    case `self`

    /// The default value (nearest).
    public static var `default`: Self { .nearest }
}

// MARK: - Scroll Axis

/// A scroll axis, used in the `scroll()` function.
/// https://drafts.csswg.org/scroll-animations-1/#scroll-notation
public enum CSSScrollAxis: String, Equatable, Sendable, Hashable, CaseIterable {
    /// Specifies to use the measure of progress along the block axis of the scroll container.
    case block
    /// Specifies to use the measure of progress along the inline axis of the scroll container.
    case inline
    /// Specifies to use the measure of progress along the horizontal axis of the scroll container.
    case x
    /// Specifies to use the measure of progress along the vertical axis of the scroll container.
    case y

    /// The default value (block).
    public static var `default`: Self { .block }
}

// MARK: - Scroll Timeline

/// The `scroll()` function.
/// https://drafts.csswg.org/scroll-animations-1/#scroll-notation
public struct CSSScrollTimeline: Equatable, Sendable, Hashable {
    /// Specifies which element to use as the scroll container.
    public var scroller: CSSScroller
    /// Specifies which axis of the scroll container to use as the progress for the timeline.
    public var axis: CSSScrollAxis

    public init(scroller: CSSScroller = .nearest, axis: CSSScrollAxis = .block) {
        self.scroller = scroller
        self.axis = axis
    }

    /// The default value.
    public static var `default`: Self {
        Self(scroller: .nearest, axis: .block)
    }
}

// MARK: - View Timeline

/// The `view()` function.
/// https://drafts.csswg.org/scroll-animations-1/#view-notation
public struct CSSViewTimeline: Equatable, Sendable, Hashable {
    /// Specifies which axis of the scroll container to use as the progress for the timeline.
    public var axis: CSSScrollAxis
    /// Provides an adjustment of the view progress visibility range.
    public var inset: CSSSize2D<CSSLengthPercentageOrAuto>

    public init(axis: CSSScrollAxis = .block, inset: CSSSize2D<CSSLengthPercentageOrAuto> = CSSSize2D(width: .auto, height: .auto)) {
        self.axis = axis
        self.inset = inset
    }

    /// The default value.
    public static var `default`: Self {
        Self(axis: .block, inset: CSSSize2D(width: .auto, height: .auto))
    }
}

// MARK: - Animation Timeline

/// A value for the `animation-timeline` property.
/// https://drafts.csswg.org/css-animations-2/#animation-timeline
public enum CSSAnimationTimeline: Equatable, Sendable, Hashable {
    /// The animation's timeline is a DocumentTimeline, more specifically the default document timeline.
    case auto
    /// The animation is not associated with a timeline.
    case none
    /// A timeline referenced by name.
    case dashedIdent(CSSDashedIdent)
    /// The `scroll()` function.
    case scroll(CSSScrollTimeline)
    /// The `view()` function.
    case view(CSSViewTimeline)

    /// The default value (auto).
    public static var `default`: Self { .auto }
}

// MARK: - Timeline Range Name

/// A view progress timeline range.
/// https://drafts.csswg.org/scroll-animations/#view-timelines-ranges
public enum CSSTimelineRangeName: String, Equatable, Sendable, Hashable, CaseIterable {
    /// Represents the full range of the view progress timeline.
    case cover
    /// Represents the range during which the principal box is either fully contained by,
    /// or fully covers, its view progress visibility range within the scrollport.
    case contain
    /// Represents the range during which the principal box is entering the view progress visibility range.
    case entry
    /// Represents the range during which the principal box is exiting the view progress visibility range.
    case exit
    /// Represents the range during which the principal box crosses the end border edge.
    case entryCrossing = "entry-crossing"
    /// Represents the range during which the principal box crosses the start border edge.
    case exitCrossing = "exit-crossing"
}

// MARK: - Animation Attachment Range

/// A value for the `animation-range-start` or `animation-range-end` property.
/// https://drafts.csswg.org/scroll-animations/#animation-range-start
public enum CSSAnimationAttachmentRange: Equatable, Sendable, Hashable {
    /// The start of the animation's attachment range is the start of its associated timeline.
    case normal
    /// The animation attachment range starts at the specified point on the timeline measuring from the start of the timeline.
    case lengthPercentage(CSSLengthPercentage)
    /// The animation attachment range starts at the specified point on the timeline measuring from the start of the specified named timeline range.
    case timelineRange(name: CSSTimelineRangeName, offset: CSSLengthPercentage)

    /// The default value (normal).
    public static var `default`: Self { .normal }
}

// MARK: - Animation Range Start

/// A value for the `animation-range-start` property.
/// https://drafts.csswg.org/scroll-animations/#animation-range-start
public struct CSSAnimationRangeStart: Equatable, Sendable, Hashable {
    public var range: CSSAnimationAttachmentRange

    public init(_ range: CSSAnimationAttachmentRange = .normal) {
        self.range = range
    }

    /// The default value.
    public static var `default`: Self { Self(.normal) }
}

// MARK: - Animation Range End

/// A value for the `animation-range-end` property.
/// https://drafts.csswg.org/scroll-animations/#animation-range-end
public struct CSSAnimationRangeEnd: Equatable, Sendable, Hashable {
    public var range: CSSAnimationAttachmentRange

    public init(_ range: CSSAnimationAttachmentRange = .normal) {
        self.range = range
    }

    /// The default value.
    public static var `default`: Self { Self(.normal) }
}

// MARK: - Animation Range

/// A value for the `animation-range` shorthand property.
/// https://drafts.csswg.org/scroll-animations/#animation-range
public struct CSSAnimationRange: Equatable, Sendable, Hashable {
    /// The start of the animation's attachment range.
    public var start: CSSAnimationRangeStart
    /// The end of the animation's attachment range.
    public var end: CSSAnimationRangeEnd

    public init(start: CSSAnimationRangeStart = .default, end: CSSAnimationRangeEnd = .default) {
        self.start = start
        self.end = end
    }

    /// The default value.
    public static var `default`: Self {
        Self(start: .default, end: .default)
    }
}

// MARK: - Animation

/// A single animation value for the `animation` shorthand property.
/// https://drafts.csswg.org/css-animations/#animation
public struct CSSAnimation: Equatable, Sendable, Hashable {
    /// The animation name.
    public var name: CSSAnimationName
    /// The animation duration.
    public var duration: CSSTime
    /// The easing function for the animation.
    public var timingFunction: CSSEasingFunction
    /// The number of times the animation will run.
    public var iterationCount: CSSAnimationIterationCount
    /// The direction of the animation.
    public var direction: CSSAnimationDirection
    /// The current play state of the animation.
    public var playState: CSSAnimationPlayState
    /// The animation delay.
    public var delay: CSSTime
    /// The animation fill mode.
    public var fillMode: CSSAnimationFillMode
    /// The animation timeline.
    public var timeline: CSSAnimationTimeline

    public init(
        name: CSSAnimationName = .none,
        duration: CSSTime = .seconds(0),
        timingFunction: CSSEasingFunction = .ease,
        iterationCount: CSSAnimationIterationCount = .number(1.0),
        direction: CSSAnimationDirection = .normal,
        playState: CSSAnimationPlayState = .running,
        delay: CSSTime = .seconds(0),
        fillMode: CSSAnimationFillMode = .none,
        timeline: CSSAnimationTimeline = .auto
    ) {
        self.name = name
        self.duration = duration
        self.timingFunction = timingFunction
        self.iterationCount = iterationCount
        self.direction = direction
        self.playState = playState
        self.delay = delay
        self.fillMode = fillMode
        self.timeline = timeline
    }

    /// The default animation value.
    public static var `default`: Self {
        Self()
    }
}

// MARK: - Animation List

/// A list of animations for the `animation` shorthand property.
public struct CSSAnimationList: Equatable, Sendable, Hashable {
    /// The list of animations.
    public var animations: [CSSAnimation]

    public init(animations: [CSSAnimation] = []) {
        self.animations = animations
    }

    /// The default value.
    public static var `default`: Self {
        Self(animations: [])
    }
}

// MARK: - Parsing

extension CSSAnimationName {
    static func parse(_ input: Parser) -> Result<CSSAnimationName, BasicParseError> {
        // Try none keyword
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        // Try string
        if case let .success(str) = input.tryParse({ CSSString.parse($0) }) {
            return .success(.string(str))
        }

        // Try ident
        if case let .success(ident) = CSSCustomIdent.parse(input) {
            return .success(.ident(ident))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSAnimationIterationCount {
    static func parse(_ input: Parser) -> Result<CSSAnimationIterationCount, BasicParseError> {
        // Try infinite keyword
        if input.tryParse({ $0.expectIdentMatching("infinite") }).isOK {
            return .success(.infinite)
        }

        // Try number
        if case let .success(num) = input.tryParse({ $0.expectNumber() }) {
            return .success(.number(num))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSAnimationDirection {
    static func parse(_ input: Parser) -> Result<CSSAnimationDirection, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "normal": return .success(.normal)
        case "reverse": return .success(.reverse)
        case "alternate": return .success(.alternate)
        case "alternate-reverse": return .success(.alternateReverse)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSAnimationPlayState {
    static func parse(_ input: Parser) -> Result<CSSAnimationPlayState, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "running": return .success(.running)
        case "paused": return .success(.paused)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSAnimationFillMode {
    static func parse(_ input: Parser) -> Result<CSSAnimationFillMode, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "none": return .success(.none)
        case "forwards": return .success(.forwards)
        case "backwards": return .success(.backwards)
        case "both": return .success(.both)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSAnimationComposition {
    static func parse(_ input: Parser) -> Result<CSSAnimationComposition, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "replace": return .success(.replace)
        case "add": return .success(.add)
        case "accumulate": return .success(.accumulate)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSScroller {
    static func parse(_ input: Parser) -> Result<CSSScroller, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "root": return .success(.root)
        case "nearest": return .success(.nearest)
        case "self": return .success(.self)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSScrollAxis {
    static func parse(_ input: Parser) -> Result<CSSScrollAxis, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "block": return .success(.block)
        case "inline": return .success(.inline)
        case "x": return .success(.x)
        case "y": return .success(.y)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSScrollTimeline {
    static func parse(_ input: Parser) -> Result<CSSScrollTimeline, BasicParseError> {
        guard input.expectFunctionMatching("scroll").isOK else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let result: Result<CSSScrollTimeline, ParseError<Never>> = input.parseNestedBlock { args in
            var scroller: CSSScroller?
            var axis: CSSScrollAxis?

            while true {
                if scroller == nil {
                    if case let .success(s) = args.tryParse({ CSSScroller.parse($0) }) {
                        scroller = s
                        continue
                    }
                }

                if axis == nil {
                    if case let .success(a) = args.tryParse({ CSSScrollAxis.parse($0) }) {
                        axis = a
                        continue
                    }
                }

                break
            }

            return .success(CSSScrollTimeline(
                scroller: scroller ?? .nearest,
                axis: axis ?? .block
            ))
        }

        switch result {
        case let .success(timeline):
            return .success(timeline)
        case let .failure(error):
            return .failure(error.basic)
        }
    }
}

extension CSSViewTimeline {
    static func parse(_ input: Parser) -> Result<CSSViewTimeline, BasicParseError> {
        guard input.expectFunctionMatching("view").isOK else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let result: Result<CSSViewTimeline, ParseError<Never>> = input.parseNestedBlock { args in
            var axis: CSSScrollAxis?
            var inset: CSSSize2D<CSSLengthPercentageOrAuto>?

            while true {
                if axis == nil {
                    if case let .success(a) = args.tryParse({ CSSScrollAxis.parse($0) }) {
                        axis = a
                        continue
                    }
                }

                if inset == nil {
                    // Parse inset as one or two length-percentage-or-auto values
                    if case let .success(first) = args.tryParse({ CSSLengthPercentageOrAuto.parse($0) }) {
                        let second: CSSLengthPercentageOrAuto = if case let .success(s) = args.tryParse({ CSSLengthPercentageOrAuto.parse($0) }) {
                            s
                        } else {
                            first
                        }
                        inset = CSSSize2D(width: first, height: second)
                        continue
                    }
                }

                break
            }

            return .success(CSSViewTimeline(
                axis: axis ?? .block,
                inset: inset ?? CSSSize2D(width: .auto, height: .auto)
            ))
        }

        switch result {
        case let .success(timeline):
            return .success(timeline)
        case let .failure(error):
            return .failure(error.basic)
        }
    }
}

extension CSSAnimationTimeline {
    static func parse(_ input: Parser) -> Result<CSSAnimationTimeline, BasicParseError> {
        // Try auto keyword
        if input.tryParse({ $0.expectIdentMatching("auto") }).isOK {
            return .success(.auto)
        }

        // Try none keyword
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        // Try scroll() function
        if case let .success(scroll) = input.tryParse({ CSSScrollTimeline.parse($0) }) {
            return .success(.scroll(scroll))
        }

        // Try view() function
        if case let .success(view) = input.tryParse({ CSSViewTimeline.parse($0) }) {
            return .success(.view(view))
        }

        // Try dashed ident
        if case let .success(ident) = CSSDashedIdent.parse(input) {
            return .success(.dashedIdent(ident))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSTimelineRangeName {
    static func parse(_ input: Parser) -> Result<CSSTimelineRangeName, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "cover": return .success(.cover)
        case "contain": return .success(.contain)
        case "entry": return .success(.entry)
        case "exit": return .success(.exit)
        case "entry-crossing": return .success(.entryCrossing)
        case "exit-crossing": return .success(.exitCrossing)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSAnimationAttachmentRange {
    static func parse(_ input: Parser, defaultOffset: Double = 0.0) -> Result<CSSAnimationAttachmentRange, BasicParseError> {
        // Try normal keyword
        if input.tryParse({ $0.expectIdentMatching("normal") }).isOK {
            return .success(.normal)
        }

        // Try length-percentage
        if case let .success(lp) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
            return .success(.lengthPercentage(lp))
        }

        // Try timeline range name with optional offset
        if case let .success(name) = input.tryParse({ CSSTimelineRangeName.parse($0) }) {
            let offset: CSSLengthPercentage = if case let .success(lp) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
                lp
            } else {
                .percentage(CSSPercentage(defaultOffset))
            }
            return .success(.timelineRange(name: name, offset: offset))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSAnimationRangeStart {
    static func parse(_ input: Parser) -> Result<CSSAnimationRangeStart, BasicParseError> {
        switch CSSAnimationAttachmentRange.parse(input, defaultOffset: 0.0) {
        case let .success(range):
            .success(CSSAnimationRangeStart(range))
        case let .failure(error):
            .failure(error)
        }
    }
}

extension CSSAnimationRangeEnd {
    static func parse(_ input: Parser) -> Result<CSSAnimationRangeEnd, BasicParseError> {
        switch CSSAnimationAttachmentRange.parse(input, defaultOffset: 1.0) {
        case let .success(range):
            .success(CSSAnimationRangeEnd(range))
        case let .failure(error):
            .failure(error)
        }
    }
}

extension CSSAnimationRange {
    static func parse(_ input: Parser) -> Result<CSSAnimationRange, BasicParseError> {
        guard case let .success(start) = CSSAnimationRangeStart.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let end: CSSAnimationRangeEnd = if case let .success(parsedEnd) = input.tryParse({ CSSAnimationRangeStart.parse($0) }) {
            CSSAnimationRangeEnd(parsedEnd.range)
        } else {
            // If <'animation-range-end'> is omitted and <'animation-range-start'> includes a <timeline-range-name> component,
            // animation-range-end is set to that same <timeline-range-name> and 100%.
            switch start.range {
            case let .timelineRange(name, _):
                CSSAnimationRangeEnd(.timelineRange(name: name, offset: .percentage(CSSPercentage(1.0))))
            default:
                .default
            }
        }

        return .success(CSSAnimationRange(start: start, end: end))
    }
}

extension CSSAnimation {
    static func parse(_ input: Parser) -> Result<CSSAnimation, BasicParseError> {
        var name: CSSAnimationName?
        var duration: CSSTime?
        var timingFunction: CSSEasingFunction?
        var iterationCount: CSSAnimationIterationCount?
        var direction: CSSAnimationDirection?
        var playState: CSSAnimationPlayState?
        var delay: CSSTime?
        var fillMode: CSSAnimationFillMode?
        var timeline: CSSAnimationTimeline?

        while true {
            // Duration must come before delay
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

            if iterationCount == nil {
                if case let .success(count) = input.tryParse({ CSSAnimationIterationCount.parse($0) }) {
                    iterationCount = count
                    continue
                }
            }

            if direction == nil {
                if case let .success(dir) = input.tryParse({ CSSAnimationDirection.parse($0) }) {
                    direction = dir
                    continue
                }
            }

            if fillMode == nil {
                if case let .success(mode) = input.tryParse({ CSSAnimationFillMode.parse($0) }) {
                    fillMode = mode
                    continue
                }
            }

            if playState == nil {
                if case let .success(state) = input.tryParse({ CSSAnimationPlayState.parse($0) }) {
                    playState = state
                    continue
                }
            }

            if name == nil {
                if case let .success(n) = input.tryParse({ CSSAnimationName.parse($0) }) {
                    name = n
                    continue
                }
            }

            if timeline == nil {
                if case let .success(t) = input.tryParse({ CSSAnimationTimeline.parse($0) }) {
                    timeline = t
                    continue
                }
            }

            break
        }

        return .success(CSSAnimation(
            name: name ?? .none,
            duration: duration ?? .seconds(0),
            timingFunction: timingFunction ?? .ease,
            iterationCount: iterationCount ?? .number(1.0),
            direction: direction ?? .normal,
            playState: playState ?? .running,
            delay: delay ?? .seconds(0),
            fillMode: fillMode ?? .none,
            timeline: timeline ?? .auto
        ))
    }
}

extension CSSAnimationList {
    static func parse(_ input: Parser) -> Result<CSSAnimationList, BasicParseError> {
        var animations: [CSSAnimation] = []

        guard case let .success(first) = CSSAnimation.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }
        animations.append(first)

        while input.tryParse({ $0.expectComma() }).isOK {
            guard case let .success(animation) = CSSAnimation.parse(input) else {
                return .failure(input.newBasicError(.endOfInput))
            }
            animations.append(animation)
        }

        return .success(CSSAnimationList(animations: animations))
    }
}

// MARK: - ToCss

extension CSSAnimationName: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case let .ident(ident):
            ident.serialize(dest: &dest)
        case let .string(str):
            // CSS-wide keywords and "none"/"default" cannot remove quotes.
            let value = str.value.lowercased()
            if value == "none" || value == "default" || CSSWideKeyword(rawValue: value) != nil {
                str.serialize(dest: &dest)
            } else {
                dest.write(str.value)
            }
        }
    }
}

extension CSSAnimationIterationCount: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .number(num):
            dest.write(String(num))
        case .infinite:
            dest.write("infinite")
        }
    }
}

extension CSSAnimationDirection: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSAnimationPlayState: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSAnimationFillMode: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSAnimationComposition: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSScroller: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSScrollAxis: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSScrollTimeline: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("scroll(")

        var needsSpace = false
        if scroller != .default {
            scroller.serialize(dest: &dest)
            needsSpace = true
        }

        if axis != .default {
            if needsSpace { dest.write(" ") }
            axis.serialize(dest: &dest)
        }

        dest.write(")")
    }
}

extension CSSViewTimeline: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("view(")

        var needsSpace = false
        if axis != .default {
            axis.serialize(dest: &dest)
            needsSpace = true
        }

        if inset.width != .auto || inset.height != .auto {
            if needsSpace { dest.write(" ") }
            inset.serialize(dest: &dest)
        }

        dest.write(")")
    }
}

extension CSSAnimationTimeline: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .auto:
            dest.write("auto")
        case .none:
            dest.write("none")
        case let .dashedIdent(ident):
            ident.serialize(dest: &dest)
        case let .scroll(scroll):
            scroll.serialize(dest: &dest)
        case let .view(view):
            view.serialize(dest: &dest)
        }
    }
}

extension CSSTimelineRangeName: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSAnimationAttachmentRange: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        serialize(dest: &dest, defaultOffset: 0.0)
    }

    func serialize(dest: inout some CSSWriter, defaultOffset: Double) {
        switch self {
        case .normal:
            dest.write("normal")
        case let .lengthPercentage(lp):
            lp.serialize(dest: &dest)
        case let .timelineRange(name, offset):
            name.serialize(dest: &dest)
            if offset != .percentage(CSSPercentage(defaultOffset)) {
                dest.write(" ")
                offset.serialize(dest: &dest)
            }
        }
    }
}

extension CSSAnimationRangeStart: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        range.serialize(dest: &dest, defaultOffset: 0.0)
    }
}

extension CSSAnimationRangeEnd: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        range.serialize(dest: &dest, defaultOffset: 1.0)
    }
}

extension CSSAnimationRange: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        start.serialize(dest: &dest)

        let omitEnd: Bool = switch (start.range, end.range) {
        case let (.timelineRange(startName, _), .timelineRange(endName, endOffset)):
            startName == endName && endOffset == .percentage(CSSPercentage(1.0))
        case let (_, endRange):
            endRange == .default
        }

        if !omitEnd {
            dest.write(" ")
            end.serialize(dest: &dest)
        }
    }
}

extension CSSAnimation: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        let isZeroDuration = duration == .seconds(0) || duration == .milliseconds(0)
        let isZeroDelay = delay == .seconds(0) || delay == .milliseconds(0)

        if name != .none {
            if !isZeroDuration || !isZeroDelay {
                duration.serialize(dest: &dest)
                dest.write(" ")
            }

            if timingFunction != .ease {
                timingFunction.serialize(dest: &dest)
                dest.write(" ")
            }

            if !isZeroDelay {
                delay.serialize(dest: &dest)
                dest.write(" ")
            }

            if iterationCount != .default {
                iterationCount.serialize(dest: &dest)
                dest.write(" ")
            }

            if direction != .default {
                direction.serialize(dest: &dest)
                dest.write(" ")
            }

            if fillMode != .default {
                fillMode.serialize(dest: &dest)
                dest.write(" ")
            }

            if playState != .default {
                playState.serialize(dest: &dest)
                dest.write(" ")
            }
        }

        name.serialize(dest: &dest)

        if name != .none, timeline != .default {
            dest.write(" ")
            timeline.serialize(dest: &dest)
        }
    }
}

extension CSSAnimationList: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        var first = true
        for animation in animations {
            if first {
                first = false
            } else {
                dest.write(", ")
            }
            animation.serialize(dest: &dest)
        }
    }
}
