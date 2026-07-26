// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("CSS Images properties")
struct CSSImagesTests {
    @Test
    func objectFitParsesEveryKeyword() throws {
        let declarations = try CSSParser(
            """
            object-fit: fill;
            object-fit: contain;
            object-fit: cover;
            object-fit: none;
            object-fit: scale-down;
            """
        ).declarations

        #expect(declarations.count == 5)
        #expect(declarations.map(\.rawValue) == [
            "fill", "contain", "cover", "none", "scale-down",
        ])
        #expect(declarations.allSatisfy { declaration in
            guard declaration.name == "object-fit",
                  case .objectFit = declaration.value
            else {
                return false
            }
            return true
        })
    }

    @Test
    func objectPositionUsesTheCompletePositionGrammar() throws {
        let declaration = try #require(
            CSSParser("object-position: right 12px bottom 20%;")
                .declarations.first
        )

        #expect(declaration.name == "object-position")
        guard case .objectPosition = declaration.value else {
            Issue.record("Expected typed object-position")
            return
        }
        #expect(declaration.rawValue == "right 12px bottom 20%")
    }

    @Test
    func objectPropertiesExposeSpecificationInitialValues() {
        #expect(CSSObjectFit.initial == .fill)
        #expect(CSSPosition.initial == .center)
        #expect(CSSPropertyId("object-fit") == .objectFit)
        #expect(CSSPropertyId("object-position") == .objectPosition)
    }
}
