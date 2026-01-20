// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// Combines declaration, at-rule, and qualified rule parsing with matching output types.
protocol RuleBodyItemParser: DeclarationParser, AtRuleParsingDelegate, QualifiedRuleParser
    where
    Declaration == AtRule,
    AtRule == QualifiedRule,
    DeclError == AtRuleError,
    AtRuleError == QRError
{
    /// Whether to attempt parsing declarations.
    var parseDeclarations: Bool { get }

    /// Whether to attempt parsing qualified rules.
    var parseQualified: Bool { get }
}
