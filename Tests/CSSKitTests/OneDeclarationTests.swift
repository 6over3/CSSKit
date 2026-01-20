// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("One Declaration Tests")
struct OneDeclarationTests {
    @Test("one_declaration.json")
    func oneDeclaration() throws {
        let testData = try loadTestData("one_declaration")
        runJsonTests(testData) { input in
            var parser = JsonParser()
            let result = parseOneDeclaration(input: input, parser: &parser)
            switch result {
            case let .success(value):
                return value
            case .failure:
                return .array([.string("error"), .string("invalid")])
            }
        }
    }
}
