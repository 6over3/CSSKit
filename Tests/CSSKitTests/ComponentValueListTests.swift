// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("Component Value List Tests")
struct ComponentValueListTests {
    @Test("component_value_list.json")
    func componentValueList() throws {
        let testData = try loadTestData("component_value_list")
        runJsonTests(testData) { input in
            .array(componentValuesToJson(input))
        }
    }
}
