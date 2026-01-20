// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("CSS Modules Tests")
struct CSSModulesTests {
    // MARK: - CSSComposes Parsing

    @Suite("CSSComposes Parsing")
    struct ComposesParsingTests {
        @Test("Parse single class name")
        func singleClassName() throws {
            let parser = Parser(css: "otherClass")
            let result = CSSComposes.parse(parser)
            guard case let .success(composes) = result else {
                Issue.record("Failed to parse single class name")
                return
            }
            #expect(composes.names.count == 1)
            #expect(composes.names[0].value == "otherClass")
            #expect(composes.from == nil)
        }

        @Test("Parse multiple class names")
        func multipleClassNames() throws {
            let parser = Parser(css: "class1 class2 class3")
            let result = CSSComposes.parse(parser)
            guard case let .success(composes) = result else {
                Issue.record("Failed to parse multiple class names")
                return
            }
            #expect(composes.names.count == 3)
            #expect(composes.names[0].value == "class1")
            #expect(composes.names[1].value == "class2")
            #expect(composes.names[2].value == "class3")
            #expect(composes.from == nil)
        }

        @Test("Parse with from global")
        func fromGlobal() throws {
            let parser = Parser(css: "globalClass from global")
            let result = CSSComposes.parse(parser)
            guard case let .success(composes) = result else {
                Issue.record("Failed to parse from global")
                return
            }
            #expect(composes.names.count == 1)
            #expect(composes.names[0].value == "globalClass")
            guard case .global = composes.from else {
                Issue.record("Expected global specifier, got \(String(describing: composes.from))")
                return
            }
        }

        @Test("Parse with from file")
        func fromFile() throws {
            let parser = Parser(css: "otherClass from './other.css'")
            let result = CSSComposes.parse(parser)
            guard case let .success(composes) = result else {
                Issue.record("Failed to parse from file")
                return
            }
            #expect(composes.names.count == 1)
            #expect(composes.names[0].value == "otherClass")
            guard case let .file(path) = composes.from else {
                Issue.record("Expected file specifier, got \(String(describing: composes.from))")
                return
            }
            #expect(path == "./other.css")
        }

        @Test("Parse multiple classes from file")
        func multipleClassesFromFile() throws {
            let parser = Parser(css: "class1 class2 from './shared.css'")
            let result = CSSComposes.parse(parser)
            guard case let .success(composes) = result else {
                Issue.record("Failed to parse multiple classes from file")
                return
            }
            #expect(composes.names.count == 2)
            #expect(composes.names[0].value == "class1")
            #expect(composes.names[1].value == "class2")
            guard case let .file(path) = composes.from else {
                Issue.record("Expected file specifier")
                return
            }
            #expect(path == "./shared.css")
        }

        @Test("Parse with double quoted file path")
        func doubleQuotedFilePath() throws {
            let parser = Parser(css: "myClass from \"./path/to/file.css\"")
            let result = CSSComposes.parse(parser)
            guard case let .success(composes) = result else {
                Issue.record("Failed to parse double quoted path")
                return
            }
            guard case let .file(path) = composes.from else {
                Issue.record("Expected file specifier")
                return
            }
            #expect(path == "./path/to/file.css")
        }

        @Test("Empty input fails")
        func emptyInputFails() throws {
            let parser = Parser(css: "")
            let result = CSSComposes.parse(parser)
            guard case .failure = result else {
                Issue.record("Expected failure for empty input")
                return
            }
        }

        @Test("'from' alone fails")
        func fromAloneFails() throws {
            let parser = Parser(css: "from global")
            let result = CSSComposes.parse(parser)
            guard case .failure = result else {
                Issue.record("Expected failure when 'from' is first token")
                return
            }
        }
    }

    // MARK: - CSSComposesSpecifier Parsing

    @Suite("CSSComposesSpecifier Parsing")
    struct ComposesSpecifierParsingTests {
        @Test("Parse global specifier")
        func parseGlobal() throws {
            let parser = Parser(css: "global")
            let result = CSSComposesSpecifier.parse(parser)
            guard case let .success(specifier) = result else {
                Issue.record("Failed to parse global")
                return
            }
            guard case .global = specifier else {
                Issue.record("Expected global, got \(specifier)")
                return
            }
        }

        @Test("Parse file specifier with single quotes")
        func parseFileSingleQuotes() throws {
            let parser = Parser(css: "'./styles.css'")
            let result = CSSComposesSpecifier.parse(parser)
            guard case let .success(specifier) = result else {
                Issue.record("Failed to parse file with single quotes")
                return
            }
            guard case let .file(path) = specifier else {
                Issue.record("Expected file, got \(specifier)")
                return
            }
            #expect(path == "./styles.css")
        }

        @Test("Parse file specifier with double quotes")
        func parseFileDoubleQuotes() throws {
            let parser = Parser(css: "\"./styles.css\"")
            let result = CSSComposesSpecifier.parse(parser)
            guard case let .success(specifier) = result else {
                Issue.record("Failed to parse file with double quotes")
                return
            }
            guard case let .file(path) = specifier else {
                Issue.record("Expected file, got \(specifier)")
                return
            }
            #expect(path == "./styles.css")
        }

        @Test("Invalid specifier fails")
        func invalidSpecifierFails() throws {
            let parser = Parser(css: "invalid")
            let result = CSSComposesSpecifier.parse(parser)
            guard case .failure = result else {
                Issue.record("Expected failure for invalid specifier")
                return
            }
        }
    }

    // MARK: - Serialization

    @Suite("CSSComposes Serialization")
    struct ComposesSerializationTests {
        @Test("Serialize single class name")
        func serializeSingleClassName() throws {
            let composes = CSSComposes(
                names: [CSSCustomIdent("myClass")],
                from: nil,
                location: SourceLocation(line: 1, column: 1)
            )
            let serialized = composes.string()
            #expect(serialized == "myClass")
        }

        @Test("Serialize multiple class names")
        func serializeMultipleClassNames() throws {
            let composes = CSSComposes(
                names: [
                    CSSCustomIdent("class1"),
                    CSSCustomIdent("class2"),
                    CSSCustomIdent("class3"),
                ],
                from: nil,
                location: SourceLocation(line: 1, column: 1)
            )
            let serialized = composes.string()
            #expect(serialized == "class1 class2 class3")
        }

        @Test("Serialize with from global")
        func serializeFromGlobal() throws {
            let composes = CSSComposes(
                names: [CSSCustomIdent("globalClass")],
                from: .global,
                location: SourceLocation(line: 1, column: 1)
            )
            let serialized = composes.string()
            #expect(serialized == "globalClass from global")
        }

        @Test("Serialize with from file")
        func serializeFromFile() throws {
            let composes = CSSComposes(
                names: [CSSCustomIdent("otherClass")],
                from: .file("./other.css"),
                location: SourceLocation(line: 1, column: 1)
            )
            let serialized = composes.string()
            #expect(serialized == "otherClass from \"./other.css\"")
        }

        @Test("Source index is not serialized")
        func sourceIndexNotSerialized() throws {
            let specifier = CSSComposesSpecifier.sourceIndex(42)
            let serialized = specifier.string()
            #expect(serialized == "") // Source indices are internal only
        }
    }

    // MARK: - Property Integration

    @Suite("CSS Modules Property Integration")
    struct PropertyIntegrationTests {
        @Test("Parse composes property")
        func parseComposesProperty() throws {
            let parser = Parser(css: "button primary")
            let result = parseCSSProperty(name: "composes", input: parser)
            guard case let .success(prop) = result else {
                Issue.record("Failed to parse composes property")
                return
            }
            guard case let .composes(composes) = prop else {
                Issue.record("Expected composes property, got \(prop)")
                return
            }
            #expect(composes.names.count == 2)
            #expect(composes.names[0].value == "button")
            #expect(composes.names[1].value == "primary")
        }

        @Test("Parse composes property with from")
        func parseComposesPropertyWithFrom() throws {
            let parser = Parser(css: "sharedButton from './shared.css'")
            let result = parseCSSProperty(name: "composes", input: parser)
            guard case let .success(prop) = result else {
                Issue.record("Failed to parse composes property with from")
                return
            }
            guard case let .composes(composes) = prop else {
                Issue.record("Expected composes property, got \(prop)")
                return
            }
            #expect(composes.names.count == 1)
            guard case let .file(path) = composes.from else {
                Issue.record("Expected file specifier")
                return
            }
            #expect(path == "./shared.css")
        }
    }

    // MARK: - Roundtrip Tests

    @Suite("Roundtrip Tests")
    struct RoundtripTests {
        @Test("Parse and serialize roundtrip")
        func parseSerializeRoundtrip() throws {
            let inputs = [
                "myClass",
                "class1 class2",
                "globalClass from global",
                "importedClass from \"./external.css\"",
            ]

            for input in inputs {
                let parser = Parser(css: input)
                let result = CSSComposes.parse(parser)
                guard case let .success(composes) = result else {
                    Issue.record("Failed to parse '\(input)'")
                    continue
                }
                let serialized = composes.string()
                // Note: single quotes become double quotes, which is acceptable
                let normalizedInput = input.replacingOccurrences(of: "'", with: "\"")
                #expect(serialized == normalizedInput, "Roundtrip failed for '\(input)': got '\(serialized)'")
            }
        }
    }
}
