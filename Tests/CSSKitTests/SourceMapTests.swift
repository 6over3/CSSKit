// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("Source Map Tests")
struct SourceMapTests {
    @Test("Parse source mapping comments")
    func parseSourcemappingComments() throws {
        let tests: [(String, String?)] = [
            ("/*# sourceMappingURL=here*/", "here"),
            ("/*# sourceMappingURL=here  */", "here"),
            ("/*@ sourceMappingURL=here*/", "here"),
            ("/*@ sourceMappingURL=there*/ /*# sourceMappingURL=here*/", "here"),
            ("/*# sourceMappingURL=here there  */", "here"),
            ("/*# sourceMappingURL=  here  */", ""),
            ("/*# sourceMappingURL=*/", ""),
            ("/*# sourceMappingUR=here  */", nil),
            ("/*! sourceMappingURL=here  */", nil),
            ("/*# sourceMappingURL = here  */", nil),
            ("/*   # sourceMappingURL=here   */", nil),
        ]

        for (css, expected) in tests {
            let input = ParserInput(css)
            let parser = Parser(input)
            while case .success = parser.nextIncludingWhitespace() {}
            let got = parser.currentSourceMapUrl.map { String($0) }
            #expect(got == expected,
                    "Source map URL mismatch for '\(css)': expected \(expected ?? "nil"), got \(got ?? "nil")")
        }
    }

    @Test("Parse source URL comments")
    func parseSourceurlComments() throws {
        let tests: [(String, String?)] = [
            ("/*# sourceURL=here*/", "here"),
            ("/*# sourceURL=here  */", "here"),
            ("/*@ sourceURL=here*/", "here"),
            ("/*@ sourceURL=there*/ /*# sourceURL=here*/", "here"),
            ("/*# sourceURL=here there  */", "here"),
            ("/*# sourceURL=  here  */", ""),
            ("/*# sourceURL=*/", ""),
            ("/*# sourceMappingUR=here  */", nil),
            ("/*! sourceURL=here  */", nil),
            ("/*# sourceURL = here  */", nil),
            ("/*   # sourceURL=here   */", nil),
        ]

        for (css, expected) in tests {
            let input = ParserInput(css)
            let parser = Parser(input)
            while case .success = parser.nextIncludingWhitespace() {}
            let got = parser.currentSourceUrl.map { String($0) }
            #expect(got == expected,
                    "Source URL mismatch for '\(css)': expected \(expected ?? "nil"), got \(got ?? "nil")")
        }
    }
}
