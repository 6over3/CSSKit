// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A CSS vendor prefix.
/// https://developer.mozilla.org/en-US/docs/Glossary/Vendor_Prefix
public enum CSSVendorPrefix: String, Equatable, Sendable, Hashable {
    /// No vendor prefix.
    case none = ""
    /// The `-webkit-` prefix (Chrome, Safari, newer Opera, Edge).
    case webkit = "-webkit-"
    /// The `-moz-` prefix (Firefox).
    case moz = "-moz-"
    /// The `-ms-` prefix (Internet Explorer, old Edge).
    case ms = "-ms-"
    /// The `-o-` prefix (old Opera).
    case o = "-o-"

    /// Creates a vendor prefix from a prefix string (without leading `-`).
    public init?(string: String) {
        switch string.lowercased() {
        case "", "none": self = .none
        case "webkit": self = .webkit
        case "moz": self = .moz
        case "ms": self = .ms
        case "o": self = .o
        default: return nil
        }
    }

    /// The CSS prefix string (e.g., "-webkit-").
    public var cssPrefix: String {
        rawValue
    }

    /// Extracts a vendor prefix from a property name.
    /// Returns the prefix and the unprefixed property name.
    ///
    /// Example:
    /// ```swift
    /// let (prefix, name) = CSSVendorPrefix.extract(from: "-webkit-transform")
    /// // prefix = .webkit, name = "transform"
    /// ```
    public static func extract(from propertyName: String) -> (prefix: Self, name: String) {
        if propertyName.hasPrefix("-webkit-") {
            return (.webkit, String(propertyName.dropFirst(8)))
        } else if propertyName.hasPrefix("-moz-") {
            return (.moz, String(propertyName.dropFirst(5)))
        } else if propertyName.hasPrefix("-ms-") {
            return (.ms, String(propertyName.dropFirst(4)))
        } else if propertyName.hasPrefix("-o-") {
            return (.o, String(propertyName.dropFirst(3)))
        }
        return (.none, propertyName)
    }
}

// MARK: - ToCss

extension CSSVendorPrefix: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if self != .none {
            dest.write(rawValue)
        }
    }
}
