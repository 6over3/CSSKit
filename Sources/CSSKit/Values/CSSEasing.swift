// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A CSS `<easing-function>` value.
/// https://www.w3.org/TR/css-easing-1/
public enum CSSEasingFunction: Equatable, Sendable, Hashable {
    // MARK: - Keyword Values

    /// The `linear` timing function.
    case linear

    /// The `ease` timing function (equivalent to cubic-bezier(0.25, 0.1, 0.25, 1)).
    case ease

    /// The `ease-in` timing function (equivalent to cubic-bezier(0.42, 0, 1, 1)).
    case easeIn

    /// The `ease-out` timing function (equivalent to cubic-bezier(0, 0, 0.58, 1)).
    case easeOut

    /// The `ease-in-out` timing function (equivalent to cubic-bezier(0.42, 0, 0.58, 1)).
    case easeInOut

    /// The `step-start` timing function (equivalent to steps(1, start)).
    case stepStart

    /// The `step-end` timing function (equivalent to steps(1, end)).
    case stepEnd

    // MARK: - Function Values

    /// A `cubic-bezier()` timing function.
    case cubicBezier(x1: Double, y1: Double, x2: Double, y2: Double)

    /// A `steps()` timing function.
    case steps(count: Int, position: CSSStepPosition)

    /// A `linear()` timing function with stops.
    case linearFunction([CSSLinearStop])
}

/// The position of a step in a steps() timing function.
public enum CSSStepPosition: String, Equatable, Sendable, Hashable {
    /// Jump at the start of each step.
    case jumpStart = "jump-start"

    /// Jump at the end of each step.
    case jumpEnd = "jump-end"

    /// Jump at both the start and end.
    case jumpBoth = "jump-both"

    /// No jump at either end.
    case jumpNone = "jump-none"

    /// Same as jump-start.
    case start

    /// Same as jump-end (default).
    case end
}

/// A stop in a linear() timing function.
public struct CSSLinearStop: Equatable, Sendable, Hashable {
    /// The output value at this stop.
    public let output: Double

    /// The optional input position (percentage of duration).
    public let input: CSSPercentage?

    /// Creates a linear stop with an output value and optional input position.
    public init(output: Double, input: CSSPercentage? = nil) {
        self.output = output
        self.input = input
    }
}

// MARK: - Parsing

extension CSSEasingFunction {
    /// Parses an `<easing-function>` value.
    static func parse(_ input: Parser) -> Result<CSSEasingFunction, BasicParseError> {
        let location = input.currentSourceLocation()

        switch input.next() {
        case let .success(token):
            switch token {
            case let .ident(ident):
                switch ident.value.lowercased() {
                case "linear":
                    return .success(.linear)
                case "ease":
                    return .success(.ease)
                case "ease-in":
                    return .success(.easeIn)
                case "ease-out":
                    return .success(.easeOut)
                case "ease-in-out":
                    return .success(.easeInOut)
                case "step-start":
                    return .success(.stepStart)
                case "step-end":
                    return .success(.stepEnd)
                default:
                    return .failure(location.newBasicUnexpectedTokenError(token))
                }

            case let .function(name):
                let funcName = name.value.lowercased()
                let result: Result<CSSEasingFunction, ParseError<Never>> = input.parseNestedBlock { args in
                    let innerResult: Result<CSSEasingFunction, BasicParseError> = switch funcName {
                    case "cubic-bezier":
                        parseCubicBezier(args)
                    case "steps":
                        parseSteps(args)
                    case "linear":
                        parseLinearFunction(args)
                    default:
                        .failure(location.newBasicUnexpectedTokenError(token))
                    }
                    return innerResult.mapError { $0.asParseError() }
                }
                return result.mapError { $0.basic }

            default:
                return .failure(location.newBasicUnexpectedTokenError(token))
            }

        case let .failure(error):
            return .failure(error)
        }
    }

    private static func parseCubicBezier(_ input: Parser) -> Result<CSSEasingFunction, BasicParseError> {
        guard case let .success(x1) = input.expectNumber() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        guard case .success = input.expectComma() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        guard case let .success(y1) = input.expectNumber() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        guard case .success = input.expectComma() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        guard case let .success(x2) = input.expectNumber() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        guard case .success = input.expectComma() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        guard case let .success(y2) = input.expectNumber() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Validate x values are in [0, 1]
        guard x1 >= 0, x1 <= 1, x2 >= 0, x2 <= 1 else {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(.cubicBezier(x1: x1, y1: y1, x2: x2, y2: y2))
    }

    private static func parseSteps(_ input: Parser) -> Result<CSSEasingFunction, BasicParseError> {
        guard case let .success(count) = input.parseInteger(), count > 0 else {
            return .failure(input.newBasicError(.endOfInput))
        }

        var position: CSSStepPosition = .end

        if input.tryParse({ $0.expectComma() }).isOK {
            guard case let .success(ident) = input.expectIdent() else {
                return .failure(input.newBasicError(.endOfInput))
            }

            switch ident.value.lowercased() {
            case "jump-start": position = .jumpStart
            case "jump-end": position = .jumpEnd
            case "jump-both": position = .jumpBoth
            case "jump-none": position = .jumpNone
            case "start": position = .start
            case "end": position = .end
            default:
                return .failure(input.newBasicError(.endOfInput))
            }
        }

        return .success(.steps(count: count, position: position))
    }

    private static func parseLinearFunction(_ input: Parser) -> Result<CSSEasingFunction, BasicParseError> {
        var stops: [CSSLinearStop] = []

        while !input.isExhausted {
            guard case let .success(output) = input.expectNumber() else {
                break
            }

            // Try to parse optional percentage
            let percentage: CSSPercentage? = if case let .success(pct) = CSSPercentage.parse(input) {
                pct
            } else {
                nil
            }

            stops.append(CSSLinearStop(output: output, input: percentage))

            // Try comma for next stop
            if input.tryParse({ $0.expectComma() }).isOK {
                continue
            }
            break
        }

        guard !stops.isEmpty else {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(.linearFunction(stops))
    }
}

// MARK: - ToCss

extension CSSEasingFunction: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .linear:
            dest.write("linear")
        case .ease:
            dest.write("ease")
        case .easeIn:
            dest.write("ease-in")
        case .easeOut:
            dest.write("ease-out")
        case .easeInOut:
            dest.write("ease-in-out")
        case .stepStart:
            dest.write("step-start")
        case .stepEnd:
            dest.write("step-end")
        case let .cubicBezier(x1, y1, x2, y2):
            dest.write("cubic-bezier(")
            x1.serialize(dest: &dest)
            dest.write(", ")
            y1.serialize(dest: &dest)
            dest.write(", ")
            x2.serialize(dest: &dest)
            dest.write(", ")
            y2.serialize(dest: &dest)
            dest.write(")")
        case let .steps(count, position):
            dest.write("steps(")
            dest.write(String(count))
            if position != .end {
                dest.write(", ")
                dest.write(position.rawValue)
            }
            dest.write(")")
        case let .linearFunction(stops):
            dest.write("linear(")
            for (i, stop) in stops.enumerated() {
                if i > 0 { dest.write(", ") }
                stop.output.serialize(dest: &dest)
                if let input = stop.input {
                    dest.write(" ")
                    input.serialize(dest: &dest)
                }
            }
            dest.write(")")
        }
    }
}
