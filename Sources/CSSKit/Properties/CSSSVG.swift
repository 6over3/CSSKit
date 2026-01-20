// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - SVG Paint Fallback

/// A fallback for an SVG paint in case a paint server `url()` cannot be resolved.
/// https://www.w3.org/TR/SVG2/painting.html#SpecifyingPaint
public enum CSSSVGPaintFallback: Equatable, Sendable, Hashable {
    /// No fallback.
    case none
    /// A solid color.
    case color(Color)
}

// MARK: - SVG Paint

/// An SVG `<paint>` value used in the `fill` and `stroke` properties.
/// https://www.w3.org/TR/SVG2/painting.html#SpecifyingPaint
public enum CSSSVGPaint: Equatable, Sendable, Hashable {
    /// A URL reference to a paint server element, e.g. `linearGradient`, `radialGradient`, and `pattern`.
    case url(CSSUrl, fallback: CSSSVGPaintFallback?)
    /// A solid color paint.
    case color(Color)
    /// Use the paint value of fill from a context element.
    case contextFill
    /// Use the paint value of stroke from a context element.
    case contextStroke
    /// No paint.
    case none
}

// MARK: - Stroke Linecap

/// A value for the `stroke-linecap` property.
/// https://www.w3.org/TR/SVG2/painting.html#LineCaps
public enum CSSStrokeLinecap: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The stroke does not extend beyond its endpoints.
    case butt
    /// The ends of the stroke are rounded.
    case round
    /// The ends of the stroke are squared.
    case square
}

// MARK: - Stroke Linejoin

/// A value for the `stroke-linejoin` property.
/// https://www.w3.org/TR/SVG2/painting.html#LineJoin
public enum CSSStrokeLinejoin: String, Equatable, Sendable, Hashable, CaseIterable {
    /// A sharp corner is to be used to join path segments.
    case miter
    /// Same as `miter` but clipped beyond `stroke-miterlimit`.
    case miterClip = "miter-clip"
    /// A round corner is to be used to join path segments.
    case round
    /// A bevelled corner is to be used to join path segments.
    case bevel
    /// An arcs corner is to be used to join path segments.
    case arcs
}

// MARK: - Stroke Dasharray

/// A value for the `stroke-dasharray` property.
/// https://www.w3.org/TR/SVG2/painting.html#StrokeDashing
public enum CSSStrokeDasharray: Equatable, Sendable, Hashable {
    /// No dashing is used.
    case none
    /// Specifies a dashing pattern to use.
    case values([CSSLengthPercentage])
}

// MARK: - Marker

/// A value for the marker properties.
/// https://www.w3.org/TR/SVG2/painting.html#VertexMarkerProperties
public enum CSSMarker: Equatable, Sendable, Hashable {
    /// No marker.
    case none
    /// A url reference to a `<marker>` element.
    case url(CSSUrl)
}

// MARK: - Color Interpolation

/// A value for the `color-interpolation` property.
/// https://www.w3.org/TR/SVG2/painting.html#ColorInterpolation
public enum CSSColorInterpolation: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The UA can choose between sRGB or linearRGB.
    case auto
    /// Color interpolation occurs in the sRGB color space.
    case sRGB = "srgb"
    /// Color interpolation occurs in the linearized RGB color space.
    case linearRGB = "linearrgb"
}

// MARK: - Color Rendering

/// A value for the `color-rendering` property.
/// https://www.w3.org/TR/SVG2/painting.html#ColorRendering
public enum CSSColorRendering: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The UA can choose a tradeoff between speed and quality.
    case auto
    /// The UA shall optimize speed over quality.
    case optimizeSpeed = "optimizespeed"
    /// The UA shall optimize quality over speed.
    case optimizeQuality = "optimizequality"
}

// MARK: - Shape Rendering

/// A value for the `shape-rendering` property.
/// https://www.w3.org/TR/SVG2/painting.html#ShapeRendering
public enum CSSShapeRendering: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The UA can choose an appropriate tradeoff.
    case auto
    /// The UA shall optimize speed.
    case optimizeSpeed = "optimizespeed"
    /// The UA shall optimize crisp edges.
    case crispEdges = "crispedges"
    /// The UA shall optimize geometric precision.
    case geometricPrecision = "geometricprecision"
}

// MARK: - Text Rendering

/// A value for the `text-rendering` property.
/// https://www.w3.org/TR/SVG2/painting.html#TextRendering
public enum CSSTextRendering: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The UA can choose an appropriate tradeoff.
    case auto
    /// The UA shall optimize speed.
    case optimizeSpeed = "optimizespeed"
    /// The UA shall optimize legibility.
    case optimizeLegibility = "optimizelegibility"
    /// The UA shall optimize geometric precision.
    case geometricPrecision = "geometricprecision"
}

// MARK: - Image Rendering

/// A value for the `image-rendering` property.
/// https://www.w3.org/TR/SVG2/painting.html#ImageRendering
public enum CSSImageRendering: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The UA can choose a tradeoff between speed and quality.
    case auto
    /// The UA shall optimize speed over quality.
    case optimizeSpeed = "optimizespeed"
    /// The UA shall optimize quality over speed.
    case optimizeQuality = "optimizequality"
}

extension CSSSVGPaintFallback {
    static func parse(_ input: Parser) -> Result<CSSSVGPaintFallback, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        if case let .success(color) = Color.parse(input) {
            return .success(.color(color))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSSVGPaint {
    static func parse(_ input: Parser) -> Result<CSSSVGPaint, BasicParseError> {
        // Try none
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        // Try context-fill / context-stroke
        if input.tryParse({ $0.expectIdentMatching("context-fill") }).isOK {
            return .success(.contextFill)
        }
        if input.tryParse({ $0.expectIdentMatching("context-stroke") }).isOK {
            return .success(.contextStroke)
        }

        // Try url with optional fallback
        if case let .success(url) = input.tryParse({ CSSUrl.parse($0) }) {
            var fallback: CSSSVGPaintFallback?
            if case let .success(fb) = input.tryParse({ CSSSVGPaintFallback.parse($0) }) {
                fallback = fb
            }
            return .success(.url(url, fallback: fallback))
        }

        // Try color
        if case let .success(color) = Color.parse(input) {
            return .success(.color(color))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSStrokeLinecap {
    static func parse(_ input: Parser) -> Result<CSSStrokeLinecap, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "butt": return .success(.butt)
        case "round": return .success(.round)
        case "square": return .success(.square)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSStrokeLinejoin {
    static func parse(_ input: Parser) -> Result<CSSStrokeLinejoin, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "miter": return .success(.miter)
        case "miter-clip": return .success(.miterClip)
        case "round": return .success(.round)
        case "bevel": return .success(.bevel)
        case "arcs": return .success(.arcs)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSStrokeDasharray {
    static func parse(_ input: Parser) -> Result<CSSStrokeDasharray, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        // Parse space or comma separated list of length-percentages
        var values: [CSSLengthPercentage] = []

        guard case let .success(first) = CSSLengthPercentage.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }
        values.append(first)

        while true {
            // Optional comma
            _ = input.tryParse { $0.expectComma() }

            if case let .success(val) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
                values.append(val)
            } else {
                break
            }
        }

        return .success(.values(values))
    }
}

extension CSSMarker {
    static func parse(_ input: Parser) -> Result<CSSMarker, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        if case let .success(url) = CSSUrl.parse(input) {
            return .success(.url(url))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSColorInterpolation {
    static func parse(_ input: Parser) -> Result<CSSColorInterpolation, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "auto": return .success(.auto)
        case "srgb": return .success(.sRGB)
        case "linearrgb": return .success(.linearRGB)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSColorRendering {
    static func parse(_ input: Parser) -> Result<CSSColorRendering, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "auto": return .success(.auto)
        case "optimizespeed": return .success(.optimizeSpeed)
        case "optimizequality": return .success(.optimizeQuality)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSShapeRendering {
    static func parse(_ input: Parser) -> Result<CSSShapeRendering, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "auto": return .success(.auto)
        case "optimizespeed": return .success(.optimizeSpeed)
        case "crispedges": return .success(.crispEdges)
        case "geometricprecision": return .success(.geometricPrecision)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSTextRendering {
    static func parse(_ input: Parser) -> Result<CSSTextRendering, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "auto": return .success(.auto)
        case "optimizespeed": return .success(.optimizeSpeed)
        case "optimizelegibility": return .success(.optimizeLegibility)
        case "geometricprecision": return .success(.geometricPrecision)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSImageRendering {
    static func parse(_ input: Parser) -> Result<CSSImageRendering, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "auto": return .success(.auto)
        case "optimizespeed": return .success(.optimizeSpeed)
        case "optimizequality": return .success(.optimizeQuality)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

// MARK: - ToCss

extension CSSSVGPaintFallback: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case let .color(color):
            color.serialize(dest: &dest)
        }
    }
}

extension CSSSVGPaint: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case .contextFill:
            dest.write("context-fill")
        case .contextStroke:
            dest.write("context-stroke")
        case let .color(color):
            color.serialize(dest: &dest)
        case let .url(url, fallback):
            url.serialize(dest: &dest)
            if let fallback {
                dest.write(" ")
                fallback.serialize(dest: &dest)
            }
        }
    }
}

extension CSSStrokeLinecap: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSStrokeLinejoin: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSStrokeDasharray: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case let .values(values):
            var first = true
            for value in values {
                if first {
                    first = false
                } else {
                    dest.write(" ")
                }
                value.serialize(dest: &dest)
            }
        }
    }
}

extension CSSMarker: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case let .url(url):
            url.serialize(dest: &dest)
        }
    }
}

extension CSSColorInterpolation: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSColorRendering: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSShapeRendering: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSTextRendering: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSImageRendering: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}
