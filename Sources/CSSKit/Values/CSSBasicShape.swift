// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A CSS `<basic-shape>` value.
/// https://www.w3.org/TR/css-shapes-1/#basic-shape-functions
public enum CSSBasicShape: Equatable, Sendable, Hashable {
    /// An inset rectangle via `inset()`.
    case inset(CSSInsetRect)

    /// A circle via `circle()`.
    case circle(CSSCircle)

    /// An ellipse via `ellipse()`.
    case ellipse(CSSEllipse)

    /// A polygon via `polygon()`.
    case polygon(CSSPolygon)

    /// A path via `path()`.
    case path(CSSPath)
}

// MARK: - Inset Rectangle

/// An `inset()` rectangle shape.
/// https://www.w3.org/TR/css-shapes-1/#funcdef-inset
public struct CSSInsetRect: Equatable, Sendable, Hashable {
    /// The rectangle insets (top, right, bottom, left).
    public let rect: CSSRect<CSSLengthPercentage>

    /// An optional corner radius for the rectangle.
    public let radius: CSSBorderRadiusValue?

    /// Creates an inset rectangle.
    public init(rect: CSSRect<CSSLengthPercentage>, radius: CSSBorderRadiusValue? = nil) {
        self.rect = rect
        self.radius = radius
    }
}

// MARK: - Circle

/// A `circle()` shape.
/// https://www.w3.org/TR/css-shapes-1/#funcdef-circle
public struct CSSCircle: Equatable, Sendable, Hashable {
    /// The radius of the circle.
    public let radius: CSSShapeRadius

    /// The position of the center of the circle.
    public let position: CSSPosition

    /// Creates a circle.
    public init(radius: CSSShapeRadius = .closestSide, position: CSSPosition = .center) {
        self.radius = radius
        self.position = position
    }
}

// MARK: - Ellipse

/// An `ellipse()` shape.
/// https://www.w3.org/TR/css-shapes-1/#funcdef-ellipse
public struct CSSEllipse: Equatable, Sendable, Hashable {
    /// The x-radius of the ellipse.
    public let radiusX: CSSShapeRadius

    /// The y-radius of the ellipse.
    public let radiusY: CSSShapeRadius

    /// The position of the center of the ellipse.
    public let position: CSSPosition

    /// Creates an ellipse.
    public init(
        radiusX: CSSShapeRadius = .closestSide,
        radiusY: CSSShapeRadius = .closestSide,
        position: CSSPosition = .center
    ) {
        self.radiusX = radiusX
        self.radiusY = radiusY
        self.position = position
    }
}

// MARK: - Shape Radius

/// A `<shape-radius>` value that defines the radius of a `circle()` or `ellipse()` shape.
/// https://www.w3.org/TR/css-shapes-1/#typedef-shape-radius
public enum CSSShapeRadius: Equatable, Sendable, Hashable {
    /// An explicit length or percentage.
    case lengthPercentage(CSSLengthPercentage)

    /// The length from the center to the closest side of the box.
    case closestSide

    /// The length from the center to the farthest side of the box.
    case farthestSide
}

public extension CSSShapeRadius {
    /// The default shape radius (closest-side).
    static var `default`: CSSShapeRadius { .closestSide }
}

// MARK: - Polygon

/// A `polygon()` shape.
/// https://www.w3.org/TR/css-shapes-1/#funcdef-polygon
public struct CSSPolygon: Equatable, Sendable, Hashable {
    /// The fill rule used to determine the interior of the polygon.
    public let fillRule: CSSFillRule

    /// The points of each vertex of the polygon.
    public let points: [CSSPoint]

    /// Creates a polygon.
    public init(fillRule: CSSFillRule = .nonzero, points: [CSSPoint]) {
        self.fillRule = fillRule
        self.points = points
    }
}

// MARK: - Point

/// A point within a `polygon()` shape.
public struct CSSPoint: Equatable, Sendable, Hashable {
    /// The x position of the point.
    public let x: CSSLengthPercentage

    /// The y position of the point.
    public let y: CSSLengthPercentage

    /// Creates a point.
    public init(x: CSSLengthPercentage, y: CSSLengthPercentage) {
        self.x = x
        self.y = y
    }
}

// MARK: - Fill Rule

/// A `<fill-rule>` used to determine the interior of a `polygon()` shape.
/// https://www.w3.org/TR/css-shapes-1/#typedef-fill-rule
public enum CSSFillRule: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The nonzero fill rule.
    case nonzero

    /// The evenodd fill rule.
    case evenodd
}

public extension CSSFillRule {
    /// The default fill rule (nonzero).
    static var `default`: CSSFillRule { .nonzero }
}

// MARK: - Path

/// A `path()` shape using SVG path syntax.
/// https://www.w3.org/TR/css-shapes-1/#funcdef-path
public struct CSSPath: Equatable, Sendable, Hashable {
    /// The fill rule for the path.
    public let fillRule: CSSFillRule

    /// The SVG path data string.
    public let path: String

    /// Creates a path.
    public init(fillRule: CSSFillRule = .nonzero, path: String) {
        self.fillRule = fillRule
        self.path = path
    }
}

// MARK: - Parsing

extension CSSBasicShape {
    /// Parses a basic shape value.
    static func parse(_ input: Parser) -> Result<CSSBasicShape, BasicParseError> {
        let location = input.currentSourceLocation()

        switch input.next() {
        case let .success(token):
            guard case let .function(name) = token else {
                return .failure(location.newBasicUnexpectedTokenError(token))
            }

            let funcName = name.value.lowercased()
            let result: Result<CSSBasicShape, ParseError<Never>> = input.parseNestedBlock { args in
                switch funcName {
                case "inset":
                    CSSInsetRect.parse(args).map { .inset($0) }.mapError { $0.asParseError() }
                case "circle":
                    CSSCircle.parse(args).map { .circle($0) }.mapError { $0.asParseError() }
                case "ellipse":
                    CSSEllipse.parse(args).map { .ellipse($0) }.mapError { $0.asParseError() }
                case "polygon":
                    CSSPolygon.parse(args).map { .polygon($0) }.mapError { $0.asParseError() }
                case "path":
                    CSSPath.parse(args).map { .path($0) }.mapError { $0.asParseError() }
                default:
                    .failure(location.newUnexpectedTokenError(token))
                }
            }
            return result.mapError { $0.basic }

        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSInsetRect {
    /// Parses an inset rectangle.
    static func parse(_ input: Parser) -> Result<CSSInsetRect, BasicParseError> {
        // Parse the rect values
        guard case let .success(top) = CSSLengthPercentage.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let right: CSSLengthPercentage = if case let .success(r) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
            r
        } else {
            top
        }

        let bottom: CSSLengthPercentage = if case let .success(b) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
            b
        } else {
            top
        }

        let left: CSSLengthPercentage = if case let .success(l) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
            l
        } else {
            right
        }

        let rect = CSSRect(top: top, right: right, bottom: bottom, left: left)

        // Parse optional "round <border-radius>"
        var radius: CSSBorderRadiusValue?
        if input.tryParse({ $0.expectIdentMatching("round") }).isOK {
            if case let .success(r) = CSSBorderRadiusValue.parse(input) {
                radius = r
            }
        }

        return .success(CSSInsetRect(rect: rect, radius: radius))
    }
}

extension CSSCircle {
    /// Parses a circle.
    static func parse(_ input: Parser) -> Result<CSSCircle, BasicParseError> {
        // Try to parse radius
        let radius: CSSShapeRadius = if case let .success(r) = input.tryParse({ CSSShapeRadius.parse($0) }) {
            r
        } else {
            .closestSide
        }

        // Try to parse "at <position>"
        var position: CSSPosition = .center
        if input.tryParse({ $0.expectIdentMatching("at") }).isOK {
            if case let .success(pos) = CSSPosition.parse(input) {
                position = pos
            }
        }

        return .success(CSSCircle(radius: radius, position: position))
    }
}

extension CSSEllipse {
    /// Parses an ellipse.
    static func parse(_ input: Parser) -> Result<CSSEllipse, BasicParseError> {
        // Try to parse both radii
        var radiusX: CSSShapeRadius = .closestSide
        var radiusY: CSSShapeRadius = .closestSide

        if case let .success(rx) = input.tryParse({ CSSShapeRadius.parse($0) }) {
            radiusX = rx
            if case let .success(ry) = input.tryParse({ CSSShapeRadius.parse($0) }) {
                radiusY = ry
            } else {
                radiusY = radiusX
            }
        }

        // Try to parse "at <position>"
        var position: CSSPosition = .center
        if input.tryParse({ $0.expectIdentMatching("at") }).isOK {
            if case let .success(pos) = CSSPosition.parse(input) {
                position = pos
            }
        }

        return .success(CSSEllipse(radiusX: radiusX, radiusY: radiusY, position: position))
    }
}

extension CSSShapeRadius {
    /// Parses a shape radius.
    static func parse(_ input: Parser) -> Result<CSSShapeRadius, BasicParseError> {
        // Try keywords first
        if input.tryParse({ $0.expectIdentMatching("closest-side") }).isOK {
            return .success(.closestSide)
        }
        if input.tryParse({ $0.expectIdentMatching("farthest-side") }).isOK {
            return .success(.farthestSide)
        }

        // Try length-percentage
        return CSSLengthPercentage.parse(input).map { .lengthPercentage($0) }
    }
}

extension CSSPolygon {
    /// Parses a polygon.
    static func parse(_ input: Parser) -> Result<CSSPolygon, BasicParseError> {
        // Try to parse fill rule
        var fillRule: CSSFillRule = .nonzero
        if input.tryParse({ $0.expectIdentMatching("nonzero") }).isOK {
            fillRule = .nonzero
            _ = input.tryParse { $0.expectComma() }
        } else if input.tryParse({ $0.expectIdentMatching("evenodd") }).isOK {
            fillRule = .evenodd
            _ = input.tryParse { $0.expectComma() }
        }

        // Parse comma-separated points
        var points: [CSSPoint] = []
        while !input.isExhausted {
            guard case let .success(point) = CSSPoint.parse(input) else {
                break
            }
            points.append(point)

            if input.tryParse({ $0.expectComma() }).isOK {
                continue
            }
            break
        }

        if points.isEmpty {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(CSSPolygon(fillRule: fillRule, points: points))
    }
}

extension CSSPoint {
    /// Parses a point.
    static func parse(_ input: Parser) -> Result<CSSPoint, BasicParseError> {
        guard case let .success(x) = CSSLengthPercentage.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }
        guard case let .success(y) = CSSLengthPercentage.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }
        return .success(CSSPoint(x: x, y: y))
    }
}

extension CSSFillRule {
    /// Parses a fill rule.
    static func parse(_ input: Parser) -> Result<CSSFillRule, BasicParseError> {
        let location = input.currentSourceLocation()

        switch input.next() {
        case let .success(token):
            guard case let .ident(ident) = token else {
                return .failure(location.newBasicUnexpectedTokenError(token))
            }
            switch ident.value.lowercased() {
            case "nonzero":
                return .success(.nonzero)
            case "evenodd":
                return .success(.evenodd)
            default:
                return .failure(location.newBasicUnexpectedTokenError(token))
            }
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension CSSPath {
    /// Parses a path.
    static func parse(_ input: Parser) -> Result<CSSPath, BasicParseError> {
        // Try to parse fill rule
        var fillRule: CSSFillRule = .nonzero
        if input.tryParse({ $0.expectIdentMatching("nonzero") }).isOK {
            fillRule = .nonzero
            _ = input.tryParse { $0.expectComma() }
        } else if input.tryParse({ $0.expectIdentMatching("evenodd") }).isOK {
            fillRule = .evenodd
            _ = input.tryParse { $0.expectComma() }
        }

        // Parse the path string
        let location = input.currentSourceLocation()
        switch input.next() {
        case let .success(token):
            guard case let .quotedString(pathString) = token else {
                return .failure(location.newBasicUnexpectedTokenError(token))
            }
            return .success(CSSPath(fillRule: fillRule, path: String(pathString.value)))
        case let .failure(error):
            return .failure(error)
        }
    }
}

// MARK: - Serialization

extension CSSBasicShape: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .inset(inset):
            dest.write("inset(")
            inset.serializeContent(dest: &dest)
            dest.write(")")
        case let .circle(circle):
            dest.write("circle(")
            circle.serializeContent(dest: &dest)
            dest.write(")")
        case let .ellipse(ellipse):
            dest.write("ellipse(")
            ellipse.serializeContent(dest: &dest)
            dest.write(")")
        case let .polygon(polygon):
            dest.write("polygon(")
            polygon.serializeContent(dest: &dest)
            dest.write(")")
        case let .path(path):
            dest.write("path(")
            path.serializeContent(dest: &dest)
            dest.write(")")
        }
    }
}

extension CSSInsetRect {
    func serializeContent(dest: inout some CSSWriter) {
        rect.top.serialize(dest: &dest)

        // Only output values that differ from defaults
        let allSame = rect.top == rect.right && rect.top == rect.bottom && rect.top == rect.left
        let verticalSame = rect.top == rect.bottom
        let horizontalSame = rect.right == rect.left

        if !allSame {
            dest.write(" ")
            rect.right.serialize(dest: &dest)

            if !verticalSame || !horizontalSame {
                dest.write(" ")
                rect.bottom.serialize(dest: &dest)

                if !horizontalSame {
                    dest.write(" ")
                    rect.left.serialize(dest: &dest)
                }
            }
        }

        if let radius {
            dest.write(" round ")
            radius.serialize(dest: &dest)
        }
    }
}

extension CSSCircle {
    func serializeContent(dest: inout some CSSWriter) {
        var hasOutput = false

        if radius != .closestSide {
            radius.serialize(dest: &dest)
            hasOutput = true
        }

        if position != .center {
            if hasOutput {
                dest.write(" ")
            }
            dest.write("at ")
            position.serialize(dest: &dest)
        }
    }
}

extension CSSEllipse {
    func serializeContent(dest: inout some CSSWriter) {
        var hasOutput = false

        if radiusX != .closestSide || radiusY != .closestSide {
            radiusX.serialize(dest: &dest)
            dest.write(" ")
            radiusY.serialize(dest: &dest)
            hasOutput = true
        }

        if position != .center {
            if hasOutput {
                dest.write(" ")
            }
            dest.write("at ")
            position.serialize(dest: &dest)
        }
    }
}

extension CSSShapeRadius: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .lengthPercentage(lp):
            lp.serialize(dest: &dest)
        case .closestSide:
            dest.write("closest-side")
        case .farthestSide:
            dest.write("farthest-side")
        }
    }
}

extension CSSPolygon {
    func serializeContent(dest: inout some CSSWriter) {
        if fillRule != .nonzero {
            dest.write(fillRule.rawValue)
            dest.write(", ")
        }

        for (i, point) in points.enumerated() {
            if i > 0 {
                dest.write(", ")
            }
            point.serialize(dest: &dest)
        }
    }
}

extension CSSPoint: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        x.serialize(dest: &dest)
        dest.write(" ")
        y.serialize(dest: &dest)
    }
}

extension CSSFillRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSPath {
    func serializeContent(dest: inout some CSSWriter) {
        if fillRule != .nonzero {
            dest.write(fillRule.rawValue)
            dest.write(", ")
        }
        dest.write("\"")
        dest.write(path)
        dest.write("\"")
    }
}

// MARK: - Border Radius Value for Inset

/// A border radius value for use in inset() shapes.
/// This is a simplified version that supports the same syntax as border-radius.
public struct CSSBorderRadiusValue: Equatable, Sendable, Hashable {
    /// Top-left corner radius.
    public let topLeft: CSSCornerRadius

    /// Top-right corner radius.
    public let topRight: CSSCornerRadius

    /// Bottom-right corner radius.
    public let bottomRight: CSSCornerRadius

    /// Bottom-left corner radius.
    public let bottomLeft: CSSCornerRadius

    /// Creates a border radius value.
    public init(
        topLeft: CSSCornerRadius,
        topRight: CSSCornerRadius,
        bottomRight: CSSCornerRadius,
        bottomLeft: CSSCornerRadius
    ) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomRight = bottomRight
        self.bottomLeft = bottomLeft
    }

    /// Creates a uniform border radius.
    public init(all: CSSLengthPercentage) {
        let corner = CSSCornerRadius(horizontal: all, vertical: all)
        topLeft = corner
        topRight = corner
        bottomRight = corner
        bottomLeft = corner
    }
}

/// A corner radius with horizontal and vertical components.
public struct CSSCornerRadius: Equatable, Sendable, Hashable {
    /// The horizontal radius.
    public let horizontal: CSSLengthPercentage

    /// The vertical radius.
    public let vertical: CSSLengthPercentage

    /// Creates a corner radius.
    public init(horizontal: CSSLengthPercentage, vertical: CSSLengthPercentage) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

    /// Creates a symmetric corner radius.
    public init(radius: CSSLengthPercentage) {
        horizontal = radius
        vertical = radius
    }
}

extension CSSBorderRadiusValue {
    /// Parses a border radius value.
    static func parse(_ input: Parser) -> Result<CSSBorderRadiusValue, BasicParseError> {
        // Parse horizontal radii
        guard case let .success(h1) = CSSLengthPercentage.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let h2: CSSLengthPercentage = if case let .success(val) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
            val
        } else {
            h1
        }

        let h3: CSSLengthPercentage = if case let .success(val) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
            val
        } else {
            h1
        }

        let h4: CSSLengthPercentage = if case let .success(val) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
            val
        } else {
            h2
        }

        // Check for "/" and vertical radii
        var v1 = h1, v2 = h2, v3 = h3, v4 = h4

        if input.tryParse({ $0.expectDelim("/") }).isOK {
            guard case let .success(vv1) = CSSLengthPercentage.parse(input) else {
                return .failure(input.newBasicError(.endOfInput))
            }
            v1 = vv1

            if case let .success(val) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
                v2 = val
            } else {
                v2 = v1
            }

            if case let .success(val) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
                v3 = val
            } else {
                v3 = v1
            }

            if case let .success(val) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
                v4 = val
            } else {
                v4 = v2
            }
        }

        return .success(CSSBorderRadiusValue(
            topLeft: CSSCornerRadius(horizontal: h1, vertical: v1),
            topRight: CSSCornerRadius(horizontal: h2, vertical: v2),
            bottomRight: CSSCornerRadius(horizontal: h3, vertical: v3),
            bottomLeft: CSSCornerRadius(horizontal: h4, vertical: v4)
        ))
    }
}

extension CSSBorderRadiusValue: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        // Serialize horizontal values
        topLeft.horizontal.serialize(dest: &dest)

        let allHSame = topLeft.horizontal == topRight.horizontal &&
            topLeft.horizontal == bottomRight.horizontal &&
            topLeft.horizontal == bottomLeft.horizontal

        if !allHSame {
            dest.write(" ")
            topRight.horizontal.serialize(dest: &dest)

            if topLeft.horizontal != bottomRight.horizontal || topRight.horizontal != bottomLeft.horizontal {
                dest.write(" ")
                bottomRight.horizontal.serialize(dest: &dest)

                if topRight.horizontal != bottomLeft.horizontal {
                    dest.write(" ")
                    bottomLeft.horizontal.serialize(dest: &dest)
                }
            }
        }

        // Check if we need vertical values
        let needsVertical = topLeft.horizontal != topLeft.vertical ||
            topRight.horizontal != topRight.vertical ||
            bottomRight.horizontal != bottomRight.vertical ||
            bottomLeft.horizontal != bottomLeft.vertical

        if needsVertical {
            dest.write(" / ")
            topLeft.vertical.serialize(dest: &dest)

            let allVSame = topLeft.vertical == topRight.vertical &&
                topLeft.vertical == bottomRight.vertical &&
                topLeft.vertical == bottomLeft.vertical

            if !allVSame {
                dest.write(" ")
                topRight.vertical.serialize(dest: &dest)

                if topLeft.vertical != bottomRight.vertical || topRight.vertical != bottomLeft.vertical {
                    dest.write(" ")
                    bottomRight.vertical.serialize(dest: &dest)

                    if topRight.vertical != bottomLeft.vertical {
                        dest.write(" ")
                        bottomLeft.vertical.serialize(dest: &dest)
                    }
                }
            }
        }
    }
}

// MARK: - Shape Outside

/// A value for the `shape-outside` property.
/// https://www.w3.org/TR/css-shapes-1/#shape-outside-property
public enum CSSShapeOutside: Equatable, Sendable, Hashable {
    /// No float area is created.
    case none

    /// A basic shape with an optional reference box.
    case shape(CSSBasicShape, CSSShapeBox?)

    /// A reference box only.
    case box(CSSShapeBox)

    /// An image whose alpha channel is used to define the float area.
    case image(CSSImage)
}

/// A `<shape-box>` value used in shape properties.
/// https://www.w3.org/TR/css-shapes-1/#typedef-shape-box
public enum CSSShapeBox: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The margin box.
    case marginBox = "margin-box"

    /// The border box.
    case borderBox = "border-box"

    /// The padding box.
    case paddingBox = "padding-box"

    /// The content box.
    case contentBox = "content-box"
}

extension CSSShapeBox {
    /// Parses a shape box.
    static func parse(_ input: Parser) -> Result<CSSShapeBox, BasicParseError> {
        let location = input.currentSourceLocation()
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "margin-box": return .success(.marginBox)
        case "border-box": return .success(.borderBox)
        case "padding-box": return .success(.paddingBox)
        case "content-box": return .success(.contentBox)
        default:
            return .failure(location.newBasicUnexpectedTokenError(.ident(ident)))
        }
    }
}

extension CSSShapeOutside {
    /// Parses a shape-outside value.
    static func parse(_ input: Parser) -> Result<CSSShapeOutside, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        // Try image
        if case let .success(image) = input.tryParse({ CSSImage.parse($0) }) {
            return .success(.image(image))
        }

        // Try basic shape with optional box
        var shape: CSSBasicShape?
        var box: CSSShapeBox?

        // Try box first, then shape
        if case let .success(b) = input.tryParse({ CSSShapeBox.parse($0) }) {
            box = b
        }

        if case let .success(s) = input.tryParse({ CSSBasicShape.parse($0) }) {
            shape = s
            // Try box after shape
            if box == nil, case let .success(b) = input.tryParse({ CSSShapeBox.parse($0) }) {
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

extension CSSShapeBox: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSShapeOutside: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case let .shape(shape, box):
            shape.serialize(dest: &dest)
            if let box {
                dest.write(" ")
                box.serialize(dest: &dest)
            }
        case let .box(box):
            box.serialize(dest: &dest)
        case let .image(image):
            image.serialize(dest: &dest)
        }
    }
}
