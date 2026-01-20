// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Mask Type

/// A value for the `mask-type` property.
/// https://www.w3.org/TR/css-masking-1/#the-mask-type
public enum CSSMaskType: String, Equatable, Sendable, Hashable {
    /// The luminance values of the mask is used.
    case luminance
    /// The alpha values of the mask is used.
    case alpha
}

/// A value for the `mask-mode` property.
/// https://www.w3.org/TR/css-masking-1/#the-mask-mode
public enum CSSMaskMode: String, Equatable, Sendable, Hashable {
    /// The luminance values of the mask image is used.
    case luminance
    /// The alpha values of the mask image is used.
    case alpha
    /// If an SVG source is used, the value matches the `mask-type` property. Otherwise, the alpha values are used.
    case matchSource = "match-source"

    /// The default value.
    public static let `default`: CSSMaskMode = .matchSource
}

/// A value for the `-webkit-mask-source-type` property.
/// See also `CSSMaskMode`.
public enum CSSWebKitMaskSourceType: String, Equatable, Sendable, Hashable {
    /// Equivalent to `match-source` in the standard `mask-mode` syntax.
    case auto
    /// The luminance values of the mask image is used.
    case luminance
    /// The alpha values of the mask image is used.
    case alpha
}

public extension CSSWebKitMaskSourceType {
    /// Creates a WebKit mask source type from a standard mask mode.
    init(from mode: CSSMaskMode) {
        switch mode {
        case .luminance: self = .luminance
        case .alpha: self = .alpha
        case .matchSource: self = .auto
        }
    }
}

// MARK: - Geometry Box

/// A `<geometry-box>` value as used in `mask-clip` and `clip-path` properties.
/// https://www.w3.org/TR/css-masking-1/#typedef-geometry-box
public enum CSSGeometryBox: String, Equatable, Sendable, Hashable {
    /// The painted content is clipped to the border box.
    case borderBox = "border-box"
    /// The painted content is clipped to the padding box.
    case paddingBox = "padding-box"
    /// The painted content is clipped to the content box.
    case contentBox = "content-box"
    /// The painted content is clipped to the margin box.
    case marginBox = "margin-box"
    /// The painted content is clipped to the object bounding box.
    case fillBox = "fill-box"
    /// The painted content is clipped to the stroke bounding box.
    case strokeBox = "stroke-box"
    /// Uses the nearest SVG viewport as reference box.
    case viewBox = "view-box"

    /// The default value.
    public static let `default`: CSSGeometryBox = .borderBox
}

// MARK: - Mask Clip

/// A value for the `mask-clip` property.
/// https://www.w3.org/TR/css-masking-1/#the-mask-clip
public enum CSSMaskClip: Equatable, Sendable, Hashable {
    /// A geometry box.
    case geometryBox(CSSGeometryBox)
    /// The painted content is not clipped.
    case noClip

    /// Creates a mask clip from a geometry box.
    public init(geometryBox: CSSGeometryBox) {
        self = .geometryBox(geometryBox)
    }

    /// The default value (border-box).
    public static let `default`: CSSMaskClip = .geometryBox(.borderBox)
}

// MARK: - Mask Composite

/// A value for the `mask-composite` property.
/// https://www.w3.org/TR/css-masking-1/#the-mask-composite
public enum CSSMaskComposite: String, Equatable, Sendable, Hashable {
    /// The source is placed over the destination.
    case add
    /// The source is placed, where it falls outside of the destination.
    case subtract
    /// The parts of source that overlap the destination, replace the destination.
    case intersect
    /// The non-overlapping regions of source and destination are combined.
    case exclude

    /// The default value.
    public static let `default`: CSSMaskComposite = .add
}

/// A value for the `-webkit-mask-composite` property.
/// See also `CSSMaskComposite`.
public enum CSSWebKitMaskComposite: String, Equatable, Sendable, Hashable {
    case clear
    case copy
    /// Equivalent to `add` in the standard `mask-composite` syntax.
    case sourceOver = "source-over"
    /// Equivalent to `intersect` in the standard `mask-composite` syntax.
    case sourceIn = "source-in"
    /// Equivalent to `subtract` in the standard `mask-composite` syntax.
    case sourceOut = "source-out"
    case sourceAtop = "source-atop"
    case destinationOver = "destination-over"
    case destinationIn = "destination-in"
    case destinationOut = "destination-out"
    case destinationAtop = "destination-atop"
    /// Equivalent to `exclude` in the standard `mask-composite` syntax.
    case xor
}

public extension CSSWebKitMaskComposite {
    /// Creates a WebKit mask composite from a standard mask composite.
    init(from composite: CSSMaskComposite) {
        switch composite {
        case .add: self = .sourceOver
        case .subtract: self = .sourceOut
        case .intersect: self = .sourceIn
        case .exclude: self = .xor
        }
    }
}

// MARK: - Mask

/// A value for the `mask` shorthand property.
/// https://www.w3.org/TR/css-masking-1/#the-mask
public struct CSSMask: Equatable, Sendable, Hashable {
    /// The mask image.
    public var image: CSSImage
    /// The position of the mask.
    public var position: CSSPosition
    /// The size of the mask image.
    public var size: CSSBackgroundSize
    /// How the mask repeats.
    public var `repeat`: CSSBackgroundRepeat
    /// The box in which the mask is clipped.
    public var clip: CSSMaskClip
    /// The origin of the mask.
    public var origin: CSSGeometryBox
    /// How the mask is composited with the element.
    public var composite: CSSMaskComposite
    /// How the mask image is interpreted.
    public var mode: CSSMaskMode
    /// The vendor prefix.
    public var vendorPrefix: CSSVendorPrefix

    /// The default position (0% 0%).
    public static var defaultPosition: CSSPosition {
        CSSPosition(
            horizontal: .lengthPercentage(.percentage(CSSPercentage(0))),
            vertical: .lengthPercentage(.percentage(CSSPercentage(0)))
        )
    }

    public init(
        image: CSSImage = .none,
        position: CSSPosition? = nil,
        size: CSSBackgroundSize = .auto,
        repeat: CSSBackgroundRepeat = .default,
        clip: CSSMaskClip = .default,
        origin: CSSGeometryBox = .borderBox,
        composite: CSSMaskComposite = .add,
        mode: CSSMaskMode = .matchSource,
        vendorPrefix: CSSVendorPrefix = .none
    ) {
        self.image = image
        self.position = position ?? Self.defaultPosition
        self.size = size
        self.repeat = `repeat`
        self.clip = clip
        self.origin = origin
        self.composite = composite
        self.mode = mode
        self.vendorPrefix = vendorPrefix
    }

    /// The default value.
    public static let `default` = Self()
}

// MARK: - Clip Path

/// A value for the `clip-path` property.
/// https://www.w3.org/TR/css-masking-1/#the-clip-path
public enum CSSClipPath: Equatable, Sendable, Hashable {
    /// No clip path.
    case none
    /// A url reference to an SVG path element.
    case url(CSSUrl)
    /// A basic shape with an optional reference box.
    case shape(CSSBasicShape, CSSGeometryBox?)
    /// A reference box only.
    case box(CSSGeometryBox)
}

// MARK: - Mask Border

/// A value for the `mask-border-mode` property.
/// https://www.w3.org/TR/css-masking-1/#the-mask-border-mode
public enum CSSMaskBorderMode: String, Equatable, Sendable, Hashable {
    /// The luminance values of the mask image is used.
    case luminance
    /// The alpha values of the mask image is used.
    case alpha

    /// The default value.
    public static let `default`: CSSMaskBorderMode = .alpha
}

// MARK: - Parsing

extension CSSMaskType {
    static func parse(_ input: Parser) -> Result<CSSMaskType, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "luminance": return .success(.luminance)
        case "alpha": return .success(.alpha)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSMaskMode {
    static func parse(_ input: Parser) -> Result<CSSMaskMode, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "luminance": return .success(.luminance)
        case "alpha": return .success(.alpha)
        case "match-source": return .success(.matchSource)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSWebKitMaskSourceType {
    static func parse(_ input: Parser) -> Result<CSSWebKitMaskSourceType, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "auto": return .success(.auto)
        case "luminance": return .success(.luminance)
        case "alpha": return .success(.alpha)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSGeometryBox {
    static func parse(_ input: Parser) -> Result<CSSGeometryBox, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "border-box": return .success(.borderBox)
        case "padding-box": return .success(.paddingBox)
        case "content-box": return .success(.contentBox)
        case "margin-box": return .success(.marginBox)
        case "fill-box": return .success(.fillBox)
        case "stroke-box": return .success(.strokeBox)
        case "view-box": return .success(.viewBox)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSMaskClip {
    static func parse(_ input: Parser) -> Result<CSSMaskClip, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("no-clip") }).isOK {
            return .success(.noClip)
        }
        switch CSSGeometryBox.parse(input) {
        case let .success(box):
            return .success(.geometryBox(box))
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSMaskComposite {
    static func parse(_ input: Parser) -> Result<CSSMaskComposite, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "add": return .success(.add)
        case "subtract": return .success(.subtract)
        case "intersect": return .success(.intersect)
        case "exclude": return .success(.exclude)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSWebKitMaskComposite {
    static func parse(_ input: Parser) -> Result<CSSWebKitMaskComposite, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "clear": return .success(.clear)
        case "copy": return .success(.copy)
        case "source-over": return .success(.sourceOver)
        case "source-in": return .success(.sourceIn)
        case "source-out": return .success(.sourceOut)
        case "source-atop": return .success(.sourceAtop)
        case "destination-over": return .success(.destinationOver)
        case "destination-in": return .success(.destinationIn)
        case "destination-out": return .success(.destinationOut)
        case "destination-atop": return .success(.destinationAtop)
        case "xor": return .success(.xor)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSMask {
    static func parse(_ input: Parser, vendorPrefix: CSSVendorPrefix = .none) -> Result<CSSMask, BasicParseError> {
        var image: CSSImage?
        var position: CSSPosition?
        var size: CSSBackgroundSize?
        var repeatVal: CSSBackgroundRepeat?
        var clip: CSSMaskClip?
        var origin: CSSGeometryBox?
        var composite: CSSMaskComposite?
        var mode: CSSMaskMode?

        while true {
            if image == nil {
                if case let .success(value) = input.tryParse({ CSSImage.parse($0) }) {
                    image = value
                    continue
                }
            }

            if position == nil {
                if case let .success(value) = input.tryParse({ CSSPosition.parse($0) }) {
                    position = value
                    // Try to parse size after position with /
                    if input.tryParse({ $0.expectDelim("/") }).isOK {
                        if case let .success(s) = input.tryParse({ CSSBackgroundSize.parse($0) }) {
                            size = s
                        }
                    }
                    continue
                }
            }

            if repeatVal == nil {
                if case let .success(value) = input.tryParse({ CSSBackgroundRepeat.parse($0) }) {
                    repeatVal = value
                    continue
                }
            }

            if origin == nil {
                if case let .success(value) = input.tryParse({ CSSGeometryBox.parse($0) }) {
                    origin = value
                    continue
                }
            }

            if clip == nil {
                if case let .success(value) = input.tryParse({ CSSMaskClip.parse($0) }) {
                    clip = value
                    continue
                }
            }

            if composite == nil {
                if case let .success(value) = input.tryParse({ CSSMaskComposite.parse($0) }) {
                    composite = value
                    continue
                }
            }

            if mode == nil {
                if case let .success(value) = input.tryParse({ CSSMaskMode.parse($0) }) {
                    mode = value
                    continue
                }
            }

            break
        }

        // If clip is not set but origin is, use origin for clip
        if clip == nil, let origin {
            clip = .geometryBox(origin)
        }

        return .success(CSSMask(
            image: image ?? .none,
            position: position,
            size: size ?? .auto,
            repeat: repeatVal ?? .default,
            clip: clip ?? .geometryBox(.borderBox),
            origin: origin ?? .borderBox,
            composite: composite ?? .add,
            mode: mode ?? .matchSource,
            vendorPrefix: vendorPrefix
        ))
    }
}

extension CSSClipPath {
    static func parse(_ input: Parser) -> Result<CSSClipPath, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        if case let .success(url) = input.tryParse({ CSSUrl.parse($0) }) {
            return .success(.url(url))
        }

        // Try basic shape with optional reference box
        var shape: CSSBasicShape?
        var box: CSSGeometryBox?

        // Try box first, then shape
        if case let .success(b) = input.tryParse({ CSSGeometryBox.parse($0) }) {
            box = b
        }

        if case let .success(s) = input.tryParse({ CSSBasicShape.parse($0) }) {
            shape = s
        }

        // If no shape yet and we have a box, try shape again
        if shape == nil, box != nil {
            // box-only case
        } else if shape == nil {
            // Try shape first, then box
            if case let .success(s) = input.tryParse({ CSSBasicShape.parse($0) }) {
                shape = s
                // Try box after shape
                if case let .success(b) = input.tryParse({ CSSGeometryBox.parse($0) }) {
                    box = b
                }
            }
        } else if box == nil {
            // We have shape, try box after
            if case let .success(b) = input.tryParse({ CSSGeometryBox.parse($0) }) {
                box = b
            }
        }

        if let shape {
            return .success(.shape(shape, box))
        }

        if let box {
            return .success(.box(box))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSMaskBorderMode {
    static func parse(_ input: Parser) -> Result<CSSMaskBorderMode, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.lowercased() {
        case "luminance": return .success(.luminance)
        case "alpha": return .success(.alpha)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

// MARK: - ToCss

extension CSSMaskType: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSMaskMode: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSWebKitMaskSourceType: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSGeometryBox: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSMaskClip: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .geometryBox(box):
            box.serialize(dest: &dest)
        case .noClip:
            dest.write("no-clip")
        }
    }
}

extension CSSMaskComposite: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSWebKitMaskComposite: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSMask: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        image.serialize(dest: &dest)

        let isDefaultPosition = position == CSSMask.defaultPosition
        if !isDefaultPosition || size != .auto {
            dest.write(" ")
            position.serialize(dest: &dest)

            if size != .auto {
                dest.write(" / ")
                size.serialize(dest: &dest)
            }
        }

        if `repeat` != .default {
            dest.write(" ")
            `repeat`.serialize(dest: &dest)
        }

        if origin != .borderBox || clip != .geometryBox(.borderBox) {
            dest.write(" ")
            origin.serialize(dest: &dest)

            if clip != .geometryBox(origin) {
                dest.write(" ")
                clip.serialize(dest: &dest)
            }
        }

        if composite != .default {
            dest.write(" ")
            composite.serialize(dest: &dest)
        }

        if mode != .default {
            dest.write(" ")
            mode.serialize(dest: &dest)
        }
    }
}

extension CSSClipPath: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case let .url(url):
            url.serialize(dest: &dest)
        case let .shape(shape, box):
            shape.serialize(dest: &dest)
            if let box {
                dest.write(" ")
                box.serialize(dest: &dest)
            }
        case let .box(box):
            box.serialize(dest: &dest)
        }
    }
}

extension CSSMaskBorderMode: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}
