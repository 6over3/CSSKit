// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("Shorthand Registration Tests")
struct ShorthandRegistrationTests {
    @Test("border-color parses one to four typed values")
    func borderColor() throws {
        let declaration = try CSSParser(
            "border-color: red green blue black"
        ).declarations.first

        guard case let .borderColor(value) = declaration?.value else {
            Issue.record("Expected a typed border-color shorthand")
            return
        }

        var writer = StringCSSWriter()
        value.serialize(dest: &writer)
        #expect(
            writer.result
                == "rgb(255, 0, 0) rgb(0, 128, 0) rgb(0, 0, 255) rgb(0, 0, 0)"
        )
    }

    @Test("logical border shorthands use their typed pair grammars")
    func logicalBorderPairs() throws {
        let declarations = try CSSParser(
            """
            border-block-color: red blue;
            border-inline-style: solid dashed;
            border-block-width: 1px thick;
            """
        ).declarations

        guard declarations.count == 3 else {
            Issue.record("Expected three declarations")
            return
        }
        guard case let .borderBlockColor(colors) = declarations[0].value,
              case let .borderInlineStyle(styles) = declarations[1].value,
              case let .borderBlockWidth(widths) = declarations[2].value
        else {
            Issue.record("Expected typed logical border shorthands")
            return
        }

        #expect(colors.start != colors.end)
        #expect(styles.start == .solid)
        #expect(styles.end == .dashed)
        #expect(widths.start == .length(.px(1)))
        #expect(widths.end == .thick)
    }
}
