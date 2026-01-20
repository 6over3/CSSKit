// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("Direct Color Parsing Tests")
struct DirectColorParsingTests {
    @Test("Parse named colors")
    func parseNamedColors() {
        let tests: [(String, (UInt8, UInt8, UInt8))] = [
            ("red", (255, 0, 0)),
            ("green", (0, 128, 0)),
            ("blue", (0, 0, 255)),
            ("rebeccapurple", (102, 51, 153)),
        ]

        for (name, expected) in tests {
            if let color = parseNamedColor(name) {
                #expect(color.red == expected.0, "Red mismatch for \(name)")
                #expect(color.green == expected.1, "Green mismatch for \(name)")
                #expect(color.blue == expected.2, "Blue mismatch for \(name)")
            } else {
                Issue.record("Failed to parse named color: \(name)")
            }
        }

        // transparent is handled as a keyword, not a named color
        #expect(parseNamedColor("transparent") == nil)
    }

    @Test("Parse hex colors")
    func parseHexColors() {
        let tests: [(String, (Double, Double, Double, Double))] = [
            ("fff", (255, 255, 255, 1.0)),
            ("000", (0, 0, 0, 1.0)),
            ("f00", (255, 0, 0, 1.0)),
            ("ff0000", (255, 0, 0, 1.0)),
            ("00ff00", (0, 255, 0, 1.0)),
            ("0000ff", (0, 0, 255, 1.0)),
            ("ff000080", (255, 0, 0, 0.5019607843137255)), // ~0.5
            ("abcd", (170, 187, 204, 0.8666666666666667)), // #aabbccdd short form
        ]

        for (hex, expected) in tests {
            if let color = parseHashColor(hex) {
                #expect(color.red == expected.0, "Red mismatch for #\(hex)")
                #expect(color.green == expected.1, "Green mismatch for #\(hex)")
                #expect(color.blue == expected.2, "Blue mismatch for #\(hex)")
                #expect(abs(color.alpha - expected.3) < 0.01, "Alpha mismatch for #\(hex): got \(color.alpha), expected \(expected.3)")
            } else {
                Issue.record("Failed to parse hex color: #\(hex)")
            }
        }
    }

    @Test("Color serialization roundtrip")
    func colorSerializationRoundtrip() {
        let colors: [(String, String)] = [
            ("rgb(255, 0, 0)", "rgb(255, 0, 0)"),
            ("rgba(255, 0, 0, 0.5)", "rgba(255, 0, 0, 0.5)"),
            ("#ff0000", "rgb(255, 0, 0)"),
            ("#ff000080", "rgba(255, 0, 0, 0.501961)"),
            ("red", "rgb(255, 0, 0)"),
            ("currentcolor", "currentcolor"),
            ("transparent", "rgba(0, 0, 0, 0)"),
        ]

        for (input, expected) in colors {
            let parserInput = ParserInput(input)
            let parser = Parser(parserInput)

            if case let .success(color) = Color.parse(parser) {
                let serialized = color.string
                #expect(serialized == expected, "Roundtrip mismatch for '\(input)': got '\(serialized)', expected '\(expected)'")
            } else {
                Issue.record("Failed to parse color: \(input)")
            }
        }
    }

    @Test("HSL to RGB conversion")
    func hslToRgbConversion() {
        // hsl(0, 100%, 50%) -> red
        let rgb1 = hslToRgb(hue: 0.0, saturation: 1.0, lightness: 0.5)
        #expect(abs(rgb1.red - 1.0) < 0.01 && abs(rgb1.green) < 0.01 && abs(rgb1.blue) < 0.01, "hsl(0, 100%, 50%) should be red")

        // hsl(120, 100%, 50%) -> green
        let rgb2 = hslToRgb(hue: 1.0 / 3.0, saturation: 1.0, lightness: 0.5)
        #expect(abs(rgb2.red) < 0.01 && abs(rgb2.green - 1.0) < 0.01 && abs(rgb2.blue) < 0.01, "hsl(120, 100%, 50%) should be green")

        // hsl(240, 100%, 50%) -> blue
        let rgb3 = hslToRgb(hue: 2.0 / 3.0, saturation: 1.0, lightness: 0.5)
        #expect(abs(rgb3.red) < 0.01 && abs(rgb3.green) < 0.01 && abs(rgb3.blue - 1.0) < 0.01, "hsl(240, 100%, 50%) should be blue")

        // hsl(0, 0%, 50%) -> gray
        let rgb4 = hslToRgb(hue: 0.0, saturation: 0.0, lightness: 0.5)
        #expect(abs(rgb4.red - 0.5) < 0.01 && abs(rgb4.green - 0.5) < 0.01 && abs(rgb4.blue - 0.5) < 0.01, "hsl(0, 0%, 50%) should be gray")
    }

    @Test("HWB to RGB conversion")
    func hwbToRgbConversion() {
        // hwb(0, 0%, 0%) -> red
        let rgb1 = hwbToRgb(hue: 0.0, whiteness: 0.0, blackness: 0.0)
        #expect(abs(rgb1.red - 1.0) < 0.01 && abs(rgb1.green) < 0.01 && abs(rgb1.blue) < 0.01, "hwb(0, 0%, 0%) should be red")

        // hwb(0, 50%, 50%) -> gray
        let rgb2 = hwbToRgb(hue: 0.0, whiteness: 0.5, blackness: 0.5)
        #expect(abs(rgb2.red - 0.5) < 0.01 && abs(rgb2.green - 0.5) < 0.01 && abs(rgb2.blue - 0.5) < 0.01, "hwb(0, 50%, 50%) should be gray")

        // hwb(0, 100%, 0%) -> white
        let rgb3 = hwbToRgb(hue: 0.0, whiteness: 1.0, blackness: 0.0)
        #expect(abs(rgb3.red - 1.0) < 0.01 && abs(rgb3.green - 1.0) < 0.01 && abs(rgb3.blue - 1.0) < 0.01, "hwb(0, 100%, 0%) should be white")

        // hwb(0, 0%, 100%) -> black
        let rgb4 = hwbToRgb(hue: 0.0, whiteness: 0.0, blackness: 1.0)
        #expect(abs(rgb4.red) < 0.01 && abs(rgb4.green) < 0.01 && abs(rgb4.blue) < 0.01, "hwb(0, 0%, 100%) should be black")
    }

    @Test("Lab color parsing and serialization")
    func labColorParsingSerialization() {
        let input = "lab(50 40 59.5)"
        let parserInput = ParserInput(input)
        let parser = Parser(parserInput)

        if case let .success(color) = Color.parse(parser) {
            if case let .lab(lab) = color {
                #expect(lab.lightness == 50)
                #expect(lab.a == 40)
                #expect(lab.b == 59.5)
                #expect(lab.alpha == 1.0)
            } else {
                Issue.record("Expected lab color")
            }
        } else {
            Issue.record("Failed to parse lab color")
        }
    }

    @Test("color() function parsing")
    func colorFunctionParsing() {
        let input = "color(srgb 1 0 0)"
        let parserInput = ParserInput(input)
        let parser = Parser(parserInput)

        if case let .success(color) = Color.parse(parser) {
            if case let .colorFunction(cf) = color {
                #expect(cf.colorSpace == .srgb)
                #expect(cf.c1 == 1.0)
                #expect(cf.c2 == 0.0)
                #expect(cf.c3 == 0.0)
                #expect(cf.alpha == 1.0)
            } else {
                Issue.record("Expected color function")
            }
        } else {
            Issue.record("Failed to parse color() function")
        }
    }
}
