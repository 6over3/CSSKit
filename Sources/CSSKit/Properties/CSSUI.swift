// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Resize

/// A value for the `resize` property.
/// https://www.w3.org/TR/2021/WD-css-ui-4-20210316/#resize
public enum CSSResize: String, Equatable, Sendable, Hashable {
    /// The element does not allow resizing.
    case none
    /// The element is resizable in both the x and y directions.
    case both
    /// The element is resizable in the x direction.
    case horizontal
    /// The element is resizable in the y direction.
    case vertical
    /// The element is resizable in the block direction, according to the writing mode.
    case block
    /// The element is resizable in the inline direction, according to the writing mode.
    case inline
}

// MARK: - Cursor Image

/// A hotspot coordinate pair for cursor images.
public struct CSSCursorHotspot: Equatable, Sendable, Hashable {
    public let x: CSSNumber
    public let y: CSSNumber

    public init(x: CSSNumber, y: CSSNumber) {
        self.x = x
        self.y = y
    }
}

/// A cursor image value, used in the `cursor` property.
/// https://www.w3.org/TR/2021/WD-css-ui-4-20210316/#cursor
public struct CSSCursorImage: Equatable, Sendable, Hashable {
    /// A url to the cursor image.
    public let url: CSSUrl
    /// The location in the image where the mouse pointer appears.
    public let hotspot: CSSCursorHotspot?

    public init(url: CSSUrl, hotspot: CSSCursorHotspot? = nil) {
        self.url = url
        self.hotspot = hotspot
    }
}

// MARK: - Cursor Keyword

/// A pre-defined cursor value, used in the `cursor` property.
/// https://www.w3.org/TR/2021/WD-css-ui-4-20210316/#cursor
public enum CSSCursorKeyword: String, Equatable, Sendable, Hashable {
    case auto
    case `default`
    case none
    case contextMenu = "context-menu"
    case help
    case pointer
    case progress
    case wait
    case cell
    case crosshair
    case text
    case verticalText = "vertical-text"
    case alias
    case copy
    case move
    case noDrop = "no-drop"
    case notAllowed = "not-allowed"
    case grab
    case grabbing
    case eResize = "e-resize"
    case nResize = "n-resize"
    case neResize = "ne-resize"
    case nwResize = "nw-resize"
    case sResize = "s-resize"
    case seResize = "se-resize"
    case swResize = "sw-resize"
    case wResize = "w-resize"
    case ewResize = "ew-resize"
    case nsResize = "ns-resize"
    case neswResize = "nesw-resize"
    case nwseResize = "nwse-resize"
    case colResize = "col-resize"
    case rowResize = "row-resize"
    case allScroll = "all-scroll"
    case zoomIn = "zoom-in"
    case zoomOut = "zoom-out"
}

// MARK: - Cursor

/// A value for the `cursor` property.
/// https://www.w3.org/TR/2021/WD-css-ui-4-20210316/#cursor
public struct CSSCursor: Equatable, Sendable, Hashable {
    /// A list of cursor images.
    public let images: [CSSCursorImage]
    /// A pre-defined cursor.
    public let keyword: CSSCursorKeyword

    public init(images: [CSSCursorImage] = [], keyword: CSSCursorKeyword) {
        self.images = images
        self.keyword = keyword
    }
}

// MARK: - Caret Color

/// A value for the `caret-color` property.
/// https://www.w3.org/TR/2021/WD-css-ui-4-20210316/#caret-color
public enum CSSCaretColor: Equatable, Sendable, Hashable {
    /// The `currentColor`, adjusted by the UA to ensure contrast against the background.
    case auto
    /// A color.
    case color(Color)

    /// The default value (auto).
    public static var `default`: Self { .auto }
}

// MARK: - Caret Shape

/// A value for the `caret-shape` property.
/// https://www.w3.org/TR/2021/WD-css-ui-4-20210316/#caret-shape
public enum CSSCaretShape: String, Equatable, Sendable, Hashable {
    /// The UA determines the caret shape.
    case auto
    /// A thin bar caret.
    case bar
    /// A rectangle caret.
    case block
    /// An underscore caret.
    case underscore

    /// The default value (auto).
    public static var `default`: Self { .auto }
}

// MARK: - Caret

/// A value for the `caret` shorthand property.
/// https://www.w3.org/TR/2021/WD-css-ui-4-20210316/#caret
public struct CSSCaret: Equatable, Sendable, Hashable {
    /// The caret color.
    public var color: CSSCaretColor
    /// The caret shape.
    public var shape: CSSCaretShape

    public init(color: CSSCaretColor = .auto, shape: CSSCaretShape = .auto) {
        self.color = color
        self.shape = shape
    }
}

// MARK: - User Select

/// A value for the `user-select` property.
/// https://www.w3.org/TR/2021/WD-css-ui-4-20210316/#content-selection
public enum CSSUserSelect: String, Equatable, Sendable, Hashable {
    /// The UA determines whether text is selectable.
    case auto
    /// Text is selectable.
    case text
    /// Text is not selectable.
    case none
    /// Text selection is contained to the element.
    case contain
    /// Only the entire element is selectable.
    case all
}

// MARK: - Appearance

/// A value for the `appearance` property.
/// https://www.w3.org/TR/2021/WD-css-ui-4-20210316/#appearance-switching
public enum CSSAppearance: Equatable, Sendable, Hashable {
    case none
    case auto
    case textfield
    case menulistButton
    case button
    case checkbox
    case listbox
    case menulist
    case meter
    case progressBar
    case pushButton
    case radio
    case searchfield
    case sliderHorizontal
    case squareButton
    case textarea
    /// Non-standard appearance value.
    case nonStandard(String)

    /// Creates an appearance from a string.
    init(fromString value: String) {
        let lower = value.lowercased()
        switch lower {
        case "none": self = .none
        case "auto": self = .auto
        case "textfield": self = .textfield
        case "menulist-button": self = .menulistButton
        case "button": self = .button
        case "checkbox": self = .checkbox
        case "listbox": self = .listbox
        case "menulist": self = .menulist
        case "meter": self = .meter
        case "progress-bar": self = .progressBar
        case "push-button": self = .pushButton
        case "radio": self = .radio
        case "searchfield": self = .searchfield
        case "slider-horizontal": self = .sliderHorizontal
        case "square-button": self = .squareButton
        case "textarea": self = .textarea
        default: self = .nonStandard(value)
        }
    }

    /// Returns the string representation.
    func toString() -> String {
        switch self {
        case .none: "none"
        case .auto: "auto"
        case .textfield: "textfield"
        case .menulistButton: "menulist-button"
        case .button: "button"
        case .checkbox: "checkbox"
        case .listbox: "listbox"
        case .menulist: "menulist"
        case .meter: "meter"
        case .progressBar: "progress-bar"
        case .pushButton: "push-button"
        case .radio: "radio"
        case .searchfield: "searchfield"
        case .sliderHorizontal: "slider-horizontal"
        case .squareButton: "square-button"
        case .textarea: "textarea"
        case let .nonStandard(s): s
        }
    }
}

// MARK: - Color Scheme

/// A value for the `color-scheme` property.
/// https://drafts.csswg.org/css-color-adjust/#color-scheme-prop
public struct CSSColorScheme: OptionSet, Equatable, Sendable, Hashable {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    /// Indicates that the element supports a light color scheme.
    public static let light = Self(rawValue: 1 << 0)
    /// Indicates that the element supports a dark color scheme.
    public static let dark = Self(rawValue: 1 << 1)
    /// Forbids the user agent from overriding the color scheme for the element.
    public static let only = Self(rawValue: 1 << 2)

    /// Normal color scheme (empty set).
    public static var normal: Self { [] }
}

// MARK: - Print Color Adjust

/// A value for the `print-color-adjust` property.
/// https://drafts.csswg.org/css-color-adjust/#propdef-print-color-adjust
public enum CSSPrintColorAdjust: String, Equatable, Sendable, Hashable {
    /// The user agent is allowed to make adjustments to the element as it deems appropriate.
    case economy
    /// The user agent is not allowed to make adjustments to the element.
    case exact
}

// MARK: - Parsing

extension CSSResize {
    static func parse(_ input: Parser) -> Result<CSSResize, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "none": return .success(.none)
        case "both": return .success(.both)
        case "horizontal": return .success(.horizontal)
        case "vertical": return .success(.vertical)
        case "block": return .success(.block)
        case "inline": return .success(.inline)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSCursorImage {
    static func parse(_ input: Parser) -> Result<CSSCursorImage, BasicParseError> {
        guard case let .success(url) = CSSUrl.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        let hotspot: CSSCursorHotspot?
        if case let .success(x) = input.tryParse({ $0.expectNumber() }) {
            if case let .success(y) = input.expectNumber() {
                hotspot = CSSCursorHotspot(x: x, y: y)
            } else {
                return .failure(input.newBasicError(.endOfInput))
            }
        } else {
            hotspot = nil
        }

        return .success(CSSCursorImage(url: url, hotspot: hotspot))
    }
}

extension CSSCursorKeyword {
    static func parse(_ input: Parser) -> Result<CSSCursorKeyword, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "auto": return .success(.auto)
        case "default": return .success(.default)
        case "none": return .success(.none)
        case "context-menu": return .success(.contextMenu)
        case "help": return .success(.help)
        case "pointer": return .success(.pointer)
        case "progress": return .success(.progress)
        case "wait": return .success(.wait)
        case "cell": return .success(.cell)
        case "crosshair": return .success(.crosshair)
        case "text": return .success(.text)
        case "vertical-text": return .success(.verticalText)
        case "alias": return .success(.alias)
        case "copy": return .success(.copy)
        case "move": return .success(.move)
        case "no-drop": return .success(.noDrop)
        case "not-allowed": return .success(.notAllowed)
        case "grab": return .success(.grab)
        case "grabbing": return .success(.grabbing)
        case "e-resize": return .success(.eResize)
        case "n-resize": return .success(.nResize)
        case "ne-resize": return .success(.neResize)
        case "nw-resize": return .success(.nwResize)
        case "s-resize": return .success(.sResize)
        case "se-resize": return .success(.seResize)
        case "sw-resize": return .success(.swResize)
        case "w-resize": return .success(.wResize)
        case "ew-resize": return .success(.ewResize)
        case "ns-resize": return .success(.nsResize)
        case "nesw-resize": return .success(.neswResize)
        case "nwse-resize": return .success(.nwseResize)
        case "col-resize": return .success(.colResize)
        case "row-resize": return .success(.rowResize)
        case "all-scroll": return .success(.allScroll)
        case "zoom-in": return .success(.zoomIn)
        case "zoom-out": return .success(.zoomOut)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSCursor {
    static func parse(_ input: Parser) -> Result<CSSCursor, BasicParseError> {
        var images: [CSSCursorImage] = []

        // Parse cursor images followed by commas
        while true {
            guard case let .success(image) = input.tryParse({ CSSCursorImage.parse($0) }) else {
                break
            }
            images.append(image)

            // Expect comma after image
            guard case .success = input.expectComma() else {
                return .failure(input.newBasicError(.endOfInput))
            }
        }

        // Parse required keyword
        guard case let .success(keyword) = CSSCursorKeyword.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(CSSCursor(images: images, keyword: keyword))
    }
}

extension CSSCaretColor {
    static func parse(_ input: Parser) -> Result<CSSCaretColor, BasicParseError> {
        // Try auto keyword first
        if input.tryParse({ $0.expectIdentMatching("auto") }).isOK {
            return .success(.auto)
        }

        // Try color
        if case let .success(color) = Color.parse(input) {
            return .success(.color(color))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSCaretShape {
    static func parse(_ input: Parser) -> Result<CSSCaretShape, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "auto": return .success(.auto)
        case "bar": return .success(.bar)
        case "block": return .success(.block)
        case "underscore": return .success(.underscore)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSCaret {
    static func parse(_ input: Parser) -> Result<CSSCaret, BasicParseError> {
        var color: CSSCaretColor?
        var shape: CSSCaretShape?
        var any = false

        // Parse components in any order
        while true {
            if color == nil {
                if case let .success(c) = input.tryParse({ CSSCaretColor.parse($0) }) {
                    color = c
                    any = true
                    continue
                }
            }

            if shape == nil {
                if case let .success(s) = input.tryParse({ CSSCaretShape.parse($0) }) {
                    shape = s
                    any = true
                    continue
                }
            }

            break
        }

        if any {
            return .success(CSSCaret(
                color: color ?? .auto,
                shape: shape ?? .auto
            ))
        }

        return .failure(input.newBasicError(.endOfInput))
    }
}

extension CSSUserSelect {
    static func parse(_ input: Parser) -> Result<CSSUserSelect, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "auto": return .success(.auto)
        case "text": return .success(.text)
        case "none": return .success(.none)
        case "contain": return .success(.contain)
        case "all": return .success(.all)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSAppearance {
    static func parse(_ input: Parser) -> Result<CSSAppearance, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        return .success(CSSAppearance(fromString: ident.value))
    }
}

extension CSSColorScheme {
    static func parse(_ input: Parser) -> Result<CSSColorScheme, BasicParseError> {
        var result = CSSColorScheme()

        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }

        switch ident.value.lowercased() {
        case "normal":
            return .success(result)
        case "only":
            result.insert(.only)
        case "light":
            result.insert(.light)
        case "dark":
            result.insert(.dark)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }

        // Parse additional keywords
        while case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
            switch ident.value.lowercased() {
            case "normal":
                return .failure(input.newBasicError(.endOfInput))
            case "only":
                // Only must be at the start or the end, not in the middle
                if result.contains(.only) {
                    return .failure(input.newBasicError(.endOfInput))
                }
                result.insert(.only)
                return .success(result)
            case "light":
                result.insert(.light)
            case "dark":
                result.insert(.dark)
            default:
                break
            }
        }

        return .success(result)
    }
}

extension CSSPrintColorAdjust {
    static func parse(_ input: Parser) -> Result<CSSPrintColorAdjust, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "economy": return .success(.economy)
        case "exact": return .success(.exact)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

// MARK: - ToCss

extension CSSResize: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSCursorImage: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        url.serialize(dest: &dest)

        if let hotspot {
            dest.write(" ")
            hotspot.x.serialize(dest: &dest)
            dest.write(" ")
            hotspot.y.serialize(dest: &dest)
        }
    }
}

extension CSSCursorKeyword: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSCursor: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        for (index, image) in images.enumerated() {
            image.serialize(dest: &dest)
            if index < images.count - 1 {
                dest.write(", ")
            }
        }

        if !images.isEmpty {
            dest.write(", ")
        }

        keyword.serialize(dest: &dest)
    }
}

extension CSSCaretColor: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .auto:
            dest.write("auto")
        case let .color(color):
            color.serialize(dest: &dest)
        }
    }
}

extension CSSCaretShape: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSCaret: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        var needsSpace = false

        if color != .auto {
            color.serialize(dest: &dest)
            needsSpace = true
        }

        if shape != .auto {
            if needsSpace {
                dest.write(" ")
            }
            shape.serialize(dest: &dest)
        }
    }
}

extension CSSUserSelect: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSAppearance: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(toString())
    }
}

extension CSSColorScheme: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if isEmpty {
            dest.write("normal")
            return
        }

        var needsSpace = false

        if contains(.light) {
            dest.write("light")
            needsSpace = true
        }

        if contains(.dark) {
            if needsSpace {
                dest.write(" ")
            }
            dest.write("dark")
            needsSpace = true
        }

        if contains(.only) {
            if needsSpace {
                dest.write(" ")
            }
            dest.write("only")
        }
    }
}

extension CSSPrintColorAdjust: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}
