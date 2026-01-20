// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("Stylesheet Tests")
struct StylesheetTests {
    @Test("stylesheet.json")
    func stylesheet() throws {
        let testData = try loadTestData("stylesheet")
        runJsonTests(testData) { input in
            let parser = JsonParser()
            var results: [JSONValue] = []
            let stylesheetParser = StyleSheetParser(input: input, parser: parser)
            for result in stylesheetParser {
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
