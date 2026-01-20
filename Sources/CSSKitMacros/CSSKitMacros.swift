// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// Generates a CSSProperty enum and associated parsing code from property definitions.
///
/// Usage:
/// ```swift
/// #CSSPropertyEnum {
///
///
///
///
/// }
/// ```
///
/// This generates:
/// - `enum CSSProperty` with a case for each property containing its typed value
/// - `parseCSSProperty(name:input:vendorPrefix:)` function for parsing
/// - Property name mappings
///
/// Each tuple contains:
/// - The CSS property name
/// - The Swift type for the value
/// - Optional flags: `.shorthand`, `.vendorPrefix`
@freestanding(declaration, names: named(CSSProperty), named(parseCSSProperty), named(cssPropertyNameToCase))
public macro CSSPropertyEnum(_ properties: () -> Void) = #externalMacro(module: "CSSKitMacrosPlugin", type: "CSSPropertyEnumMacro")

/// Property definition flags
public struct CSSPropertyFlags: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// This property is a shorthand (e.g., `border`, `margin`, `background`).
    public static let shorthand = Self(rawValue: 1 << 0)

    /// Supports -webkit- prefix.
    public static let webkit = Self(rawValue: 1 << 1)

    /// Supports -moz- prefix.
    public static let moz = Self(rawValue: 1 << 2)

    /// Supports -ms- prefix.
    public static let ms = Self(rawValue: 1 << 3)

    /// Supports -o- prefix.
    public static let o = Self(rawValue: 1 << 4)

    /// This property inherits by default (e.g., `color`, `font-family`).
    public static let inherits = Self(rawValue: 1 << 5)

    /// Supports all common vendor prefixes (webkit, moz, ms, o).
    public static let allPrefixes: CSSPropertyFlags = [.webkit, .moz, .ms, .o]

    /// Convenience: Transform prefixes
    public static let transformPrefixes: CSSPropertyFlags = [.webkit, .moz, .ms, .o]

    /// Any vendor prefix flag is set.
    public var hasVendorPrefix: Bool {
        !isDisjoint(with: [.webkit, .moz, .ms, .o])
    }
}

@freestanding(declaration, names: named(CSSValue), named(parseCSSValue))
public macro CSSValueEnum(_ values: () -> Void) = #externalMacro(module: "CSSKitMacrosPlugin", type: "CSSValueEnumMacro")
