// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Border Image Repeat

/// A single `border-image-repeat` keyword.
/// https://www.w3.org/TR/css-backgrounds-3/#border-image-repeat
public enum CSSBorderImageRepeatKeyword: String, Equatable, Sendable, Hashable {
    /// The image is stretched to fill the area.
    case stretch
    /// The image is tiled (repeated) to fill the area.
    case `repeat`
    /// The image is scaled so that it repeats an even number of times.
    case round
    /// The image is repeated so that it fits, and then spaced apart evenly.
    case space
}

/// A value for the `border-image-repeat` property.
/// https://www.w3.org/TR/css-backgrounds-3/#border-image-repeat
public struct CSSBorderImageRepeat: Equatable, Sendable, Hashable {
    /// The horizontal repeat value.
    public var horizontal: CSSBorderImageRepeatKeyword
    /// The vertical repeat value.
    public var vertical: CSSBorderImageRepeatKeyword

    public init(
        horizontal: CSSBorderImageRepeatKeyword = .stretch,
        vertical: CSSBorderImageRepeatKeyword = .stretch
    ) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

    /// Creates a repeat value with the same keyword for both directions.
    public init(_ keyword: CSSBorderImageRepeatKeyword) {
        horizontal = keyword
        vertical = keyword
    }

    /// The default value (stretch stretch).
    public static let `default` = Self()
}

// MARK: - Border Image Side Width

/// A value for individual `border-image-width` sides.
/// https://www.w3.org/TR/css-backgrounds-3/#border-image-width
public enum CSSBorderImageSideWidth: Equatable, Sendable, Hashable {
    /// A number representing a multiple of the border width.
    case number(Double)
    /// An explicit length or percentage.
    case lengthPercentage(CSSLengthPercentage)
    /// The `auto` keyword, representing the natural width of the image slice.
    case auto

    /// The default value (1).
    public static let one: CSSBorderImageSideWidth = .number(1)
    public static let `default`: CSSBorderImageSideWidth = .number(1)
}

// MARK: - Border Image Slice

/// A value for the `border-image-slice` property.
/// https://www.w3.org/TR/css-backgrounds-3/#border-image-slice
public struct CSSBorderImageSlice: Equatable, Sendable, Hashable {
    /// The offsets from the edges of the image.
    public var offsets: CSSRect<CSSNumberOrPercentage>
    /// Whether the middle of the border image should be preserved.
    public var fill: Bool

    public init(
        offsets: CSSRect<CSSNumberOrPercentage> = CSSRect(all: .percentage(CSSPercentage(1.0))),
        fill: Bool = false
    ) {
        self.offsets = offsets
        self.fill = fill
    }

    /// The default value (100% on all sides, no fill).
    public static let `default` = Self()
}

// MARK: - Length or Number

/// A length or number value.
public enum CSSLengthOrNumber: Equatable, Sendable, Hashable, CSSSerializable {
    case length(CSSLength)
    case number(Double)

    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .length(l):
            l.serialize(dest: &dest)
        case let .number(n):
            n.serialize(dest: &dest)
        }
    }

    /// The default value (0).
    public static let `default`: CSSLengthOrNumber = .number(0)
}

// MARK: - Border Image

/// A value for the `border-image` shorthand property.
/// https://www.w3.org/TR/css-backgrounds-3/#border-image
public struct CSSBorderImage: Equatable, Sendable, Hashable {
    /// The border image.
    public var source: CSSImage
    /// The offsets that define where the image is sliced.
    public var slice: CSSBorderImageSlice
    /// The width of the border image.
    public var width: CSSRect<CSSBorderImageSideWidth>
    /// The amount that the image extends beyond the border box.
    public var outset: CSSRect<CSSLengthOrNumber>
    /// How the border image is scaled and tiled.
    public var `repeat`: CSSBorderImageRepeat

    public init(
        source: CSSImage = .none,
        slice: CSSBorderImageSlice = .default,
        width: CSSRect<CSSBorderImageSideWidth> = CSSRect(all: .number(1)),
        outset: CSSRect<CSSLengthOrNumber> = CSSRect(all: .number(0)),
        repeat: CSSBorderImageRepeat = .default
    ) {
        self.source = source
        self.slice = slice
        self.width = width
        self.outset = outset
        self.repeat = `repeat`
    }

    /// The default value.
    public static let `default` = Self()
}

// MARK: - Parsing

extension CSSBorderImageRepeatKeyword {
    static func parse(_ input: Parser) -> Result<CSSBorderImageRepeatKeyword, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "stretch": return .success(.stretch)
        case "repeat": return .success(.repeat)
        case "round": return .success(.round)
        case "space": return .success(.space)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSBorderImageRepeat {
    static func parse(_ input: Parser) -> Result<CSSBorderImageRepeat, BasicParseError> {
        switch CSSBorderImageRepeatKeyword.parse(input) {
        case let .success(horizontal):
            let vertical: CSSBorderImageRepeatKeyword = if case let .success(v) = input.tryParse({ CSSBorderImageRepeatKeyword.parse($0) }) {
                v
            } else {
                horizontal
            }
            return .success(CSSBorderImageRepeat(horizontal: horizontal, vertical: vertical))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSBorderImageSideWidth {
    static func parse(_ input: Parser) -> Result<CSSBorderImageSideWidth, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("auto") }).isOK {
            return .success(.auto)
        }

        // Try number first
        if case let .success(token) = input.tryParse({ $0.next() }) {
            if case let .number(numeric) = token {
                return .success(.number(numeric.value))
            }
        }

        // Try length-percentage
        switch CSSLengthPercentage.parse(input) {
        case let .success(lp):
            return .success(.lengthPercentage(lp))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSLengthOrNumber {
    static func parse(_ input: Parser) -> Result<CSSLengthOrNumber, BasicParseError> {
        // Try number first
        let state = input.state()
        if case let .success(token) = input.next() {
            if case let .number(numeric) = token {
                return .success(.number(numeric.value))
            }
        }
        input.reset(state)

        // Try length
        switch CSSLength.parse(input) {
        case let .success(length):
            return .success(.length(length))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSBorderImageSlice {
    static func parse(_ input: Parser) -> Result<CSSBorderImageSlice, BasicParseError> {
        var fill = input.tryParse { $0.expectIdentMatching("fill") }.isOK

        // Parse up to 4 number-or-percentage values
        var values: [CSSNumberOrPercentage] = []

        while values.count < 4 {
            if case let .success(val) = input.tryParse({ CSSNumberOrPercentage.parse($0) }) {
                values.append(val)
            } else {
                break
            }
        }

        if values.isEmpty {
            return .failure(input.newBasicError(.endOfInput))
        }

        if !fill {
            fill = input.tryParse { $0.expectIdentMatching("fill") }.isOK
        }

        let offsets: CSSRect<CSSNumberOrPercentage> = switch values.count {
        case 1:
            CSSRect(all: values[0])
        case 2:
            CSSRect(vertical: values[0], horizontal: values[1])
        case 3:
            CSSRect(top: values[0], horizontal: values[1], bottom: values[2])
        case 4:
            CSSRect(top: values[0], right: values[1], bottom: values[2], left: values[3])
        default:
            CSSRect(all: values[0])
        }

        return .success(CSSBorderImageSlice(offsets: offsets, fill: fill))
    }
}

extension CSSBorderImage {
    static func parse(_ input: Parser) -> Result<CSSBorderImage, BasicParseError> {
        var source: CSSImage?
        var slice: CSSBorderImageSlice?
        var width: CSSRect<CSSBorderImageSideWidth>?
        var outset: CSSRect<CSSLengthOrNumber>?
        var repeatVal: CSSBorderImageRepeat?

        while true {
            if slice == nil {
                if case let .success(value) = input.tryParse({ CSSBorderImageSlice.parse($0) }) {
                    slice = value
                    // Try to parse width and outset
                    if input.tryParse({ $0.expectDelim("/") }).isOK {
                        // Parse width
                        var widthValues: [CSSBorderImageSideWidth] = []
                        while widthValues.count < 4 {
                            if case let .success(w) = input.tryParse({ CSSBorderImageSideWidth.parse($0) }) {
                                widthValues.append(w)
                            } else {
                                break
                            }
                        }

                        if !widthValues.isEmpty {
                            switch widthValues.count {
                            case 1:
                                width = CSSRect(all: widthValues[0])
                            case 2:
                                width = CSSRect(vertical: widthValues[0], horizontal: widthValues[1])
                            case 3:
                                width = CSSRect(top: widthValues[0], horizontal: widthValues[1], bottom: widthValues[2])
                            case 4:
                                width = CSSRect(top: widthValues[0], right: widthValues[1], bottom: widthValues[2], left: widthValues[3])
                            default:
                                break
                            }
                        }

                        // Try to parse outset
                        if input.tryParse({ $0.expectDelim("/") }).isOK {
                            var outsetValues: [CSSLengthOrNumber] = []
                            while outsetValues.count < 4 {
                                if case let .success(o) = input.tryParse({ CSSLengthOrNumber.parse($0) }) {
                                    outsetValues.append(o)
                                } else {
                                    break
                                }
                            }

                            if !outsetValues.isEmpty {
                                switch outsetValues.count {
                                case 1:
                                    outset = CSSRect(all: outsetValues[0])
                                case 2:
                                    outset = CSSRect(vertical: outsetValues[0], horizontal: outsetValues[1])
                                case 3:
                                    outset = CSSRect(top: outsetValues[0], horizontal: outsetValues[1], bottom: outsetValues[2])
                                case 4:
                                    outset = CSSRect(top: outsetValues[0], right: outsetValues[1], bottom: outsetValues[2], left: outsetValues[3])
                                default:
                                    break
                                }
                            }
                        }
                    }
                    continue
                }
            }

            if source == nil {
                if case let .success(value) = input.tryParse({ CSSImage.parse($0) }) {
                    source = value
                    continue
                }
            }

            if repeatVal == nil {
                if case let .success(value) = input.tryParse({ CSSBorderImageRepeat.parse($0) }) {
                    repeatVal = value
                    continue
                }
            }

            break
        }

        if source != nil || slice != nil || width != nil || outset != nil || repeatVal != nil {
            return .success(CSSBorderImage(
                source: source ?? .none,
                slice: slice ?? .default,
                width: width ?? CSSRect(all: .number(1)),
                outset: outset ?? CSSRect(all: .number(0)),
                repeat: repeatVal ?? .default
            ))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

// MARK: - ToCss

extension CSSBorderImageRepeatKeyword: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSBorderImageRepeat: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        horizontal.serialize(dest: &dest)
        if horizontal != vertical {
            dest.write(" ")
            vertical.serialize(dest: &dest)
        }
    }
}

extension CSSBorderImageSideWidth: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .number(n):
            n.serialize(dest: &dest)
        case let .lengthPercentage(lp):
            lp.serialize(dest: &dest)
        case .auto:
            dest.write("auto")
        }
    }
}

extension CSSBorderImageSlice: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        offsets.serialize(dest: &dest)
        if fill {
            dest.write(" fill")
        }
    }
}

extension CSSBorderImage: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if source != .none {
            source.serialize(dest: &dest)
        }

        let hasSlice = slice != .default
        let hasWidth = width != CSSRect(all: CSSBorderImageSideWidth.number(1))
        let hasOutset = outset != CSSRect(all: CSSLengthOrNumber.number(0))

        if hasSlice || hasWidth || hasOutset {
            dest.write(" ")
            slice.serialize(dest: &dest)

            if hasWidth || hasOutset {
                dest.write(" / ")
            }

            if hasWidth {
                width.serialize(dest: &dest)
            }

            if hasOutset {
                dest.write(" / ")
                outset.serialize(dest: &dest)
            }
        }

        if `repeat` != .default {
            dest.write(" ")
            `repeat`.serialize(dest: &dest)
        }
    }
}

// MARK: - CSSParseable Conformance

extension CSSBorderImageSideWidth: CSSParseable {}
extension CSSLengthOrNumber: CSSParseable {}
