// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct CSSValueEnumMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let closure = node.trailingClosure else {
            throw CSSValueMacroError.missingClosure
        }

        let definitions = try parseValueDefinitions(from: closure)

        let enumDecl = generateEnum(definitions: definitions)
        let parseFunc = generateParseFunction(definitions: definitions)

        return [
            DeclSyntax(enumDecl),
            DeclSyntax(parseFunc),
        ]
    }

    struct ValueDefinition {
        let caseName: String
        let valueType: String
    }

    static func parseValueDefinitions(from closure: ClosureExprSyntax) throws -> [ValueDefinition] {
        var definitions: [ValueDefinition] = []

        for statement in closure.statements {
            if let tuple = statement.item.as(TupleExprSyntax.self) {
                if let def = try parseValueTuple(tuple) {
                    definitions.append(def)
                }
                continue
            }

            if let infixExpr = statement.item.as(InfixOperatorExprSyntax.self) {
                if let tuple = infixExpr.rightOperand.as(TupleExprSyntax.self) {
                    if let def = try parseValueTuple(tuple) {
                        definitions.append(def)
                    }
                }
                continue
            }

            if let seqExpr = statement.item.as(SequenceExprSyntax.self) {
                for element in seqExpr.elements {
                    if let tuple = element.as(TupleExprSyntax.self) {
                        if let def = try parseValueTuple(tuple) {
                            definitions.append(def)
                        }
                    }
                }
            }
        }

        return definitions
    }

    static func parseValueTuple(_ tuple: TupleExprSyntax) throws -> ValueDefinition? {
        var caseName: String?
        var valueType: String?

        for (index, element) in tuple.elements.enumerated() {
            if index == 0 {
                if let ident = element.expression.as(DeclReferenceExprSyntax.self) {
                    caseName = ident.baseName.text
                } else if let stringLiteral = element.expression.as(StringLiteralExprSyntax.self),
                          let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self)
                {
                    caseName = segment.content.text
                }
            } else if index == 1 {
                if let memberAccess = element.expression.as(MemberAccessExprSyntax.self),
                   let base = memberAccess.base
                {
                    valueType = base.description.trimmingCharacters(in: .whitespaces)
                } else {
                    valueType = element.expression.description.trimmingCharacters(in: .whitespaces)
                        .replacingOccurrences(of: ".self", with: "")
                }
            }
        }

        guard let name = caseName, let type = valueType else {
            return nil
        }

        return ValueDefinition(caseName: name, valueType: type)
    }

    static func generateEnum(definitions: [ValueDefinition]) -> EnumDeclSyntax {
        let cases = definitions.map { def in
            "    case \(def.caseName)(\(def.valueType))"
        }.joined(separator: "\n")

        let serializeCases = definitions.map { def in
            """
                    case .\(def.caseName)(let v):
                        v.serialize(dest: &dest)
            """
        }.joined(separator: "\n")

        let source = """
        public enum CSSValue: Equatable, Sendable, CSSSerializable {
        \(cases)

            public func serialize<W: CSSWriter>(dest: inout W) {
                switch self {
        \(serializeCases)
                }
            }
        }
        """

        return try! EnumDeclSyntax(SyntaxNodeString(stringLiteral: source))
    }

    static func generateParseFunction(definitions: [ValueDefinition]) -> FunctionDeclSyntax {
        var parseAttempts: [String] = []
        for def in definitions {
            parseAttempts.append("""
                    if case .success(let v) = input.tryParse({ \(def.valueType).parse($0) }) {
                        return .success(.\(def.caseName)(v))
                    }
            """)
        }
        let parseCalls = parseAttempts.joined(separator: "\n")

        let source = """
        func parseCSSValue(input: Parser) -> Result<CSSValue, BasicParseError> {
        \(parseCalls)

            return .failure(input.newBasicError(.endOfInput))
        }
        """

        return try! FunctionDeclSyntax(SyntaxNodeString(stringLiteral: source))
    }
}

enum CSSValueMacroError: Error, CustomStringConvertible {
    case missingClosure
    case invalidDefinition(String)

    var description: String {
        switch self {
        case .missingClosure:
            "#CSSValueEnum requires a trailing closure with value definitions"
        case let .invalidDefinition(detail):
            "Invalid value definition: \(detail)"
        }
    }
}
