// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

#if canImport(CSSKitMacrosPlugin)
    import CSSKitMacrosPlugin

    private nonisolated(unsafe) let testMacros: [String: Macro.Type] = [
        "CSSValueEnum": CSSValueEnumMacro.self,
    ]
#endif

@Suite("CSSValueEnum Macro Tests")
struct CSSValueEnumMacroTests {
    @Test("Basic value enum generation")
    func basicValueEnumGeneration() throws {
        #if canImport(CSSKitMacrosPlugin)
            assertMacroExpansion(
                """
                #CSSValueEnum {
                    _ = ("number", Double.self)
                    _ = ("percentage", CSSPercentage.self)
                }
                """,
                expandedSource: """
                public enum CSSValue: Equatable, Sendable, CSSSerializable {
                    case number(Double)
                    case percentage(CSSPercentage)

                    public func serialize<W: CSSWriter>(dest: inout W) {
                        switch self {
                        case .number(let v):
                            v.serialize(dest: &dest)
                        case .percentage(let v):
                            v.serialize(dest: &dest)
                        }
                    }
                }
                func parseCSSValue(input: Parser) -> Result<CSSValue, BasicParseError> {
                    if case .success(let v) = input.tryParse({ Double.parse($0) }) {
                        return .success(.number(v))
                    }
                    if case .success(let v) = input.tryParse({ CSSPercentage.parse($0) }) {
                        return .success(.percentage(v))
                    }

                    return .failure(input.newBasicError(.endOfInput))
                }
                """,
                macros: testMacros
            )
        #else
            try #require(Bool(false), "macros are only supported when running tests for the host platform")
        #endif
    }
}
