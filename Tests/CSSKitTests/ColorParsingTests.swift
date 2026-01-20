// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("Color Parsing Tests")
struct ColorParsingTests {
    // MARK: - CSS Color Level 3

    @Test("color_hexadecimal_3.json - Hex colors (Level 3)")
    func colorHexadecimal3() throws {
        let testData = try loadTestData("color_hexadecimal_3")
        runColorTests(testData)
    }

    @Test("color_hsl_3.json - HSL colors (Level 3)")
    func colorHsl3() throws {
        let testData = try loadTestData("color_hsl_3")
        runColorTests(testData)
    }

    @Test("color_keywords_3.json - Named color keywords (Level 3)")
    func colorKeywords3() throws {
        let testData = try loadTestData("color_keywords_3")
        runColorTests(testData)
    }

    // MARK: - CSS Color Level 4

    @Test("color_hexadecimal_4.json - Hex colors (Level 4)")
    func colorHexadecimal4() throws {
        let testData = try loadTestData("color_hexadecimal_4")
        runColorTests(testData)
    }

    @Test("color_hsl_4.json - HSL colors (Level 4)")
    func colorHsl4() throws {
        let testData = try loadTestData("color_hsl_4")
        runColorTests(testData)
    }

    @Test("color_keywords_4.json - Named color keywords (Level 4)")
    func colorKeywords4() throws {
        let testData = try loadTestData("color_keywords_4")
        runColorTests(testData)
    }

    @Test("color_hwb_4.json - HWB colors (Level 4)")
    func colorHwb4() throws {
        let testData = try loadTestData("color_hwb_4")
        runColorTests(testData)
    }

    @Test("color_lab_4.json - Lab colors (Level 4)")
    func colorLab4() throws {
        let testData = try loadTestData("color_lab_4")
        runColorTests(testData)
    }

    @Test("color_lch_4.json - LCH colors (Level 4)")
    func colorLch4() throws {
        let testData = try loadTestData("color_lch_4")
        runColorTests(testData)
    }

    @Test("color_oklab_4.json - OKLab colors (Level 4)")
    func colorOklab4() throws {
        let testData = try loadTestData("color_oklab_4")
        runColorTests(testData)
    }

    @Test("color_oklch_4.json - OKLCH colors (Level 4)")
    func colorOklch4() throws {
        let testData = try loadTestData("color_oklch_4")
        runColorTests(testData)
    }

    @Test("color_function_4.json - color() function (Level 4)")
    func colorFunction4() throws {
        let testData = try loadTestData("color_function_4")
        runColorTests(testData)
    }

    // MARK: - CSS Color Level 5

    @Test("color_functions_5.json - Color functions (Level 5)")
    func colorFunctions5() throws {
        let testData = try loadTestData("color_functions_5")
        runColorTests(testData)
    }

    // MARK: - Test Runner

    private func runColorTests(_ jsonData: [JSONValue]) {
        var i = 0
        while i < jsonData.count - 1 {
            guard case let .string(input) = jsonData[i] else {
                i += 1
                continue
            }
            let expected = jsonData[i + 1]
            i += 2

            let parserInput = ParserInput(input)
            let parser = Parser(parserInput)

            let parseResult = Color.parse(parser)

            switch parseResult {
            case let .success(color):
                // Color parsed successfully - check if we expected a result or null
                if case .null = expected {
                    Issue.record("Expected null but got color for input: \(input) -> \(color.string)")
                } else if case let .string(expectedCss) = expected {
                    let serialized = color.string
                    if !colorsApproximatelyEqual(serialized, expectedCss) {
                        Issue.record("Color mismatch for '\(input)':\n  Got: \(serialized)\n  Expected: \(expectedCss)")
                    }
                }
            case .failure:
                // Parse failed - should have expected null
                if case .null = expected {
                    // Expected failure - OK
                } else if case let .string(expectedCss) = expected {
                    Issue.record("Expected '\(expectedCss)' but parsing failed for input: \(input)")
                }
            }
        }
    }

    /// Compares two color strings with tolerance for floating point differences.
    private func colorsApproximatelyEqual(_ a: String, _ b: String) -> Bool {
        if a == b { return true }

        let (numbersA, structureA) = extractNumbersAndStructure(from: a)
        let (numbersB, structureB) = extractNumbersAndStructure(from: b)

        guard structureA == structureB, numbersA.count == numbersB.count else { return false }

        for (numA, numB) in zip(numbersA, numbersB) {
            // Use absolute tolerance of 0.000002
            if !numA.isApproximatelyEqual(to: numB, absoluteTolerance: 0.000002) {
                return false
            }
        }
        return true
    }

    /// Extracts numbers and non-numeric structure from a color string.
    private func extractNumbersAndStructure(from string: String) -> (numbers: [Double], structure: String) {
        var numbers: [Double] = []
        var structure = ""
        var currentNumber = ""

        for char in string {
            if char.isNumber || char == "." || (char == "-" && currentNumber.isEmpty) {
                currentNumber.append(char)
            } else {
                if !currentNumber.isEmpty {
                    if let num = Double(currentNumber) {
                        numbers.append(num)
                    }
                    structure.append("#")
                    currentNumber = ""
                }
                structure.append(char)
            }
        }

        if !currentNumber.isEmpty {
            if let num = Double(currentNumber) {
                numbers.append(num)
            }
            structure.append("#")
        }

        return (numbers, structure)
    }
}
