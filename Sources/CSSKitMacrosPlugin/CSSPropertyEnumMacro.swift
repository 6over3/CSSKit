// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Generates CSSProperty enum with parsing and serialization from property definitions.
public struct CSSPropertyEnumMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Parse the property definitions from the macro arguments
        guard let closure = node.trailingClosure else {
            throw MacroError.missingClosure
        }

        let properties = try parsePropertyDefinitions(from: closure)

        // Generate the enum
        let enumDecl = generateEnum(properties: properties)

        // Generate the parsing function
        let parseFunc = generateParseFunction(properties: properties)

        // Generate the property name dictionary
        let nameDict = generateNameDictionary(properties: properties)

        return [
            DeclSyntax(enumDecl),
            DeclSyntax(parseFunc),
            DeclSyntax(nameDict),
        ]
    }

    // MARK: - Property Definition Parsing

    struct PropertyDefinition {
        let cssName: String // e.g., "background-color"
        let swiftName: String // e.g., "backgroundColor"
        let enumCase: String // e.g., "backgroundColor"
        let valueType: String // e.g., "Color"
        let isShorthand: Bool
        let inherits: Bool
        let vendorPrefixes: VendorPrefixSet
        let logicalGroup: String?
    }

    struct VendorPrefixSet: OptionSet {
        let rawValue: Int

        static let webkit = Self(rawValue: 1 << 0)
        static let moz = Self(rawValue: 1 << 1)
        static let ms = Self(rawValue: 1 << 2)
        static let o = Self(rawValue: 1 << 3)

        var isEmpty: Bool { rawValue == 0 }
    }

    static func parsePropertyDefinitions(from closure: ClosureExprSyntax) throws -> [PropertyDefinition] {
        var properties: [PropertyDefinition] = []

        for statement in closure.statements {
            // Try direct tuple:
            if let tuple = statement.item.as(TupleExprSyntax.self) {
                if let prop = try parsePropertyTuple(tuple) {
                    properties.append(prop)
                }
                continue
            }

            // Try infix operator expression: _ =
            if let infixExpr = statement.item.as(InfixOperatorExprSyntax.self) {
                if let tuple = infixExpr.rightOperand.as(TupleExprSyntax.self) {
                    if let prop = try parsePropertyTuple(tuple) {
                        properties.append(prop)
                    }
                }
                continue
            }

            // Try sequence expression with discarding pattern: _ =
            if let seqExpr = statement.item.as(SequenceExprSyntax.self) {
                for element in seqExpr.elements {
                    if let tuple = element.as(TupleExprSyntax.self) {
                        if let prop = try parsePropertyTuple(tuple) {
                            properties.append(prop)
                        }
                    }
                }
                continue
            }

            // Try function call syntax: property("name", Type.self)
            if let funcCall = statement.item.as(FunctionCallExprSyntax.self) {
                if let prop = try parsePropertyFunctionCall(funcCall) {
                    properties.append(prop)
                }
            }
        }

        return properties
    }

    static func parsePropertyFunctionCall(_ call: FunctionCallExprSyntax) throws -> PropertyDefinition? {
        // Handle: property("name", Type.self, .shorthand)
        var cssName: String?
        var valueType: String?
        var isShorthand = false
        var inherits = false
        var vendorPrefixes: VendorPrefixSet = []

        for (index, arg) in call.arguments.enumerated() {
            if index == 0 {
                // CSS property name
                if let stringLiteral = arg.expression.as(StringLiteralExprSyntax.self),
                   let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self)
                {
                    cssName = segment.content.text
                }
            } else if index == 1 {
                // Type
                if let memberAccess = arg.expression.as(MemberAccessExprSyntax.self),
                   let base = memberAccess.base
                {
                    valueType = base.description.trimmingCharacters(in: .whitespaces)
                } else {
                    valueType = arg.expression.description.trimmingCharacters(in: .whitespaces)
                        .replacingOccurrences(of: ".self", with: "")
                }
            } else {
                // Flags
                let text = arg.expression.description.lowercased()
                if text.contains("shorthand") {
                    isShorthand = true
                }
                if text.contains("inherits") {
                    inherits = true
                }
                if text.contains("webkit") {
                    vendorPrefixes.insert(.webkit)
                }
                if text.contains("moz") {
                    vendorPrefixes.insert(.moz)
                }
                if text.contains("ms") && !text.contains("transform") {
                    vendorPrefixes.insert(.ms)
                }
                if text.contains(".o") || text.contains("| .o") || text.hasSuffix("o]") {
                    vendorPrefixes.insert(.o)
                }
                if text.contains("allprefixes") || text.contains("transformprefixes") {
                    vendorPrefixes = [.webkit, .moz, .ms, .o]
                }
            }
        }

        guard let name = cssName, let type = valueType else {
            return nil
        }

        let swiftName = cssNameToSwiftName(name)
        return PropertyDefinition(
            cssName: name,
            swiftName: swiftName,
            enumCase: swiftName,
            valueType: type,
            isShorthand: isShorthand,
            inherits: inherits,
            vendorPrefixes: vendorPrefixes,
            logicalGroup: nil
        )
    }

    static func parsePropertyTuple(_ tuple: TupleExprSyntax) throws -> PropertyDefinition? {
        var cssName: String?
        var valueType: String?
        var isShorthand = false
        var inherits = false
        var vendorPrefixes: VendorPrefixSet = []

        for (index, element) in tuple.elements.enumerated() {
            if index == 0 {
                // CSS property name
                if let stringLiteral = element.expression.as(StringLiteralExprSyntax.self),
                   let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self)
                {
                    cssName = segment.content.text
                }
            } else if index == 1 {
                // Type
                if let memberAccess = element.expression.as(MemberAccessExprSyntax.self),
                   let base = memberAccess.base
                {
                    valueType = base.description.trimmingCharacters(in: .whitespaces)
                } else {
                    valueType = element.expression.description.trimmingCharacters(in: .whitespaces)
                        .replacingOccurrences(of: ".self", with: "")
                }
            } else {
                // Flags
                let text = element.expression.description.lowercased()
                if text.contains("shorthand") {
                    isShorthand = true
                }
                if text.contains("inherits") {
                    inherits = true
                }
                if text.contains("webkit") {
                    vendorPrefixes.insert(.webkit)
                }
                if text.contains("moz") {
                    vendorPrefixes.insert(.moz)
                }
                if text.contains("ms") && !text.contains("transform") {
                    vendorPrefixes.insert(.ms)
                }
                if text.contains(".o") || text.contains("| .o") || text.hasSuffix("o]") {
                    vendorPrefixes.insert(.o)
                }
                if text.contains("allprefixes") || text.contains("transformprefixes") {
                    vendorPrefixes = [.webkit, .moz, .ms, .o]
                }
            }
        }

        guard let name = cssName, let type = valueType else {
            return nil
        }

        let swiftName = cssNameToSwiftName(name)
        return PropertyDefinition(
            cssName: name,
            swiftName: swiftName,
            enumCase: swiftName,
            valueType: type,
            isShorthand: isShorthand,
            inherits: inherits,
            vendorPrefixes: vendorPrefixes,
            logicalGroup: nil
        )
    }

    static func cssNameToSwiftName(_ cssName: String) -> String {
        // Convert "background-color" to "backgroundColor"
        let parts = cssName.split(separator: "-")
        var result = String(parts[0])
        for part in parts.dropFirst() {
            result += part.capitalized
        }
        return result
    }

    // MARK: - Code Generation

    static func generateEnum(properties: [PropertyDefinition]) -> EnumDeclSyntax {
        let cases = properties.map { prop -> String in
            if !prop.vendorPrefixes.isEmpty {
                return "    case \(prop.enumCase)(\(prop.valueType), CSSVendorPrefix)"
            } else {
                return "    case \(prop.enumCase)(\(prop.valueType))"
            }
        }.joined(separator: "\n")

        let serializeCases = properties.map { prop -> String in
            if !prop.vendorPrefixes.isEmpty {
                return """
                        case .\(prop.enumCase)(let value, _):
                            value.serialize(dest: &dest)
                """
            } else {
                return """
                        case .\(prop.enumCase)(let value):
                            value.serialize(dest: &dest)
                """
            }
        }.joined(separator: "\n")

        let nameCases = properties.map { prop -> String in
            if !prop.vendorPrefixes.isEmpty {
                return """
                        case .\(prop.enumCase)(_, let prefix):
                            var name = "\(prop.cssName)"
                            if prefix != .none {
                                name = prefix.cssPrefix + name
                            }
                            return name
                """
            } else {
                return """
                        case .\(prop.enumCase):
                            return "\(prop.cssName)"
                """
            }
        }.joined(separator: "\n")

        let isShorthandCases = properties.filter(\.isShorthand).map { prop -> String in
            "        case .\(prop.enumCase): return true"
        }.joined(separator: "\n")

        let inheritsCases = properties.filter(\.inherits).map { prop -> String in
            "        case .\(prop.enumCase): return true"
        }.joined(separator: "\n")

        let source = """
        /// A fully-typed CSS property with its parsed value.
        public enum CSSProperty: Equatable, Sendable {
        \(cases)
            /// A CSS-wide keyword (inherit, initial, unset, revert, revert-layer).
            case wideKeyword(CSSWideKeyword, CSSPropertyId)
            /// An unparsed property (fallback for complex values or var() references).
            case unparsed(CSSUnparsedProperty)
            /// A custom property (CSS variable).
            case custom(CSSCustomProperty)

            /// The CSS property name.
            public var name: String {
                switch self {
        \(nameCases)
                case .wideKeyword(_, let propertyId):
                    return propertyId.name
                case .unparsed(let prop):
                    return prop.propertyId.name
                case .custom(let prop):
                    return prop.name.name
                }
            }

            /// Whether this property is a shorthand property.
            public var isShorthand: Bool {
                switch self {
        \(isShorthandCases.isEmpty ? "        default: return false" : isShorthandCases + "\n        default: return false")
                }
            }

            /// Whether this property inherits by default.
            public var inherits: Bool {
                switch self {
        \(inheritsCases.isEmpty ? "" : inheritsCases + "\n")        case .wideKeyword(_, let propertyId):
                    return propertyId.inherits
                case .unparsed(let prop):
                    return prop.propertyId.inherits
                case .custom:
                    return true
                default:
                    return false
                }
            }

            /// Serializes the property value to CSS.
            public func serialize<W: CSSWriter>(dest: inout W) {
                switch self {
        \(serializeCases)
                case .wideKeyword(let keyword, _):
                    keyword.serialize(dest: &dest)
                case .unparsed(let prop):
                    prop.serialize(dest: &dest)
                case .custom(let prop):
                    prop.serialize(dest: &dest)
                }
            }
        }
        """

        return try! EnumDeclSyntax(SyntaxNodeString(stringLiteral: source))
    }

    static func generateParseFunction(properties: [PropertyDefinition]) -> FunctionDeclSyntax {
        let parseCases = properties.map { prop -> String in
            if !prop.vendorPrefixes.isEmpty {
                // Generate allowed prefix set for properties that support vendor prefixes
                var allowedPrefixes = [".none"]
                if prop.vendorPrefixes.contains(.webkit) { allowedPrefixes.append(".webkit") }
                if prop.vendorPrefixes.contains(.moz) { allowedPrefixes.append(".moz") }
                if prop.vendorPrefixes.contains(.ms) { allowedPrefixes.append(".ms") }
                if prop.vendorPrefixes.contains(.o) { allowedPrefixes.append(".o") }
                let prefixSet = allowedPrefixes.joined(separator: ", ")

                return """
                    case "\(prop.cssName)":
                        // Allowed prefixes: \(prefixSet)
                        let allowedPrefixes: Set<CSSVendorPrefix> = [\(prefixSet)]
                        guard allowedPrefixes.contains(vendorPrefix) else { break }
                        if case .success(let value) = \(prop.valueType).parse(input), input.isExhausted {
                            return .success(.\(prop.enumCase)(value, vendorPrefix))
                        }
                """
            } else {
                return """
                    case "\(prop.cssName)":
                        // No vendor prefix allowed
                        guard vendorPrefix == .none else { break }
                        if case .success(let value) = \(prop.valueType).parse(input), input.isExhausted {
                            return .success(.\(prop.enumCase)(value))
                        }
                """
            }
        }.joined(separator: "\n")

        let source = """
        /// Parses a CSS property by name into a typed CSSProperty value.
        func parseCSSProperty(
            name: String,
            input: Parser,
            vendorPrefix: CSSVendorPrefix = .none
        ) -> Result<CSSProperty, BasicParseError> {
            let propertyName = name.lowercased()
            let startState = input.state()

            switch propertyName {
        \(parseCases)
            default:
                break
            }

            // Try CSS-wide keywords
            input.reset(startState)
            let propertyId = CSSPropertyId(propertyName)
            if case .success(let keyword) = CSSWideKeyword.parse(input), input.isExhausted {
                return .success(.wideKeyword(keyword, propertyId))
            }

            // Fallback to unparsed - preserves token structure including var() references
            input.reset(startState)
            switch CSSUnparsedProperty.parse(propertyId: propertyId, input: input) {
            case .success(let unparsed):
                return .success(.unparsed(unparsed))
            case .failure(let error):
                return .failure(error)
            }
        }
        """

        return try! FunctionDeclSyntax(SyntaxNodeString(stringLiteral: source))
    }

    static func generateNameDictionary(properties: [PropertyDefinition]) -> VariableDeclSyntax {
        let entries = properties.map { prop -> String in
            "    \"\(prop.cssName)\": \"\(prop.enumCase)\""
        }.joined(separator: ",\n")

        let source = """
        /// Maps CSS property names to their Swift enum case names.
        let cssPropertyNameToCase: [String: String] = [
        \(entries)
        ]
        """

        return try! VariableDeclSyntax(SyntaxNodeString(stringLiteral: source.replacingOccurrences(of: "let cssPropertyNameToCase", with: "private let cssPropertyNameToCase")))
    }
}

// MARK: - Errors

enum MacroError: Error, CustomStringConvertible {
    case missingClosure
    case invalidPropertyDefinition(String)

    var description: String {
        switch self {
        case .missingClosure:
            "#CSSPropertyEnum requires a trailing closure with property definitions"
        case let .invalidPropertyDefinition(detail):
            "Invalid property definition: \(detail)"
        }
    }
}
