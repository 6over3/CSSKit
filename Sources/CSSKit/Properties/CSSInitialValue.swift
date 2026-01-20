// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A CSS value type that has a defined initial value per the CSS specification.
public protocol CSSInitialValue {
    /// The initial value for this type as defined in the CSS specification.
    static var initial: Self { get }
}

// MARK: - Font Properties

extension CSSFontWeight: CSSInitialValue {
    public static var initial: CSSFontWeight { .absolute(.normal) }
}

extension CSSAbsoluteFontWeight: CSSInitialValue {
    public static var initial: CSSAbsoluteFontWeight { .normal }
}

extension CSSFontStyle: CSSInitialValue {
    public static var initial: CSSFontStyle { .normal }
}

extension CSSFontStretch: CSSInitialValue {
    public static var initial: CSSFontStretch { .keyword(.normal) }
}

extension CSSFontVariantCaps: CSSInitialValue {
    public static var initial: CSSFontVariantCaps { .normal }
}

extension CSSLineHeight: CSSInitialValue {
    public static var initial: CSSLineHeight { .normal }
}

// MARK: - Display & Visibility

extension CSSDisplay: CSSInitialValue {
    public static var initial: CSSDisplay { .pair(.init(outside: .inline, inside: .flow, isListItem: false)) }
}

extension CSSVisibility: CSSInitialValue {
    public static var initial: CSSVisibility { .visible }
}

extension CSSPositionProperty: CSSInitialValue {
    public static var initial: CSSPositionProperty { .static }
}

// MARK: - Flexbox

extension CSSFlexDirection: CSSInitialValue {
    public static var initial: CSSFlexDirection { .row }
}

extension CSSFlexWrap: CSSInitialValue {
    public static var initial: CSSFlexWrap { .nowrap }
}

// MARK: - Text

extension CSSTextAlign: CSSInitialValue {
    public static var initial: CSSTextAlign { .start }
}

extension CSSTextTransform: CSSInitialValue {
    public static var initial: CSSTextTransform { .none }
}

extension CSSTextDecorationLine: CSSInitialValue {
    public static var initial: CSSTextDecorationLine { .none }
}

extension CSSTextDecorationStyle: CSSInitialValue {
    public static var initial: CSSTextDecorationStyle { .solid }
}

extension CSSWhiteSpace: CSSInitialValue {
    public static var initial: CSSWhiteSpace { .normal }
}

extension CSSWordBreak: CSSInitialValue {
    public static var initial: CSSWordBreak { .normal }
}

extension CSSOverflowWrap: CSSInitialValue {
    public static var initial: CSSOverflowWrap { .normal }
}

extension CSSDirection: CSSInitialValue {
    public static var initial: CSSDirection { .ltr }
}

extension CSSTextOverflow: CSSInitialValue {
    public static var initial: CSSTextOverflow { .clip }
}

// MARK: - Overflow

extension CSSOverflowKeyword: CSSInitialValue {
    public static var initial: CSSOverflowKeyword { .visible }
}

// MARK: - List

extension CSSListStyleType: CSSInitialValue {
    public static var initial: CSSListStyleType { .string("disc") }
}

extension CSSListStylePosition: CSSInitialValue {
    public static var initial: CSSListStylePosition { .outside }
}

// MARK: - Cursor

extension CSSCursor: CSSInitialValue {
    public static var initial: CSSCursor { CSSCursor(keyword: .auto) }
}

// MARK: - Border

extension CSSLineStyle: CSSInitialValue {
    public static var initial: CSSLineStyle { .none }
}

extension CSSBorderSideWidth: CSSInitialValue {
    public static var initial: CSSBorderSideWidth { .medium }
}

// MARK: - Background

extension CSSBackgroundRepeatKeyword: CSSInitialValue {
    public static var initial: CSSBackgroundRepeatKeyword { .repeat }
}

extension CSSBackgroundAttachment: CSSInitialValue {
    public static var initial: CSSBackgroundAttachment { .scroll }
}

extension CSSBackgroundClip: CSSInitialValue {
    public static var initial: CSSBackgroundClip { .borderBox }
}

extension CSSBackgroundOrigin: CSSInitialValue {
    public static var initial: CSSBackgroundOrigin { .paddingBox }
}

// MARK: - Animation

extension CSSAnimationDirection: CSSInitialValue {
    public static var initial: CSSAnimationDirection { .normal }
}

extension CSSAnimationFillMode: CSSInitialValue {
    public static var initial: CSSAnimationFillMode { .none }
}

extension CSSAnimationPlayState: CSSInitialValue {
    public static var initial: CSSAnimationPlayState { .running }
}

extension CSSAnimationIterationCount: CSSInitialValue {
    public static var initial: CSSAnimationIterationCount { .number(1) }
}

// MARK: - Numbers with Initial Values

extension CSSNumber: CSSInitialValue {
    public static var initial: CSSNumber { CSSNumber(0) }
}

extension CSSInteger: CSSInitialValue {
    public static var initial: CSSInteger { CSSInteger(0) }
}

extension CSSAlphaValue: CSSInitialValue {
    public static var initial: CSSAlphaValue { CSSAlphaValue(1.0) }
}

// MARK: - Size Properties

extension CSSSize: CSSInitialValue {
    public static var initial: CSSSize { .auto }
}

extension CSSMaxSize: CSSInitialValue {
    public static var initial: CSSMaxSize { .none }
}

extension CSSLengthPercentageOrAuto: CSSInitialValue {
    public static var initial: CSSLengthPercentageOrAuto { .auto }
}

extension CSSAspectRatio: CSSInitialValue {
    public static var initial: CSSAspectRatio { CSSAspectRatio(auto: true) }
}

// MARK: - Position & Box Model

extension CSSBoxSizing: CSSInitialValue {
    public static var initial: CSSBoxSizing { .contentBox }
}

extension CSSZIndex: CSSInitialValue {
    public static var initial: CSSZIndex { .auto }
}

// MARK: - Time & Easing

extension CSSTime: CSSInitialValue {
    public static var initial: CSSTime { .seconds(0) }
}

extension CSSEasingFunction: CSSInitialValue {
    public static var initial: CSSEasingFunction { .ease }
}

// MARK: - Image

extension CSSImage: CSSInitialValue {
    public static var initial: CSSImage { .none }
}

// MARK: - Font Size

extension CSSFontSize: CSSInitialValue {
    public static var initial: CSSFontSize { .absolute(.medium) }
}

// MARK: - Vertical Align

extension CSSVerticalAlign: CSSInitialValue {
    public static var initial: CSSVerticalAlign { .keyword(.baseline) }
}

// MARK: - Unicode Bidi

extension CSSUnicodeBidi: CSSInitialValue {
    public static var initial: CSSUnicodeBidi { .normal }
}

// MARK: - Transform

extension CSSTransformList: CSSInitialValue {
    public static var initial: CSSTransformList { .none }
}

extension CSSBackfaceVisibility: CSSInitialValue {
    public static var initial: CSSBackfaceVisibility { .visible }
}

// MARK: - UI

extension CSSResize: CSSInitialValue {
    public static var initial: CSSResize { .none }
}

extension CSSUserSelect: CSSInitialValue {
    public static var initial: CSSUserSelect { .auto }
}

extension CSSAppearance: CSSInitialValue {
    public static var initial: CSSAppearance { .auto }
}

// MARK: - Container

extension CSSContainerType: CSSInitialValue {
    public static var initial: CSSContainerType { .normal }
}

extension CSSContentVisibility: CSSInitialValue {
    public static var initial: CSSContentVisibility { .visible }
}

// MARK: - Grid

extension CSSGridAutoFlow: CSSInitialValue {
    public static var initial: CSSGridAutoFlow { .row }
}

extension CSSGridLine: CSSInitialValue {
    public static var initial: CSSGridLine { .auto }
}

extension CSSGapValue: CSSInitialValue {
    public static var initial: CSSGapValue { .normal }
}

// MARK: - Outline

extension CSSOutlineStyle: CSSInitialValue {
    public static var initial: CSSOutlineStyle { .lineStyle(.none) }
}

// MARK: - Background & Effects

extension CSSBackgroundSize: CSSInitialValue {
    public static var initial: CSSBackgroundSize { .auto }
}

extension CSSFilterList: CSSInitialValue {
    public static var initial: CSSFilterList { .none }
}

extension CSSBoxShadowList: CSSInitialValue {
    public static var initial: CSSBoxShadowList { .none }
}

// MARK: - Transform

extension CSSTransformStyle: CSSInitialValue {
    public static var initial: CSSTransformStyle { .flat }
}

extension CSSPerspectiveProperty: CSSInitialValue {
    public static var initial: CSSPerspectiveProperty { .none }
}

// MARK: - Text

extension CSSSpacing: CSSInitialValue {
    public static var initial: CSSSpacing { .normal }
}

extension CSSLineBreak: CSSInitialValue {
    public static var initial: CSSLineBreak { .auto }
}

extension CSSHyphens: CSSInitialValue {
    public static var initial: CSSHyphens { .manual }
}

extension CSSTextAlignLast: CSSInitialValue {
    public static var initial: CSSTextAlignLast { .auto }
}

// MARK: - SVG

extension CSSFillRule: CSSInitialValue {
    public static var initial: CSSFillRule { .nonzero }
}

extension CSSStrokeLinecap: CSSInitialValue {
    public static var initial: CSSStrokeLinecap { .butt }
}

extension CSSStrokeLinejoin: CSSInitialValue {
    public static var initial: CSSStrokeLinejoin { .miter }
}

extension CSSStrokeDasharray: CSSInitialValue {
    public static var initial: CSSStrokeDasharray { .none }
}

// MARK: - UI Extras

extension CSSCaretShape: CSSInitialValue {
    public static var initial: CSSCaretShape { .auto }
}

extension CSSColorScheme: CSSInitialValue {
    public static var initial: CSSColorScheme { .normal }
}

extension CSSPrintColorAdjust: CSSInitialValue {
    public static var initial: CSSPrintColorAdjust { .economy }
}

// MARK: - Alignment

extension CSSAlignContent: CSSInitialValue {
    public static var initial: CSSAlignContent { .normal }
}

extension CSSAlignItems: CSSInitialValue {
    public static var initial: CSSAlignItems { .normal }
}

extension CSSAlignSelf: CSSInitialValue {
    public static var initial: CSSAlignSelf { .auto }
}

extension CSSJustifyContent: CSSInitialValue {
    public static var initial: CSSJustifyContent { .normal }
}

extension CSSJustifyItems: CSSInitialValue {
    public static var initial: CSSJustifyItems { .normal }
}

extension CSSJustifySelf: CSSInitialValue {
    public static var initial: CSSJustifySelf { .auto }
}

// MARK: - Animation & Transition

extension CSSAnimationName: CSSInitialValue {
    public static var initial: CSSAnimationName { .none }
}

extension CSSAnimationComposition: CSSInitialValue {
    public static var initial: CSSAnimationComposition { .replace }
}

extension CSSTransitionPropertyId: CSSInitialValue {
    public static var initial: CSSTransitionPropertyId { .all }
}

extension CSSViewTransitionName: CSSInitialValue {
    public static var initial: CSSViewTransitionName { .none }
}

// MARK: - Masking

extension CSSMaskMode: CSSInitialValue {
    public static var initial: CSSMaskMode { .matchSource }
}

extension CSSMaskType: CSSInitialValue {
    public static var initial: CSSMaskType { .luminance }
}

extension CSSClipPath: CSSInitialValue {
    public static var initial: CSSClipPath { .none }
}

// MARK: - Containment

extension CSSContain: CSSInitialValue {
    public static var initial: CSSContain { .none }
}

// MARK: - Text Extras

extension CSSTextJustify: CSSInitialValue {
    public static var initial: CSSTextJustify { .auto }
}

extension CSSTextDecorationSkipInk: CSSInitialValue {
    public static var initial: CSSTextDecorationSkipInk { .auto }
}

// MARK: - SVG Rendering

extension CSSColorInterpolation: CSSInitialValue {
    public static var initial: CSSColorInterpolation { .sRGB }
}

extension CSSColorRendering: CSSInitialValue {
    public static var initial: CSSColorRendering { .auto }
}

extension CSSShapeRendering: CSSInitialValue {
    public static var initial: CSSShapeRendering { .auto }
}

extension CSSTextRendering: CSSInitialValue {
    public static var initial: CSSTextRendering { .auto }
}

extension CSSImageRendering: CSSInitialValue {
    public static var initial: CSSImageRendering { .auto }
}

// MARK: - Transform Box

extension CSSTransformBox: CSSInitialValue {
    public static var initial: CSSTransformBox { .viewBox }
}
