// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A 2D size value with width and height components.
public struct CSSSize2D<T: Equatable & Sendable & CSSSerializable>: Equatable, Sendable {
    /// The width value.
    public let width: T

    /// The height value.
    public let height: T

    /// Creates a size with the given width and height.
    public init(width: T, height: T) {
        self.width = width
        self.height = height
    }

    /// Creates a size with the same value for width and height.
    public init(square: T) {
        width = square
        height = square
    }
}

// MARK: - Hashable

extension CSSSize2D: Hashable where T: Hashable {}

// MARK: - CSSSize2D Parsing

/// Protocol for types that can be parsed from CSS.
protocol CSSParseable {
    static func parse(_ input: Parser) -> Result<Self, BasicParseError>
}

extension CSSSize2D where T: CSSParseable {
    /// Parses a 2D size value (one or two values).
    static func parse(_ input: Parser) -> Result<CSSSize2D<T>, BasicParseError> {
        // Parse first value
        guard case let .success(first) = T.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Try to parse second value
        if case let .success(second) = input.tryParse({ T.parse($0) }) {
            return .success(CSSSize2D(width: first, height: second))
        }

        // If only one value, use it for both dimensions
        return .success(CSSSize2D(square: first))
    }
}

// Conform common types to CSSParseable
extension CSSLength: CSSParseable {}
extension CSSLengthPercentage: CSSParseable {}

// MARK: - ToCss

extension CSSSize2D: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if width == height {
            // Square: output one value
            width.serialize(dest: &dest)
        } else {
            // Different: output two values
            width.serialize(dest: &dest)
            dest.write(" ")
            height.serialize(dest: &dest)
        }
    }
}

// MARK: - Common Type Aliases

/// A size of length-percentage values.
public typealias CSSLengthPercentageSize = CSSSize2D<CSSLengthPercentage>

// MARK: - Size Keywords

/// A size value that can be a keyword or specific size.
public enum CSSSizeKeyword: Equatable, Sendable, Hashable {
    /// An auto size.
    case auto

    /// A cover size (scale to cover the entire area).
    case cover

    /// A contain size (scale to fit within the area).
    case contain

    /// A specific length-percentage size.
    case lengthPercentage(CSSLengthPercentage)
}

extension CSSSizeKeyword {
    /// Parses a size keyword or length-percentage.
    static func parse(_ input: Parser) -> Result<CSSSizeKeyword, BasicParseError> {
        // Try keywords first
        if input.tryParse({ $0.expectIdentMatching("auto") }).isOK {
            return .success(.auto)
        }
        if input.tryParse({ $0.expectIdentMatching("cover") }).isOK {
            return .success(.cover)
        }
        if input.tryParse({ $0.expectIdentMatching("contain") }).isOK {
            return .success(.contain)
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

extension CSSSizeKeyword: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .auto:
            dest.write("auto")
        case .cover:
            dest.write("cover")
        case .contain:
            dest.write("contain")
        case let .lengthPercentage(lp):
            lp.serialize(dest: &dest)
        }
    }
}

/// A background-size value (width and height, or keywords).
public struct CSSBackgroundSize: Equatable, Sendable, Hashable {
    /// The width component.
    public let width: CSSSizeKeyword

    /// The height component (optional, defaults to auto).
    public let height: CSSSizeKeyword?

    /// Creates a background size.
    public init(width: CSSSizeKeyword, height: CSSSizeKeyword? = nil) {
        self.width = width
        self.height = height
    }

    /// The `cover` background size.
    public static let cover = Self(width: .cover)

    /// The `contain` background size.
    public static let contain = Self(width: .contain)

    /// The `auto` background size.
    public static let auto = Self(width: .auto)
}

extension CSSBackgroundSize {
    /// Parses a background-size value.
    static func parse(_ input: Parser) -> Result<CSSBackgroundSize, BasicParseError> {
        // Try cover/contain first
        if input.tryParse({ $0.expectIdentMatching("cover") }).isOK {
            return .success(.cover)
        }
        if input.tryParse({ $0.expectIdentMatching("contain") }).isOK {
            return .success(.contain)
        }

        // Parse width
        switch CSSSizeKeyword.parse(input) {
        case let .success(width):
            // Try to parse height
            if case let .success(height) = input.tryParse({ CSSSizeKeyword.parse($0) }) {
                return .success(CSSBackgroundSize(width: width, height: height))
            }
            return .success(CSSBackgroundSize(width: width))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSBackgroundSize: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        width.serialize(dest: &dest)
        if let height {
            dest.write(" ")
            height.serialize(dest: &dest)
        }
    }
}

// MARK: - Width/Height Size Properties

/// A value for the preferred size properties (width and height).
/// https://drafts.csswg.org/css-sizing-3/#preferred-size-properties
/// https://www.w3.org/TR/css-sizing-4/#sizing-values
public enum CSSSize: Equatable, Sendable, Hashable {
    /// The `auto` keyword.
    case auto

    /// An explicit length or percentage.
    case lengthPercentage(CSSLengthPercentage)

    /// The `min-content` keyword.
    case minContent(CSSVendorPrefix)

    /// The `max-content` keyword.
    case maxContent(CSSVendorPrefix)

    /// The `fit-content` keyword.
    case fitContent(CSSVendorPrefix)

    /// The `fit-content()` function.
    case fitContentFunction(CSSLengthPercentage)

    /// The `stretch` keyword, or the `-webkit-fill-available` or `-moz-available` prefixed keywords.
    case stretch(CSSVendorPrefix)

    /// The `contain` keyword.
    case contain
}

/// A value for the minimum and maximum size properties (e.g., min-width, max-height).
/// https://drafts.csswg.org/css-sizing-3/#min-size-properties
/// https://drafts.csswg.org/css-sizing-3/#max-size-properties
public enum CSSMaxSize: Equatable, Sendable, Hashable {
    /// The `none` keyword.
    case none

    /// An explicit length or percentage.
    case lengthPercentage(CSSLengthPercentage)

    /// The `min-content` keyword.
    case minContent(CSSVendorPrefix)

    /// The `max-content` keyword.
    case maxContent(CSSVendorPrefix)

    /// The `fit-content` keyword.
    case fitContent(CSSVendorPrefix)

    /// The `fit-content()` function.
    case fitContentFunction(CSSLengthPercentage)

    /// The `stretch` keyword, or the `-webkit-fill-available` or `-moz-available` prefixed keywords.
    case stretch(CSSVendorPrefix)

    /// The `contain` keyword.
    case contain
}

/// A value for the aspect-ratio property.
/// https://drafts.csswg.org/css-sizing-4/#aspect-ratio
public struct CSSAspectRatio: Equatable, Sendable, Hashable {
    /// The `auto` keyword.
    public var auto: Bool

    /// A preferred aspect ratio for the box, specified as width / height.
    public var ratio: CSSRatio?

    public init(auto: Bool, ratio: CSSRatio? = nil) {
        self.auto = auto
        self.ratio = ratio
    }
}

// MARK: - Size Property Parsing

extension CSSSize {
    static func parse(_ input: Parser) -> Result<CSSSize, BasicParseError> {
        // Try to parse identifiers first
        if case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
            let identLower = ident.lowercased()
            switch identLower {
            case "auto":
                return .success(.auto)
            case "min-content":
                return .success(.minContent(.none))
            case "-webkit-min-content":
                return .success(.minContent(.webkit))
            case "-moz-min-content":
                return .success(.minContent(.moz))
            case "max-content":
                return .success(.maxContent(.none))
            case "-webkit-max-content":
                return .success(.maxContent(.webkit))
            case "-moz-max-content":
                return .success(.maxContent(.moz))
            case "stretch":
                return .success(.stretch(.none))
            case "-webkit-fill-available":
                return .success(.stretch(.webkit))
            case "-moz-available":
                return .success(.stretch(.moz))
            case "fit-content":
                return .success(.fitContent(.none))
            case "-webkit-fit-content":
                return .success(.fitContent(.webkit))
            case "-moz-fit-content":
                return .success(.fitContent(.moz))
            case "contain":
                return .success(.contain)
            default:
                break
            }
        }

        // Try to parse fit-content() function
        if case let .success(lp) = input.tryParse(parseFitContent) {
            return .success(.fitContentFunction(lp))
        }

        // Try to parse length-percentage
        switch CSSLengthPercentage.parse(input) {
        case let .success(lp):
            return .success(.lengthPercentage(lp))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSMaxSize {
    static func parse(_ input: Parser) -> Result<CSSMaxSize, BasicParseError> {
        // Try to parse identifiers first
        if case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
            let identLower = ident.lowercased()
            switch identLower {
            case "none":
                return .success(.none)
            case "min-content":
                return .success(.minContent(.none))
            case "-webkit-min-content":
                return .success(.minContent(.webkit))
            case "-moz-min-content":
                return .success(.minContent(.moz))
            case "max-content":
                return .success(.maxContent(.none))
            case "-webkit-max-content":
                return .success(.maxContent(.webkit))
            case "-moz-max-content":
                return .success(.maxContent(.moz))
            case "stretch":
                return .success(.stretch(.none))
            case "-webkit-fill-available":
                return .success(.stretch(.webkit))
            case "-moz-available":
                return .success(.stretch(.moz))
            case "fit-content":
                return .success(.fitContent(.none))
            case "-webkit-fit-content":
                return .success(.fitContent(.webkit))
            case "-moz-fit-content":
                return .success(.fitContent(.moz))
            case "contain":
                return .success(.contain)
            default:
                break
            }
        }

        // Try to parse fit-content() function
        if case let .success(lp) = input.tryParse(parseFitContent) {
            return .success(.fitContentFunction(lp))
        }

        // Try to parse length-percentage
        switch CSSLengthPercentage.parse(input) {
        case let .success(lp):
            return .success(.lengthPercentage(lp))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSAspectRatio {
    static func parse(_ input: Parser) -> Result<CSSAspectRatio, BasicParseError> {
        var auto = input.tryParse { $0.expectIdentMatching("auto") }.isOK

        var parsedRatio: CSSRatio?
        if case let .success(r) = input.tryParse({ CSSRatio.parse($0) }) {
            parsedRatio = r
        }

        if !auto {
            auto = input.tryParse { $0.expectIdentMatching("auto") }.isOK
        }

        if !auto, parsedRatio == nil {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(CSSAspectRatio(auto: auto, ratio: parsedRatio))
    }
}

// MARK: - Helper Functions

private func parseFitContent(_ input: Parser) -> Result<CSSLengthPercentage, BasicParseError> {
    guard input.expectFunctionMatching("fit-content").isOK else {
        return .failure(input.newBasicError(.endOfInput))
    }

    let result: Result<CSSLengthPercentage, ParseError<BasicParseErrorKind>> = input.parseNestedBlock { innerInput in
        CSSLengthPercentage.parse(innerInput).mapError { error in
            ParseError(kind: .basic(error.kind), location: error.location)
        }
    }

    switch result {
    case let .success(lp):
        return .success(lp)
    case let .failure(error):
        return .failure(error.basic)
    }
}

// MARK: - Size Property ToCss

extension CSSSize: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .auto:
            dest.write("auto")
        case .contain:
            dest.write("contain")
        case let .minContent(vp):
            vp.serialize(dest: &dest)
            dest.write("min-content")
        case let .maxContent(vp):
            vp.serialize(dest: &dest)
            dest.write("max-content")
        case let .fitContent(vp):
            vp.serialize(dest: &dest)
            dest.write("fit-content")
        case let .stretch(vp):
            switch vp {
            case .none:
                dest.write("stretch")
            case .webkit:
                dest.write("-webkit-fill-available")
            case .moz:
                dest.write("-moz-available")
            default:
                dest.write("stretch")
            }
        case let .fitContentFunction(lp):
            dest.write("fit-content(")
            lp.serialize(dest: &dest)
            dest.write(")")
        case let .lengthPercentage(lp):
            lp.serialize(dest: &dest)
        }
    }
}

extension CSSMaxSize: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case .contain:
            dest.write("contain")
        case let .minContent(vp):
            vp.serialize(dest: &dest)
            dest.write("min-content")
        case let .maxContent(vp):
            vp.serialize(dest: &dest)
            dest.write("max-content")
        case let .fitContent(vp):
            vp.serialize(dest: &dest)
            dest.write("fit-content")
        case let .stretch(vp):
            switch vp {
            case .none:
                dest.write("stretch")
            case .webkit:
                dest.write("-webkit-fill-available")
            case .moz:
                dest.write("-moz-available")
            default:
                dest.write("stretch")
            }
        case let .fitContentFunction(lp):
            dest.write("fit-content(")
            lp.serialize(dest: &dest)
            dest.write(")")
        case let .lengthPercentage(lp):
            lp.serialize(dest: &dest)
        }
    }
}

extension CSSAspectRatio: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if auto {
            dest.write("auto")
        }

        if let ratio {
            if auto {
                dest.write(" ")
            }
            ratio.serialize(dest: &dest)
        }
    }
}
