// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("CSS Value Parsing Tests")
struct ValueParsingTests {
    // MARK: - CSSLength Tests

    @Suite("CSSLength Parsing")
    struct LengthTests {
        @Test("Parse absolute length units")
        func absoluteUnits() throws {
            let cases: [(String, Double, CSSLengthUnit)] = [
                ("10px", 10, .px),
                ("2.5em", 2.5, .em),
                ("1.5rem", 1.5, .rem),
                ("100vw", 100, .vw),
                ("50vh", 50, .vh),
                ("1in", 1, .in),
                ("2.54cm", 2.54, .cm),
                ("25.4mm", 25.4, .mm),
                ("12pt", 12, .pt),
                ("1pc", 1, .pc),
            ]

            for (input, expectedValue, expectedUnit) in cases {
                let parser = Parser(css: input)
                let result = CSSLength.parse(parser)
                guard case let .success(length) = result else {
                    Issue.record("Failed to parse '\(input)'")
                    continue
                }
                #expect(length.value == expectedValue, "Value mismatch for '\(input)'")
                #expect(length.unit == expectedUnit, "Unit mismatch for '\(input)'")
            }
        }

        @Test("Parse viewport units")
        func viewportUnits() throws {
            let cases: [(String, CSSLengthUnit)] = [
                ("100vw", .vw),
                ("100vh", .vh),
                ("50vmin", .vmin),
                ("50vmax", .vmax),
                ("100svw", .svw),
                ("100svh", .svh),
                ("100lvw", .lvw),
                ("100lvh", .lvh),
                ("100dvw", .dvw),
                ("100dvh", .dvh),
            ]

            for (input, expectedUnit) in cases {
                let parser = Parser(css: input)
                let result = CSSLength.parse(parser)
                guard case let .success(length) = result else {
                    Issue.record("Failed to parse '\(input)'")
                    continue
                }
                #expect(length.unit == expectedUnit)
            }
        }

        @Test("Parse container query units")
        func containerQueryUnits() throws {
            let cases: [(String, CSSLengthUnit)] = [
                ("50cqw", .cqw),
                ("50cqh", .cqh),
                ("50cqi", .cqi),
                ("50cqb", .cqb),
                ("50cqmin", .cqmin),
                ("50cqmax", .cqmax),
            ]

            for (input, expectedUnit) in cases {
                let parser = Parser(css: input)
                let result = CSSLength.parse(parser)
                guard case let .success(length) = result else {
                    Issue.record("Failed to parse '\(input)'")
                    continue
                }
                #expect(length.unit == expectedUnit)
            }
        }

        @Test("Parse negative lengths")
        func negativeLengths() throws {
            let parser = Parser(css: "-10px")
            let result = CSSLength.parse(parser)
            guard case let .success(length) = result else {
                Issue.record("Failed to parse negative length")
                return
            }
            #expect(length.value == -10)
            #expect(length.unit == .px)
        }

        @Test("Parse zero with unit")
        func zeroWithUnit() throws {
            let parser = Parser(css: "0px")
            let result = CSSLength.parse(parser)
            guard case let .success(length) = result else {
                Issue.record("Failed to parse zero length")
                return
            }
            #expect(length.value == 0)
            #expect(length.unit == .px)
        }

        @Test("CSSLength serialization roundtrip")
        func serializationRoundtrip() throws {
            let length = CSSLength(10.5, .px)
            let serialized = length.string()
            #expect(serialized == "10.5px")
        }

        @Test("CSSLength pixel conversion")
        func pixelConversion() throws {
            let cases: [(CSSLength, Double)] = [
                (CSSLength(96, .px), 96),
                (CSSLength(1, .in), 96),
                (CSSLength(2.54, .cm), 96),
                (CSSLength(25.4, .mm), 96),
                (CSSLength(72, .pt), 96),
                (CSSLength(6, .pc), 96),
            ]

            for (length, expectedPx) in cases {
                let px = length.pixels
                #expect(px != nil)
                #expect(abs(px! - expectedPx) < 0.001, "Conversion failed for \(length.unit)")
            }
        }
    }

    // MARK: - CSSPercentage Tests

    @Suite("CSSPercentage Parsing")
    struct PercentageTests {
        @Test("Parse percentage values")
        func parsePercentages() throws {
            let cases: [(String, Double)] = [
                ("50%", 0.5),
                ("100%", 1.0),
                ("0%", 0.0),
                ("25.5%", 0.255),
                ("-10%", -0.1),
            ]

            for (input, expectedValue) in cases {
                let parser = Parser(css: input)
                let result = CSSPercentage.parse(parser)
                guard case let .success(pct) = result else {
                    Issue.record("Failed to parse '\(input)'")
                    continue
                }
                #expect(abs(pct.value - expectedValue) < 0.0001, "Value mismatch for '\(input)'")
            }
        }

        @Test("CSSPercentage serialization")
        func serialization() throws {
            let pct = CSSPercentage(0.5)
            let serialized = pct.string()
            #expect(serialized == "50%")
        }
    }

    // MARK: - CSSAngle Tests

    @Suite("CSSAngle Parsing")
    struct AngleTests {
        @Test("Parse angle units")
        func parseAngles() throws {
            let cases: [(String, Double)] = [
                ("45deg", 45),
                ("90deg", 90),
                ("0.5turn", 180),
                ("1turn", 360),
                ("100grad", 90),
                ("1.5708rad", 90.00021045914971), // approximately 90 degrees
            ]

            for (input, expectedDegrees) in cases {
                let parser = Parser(css: input)
                let result = CSSAngle.parse(parser)
                guard case let .success(angle) = result else {
                    Issue.record("Failed to parse '\(input)'")
                    continue
                }
                #expect(abs(angle.degrees - expectedDegrees) < 0.01, "Degree conversion mismatch for '\(input)'")
            }
        }

        @Test("Parse negative angles")
        func negativeAngles() throws {
            let parser = Parser(css: "-45deg")
            let result = CSSAngle.parse(parser)
            guard case let .success(angle) = result else {
                Issue.record("Failed to parse negative angle")
                return
            }
            #expect(angle.degrees == -45)
        }

        @Test("CSSAngle serialization")
        func serialization() throws {
            let angle = CSSAngle.deg(45)
            let serialized = angle.string()
            #expect(serialized == "45deg")
        }

        @Test("Parse angle via parseCSSValue")
        func parseViaRegistry() throws {
            let parser = Parser(css: "45deg")
            let result = parseCSSValue(input: parser)
            guard case let .success(.angle(angle)) = result else {
                Issue.record("Expected angle, got \(result)")
                return
            }
            #expect(angle.degrees == 45)
        }

        @Test("CSSLength fails on angle input")
        func lengthFailsOnAngle() throws {
            let parser = Parser(css: "45deg")
            let result = CSSLength.parse(parser)
            // Should fail because deg is not a length unit
            guard case .failure = result else {
                Issue.record("Expected failure, got \(result)")
                return
            }
        }

        @Test("tryParse sequence for angle")
        func tryParseSequence() throws {
            let parser = Parser(css: "45deg")

            let r1 = parser.tryParse { CSSLength.parse($0) }
            #expect(r1.isFailure, "Length should fail on angle")

            #expect(!parser.isExhausted, "Parser should not be exhausted after failed parse")

            let r2 = parser.tryParse { CSSAngle.parse($0) }
            guard case let .success(angle) = r2 else {
                Issue.record("Angle parse failed: \(r2)")
                return
            }
            #expect(angle.degrees == 45)
        }

        @Test("Manual parse sequence like macro")
        func manualParseSequence() throws {
            let parser = Parser(css: "45deg")

            if case .success = parser.tryParse({ Color.parse($0) }) {
                Issue.record("Should not match color")
                return
            }
            if case .success = parser.tryParse({ CSSGradient.parse($0) }) {
                Issue.record("Should not match gradient")
                return
            }
            if case .success = parser.tryParse({ CSSBasicShape.parse($0) }) {
                Issue.record("Should not match basicShape")
                return
            }
            if case .success = parser.tryParse({ CSSEasingFunction.parse($0) }) {
                Issue.record("Should not match easing")
                return
            }
            if case .success = parser.tryParse({ CSSLengthPercentage.parse($0) }) {
                Issue.record("Should not match lengthPercentage")
                return
            }
            if case .success = parser.tryParse({ CSSLength.parse($0) }) {
                Issue.record("Should not match length")
                return
            }
            if case .success = parser.tryParse({ CSSPercentage.parse($0) }) {
                Issue.record("Should not match percentage")
                return
            }
            if case let .success(angle) = parser.tryParse({ CSSAngle.parse($0) }) {
                #expect(angle.degrees == 45)
                return
            }
            Issue.record("Should have matched angle")
        }

        @Test("Full parse sequence like macro")
        func fullParseSequence() throws {
            let parser = Parser(css: "45deg")

            // All types in the same order as CSSValueRegistry
            if case .success = parser.tryParse({ Color.parse($0) }) { return }
            if case .success = parser.tryParse({ CSSGradient.parse($0) }) { return }
            if case .success = parser.tryParse({ CSSBasicShape.parse($0) }) { return }
            if case .success = parser.tryParse({ CSSEasingFunction.parse($0) }) { return }
            if case .success = parser.tryParse({ CSSLengthPercentage.parse($0) }) { return }
            if case .success = parser.tryParse({ CSSLength.parse($0) }) { return }
            if case .success = parser.tryParse({ CSSPercentage.parse($0) }) { return }
            if case let .success(angle) = parser.tryParse({ CSSAngle.parse($0) }) {
                #expect(angle.degrees == 45)
                return
            }
            if case .success = parser.tryParse({ CSSTime.parse($0) }) { return }
            if case .success = parser.tryParse({ CSSResolution.parse($0) }) { return }
            if case .success = parser.tryParse({ CSSRatio.parse($0) }) { return }
            if case .success = parser.tryParse({ CSSAlphaValue.parse($0) }) { return }
            if case .success = parser.tryParse({ CSSNumber.parse($0) }) { return }
            if case .success = parser.tryParse({ CSSString.parse($0) }) { return }
            if case .success = parser.tryParse({ CSSUrl.parse($0) }) { return }
            if case .success = parser.tryParse({ CSSImage.parse($0) }) { return }
            if case .success = parser.tryParse({ CSSRect<CSSLengthPercentage>.parse($0) }) { return }
            if case .success = parser.tryParse({ CSSPosition.parse($0) }) { return }
            if case .success = parser.tryParse({ CSSCustomIdent.parse($0) }) { return }

            Issue.record("Should have matched angle")
        }

        @Test("Check CSSValue memory layout")
        func checkMemoryLayout() throws {
            print("Size of CSSAngle: \(MemoryLayout<CSSAngle>.size)")
            print("Stride of CSSAngle: \(MemoryLayout<CSSAngle>.stride)")
            print("Alignment of CSSAngle: \(MemoryLayout<CSSAngle>.alignment)")

            print("Size of CSSValue: \(MemoryLayout<CSSValue>.size)")
            print("Stride of CSSValue: \(MemoryLayout<CSSValue>.stride)")
            print("Alignment of CSSValue: \(MemoryLayout<CSSValue>.alignment)")

            // Check sizes of individual types
            print("Size of Color: \(MemoryLayout<Color>.size)")
            print("Size of CSSGradient: \(MemoryLayout<CSSGradient>.size)")
            print("Size of CSSBasicShape: \(MemoryLayout<CSSBasicShape>.size)")
            print("Size of CSSEasingFunction: \(MemoryLayout<CSSEasingFunction>.size)")
            print("Size of CSSLengthPercentage: \(MemoryLayout<CSSLengthPercentage>.size)")
            print("Size of CSSLength: \(MemoryLayout<CSSLength>.size)")
            print("Size of CSSPercentage: \(MemoryLayout<CSSPercentage>.size)")
            print("Size of CSSTime: \(MemoryLayout<CSSTime>.size)")
            print("Size of CSSResolution: \(MemoryLayout<CSSResolution>.size)")
            print("Size of CSSRatio: \(MemoryLayout<CSSRatio>.size)")
            print("Size of CSSAlphaValue: \(MemoryLayout<CSSAlphaValue>.size)")
            print("Size of CSSNumber: \(MemoryLayout<CSSNumber>.size)")
            print("Size of CSSString: \(MemoryLayout<CSSString>.size)")
            print("Size of CSSUrl: \(MemoryLayout<CSSUrl>.size)")
            print("Size of CSSImage: \(MemoryLayout<CSSImage>.size)")
            print("Size of CSSRect<CSSLengthPercentage>: \(MemoryLayout<CSSRect<CSSLengthPercentage>>.size)")
            print("Size of CSSPosition: \(MemoryLayout<CSSPosition>.size)")
            print("Size of CSSCustomIdent: \(MemoryLayout<CSSCustomIdent>.size)")

            #expect(MemoryLayout<CSSValue>.size > 0)
        }

        @Test("Create CSSValue number")
        func createCSSValueNumber() throws {
            let num: CSSNumber = 42
            let value = CSSValue.number(num)
            guard case let .number(n) = value else {
                Issue.record("Expected number case")
                return
            }
            #expect(n == 42)
        }

        @Test("Create CSSValue percentage")
        func createCSSValuePercentage() throws {
            let pct = CSSPercentage(0.5)
            let value = CSSValue.percentage(pct)
            guard case let .percentage(p) = value else {
                Issue.record("Expected percentage case")
                return
            }
            #expect(p.value == 0.5)
        }

        @Test("Create CSSValue length")
        func createCSSValueLength() throws {
            let len = CSSLength(10, .px)
            let value = CSSValue.length(len)
            guard case let .length(l) = value else {
                Issue.record("Expected length case")
                return
            }
            #expect(l.value == 10)
        }

        @Test("Direct CSSValue.angle creation")
        func directCSSValueAngleCreation() throws {
            let angle = CSSAngle.deg(45)
            #expect(angle.degrees == 45)

            // Just create the CSSValue directly without any parsing
            let value = CSSValue.angle(angle)

            // Try to access it
            guard case let .angle(extractedAngle) = value else {
                Issue.record("Expected angle case")
                return
            }
            #expect(extractedAngle.degrees == 45)
        }

        @Test("Full parse with CSSValue wrapping")
        func fullParseWithWrapping() throws {
            let parser = Parser(css: "45deg")

            // Exactly like the macro-generated code, returning CSSValue
            func testParseCSSValue(input: Parser) -> Result<CSSValue, BasicParseError> {
                if case let .success(v) = input.tryParse({ Color.parse($0) }) {
                    return .success(.color(v))
                }
                if case let .success(v) = input.tryParse({ CSSGradient.parse($0) }) {
                    return .success(.gradient(v))
                }
                if case let .success(v) = input.tryParse({ CSSBasicShape.parse($0) }) {
                    return .success(.basicShape(v))
                }
                if case let .success(v) = input.tryParse({ CSSEasingFunction.parse($0) }) {
                    return .success(.easing(v))
                }
                if case let .success(v) = input.tryParse({ CSSLengthPercentage.parse($0) }) {
                    return .success(.lengthPercentage(v))
                }
                if case let .success(v) = input.tryParse({ CSSLength.parse($0) }) {
                    return .success(.length(v))
                }
                if case let .success(v) = input.tryParse({ CSSPercentage.parse($0) }) {
                    return .success(.percentage(v))
                }
                if case let .success(v) = input.tryParse({ CSSAngle.parse($0) }) {
                    return .success(.angle(v))
                }
                if case let .success(v) = input.tryParse({ CSSTime.parse($0) }) {
                    return .success(.time(v))
                }
                if case let .success(v) = input.tryParse({ CSSResolution.parse($0) }) {
                    return .success(.resolution(v))
                }
                if case let .success(v) = input.tryParse({ CSSRatio.parse($0) }) {
                    return .success(.ratio(v))
                }
                if case let .success(v) = input.tryParse({ CSSAlphaValue.parse($0) }) {
                    return .success(.alpha(v))
                }
                if case let .success(v) = input.tryParse({ CSSNumber.parse($0) }) {
                    return .success(.number(v))
                }
                if case let .success(v) = input.tryParse({ CSSString.parse($0) }) {
                    return .success(.string(v))
                }
                if case let .success(v) = input.tryParse({ CSSUrl.parse($0) }) {
                    return .success(.url(v))
                }
                if case let .success(v) = input.tryParse({ CSSImage.parse($0) }) {
                    return .success(.image(v))
                }
                if case let .success(v) = input.tryParse({ CSSRect<CSSLengthPercentage>.parse($0) }) {
                    return .success(.rect(v))
                }
                if case let .success(v) = input.tryParse({ CSSPosition.parse($0) }) {
                    return .success(.position(v))
                }
                if case let .success(v) = input.tryParse({ CSSCustomIdent.parse($0) }) {
                    return .success(.ident(v))
                }
                return .failure(input.newBasicError(.endOfInput))
            }

            let result = testParseCSSValue(input: parser)
            guard case let .success(.angle(angle)) = result else {
                Issue.record("Expected angle, got \(result)")
                return
            }
            #expect(angle.degrees == 45)
        }
    }

    // MARK: - CSSTime Tests

    @Suite("CSSTime Parsing")
    struct TimeTests {
        @Test("Parse time values")
        func parseTime() throws {
            let cases: [(String, Double)] = [
                ("1s", 1.0),
                ("500ms", 0.5),
                ("0.5s", 0.5),
                ("1000ms", 1.0),
                ("2.5s", 2.5),
            ]

            for (input, expectedSeconds) in cases {
                let parser = Parser(css: input)
                let result = CSSTime.parse(parser)
                guard case let .success(time) = result else {
                    Issue.record("Failed to parse '\(input)'")
                    continue
                }
                #expect(abs(time.inSeconds - expectedSeconds) < 0.0001, "Seconds mismatch for '\(input)'")
            }
        }

        @Test("CSSTime serialization prefers shorter unit")
        func serializationPrefersShort() throws {
            // 500ms should serialize as 500ms
            let time = CSSTime.milliseconds(500)
            let serialized = time.string()
            #expect(serialized == "500ms")

            // 1000ms should serialize as 1s
            let time2 = CSSTime.milliseconds(1000)
            let serialized2 = time2.string()
            #expect(serialized2 == "1s")
        }
    }

    // MARK: - CSSResolution Tests

    @Suite("CSSResolution Parsing")
    struct ResolutionTests {
        @Test("Parse resolution values")
        func parseResolution() throws {
            let cases: [(String, Double)] = [
                ("96dpi", 96),
                ("1dppx", 96),
                ("2dppx", 192),
                ("1x", 96),
                ("2x", 192),
            ]

            for (input, expectedDpi) in cases {
                let parser = Parser(css: input)
                let result = CSSResolution.parse(parser)
                guard case let .success(res) = result else {
                    Issue.record("Failed to parse '\(input)'")
                    continue
                }
                #expect(abs(res.inDpi - expectedDpi) < 0.01, "DPI mismatch for '\(input)'")
            }
        }
    }

    // MARK: - CSSLengthPercentage Tests

    @Suite("CSSLengthPercentage Parsing")
    struct LengthPercentageTests {
        @Test("Parse length-percentage as length")
        func parseAsLength() throws {
            let parser = Parser(css: "10px")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse length-percentage")
                return
            }
            guard case let .dimension(length) = lp else {
                Issue.record("Expected dimension, got \(lp)")
                return
            }
            #expect(length.value == 10)
            #expect(length.unit == .px)
        }

        @Test("Parse length-percentage as percentage")
        func parseAsPercentage() throws {
            let parser = Parser(css: "50%")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse length-percentage")
                return
            }
            guard case let .percentage(pct) = lp else {
                Issue.record("Expected percentage, got \(lp)")
                return
            }
            #expect(pct.value == 0.5)
        }
    }

    // MARK: - CSSPosition Tests

    @Suite("CSSPosition Parsing")
    struct PositionTests {
        @Test("Parse single keyword positions")
        func singleKeyword() throws {
            // Test center keyword
            let parser1 = Parser(css: "center")
            let result1 = CSSPosition.parse(parser1)
            guard case let .success(pos1) = result1 else {
                Issue.record("Failed to parse 'center'")
                return
            }
            guard case .keyword(.center) = pos1.horizontal else {
                Issue.record("Expected horizontal center")
                return
            }
            guard case .keyword(.center) = pos1.vertical else {
                Issue.record("Expected vertical center")
                return
            }

            // Test left keyword
            let parser2 = Parser(css: "left")
            let result2 = CSSPosition.parse(parser2)
            guard case let .success(pos2) = result2 else {
                Issue.record("Failed to parse 'left'")
                return
            }
            guard case .keyword(.left) = pos2.horizontal else {
                Issue.record("Expected horizontal left")
                return
            }
        }

        @Test("Parse two keyword positions")
        func twoKeywords() throws {
            let parser = Parser(css: "left top")
            let result = CSSPosition.parse(parser)
            guard case let .success(pos) = result else {
                Issue.record("Failed to parse position")
                return
            }
            guard case .keyword(.left) = pos.horizontal else {
                Issue.record("Expected horizontal left")
                return
            }
            guard case .keyword(.top) = pos.vertical else {
                Issue.record("Expected vertical top")
                return
            }
        }

        @Test("Parse percentage positions")
        func percentagePosition() throws {
            let parser = Parser(css: "25% 75%")
            let result = CSSPosition.parse(parser)
            guard case let .success(pos) = result else {
                Issue.record("Failed to parse position")
                return
            }
            // Should have length-percentage values
            guard case .lengthPercentage = pos.horizontal else {
                Issue.record("Expected horizontal length-percentage, got \(pos.horizontal)")
                return
            }
            guard case .lengthPercentage = pos.vertical else {
                Issue.record("Expected vertical length-percentage, got \(pos.vertical)")
                return
            }
        }
    }

    // MARK: - CSSEasingFunction Tests

    @Suite("CSSEasingFunction Parsing")
    struct EasingTests {
        @Test("Parse keyword easing functions")
        func keywordEasing() throws {
            let cases: [(String, CSSEasingFunction)] = [
                ("linear", .linear),
                ("ease", .ease),
                ("ease-in", .easeIn),
                ("ease-out", .easeOut),
                ("ease-in-out", .easeInOut),
            ]

            for (input, expected) in cases {
                let parser = Parser(css: input)
                let result = CSSEasingFunction.parse(parser)
                guard case let .success(easing) = result else {
                    Issue.record("Failed to parse '\(input)'")
                    continue
                }
                #expect(easing == expected)
            }
        }

        @Test("Parse cubic-bezier")
        func cubicBezier() throws {
            let parser = Parser(css: "cubic-bezier(0.4, 0, 0.2, 1)")
            let result = CSSEasingFunction.parse(parser)
            guard case let .success(easing) = result else {
                Issue.record("Failed to parse cubic-bezier")
                return
            }
            guard case let .cubicBezier(x1, y1, x2, y2) = easing else {
                Issue.record("Expected cubic-bezier, got \(easing)")
                return
            }
            #expect(x1 == 0.4)
            #expect(y1 == 0)
            #expect(x2 == 0.2)
            #expect(y2 == 1)
        }

        @Test("Parse steps")
        func steps() throws {
            let parser = Parser(css: "steps(4, end)")
            let result = CSSEasingFunction.parse(parser)
            guard case let .success(easing) = result else {
                Issue.record("Failed to parse steps")
                return
            }
            guard case let .steps(count, position) = easing else {
                Issue.record("Expected steps, got \(easing)")
                return
            }
            #expect(count == 4)
            #expect(position == .end)
        }

        @Test("CSSEasingFunction serialization roundtrip")
        func serializationRoundtrip() throws {
            let easing = CSSEasingFunction.cubicBezier(x1: 0.4, y1: 0, x2: 0.2, y2: 1)
            let serialized = easing.string()
            #expect(serialized == "cubic-bezier(0.4, 0, 0.2, 1)")
        }
    }

    // MARK: - CSSRatio Tests

    @Suite("CSSRatio Parsing")
    struct RatioTests {
        @Test("Parse ratio values")
        func parseRatio() throws {
            let cases: [(String, Double, Double)] = [
                ("16/9", 16, 9),
                ("4/3", 4, 3),
                ("1/1", 1, 1),
                ("2.35/1", 2.35, 1),
            ]

            for (input, expectedNum, expectedDenom) in cases {
                let parser = Parser(css: input)
                let result = CSSRatio.parse(parser)
                guard case let .success(ratio) = result else {
                    Issue.record("Failed to parse '\(input)'")
                    continue
                }
                #expect(ratio.numerator == expectedNum, "Numerator mismatch for '\(input)'")
                #expect(ratio.denominator == expectedDenom, "Denominator mismatch for '\(input)'")
            }
        }

        @Test("Parse single number ratio")
        func singleNumberRatio() throws {
            let parser = Parser(css: "2")
            let result = CSSRatio.parse(parser)
            guard case let .success(ratio) = result else {
                Issue.record("Failed to parse single number ratio")
                return
            }
            #expect(ratio.numerator == 2)
            #expect(ratio.denominator == 1)
        }

        @Test("CSSRatio value calculation")
        func ratioValue() throws {
            let ratio = CSSRatio(16, 9)
            let value = ratio.value
            #expect(abs(value - 1.777777) < 0.001)
        }
    }

    // MARK: - CSSAlphaValue Tests

    @Suite("CSSAlphaValue Parsing")
    struct AlphaTests {
        @Test("Parse alpha as number")
        func parseAsNumber() throws {
            let cases: [(String, Double)] = [
                ("1", 1.0),
                ("0", 0.0),
                ("0.5", 0.5),
                ("0.75", 0.75),
            ]

            for (input, expected) in cases {
                let parser = Parser(css: input)
                let result = CSSAlphaValue.parse(parser)
                guard case let .success(alpha) = result else {
                    Issue.record("Failed to parse '\(input)'")
                    continue
                }
                #expect(alpha.value == expected)
            }
        }

        @Test("Parse alpha as percentage")
        func parseAsPercentage() throws {
            let cases: [(String, Double)] = [
                ("100%", 1.0),
                ("0%", 0.0),
                ("50%", 0.5),
                ("75%", 0.75),
            ]

            for (input, expected) in cases {
                let parser = Parser(css: input)
                let result = CSSAlphaValue.parse(parser)
                guard case let .success(alpha) = result else {
                    Issue.record("Failed to parse '\(input)'")
                    continue
                }
                #expect(alpha.value == expected)
            }
        }

        @Test("Alpha value clamping")
        func clamping() throws {
            let alpha1 = CSSAlphaValue(1.5)
            #expect(alpha1.value == 1.0)

            let alpha2 = CSSAlphaValue(-0.5)
            #expect(alpha2.value == 0.0)
        }
    }

    // MARK: - CSSGradient Tests

    @Suite("CSSGradient Parsing")
    struct GradientTests {
        @Test("Parse linear-gradient")
        func linearGradient() throws {
            let parser = Parser(css: "linear-gradient(to right, red, blue)")
            let result = CSSGradient.parse(parser)
            guard case let .success(gradient) = result else {
                Issue.record("Failed to parse linear-gradient")
                return
            }
            guard case let .linear(linear) = gradient else {
                Issue.record("Expected linear gradient, got \(gradient)")
                return
            }
            #expect(linear.items.count >= 2)
            guard case .side(.right, nil) = linear.direction else {
                Issue.record("Expected direction to right")
                return
            }
        }

        @Test("Parse linear-gradient with angle")
        func linearGradientWithAngle() throws {
            let parser = Parser(css: "linear-gradient(45deg, red, blue)")
            let result = CSSGradient.parse(parser)
            guard case let .success(gradient) = result else {
                Issue.record("Failed to parse linear-gradient with angle")
                return
            }
            guard case let .linear(linear) = gradient else {
                Issue.record("Expected linear gradient")
                return
            }
            guard case let .angle(angle) = linear.direction else {
                Issue.record("Expected angle direction")
                return
            }
            #expect(angle.degrees == 45)
        }

        @Test("Parse radial-gradient")
        func radialGradient() throws {
            let parser = Parser(css: "radial-gradient(circle, red, blue)")
            let result = CSSGradient.parse(parser)
            guard case let .success(gradient) = result else {
                Issue.record("Failed to parse radial-gradient")
                return
            }
            guard case .radial = gradient else {
                Issue.record("Expected radial gradient, got \(gradient)")
                return
            }
        }

        @Test("Parse conic-gradient")
        func conicGradient() throws {
            let parser = Parser(css: "conic-gradient(red, blue)")
            let result = CSSGradient.parse(parser)
            guard case let .success(gradient) = result else {
                Issue.record("Failed to parse conic-gradient")
                return
            }
            guard case .conic = gradient else {
                Issue.record("Expected conic gradient, got \(gradient)")
                return
            }
        }

        @Test("Parse repeating-linear-gradient")
        func repeatingLinearGradient() throws {
            let parser = Parser(css: "repeating-linear-gradient(red, blue 20px)")
            let result = CSSGradient.parse(parser)
            guard case let .success(gradient) = result else {
                Issue.record("Failed to parse repeating-linear-gradient")
                return
            }
            guard case .repeatingLinear = gradient else {
                Issue.record("Expected repeating linear gradient, got \(gradient)")
                return
            }
        }

        @Test("Parse gradient with color interpolation hint")
        func gradientWithHint() throws {
            let parser = Parser(css: "linear-gradient(red, 30%, blue)")
            let result = CSSGradient.parse(parser)
            guard case let .success(gradient) = result else {
                Issue.record("Failed to parse gradient with hint")
                return
            }
            guard case let .linear(linear) = gradient else {
                Issue.record("Expected linear gradient")
                return
            }
            // Should have 3 items: color stop, hint, color stop
            #expect(linear.items.count == 3)
            guard case .colorStop = linear.items[0],
                  case .hint = linear.items[1],
                  case .colorStop = linear.items[2]
            else {
                Issue.record("Expected color stop, hint, color stop")
                return
            }
        }

        @Test("Parse gradient with dual position color stop")
        func gradientWithDualPosition() throws {
            let parser = Parser(css: "linear-gradient(red 10% 20%, blue)")
            let result = CSSGradient.parse(parser)
            guard case let .success(gradient) = result else {
                Issue.record("Failed to parse gradient with dual position")
                return
            }
            guard case let .linear(linear) = gradient else {
                Issue.record("Expected linear gradient")
                return
            }
            // Should have 3 items: two color stops for red (at 10% and 20%), one for blue
            #expect(linear.items.count == 3)
            guard case let .colorStop(stop1) = linear.items[0],
                  case let .colorStop(stop2) = linear.items[1]
            else {
                Issue.record("Expected two color stops")
                return
            }
            // Both stops should have the same color
            #expect(stop1.color == stop2.color)
        }

        @Test("Roundtrip gradient with hint")
        func roundtripGradientWithHint() throws {
            let parser = Parser(css: "linear-gradient(red, 50%, blue)")
            let result = CSSGradient.parse(parser)
            guard case let .success(gradient) = result else {
                Issue.record("Failed to parse")
                return
            }
            let serialized = gradient.string()
            #expect(serialized.contains("50%"))
        }
    }

    // MARK: - CSSImage Tests

    @Suite("CSSImage Parsing")
    struct ImageTests {
        @Test("Parse url() image")
        func urlImage() throws {
            let parser = Parser(css: "url('image.png')")
            let result = CSSImage.parse(parser)
            guard case let .success(image) = result else {
                Issue.record("Failed to parse url image")
                return
            }
            guard case let .url(url) = image else {
                Issue.record("Expected url image, got \(image)")
                return
            }
            #expect(url.url == "image.png")
        }

        @Test("Parse gradient as image")
        func gradientImage() throws {
            let parser = Parser(css: "linear-gradient(red, blue)")
            let result = CSSImage.parse(parser)
            guard case let .success(image) = result else {
                Issue.record("Failed to parse gradient image")
                return
            }
            guard case .gradient = image else {
                Issue.record("Expected gradient image, got \(image)")
                return
            }
        }
    }

    // MARK: - CSSCustomIdent Tests

    @Suite("CSSCustomIdent Parsing")
    struct CustomIdentTests {
        @Test("Parse valid custom identifiers")
        func validIdents() throws {
            let cases = ["my-animation", "slide-in", "fadeOut", "custom_name"]

            for input in cases {
                let parser = Parser(css: input)
                let result = CSSCustomIdent.parse(parser)
                guard case let .success(ident) = result else {
                    Issue.record("Failed to parse '\(input)'")
                    continue
                }
                #expect(ident.value == input)
            }
        }

        @Test("Reject reserved keywords")
        func rejectReserved() throws {
            let reserved = ["initial", "inherit", "unset", "revert", "default"]

            for input in reserved {
                let parser = Parser(css: input)
                let result = CSSCustomIdent.parse(parser)
                guard case .failure = result else {
                    Issue.record("Should have rejected reserved keyword '\(input)'")
                    continue
                }
            }
        }
    }

    // MARK: - Property Value Parser Tests

    @Suite("Property Value Parser")
    struct PropertyValueParserTests {
        @Test("Parse color property")
        func colorProperty() throws {
            let parser = Parser(css: "red")
            let result = parseCSSProperty(name: "color", input: parser)
            guard case let .success(prop) = result else {
                Issue.record("Failed to parse color property")
                return
            }
            guard case .color = prop else {
                Issue.record("Expected color property, got \(prop)")
                return
            }
        }

        @Test("Parse width property with percentage")
        func widthPercentageProperty() throws {
            let parser = Parser(css: "50%")
            let result = parseCSSProperty(name: "width", input: parser)
            guard case let .success(prop) = result else {
                Issue.record("Failed to parse width property")
                return
            }
            guard case let .width(size) = prop else {
                Issue.record("Expected width property, got \(prop)")
                return
            }
            guard case let .lengthPercentage(lp) = size else {
                Issue.record("Expected lengthPercentage size, got \(size)")
                return
            }
            guard case let .percentage(pct) = lp else {
                Issue.record("Expected percentage, got \(lp)")
                return
            }
            #expect(pct.value == 0.5)
        }

        @Test("Parse margin with auto")
        func marginAutoProperty() throws {
            let parser = Parser(css: "auto")
            let result = parseCSSProperty(name: "margin-top", input: parser)
            guard case let .success(prop) = result else {
                Issue.record("Failed to parse margin-top property")
                return
            }
            guard case let .marginTop(lpa) = prop else {
                Issue.record("Expected marginTop property, got \(prop)")
                return
            }
            guard case .auto = lpa else {
                Issue.record("Expected auto, got \(lpa)")
                return
            }
        }

        @Test("Parse transition-duration property")
        func transitionDurationProperty() throws {
            let parser = Parser(css: "500ms")
            let result = parseCSSProperty(name: "transition-duration", input: parser)
            guard case let .success(prop) = result else {
                Issue.record("Failed to parse transition-duration property")
                return
            }
            guard case let .transitionDuration(time, prefix) = prop else {
                Issue.record("Expected transitionDuration property, got \(prop)")
                return
            }
            #expect(time.inMilliseconds == 500)
            #expect(prefix == .none)
        }

        @Test("Parse transition-timing-function property")
        func transitionTimingFunctionProperty() throws {
            let parser = Parser(css: "ease-in-out")
            let result = parseCSSProperty(name: "transition-timing-function", input: parser)
            guard case let .success(prop) = result else {
                Issue.record("Failed to parse transition-timing-function property")
                return
            }
            guard case let .transitionTimingFunction(easing, prefix) = prop else {
                Issue.record("Expected transitionTimingFunction property, got \(prop)")
                return
            }
            #expect(easing == .easeInOut)
            #expect(prefix == .none)
        }

        @Test("Fallback to unparsed for complex values")
        func unparsedFallback() throws {
            // Use a value that won't parse for the property type
            let parser = Parser(css: "var(--custom)")
            let result = parseCSSProperty(name: "color", input: parser)
            guard case let .success(prop) = result else {
                Issue.record("Failed to parse property")
                return
            }
            guard case .unparsed = prop else {
                Issue.record("Expected unparsed property, got \(prop)")
                return
            }
        }

        @Test("Valid vendor prefix is preserved")
        func validVendorPrefix() throws {
            // transform supports vendor prefixes
            let parser = Parser(css: "rotate(45deg)")
            let result = parseCSSProperty(name: "transform", input: parser, vendorPrefix: .webkit)
            guard case let .success(prop) = result else {
                Issue.record("Failed to parse property")
                return
            }
            guard case let .transform(_, prefix) = prop else {
                Issue.record("Expected transform property, got \(prop)")
                return
            }
            #expect(prefix == .webkit)
            #expect(prop.name == "-webkit-transform")
        }

        @Test("Invalid vendor prefix falls back to unparsed")
        func invalidVendorPrefix() throws {
            // color does NOT support vendor prefixes
            let parser = Parser(css: "red")
            let result = parseCSSProperty(name: "color", input: parser, vendorPrefix: .webkit)
            guard case let .success(prop) = result else {
                Issue.record("Failed to parse property")
                return
            }
            // Should fall back to unparsed because -webkit-color is not valid
            guard case let .unparsed(unparsed) = prop else {
                Issue.record("Expected unparsed property for invalid prefix, got \(prop)")
                return
            }
            #expect(unparsed.propertyId.name == "color")
            #expect(unparsed.string() == "red")
        }
    }

    // MARK: - CSSBasicShape Tests

    @Suite("CSSBasicShape Parsing")
    struct BasicShapeTests {
        @Test("Parse circle() with defaults")
        func circleDefaults() throws {
            let parser = Parser(css: "circle()")
            let result = CSSBasicShape.parse(parser)
            guard case let .success(shape) = result else {
                Issue.record("Failed to parse circle()")
                return
            }
            guard case let .circle(circle) = shape else {
                Issue.record("Expected circle, got \(shape)")
                return
            }
            #expect(circle.radius == .closestSide)
            #expect(circle.position == .center)
        }

        @Test("Parse circle() with radius")
        func circleWithRadius() throws {
            let parser = Parser(css: "circle(50px)")
            let result = CSSBasicShape.parse(parser)
            guard case let .success(shape) = result else {
                Issue.record("Failed to parse circle(50px)")
                return
            }
            guard case let .circle(circle) = shape else {
                Issue.record("Expected circle, got \(shape)")
                return
            }
            guard case let .lengthPercentage(lp) = circle.radius else {
                Issue.record("Expected length-percentage radius")
                return
            }
            guard case let .dimension(length) = lp else {
                Issue.record("Expected dimension")
                return
            }
            #expect(length.value == 50)
            #expect(length.unit == .px)
        }

        @Test("Parse circle() with position")
        func circleWithPosition() throws {
            let parser = Parser(css: "circle(50% at center)")
            let result = CSSBasicShape.parse(parser)
            guard case let .success(shape) = result else {
                Issue.record("Failed to parse circle with position")
                return
            }
            guard case let .circle(circle) = shape else {
                Issue.record("Expected circle, got \(shape)")
                return
            }
            guard case .lengthPercentage = circle.radius else {
                Issue.record("Expected length-percentage radius")
                return
            }
        }

        @Test("Parse ellipse() with defaults")
        func ellipseDefaults() throws {
            let parser = Parser(css: "ellipse()")
            let result = CSSBasicShape.parse(parser)
            guard case let .success(shape) = result else {
                Issue.record("Failed to parse ellipse()")
                return
            }
            guard case let .ellipse(ellipse) = shape else {
                Issue.record("Expected ellipse, got \(shape)")
                return
            }
            #expect(ellipse.radiusX == .closestSide)
            #expect(ellipse.radiusY == .closestSide)
        }

        @Test("Parse ellipse() with radii")
        func ellipseWithRadii() throws {
            let parser = Parser(css: "ellipse(100px 50px)")
            let result = CSSBasicShape.parse(parser)
            guard case let .success(shape) = result else {
                Issue.record("Failed to parse ellipse(100px 50px)")
                return
            }
            guard case let .ellipse(ellipse) = shape else {
                Issue.record("Expected ellipse, got \(shape)")
                return
            }
            guard case let .lengthPercentage(lpX) = ellipse.radiusX,
                  case let .dimension(lengthX) = lpX
            else {
                Issue.record("Expected dimension for radiusX")
                return
            }
            guard case let .lengthPercentage(lpY) = ellipse.radiusY,
                  case let .dimension(lengthY) = lpY
            else {
                Issue.record("Expected dimension for radiusY")
                return
            }
            #expect(lengthX.value == 100)
            #expect(lengthY.value == 50)
        }

        @Test("Parse inset() with single value")
        func insetSingleValue() throws {
            let parser = Parser(css: "inset(10px)")
            let result = CSSBasicShape.parse(parser)
            guard case let .success(shape) = result else {
                Issue.record("Failed to parse inset(10px)")
                return
            }
            guard case let .inset(inset) = shape else {
                Issue.record("Expected inset, got \(shape)")
                return
            }
            // All sides should be 10px
            #expect(inset.rect.top == inset.rect.right)
            #expect(inset.rect.top == inset.rect.bottom)
            #expect(inset.rect.top == inset.rect.left)
        }

        @Test("Parse inset() with four values")
        func insetFourValues() throws {
            let parser = Parser(css: "inset(10px 20px 30px 40px)")
            let result = CSSBasicShape.parse(parser)
            guard case let .success(shape) = result else {
                Issue.record("Failed to parse inset with four values")
                return
            }
            guard case let .inset(inset) = shape else {
                Issue.record("Expected inset, got \(shape)")
                return
            }
            guard case let .dimension(top) = inset.rect.top,
                  case let .dimension(right) = inset.rect.right,
                  case let .dimension(bottom) = inset.rect.bottom,
                  case let .dimension(left) = inset.rect.left
            else {
                Issue.record("Expected all dimensions")
                return
            }
            #expect(top.value == 10)
            #expect(right.value == 20)
            #expect(bottom.value == 30)
            #expect(left.value == 40)
        }

        @Test("Parse inset() with round")
        func insetWithRound() throws {
            let parser = Parser(css: "inset(10px round 5px)")
            let result = CSSBasicShape.parse(parser)
            guard case let .success(shape) = result else {
                Issue.record("Failed to parse inset with round")
                return
            }
            guard case let .inset(inset) = shape else {
                Issue.record("Expected inset, got \(shape)")
                return
            }
            #expect(inset.radius != nil)
        }

        @Test("Parse polygon() with points")
        func polygonWithPoints() throws {
            // Use explicit 0px instead of bare 0 for compatibility
            let parser = Parser(css: "polygon(0px 0px, 100% 0px, 100% 100%, 0px 100%)")
            let result = CSSBasicShape.parse(parser)
            guard case let .success(shape) = result else {
                Issue.record("Failed to parse polygon")
                return
            }
            guard case let .polygon(polygon) = shape else {
                Issue.record("Expected polygon, got \(shape)")
                return
            }
            #expect(polygon.points.count == 4)
            #expect(polygon.fillRule == .nonzero)
        }

        @Test("Parse polygon() with fill rule")
        func polygonWithFillRule() throws {
            let parser = Parser(css: "polygon(evenodd, 0px 0px, 100% 0px, 50% 100%)")
            let result = CSSBasicShape.parse(parser)
            guard case let .success(shape) = result else {
                Issue.record("Failed to parse polygon with fill rule")
                return
            }
            guard case let .polygon(polygon) = shape else {
                Issue.record("Expected polygon, got \(shape)")
                return
            }
            #expect(polygon.fillRule == .evenodd)
            #expect(polygon.points.count == 3)
        }

        @Test("Parse path()")
        func pathShape() throws {
            let parser = Parser(css: "path('M 0 0 L 100 100')")
            let result = CSSBasicShape.parse(parser)
            guard case let .success(shape) = result else {
                Issue.record("Failed to parse path()")
                return
            }
            guard case let .path(path) = shape else {
                Issue.record("Expected path, got \(shape)")
                return
            }
            #expect(path.path == "M 0 0 L 100 100")
            #expect(path.fillRule == .nonzero)
        }

        @Test("Parse path() with fill rule")
        func pathWithFillRule() throws {
            let parser = Parser(css: "path(evenodd, 'M 0 0 L 100 100')")
            let result = CSSBasicShape.parse(parser)
            guard case let .success(shape) = result else {
                Issue.record("Failed to parse path with fill rule")
                return
            }
            guard case let .path(path) = shape else {
                Issue.record("Expected path, got \(shape)")
                return
            }
            #expect(path.fillRule == .evenodd)
        }

        @Test("Circle serialization roundtrip")
        func circleSerializationRoundtrip() throws {
            let circle = CSSCircle(
                radius: .lengthPercentage(.dimension(CSSLength(50, .px))),
                position: .center
            )
            let shape = CSSBasicShape.circle(circle)
            let serialized = shape.string()
            #expect(serialized == "circle(50px)")
        }

        @Test("Polygon serialization roundtrip")
        func polygonSerializationRoundtrip() throws {
            let polygon = CSSPolygon(
                fillRule: .nonzero,
                points: [
                    CSSPoint(x: .dimension(CSSLength(0, .px)), y: .dimension(CSSLength(0, .px))),
                    CSSPoint(x: .percentage(CSSPercentage(1.0)), y: .dimension(CSSLength(0, .px))),
                    CSSPoint(x: .percentage(CSSPercentage(0.5)), y: .percentage(CSSPercentage(1.0))),
                ]
            )
            let shape = CSSBasicShape.polygon(polygon)
            let serialized = shape.string()
            #expect(serialized.contains("polygon"))
            #expect(serialized.contains("100%"))
        }
    }

    // MARK: - CSSShapeOutside Tests

    @Suite("CSSShapeOutside Parsing")
    struct ShapeOutsideTests {
        @Test("Parse none")
        func parseNone() throws {
            let parser = Parser(css: "none")
            let result = CSSShapeOutside.parse(parser)
            guard case let .success(shape) = result else {
                Issue.record("Failed to parse none")
                return
            }
            guard case .none = shape else {
                Issue.record("Expected none, got \(shape)")
                return
            }
        }

        @Test("Parse box value")
        func parseBox() throws {
            let cases: [(String, CSSShapeBox)] = [
                ("margin-box", .marginBox),
                ("border-box", .borderBox),
                ("padding-box", .paddingBox),
                ("content-box", .contentBox),
            ]

            for (input, expected) in cases {
                let parser = Parser(css: input)
                let result = CSSShapeOutside.parse(parser)
                guard case let .success(shape) = result else {
                    Issue.record("Failed to parse '\(input)'")
                    continue
                }
                guard case let .box(box) = shape else {
                    Issue.record("Expected box, got \(shape)")
                    continue
                }
                #expect(box == expected)
            }
        }

        @Test("Parse shape with box")
        func parseShapeWithBox() throws {
            let parser = Parser(css: "circle(50%) border-box")
            let result = CSSShapeOutside.parse(parser)
            guard case let .success(shape) = result else {
                Issue.record("Failed to parse shape with box")
                return
            }
            guard case let .shape(_, box) = shape else {
                Issue.record("Expected shape, got \(shape)")
                return
            }
            #expect(box == .borderBox)
        }

        @Test("Parse image")
        func parseImage() throws {
            let parser = Parser(css: "url('shape.png')")
            let result = CSSShapeOutside.parse(parser)
            guard case let .success(shape) = result else {
                Issue.record("Failed to parse image")
                return
            }
            guard case .image = shape else {
                Issue.record("Expected image, got \(shape)")
                return
            }
        }
    }

    // MARK: - CSSClipPath Tests

    @Suite("CSSClipPath Parsing")
    struct ClipPathTests {
        @Test("Parse none")
        func parseNone() throws {
            let parser = Parser(css: "none")
            let result = CSSClipPath.parse(parser)
            guard case let .success(clipPath) = result else {
                Issue.record("Failed to parse none")
                return
            }
            guard case .none = clipPath else {
                Issue.record("Expected none, got \(clipPath)")
                return
            }
        }

        @Test("Parse url")
        func parseUrl() throws {
            let parser = Parser(css: "url('#myClip')")
            let result = CSSClipPath.parse(parser)
            guard case let .success(clipPath) = result else {
                Issue.record("Failed to parse url")
                return
            }
            guard case .url = clipPath else {
                Issue.record("Expected url, got \(clipPath)")
                return
            }
        }

        @Test("Parse basic shape")
        func parseBasicShape() throws {
            let parser = Parser(css: "circle(50%)")
            let result = CSSClipPath.parse(parser)
            guard case let .success(clipPath) = result else {
                Issue.record("Failed to parse basic shape")
                return
            }
            guard case let .shape(shape, _) = clipPath else {
                Issue.record("Expected shape, got \(clipPath)")
                return
            }
            guard case .circle = shape else {
                Issue.record("Expected circle shape, got \(shape)")
                return
            }
        }

        @Test("Parse shape with geometry box")
        func parseShapeWithBox() throws {
            // Use explicit 0px instead of bare 0
            let parser = Parser(css: "polygon(0px 0px, 100% 0px, 50% 100%) border-box")
            let result = CSSClipPath.parse(parser)
            guard case let .success(clipPath) = result else {
                Issue.record("Failed to parse shape with box")
                return
            }
            guard case let .shape(_, box) = clipPath else {
                Issue.record("Expected shape, got \(clipPath)")
                return
            }
            #expect(box == .borderBox)
        }

        @Test("Parse geometry box only")
        func parseBoxOnly() throws {
            let parser = Parser(css: "padding-box")
            let result = CSSClipPath.parse(parser)
            guard case let .success(clipPath) = result else {
                Issue.record("Failed to parse box")
                return
            }
            guard case let .box(box) = clipPath else {
                Issue.record("Expected box, got \(clipPath)")
                return
            }
            #expect(box == .paddingBox)
        }
    }

    // MARK: - CSSCalc Tests

    @Suite("CSSCalc Parsing")
    struct CalcTests {
        @Test("Parse simple calc() with length")
        func simpleCalcLength() throws {
            let parser = Parser(css: "calc(10px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse calc(10px)")
                return
            }
            // Simple value gets unwrapped
            guard case let .dimension(length) = lp else {
                Issue.record("Expected dimension, got \(lp)")
                return
            }
            #expect(length.value == 10)
            #expect(length.unit == .px)
        }

        @Test("Parse calc() with addition")
        func calcAddition() throws {
            let parser = Parser(css: "calc(10px + 20px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse calc with addition")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case .sum = calc else {
                Issue.record("Expected sum, got \(calc)")
                return
            }
        }

        @Test("Parse calc() with subtraction")
        func calcSubtraction() throws {
            let parser = Parser(css: "calc(100% - 20px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse calc with subtraction")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case .sum = calc else {
                Issue.record("Expected sum, got \(calc)")
                return
            }
        }

        @Test("Parse calc() with multiplication")
        func calcMultiplication() throws {
            let parser = Parser(css: "calc(10px * 2)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse calc with multiplication")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case .product = calc else {
                Issue.record("Expected product, got \(calc)")
                return
            }
        }

        @Test("Parse calc() with division")
        func calcDivision() throws {
            let parser = Parser(css: "calc(100px / 2)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse calc with division")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case .product = calc else {
                Issue.record("Expected product, got \(calc)")
                return
            }
        }

        @Test("Parse calc() with mixed operations")
        func calcMixedOperations() throws {
            let parser = Parser(css: "calc(100% - 20px + 5px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse calc with mixed operations")
                return
            }
            guard case .calc = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
        }

        @Test("Parse min() function")
        func minFunction() throws {
            let parser = Parser(css: "min(100px, 50%)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse min()")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case let .min(args) = fn else {
                Issue.record("Expected min, got \(fn)")
                return
            }
            #expect(args.count == 2)
        }

        @Test("Parse max() function")
        func maxFunction() throws {
            let parser = Parser(css: "max(10px, 20px, 30px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse max()")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case let .max(args) = fn else {
                Issue.record("Expected max, got \(fn)")
                return
            }
            #expect(args.count == 3)
        }

        @Test("Parse clamp() function")
        func clampFunction() throws {
            let parser = Parser(css: "clamp(10px, 50%, 100px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse clamp()")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .clamp = fn else {
                Issue.record("Expected clamp, got \(fn)")
                return
            }
        }

        @Test("Parse abs() function")
        func absFunction() throws {
            let parser = Parser(css: "abs(-10px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse abs()")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .abs = fn else {
                Issue.record("Expected abs, got \(fn)")
                return
            }
        }

        @Test("Parse sign() function")
        func signFunction() throws {
            let parser = Parser(css: "sign(-10px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse sign()")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .sign = fn else {
                Issue.record("Expected sign, got \(fn)")
                return
            }
        }

        @Test("Parse round() function with default strategy")
        func roundFunctionDefault() throws {
            let parser = Parser(css: "round(10px, 5px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse round()")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case let .round(strategy, _, _) = fn else {
                Issue.record("Expected round, got \(fn)")
                return
            }
            #expect(strategy == .nearest)
        }

        @Test("Parse round() function with up strategy")
        func roundFunctionUp() throws {
            let parser = Parser(css: "round(up, 10px, 5px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse round(up)")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case let .round(strategy, _, _) = fn else {
                Issue.record("Expected round, got \(fn)")
                return
            }
            #expect(strategy == .up)
        }

        @Test("Parse round() function with down strategy")
        func roundFunctionDown() throws {
            let parser = Parser(css: "round(down, 10px, 5px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse round(down)")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case let .round(strategy, _, _) = fn else {
                Issue.record("Expected round, got \(fn)")
                return
            }
            #expect(strategy == .down)
        }

        @Test("Parse round() function with to-zero strategy")
        func roundFunctionToZero() throws {
            let parser = Parser(css: "round(to-zero, 10px, 5px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse round(to-zero)")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case let .round(strategy, _, _) = fn else {
                Issue.record("Expected round, got \(fn)")
                return
            }
            #expect(strategy == .toZero)
        }

        @Test("Parse mod() function")
        func modFunction() throws {
            let parser = Parser(css: "mod(18px, 5px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse mod()")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .mod = fn else {
                Issue.record("Expected mod, got \(fn)")
                return
            }
        }

        @Test("Parse rem() function")
        func remFunction() throws {
            let parser = Parser(css: "rem(18px, 5px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse rem()")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .rem = fn else {
                Issue.record("Expected rem, got \(fn)")
                return
            }
        }

        @Test("Parse sin() function with number")
        func sinFunctionWithNumber() throws {
            let parser = Parser(css: "sin(0.785)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse sin()")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .sin = fn else {
                Issue.record("Expected sin, got \(fn)")
                return
            }
        }

        @Test("Parse sin() function with angle")
        func sinFunctionWithAngle() throws {
            let parser = Parser(css: "sin(45deg)")
            let result = CSSAnglePercentage.parse(parser)
            guard case let .success(ap) = result else {
                Issue.record("Failed to parse sin(45deg)")
                return
            }
            guard case let .calc(calc) = ap else {
                Issue.record("Expected calc, got \(ap)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .sin = fn else {
                Issue.record("Expected sin, got \(fn)")
                return
            }
        }

        @Test("Parse cos() function with number")
        func cosFunctionWithNumber() throws {
            let parser = Parser(css: "cos(0.785)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse cos()")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .cos = fn else {
                Issue.record("Expected cos, got \(fn)")
                return
            }
        }

        @Test("Parse cos() function with angle")
        func cosFunctionWithAngle() throws {
            let parser = Parser(css: "cos(45deg)")
            let result = CSSAnglePercentage.parse(parser)
            guard case let .success(ap) = result else {
                Issue.record("Failed to parse cos(45deg)")
                return
            }
            guard case let .calc(calc) = ap else {
                Issue.record("Expected calc, got \(ap)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .cos = fn else {
                Issue.record("Expected cos, got \(fn)")
                return
            }
        }

        @Test("Parse tan() function with number")
        func tanFunctionWithNumber() throws {
            let parser = Parser(css: "tan(0.785)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse tan()")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .tan = fn else {
                Issue.record("Expected tan, got \(fn)")
                return
            }
        }

        @Test("Parse tan() function with angle")
        func tanFunctionWithAngle() throws {
            let parser = Parser(css: "tan(45deg)")
            let result = CSSAnglePercentage.parse(parser)
            guard case let .success(ap) = result else {
                Issue.record("Failed to parse tan(45deg)")
                return
            }
            guard case let .calc(calc) = ap else {
                Issue.record("Expected calc, got \(ap)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .tan = fn else {
                Issue.record("Expected tan, got \(fn)")
                return
            }
        }

        @Test("Parse atan() function")
        func atanFunction() throws {
            let parser = Parser(css: "atan(1)")
            let result = CSSAnglePercentage.parse(parser)
            guard case let .success(ap) = result else {
                Issue.record("Failed to parse atan()")
                return
            }
            guard case let .calc(calc) = ap else {
                Issue.record("Expected calc, got \(ap)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .atan = fn else {
                Issue.record("Expected atan, got \(fn)")
                return
            }
        }

        @Test("Parse asin() function")
        func asinFunction() throws {
            let parser = Parser(css: "asin(0.5)")
            let result = CSSAnglePercentage.parse(parser)
            guard case let .success(ap) = result else {
                Issue.record("Failed to parse asin()")
                return
            }
            guard case let .calc(calc) = ap else {
                Issue.record("Expected calc, got \(ap)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .asin = fn else {
                Issue.record("Expected asin, got \(fn)")
                return
            }
        }

        @Test("Parse acos() function")
        func acosFunction() throws {
            let parser = Parser(css: "acos(0.5)")
            let result = CSSAnglePercentage.parse(parser)
            guard case let .success(ap) = result else {
                Issue.record("Failed to parse acos()")
                return
            }
            guard case let .calc(calc) = ap else {
                Issue.record("Expected calc, got \(ap)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .acos = fn else {
                Issue.record("Expected acos, got \(fn)")
                return
            }
        }

        @Test("Parse atan2() function")
        func atan2Function() throws {
            let parser = Parser(css: "atan2(1, 1)")
            let result = CSSAnglePercentage.parse(parser)
            guard case let .success(ap) = result else {
                Issue.record("Failed to parse atan2()")
                return
            }
            guard case let .calc(calc) = ap else {
                Issue.record("Expected calc, got \(ap)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .atan2 = fn else {
                Issue.record("Expected atan2, got \(fn)")
                return
            }
        }

        @Test("Parse sqrt() function")
        func sqrtFunction() throws {
            let parser = Parser(css: "sqrt(100px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse sqrt()")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .sqrt = fn else {
                Issue.record("Expected sqrt, got \(fn)")
                return
            }
        }

        @Test("Parse pow() function")
        func powFunction() throws {
            let parser = Parser(css: "pow(10px, 2)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse pow()")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .pow = fn else {
                Issue.record("Expected pow, got \(fn)")
                return
            }
        }

        @Test("Parse exp() function")
        func expFunction() throws {
            let parser = Parser(css: "exp(2)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse exp()")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case .exp = fn else {
                Issue.record("Expected exp, got \(fn)")
                return
            }
        }

        @Test("Parse log() function without base")
        func logFunctionNoBase() throws {
            let parser = Parser(css: "log(10px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse log()")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case let .log(_, base) = fn else {
                Issue.record("Expected log, got \(fn)")
                return
            }
            #expect(base == nil)
        }

        @Test("Parse log() function with base")
        func logFunctionWithBase() throws {
            let parser = Parser(css: "log(100px, 10)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse log() with base")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case let .log(_, base) = fn else {
                Issue.record("Expected log, got \(fn)")
                return
            }
            #expect(base != nil)
        }

        @Test("Parse hypot() function")
        func hypotFunction() throws {
            let parser = Parser(css: "hypot(3px, 4px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse hypot()")
                return
            }
            guard case let .calc(calc) = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
            guard case let .function(fn) = calc else {
                Issue.record("Expected function, got \(calc)")
                return
            }
            guard case let .hypot(args) = fn else {
                Issue.record("Expected hypot, got \(fn)")
                return
            }
            #expect(args.count == 2)
        }

        @Test("Parse nested calc() expressions")
        func nestedCalc() throws {
            let parser = Parser(css: "calc(100% - calc(10px + 20px))")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse nested calc")
                return
            }
            guard case .calc = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
        }

        @Test("Parse calc with parentheses")
        func calcWithParentheses() throws {
            let parser = Parser(css: "calc((10px + 20px) * 2)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse calc with parentheses")
                return
            }
            guard case .calc = lp else {
                Issue.record("Expected calc, got \(lp)")
                return
            }
        }

        @Test("Calc serialization roundtrip - sum")
        func calcSerializationSum() throws {
            let calc: CSSCalc<CSSLengthPercentage> = .sum(
                .value(.dimension(CSSLength(10, .px))),
                .value(.dimension(CSSLength(20, .px)))
            )
            let lp: CSSLengthPercentage = .calc(calc)
            let serialized = lp.string()
            #expect(serialized.contains("calc"))
            #expect(serialized.contains("+"))
        }

        @Test("Calc serialization roundtrip - min")
        func calcSerializationMin() throws {
            let calc: CSSCalc<CSSLengthPercentage> = .function(.min([
                .value(.dimension(CSSLength(100, .px))),
                .value(.percentage(CSSPercentage(0.5))),
            ]))
            let lp: CSSLengthPercentage = .calc(calc)
            let serialized = lp.string()
            #expect(serialized.contains("min"))
            #expect(serialized.contains("100px"))
            #expect(serialized.contains("50%"))
        }

        @Test("Calc serialization roundtrip - clamp")
        func calcSerializationClamp() throws {
            let calc: CSSCalc<CSSLengthPercentage> = .function(.clamp(
                .value(.dimension(CSSLength(10, .px))),
                .value(.percentage(CSSPercentage(0.5))),
                .value(.dimension(CSSLength(100, .px)))
            ))
            let lp: CSSLengthPercentage = .calc(calc)
            let serialized = lp.string()
            #expect(serialized.contains("clamp"))
            #expect(serialized.contains("10px"))
            #expect(serialized.contains("50%"))
            #expect(serialized.contains("100px"))
        }

        @Test("Single argument min/max returns argument directly")
        func singleArgMinMax() throws {
            let parser = Parser(css: "min(10px)")
            let result = CSSLengthPercentage.parse(parser)
            guard case let .success(lp) = result else {
                Issue.record("Failed to parse single arg min()")
                return
            }
            // Single arg should be unwrapped to just the value
            guard case let .dimension(length) = lp else {
                Issue.record("Expected dimension, got \(lp)")
                return
            }
            #expect(length.value == 10)
            #expect(length.unit == .px)
        }
    }

    // MARK: - CSSGridTemplate Parsing

    @Suite("CSSGridTemplate Parsing")
    struct GridTemplateTests {
        @Test("Parse grid-template: none")
        func parseNone() throws {
            let parser = Parser(css: "none")
            let result = CSSGridTemplate.parse(parser)
            guard case let .success(template) = result else {
                Issue.record("Failed to parse 'none'")
                return
            }
            guard case .none = template.rows,
                  case .none = template.columns,
                  case .none = template.areas
            else {
                Issue.record("Expected all none")
                return
            }
        }

        @Test("Parse grid-template: rows / columns")
        func parseRowsColumns() throws {
            let parser = Parser(css: "100px auto / 1fr 2fr")
            let result = CSSGridTemplate.parse(parser)
            guard case let .success(template) = result else {
                Issue.record("Failed to parse rows/columns")
                return
            }
            guard case let .trackList(rows) = template.rows,
                  case let .trackList(cols) = template.columns
            else {
                Issue.record("Expected track lists")
                return
            }
            #expect(rows.items.count == 2)
            #expect(cols.items.count == 2)
        }

        @Test("Parse grid-template with areas")
        func parseWithAreas() throws {
            let parser = Parser(css: "\"header header\" 100px \"main sidebar\" auto")
            let result = CSSGridTemplate.parse(parser)
            guard case let .success(template) = result else {
                Issue.record("Failed to parse areas")
                return
            }
            guard case let .areas(columns, tokens) = template.areas else {
                Issue.record("Expected areas, got \(template.areas)")
                return
            }
            #expect(columns == 2)
            #expect(tokens.count == 4)
            #expect(tokens[0] == "header")
            #expect(tokens[1] == "header")
            #expect(tokens[2] == "main")
            #expect(tokens[3] == "sidebar")

            guard case let .trackList(rows) = template.rows else {
                Issue.record("Expected track list for rows")
                return
            }
            #expect(rows.items.count == 2)
        }

        @Test("Parse grid-template with areas and null cells")
        func parseAreasWithNullCells() throws {
            let parser = Parser(css: "\"header header\" \"main .\" \"footer footer\"")
            let result = CSSGridTemplate.parse(parser)
            guard case let .success(template) = result else {
                Issue.record("Failed to parse areas with null cells")
                return
            }
            guard case let .areas(columns, tokens) = template.areas else {
                Issue.record("Expected areas")
                return
            }
            #expect(columns == 2)
            #expect(tokens.count == 6)
            #expect(tokens[3] == nil) // The "." becomes nil
        }

        @Test("Parse grid-template with line names")
        func parseAreasWithLineNames() throws {
            let parser = Parser(css: "[header-start] \"header header\" 100px [header-end]")
            let result = CSSGridTemplate.parse(parser)
            guard case let .success(template) = result else {
                Issue.record("Failed to parse areas with line names")
                return
            }
            guard case let .trackList(rows) = template.rows else {
                Issue.record("Expected track list for rows")
                return
            }
            #expect(rows.lineNames[0].count == 1)
            #expect(rows.lineNames[0][0].value == "header-start")
            #expect(rows.lineNames[1].count == 1)
            #expect(rows.lineNames[1][0].value == "header-end")
        }

        @Test("Parse grid-template with areas and columns")
        func parseAreasWithColumns() throws {
            let parser = Parser(css: "\"header header\" 100px / 1fr 2fr")
            let result = CSSGridTemplate.parse(parser)
            guard case let .success(template) = result else {
                Issue.record("Failed to parse areas with columns")
                return
            }
            guard case .areas = template.areas else {
                Issue.record("Expected areas")
                return
            }
            guard case let .trackList(cols) = template.columns else {
                Issue.record("Expected track list for columns")
                return
            }
            #expect(cols.items.count == 2)
        }

        @Test("Serialize grid-template: none")
        func serializeNone() throws {
            let template = CSSGridTemplate(rows: .none, columns: .none, areas: .none)
            let serialized = template.string()
            #expect(serialized == "none")
        }

        @Test("Serialize grid-template with rows/columns")
        func serializeRowsColumns() throws {
            let rows = CSSTrackList(lineNames: [[]], items: [.trackSize(.trackBreadth(.length(.dimension(.px(100)))))])
            let cols = CSSTrackList(lineNames: [[]], items: [.trackSize(.trackBreadth(.flex(1)))])
            let template = CSSGridTemplate(rows: .trackList(rows), columns: .trackList(cols), areas: .none)
            let serialized = template.string()
            #expect(serialized.contains("100px"))
            #expect(serialized.contains("1fr"))
            #expect(serialized.contains("/"))
        }

        @Test("Roundtrip grid-template with areas")
        func roundtripAreas() throws {
            let input = "\"a b\" 100px \"c d\" auto"
            let parser = Parser(css: input)
            let result = CSSGridTemplate.parse(parser)
            guard case let .success(template) = result else {
                Issue.record("Failed to parse")
                return
            }
            let serialized = template.string()
            #expect(serialized.contains("\"a b\""))
            #expect(serialized.contains("\"c d\""))
            #expect(serialized.contains("100px"))
        }
    }
}
