// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Contain Property

/// A value for the `contain` CSS property.
/// https://drafts.csswg.org/css-contain-2/#contain-property
public struct CSSContain: OptionSet, Equatable, Sendable, Hashable {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    /// No containment.
    public static let none = Self([])
    /// Size containment.
    public static let size = Self(rawValue: 1 << 0)
    /// Inline-size containment.
    public static let inlineSize = Self(rawValue: 1 << 1)
    /// Layout containment.
    public static let layout = Self(rawValue: 1 << 2)
    /// Paint containment.
    public static let paint = Self(rawValue: 1 << 3)
    /// Style containment.
    public static let style = Self(rawValue: 1 << 4)

    /// The `strict` keyword (equivalent to size layout paint style).
    public static let strict: CSSContain = [.size, .layout, .paint, .style]
    /// The `content` keyword (equivalent to layout paint style).
    public static let content: CSSContain = [.layout, .paint, .style]
}

// MARK: - Content Visibility

/// A value for the `content-visibility` CSS property.
/// https://drafts.csswg.org/css-contain-2/#content-visibility
public enum CSSContentVisibility: String, Equatable, Sendable, Hashable, CaseIterable {
    /// No effect on the element's rendering.
    case visible
    /// The element skips its contents when offscreen.
    case auto
    /// The element skips its contents regardless of visibility.
    case hidden
}

// MARK: - Container Type

/// A value for the `container-type` property.
/// https://drafts.csswg.org/css-contain-3/#container-type
public enum CSSContainerType: String, Equatable, Sendable, Hashable, CaseIterable {
    /// The element is not a query container for any container size queries,
    /// but remains a query container for container style queries.
    case normal
    /// Establishes a query container for container size queries on the container's own inline axis.
    case inlineSize = "inline-size"
    /// Establishes a query container for container size queries on both the inline and block axis.
    case size
    /// Establishes a query container for container scroll-state queries.
    case scrollState = "scroll-state"

    /// The default value (normal).
    public static var `default`: Self { .normal }
}

// MARK: - Container Name List

/// A value for the `container-name` property.
/// https://drafts.csswg.org/css-contain-3/#container-name
public enum CSSContainerNameList: Equatable, Sendable, Hashable {
    /// The `none` keyword.
    case none
    /// A list of container names.
    case names([CSSCustomIdent])

    /// The default value (none).
    public static var `default`: Self { .none }
}

// MARK: - Container

/// A value for the `container` shorthand property.
/// https://drafts.csswg.org/css-contain-3/#container-shorthand
public struct CSSContainer: Equatable, Sendable, Hashable {
    /// The container name.
    public var name: CSSContainerNameList
    /// The container type.
    public var containerType: CSSContainerType

    public init(
        name: CSSContainerNameList = .none,
        containerType: CSSContainerType = .normal
    ) {
        self.name = name
        self.containerType = containerType
    }

    /// The default value.
    public static var `default`: Self {
        Self(name: .none, containerType: .normal)
    }
}

// MARK: - Parsing

extension CSSContain {
    static func parse(_ input: Parser) -> Result<CSSContain, BasicParseError> {
        // Try 'none' keyword first
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        // Try 'strict' keyword
        if input.tryParse({ $0.expectIdentMatching("strict") }).isOK {
            return .success(.strict)
        }

        // Try 'content' keyword
        if input.tryParse({ $0.expectIdentMatching("content") }).isOK {
            return .success(.content)
        }

        // Parse individual containment types
        var result: CSSContain = []
        while case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
            switch ident.value.lowercased() {
            case "size":
                result.insert(.size)
            case "inline-size":
                result.insert(.inlineSize)
            case "layout":
                result.insert(.layout)
            case "paint":
                result.insert(.paint)
            case "style":
                result.insert(.style)
            default:
                return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
            }
        }

        if result.isEmpty {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(result)
    }
}

extension CSSContentVisibility {
    static func parse(_ input: Parser) -> Result<CSSContentVisibility, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "visible": return .success(.visible)
        case "auto": return .success(.auto)
        case "hidden": return .success(.hidden)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSContainerType {
    static func parse(_ input: Parser) -> Result<CSSContainerType, BasicParseError> {
        guard case let .success(ident) = input.expectIdent() else {
            return .failure(input.newBasicError(.endOfInput))
        }
        switch ident.value.lowercased() {
        case "normal": return .success(.normal)
        case "inline-size": return .success(.inlineSize)
        case "size": return .success(.size)
        case "scroll-state": return .success(.scrollState)
        default:
            return .failure(input.newBasicError(.unexpectedToken(.ident(ident))))
        }
    }
}

extension CSSContainerNameList {
    static func parse(_ input: Parser) -> Result<CSSContainerNameList, BasicParseError> {
        // Try none keyword
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        // Parse list of custom idents
        var names: [CSSCustomIdent] = []
        while case let .success(name) = input.tryParse({ CSSCustomIdent.parse($0) }) {
            names.append(name)
        }

        if names.isEmpty {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(.names(names))
    }
}

extension CSSContainer {
    static func parse(_ input: Parser) -> Result<CSSContainer, BasicParseError> {
        guard case let .success(name) = CSSContainerNameList.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        // Check for optional `/` separator for container type
        let containerType: CSSContainerType
        if input.tryParse({ $0.expectDelim("/") }).isOK {
            guard case let .success(ct) = CSSContainerType.parse(input) else {
                return .failure(input.newBasicError(.endOfInput))
            }
            containerType = ct
        } else {
            containerType = .normal
        }

        return .success(CSSContainer(name: name, containerType: containerType))
    }
}

// MARK: - ToCss

extension CSSContain: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if isEmpty {
            dest.write("none")
            return
        }

        if self == .strict {
            dest.write("strict")
            return
        }

        if self == .content {
            dest.write("content")
            return
        }

        var first = true
        if contains(.size) {
            dest.write("size")
            first = false
        }
        if contains(.inlineSize) {
            if !first { dest.write(" ") }
            dest.write("inline-size")
            first = false
        }
        if contains(.layout) {
            if !first { dest.write(" ") }
            dest.write("layout")
            first = false
        }
        if contains(.paint) {
            if !first { dest.write(" ") }
            dest.write("paint")
            first = false
        }
        if contains(.style) {
            if !first { dest.write(" ") }
            dest.write("style")
        }
    }
}

extension CSSContentVisibility: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSContainerType: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}

extension CSSContainerNameList: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .none:
            dest.write("none")
        case let .names(names):
            var first = true
            for name in names {
                if first {
                    first = false
                } else {
                    dest.write(" ")
                }
                name.serialize(dest: &dest)
            }
        }
    }
}

extension CSSContainer: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        name.serialize(dest: &dest)
        if containerType != .default {
            dest.write(" / ")
            containerType.serialize(dest: &dest)
        }
    }
}
