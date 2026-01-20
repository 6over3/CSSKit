// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

#if canImport(CSSKitMacrosPlugin)
    import CSSKitMacrosPlugin

    private nonisolated(unsafe) let testMacros: [String: Macro.Type] = [
        "CSSPropertyEnum": CSSPropertyEnumMacro.self,
    ]
#endif

@Suite("CSSPropertyEnum Macro Tests")
struct CSSPropertyEnumMacroTests {
    @Test("Basic property generation")
    func basicPropertyGeneration() throws {
        #if canImport(CSSKitMacrosPlugin)
            assertMacroExpansion(
                """
                #CSSPropertyEnum {
                    ("color", Color.self)
                }
                """,
                expandedSource: """
                /// A fully-typed CSS property with its parsed value.
                public enum CSSProperty: Equatable, Sendable {
                    case color(Color)
                    /// An unparsed property (fallback for complex values or var() references).
                    case unparsed(CSSUnparsedProperty)
                    /// A custom property (CSS variable).
                    case custom(CSSCustomProperty)

                    /// The CSS property name.
                    public var name: String {
                        switch self {
                        case .color:
                            return "color"
                        case .unparsed(let prop):
                            return prop.propertyId.name
                        case .custom(let prop):
                            return prop.name.name
                        }
                    }

                    /// Whether this property is a shorthand property.
                    public var isShorthand: Bool {
                        switch self {
                        default:
                            return false
                        }
                    }

                    /// Serializes the property value to CSS.
                    public func serialize<W: CSSWriter>(dest: inout W) {
                        switch self {
                        case .color(let value):
                            value.serialize(dest: &dest)
                        case .unparsed(let prop):
                            prop.serialize(dest: &dest)
                        case .custom(let prop):
                            prop.serialize(dest: &dest)
                        }
                    }
                }
                /// Parses a CSS property by name into a typed CSSProperty value.
                func parseCSSProperty(
                    name: String,
                    input: Parser,
                    vendorPrefix: CSSVendorPrefix = .none
                ) -> Result<CSSProperty, BasicParseError> {
                    let propertyName = name.lowercased()
                    let startState = input.state()

                    switch propertyName {
                    case "color":
                        // No vendor prefix allowed
                        guard vendorPrefix == .none else {
                            break
                        }
                        if case .success(let value) = Color.parse(input), input.isExhausted {
                            return .success(.color(value))
                        }
                    default:
                        break
                    }

                    // Fallback to unparsed - preserves token structure including var() references
                    input.reset(startState)
                    let propertyId = CSSPropertyId(propertyName)
                    switch CSSUnparsedProperty.parse(propertyId: propertyId, input: input) {
                    case .success(let unparsed):
                        return .success(.unparsed(unparsed))
                    case .failure(let error):
                        return .failure(error)
                    }
                }
                /// Maps CSS property names to their Swift enum case names.
                private let cssPropertyNameToCase: [String: String] = [
                    "color": "color"
                ]
                """,
                macros: testMacros
            )
        #else
            try #require(Bool(false), "macros are only supported when running tests for the host platform")
        #endif
    }
}
