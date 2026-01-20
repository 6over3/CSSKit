// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("One Component Value Tests")
struct OneComponentValueTests {
    @Test("one_component_value.json")
    func oneComponentValue() throws {
        let testData = try loadTestData("one_component_value")
        runJsonTests(testData) { input in
            let result: Result<JSONValue, ParseError<Never>> = input.parseEntirely { parser in
                switch parser.next() {
                case let .success(token):
                    .success(oneComponentValueToJson(token, parser))
                case let .failure(error):
                    .failure(error.asParseError())
                }
            }
            return (try? result.get()) ?? .array([.string("error"), .string("invalid")])
        }
    }
}
