// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A rule parsing error with the associated input slice.
struct RuleParseError<E: Equatable>: Error, Equatable, @unchecked Sendable {
    /// The underlying parse error.
    let error: ParseError<E>

    /// The slice of input where the error occurred.
    let slice: Substring
}
