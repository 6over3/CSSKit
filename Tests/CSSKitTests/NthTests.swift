// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("An+B Notation Tests")
struct NthTests {
    @Test("An+B.json")
    func nth() throws {
        let testData = try loadTestData("An+B")
        runJsonTests(testData) { input in
            let result: Result<(Int32, Int32), ParseError<Never>> = input.parseEntirely { parser in
                parseNth(parser).mapError { $0.asParseError() }
            }
            switch result {
            case .success(let (a, b)):
                return .array([.int(Int(a)), .int(Int(b))])
            case .failure:
                return .null
            }
        }
    }
}
