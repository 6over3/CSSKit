// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Filter

/// A filter function.
/// https://drafts.fxtf.org/filter-effects-1/#filter-functions
public enum CSSFilter: Equatable, Sendable, Hashable {
    /// A `blur()` filter.
    case blur(CSSLength)
    /// A `brightness()` filter.
    case brightness(CSSNumberOrPercentage)
    /// A `contrast()` filter.
    case contrast(CSSNumberOrPercentage)
    /// A `grayscale()` filter.
    case grayscale(CSSNumberOrPercentage)
    /// A `hue-rotate()` filter.
    case hueRotate(CSSAngle)
    /// An `invert()` filter.
    case invert(CSSNumberOrPercentage)
    /// An `opacity()` filter.
    case opacity(CSSNumberOrPercentage)
    /// A `saturate()` filter.
    case saturate(CSSNumberOrPercentage)
    /// A `sepia()` filter.
    case sepia(CSSNumberOrPercentage)
    /// A `drop-shadow()` filter.
    case dropShadow(CSSDropShadow)
    /// A `url()` reference to an SVG filter.
    case url(CSSUrl)
}

// MARK: - Drop Shadow

/// A `drop-shadow()` filter function.
/// https://drafts.fxtf.org/filter-effects-1/#funcdef-filter-drop-shadow
public struct CSSDropShadow: Equatable, Sendable, Hashable {
    /// The color of the drop shadow.
    public var color: Color
    /// The x offset of the drop shadow.
    public var xOffset: CSSLength
    /// The y offset of the drop shadow.
    public var yOffset: CSSLength
    /// The blur radius of the drop shadow.
    public var blur: CSSLength

    public init(
        color: Color = .currentColor,
        xOffset: CSSLength,
        yOffset: CSSLength,
        blur: CSSLength = .zero
    ) {
        self.color = color
        self.xOffset = xOffset
        self.yOffset = yOffset
        self.blur = blur
    }
}

// MARK: - Filter List

/// A value for the `filter` and `backdrop-filter` properties.
/// https://drafts.fxtf.org/filter-effects-1/#FilterProperty
/// https://drafts.fxtf.org/filter-effects-2/#BackdropFilterProperty
public enum CSSFilterList: Equatable, Sendable, Hashable {
    /// The `none` keyword.
    case none
    /// A list of filter functions.
    case filters([CSSFilter])
}

// MARK: - Parsing

extension CSSFilter {
    static func parse(_ input: Parser) -> Result<CSSFilter, BasicParseError> {
        // Try URL first
        if case let .success(url) = input.tryParse({ CSSUrl.parse($0) }) {
            return .success(.url(url))
        }

        let location = input.currentSourceLocation()

        guard case let .success(token) = input.next() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        guard case let .function(name) = token else {
            return .failure(location.newBasicUnexpectedTokenError(token))
        }

        let functionName = name.value.lowercased()

        let result: Result<CSSFilter, ParseError<Never>> = input.parseNestedBlock { args in
            switch functionName {
            case "blur":
                let length: CSSLength = if case let .success(l) = args.tryParse({ CSSLength.parse($0) }) {
                    l
                } else {
                    .zero
                }
                return .success(.blur(length))

            case "brightness":
                let value: CSSNumberOrPercentage = if case let .success(v) = args.tryParse({ CSSNumberOrPercentage.parse($0) }) {
                    v
                } else {
                    .number(1.0)
                }
                return .success(.brightness(value))

            case "contrast":
                let value: CSSNumberOrPercentage = if case let .success(v) = args.tryParse({ CSSNumberOrPercentage.parse($0) }) {
                    v
                } else {
                    .number(1.0)
                }
                return .success(.contrast(value))

            case "grayscale":
                let value: CSSNumberOrPercentage = if case let .success(v) = args.tryParse({ CSSNumberOrPercentage.parse($0) }) {
                    v
                } else {
                    .number(1.0)
                }
                return .success(.grayscale(value))

            case "hue-rotate":
                // Spec has an exception for unitless zero angles
                let angle: CSSAngle = if case let .success(a) = args.tryParse({ CSSAngle.parseWithUnitlessZero($0) }) {
                    a
                } else {
                    .zero
                }
                return .success(.hueRotate(angle))

            case "invert":
                let value: CSSNumberOrPercentage = if case let .success(v) = args.tryParse({ CSSNumberOrPercentage.parse($0) }) {
                    v
                } else {
                    .number(1.0)
                }
                return .success(.invert(value))

            case "opacity":
                let value: CSSNumberOrPercentage = if case let .success(v) = args.tryParse({ CSSNumberOrPercentage.parse($0) }) {
                    v
                } else {
                    .number(1.0)
                }
                return .success(.opacity(value))

            case "saturate":
                let value: CSSNumberOrPercentage = if case let .success(v) = args.tryParse({ CSSNumberOrPercentage.parse($0) }) {
                    v
                } else {
                    .number(1.0)
                }
                return .success(.saturate(value))

            case "sepia":
                let value: CSSNumberOrPercentage = if case let .success(v) = args.tryParse({ CSSNumberOrPercentage.parse($0) }) {
                    v
                } else {
                    .number(1.0)
                }
                return .success(.sepia(value))

            case "drop-shadow":
                guard case let .success(shadow) = CSSDropShadow.parse(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.dropShadow(shadow))

            default:
                return .failure(location.newUnexpectedTokenError(.ident(name)))
            }
        }

        switch result {
        case let .success(filter):
            return .success(filter)
        case let .failure(error):
            return .failure(error.basic)
        }
    }
}

extension CSSDropShadow {
    static func parse(_ input: Parser) -> Result<CSSDropShadow, BasicParseError> {
        var color: Color?
        var lengths: (CSSLength, CSSLength, CSSLength)?

        // Parse in any order: color and lengths
        while true {
            if lengths == nil {
                if case let .success(l) = input.tryParse({ inp -> Result<(CSSLength, CSSLength, CSSLength), BasicParseError> in
                    guard case let .success(horizontal) = CSSLength.parse(inp) else {
                        return .failure(inp.newBasicError(.endOfInput))
                    }
                    guard case let .success(vertical) = CSSLength.parse(inp) else {
                        return .failure(inp.newBasicError(.endOfInput))
                    }
                    let blur: CSSLength = if case let .success(b) = inp.tryParse({ CSSLength.parse($0) }) {
                        b
                    } else {
                        .zero
                    }
                    return .success((horizontal, vertical, blur))
                }) {
                    lengths = l
                    continue
                }
            }

            if color == nil {
                if case let .success(c) = input.tryParse({ Color.parse($0) }) {
                    color = c
                    continue
                }
            }

            break
        }

        guard let lengths else {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(CSSDropShadow(
            color: color ?? .currentColor,
            xOffset: lengths.0,
            yOffset: lengths.1,
            blur: lengths.2
        ))
    }
}

extension CSSFilterList {
    static func parse(_ input: Parser) -> Result<CSSFilterList, BasicParseError> {
        // Try none keyword
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        // Parse list of filters
        var filters: [CSSFilter] = []
        while case let .success(filter) = input.tryParse({ CSSFilter.parse($0) }) {
            filters.append(filter)
        }

        return .success(.filters(filters))
    }
}

// MARK: - ToCss

extension CSSFilter: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .blur(val):
            dest.write("blur(")
            if val != .zero {
                val.serialize(dest: &dest)
            }
            dest.write(")")

        case let .brightness(val):
            dest.write("brightness(")
            if val.unitValue != 1.0 {
                val.serialize(dest: &dest)
            }
            dest.write(")")

        case let .contrast(val):
            dest.write("contrast(")
            if val.unitValue != 1.0 {
                val.serialize(dest: &dest)
            }
            dest.write(")")

        case let .grayscale(val):
            dest.write("grayscale(")
            if val.unitValue != 1.0 {
                val.serialize(dest: &dest)
            }
            dest.write(")")

        case let .hueRotate(val):
            dest.write("hue-rotate(")
            if !val.isZero {
                val.serialize(dest: &dest)
            }
            dest.write(")")

        case let .invert(val):
            dest.write("invert(")
            if val.unitValue != 1.0 {
                val.serialize(dest: &dest)
            }
            dest.write(")")

        case let .opacity(val):
            dest.write("opacity(")
            if val.unitValue != 1.0 {
                val.serialize(dest: &dest)
            }
            dest.write(")")

        case let .saturate(val):
            dest.write("saturate(")
            if val.unitValue != 1.0 {
                val.serialize(dest: &dest)
            }
            dest.write(")")

        case let .sepia(val):
            dest.write("sepia(")
            if val.unitValue != 1.0 {
                val.serialize(dest: &dest)
            }
            dest.write(")")

        case let .dropShadow(val):
            dest.write("drop-shadow(")
            val.serialize(dest: &dest)
            dest.write(")")

        case let .url(url):
            url.serialize(dest: &dest)
        }
    }
}

extension CSSDropShadow: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        xOffset.serialize(dest: &dest)
        dest.write(" ")
        yOffset.serialize(dest: &dest)

        if blur != .zero {
            dest.write(" ")
            blur.serialize(dest: &dest)
        }

        if color != .currentColor {
            dest.write(" ")
            color.serialize(dest: &dest)
        }
    }
}

extension CSSFilterList: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case let .filters(filters):
            var first = true
            for filter in filters {
                if first {
                    first = false
                } else {
                    dest.write(" ")
                }
                filter.serialize(dest: &dest)
            }
        }
    }
}
