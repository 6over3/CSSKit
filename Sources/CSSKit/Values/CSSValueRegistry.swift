// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import CSSKitMacros

#CSSValueEnum {
    _ = ("color", Color.self)
    _ = ("gradient", CSSGradient.self)
    _ = ("basicShape", CSSBasicShape.self)
    _ = ("easing", CSSEasingFunction.self)
    _ = ("lengthPercentage", CSSLengthPercentage.self)
    _ = ("length", CSSLength.self)
    _ = ("percentage", CSSPercentage.self)
    _ = ("angle", CSSAngle.self)
    _ = ("time", CSSTime.self)
    _ = ("resolution", CSSResolution.self)
    _ = ("ratio", CSSRatio.self)
    _ = ("alpha", CSSAlphaValue.self)
    _ = ("number", CSSNumber.self)
    _ = ("string", CSSString.self)
    _ = ("url", CSSUrl.self)
    _ = ("image", CSSImage.self)
    _ = ("rect", CSSRect<CSSLengthPercentage>.self)
    _ = ("position", CSSPosition.self)
    _ = ("ident", CSSCustomIdent.self)
}
