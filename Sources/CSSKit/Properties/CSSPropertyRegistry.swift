// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import CSSKitMacros

// MARK: - CSS Property Enum Generation

//
// This macro generates:
// - `enum CSSProperty` with a case for each property
// - `parseCSSProperty(name:input:vendorPrefix:)` function
// - Property name mappings
//
// Each entry is: _ =
// Flags: .shorthand, .inherits, .webkit, .moz, .ms, .o, .allPrefixes, .transformPrefixes

#CSSPropertyEnum {
    // MARK: - Color Properties

    _ = ("color", Color.self, CSSPropertyFlags.inherits)
    _ = ("background-color", Color.self)
    _ = ("border-color", Color.self)
    _ = ("border-top-color", Color.self)
    _ = ("border-right-color", Color.self)
    _ = ("border-bottom-color", Color.self)
    _ = ("border-left-color", Color.self)
    _ = ("border-block-start-color", Color.self)
    _ = ("border-block-end-color", Color.self)
    _ = ("border-inline-start-color", Color.self)
    _ = ("border-inline-end-color", Color.self)
    _ = ("outline-color", Color.self)
    _ = ("text-decoration-color", Color.self)
    _ = ("text-emphasis-color", Color.self)
    _ = ("caret-color", Color.self)
    _ = ("accent-color", Color.self)
    _ = ("flood-color", Color.self)
    _ = ("lighting-color", Color.self)
    _ = ("stop-color", Color.self)

    // MARK: - Sizing Properties

    _ = ("width", CSSSize.self)
    _ = ("height", CSSSize.self)
    _ = ("min-width", CSSSize.self)
    _ = ("min-height", CSSSize.self)
    _ = ("max-width", CSSMaxSize.self)
    _ = ("max-height", CSSMaxSize.self)
    _ = ("inline-size", CSSSize.self)
    _ = ("block-size", CSSSize.self)
    _ = ("min-inline-size", CSSSize.self)
    _ = ("min-block-size", CSSSize.self)
    _ = ("max-inline-size", CSSMaxSize.self)
    _ = ("max-block-size", CSSMaxSize.self)
    _ = ("aspect-ratio", CSSAspectRatio.self)

    // MARK: - Margin Properties

    _ = ("margin", CSSMargin.self, CSSPropertyFlags.shorthand)
    _ = ("margin-top", CSSLengthPercentageOrAuto.self)
    _ = ("margin-right", CSSLengthPercentageOrAuto.self)
    _ = ("margin-bottom", CSSLengthPercentageOrAuto.self)
    _ = ("margin-left", CSSLengthPercentageOrAuto.self)
    _ = ("margin-block", CSSMarginBlock.self, CSSPropertyFlags.shorthand)
    _ = ("margin-block-start", CSSLengthPercentageOrAuto.self)
    _ = ("margin-block-end", CSSLengthPercentageOrAuto.self)
    _ = ("margin-inline", CSSMarginInline.self, CSSPropertyFlags.shorthand)
    _ = ("margin-inline-start", CSSLengthPercentageOrAuto.self)
    _ = ("margin-inline-end", CSSLengthPercentageOrAuto.self)

    // MARK: - Padding Properties

    _ = ("padding", CSSPadding.self, CSSPropertyFlags.shorthand)
    _ = ("padding-top", CSSLengthPercentage.self)
    _ = ("padding-right", CSSLengthPercentage.self)
    _ = ("padding-bottom", CSSLengthPercentage.self)
    _ = ("padding-left", CSSLengthPercentage.self)
    _ = ("padding-block", CSSPaddingBlock.self, CSSPropertyFlags.shorthand)
    _ = ("padding-block-start", CSSLengthPercentage.self)
    _ = ("padding-block-end", CSSLengthPercentage.self)
    _ = ("padding-inline", CSSPaddingInline.self, CSSPropertyFlags.shorthand)
    _ = ("padding-inline-start", CSSLengthPercentage.self)
    _ = ("padding-inline-end", CSSLengthPercentage.self)

    // MARK: - Position Properties

    _ = ("position", CSSPositionProperty.self)
    _ = ("top", CSSLengthPercentageOrAuto.self)
    _ = ("right", CSSLengthPercentageOrAuto.self)
    _ = ("bottom", CSSLengthPercentageOrAuto.self)
    _ = ("left", CSSLengthPercentageOrAuto.self)
    _ = ("inset", CSSInset.self, CSSPropertyFlags.shorthand)
    _ = ("inset-block", CSSInsetBlock.self, CSSPropertyFlags.shorthand)
    _ = ("inset-block-start", CSSLengthPercentageOrAuto.self)
    _ = ("inset-block-end", CSSLengthPercentageOrAuto.self)
    _ = ("inset-inline", CSSInsetInline.self, CSSPropertyFlags.shorthand)
    _ = ("inset-inline-start", CSSLengthPercentageOrAuto.self)
    _ = ("inset-inline-end", CSSLengthPercentageOrAuto.self)
    _ = ("z-index", CSSZIndex.self)

    // MARK: - Display & Visibility

    _ = ("display", CSSDisplay.self)
    _ = ("visibility", CSSVisibility.self, CSSPropertyFlags.inherits)
    _ = ("box-sizing", CSSBoxSizing.self)

    // MARK: - Overflow

    _ = ("overflow", CSSOverflow.self, CSSPropertyFlags.shorthand)
    _ = ("overflow-x", CSSOverflowKeyword.self)
    _ = ("overflow-y", CSSOverflowKeyword.self)
    _ = ("text-overflow", CSSTextOverflow.self)

    // MARK: - Flex Properties

    _ = ("flex-direction", CSSFlexDirection.self)
    _ = ("flex-wrap", CSSFlexWrap.self)
    _ = ("flex-flow", CSSFlexFlow.self, CSSPropertyFlags.shorthand)
    _ = ("flex", CSSFlex.self, CSSPropertyFlags.shorthand)
    _ = ("flex-grow", CSSNumber.self)
    _ = ("flex-shrink", CSSNumber.self)
    _ = ("flex-basis", CSSSize.self)
    _ = ("order", CSSInteger.self)

    // MARK: - Alignment Properties

    _ = ("align-content", CSSAlignContent.self)
    _ = ("align-items", CSSAlignItems.self)
    _ = ("align-self", CSSAlignSelf.self)
    _ = ("justify-content", CSSJustifyContent.self)
    _ = ("justify-items", CSSJustifyItems.self)
    _ = ("justify-self", CSSJustifySelf.self)
    _ = ("place-content", CSSPlaceContent.self, CSSPropertyFlags.shorthand)
    _ = ("place-items", CSSPlaceItems.self, CSSPropertyFlags.shorthand)
    _ = ("place-self", CSSPlaceSelf.self, CSSPropertyFlags.shorthand)
    _ = ("gap", CSSGap.self, CSSPropertyFlags.shorthand)
    _ = ("row-gap", CSSGapValue.self)
    _ = ("column-gap", CSSGapValue.self)

    // MARK: - Grid Properties

    _ = ("grid-template-columns", CSSTrackList.self)
    _ = ("grid-template-rows", CSSTrackList.self)
    _ = ("grid-template-areas", CSSGridTemplateAreas.self)
    _ = ("grid-template", CSSGridTemplate.self, CSSPropertyFlags.shorthand)
    _ = ("grid", CSSGrid.self, CSSPropertyFlags.shorthand)
    _ = ("grid-auto-flow", CSSGridAutoFlow.self)
    _ = ("grid-auto-columns", CSSTrackSizeList.self)
    _ = ("grid-auto-rows", CSSTrackSizeList.self)
    _ = ("grid-row-start", CSSGridLine.self)
    _ = ("grid-row-end", CSSGridLine.self)
    _ = ("grid-column-start", CSSGridLine.self)
    _ = ("grid-column-end", CSSGridLine.self)
    _ = ("grid-row", CSSGridRow.self, CSSPropertyFlags.shorthand)
    _ = ("grid-column", CSSGridColumn.self, CSSPropertyFlags.shorthand)
    _ = ("grid-area", CSSGridArea.self, CSSPropertyFlags.shorthand)

    // MARK: - Border Style

    _ = ("border-style", CSSBorderStyle.self, CSSPropertyFlags.shorthand)
    _ = ("border-top-style", CSSLineStyle.self)
    _ = ("border-right-style", CSSLineStyle.self)
    _ = ("border-bottom-style", CSSLineStyle.self)
    _ = ("border-left-style", CSSLineStyle.self)
    _ = ("border-block-start-style", CSSLineStyle.self)
    _ = ("border-block-end-style", CSSLineStyle.self)
    _ = ("border-inline-start-style", CSSLineStyle.self)
    _ = ("border-inline-end-style", CSSLineStyle.self)

    // MARK: - Border Width

    _ = ("border-width", CSSBorderWidth.self, CSSPropertyFlags.shorthand)
    _ = ("border-top-width", CSSBorderSideWidth.self)
    _ = ("border-right-width", CSSBorderSideWidth.self)
    _ = ("border-bottom-width", CSSBorderSideWidth.self)
    _ = ("border-left-width", CSSBorderSideWidth.self)
    _ = ("border-block-start-width", CSSBorderSideWidth.self)
    _ = ("border-block-end-width", CSSBorderSideWidth.self)
    _ = ("border-inline-start-width", CSSBorderSideWidth.self)
    _ = ("border-inline-end-width", CSSBorderSideWidth.self)

    // MARK: - Border Shorthand

    _ = ("border", CSSBorderSide.self, CSSPropertyFlags.shorthand)
    _ = ("border-top", CSSBorderSide.self, CSSPropertyFlags.shorthand)
    _ = ("border-right", CSSBorderSide.self, CSSPropertyFlags.shorthand)
    _ = ("border-bottom", CSSBorderSide.self, CSSPropertyFlags.shorthand)
    _ = ("border-left", CSSBorderSide.self, CSSPropertyFlags.shorthand)
    _ = ("border-block", CSSBorderSide.self, CSSPropertyFlags.shorthand)
    _ = ("border-block-start", CSSBorderSide.self, CSSPropertyFlags.shorthand)
    _ = ("border-block-end", CSSBorderSide.self, CSSPropertyFlags.shorthand)
    _ = ("border-inline", CSSBorderSide.self, CSSPropertyFlags.shorthand)
    _ = ("border-inline-start", CSSBorderSide.self, CSSPropertyFlags.shorthand)
    _ = ("border-inline-end", CSSBorderSide.self, CSSPropertyFlags.shorthand)

    // MARK: - Border Radius

    _ = ("border-radius", CSSBorderRadius.self, CSSPropertyFlags.shorthand)
    _ = ("border-top-left-radius", CSSSize2D<CSSLengthPercentage>.self)
    _ = ("border-top-right-radius", CSSSize2D<CSSLengthPercentage>.self)
    _ = ("border-bottom-right-radius", CSSSize2D<CSSLengthPercentage>.self)
    _ = ("border-bottom-left-radius", CSSSize2D<CSSLengthPercentage>.self)
    _ = ("border-start-start-radius", CSSSize2D<CSSLengthPercentage>.self)
    _ = ("border-start-end-radius", CSSSize2D<CSSLengthPercentage>.self)
    _ = ("border-end-start-radius", CSSSize2D<CSSLengthPercentage>.self)
    _ = ("border-end-end-radius", CSSSize2D<CSSLengthPercentage>.self)

    // MARK: - Border Image

    _ = ("border-image", CSSBorderImage.self, CSSPropertyFlags.shorthand)
    _ = ("border-image-source", CSSImage.self)
    _ = ("border-image-slice", CSSBorderImageSlice.self)
    _ = ("border-image-width", CSSRect<CSSBorderImageSideWidth>.self)
    _ = ("border-image-outset", CSSRect<CSSLengthOrNumber>.self)
    _ = ("border-image-repeat", CSSBorderImageRepeat.self)

    // MARK: - Border Spacing

    _ = ("border-spacing", CSSSize2D<CSSLength>.self, CSSPropertyFlags.inherits)

    // MARK: - Outline

    _ = ("outline", CSSOutline.self, CSSPropertyFlags.shorthand)
    _ = ("outline-style", CSSOutlineStyle.self)
    _ = ("outline-width", CSSBorderSideWidth.self)
    _ = ("outline-offset", CSSLength.self)

    // MARK: - Background

    _ = ("background", CSSBackgroundList.self, CSSPropertyFlags.shorthand)
    _ = ("background-image", CSSImage.self)
    _ = ("background-position", CSSBackgroundPosition.self)
    _ = ("background-position-x", CSSLengthPercentage.self)
    _ = ("background-position-y", CSSLengthPercentage.self)
    _ = ("background-size", CSSBackgroundSize.self)
    _ = ("background-repeat", CSSBackgroundRepeat.self)
    _ = ("background-attachment", CSSBackgroundAttachment.self)
    _ = ("background-clip", CSSBackgroundClip.self)
    _ = ("background-origin", CSSBackgroundOrigin.self)

    // MARK: - Opacity & Effects

    _ = ("opacity", CSSAlphaValue.self)
    _ = ("box-shadow", CSSBoxShadowList.self)
    _ = ("filter", CSSFilterList.self)
    _ = ("backdrop-filter", CSSFilterList.self)

    // MARK: - Font Properties

    _ = ("font", CSSFont.self, [CSSPropertyFlags.shorthand, .inherits])
    _ = ("font-family", CSSFontFamily.self, CSSPropertyFlags.inherits)
    _ = ("font-size", CSSFontSize.self, CSSPropertyFlags.inherits)
    _ = ("font-weight", CSSFontWeight.self, CSSPropertyFlags.inherits)
    _ = ("font-style", CSSFontStyle.self, CSSPropertyFlags.inherits)
    _ = ("font-stretch", CSSFontStretch.self, CSSPropertyFlags.inherits)
    _ = ("font-variant-caps", CSSFontVariantCaps.self, CSSPropertyFlags.inherits)
    _ = ("line-height", CSSLineHeight.self, CSSPropertyFlags.inherits)

    // MARK: - Text Properties

    _ = ("text-align", CSSTextAlign.self, CSSPropertyFlags.inherits)
    _ = ("text-align-last", CSSTextAlignLast.self, CSSPropertyFlags.inherits)
    _ = ("text-justify", CSSTextJustify.self, CSSPropertyFlags.inherits)
    _ = ("text-transform", CSSTextTransform.self, CSSPropertyFlags.inherits)
    _ = ("text-decoration", CSSTextDecoration.self, CSSPropertyFlags.shorthand)
    _ = ("text-decoration-line", CSSTextDecorationLine.self)
    _ = ("text-decoration-style", CSSTextDecorationStyle.self)
    _ = ("text-decoration-thickness", CSSTextDecorationThickness.self)
    _ = ("text-decoration-skip-ink", CSSTextDecorationSkipInk.self)
    _ = ("text-emphasis", CSSTextEmphasis.self, [CSSPropertyFlags.shorthand, .inherits])
    _ = ("text-emphasis-style", CSSTextEmphasisStyle.self, CSSPropertyFlags.inherits)
    _ = ("text-emphasis-position", CSSTextEmphasisPosition.self, CSSPropertyFlags.inherits)
    _ = ("text-indent", CSSTextIndent.self, CSSPropertyFlags.inherits)
    _ = ("text-shadow", CSSTextShadow.self, CSSPropertyFlags.inherits)
    _ = ("white-space", CSSWhiteSpace.self, CSSPropertyFlags.inherits)
    _ = ("word-break", CSSWordBreak.self, CSSPropertyFlags.inherits)
    _ = ("line-break", CSSLineBreak.self, CSSPropertyFlags.inherits)
    _ = ("overflow-wrap", CSSOverflowWrap.self, CSSPropertyFlags.inherits)
    _ = ("word-wrap", CSSOverflowWrap.self, CSSPropertyFlags.inherits)
    _ = ("hyphens", CSSHyphens.self, CSSPropertyFlags.inherits)
    _ = ("letter-spacing", CSSSpacing.self, CSSPropertyFlags.inherits)
    _ = ("word-spacing", CSSSpacing.self, CSSPropertyFlags.inherits)
    _ = ("vertical-align", CSSVerticalAlign.self)
    _ = ("direction", CSSDirection.self, CSSPropertyFlags.inherits)
    _ = ("unicode-bidi", CSSUnicodeBidi.self)

    // MARK: - Transform Properties

    _ = ("transform", CSSTransformList.self, CSSPropertyFlags.transformPrefixes)
    _ = ("transform-origin", CSSPosition.self, CSSPropertyFlags.transformPrefixes)
    _ = ("transform-style", CSSTransformStyle.self, CSSPropertyFlags.transformPrefixes)
    _ = ("transform-box", CSSTransformBox.self)
    _ = ("perspective", CSSPerspectiveProperty.self, CSSPropertyFlags.transformPrefixes)
    _ = ("perspective-origin", CSSPosition.self, CSSPropertyFlags.transformPrefixes)
    _ = ("backface-visibility", CSSBackfaceVisibility.self, CSSPropertyFlags.transformPrefixes)
    _ = ("translate", CSSTranslateProperty.self)
    _ = ("rotate", CSSRotateProperty.self)
    _ = ("scale", CSSScaleProperty.self)

    // MARK: - Transition Properties

    _ = ("transition", CSSTransitionList.self, [CSSPropertyFlags.shorthand, .webkit, .moz, .o])
    _ = ("transition-property", CSSTransitionPropertyId.self, [CSSPropertyFlags.webkit, .moz, .o])
    _ = ("transition-duration", CSSTime.self, [CSSPropertyFlags.webkit, .moz, .o])
    _ = ("transition-delay", CSSTime.self, [CSSPropertyFlags.webkit, .moz, .o])
    _ = ("transition-timing-function", CSSEasingFunction.self, [CSSPropertyFlags.webkit, .moz, .o])

    // MARK: - Animation Properties

    _ = ("animation", CSSAnimationList.self, [CSSPropertyFlags.shorthand, .webkit, .moz, .o])
    _ = ("animation-name", CSSAnimationName.self, [CSSPropertyFlags.webkit, .moz, .o])
    _ = ("animation-duration", CSSTime.self, [CSSPropertyFlags.webkit, .moz, .o])
    _ = ("animation-delay", CSSTime.self, [CSSPropertyFlags.webkit, .moz, .o])
    _ = ("animation-timing-function", CSSEasingFunction.self, [CSSPropertyFlags.webkit, .moz, .o])
    _ = ("animation-iteration-count", CSSAnimationIterationCount.self, [CSSPropertyFlags.webkit, .moz, .o])
    _ = ("animation-direction", CSSAnimationDirection.self, [CSSPropertyFlags.webkit, .moz, .o])
    _ = ("animation-fill-mode", CSSAnimationFillMode.self, [CSSPropertyFlags.webkit, .moz, .o])
    _ = ("animation-play-state", CSSAnimationPlayState.self, [CSSPropertyFlags.webkit, .moz, .o])
    _ = ("animation-composition", CSSAnimationComposition.self)

    // MARK: - List Properties

    _ = ("list-style", CSSListStyle.self, [CSSPropertyFlags.shorthand, .inherits])
    _ = ("list-style-type", CSSListStyleType.self, CSSPropertyFlags.inherits)
    _ = ("list-style-position", CSSListStylePosition.self, CSSPropertyFlags.inherits)
    _ = ("list-style-image", CSSImage.self, CSSPropertyFlags.inherits)

    // MARK: - Masking Properties

    _ = ("mask", CSSMask.self, [CSSPropertyFlags.shorthand, .webkit])
    _ = ("mask-image", CSSImage.self, CSSPropertyFlags.webkit)
    _ = ("mask-mode", CSSMaskMode.self, CSSPropertyFlags.webkit)
    _ = ("mask-repeat", CSSBackgroundRepeat.self, CSSPropertyFlags.webkit)
    _ = ("mask-position", CSSPosition.self, CSSPropertyFlags.webkit)
    _ = ("mask-clip", CSSMaskClip.self, CSSPropertyFlags.webkit)
    _ = ("mask-origin", CSSGeometryBox.self, CSSPropertyFlags.webkit)
    _ = ("mask-size", CSSBackgroundSize.self, CSSPropertyFlags.webkit)
    _ = ("mask-composite", CSSMaskComposite.self, CSSPropertyFlags.webkit)
    _ = ("mask-type", CSSMaskType.self)
    _ = ("clip-path", CSSClipPath.self, CSSPropertyFlags.webkit)

    // MARK: - SVG Properties

    _ = ("fill", CSSSVGPaint.self, CSSPropertyFlags.inherits)
    _ = ("fill-opacity", CSSAlphaValue.self, CSSPropertyFlags.inherits)
    _ = ("fill-rule", CSSFillRule.self, CSSPropertyFlags.inherits)
    _ = ("stroke", CSSSVGPaint.self, CSSPropertyFlags.inherits)
    _ = ("stroke-opacity", CSSAlphaValue.self, CSSPropertyFlags.inherits)
    _ = ("stroke-width", CSSLengthPercentage.self, CSSPropertyFlags.inherits)
    _ = ("stroke-linecap", CSSStrokeLinecap.self, CSSPropertyFlags.inherits)
    _ = ("stroke-linejoin", CSSStrokeLinejoin.self, CSSPropertyFlags.inherits)
    _ = ("stroke-miterlimit", CSSNumber.self, CSSPropertyFlags.inherits)
    _ = ("stroke-dasharray", CSSStrokeDasharray.self, CSSPropertyFlags.inherits)
    _ = ("stroke-dashoffset", CSSLengthPercentage.self, CSSPropertyFlags.inherits)
    _ = ("marker", CSSMarker.self, [CSSPropertyFlags.shorthand, .inherits])
    _ = ("marker-start", CSSMarker.self, CSSPropertyFlags.inherits)
    _ = ("marker-mid", CSSMarker.self, CSSPropertyFlags.inherits)
    _ = ("marker-end", CSSMarker.self, CSSPropertyFlags.inherits)
    _ = ("color-interpolation", CSSColorInterpolation.self, CSSPropertyFlags.inherits)
    _ = ("color-rendering", CSSColorRendering.self, CSSPropertyFlags.inherits)
    _ = ("shape-rendering", CSSShapeRendering.self, CSSPropertyFlags.inherits)
    _ = ("text-rendering", CSSTextRendering.self, CSSPropertyFlags.inherits)
    _ = ("image-rendering", CSSImageRendering.self, CSSPropertyFlags.inherits)

    // MARK: - UI Properties

    _ = ("cursor", CSSCursor.self, CSSPropertyFlags.inherits)
    _ = ("caret-shape", CSSCaretShape.self)
    _ = ("caret", CSSCaret.self, CSSPropertyFlags.shorthand)
    _ = ("resize", CSSResize.self)
    _ = ("user-select", CSSUserSelect.self, CSSPropertyFlags.allPrefixes)
    _ = ("appearance", CSSAppearance.self, [CSSPropertyFlags.webkit, .moz])
    _ = ("color-scheme", CSSColorScheme.self, CSSPropertyFlags.inherits)
    _ = ("print-color-adjust", CSSPrintColorAdjust.self, CSSPropertyFlags.inherits)

    // MARK: - Container Properties

    _ = ("container", CSSContainer.self, CSSPropertyFlags.shorthand)
    _ = ("container-type", CSSContainerType.self)
    _ = ("container-name", CSSContainerNameList.self)

    // MARK: - View Transition

    _ = ("view-transition-name", CSSViewTransitionName.self)

    // MARK: - Contain

    _ = ("contain", CSSContain.self)
    _ = ("content-visibility", CSSContentVisibility.self)

    // MARK: - Shape Properties

    _ = ("shape-outside", CSSShapeOutside.self)
    _ = ("shape-margin", CSSLengthPercentage.self)
    _ = ("shape-image-threshold", CSSAlphaValue.self)

    // MARK: - CSS Modules

    _ = ("composes", CSSComposes.self)
}
