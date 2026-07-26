// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A value for the `object-fit` property.
/// https://drafts.csswg.org/css-images-3/#the-object-fit
public enum CSSObjectFit: String, Equatable, Sendable, Hashable {
    /// Fill the content box, independently scaling both dimensions.
    case fill

    /// Preserve the natural ratio while fitting inside the content box.
    case contain

    /// Preserve the natural ratio while covering the content box.
    case cover

    /// Preserve the natural dimensions.
    case none

    /// Use the smaller concrete object size produced by `none` or `contain`.
    case scaleDown = "scale-down"
}

extension CSSObjectFit {
    static func parse(_ input: Parser) -> Result<CSSObjectFit, BasicParseError> {
        guard case let .success(identifier) = input.expectIdent(),
              let value = CSSObjectFit(
                  rawValue: identifier.value.lowercased()
              )
        else {
            return .failure(input.newBasicError(.endOfInput))
        }
        return .success(value)
    }
}

extension CSSObjectFit: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(rawValue)
    }
}
