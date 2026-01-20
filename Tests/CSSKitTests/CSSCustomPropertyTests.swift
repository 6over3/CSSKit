// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("CSS Custom Property Tests")
struct CSSCustomPropertyTests {
    // MARK: - CSSCustomPropertyName

    @Suite("CSSCustomPropertyName Tests")
    struct CustomPropertyNameTests {
        @Test("Create custom property name from dashed ident")
        func dashedIdent() throws {
            let name = CSSCustomPropertyName("--my-color")
            guard case let .custom(ident) = name else {
                Issue.record("Expected custom, got \(name)")
                return
            }
            #expect(ident.value == "--my-color")
            #expect(name.name == "--my-color")
        }

        @Test("Create unknown property name")
        func unknownProperty() throws {
            let name = CSSCustomPropertyName("unknown-property")
            guard case let .unknown(propName) = name else {
                Issue.record("Expected unknown, got \(name)")
                return
            }
            #expect(propName == "unknown-property")
            #expect(name.name == "unknown-property")
        }
    }

    // MARK: - CSSVariable

    @Suite("CSSVariable Tests")
    struct VariableTests {
        @Test("Parse variable name and fallback")
        func parseVariableContent() throws {
            let parser = Parser(css: "--my-color")
            let result = CSSVariable.parse(parser)
            guard case let .success(variable) = result else {
                Issue.record("Failed to parse variable content")
                return
            }
            #expect(variable.name.value == "--my-color")
            #expect(variable.fallback == nil)
        }

        @Test("Parse variable with fallback")
        func parseWithFallback() throws {
            let parser = Parser(css: "--my-color, red")
            let result = CSSVariable.parse(parser)
            guard case let .success(variable) = result else {
                Issue.record("Failed to parse variable with fallback")
                return
            }
            #expect(variable.name.value == "--my-color")
            #expect(variable.fallback != nil)
            #expect(!variable.fallback!.isEmpty)
        }

        @Test("Parse variable in token list")
        func parseVarInTokenList() throws {
            let parser = Parser(css: "var(--my-color)")
            let result = CSSTokenList.parse(parser)
            guard case let .success(list) = result else {
                Issue.record("Failed to parse var() in token list")
                return
            }
            let hasVariable = list.tokens.contains { token in
                if case .variable = token { return true }
                return false
            }
            #expect(hasVariable)
        }

        @Test("Serialize var() without fallback")
        func serializeWithoutFallback() throws {
            let variable = CSSVariable(name: CSSDashedIdent("--my-color"), fallback: nil)
            let serialized = variable.string()
            #expect(serialized == "var(--my-color)")
        }

        @Test("Serialize var() with fallback")
        func serializeWithFallback() throws {
            let fallback = CSSTokenList(tokens: [
                .token(.ident(Lexeme("red"))),
            ])
            let variable = CSSVariable(name: CSSDashedIdent("--my-color"), fallback: fallback)
            let serialized = variable.string()
            #expect(serialized.contains("var(--my-color"))
            #expect(serialized.contains("red"))
        }
    }

    // MARK: - CSSEnvironmentVariable

    @Suite("CSSEnvironmentVariable Tests")
    struct EnvironmentVariableTests {
        @Test("Parse env content with known name")
        func knownEnv() throws {
            let parser = Parser(css: "safe-area-inset-top")
            let result = CSSEnvironmentVariable.parse(parser)
            guard case let .success(env) = result else {
                Issue.record("Failed to parse env content")
                return
            }
            guard case .safeAreaInsetTop = env.name else {
                Issue.record("Expected safeAreaInsetTop, got \(env.name)")
                return
            }
            #expect(env.fallback == nil)
        }

        @Test("Parse env content with fallback")
        func envWithFallback() throws {
            let parser = Parser(css: "safe-area-inset-top, 0px")
            let result = CSSEnvironmentVariable.parse(parser)
            guard case let .success(env) = result else {
                Issue.record("Failed to parse env content with fallback")
                return
            }
            guard case .safeAreaInsetTop = env.name else {
                Issue.record("Expected safeAreaInsetTop")
                return
            }
            #expect(env.fallback != nil)
        }

        @Test("Parse env content with custom name")
        func customEnv() throws {
            let parser = Parser(css: "custom-env-var")
            let result = CSSEnvironmentVariable.parse(parser)
            guard case let .success(env) = result else {
                Issue.record("Failed to parse env content with custom name")
                return
            }
            guard case let .custom(name) = env.name else {
                Issue.record("Expected custom, got \(env.name)")
                return
            }
            #expect(name == "custom-env-var")
        }

        @Test("Serialize env() without fallback")
        func serializeWithoutFallback() throws {
            let env = CSSEnvironmentVariable(
                name: .safeAreaInsetTop,
                indices: [],
                fallback: nil
            )
            let serialized = env.string()
            #expect(serialized == "env(safe-area-inset-top)")
        }

        @Test("Serialize env() with fallback")
        func serializeWithFallback() throws {
            let fallback = CSSTokenList(tokens: [
                .length(CSSLength(0, .px)),
            ])
            let env = CSSEnvironmentVariable(
                name: .safeAreaInsetTop,
                indices: [],
                fallback: fallback
            )
            let serialized = env.string()
            #expect(serialized.contains("env(safe-area-inset-top"))
        }
    }

    // MARK: - CSSTokenList

    @Suite("CSSTokenList Tests")
    struct TokenListTests {
        @Test("Empty token list")
        func emptyList() throws {
            let list = CSSTokenList.empty
            #expect(list.isEmpty)
            #expect(list.tokens.isEmpty)
        }

        @Test("Token list with tokens")
        func withTokens() throws {
            let list = CSSTokenList(tokens: [
                .token(.ident(Lexeme("red"))),
                .token(.whiteSpace(" ")),
                .length(CSSLength(10, .px)),
            ])
            #expect(!list.isEmpty)
            #expect(list.tokens.count == 3)
        }

        @Test("Starts with whitespace")
        func startsWithWhitespace() throws {
            let listWithWhitespace = CSSTokenList(tokens: [
                .token(.whiteSpace(" ")),
                .token(.ident(Lexeme("red"))),
            ])
            #expect(listWithWhitespace.startsWithWhitespace)

            let listWithoutWhitespace = CSSTokenList(tokens: [
                .token(.ident(Lexeme("red"))),
            ])
            #expect(!listWithoutWhitespace.startsWithWhitespace)
        }

        @Test("Parse simple token list")
        func parseSimpleTokenList() throws {
            let parser = Parser(css: "10px 20px 30px")
            let result = CSSTokenList.parse(parser)
            guard case let .success(list) = result else {
                Issue.record("Failed to parse token list")
                return
            }
            #expect(!list.isEmpty)
        }

        @Test("Parse token list with var()")
        func parseWithVar() throws {
            let parser = Parser(css: "var(--spacing) 10px")
            let result = CSSTokenList.parse(parser)
            guard case let .success(list) = result else {
                Issue.record("Failed to parse token list with var()")
                return
            }
            #expect(!list.isEmpty)
            let hasVariable = list.tokens.contains { token in
                if case .variable = token { return true }
                return false
            }
            #expect(hasVariable)
        }

        @Test("Parse token list with colors")
        func parseWithColors() throws {
            let parser = Parser(css: "red blue green")
            let result = CSSTokenList.parse(parser)
            guard case let .success(list) = result else {
                Issue.record("Failed to parse token list with colors")
                return
            }
            #expect(!list.isEmpty)
        }
    }

    // MARK: - CSSTokenOrValue

    @Suite("CSSTokenOrValue Tests")
    struct TokenOrValueTests {
        @Test("Whitespace detection")
        func whitespaceDetection() throws {
            let whitespace = CSSTokenOrValue.token(.whiteSpace(" "))
            #expect(whitespace.isWhitespace)

            let notWhitespace = CSSTokenOrValue.token(.ident(Lexeme("test")))
            #expect(!notWhitespace.isWhitespace)

            let color = CSSTokenOrValue.color(.rgba(RgbaLegacy(red: 255.0, green: 0.0, blue: 0.0, alpha: 1.0)))
            #expect(!color.isWhitespace)
        }
    }

    // MARK: - CSSFunction

    @Suite("CSSFunction Tests")
    struct FunctionTests {
        @Test("Create function")
        func createFunction() throws {
            let func_ = CSSFunction(
                name: "custom-func",
                arguments: CSSTokenList(tokens: [
                    .length(CSSLength(10, .px)),
                    .token(.comma),
                    .length(CSSLength(20, .px)),
                ])
            )
            #expect(func_.name == "custom-func")
            #expect(!func_.arguments.isEmpty)
        }

        @Test("Serialize function")
        func serializeFunction() throws {
            let func_ = CSSFunction(
                name: "my-function",
                arguments: CSSTokenList(tokens: [
                    .length(CSSLength(10, .px)),
                ])
            )
            let serialized = func_.string()
            #expect(serialized.hasPrefix("my-function("))
            #expect(serialized.hasSuffix(")"))
        }
    }

    // MARK: - CSSCustomProperty

    @Suite("CSSCustomProperty Tests")
    struct CustomPropertyTests {
        @Test("Create custom property")
        func createCustomProperty() throws {
            let property = CSSCustomProperty(
                name: CSSCustomPropertyName("--my-spacing"),
                value: CSSTokenList(tokens: [
                    .length(CSSLength(10, .px)),
                ])
            )
            guard case .custom = property.name else {
                Issue.record("Expected custom name")
                return
            }
            #expect(property.name.name == "--my-spacing")
            #expect(!property.value.isEmpty)
        }

        @Test("Serialize custom property")
        func serializeCustomProperty() throws {
            let property = CSSCustomProperty(
                name: CSSCustomPropertyName("--my-color"),
                value: CSSTokenList(tokens: [
                    .token(.ident(Lexeme("red"))),
                ])
            )
            let serialized = property.string()
            #expect(serialized.contains("red"))
        }
    }

    // MARK: - CSSUnparsedProperty

    @Suite("CSSUnparsedProperty Tests")
    struct UnparsedPropertyTests {
        @Test("Create unparsed property")
        func createUnparsedProperty() throws {
            let property = CSSUnparsedProperty(
                propertyId: CSSPropertyId("color"),
                value: CSSTokenList(tokens: [
                    .variable(CSSVariable(name: CSSDashedIdent("--my-color"), fallback: nil)),
                ])
            )
            #expect(property.propertyId.name == "color")
            #expect(!property.value.isEmpty)
        }

        @Test("Serialize unparsed property")
        func serializeUnparsedProperty() throws {
            let property = CSSUnparsedProperty(
                propertyId: CSSPropertyId("width"),
                value: CSSTokenList(tokens: [
                    .variable(CSSVariable(name: CSSDashedIdent("--my-width"), fallback: nil)),
                ])
            )
            let serialized = property.string()
            #expect(serialized.contains("var(--my-width)"))
        }
    }

    // MARK: - Integration Tests

    @Suite("Integration Tests")
    struct IntegrationTests {
        @Test("Var in color property falls back to unparsed")
        func varInColorProperty() throws {
            let parser = Parser(css: "var(--theme-color)")
            let result = parseCSSProperty(name: "color", input: parser)
            guard case let .success(prop) = result else {
                Issue.record("Failed to parse color with var()")
                return
            }
            guard case .unparsed = prop else {
                Issue.record("Expected unparsed, got \(prop)")
                return
            }
        }

        @Test("Var in width property falls back to unparsed")
        func varInWidthProperty() throws {
            let parser = Parser(css: "var(--dynamic-width, 100px)")
            let result = parseCSSProperty(name: "width", input: parser)
            guard case let .success(prop) = result else {
                Issue.record("Failed to parse width with var()")
                return
            }
            guard case .unparsed = prop else {
                Issue.record("Expected unparsed, got \(prop)")
                return
            }
        }
    }
}
