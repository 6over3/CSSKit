// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A CSS gradient value.
/// https://www.w3.org/TR/css-images-4/#gradients
public enum CSSGradient: Equatable, Sendable, Hashable {
    /// A linear gradient.
    case linear(CSSLinearGradient)

    /// A radial gradient.
    case radial(CSSRadialGradient)

    /// A conic gradient.
    case conic(CSSConicGradient)

    /// A repeating linear gradient.
    case repeatingLinear(CSSLinearGradient)

    /// A repeating radial gradient.
    case repeatingRadial(CSSRadialGradient)

    /// A repeating conic gradient.
    case repeatingConic(CSSConicGradient)
}

// MARK: - Linear Gradient

/// A CSS linear-gradient() value.
/// https://www.w3.org/TR/css-images-4/#linear-gradients
public struct CSSLinearGradient: Equatable, Sendable, Hashable {
    /// The direction of the gradient.
    public let direction: CSSLinearGradientDirection

    /// The color stops and interpolation hints.
    public let items: [CSSGradientItem]

    /// Creates a linear gradient.
    public init(direction: CSSLinearGradientDirection, items: [CSSGradientItem]) {
        self.direction = direction
        self.items = items
    }
}

/// The direction of a linear gradient.
public enum CSSLinearGradientDirection: Equatable, Sendable, Hashable {
    /// An angle.
    case angle(CSSAngle)

    /// A side or corner.
    case side(CSSHorizontalPositionKeyword?, CSSVerticalPositionKeyword?)
}

// MARK: - Radial Gradient

/// A CSS radial-gradient() value.
/// https://www.w3.org/TR/css-images-4/#radial-gradients
public struct CSSRadialGradient: Equatable, Sendable, Hashable {
    /// The shape of the gradient.
    public let shape: CSSRadialGradientShape

    /// The size of the gradient.
    public let size: CSSRadialGradientSize

    /// The center position.
    public let position: CSSPosition

    /// The color stops and interpolation hints.
    public let items: [CSSGradientItem]

    /// Creates a radial gradient.
    public init(
        shape: CSSRadialGradientShape = .ellipse,
        size: CSSRadialGradientSize = .farthestCorner,
        position: CSSPosition = .center,
        items: [CSSGradientItem]
    ) {
        self.shape = shape
        self.size = size
        self.position = position
        self.items = items
    }
}

/// The shape of a radial gradient.
public enum CSSRadialGradientShape: String, Equatable, Sendable, Hashable {
    case circle
    case ellipse
}

/// The size of a radial gradient.
public enum CSSRadialGradientSize: Equatable, Sendable, Hashable {
    /// Closest side.
    case closestSide
    /// Farthest side.
    case farthestSide
    /// Closest corner.
    case closestCorner
    /// Farthest corner.
    case farthestCorner
    /// Explicit length (for circle).
    case length(CSSLengthPercentage)
    /// Explicit size (for ellipse).
    case size(CSSLengthPercentage, CSSLengthPercentage)
}

// MARK: - Conic Gradient

/// A CSS conic-gradient() value.
/// https://www.w3.org/TR/css-images-4/#conic-gradients
public struct CSSConicGradient: Equatable, Sendable, Hashable {
    /// The starting angle (default 0deg).
    public let fromAngle: CSSAngle

    /// The center position.
    public let position: CSSPosition

    /// The color stops and interpolation hints.
    public let items: [CSSGradientItem]

    /// Creates a conic gradient.
    public init(
        fromAngle: CSSAngle = .zero,
        position: CSSPosition = .center,
        items: [CSSGradientItem]
    ) {
        self.fromAngle = fromAngle
        self.position = position
        self.items = items
    }
}

// MARK: - Gradient Color Stop

/// A color stop in a gradient.
/// https://www.w3.org/TR/css-images-4/#color-stop-syntax
public struct CSSGradientColorStop: Equatable, Sendable, Hashable {
    /// The color at this stop.
    public let color: Color

    /// The position of this stop (optional).
    public let position: CSSLengthPercentage?

    /// Creates a color stop.
    public init(color: Color, position: CSSLengthPercentage? = nil) {
        self.color = color
        self.position = position
    }
}

// MARK: - Gradient Item

/// A color stop or interpolation hint in a gradient.
/// https://www.w3.org/TR/css-images-4/#color-stop-syntax
public enum CSSGradientItem: Equatable, Sendable, Hashable {
    /// A color stop.
    case colorStop(CSSGradientColorStop)

    /// An interpolation hint (transition point between two colors).
    case hint(CSSLengthPercentage)
}

// MARK: - Parsing

extension CSSGradient {
    /// Parses a gradient value.
    static func parse(_ input: Parser) -> Result<CSSGradient, BasicParseError> {
        let location = input.currentSourceLocation()

        switch input.next() {
        case let .success(token):
            guard case let .function(name) = token else {
                return .failure(location.newBasicUnexpectedTokenError(token))
            }

            let funcName = name.value.lowercased()
            let result: Result<CSSGradient, ParseError<Never>> = input.parseNestedBlock { args in
                switch funcName {
                case "linear-gradient":
                    CSSLinearGradient.parse(args).map { .linear($0) }.mapError { $0.asParseError() }
                case "radial-gradient":
                    CSSRadialGradient.parse(args).map { .radial($0) }.mapError { $0.asParseError() }
                case "conic-gradient":
                    CSSConicGradient.parse(args).map { .conic($0) }.mapError { $0.asParseError() }
                case "repeating-linear-gradient":
                    CSSLinearGradient.parse(args).map { .repeatingLinear($0) }.mapError { $0.asParseError() }
                case "repeating-radial-gradient":
                    CSSRadialGradient.parse(args).map { .repeatingRadial($0) }.mapError { $0.asParseError() }
                case "repeating-conic-gradient":
                    CSSConicGradient.parse(args).map { .repeatingConic($0) }.mapError { $0.asParseError() }
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

extension CSSLinearGradient {
    static func parse(_ input: Parser) -> Result<CSSLinearGradient, BasicParseError> {
        // Try to parse direction
        var direction: CSSLinearGradientDirection = .angle(.deg(180))

        // Try angle first
        if case let .success(angle) = input.tryParse({ CSSAngle.parse($0) }) {
            direction = .angle(angle)
            // Expect comma after direction
            _ = input.tryParse { $0.expectComma() }
        } else if input.tryParse({ $0.expectIdentMatching("to") }).isOK {
            // Parse side/corner
            var horizontal: CSSHorizontalPositionKeyword?
            var vertical: CSSVerticalPositionKeyword?

            if case let .success(h) = input.tryParse({ p -> Result<CSSHorizontalPositionKeyword, BasicParseError> in
                let ident = try? p.expectIdent().get()
                switch ident?.value.lowercased() {
                case "left": return .success(.left)
                case "right": return .success(.right)
                default: return .failure(p.newBasicError(.endOfInput))
                }
            }) {
                horizontal = h
            }

            if case let .success(v) = input.tryParse({ p -> Result<CSSVerticalPositionKeyword, BasicParseError> in
                let ident = try? p.expectIdent().get()
                switch ident?.value.lowercased() {
                case "top": return .success(.top)
                case "bottom": return .success(.bottom)
                default: return .failure(p.newBasicError(.endOfInput))
                }
            }) {
                vertical = v
            }

            // If we got horizontal but not vertical, try again for horizontal after vertical
            if horizontal == nil {
                if case let .success(h) = input.tryParse({ p -> Result<CSSHorizontalPositionKeyword, BasicParseError> in
                    let ident = try? p.expectIdent().get()
                    switch ident?.value.lowercased() {
                    case "left": return .success(.left)
                    case "right": return .success(.right)
                    default: return .failure(p.newBasicError(.endOfInput))
                    }
                }) {
                    horizontal = h
                }
            }

            direction = .side(horizontal, vertical)

            // Expect comma
            _ = input.tryParse { $0.expectComma() }
        }

        // Parse color stops and hints
        let items = parseGradientItems(input)
        if items.isEmpty {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(CSSLinearGradient(direction: direction, items: items))
    }
}

extension CSSRadialGradient {
    static func parse(_ input: Parser) -> Result<CSSRadialGradient, BasicParseError> {
        var shape: CSSRadialGradientShape = .ellipse
        var size: CSSRadialGradientSize = .farthestCorner
        var position: CSSPosition = .center

        // Try to parse shape
        if input.tryParse({ $0.expectIdentMatching("circle") }).isOK {
            shape = .circle
        } else if input.tryParse({ $0.expectIdentMatching("ellipse") }).isOK {
            shape = .ellipse
        }

        // Try to parse size keyword
        if input.tryParse({ $0.expectIdentMatching("closest-side") }).isOK {
            size = .closestSide
        } else if input.tryParse({ $0.expectIdentMatching("farthest-side") }).isOK {
            size = .farthestSide
        } else if input.tryParse({ $0.expectIdentMatching("closest-corner") }).isOK {
            size = .closestCorner
        } else if input.tryParse({ $0.expectIdentMatching("farthest-corner") }).isOK {
            size = .farthestCorner
        }

        // Try "at position"
        if input.tryParse({ $0.expectIdentMatching("at") }).isOK {
            if case let .success(pos) = CSSPosition.parse(input) {
                position = pos
            }
        }

        // Comma before color stops
        _ = input.tryParse { $0.expectComma() }

        // Parse color stops and hints
        let items = parseGradientItems(input)
        if items.isEmpty {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(CSSRadialGradient(shape: shape, size: size, position: position, items: items))
    }
}

extension CSSConicGradient {
    static func parse(_ input: Parser) -> Result<CSSConicGradient, BasicParseError> {
        var fromAngle: CSSAngle = .zero
        var position: CSSPosition = .center

        // Try "from angle"
        if input.tryParse({ $0.expectIdentMatching("from") }).isOK {
            if case let .success(angle) = CSSAngle.parse(input) {
                fromAngle = angle
            }
        }

        // Try "at position"
        if input.tryParse({ $0.expectIdentMatching("at") }).isOK {
            if case let .success(pos) = CSSPosition.parse(input) {
                position = pos
            }
        }

        // Comma before color stops
        _ = input.tryParse { $0.expectComma() }

        // Parse color stops and hints
        let items = parseGradientItems(input)
        if items.isEmpty {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(CSSConicGradient(fromAngle: fromAngle, position: position, items: items))
    }
}

/// Parses a comma-separated list of color stops and interpolation hints.
/// https://www.w3.org/TR/css-images-4/#color-stop-syntax
private func parseGradientItems(_ input: Parser) -> [CSSGradientItem] {
    var items: [CSSGradientItem] = []
    var seenStop = false

    while !input.isExhausted {
        // After seeing a color stop, check for interpolation hint
        if seenStop {
            if case let .success(hint) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
                items.append(.hint(hint))
                seenStop = false
                // Try comma for next item
                if input.tryParse({ $0.expectComma() }).isOK {
                    continue
                }
                break
            }
        }

        // Try to parse color
        guard case let .success(color) = input.tryParse({ Color.parse($0) }) else {
            break
        }

        // Try to parse first position
        var position: CSSLengthPercentage?
        if case let .success(lp) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
            position = lp
        }

        // Try to parse second position
        if case let .success(secondPosition) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
            items.append(.colorStop(CSSGradientColorStop(color: color, position: position)))
            items.append(.colorStop(CSSGradientColorStop(color: color, position: secondPosition)))
        } else {
            items.append(.colorStop(CSSGradientColorStop(color: color, position: position)))
        }

        seenStop = true

        // Try comma for next item
        if input.tryParse({ $0.expectComma() }).isOK {
            continue
        }
        break
    }

    return items
}

// MARK: - ToCss

extension CSSGradient: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .linear(g):
            dest.write("linear-gradient(")
            g.serializeContent(dest: &dest)
            dest.write(")")
        case let .radial(g):
            dest.write("radial-gradient(")
            g.serializeContent(dest: &dest)
            dest.write(")")
        case let .conic(g):
            dest.write("conic-gradient(")
            g.serializeContent(dest: &dest)
            dest.write(")")
        case let .repeatingLinear(g):
            dest.write("repeating-linear-gradient(")
            g.serializeContent(dest: &dest)
            dest.write(")")
        case let .repeatingRadial(g):
            dest.write("repeating-radial-gradient(")
            g.serializeContent(dest: &dest)
            dest.write(")")
        case let .repeatingConic(g):
            dest.write("repeating-conic-gradient(")
            g.serializeContent(dest: &dest)
            dest.write(")")
        }
    }
}

/// Serializes gradient items (color stops and hints).
private func serializeGradientItems(_ items: [CSSGradientItem], dest: inout some CSSWriter) {
    for (i, item) in items.enumerated() {
        if i > 0 { dest.write(", ") }
        switch item {
        case let .colorStop(stop):
            stop.color.serialize(dest: &dest)
            if let pos = stop.position {
                dest.write(" ")
                pos.serialize(dest: &dest)
            }
        case let .hint(hint):
            hint.serialize(dest: &dest)
        }
    }
}

extension CSSLinearGradient {
    func serializeContent(dest: inout some CSSWriter) {
        // Direction
        switch direction {
        case let .angle(angle):
            if angle != .deg(180) {
                angle.serialize(dest: &dest)
                dest.write(", ")
            }
        case let .side(h, v):
            dest.write("to ")
            if let v {
                dest.write(v.rawValue)
                if h != nil { dest.write(" ") }
            }
            if let h {
                dest.write(h.rawValue)
            }
            dest.write(", ")
        }

        // Color stops and hints
        serializeGradientItems(items, dest: &dest)
    }
}

extension CSSRadialGradient {
    func serializeContent(dest: inout some CSSWriter) {
        var needsComma = false

        // Shape and size
        if shape != .ellipse || size != .farthestCorner {
            if shape == .circle {
                dest.write("circle")
            }
            switch size {
            case .closestSide:
                if shape != .ellipse { dest.write(" ") }
                dest.write("closest-side")
            case .farthestSide:
                if shape != .ellipse { dest.write(" ") }
                dest.write("farthest-side")
            case .closestCorner:
                if shape != .ellipse { dest.write(" ") }
                dest.write("closest-corner")
            case .farthestCorner:
                break // Default
            case let .length(l):
                if shape != .ellipse { dest.write(" ") }
                l.serialize(dest: &dest)
            case let .size(w, h):
                if shape != .ellipse { dest.write(" ") }
                w.serialize(dest: &dest)
                dest.write(" ")
                h.serialize(dest: &dest)
            }
            needsComma = true
        }

        // Position
        if position != .center {
            if needsComma { dest.write(" ") }
            dest.write("at ")
            position.serialize(dest: &dest)
            needsComma = true
        }

        if needsComma {
            dest.write(", ")
        }

        // Color stops and hints
        serializeGradientItems(items, dest: &dest)
    }
}

extension CSSConicGradient {
    func serializeContent(dest: inout some CSSWriter) {
        var needsComma = false

        // From angle
        if !fromAngle.isZero {
            dest.write("from ")
            fromAngle.serialize(dest: &dest)
            needsComma = true
        }

        // Position
        if position != .center {
            if needsComma { dest.write(" ") }
            dest.write("at ")
            position.serialize(dest: &dest)
            needsComma = true
        }

        if needsComma {
            dest.write(", ")
        }

        // Color stops and hints
        serializeGradientItems(items, dest: &dest)
    }
}
