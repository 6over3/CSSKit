// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

// MARK: - Result Extensions

extension Result where Success == Void {
    /// Whether the result is success.
    var isOK: Bool {
        if case .success = self { return true }
        return false
    }
}

extension Result where Failure == BasicParseError {
    /// Map the error to a ParseError.
    func mapError<E: Equatable>(
        _ transform: (BasicParseError) -> ParseError<E>
    ) -> Result<Success, ParseError<E>> {
        switch self {
        case let .success(value):
            .success(value)
        case let .failure(error):
            .failure(transform(error))
        }
    }

    /// Converts the Result to use ParseError instead of BasicParseError.
    func asParseError<E: Equatable>() -> Result<Success, ParseError<E>> {
        mapError { ParseError($0) }
    }
}

extension Result {
    /// Whether the result is a success.
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    /// Returns the success value or nil.
    var value: Success? {
        if case let .success(v) = self { return v }
        return nil
    }

    /// Returns the success value or the provided default.
    func unwrapOr(_ defaultValue: @autoclosure () -> Success) -> Success {
        if case let .success(v) = self { return v }
        return defaultValue()
    }
}
