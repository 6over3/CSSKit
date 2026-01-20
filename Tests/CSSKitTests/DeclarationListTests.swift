// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("Declaration List Tests")
struct DeclarationListTests {
    @Test("declaration_list.json")
    func declarationList() throws {
        let testData = try loadTestData("declaration_list")
        runJsonTests(testData) { input in
            let parser = JsonParser()
            var results: [JSONValue] = []
            let ruleBodyParser = RuleBodyParser(input: input, parser: parser)
            for result in ruleBodyParser {
                switch result {
                case let .success(value):
                    results.append(value)
                case .failure:
                    results.append(.array([.string("error"), .string("invalid")]))
                }
            }
            return .array(results)
        }
    }
}
