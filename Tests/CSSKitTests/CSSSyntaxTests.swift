// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("CSSSyntax Parsing Tests")
struct CSSSyntaxTests {
    // MARK: - Syntax String Parsing

    @Suite("Syntax String Parsing")
    struct SyntaxStringTests {
        @Test("Parse universal syntax")
        func universalSyntax() throws {
            let result = CSSSyntaxString.parse(string: "*")
            guard case let .success(syntax) = result else {
                Issue.record("Failed to parse universal syntax")
                return
            }
            guard case .universal = syntax else {
                Issue.record("Expected universal, got \(syntax)")
                return
            }
        }

        @Test("Parse single component")
        func singleComponent() throws {
            let cases: [(String, CSSSyntaxComponentKind)] = [
                ("<length>", .length),
                ("<number>", .number),
                ("<percentage>", .percentage),
                ("<length-percentage>", .lengthPercentage),
                ("<color>", .color),
                ("<image>", .image),
                ("<url>", .url),
                ("<integer>", .integer),
                ("<angle>", .angle),
                ("<time>", .time),
                ("<resolution>", .resolution),
                ("<transform-function>", .transformFunction),
                ("<transform-list>", .transformList),
                ("<custom-ident>", .customIdent),
                ("<string>", .string),
            ]

            for (input, expectedKind) in cases {
                let result = CSSSyntaxString.parse(string: input)
                guard case let .success(syntax) = result else {
                    Issue.record("Failed to parse '\(input)'")
                    continue
                }
                guard case let .components(components) = syntax else {
                    Issue.record("Expected components, got \(syntax)")
                    continue
                }
                #expect(components.count == 1, "Expected 1 component for '\(input)'")
                #expect(components[0].kind == expectedKind, "Kind mismatch for '\(input)'")
                #expect(components[0].multiplier == .none, "Expected no multiplier for '\(input)'")
            }
        }

        @Test("Parse literal identifier")
        func literalIdent() throws {
            let result = CSSSyntaxString.parse(string: "auto")
            guard case let .success(syntax) = result else {
                Issue.record("Failed to parse literal ident")
                return
            }
            guard case let .components(components) = syntax else {
                Issue.record("Expected components, got \(syntax)")
                return
            }
            #expect(components.count == 1)
            guard case let .literal(value) = components[0].kind else {
                Issue.record("Expected literal, got \(components[0].kind)")
                return
            }
            #expect(value == "auto")
        }

        @Test("Parse with space multiplier")
        func spaceMultiplier() throws {
            let result = CSSSyntaxString.parse(string: "<length>+")
            guard case let .success(syntax) = result else {
                Issue.record("Failed to parse with space multiplier")
                return
            }
            guard case let .components(components) = syntax else {
                Issue.record("Expected components, got \(syntax)")
                return
            }
            #expect(components.count == 1)
            #expect(components[0].kind == .length)
            #expect(components[0].multiplier == .space)
        }

        @Test("Parse with comma multiplier")
        func commaMultiplier() throws {
            let result = CSSSyntaxString.parse(string: "<color>#")
            guard case let .success(syntax) = result else {
                Issue.record("Failed to parse with comma multiplier")
                return
            }
            guard case let .components(components) = syntax else {
                Issue.record("Expected components, got \(syntax)")
                return
            }
            #expect(components.count == 1)
            #expect(components[0].kind == .color)
            #expect(components[0].multiplier == .comma)
        }

        @Test("Parse alternatives")
        func alternatives() throws {
            let result = CSSSyntaxString.parse(string: "<length> | <percentage> | auto")
            guard case let .success(syntax) = result else {
                Issue.record("Failed to parse alternatives")
                return
            }
            guard case let .components(components) = syntax else {
                Issue.record("Expected components, got \(syntax)")
                return
            }
            #expect(components.count == 3)
            #expect(components[0].kind == .length)
            #expect(components[1].kind == .percentage)
            guard case let .literal(value) = components[2].kind else {
                Issue.record("Expected literal for third component")
                return
            }
            #expect(value == "auto")
        }

        @Test("Transform-list cannot have multiplier")
        func transformListNoMultiplier() throws {
            // <transform-list> is pre-multiplied, so we should still be able to parse it
            // But the multiplier should be .none
            let result = CSSSyntaxString.parse(string: "<transform-list>")
            guard case let .success(syntax) = result else {
                Issue.record("Failed to parse")
                return
            }
            guard case let .components(components) = syntax else {
                Issue.record("Expected components")
                return
            }
            #expect(components.count == 1)
            #expect(components[0].kind == .transformList)
            #expect(components[0].multiplier == .none)
        }

        @Test("Empty syntax string fails")
        func emptySyntaxFails() throws {
            let result = CSSSyntaxString.parse(string: "")
            guard case let .failure(error) = result else {
                Issue.record("Expected failure for empty syntax")
                return
            }
            #expect(error == .empty)
        }

        @Test("Invalid data type fails")
        func invalidDataTypeFails() throws {
            let result = CSSSyntaxString.parse(string: "<invalid-type>")
            guard case let .failure(error) = result else {
                Issue.record("Expected failure for invalid data type")
                return
            }
            #expect(error == .invalidDataType)
        }

        @Test("Missing closing bracket fails")
        func missingClosingBracketFails() throws {
            let result = CSSSyntaxString.parse(string: "<length")
            guard case let .failure(error) = result else {
                Issue.record("Expected failure for missing closing bracket")
                return
            }
            #expect(error == .missingClosingBracket)
        }
    }

    // MARK: - Value Parsing

    @Suite("Syntax Value Parsing")
    struct SyntaxValueTests {
        @Test("Parse length value")
        func parseLengthValue() throws {
            let syntax = CSSSyntaxString.components([
                CSSSyntaxComponent(kind: .length, multiplier: .none),
            ])
            let parser = Parser(css: "10px")
            let result = syntax.parseValue(parser)
            guard case let .success(value) = result else {
                Issue.record("Failed to parse length value")
                return
            }
            guard case let .length(length) = value else {
                Issue.record("Expected length, got \(value)")
                return
            }
            #expect(length.value == 10)
            #expect(length.unit == .px)
        }

        @Test("Parse color value")
        func parseColorValue() throws {
            let syntax = CSSSyntaxString.components([
                CSSSyntaxComponent(kind: .color, multiplier: .none),
            ])
            let parser = Parser(css: "red")
            let result = syntax.parseValue(parser)
            guard case let .success(value) = result else {
                Issue.record("Failed to parse color value")
                return
            }
            guard case .color = value else {
                Issue.record("Expected color, got \(value)")
                return
            }
        }

        @Test("Parse number value")
        func parseNumberValue() throws {
            let syntax = CSSSyntaxString.components([
                CSSSyntaxComponent(kind: .number, multiplier: .none),
            ])
            let parser = Parser(css: "42.5")
            let result = syntax.parseValue(parser)
            guard case let .success(value) = result else {
                Issue.record("Failed to parse number value")
                return
            }
            guard case let .number(num) = value else {
                Issue.record("Expected number, got \(value)")
                return
            }
            #expect(num == 42.5)
        }

        @Test("Parse integer value")
        func parseIntegerValue() throws {
            let syntax = CSSSyntaxString.components([
                CSSSyntaxComponent(kind: .integer, multiplier: .none),
            ])
            let parser = Parser(css: "42")
            let result = syntax.parseValue(parser)
            guard case let .success(value) = result else {
                Issue.record("Failed to parse integer value")
                return
            }
            guard case let .integer(num) = value else {
                Issue.record("Expected integer, got \(value)")
                return
            }
            #expect(num == 42)
        }

        @Test("Parse literal value")
        func parseLiteralValue() throws {
            let syntax = CSSSyntaxString.components([
                CSSSyntaxComponent(kind: .literal("auto"), multiplier: .none),
            ])
            let parser = Parser(css: "auto")
            let result = syntax.parseValue(parser)
            guard case let .success(value) = result else {
                Issue.record("Failed to parse literal value")
                return
            }
            guard case let .literal(lit) = value else {
                Issue.record("Expected literal, got \(value)")
                return
            }
            #expect(lit.lowercased() == "auto")
        }

        @Test("Parse first matching alternative")
        func parseFirstMatchingAlternative() throws {
            let syntax = CSSSyntaxString.components([
                CSSSyntaxComponent(kind: .length, multiplier: .none),
                CSSSyntaxComponent(kind: .percentage, multiplier: .none),
                CSSSyntaxComponent(kind: .literal("auto"), multiplier: .none),
            ])

            // Test length
            let parser1 = Parser(css: "10px")
            let result1 = syntax.parseValue(parser1)
            guard case let .success(value1) = result1 else {
                Issue.record("Failed to parse length")
                return
            }
            guard case .length = value1 else {
                Issue.record("Expected length, got \(value1)")
                return
            }

            // Test percentage
            let parser2 = Parser(css: "50%")
            let result2 = syntax.parseValue(parser2)
            guard case let .success(value2) = result2 else {
                Issue.record("Failed to parse percentage")
                return
            }
            guard case .percentage = value2 else {
                Issue.record("Expected percentage, got \(value2)")
                return
            }

            // Test literal
            let parser3 = Parser(css: "auto")
            let result3 = syntax.parseValue(parser3)
            guard case let .success(value3) = result3 else {
                Issue.record("Failed to parse auto")
                return
            }
            guard case .literal = value3 else {
                Issue.record("Expected literal, got \(value3)")
                return
            }
        }

        @Test("Parse comma-separated values")
        func parseCommaSeparatedValues() throws {
            let syntax = CSSSyntaxString.components([
                CSSSyntaxComponent(kind: .length, multiplier: .comma),
            ])
            let parser = Parser(css: "10px, 20px, 30px")
            let result = syntax.parseValue(parser)
            guard case let .success(value) = result else {
                Issue.record("Failed to parse comma-separated values")
                return
            }
            guard case let .repeated(values, multiplier) = value else {
                Issue.record("Expected repeated, got \(value)")
                return
            }
            #expect(values.count == 3)
            #expect(multiplier == .comma)
        }

        @Test("Parse space-separated values")
        func parseSpaceSeparatedValues() throws {
            let syntax = CSSSyntaxString.components([
                CSSSyntaxComponent(kind: .length, multiplier: .space),
            ])
            let parser = Parser(css: "10px 20px 30px")
            let result = syntax.parseValue(parser)
            guard case let .success(value) = result else {
                Issue.record("Failed to parse space-separated values")
                return
            }
            guard case let .repeated(values, multiplier) = value else {
                Issue.record("Expected repeated, got \(value)")
                return
            }
            #expect(values.count == 3)
            #expect(multiplier == .space)
        }

        @Test("Parse universal syntax")
        func parseUniversalSyntax() throws {
            let syntax = CSSSyntaxString.universal
            let parser = Parser(css: "anything goes here 123 #abc")
            let result = syntax.parseValue(parser)
            guard case let .success(value) = result else {
                Issue.record("Failed to parse universal syntax")
                return
            }
            guard case let .tokenList(tokens) = value else {
                Issue.record("Expected tokenList, got \(value)")
                return
            }
            #expect(tokens.contains("anything"))
        }
    }

    // MARK: - Serialization

    @Suite("Syntax Serialization")
    struct SyntaxSerializationTests {
        @Test("Serialize universal syntax")
        func serializeUniversal() throws {
            let syntax = CSSSyntaxString.universal
            let serialized = syntax.string()
            #expect(serialized == "\"*\"")
        }

        @Test("Serialize single component")
        func serializeSingleComponent() throws {
            let syntax = CSSSyntaxString.components([
                CSSSyntaxComponent(kind: .length, multiplier: .none),
            ])
            let serialized = syntax.string()
            #expect(serialized == "\"<length>\"")
        }

        @Test("Serialize with multiplier")
        func serializeWithMultiplier() throws {
            let syntaxSpace = CSSSyntaxString.components([
                CSSSyntaxComponent(kind: .length, multiplier: .space),
            ])
            #expect(syntaxSpace.string() == "\"<length>+\"")

            let syntaxComma = CSSSyntaxString.components([
                CSSSyntaxComponent(kind: .color, multiplier: .comma),
            ])
            #expect(syntaxComma.string() == "\"<color>#\"")
        }

        @Test("Serialize alternatives")
        func serializeAlternatives() throws {
            let syntax = CSSSyntaxString.components([
                CSSSyntaxComponent(kind: .length, multiplier: .none),
                CSSSyntaxComponent(kind: .percentage, multiplier: .none),
                CSSSyntaxComponent(kind: .literal("auto"), multiplier: .none),
            ])
            let serialized = syntax.string()
            #expect(serialized == "\"<length> | <percentage> | auto\"")
        }

        @Test("Serialize parsed component")
        func serializeParsedComponent() throws {
            let length = CSSParsedComponent.length(CSSLength(10, .px))
            #expect(length.string() == "10px")

            let number = CSSParsedComponent.number(42.5)
            #expect(number.string() == "42.5")

            let integer = CSSParsedComponent.integer(42)
            #expect(integer.string() == "42")

            let literal = CSSParsedComponent.literal("auto")
            #expect(literal.string() == "auto")
        }

        @Test("Serialize repeated component")
        func serializeRepeatedComponent() throws {
            let repeated = CSSParsedComponent.repeated([
                .length(CSSLength(10, .px)),
                .length(CSSLength(20, .px)),
                .length(CSSLength(30, .px)),
            ], .comma)
            let serialized = repeated.string()
            #expect(serialized == "10px, 20px, 30px")
        }
    }
}
