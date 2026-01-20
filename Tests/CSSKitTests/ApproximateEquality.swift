// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

extension Numeric where Magnitude: FloatingPoint {
    @inlinable @inline(__always)
    func isApproximatelyEqual(
        to other: Self,
        relativeTolerance: Magnitude = Magnitude.ulpOfOne.squareRoot(),
        norm: (Self) -> Magnitude = \.magnitude
    ) -> Bool {
        isApproximatelyEqual(
            to: other,
            absoluteTolerance: relativeTolerance * Magnitude.leastNormalMagnitude,
            relativeTolerance: relativeTolerance,
            norm: norm
        )
    }

    @inlinable @inline(__always)
    func isApproximatelyEqual(
        to other: Self,
        absoluteTolerance: Magnitude,
        relativeTolerance: Magnitude = 0
    ) -> Bool {
        isApproximatelyEqual(
            to: other,
            absoluteTolerance: absoluteTolerance,
            relativeTolerance: relativeTolerance,
            norm: \.magnitude
        )
    }
}

extension AdditiveArithmetic {
    @inlinable
    func isApproximatelyEqual<Magnitude>(
        to other: Self,
        absoluteTolerance: Magnitude,
        relativeTolerance: Magnitude = 0,
        norm: (Self) -> Magnitude
    ) -> Bool
        where Magnitude: FloatingPoint
    {
        if self == other { return true }
        let delta = norm(self - other)
        let scale = max(norm(self), norm(other))
        let bound = max(absoluteTolerance, scale * relativeTolerance)
        return delta.isFinite && delta <= bound
    }
}
