// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A CSS `<time>` value. https://www.w3.org/TR/css-values-4/#time
public enum CSSTime: Sendable, Hashable {
    /// A time in seconds.
    case seconds(Double)

    /// A time in milliseconds.
    case milliseconds(Double)
}

// MARK: - Parsing

extension CSSTime {
    /// Parses a `<time>` value.
    static func parse(_ input: Parser) -> Result<CSSTime, BasicParseError> {
        let location = input.currentSourceLocation()

        switch input.next() {
        case let .success(token):
            switch token {
            case let .dimension(numeric, unit):
                let value = numeric.value
                switch unit.value.lowercased() {
                case "s":
                    return .success(.seconds(value))
                case "ms":
                    return .success(.milliseconds(value))
                default:
                    return .failure(location.newBasicUnexpectedTokenError(token))
                }

            default:
                return .failure(location.newBasicUnexpectedTokenError(token))
            }

        case let .failure(error):
            return .failure(error)
        }
    }
}

// MARK: - Conversions

public extension CSSTime {
    /// The time converted to seconds.
    var inSeconds: Double {
        switch self {
        case let .seconds(v):
            v
        case let .milliseconds(v):
            v / 1000.0
        }
    }

    /// The time converted to milliseconds.
    var inMilliseconds: Double {
        switch self {
        case let .seconds(v):
            v * 1000.0
        case let .milliseconds(v):
            v
        }
    }

    /// The raw numeric value without unit.
    var value: Double {
        switch self {
        case let .seconds(v), let .milliseconds(v):
            v
        }
    }
}

// MARK: - ToCss

extension CSSTime: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        let (value, unit): (Double, String)

        switch self {
        case let .seconds(v):
            // Prefer milliseconds if the value is a whole number of ms
            let ms = v * 1000.0
            if ms.truncatingRemainder(dividingBy: 1) == 0, abs(ms) < 1000 {
                value = ms
                unit = "ms"
            } else {
                value = v
                unit = "s"
            }
        case let .milliseconds(v):
            // Prefer seconds if the value is a whole number of seconds
            let s = v / 1000.0
            if v.truncatingRemainder(dividingBy: 1000) == 0, v != 0 {
                value = s
                unit = "s"
            } else {
                value = v
                unit = "ms"
            }
        }

        serializeDimension(value: value, unit: unit, dest: &dest)
    }
}

// MARK: - Zero

extension CSSTime: Zero {
    public static var zero: CSSTime { .seconds(0.0) }

    public var isZero: Bool { value == 0.0 }
}

// MARK: - Signed

extension CSSTime: Signed {
    public var cssSign: Double { value.cssSign }

    public var isPositive: Bool { value >= 0.0 }

    public var isNegative: Bool { value < 0.0 }
}

// MARK: - Equatable

extension CSSTime: Equatable {
    public static func == (lhs: CSSTime, rhs: CSSTime) -> Bool {
        lhs.inSeconds == rhs.inSeconds
    }
}

// MARK: - Comparable

extension CSSTime: Comparable {
    public static func < (lhs: CSSTime, rhs: CSSTime) -> Bool {
        lhs.inSeconds < rhs.inSeconds
    }
}

// MARK: - Arithmetic

public extension CSSTime {
    static func + (lhs: CSSTime, rhs: CSSTime) -> CSSTime {
        .seconds(lhs.inSeconds + rhs.inSeconds)
    }

    static func - (lhs: CSSTime, rhs: CSSTime) -> CSSTime {
        .seconds(lhs.inSeconds - rhs.inSeconds)
    }

    static func * (lhs: CSSTime, rhs: Double) -> CSSTime {
        switch lhs {
        case let .seconds(v): .seconds(v * rhs)
        case let .milliseconds(v): .milliseconds(v * rhs)
        }
    }

    static func / (lhs: CSSTime, rhs: Double) -> CSSTime {
        switch lhs {
        case let .seconds(v): .seconds(v / rhs)
        case let .milliseconds(v): .milliseconds(v / rhs)
        }
    }
}
