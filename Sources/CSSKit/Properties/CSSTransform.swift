// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

// MARK: - Transform List

/// A value for the `transform` property.
/// https://www.w3.org/TR/2019/CR-css-transforms-1-20190214/#propdef-transform
public struct CSSTransformList: Equatable, Sendable, Hashable {
    /// The list of transforms.
    public var transforms: [CSSTransform]

    public init(transforms: [CSSTransform]) {
        self.transforms = transforms
    }

    /// Creates a transform list representing "none".
    public static var none: Self {
        Self(transforms: [])
    }

    /// Converts the transform list to a 3D matrix if possible.
    public var matrix: CSSMatrix3d? {
        var matrix = CSSMatrix3d.identity
        for transform in transforms {
            guard let m = transform.matrix else {
                return nil
            }
            matrix = m.multiply(matrix)
        }
        return matrix
    }
}

// MARK: - Transform

/// An individual transform function.
/// https://www.w3.org/TR/2019/CR-css-transforms-1-20190214/#two-d-transform-functions
public enum CSSTransform: Equatable, Sendable, Hashable {
    /// A 2D translation.
    case translate(CSSLengthPercentage, CSSLengthPercentage)
    /// A translation in the X direction.
    case translateX(CSSLengthPercentage)
    /// A translation in the Y direction.
    case translateY(CSSLengthPercentage)
    /// A translation in the Z direction.
    case translateZ(CSSLength)
    /// A 3D translation.
    case translate3d(CSSLengthPercentage, CSSLengthPercentage, CSSLength)
    /// A 2D scale.
    case scale(CSSNumberOrPercentage, CSSNumberOrPercentage)
    /// A scale in the X direction.
    case scaleX(CSSNumberOrPercentage)
    /// A scale in the Y direction.
    case scaleY(CSSNumberOrPercentage)
    /// A scale in the Z direction.
    case scaleZ(CSSNumberOrPercentage)
    /// A 3D scale.
    case scale3d(CSSNumberOrPercentage, CSSNumberOrPercentage, CSSNumberOrPercentage)
    /// A 2D rotation.
    case rotate(CSSAngle)
    /// A rotation around the X axis.
    case rotateX(CSSAngle)
    /// A rotation around the Y axis.
    case rotateY(CSSAngle)
    /// A rotation around the Z axis.
    case rotateZ(CSSAngle)
    /// A 3D rotation.
    case rotate3d(Double, Double, Double, CSSAngle)
    /// A 2D skew.
    case skew(CSSAngle, CSSAngle)
    /// A skew along the X axis.
    case skewX(CSSAngle)
    /// A skew along the Y axis.
    case skewY(CSSAngle)
    /// A perspective transform.
    case perspective(CSSLength)
    /// A 2D matrix transform.
    case matrix(CSSMatrix)
    /// A 3D matrix transform.
    case matrix3d(CSSMatrix3d)
}

// MARK: - Matrix

/// A 2D matrix.
public struct CSSMatrix: Equatable, Sendable, Hashable {
    public var a: Double
    public var b: Double
    public var c: Double
    public var d: Double
    public var e: Double
    public var f: Double

    public init(a: Double, b: Double, c: Double, d: Double, e: Double, f: Double) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.e = e
        self.f = f
    }

    /// Converts the matrix to a 3D matrix.
    public var matrix3d: CSSMatrix3d {
        CSSMatrix3d(
            m11: a, m12: b, m13: 0, m14: 0,
            m21: c, m22: d, m23: 0, m24: 0,
            m31: 0, m32: 0, m33: 1, m34: 0,
            m41: e, m42: f, m43: 0, m44: 1
        )
    }
}

// MARK: - Matrix3d

/// A 3D matrix.
public struct CSSMatrix3d: Equatable, Sendable, Hashable {
    public var m11: Double
    public var m12: Double
    public var m13: Double
    public var m14: Double
    public var m21: Double
    public var m22: Double
    public var m23: Double
    public var m24: Double
    public var m31: Double
    public var m32: Double
    public var m33: Double
    public var m34: Double
    public var m41: Double
    public var m42: Double
    public var m43: Double
    public var m44: Double

    public init(
        m11: Double, m12: Double, m13: Double, m14: Double,
        m21: Double, m22: Double, m23: Double, m24: Double,
        m31: Double, m32: Double, m33: Double, m34: Double,
        m41: Double, m42: Double, m43: Double, m44: Double
    ) {
        self.m11 = m11
        self.m12 = m12
        self.m13 = m13
        self.m14 = m14
        self.m21 = m21
        self.m22 = m22
        self.m23 = m23
        self.m24 = m24
        self.m31 = m31
        self.m32 = m32
        self.m33 = m33
        self.m34 = m34
        self.m41 = m41
        self.m42 = m42
        self.m43 = m43
        self.m44 = m44
    }

    /// Creates an identity matrix.
    public static var identity: Self {
        Self(
            m11: 1, m12: 0, m13: 0, m14: 0,
            m21: 0, m22: 1, m23: 0, m24: 0,
            m31: 0, m32: 0, m33: 1, m34: 0,
            m41: 0, m42: 0, m43: 0, m44: 1
        )
    }

    /// Creates a translation matrix.
    public static func translate(x: Double, y: Double, z: Double) -> Self {
        Self(
            m11: 1, m12: 0, m13: 0, m14: 0,
            m21: 0, m22: 1, m23: 0, m24: 0,
            m31: 0, m32: 0, m33: 1, m34: 0,
            m41: x, m42: y, m43: z, m44: 1
        )
    }

    /// Creates a scale matrix.
    public static func scale(x: Double, y: Double, z: Double) -> Self {
        Self(
            m11: x, m12: 0, m13: 0, m14: 0,
            m21: 0, m22: y, m23: 0, m24: 0,
            m31: 0, m32: 0, m33: z, m34: 0,
            m41: 0, m42: 0, m43: 0, m44: 1
        )
    }

    /// Creates a rotation matrix.
    public static func rotate(x: Double, y: Double, z: Double, angle: Double) -> Self {
        // Normalize the vector
        let length = sqrt(x * x + y * y + z * z)
        if length == 0 {
            return .identity
        }

        let x = x / length
        let y = y / length
        let z = z / length

        let halfAngle = angle / 2
        let sin = Foundation.sin(halfAngle)
        let sc = sin * cos(halfAngle)
        let sq = sin * sin

        let m11 = 1 - 2 * (y * y + z * z) * sq
        let m12 = 2 * (x * y * sq + z * sc)
        let m13 = 2 * (x * z * sq - y * sc)
        let m21 = 2 * (x * y * sq - z * sc)
        let m22 = 1 - 2 * (x * x + z * z) * sq
        let m23 = 2 * (y * z * sq + x * sc)
        let m31 = 2 * (x * z * sq + y * sc)
        let m32 = 2 * (y * z * sq - x * sc)
        let m33 = 1 - 2 * (x * x + y * y) * sq

        return Self(
            m11: m11, m12: m12, m13: m13, m14: 0,
            m21: m21, m22: m22, m23: m23, m24: 0,
            m31: m31, m32: m32, m33: m33, m34: 0,
            m41: 0, m42: 0, m43: 0, m44: 1
        )
    }

    /// Creates a skew matrix.
    public static func skew(a: Double, b: Double) -> Self {
        Self(
            m11: 1, m12: tan(b), m13: 0, m14: 0,
            m21: tan(a), m22: 1, m23: 0, m24: 0,
            m31: 0, m32: 0, m33: 1, m34: 0,
            m41: 0, m42: 0, m43: 0, m44: 1
        )
    }

    /// Creates a perspective matrix.
    public static func perspective(d: Double) -> Self {
        Self(
            m11: 1, m12: 0, m13: 0, m14: 0,
            m21: 0, m22: 1, m23: 0, m24: 0,
            m31: 0, m32: 0, m33: 1, m34: -1 / d,
            m41: 0, m42: 0, m43: 0, m44: 1
        )
    }

    /// Multiplies this matrix by another, returning a new matrix.
    public func multiply(_ other: Self) -> Self {
        Self(
            m11: m11 * other.m11 + m12 * other.m21 + m13 * other.m31 + m14 * other.m41,
            m12: m11 * other.m12 + m12 * other.m22 + m13 * other.m32 + m14 * other.m42,
            m13: m11 * other.m13 + m12 * other.m23 + m13 * other.m33 + m14 * other.m43,
            m14: m11 * other.m14 + m12 * other.m24 + m13 * other.m34 + m14 * other.m44,
            m21: m21 * other.m11 + m22 * other.m21 + m23 * other.m31 + m24 * other.m41,
            m22: m21 * other.m12 + m22 * other.m22 + m23 * other.m32 + m24 * other.m42,
            m23: m21 * other.m13 + m22 * other.m23 + m23 * other.m33 + m24 * other.m43,
            m24: m21 * other.m14 + m22 * other.m24 + m23 * other.m34 + m24 * other.m44,
            m31: m31 * other.m11 + m32 * other.m21 + m33 * other.m31 + m34 * other.m41,
            m32: m31 * other.m12 + m32 * other.m22 + m33 * other.m32 + m34 * other.m42,
            m33: m31 * other.m13 + m32 * other.m23 + m33 * other.m33 + m34 * other.m43,
            m34: m31 * other.m14 + m32 * other.m24 + m33 * other.m34 + m34 * other.m44,
            m41: m41 * other.m11 + m42 * other.m21 + m43 * other.m31 + m44 * other.m41,
            m42: m41 * other.m12 + m42 * other.m22 + m43 * other.m32 + m44 * other.m42,
            m43: m41 * other.m13 + m42 * other.m23 + m43 * other.m33 + m44 * other.m43,
            m44: m41 * other.m14 + m42 * other.m24 + m43 * other.m34 + m44 * other.m44
        )
    }

    /// Returns whether this matrix could be converted to a 2D matrix.
    public var is2D: Bool {
        m31 == 0 && m32 == 0 && m13 == 0 && m23 == 0 && m43 == 0 &&
            m14 == 0 && m24 == 0 && m34 == 0 && m33 == 1 && m44 == 1
    }

    /// Attempts to convert the matrix to 2D.
    public var matrix2D: CSSMatrix? {
        guard is2D else { return nil }
        return CSSMatrix(a: m11, b: m12, c: m21, d: m22, e: m41, f: m42)
    }

    /// Scales the matrix by the given factor.
    public mutating func scaleByFactor(_ factor: Double) {
        m11 *= factor; m12 *= factor; m13 *= factor; m14 *= factor
        m21 *= factor; m22 *= factor; m23 *= factor; m24 *= factor
        m31 *= factor; m32 *= factor; m33 *= factor; m34 *= factor
        m41 *= factor; m42 *= factor; m43 *= factor; m44 *= factor
    }

    /// Returns the determinant of the matrix.
    public var determinant: Double {
        m14 * m23 * m32 * m41 - m13 * m24 * m32 * m41 - m14 * m22 * m33 * m41 +
            m12 * m24 * m33 * m41 + m13 * m22 * m34 * m41 - m12 * m23 * m34 * m41 -
            m14 * m23 * m31 * m42 + m13 * m24 * m31 * m42 + m14 * m21 * m33 * m42 -
            m11 * m24 * m33 * m42 - m13 * m21 * m34 * m42 + m11 * m23 * m34 * m42 +
            m14 * m22 * m31 * m43 - m12 * m24 * m31 * m43 - m14 * m21 * m32 * m43 +
            m11 * m24 * m32 * m43 + m12 * m21 * m34 * m43 - m11 * m22 * m34 * m43 -
            m13 * m22 * m31 * m44 + m12 * m23 * m31 * m44 + m13 * m21 * m32 * m44 -
            m11 * m23 * m32 * m44 - m12 * m21 * m33 * m44 + m11 * m22 * m33 * m44
    }

    /// Returns the inverse of the matrix if possible.
    public func inverse() -> Self? {
        var det = determinant
        guard det != 0 else { return nil }

        det = 1 / det
        return Self(
            m11: det * (m23 * m34 * m42 - m24 * m33 * m42 + m24 * m32 * m43 -
                m22 * m34 * m43 - m23 * m32 * m44 + m22 * m33 * m44),
            m12: det * (m14 * m33 * m42 - m13 * m34 * m42 - m14 * m32 * m43 +
                m12 * m34 * m43 + m13 * m32 * m44 - m12 * m33 * m44),
            m13: det * (m13 * m24 * m42 - m14 * m23 * m42 + m14 * m22 * m43 -
                m12 * m24 * m43 - m13 * m22 * m44 + m12 * m23 * m44),
            m14: det * (m14 * m23 * m32 - m13 * m24 * m32 - m14 * m22 * m33 +
                m12 * m24 * m33 + m13 * m22 * m34 - m12 * m23 * m34),
            m21: det * (m24 * m33 * m41 - m23 * m34 * m41 - m24 * m31 * m43 +
                m21 * m34 * m43 + m23 * m31 * m44 - m21 * m33 * m44),
            m22: det * (m13 * m34 * m41 - m14 * m33 * m41 + m14 * m31 * m43 -
                m11 * m34 * m43 - m13 * m31 * m44 + m11 * m33 * m44),
            m23: det * (m14 * m23 * m41 - m13 * m24 * m41 - m14 * m21 * m43 +
                m11 * m24 * m43 + m13 * m21 * m44 - m11 * m23 * m44),
            m24: det * (m13 * m24 * m31 - m14 * m23 * m31 + m14 * m21 * m33 -
                m11 * m24 * m33 - m13 * m21 * m34 + m11 * m23 * m34),
            m31: det * (m22 * m34 * m41 - m24 * m32 * m41 + m24 * m31 * m42 -
                m21 * m34 * m42 - m22 * m31 * m44 + m21 * m32 * m44),
            m32: det * (m14 * m32 * m41 - m12 * m34 * m41 - m14 * m31 * m42 +
                m11 * m34 * m42 + m12 * m31 * m44 - m11 * m32 * m44),
            m33: det * (m12 * m24 * m41 - m14 * m22 * m41 + m14 * m21 * m42 -
                m11 * m24 * m42 - m12 * m21 * m44 + m11 * m22 * m44),
            m34: det * (m14 * m22 * m31 - m12 * m24 * m31 - m14 * m21 * m32 +
                m11 * m24 * m32 + m12 * m21 * m34 - m11 * m22 * m34),
            m41: det * (m23 * m32 * m41 - m22 * m33 * m41 - m23 * m31 * m42 +
                m21 * m33 * m42 + m22 * m31 * m43 - m21 * m32 * m43),
            m42: det * (m12 * m33 * m41 - m13 * m32 * m41 + m13 * m31 * m42 -
                m11 * m33 * m42 - m12 * m31 * m43 + m11 * m32 * m43),
            m43: det * (m13 * m22 * m41 - m12 * m23 * m41 - m13 * m21 * m42 +
                m11 * m23 * m42 + m12 * m21 * m43 - m11 * m22 * m43),
            m44: det * (m12 * m23 * m31 - m13 * m22 * m31 + m13 * m21 * m32 -
                m11 * m23 * m32 - m12 * m21 * m33 + m11 * m22 * m33)
        )
    }

    /// Transposes the matrix.
    public func transpose() -> Self {
        Self(
            m11: m11, m12: m21, m13: m31, m14: m41,
            m21: m12, m22: m22, m23: m32, m24: m42,
            m31: m13, m32: m23, m33: m33, m34: m43,
            m41: m14, m42: m24, m43: m34, m44: m44
        )
    }

    /// Multiplies a vector by the matrix.
    public func multiplyVector(_ v: (Double, Double, Double, Double)) -> (Double, Double, Double, Double) {
        (
            v.0 * m11 + v.1 * m21 + v.2 * m31 + v.3 * m41,
            v.0 * m12 + v.1 * m22 + v.2 * m32 + v.3 * m42,
            v.0 * m13 + v.1 * m23 + v.2 * m33 + v.3 * m43,
            v.0 * m14 + v.1 * m24 + v.2 * m34 + v.3 * m44
        )
    }
}

// MARK: - Transform to Matrix

public extension CSSTransform {
    /// Converts the transform to a 3D matrix.
    var matrix: CSSMatrix3d? {
        switch self {
        case let .translate(x, y):
            if case let .dimension(xLen) = x, case let .dimension(yLen) = y,
               let xPx = xLen.pixels, let yPx = yLen.pixels
            {
                return .translate(x: xPx, y: yPx, z: 0)
            }
        case let .translateX(x):
            if case let .dimension(xLen) = x, let xPx = xLen.pixels {
                return .translate(x: xPx, y: 0, z: 0)
            }
        case let .translateY(y):
            if case let .dimension(yLen) = y, let yPx = yLen.pixels {
                return .translate(x: 0, y: yPx, z: 0)
            }
        case let .translateZ(z):
            if let zPx = z.pixels {
                return .translate(x: 0, y: 0, z: zPx)
            }
        case let .translate3d(x, y, z):
            if case let .dimension(xLen) = x, case let .dimension(yLen) = y,
               let xPx = xLen.pixels, let yPx = yLen.pixels, let zPx = z.pixels
            {
                return .translate(x: xPx, y: yPx, z: zPx)
            }
        case let .scale(x, y):
            return .scale(x: x.unitValue, y: y.unitValue, z: 1)
        case let .scaleX(x):
            return .scale(x: x.unitValue, y: 1, z: 1)
        case let .scaleY(y):
            return .scale(x: 1, y: y.unitValue, z: 1)
        case let .scaleZ(z):
            return .scale(x: 1, y: 1, z: z.unitValue)
        case let .scale3d(x, y, z):
            return .scale(x: x.unitValue, y: y.unitValue, z: z.unitValue)
        case let .rotate(angle), let .rotateZ(angle):
            let rad = angle.radians
            guard rad >= 0, rad < 2 * .pi else { return nil }
            return .rotate(x: 0, y: 0, z: 1, angle: rad)
        case let .rotateX(angle):
            let rad = angle.radians
            guard rad >= 0, rad < 2 * .pi else { return nil }
            return .rotate(x: 1, y: 0, z: 0, angle: rad)
        case let .rotateY(angle):
            let rad = angle.radians
            guard rad >= 0, rad < 2 * .pi else { return nil }
            return .rotate(x: 0, y: 1, z: 0, angle: rad)
        case let .rotate3d(x, y, z, angle):
            let rad = angle.radians
            guard rad >= 0, rad < 2 * .pi else { return nil }
            return .rotate(x: x, y: y, z: z, angle: rad)
        case let .skew(x, y):
            let xRad = x.radians
            let yRad = y.radians
            guard xRad >= 0, xRad < 2 * .pi, yRad >= 0, yRad < 2 * .pi else { return nil }
            return .skew(a: xRad, b: yRad)
        case let .skewX(x):
            let xRad = x.radians
            guard xRad >= 0, xRad < 2 * .pi else { return nil }
            return .skew(a: xRad, b: 0)
        case let .skewY(y):
            let yRad = y.radians
            guard yRad >= 0, yRad < 2 * .pi else { return nil }
            return .skew(a: 0, b: yRad)
        case let .perspective(len):
            if let px = len.pixels {
                return .perspective(d: px)
            }
        case let .matrix(m):
            return m.matrix3d
        case let .matrix3d(m):
            return m
        }
        return nil
    }
}

// MARK: - Transform Style

/// A value for the `transform-style` property.
/// https://drafts.csswg.org/css-transforms-2/#transform-style-property
public enum CSSTransformStyle: String, Equatable, Sendable, Hashable, CaseIterable {
    case flat
    case preserve3d = "preserve-3d"

    /// The default value (flat).
    public static var `default`: Self { .flat }
}

// MARK: - Transform Box

/// A value for the `transform-box` property.
/// https://drafts.csswg.org/css-transforms-1/#transform-box
public enum CSSTransformBox: String, Equatable, Sendable, Hashable, CaseIterable {
    /// Uses the content box as reference box.
    case contentBox = "content-box"
    /// Uses the border box as reference box.
    case borderBox = "border-box"
    /// Uses the object bounding box as reference box.
    case fillBox = "fill-box"
    /// Uses the stroke bounding box as reference box.
    case strokeBox = "stroke-box"
    /// Uses the nearest SVG viewport as reference box.
    case viewBox = "view-box"

    /// The default value (view-box).
    public static var `default`: Self { .viewBox }
}

// MARK: - Backface Visibility

/// A value for the `backface-visibility` property.
/// https://drafts.csswg.org/css-transforms-2/#backface-visibility-property
public enum CSSBackfaceVisibility: String, Equatable, Sendable, Hashable, CaseIterable {
    case visible
    case hidden

    /// The default value (visible).
    public static var `default`: Self { .visible }
}

// MARK: - Perspective Property

/// A value for the `perspective` property.
/// https://drafts.csswg.org/css-transforms-2/#perspective-property
public enum CSSPerspectiveProperty: Equatable, Sendable, Hashable {
    /// No perspective transform is applied.
    case none
    /// Distance to the center of projection.
    case length(CSSLength)

    /// The default value (none).
    public static var `default`: Self { .none }
}

// MARK: - Translate Property

/// A value for the `translate` property.
/// https://drafts.csswg.org/css-transforms-2/#propdef-translate
public enum CSSTranslateProperty: Equatable, Sendable, Hashable {
    /// The "none" keyword.
    case none
    /// The x, y, and z translations.
    case xyz(x: CSSLengthPercentage, y: CSSLengthPercentage, z: CSSLength)

    /// The default value (none).
    public static var `default`: Self { .none }

    /// Converts to a transform function.
    public var transform: CSSTransform {
        switch self {
        case .none:
            .translate3d(.zero, .zero, .zero)
        case let .xyz(x, y, z):
            .translate3d(x, y, z)
        }
    }
}

// MARK: - Rotate Property

/// A value for the `rotate` property.
/// https://drafts.csswg.org/css-transforms-2/#propdef-rotate
public struct CSSRotateProperty: Equatable, Sendable, Hashable {
    /// Rotation around the x axis.
    public var x: Double
    /// Rotation around the y axis.
    public var y: Double
    /// Rotation around the z axis.
    public var z: Double
    /// The angle of rotation.
    public var angle: CSSAngle

    public init(x: Double = 0, y: Double = 0, z: Double = 1, angle: CSSAngle) {
        self.x = x
        self.y = y
        self.z = z
        self.angle = angle
    }

    /// The default value (none / 0deg).
    public static var `default`: Self {
        Self(x: 0, y: 0, z: 1, angle: .deg(0))
    }

    /// Converts to a transform function.
    public var transform: CSSTransform {
        .rotate3d(x, y, z, angle)
    }
}

// MARK: - Scale Property

/// A value for the `scale` property.
/// https://drafts.csswg.org/css-transforms-2/#propdef-scale
public enum CSSScaleProperty: Equatable, Sendable, Hashable {
    /// The "none" keyword.
    case none
    /// Scale on the x, y, and z axis.
    case xyz(x: CSSNumberOrPercentage, y: CSSNumberOrPercentage, z: CSSNumberOrPercentage)

    /// The default value (none).
    public static var `default`: Self { .none }

    /// Converts to a transform function.
    public var transform: CSSTransform {
        switch self {
        case .none:
            .scale3d(.number(1), .number(1), .number(1))
        case let .xyz(x, y, z):
            .scale3d(x, y, z)
        }
    }
}

// MARK: - Parsing

extension CSSTransformList {
    static func parse(_ input: Parser) -> Result<CSSTransformList, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        var transforms: [CSSTransform] = []
        while case let .success(transform) = input.tryParse({ CSSTransform.parse($0) }) {
            transforms.append(transform)
        }

        if transforms.isEmpty {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(CSSTransformList(transforms: transforms))
    }
}

extension CSSTransform {
    static func parse(_ input: Parser) -> Result<CSSTransform, BasicParseError> {
        let location = input.currentSourceLocation()

        guard case let .success(token) = input.next() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        guard case let .function(name) = token else {
            return .failure(location.newBasicUnexpectedTokenError(token))
        }

        let functionName = name.value.lowercased()

        let result: Result<CSSTransform, ParseError<Never>> = input.parseNestedBlock { args in
            switch functionName {
            case "matrix":
                guard case let .success(a) = args.expectNumber() else {
                    return .failure(args.newError(.endOfInput))
                }
                guard args.expectComma().isOK else {
                    return .failure(args.newError(.endOfInput))
                }
                guard case let .success(b) = args.expectNumber() else {
                    return .failure(args.newError(.endOfInput))
                }
                guard args.expectComma().isOK else {
                    return .failure(args.newError(.endOfInput))
                }
                guard case let .success(c) = args.expectNumber() else {
                    return .failure(args.newError(.endOfInput))
                }
                guard args.expectComma().isOK else {
                    return .failure(args.newError(.endOfInput))
                }
                guard case let .success(d) = args.expectNumber() else {
                    return .failure(args.newError(.endOfInput))
                }
                guard args.expectComma().isOK else {
                    return .failure(args.newError(.endOfInput))
                }
                guard case let .success(e) = args.expectNumber() else {
                    return .failure(args.newError(.endOfInput))
                }
                guard args.expectComma().isOK else {
                    return .failure(args.newError(.endOfInput))
                }
                guard case let .success(f) = args.expectNumber() else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.matrix(CSSMatrix(a: a, b: b, c: c, d: d, e: e, f: f)))

            case "matrix3d":
                var values: [Double] = []
                for i in 0 ..< 16 {
                    if i > 0 {
                        guard args.expectComma().isOK else {
                            return .failure(args.newError(.endOfInput))
                        }
                    }
                    guard case let .success(v) = args.expectNumber() else {
                        return .failure(args.newError(.endOfInput))
                    }
                    values.append(v)
                }
                return .success(.matrix3d(CSSMatrix3d(
                    m11: values[0], m12: values[1], m13: values[2], m14: values[3],
                    m21: values[4], m22: values[5], m23: values[6], m24: values[7],
                    m31: values[8], m32: values[9], m33: values[10], m34: values[11],
                    m41: values[12], m42: values[13], m43: values[14], m44: values[15]
                )))

            case "translate":
                guard case let .success(x) = CSSLengthPercentage.parse(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                if args.tryParse({ $0.expectComma() }).isOK {
                    guard case let .success(y) = CSSLengthPercentage.parse(args) else {
                        return .failure(args.newError(.endOfInput))
                    }
                    return .success(.translate(x, y))
                }
                return .success(.translate(x, .zero))

            case "translatex":
                guard case let .success(x) = CSSLengthPercentage.parse(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.translateX(x))

            case "translatey":
                guard case let .success(y) = CSSLengthPercentage.parse(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.translateY(y))

            case "translatez":
                guard case let .success(z) = CSSLength.parse(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.translateZ(z))

            case "translate3d":
                guard case let .success(x) = CSSLengthPercentage.parse(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                guard args.expectComma().isOK else {
                    return .failure(args.newError(.endOfInput))
                }
                guard case let .success(y) = CSSLengthPercentage.parse(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                guard args.expectComma().isOK else {
                    return .failure(args.newError(.endOfInput))
                }
                guard case let .success(z) = CSSLength.parse(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.translate3d(x, y, z))

            case "scale":
                guard case let .success(x) = CSSNumberOrPercentage.parse(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                if args.tryParse({ $0.expectComma() }).isOK {
                    guard case let .success(y) = CSSNumberOrPercentage.parse(args) else {
                        return .failure(args.newError(.endOfInput))
                    }
                    return .success(.scale(x, y))
                }
                return .success(.scale(x, x))

            case "scalex":
                guard case let .success(x) = CSSNumberOrPercentage.parse(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.scaleX(x))

            case "scaley":
                guard case let .success(y) = CSSNumberOrPercentage.parse(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.scaleY(y))

            case "scalez":
                guard case let .success(z) = CSSNumberOrPercentage.parse(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.scaleZ(z))

            case "scale3d":
                guard case let .success(x) = CSSNumberOrPercentage.parse(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                guard args.expectComma().isOK else {
                    return .failure(args.newError(.endOfInput))
                }
                guard case let .success(y) = CSSNumberOrPercentage.parse(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                guard args.expectComma().isOK else {
                    return .failure(args.newError(.endOfInput))
                }
                guard case let .success(z) = CSSNumberOrPercentage.parse(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.scale3d(x, y, z))

            case "rotate":
                guard case let .success(angle) = CSSAngle.parseWithUnitlessZero(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.rotate(angle))

            case "rotatex":
                guard case let .success(angle) = CSSAngle.parseWithUnitlessZero(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.rotateX(angle))

            case "rotatey":
                guard case let .success(angle) = CSSAngle.parseWithUnitlessZero(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.rotateY(angle))

            case "rotatez":
                guard case let .success(angle) = CSSAngle.parseWithUnitlessZero(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.rotateZ(angle))

            case "rotate3d":
                guard case let .success(x) = args.expectNumber() else {
                    return .failure(args.newError(.endOfInput))
                }
                guard args.expectComma().isOK else {
                    return .failure(args.newError(.endOfInput))
                }
                guard case let .success(y) = args.expectNumber() else {
                    return .failure(args.newError(.endOfInput))
                }
                guard args.expectComma().isOK else {
                    return .failure(args.newError(.endOfInput))
                }
                guard case let .success(z) = args.expectNumber() else {
                    return .failure(args.newError(.endOfInput))
                }
                guard args.expectComma().isOK else {
                    return .failure(args.newError(.endOfInput))
                }
                guard case let .success(angle) = CSSAngle.parseWithUnitlessZero(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.rotate3d(x, y, z, angle))

            case "skew":
                guard case let .success(x) = CSSAngle.parseWithUnitlessZero(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                if args.tryParse({ $0.expectComma() }).isOK {
                    guard case let .success(y) = CSSAngle.parseWithUnitlessZero(args) else {
                        return .failure(args.newError(.endOfInput))
                    }
                    return .success(.skew(x, y))
                }
                return .success(.skew(x, .deg(0)))

            case "skewx":
                guard case let .success(angle) = CSSAngle.parseWithUnitlessZero(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.skewX(angle))

            case "skewy":
                guard case let .success(angle) = CSSAngle.parseWithUnitlessZero(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.skewY(angle))

            case "perspective":
                guard case let .success(len) = CSSLength.parse(args) else {
                    return .failure(args.newError(.endOfInput))
                }
                return .success(.perspective(len))

            default:
                return .failure(location.newUnexpectedTokenError(.ident(name)))
            }
        }

        switch result {
        case let .success(transform):
            return .success(transform)
        case let .failure(error):
            return .failure(error.basic)
        }
    }
}

extension CSSTransformStyle {
    static func parse(_ input: Parser) -> Result<CSSTransformStyle, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        switch ident.value.lowercased() {
        case "flat":
            return .success(.flat)
        case "preserve-3d":
            return .success(.preserve3d)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSTransformBox {
    static func parse(_ input: Parser) -> Result<CSSTransformBox, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let value = ident.value.lowercased()
        if let box = CSSTransformBox.allCases.first(where: { $0.rawValue == value }) {
            return .success(box)
        }

        return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
    }
}

extension CSSBackfaceVisibility {
    static func parse(_ input: Parser) -> Result<CSSBackfaceVisibility, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        switch ident.value.lowercased() {
        case "visible":
            return .success(.visible)
        case "hidden":
            return .success(.hidden)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSPerspectiveProperty {
    static func parse(_ input: Parser) -> Result<CSSPerspectiveProperty, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        guard case let .success(len) = CSSLength.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(.length(len))
    }
}

extension CSSTranslateProperty {
    static func parse(_ input: Parser) -> Result<CSSTranslateProperty, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        guard case let .success(x) = CSSLengthPercentage.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let y: CSSLengthPercentage
        if case let .success(yVal) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
            y = yVal
        } else {
            return .success(.xyz(x: x, y: .zero, z: .zero))
        }

        let z: CSSLength = if case let .success(zVal) = input.tryParse({ CSSLength.parse($0) }) {
            zVal
        } else {
            .zero
        }

        return .success(.xyz(x: x, y: y, z: z))
    }
}

extension CSSRotateProperty {
    static func parse(_ input: Parser) -> Result<CSSRotateProperty, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.default)
        }

        // Try angle first
        let angleFirst = input.tryParse { CSSAngle.parse($0) }

        // Try axis keyword or numbers
        var x: Double = 0
        var y: Double = 0
        var z: Double = 1

        if case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
            switch ident.value.lowercased() {
            case "x":
                x = 1; y = 0; z = 0
            case "y":
                x = 0; y = 1; z = 0
            case "z":
                x = 0; y = 0; z = 1
            default:
                break
            }
        } else if case let .success(xVal) = input.tryParse({ $0.expectNumber() }) {
            if case let .success(yVal) = input.tryParse({ $0.expectNumber() }),
               case let .success(zVal) = input.tryParse({ $0.expectNumber() })
            {
                x = xVal; y = yVal; z = zVal
            }
        }

        // Get angle
        let angle: CSSAngle
        if case let .success(a) = angleFirst {
            angle = a
        } else if case let .success(a) = CSSAngle.parse(input) {
            angle = a
        } else {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(CSSRotateProperty(x: x, y: y, z: z, angle: angle))
    }
}

extension CSSScaleProperty {
    static func parse(_ input: Parser) -> Result<CSSScaleProperty, BasicParseError> {
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        guard case let .success(x) = CSSNumberOrPercentage.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let y: CSSNumberOrPercentage
        if case let .success(yVal) = input.tryParse({ CSSNumberOrPercentage.parse($0) }) {
            y = yVal
        } else {
            return .success(.xyz(x: x, y: x, z: .number(1)))
        }

        let z: CSSNumberOrPercentage = if case let .success(zVal) = input.tryParse({ CSSNumberOrPercentage.parse($0) }) {
            zVal
        } else {
            .number(1)
        }

        return .success(.xyz(x: x, y: y, z: z))
    }
}

// MARK: - ToCss

extension CSSTransformList: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if transforms.isEmpty {
            dest.write("none")
            return
        }

        for transform in transforms {
            transform.serialize(dest: &dest)
        }
    }
}

extension CSSTransform: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .translate(x, y):
            dest.write("translate(")
            x.serialize(dest: &dest)
            if !y.isZero {
                dest.write(", ")
                y.serialize(dest: &dest)
            }
            dest.write(")")

        case let .translateX(x):
            dest.write("translateX(")
            x.serialize(dest: &dest)
            dest.write(")")

        case let .translateY(y):
            dest.write("translateY(")
            y.serialize(dest: &dest)
            dest.write(")")

        case let .translateZ(z):
            dest.write("translateZ(")
            z.serialize(dest: &dest)
            dest.write(")")

        case let .translate3d(x, y, z):
            dest.write("translate3d(")
            x.serialize(dest: &dest)
            dest.write(", ")
            y.serialize(dest: &dest)
            dest.write(", ")
            z.serialize(dest: &dest)
            dest.write(")")

        case let .scale(x, y):
            dest.write("scale(")
            writeNumber(x.unitValue, dest: &dest)
            if x.unitValue != y.unitValue {
                dest.write(", ")
                writeNumber(y.unitValue, dest: &dest)
            }
            dest.write(")")

        case let .scaleX(x):
            dest.write("scaleX(")
            writeNumber(x.unitValue, dest: &dest)
            dest.write(")")

        case let .scaleY(y):
            dest.write("scaleY(")
            writeNumber(y.unitValue, dest: &dest)
            dest.write(")")

        case let .scaleZ(z):
            dest.write("scaleZ(")
            writeNumber(z.unitValue, dest: &dest)
            dest.write(")")

        case let .scale3d(x, y, z):
            dest.write("scale3d(")
            writeNumber(x.unitValue, dest: &dest)
            dest.write(", ")
            writeNumber(y.unitValue, dest: &dest)
            dest.write(", ")
            writeNumber(z.unitValue, dest: &dest)
            dest.write(")")

        case let .rotate(angle):
            dest.write("rotate(")
            angle.serializeWithUnitlessZero(dest: &dest)
            dest.write(")")

        case let .rotateX(angle):
            dest.write("rotateX(")
            angle.serializeWithUnitlessZero(dest: &dest)
            dest.write(")")

        case let .rotateY(angle):
            dest.write("rotateY(")
            angle.serializeWithUnitlessZero(dest: &dest)
            dest.write(")")

        case let .rotateZ(angle):
            dest.write("rotateZ(")
            angle.serializeWithUnitlessZero(dest: &dest)
            dest.write(")")

        case let .rotate3d(x, y, z, angle):
            dest.write("rotate3d(")
            writeNumber(x, dest: &dest)
            dest.write(", ")
            writeNumber(y, dest: &dest)
            dest.write(", ")
            writeNumber(z, dest: &dest)
            dest.write(", ")
            angle.serializeWithUnitlessZero(dest: &dest)
            dest.write(")")

        case let .skew(x, y):
            dest.write("skew(")
            x.serialize(dest: &dest)
            if !y.isZero {
                dest.write(", ")
                y.serializeWithUnitlessZero(dest: &dest)
            }
            dest.write(")")

        case let .skewX(angle):
            dest.write("skewX(")
            angle.serializeWithUnitlessZero(dest: &dest)
            dest.write(")")

        case let .skewY(angle):
            dest.write("skewY(")
            angle.serializeWithUnitlessZero(dest: &dest)
            dest.write(")")

        case let .perspective(len):
            dest.write("perspective(")
            len.serialize(dest: &dest)
            dest.write(")")

        case let .matrix(m):
            dest.write("matrix(")
            writeNumber(m.a, dest: &dest)
            dest.write(", ")
            writeNumber(m.b, dest: &dest)
            dest.write(", ")
            writeNumber(m.c, dest: &dest)
            dest.write(", ")
            writeNumber(m.d, dest: &dest)
            dest.write(", ")
            writeNumber(m.e, dest: &dest)
            dest.write(", ")
            writeNumber(m.f, dest: &dest)
            dest.write(")")

        case let .matrix3d(m):
            dest.write("matrix3d(")
            writeNumber(m.m11, dest: &dest); dest.write(", ")
            writeNumber(m.m12, dest: &dest); dest.write(", ")
            writeNumber(m.m13, dest: &dest); dest.write(", ")
            writeNumber(m.m14, dest: &dest); dest.write(", ")
            writeNumber(m.m21, dest: &dest); dest.write(", ")
            writeNumber(m.m22, dest: &dest); dest.write(", ")
            writeNumber(m.m23, dest: &dest); dest.write(", ")
            writeNumber(m.m24, dest: &dest); dest.write(", ")
            writeNumber(m.m31, dest: &dest); dest.write(", ")
            writeNumber(m.m32, dest: &dest); dest.write(", ")
            writeNumber(m.m33, dest: &dest); dest.write(", ")
            writeNumber(m.m34, dest: &dest); dest.write(", ")
            writeNumber(m.m41, dest: &dest); dest.write(", ")
            writeNumber(m.m42, dest: &dest); dest.write(", ")
            writeNumber(m.m43, dest: &dest); dest.write(", ")
            writeNumber(m.m44, dest: &dest)
            dest.write(")")
        }
    }

    private func writeNumber(_ n: Double, dest: inout some CSSWriter) {
        if n == n.rounded(), abs(n) < 1e10 {
            dest.write(String(Int(n)))
        } else {
            dest.write(String(n))
        }
    }
}

extension CSSTransformStyle: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSTransformBox: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSBackfaceVisibility: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSPerspectiveProperty: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case let .length(len):
            len.serialize(dest: &dest)
        }
    }
}

extension CSSTranslateProperty: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case let .xyz(x, y, z):
            x.serialize(dest: &dest)
            if !y.isZero || !z.isZero {
                dest.write(" ")
                y.serialize(dest: &dest)
                if !z.isZero {
                    dest.write(" ")
                    z.serialize(dest: &dest)
                }
            }
        }
    }
}

extension CSSRotateProperty: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if x == 0, y == 0, z == 1, angle.isZero {
            dest.write("none")
            return
        }

        if x == 1, y == 0, z == 0 {
            dest.write("x ")
        } else if x == 0, y == 1, z == 0 {
            dest.write("y ")
        } else if !(x == 0 && y == 0 && z == 1) {
            writeNumber(x, dest: &dest)
            dest.write(" ")
            writeNumber(y, dest: &dest)
            dest.write(" ")
            writeNumber(z, dest: &dest)
            dest.write(" ")
        }

        angle.serialize(dest: &dest)
    }

    private func writeNumber(_ n: Double, dest: inout some CSSWriter) {
        if n == n.rounded(), abs(n) < 1e10 {
            dest.write(String(Int(n)))
        } else {
            dest.write(String(n))
        }
    }
}

extension CSSScaleProperty: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case let .xyz(x, y, z):
            x.serialize(dest: &dest)
            let zVal = z.unitValue
            if y != x || zVal != 1 {
                dest.write(" ")
                y.serialize(dest: &dest)
                if zVal != 1 {
                    dest.write(" ")
                    z.serialize(dest: &dest)
                }
            }
        }
    }
}
