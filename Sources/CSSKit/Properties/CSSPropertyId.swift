// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// Identifies a CSS property by name.
/// This enum provides type-safe access to CSS property identifiers.
public enum CSSPropertyId: Hashable, Equatable, Sendable {
    // MARK: - Background Properties

    case backgroundColor
    case backgroundImage
    case backgroundPositionX
    case backgroundPositionY
    case backgroundPosition
    case backgroundSize
    case backgroundRepeat
    case backgroundAttachment
    case backgroundClip
    case backgroundOrigin
    case background

    // MARK: - Box Shadow & Opacity

    case boxShadow
    case opacity

    // MARK: - Color & Display

    case color
    case display
    case visibility

    // MARK: - Sizing Properties

    case width
    case height
    case minWidth
    case minHeight
    case maxWidth
    case maxHeight
    case blockSize
    case inlineSize
    case minBlockSize
    case minInlineSize
    case maxBlockSize
    case maxInlineSize
    case boxSizing
    case aspectRatio

    // MARK: - Overflow Properties

    case overflow
    case overflowX
    case overflowY
    case textOverflow

    // MARK: - Position Properties

    case position
    case top
    case bottom
    case left
    case right
    case insetBlockStart
    case insetBlockEnd
    case insetInlineStart
    case insetInlineEnd
    case insetBlock
    case insetInline
    case inset
    case zIndex

    // MARK: - Border Spacing

    case borderSpacing

    // MARK: - Border Color Properties

    case borderTopColor
    case borderBottomColor
    case borderLeftColor
    case borderRightColor
    case borderBlockStartColor
    case borderBlockEndColor
    case borderInlineStartColor
    case borderInlineEndColor
    case borderColor
    case borderBlockColor
    case borderInlineColor

    // MARK: - Border Style Properties

    case borderTopStyle
    case borderBottomStyle
    case borderLeftStyle
    case borderRightStyle
    case borderBlockStartStyle
    case borderBlockEndStyle
    case borderInlineStartStyle
    case borderInlineEndStyle
    case borderStyle
    case borderBlockStyle
    case borderInlineStyle

    // MARK: - Border Width Properties

    case borderTopWidth
    case borderBottomWidth
    case borderLeftWidth
    case borderRightWidth
    case borderBlockStartWidth
    case borderBlockEndWidth
    case borderInlineStartWidth
    case borderInlineEndWidth
    case borderWidth
    case borderBlockWidth
    case borderInlineWidth

    // MARK: - Border Radius Properties

    case borderTopLeftRadius
    case borderTopRightRadius
    case borderBottomLeftRadius
    case borderBottomRightRadius
    case borderStartStartRadius
    case borderStartEndRadius
    case borderEndStartRadius
    case borderEndEndRadius
    case borderRadius

    // MARK: - Border Image Properties

    case borderImageSource
    case borderImageOutset
    case borderImageRepeat
    case borderImageWidth
    case borderImageSlice
    case borderImage

    // MARK: - Border Shorthand Properties

    case border
    case borderTop
    case borderBottom
    case borderLeft
    case borderRight
    case borderBlock
    case borderBlockStart
    case borderBlockEnd
    case borderInline
    case borderInlineStart
    case borderInlineEnd

    // MARK: - Outline Properties

    case outline
    case outlineColor
    case outlineStyle
    case outlineWidth
    case outlineOffset

    // MARK: - Flex Properties

    case flexDirection
    case flexWrap
    case flexFlow
    case flexGrow
    case flexShrink
    case flexBasis
    case flex
    case order

    // MARK: - Alignment Properties

    case alignContent
    case justifyContent
    case placeContent
    case alignSelf
    case justifySelf
    case placeSelf
    case alignItems
    case justifyItems
    case placeItems
    case rowGap
    case columnGap
    case gap

    // MARK: - Grid Properties

    case gridTemplateColumns
    case gridTemplateRows
    case gridAutoColumns
    case gridAutoRows
    case gridAutoFlow
    case gridTemplateAreas
    case gridTemplate
    case grid
    case gridRowStart
    case gridRowEnd
    case gridColumnStart
    case gridColumnEnd
    case gridRow
    case gridColumn
    case gridArea

    // MARK: - Margin Properties

    case marginTop
    case marginBottom
    case marginLeft
    case marginRight
    case marginBlockStart
    case marginBlockEnd
    case marginInlineStart
    case marginInlineEnd
    case marginBlock
    case marginInline
    case margin

    // MARK: - Padding Properties

    case paddingTop
    case paddingBottom
    case paddingLeft
    case paddingRight
    case paddingBlockStart
    case paddingBlockEnd
    case paddingInlineStart
    case paddingInlineEnd
    case paddingBlock
    case paddingInline
    case padding

    // MARK: - Scroll Margin Properties

    case scrollMarginTop
    case scrollMarginBottom
    case scrollMarginLeft
    case scrollMarginRight
    case scrollMarginBlockStart
    case scrollMarginBlockEnd
    case scrollMarginInlineStart
    case scrollMarginInlineEnd
    case scrollMarginBlock
    case scrollMarginInline
    case scrollMargin

    // MARK: - Scroll Padding Properties

    case scrollPaddingTop
    case scrollPaddingBottom
    case scrollPaddingLeft
    case scrollPaddingRight
    case scrollPaddingBlockStart
    case scrollPaddingBlockEnd
    case scrollPaddingInlineStart
    case scrollPaddingInlineEnd
    case scrollPaddingBlock
    case scrollPaddingInline
    case scrollPadding

    // MARK: - Font Properties

    case fontWeight
    case fontSize
    case fontStretch
    case fontFamily
    case fontStyle
    case fontVariantCaps
    case lineHeight
    case font
    case verticalAlign

    // MARK: - Transition Properties

    case transitionProperty
    case transitionDuration
    case transitionDelay
    case transitionTimingFunction
    case transition

    // MARK: - Animation Properties

    case animationName
    case animationDuration
    case animationTimingFunction
    case animationIterationCount
    case animationDirection
    case animationPlayState
    case animationDelay
    case animationFillMode
    case animationComposition
    case animationTimeline
    case animation

    // MARK: - Transform Properties

    case transform
    case transformOrigin
    case transformStyle
    case transformBox
    case backfaceVisibility
    case perspective
    case perspectiveOrigin
    case translate
    case rotate
    case scale

    // MARK: - Text Properties

    case textTransform
    case whiteSpace
    case tabSize
    case wordBreak
    case lineBreak
    case hyphens
    case overflowWrap
    case wordWrap
    case textAlign
    case textAlignLast
    case textJustify
    case wordSpacing
    case letterSpacing
    case textIndent

    // MARK: - Text Decoration Properties

    case textDecorationLine
    case textDecorationStyle
    case textDecorationColor
    case textDecorationThickness
    case textDecoration
    case textDecorationSkipInk
    case textEmphasisStyle
    case textEmphasisColor
    case textEmphasis
    case textEmphasisPosition
    case textShadow

    // MARK: - Writing Mode Properties

    case direction
    case unicodeBidi

    // MARK: - UI Properties

    case resize
    case cursor
    case caretColor
    case caretShape
    case caret
    case userSelect
    case accentColor
    case appearance

    // MARK: - List Properties

    case listStyleType
    case listStyleImage
    case listStylePosition
    case listStyle
    case markerSide

    // MARK: - SVG Properties

    case fill
    case fillRule
    case fillOpacity
    case stroke
    case strokeOpacity
    case strokeWidth
    case strokeLinecap
    case strokeLinejoin
    case strokeMiterlimit
    case strokeDasharray
    case strokeDashoffset
    case markerStart
    case markerMid
    case markerEnd
    case marker
    case colorInterpolation
    case colorInterpolationFilters
    case colorRendering
    case shapeRendering
    case textRendering
    case imageRendering

    // MARK: - Masking Properties

    case clipPath
    case clipRule
    case maskImage
    case maskMode
    case maskRepeat
    case maskPositionX
    case maskPositionY
    case maskPosition
    case maskClip
    case maskOrigin
    case maskSize
    case maskComposite
    case maskType
    case mask
    case maskBorderSource
    case maskBorderMode
    case maskBorderSlice
    case maskBorderWidth
    case maskBorderOutset
    case maskBorderRepeat
    case maskBorder

    // MARK: - Filter Properties

    case filter
    case backdropFilter

    // MARK: - Container Properties

    case containerType
    case containerName
    case container

    // MARK: - View Transition Properties

    case viewTransitionName
    case viewTransitionClass

    // MARK: - Color Scheme Properties

    case colorScheme
    case printColorAdjust

    // MARK: - Content Properties

    case content
    case quotes
    case counterReset
    case counterIncrement
    case counterSet

    // MARK: - Custom Properties

    case custom(String)

    /// Returns the CSS property name as a string.
    public var name: String {
        switch self {
        case .backgroundColor: "background-color"
        case .backgroundImage: "background-image"
        case .backgroundPositionX: "background-position-x"
        case .backgroundPositionY: "background-position-y"
        case .backgroundPosition: "background-position"
        case .backgroundSize: "background-size"
        case .backgroundRepeat: "background-repeat"
        case .backgroundAttachment: "background-attachment"
        case .backgroundClip: "background-clip"
        case .backgroundOrigin: "background-origin"
        case .background: "background"
        case .boxShadow: "box-shadow"
        case .opacity: "opacity"
        case .color: "color"
        case .display: "display"
        case .visibility: "visibility"
        case .width: "width"
        case .height: "height"
        case .minWidth: "min-width"
        case .minHeight: "min-height"
        case .maxWidth: "max-width"
        case .maxHeight: "max-height"
        case .blockSize: "block-size"
        case .inlineSize: "inline-size"
        case .minBlockSize: "min-block-size"
        case .minInlineSize: "min-inline-size"
        case .maxBlockSize: "max-block-size"
        case .maxInlineSize: "max-inline-size"
        case .boxSizing: "box-sizing"
        case .aspectRatio: "aspect-ratio"
        case .overflow: "overflow"
        case .overflowX: "overflow-x"
        case .overflowY: "overflow-y"
        case .textOverflow: "text-overflow"
        case .position: "position"
        case .top: "top"
        case .bottom: "bottom"
        case .left: "left"
        case .right: "right"
        case .insetBlockStart: "inset-block-start"
        case .insetBlockEnd: "inset-block-end"
        case .insetInlineStart: "inset-inline-start"
        case .insetInlineEnd: "inset-inline-end"
        case .insetBlock: "inset-block"
        case .insetInline: "inset-inline"
        case .inset: "inset"
        case .zIndex: "z-index"
        case .borderSpacing: "border-spacing"
        case .borderTopColor: "border-top-color"
        case .borderBottomColor: "border-bottom-color"
        case .borderLeftColor: "border-left-color"
        case .borderRightColor: "border-right-color"
        case .borderBlockStartColor: "border-block-start-color"
        case .borderBlockEndColor: "border-block-end-color"
        case .borderInlineStartColor: "border-inline-start-color"
        case .borderInlineEndColor: "border-inline-end-color"
        case .borderColor: "border-color"
        case .borderBlockColor: "border-block-color"
        case .borderInlineColor: "border-inline-color"
        case .borderTopStyle: "border-top-style"
        case .borderBottomStyle: "border-bottom-style"
        case .borderLeftStyle: "border-left-style"
        case .borderRightStyle: "border-right-style"
        case .borderBlockStartStyle: "border-block-start-style"
        case .borderBlockEndStyle: "border-block-end-style"
        case .borderInlineStartStyle: "border-inline-start-style"
        case .borderInlineEndStyle: "border-inline-end-style"
        case .borderStyle: "border-style"
        case .borderBlockStyle: "border-block-style"
        case .borderInlineStyle: "border-inline-style"
        case .borderTopWidth: "border-top-width"
        case .borderBottomWidth: "border-bottom-width"
        case .borderLeftWidth: "border-left-width"
        case .borderRightWidth: "border-right-width"
        case .borderBlockStartWidth: "border-block-start-width"
        case .borderBlockEndWidth: "border-block-end-width"
        case .borderInlineStartWidth: "border-inline-start-width"
        case .borderInlineEndWidth: "border-inline-end-width"
        case .borderWidth: "border-width"
        case .borderBlockWidth: "border-block-width"
        case .borderInlineWidth: "border-inline-width"
        case .borderTopLeftRadius: "border-top-left-radius"
        case .borderTopRightRadius: "border-top-right-radius"
        case .borderBottomLeftRadius: "border-bottom-left-radius"
        case .borderBottomRightRadius: "border-bottom-right-radius"
        case .borderStartStartRadius: "border-start-start-radius"
        case .borderStartEndRadius: "border-start-end-radius"
        case .borderEndStartRadius: "border-end-start-radius"
        case .borderEndEndRadius: "border-end-end-radius"
        case .borderRadius: "border-radius"
        case .borderImageSource: "border-image-source"
        case .borderImageOutset: "border-image-outset"
        case .borderImageRepeat: "border-image-repeat"
        case .borderImageWidth: "border-image-width"
        case .borderImageSlice: "border-image-slice"
        case .borderImage: "border-image"
        case .border: "border"
        case .borderTop: "border-top"
        case .borderBottom: "border-bottom"
        case .borderLeft: "border-left"
        case .borderRight: "border-right"
        case .borderBlock: "border-block"
        case .borderBlockStart: "border-block-start"
        case .borderBlockEnd: "border-block-end"
        case .borderInline: "border-inline"
        case .borderInlineStart: "border-inline-start"
        case .borderInlineEnd: "border-inline-end"
        case .outline: "outline"
        case .outlineColor: "outline-color"
        case .outlineStyle: "outline-style"
        case .outlineWidth: "outline-width"
        case .outlineOffset: "outline-offset"
        case .flexDirection: "flex-direction"
        case .flexWrap: "flex-wrap"
        case .flexFlow: "flex-flow"
        case .flexGrow: "flex-grow"
        case .flexShrink: "flex-shrink"
        case .flexBasis: "flex-basis"
        case .flex: "flex"
        case .order: "order"
        case .alignContent: "align-content"
        case .justifyContent: "justify-content"
        case .placeContent: "place-content"
        case .alignSelf: "align-self"
        case .justifySelf: "justify-self"
        case .placeSelf: "place-self"
        case .alignItems: "align-items"
        case .justifyItems: "justify-items"
        case .placeItems: "place-items"
        case .rowGap: "row-gap"
        case .columnGap: "column-gap"
        case .gap: "gap"
        case .gridTemplateColumns: "grid-template-columns"
        case .gridTemplateRows: "grid-template-rows"
        case .gridAutoColumns: "grid-auto-columns"
        case .gridAutoRows: "grid-auto-rows"
        case .gridAutoFlow: "grid-auto-flow"
        case .gridTemplateAreas: "grid-template-areas"
        case .gridTemplate: "grid-template"
        case .grid: "grid"
        case .gridRowStart: "grid-row-start"
        case .gridRowEnd: "grid-row-end"
        case .gridColumnStart: "grid-column-start"
        case .gridColumnEnd: "grid-column-end"
        case .gridRow: "grid-row"
        case .gridColumn: "grid-column"
        case .gridArea: "grid-area"
        case .marginTop: "margin-top"
        case .marginBottom: "margin-bottom"
        case .marginLeft: "margin-left"
        case .marginRight: "margin-right"
        case .marginBlockStart: "margin-block-start"
        case .marginBlockEnd: "margin-block-end"
        case .marginInlineStart: "margin-inline-start"
        case .marginInlineEnd: "margin-inline-end"
        case .marginBlock: "margin-block"
        case .marginInline: "margin-inline"
        case .margin: "margin"
        case .paddingTop: "padding-top"
        case .paddingBottom: "padding-bottom"
        case .paddingLeft: "padding-left"
        case .paddingRight: "padding-right"
        case .paddingBlockStart: "padding-block-start"
        case .paddingBlockEnd: "padding-block-end"
        case .paddingInlineStart: "padding-inline-start"
        case .paddingInlineEnd: "padding-inline-end"
        case .paddingBlock: "padding-block"
        case .paddingInline: "padding-inline"
        case .padding: "padding"
        case .scrollMarginTop: "scroll-margin-top"
        case .scrollMarginBottom: "scroll-margin-bottom"
        case .scrollMarginLeft: "scroll-margin-left"
        case .scrollMarginRight: "scroll-margin-right"
        case .scrollMarginBlockStart: "scroll-margin-block-start"
        case .scrollMarginBlockEnd: "scroll-margin-block-end"
        case .scrollMarginInlineStart: "scroll-margin-inline-start"
        case .scrollMarginInlineEnd: "scroll-margin-inline-end"
        case .scrollMarginBlock: "scroll-margin-block"
        case .scrollMarginInline: "scroll-margin-inline"
        case .scrollMargin: "scroll-margin"
        case .scrollPaddingTop: "scroll-padding-top"
        case .scrollPaddingBottom: "scroll-padding-bottom"
        case .scrollPaddingLeft: "scroll-padding-left"
        case .scrollPaddingRight: "scroll-padding-right"
        case .scrollPaddingBlockStart: "scroll-padding-block-start"
        case .scrollPaddingBlockEnd: "scroll-padding-block-end"
        case .scrollPaddingInlineStart: "scroll-padding-inline-start"
        case .scrollPaddingInlineEnd: "scroll-padding-inline-end"
        case .scrollPaddingBlock: "scroll-padding-block"
        case .scrollPaddingInline: "scroll-padding-inline"
        case .scrollPadding: "scroll-padding"
        case .fontWeight: "font-weight"
        case .fontSize: "font-size"
        case .fontStretch: "font-stretch"
        case .fontFamily: "font-family"
        case .fontStyle: "font-style"
        case .fontVariantCaps: "font-variant-caps"
        case .lineHeight: "line-height"
        case .font: "font"
        case .verticalAlign: "vertical-align"
        case .transitionProperty: "transition-property"
        case .transitionDuration: "transition-duration"
        case .transitionDelay: "transition-delay"
        case .transitionTimingFunction: "transition-timing-function"
        case .transition: "transition"
        case .animationName: "animation-name"
        case .animationDuration: "animation-duration"
        case .animationTimingFunction: "animation-timing-function"
        case .animationIterationCount: "animation-iteration-count"
        case .animationDirection: "animation-direction"
        case .animationPlayState: "animation-play-state"
        case .animationDelay: "animation-delay"
        case .animationFillMode: "animation-fill-mode"
        case .animationComposition: "animation-composition"
        case .animationTimeline: "animation-timeline"
        case .animation: "animation"
        case .transform: "transform"
        case .transformOrigin: "transform-origin"
        case .transformStyle: "transform-style"
        case .transformBox: "transform-box"
        case .backfaceVisibility: "backface-visibility"
        case .perspective: "perspective"
        case .perspectiveOrigin: "perspective-origin"
        case .translate: "translate"
        case .rotate: "rotate"
        case .scale: "scale"
        case .textTransform: "text-transform"
        case .whiteSpace: "white-space"
        case .tabSize: "tab-size"
        case .wordBreak: "word-break"
        case .lineBreak: "line-break"
        case .hyphens: "hyphens"
        case .overflowWrap: "overflow-wrap"
        case .wordWrap: "word-wrap"
        case .textAlign: "text-align"
        case .textAlignLast: "text-align-last"
        case .textJustify: "text-justify"
        case .wordSpacing: "word-spacing"
        case .letterSpacing: "letter-spacing"
        case .textIndent: "text-indent"
        case .textDecorationLine: "text-decoration-line"
        case .textDecorationStyle: "text-decoration-style"
        case .textDecorationColor: "text-decoration-color"
        case .textDecorationThickness: "text-decoration-thickness"
        case .textDecoration: "text-decoration"
        case .textDecorationSkipInk: "text-decoration-skip-ink"
        case .textEmphasisStyle: "text-emphasis-style"
        case .textEmphasisColor: "text-emphasis-color"
        case .textEmphasis: "text-emphasis"
        case .textEmphasisPosition: "text-emphasis-position"
        case .textShadow: "text-shadow"
        case .direction: "direction"
        case .unicodeBidi: "unicode-bidi"
        case .resize: "resize"
        case .cursor: "cursor"
        case .caretColor: "caret-color"
        case .caretShape: "caret-shape"
        case .caret: "caret"
        case .userSelect: "user-select"
        case .accentColor: "accent-color"
        case .appearance: "appearance"
        case .listStyleType: "list-style-type"
        case .listStyleImage: "list-style-image"
        case .listStylePosition: "list-style-position"
        case .listStyle: "list-style"
        case .markerSide: "marker-side"
        case .fill: "fill"
        case .fillRule: "fill-rule"
        case .fillOpacity: "fill-opacity"
        case .stroke: "stroke"
        case .strokeOpacity: "stroke-opacity"
        case .strokeWidth: "stroke-width"
        case .strokeLinecap: "stroke-linecap"
        case .strokeLinejoin: "stroke-linejoin"
        case .strokeMiterlimit: "stroke-miterlimit"
        case .strokeDasharray: "stroke-dasharray"
        case .strokeDashoffset: "stroke-dashoffset"
        case .markerStart: "marker-start"
        case .markerMid: "marker-mid"
        case .markerEnd: "marker-end"
        case .marker: "marker"
        case .colorInterpolation: "color-interpolation"
        case .colorInterpolationFilters: "color-interpolation-filters"
        case .colorRendering: "color-rendering"
        case .shapeRendering: "shape-rendering"
        case .textRendering: "text-rendering"
        case .imageRendering: "image-rendering"
        case .clipPath: "clip-path"
        case .clipRule: "clip-rule"
        case .maskImage: "mask-image"
        case .maskMode: "mask-mode"
        case .maskRepeat: "mask-repeat"
        case .maskPositionX: "mask-position-x"
        case .maskPositionY: "mask-position-y"
        case .maskPosition: "mask-position"
        case .maskClip: "mask-clip"
        case .maskOrigin: "mask-origin"
        case .maskSize: "mask-size"
        case .maskComposite: "mask-composite"
        case .maskType: "mask-type"
        case .mask: "mask"
        case .maskBorderSource: "mask-border-source"
        case .maskBorderMode: "mask-border-mode"
        case .maskBorderSlice: "mask-border-slice"
        case .maskBorderWidth: "mask-border-width"
        case .maskBorderOutset: "mask-border-outset"
        case .maskBorderRepeat: "mask-border-repeat"
        case .maskBorder: "mask-border"
        case .filter: "filter"
        case .backdropFilter: "backdrop-filter"
        case .containerType: "container-type"
        case .containerName: "container-name"
        case .container: "container"
        case .viewTransitionName: "view-transition-name"
        case .viewTransitionClass: "view-transition-class"
        case .colorScheme: "color-scheme"
        case .printColorAdjust: "print-color-adjust"
        case .content: "content"
        case .quotes: "quotes"
        case .counterReset: "counter-reset"
        case .counterIncrement: "counter-increment"
        case .counterSet: "counter-set"
        case let .custom(name): name
        }
    }

    /// Creates a property ID from a CSS property name string.
    /// This initializer always succeeds - unrecognized names become `.custom(name)`.
    public init(_ name: String) {
        switch name.lowercased() {
        case "background-color": self = .backgroundColor
        case "background-image": self = .backgroundImage
        case "background-position-x": self = .backgroundPositionX
        case "background-position-y": self = .backgroundPositionY
        case "background-position": self = .backgroundPosition
        case "background-size": self = .backgroundSize
        case "background-repeat": self = .backgroundRepeat
        case "background-attachment": self = .backgroundAttachment
        case "background-clip": self = .backgroundClip
        case "background-origin": self = .backgroundOrigin
        case "background": self = .background
        case "box-shadow": self = .boxShadow
        case "opacity": self = .opacity
        case "color": self = .color
        case "display": self = .display
        case "visibility": self = .visibility
        case "width": self = .width
        case "height": self = .height
        case "min-width": self = .minWidth
        case "min-height": self = .minHeight
        case "max-width": self = .maxWidth
        case "max-height": self = .maxHeight
        case "block-size": self = .blockSize
        case "inline-size": self = .inlineSize
        case "min-block-size": self = .minBlockSize
        case "min-inline-size": self = .minInlineSize
        case "max-block-size": self = .maxBlockSize
        case "max-inline-size": self = .maxInlineSize
        case "box-sizing": self = .boxSizing
        case "aspect-ratio": self = .aspectRatio
        case "overflow": self = .overflow
        case "overflow-x": self = .overflowX
        case "overflow-y": self = .overflowY
        case "text-overflow": self = .textOverflow
        case "position": self = .position
        case "top": self = .top
        case "bottom": self = .bottom
        case "left": self = .left
        case "right": self = .right
        case "inset-block-start": self = .insetBlockStart
        case "inset-block-end": self = .insetBlockEnd
        case "inset-inline-start": self = .insetInlineStart
        case "inset-inline-end": self = .insetInlineEnd
        case "inset-block": self = .insetBlock
        case "inset-inline": self = .insetInline
        case "inset": self = .inset
        case "z-index": self = .zIndex
        case "border-spacing": self = .borderSpacing
        case "border-top-color": self = .borderTopColor
        case "border-bottom-color": self = .borderBottomColor
        case "border-left-color": self = .borderLeftColor
        case "border-right-color": self = .borderRightColor
        case "border-block-start-color": self = .borderBlockStartColor
        case "border-block-end-color": self = .borderBlockEndColor
        case "border-inline-start-color": self = .borderInlineStartColor
        case "border-inline-end-color": self = .borderInlineEndColor
        case "border-color": self = .borderColor
        case "border-block-color": self = .borderBlockColor
        case "border-inline-color": self = .borderInlineColor
        case "border-top-style": self = .borderTopStyle
        case "border-bottom-style": self = .borderBottomStyle
        case "border-left-style": self = .borderLeftStyle
        case "border-right-style": self = .borderRightStyle
        case "border-block-start-style": self = .borderBlockStartStyle
        case "border-block-end-style": self = .borderBlockEndStyle
        case "border-inline-start-style": self = .borderInlineStartStyle
        case "border-inline-end-style": self = .borderInlineEndStyle
        case "border-style": self = .borderStyle
        case "border-block-style": self = .borderBlockStyle
        case "border-inline-style": self = .borderInlineStyle
        case "border-top-width": self = .borderTopWidth
        case "border-bottom-width": self = .borderBottomWidth
        case "border-left-width": self = .borderLeftWidth
        case "border-right-width": self = .borderRightWidth
        case "border-block-start-width": self = .borderBlockStartWidth
        case "border-block-end-width": self = .borderBlockEndWidth
        case "border-inline-start-width": self = .borderInlineStartWidth
        case "border-inline-end-width": self = .borderInlineEndWidth
        case "border-width": self = .borderWidth
        case "border-block-width": self = .borderBlockWidth
        case "border-inline-width": self = .borderInlineWidth
        case "border-top-left-radius": self = .borderTopLeftRadius
        case "border-top-right-radius": self = .borderTopRightRadius
        case "border-bottom-left-radius": self = .borderBottomLeftRadius
        case "border-bottom-right-radius": self = .borderBottomRightRadius
        case "border-start-start-radius": self = .borderStartStartRadius
        case "border-start-end-radius": self = .borderStartEndRadius
        case "border-end-start-radius": self = .borderEndStartRadius
        case "border-end-end-radius": self = .borderEndEndRadius
        case "border-radius": self = .borderRadius
        case "border-image-source": self = .borderImageSource
        case "border-image-outset": self = .borderImageOutset
        case "border-image-repeat": self = .borderImageRepeat
        case "border-image-width": self = .borderImageWidth
        case "border-image-slice": self = .borderImageSlice
        case "border-image": self = .borderImage
        case "border": self = .border
        case "border-top": self = .borderTop
        case "border-bottom": self = .borderBottom
        case "border-left": self = .borderLeft
        case "border-right": self = .borderRight
        case "border-block": self = .borderBlock
        case "border-block-start": self = .borderBlockStart
        case "border-block-end": self = .borderBlockEnd
        case "border-inline": self = .borderInline
        case "border-inline-start": self = .borderInlineStart
        case "border-inline-end": self = .borderInlineEnd
        case "outline": self = .outline
        case "outline-color": self = .outlineColor
        case "outline-style": self = .outlineStyle
        case "outline-width": self = .outlineWidth
        case "outline-offset": self = .outlineOffset
        case "flex-direction": self = .flexDirection
        case "flex-wrap": self = .flexWrap
        case "flex-flow": self = .flexFlow
        case "flex-grow": self = .flexGrow
        case "flex-shrink": self = .flexShrink
        case "flex-basis": self = .flexBasis
        case "flex": self = .flex
        case "order": self = .order
        case "align-content": self = .alignContent
        case "justify-content": self = .justifyContent
        case "place-content": self = .placeContent
        case "align-self": self = .alignSelf
        case "justify-self": self = .justifySelf
        case "place-self": self = .placeSelf
        case "align-items": self = .alignItems
        case "justify-items": self = .justifyItems
        case "place-items": self = .placeItems
        case "row-gap": self = .rowGap
        case "column-gap": self = .columnGap
        case "gap": self = .gap
        case "grid-template-columns": self = .gridTemplateColumns
        case "grid-template-rows": self = .gridTemplateRows
        case "grid-auto-columns": self = .gridAutoColumns
        case "grid-auto-rows": self = .gridAutoRows
        case "grid-auto-flow": self = .gridAutoFlow
        case "grid-template-areas": self = .gridTemplateAreas
        case "grid-template": self = .gridTemplate
        case "grid": self = .grid
        case "grid-row-start": self = .gridRowStart
        case "grid-row-end": self = .gridRowEnd
        case "grid-column-start": self = .gridColumnStart
        case "grid-column-end": self = .gridColumnEnd
        case "grid-row": self = .gridRow
        case "grid-column": self = .gridColumn
        case "grid-area": self = .gridArea
        case "margin-top": self = .marginTop
        case "margin-bottom": self = .marginBottom
        case "margin-left": self = .marginLeft
        case "margin-right": self = .marginRight
        case "margin-block-start": self = .marginBlockStart
        case "margin-block-end": self = .marginBlockEnd
        case "margin-inline-start": self = .marginInlineStart
        case "margin-inline-end": self = .marginInlineEnd
        case "margin-block": self = .marginBlock
        case "margin-inline": self = .marginInline
        case "margin": self = .margin
        case "padding-top": self = .paddingTop
        case "padding-bottom": self = .paddingBottom
        case "padding-left": self = .paddingLeft
        case "padding-right": self = .paddingRight
        case "padding-block-start": self = .paddingBlockStart
        case "padding-block-end": self = .paddingBlockEnd
        case "padding-inline-start": self = .paddingInlineStart
        case "padding-inline-end": self = .paddingInlineEnd
        case "padding-block": self = .paddingBlock
        case "padding-inline": self = .paddingInline
        case "padding": self = .padding
        case "scroll-margin-top": self = .scrollMarginTop
        case "scroll-margin-bottom": self = .scrollMarginBottom
        case "scroll-margin-left": self = .scrollMarginLeft
        case "scroll-margin-right": self = .scrollMarginRight
        case "scroll-margin-block-start": self = .scrollMarginBlockStart
        case "scroll-margin-block-end": self = .scrollMarginBlockEnd
        case "scroll-margin-inline-start": self = .scrollMarginInlineStart
        case "scroll-margin-inline-end": self = .scrollMarginInlineEnd
        case "scroll-margin-block": self = .scrollMarginBlock
        case "scroll-margin-inline": self = .scrollMarginInline
        case "scroll-margin": self = .scrollMargin
        case "scroll-padding-top": self = .scrollPaddingTop
        case "scroll-padding-bottom": self = .scrollPaddingBottom
        case "scroll-padding-left": self = .scrollPaddingLeft
        case "scroll-padding-right": self = .scrollPaddingRight
        case "scroll-padding-block-start": self = .scrollPaddingBlockStart
        case "scroll-padding-block-end": self = .scrollPaddingBlockEnd
        case "scroll-padding-inline-start": self = .scrollPaddingInlineStart
        case "scroll-padding-inline-end": self = .scrollPaddingInlineEnd
        case "scroll-padding-block": self = .scrollPaddingBlock
        case "scroll-padding-inline": self = .scrollPaddingInline
        case "scroll-padding": self = .scrollPadding
        case "font-weight": self = .fontWeight
        case "font-size": self = .fontSize
        case "font-stretch": self = .fontStretch
        case "font-family": self = .fontFamily
        case "font-style": self = .fontStyle
        case "font-variant-caps": self = .fontVariantCaps
        case "line-height": self = .lineHeight
        case "font": self = .font
        case "vertical-align": self = .verticalAlign
        case "transition-property": self = .transitionProperty
        case "transition-duration": self = .transitionDuration
        case "transition-delay": self = .transitionDelay
        case "transition-timing-function": self = .transitionTimingFunction
        case "transition": self = .transition
        case "animation-name": self = .animationName
        case "animation-duration": self = .animationDuration
        case "animation-timing-function": self = .animationTimingFunction
        case "animation-iteration-count": self = .animationIterationCount
        case "animation-direction": self = .animationDirection
        case "animation-play-state": self = .animationPlayState
        case "animation-delay": self = .animationDelay
        case "animation-fill-mode": self = .animationFillMode
        case "animation-composition": self = .animationComposition
        case "animation-timeline": self = .animationTimeline
        case "animation": self = .animation
        case "transform": self = .transform
        case "transform-origin": self = .transformOrigin
        case "transform-style": self = .transformStyle
        case "transform-box": self = .transformBox
        case "backface-visibility": self = .backfaceVisibility
        case "perspective": self = .perspective
        case "perspective-origin": self = .perspectiveOrigin
        case "translate": self = .translate
        case "rotate": self = .rotate
        case "scale": self = .scale
        case "text-transform": self = .textTransform
        case "white-space": self = .whiteSpace
        case "tab-size": self = .tabSize
        case "word-break": self = .wordBreak
        case "line-break": self = .lineBreak
        case "hyphens": self = .hyphens
        case "overflow-wrap": self = .overflowWrap
        case "word-wrap": self = .wordWrap
        case "text-align": self = .textAlign
        case "text-align-last": self = .textAlignLast
        case "text-justify": self = .textJustify
        case "word-spacing": self = .wordSpacing
        case "letter-spacing": self = .letterSpacing
        case "text-indent": self = .textIndent
        case "text-decoration-line": self = .textDecorationLine
        case "text-decoration-style": self = .textDecorationStyle
        case "text-decoration-color": self = .textDecorationColor
        case "text-decoration-thickness": self = .textDecorationThickness
        case "text-decoration": self = .textDecoration
        case "text-decoration-skip-ink": self = .textDecorationSkipInk
        case "text-emphasis-style": self = .textEmphasisStyle
        case "text-emphasis-color": self = .textEmphasisColor
        case "text-emphasis": self = .textEmphasis
        case "text-emphasis-position": self = .textEmphasisPosition
        case "text-shadow": self = .textShadow
        case "direction": self = .direction
        case "unicode-bidi": self = .unicodeBidi
        case "resize": self = .resize
        case "cursor": self = .cursor
        case "caret-color": self = .caretColor
        case "caret-shape": self = .caretShape
        case "caret": self = .caret
        case "user-select": self = .userSelect
        case "accent-color": self = .accentColor
        case "appearance": self = .appearance
        case "list-style-type": self = .listStyleType
        case "list-style-image": self = .listStyleImage
        case "list-style-position": self = .listStylePosition
        case "list-style": self = .listStyle
        case "marker-side": self = .markerSide
        case "fill": self = .fill
        case "fill-rule": self = .fillRule
        case "fill-opacity": self = .fillOpacity
        case "stroke": self = .stroke
        case "stroke-opacity": self = .strokeOpacity
        case "stroke-width": self = .strokeWidth
        case "stroke-linecap": self = .strokeLinecap
        case "stroke-linejoin": self = .strokeLinejoin
        case "stroke-miterlimit": self = .strokeMiterlimit
        case "stroke-dasharray": self = .strokeDasharray
        case "stroke-dashoffset": self = .strokeDashoffset
        case "marker-start": self = .markerStart
        case "marker-mid": self = .markerMid
        case "marker-end": self = .markerEnd
        case "marker": self = .marker
        case "color-interpolation": self = .colorInterpolation
        case "color-interpolation-filters": self = .colorInterpolationFilters
        case "color-rendering": self = .colorRendering
        case "shape-rendering": self = .shapeRendering
        case "text-rendering": self = .textRendering
        case "image-rendering": self = .imageRendering
        case "clip-path": self = .clipPath
        case "clip-rule": self = .clipRule
        case "mask-image": self = .maskImage
        case "mask-mode": self = .maskMode
        case "mask-repeat": self = .maskRepeat
        case "mask-position-x": self = .maskPositionX
        case "mask-position-y": self = .maskPositionY
        case "mask-position": self = .maskPosition
        case "mask-clip": self = .maskClip
        case "mask-origin": self = .maskOrigin
        case "mask-size": self = .maskSize
        case "mask-composite": self = .maskComposite
        case "mask-type": self = .maskType
        case "mask": self = .mask
        case "mask-border-source": self = .maskBorderSource
        case "mask-border-mode": self = .maskBorderMode
        case "mask-border-slice": self = .maskBorderSlice
        case "mask-border-width": self = .maskBorderWidth
        case "mask-border-outset": self = .maskBorderOutset
        case "mask-border-repeat": self = .maskBorderRepeat
        case "mask-border": self = .maskBorder
        case "filter": self = .filter
        case "backdrop-filter": self = .backdropFilter
        case "container-type": self = .containerType
        case "container-name": self = .containerName
        case "container": self = .container
        case "view-transition-name": self = .viewTransitionName
        case "view-transition-class": self = .viewTransitionClass
        case "color-scheme": self = .colorScheme
        case "print-color-adjust": self = .printColorAdjust
        case "content": self = .content
        case "quotes": self = .quotes
        case "counter-reset": self = .counterReset
        case "counter-increment": self = .counterIncrement
        case "counter-set": self = .counterSet
        default:
            self = .custom(name)
        }
    }

    /// Whether this property is a shorthand property.
    public var isShorthand: Bool {
        switch self {
        case .background, .backgroundPosition, .border, .borderTop, .borderBottom,
             .borderLeft, .borderRight, .borderBlock, .borderBlockStart, .borderBlockEnd,
             .borderInline, .borderInlineStart, .borderInlineEnd, .borderColor,
             .borderBlockColor, .borderInlineColor, .borderStyle, .borderBlockStyle,
             .borderInlineStyle, .borderWidth, .borderBlockWidth, .borderInlineWidth,
             .borderRadius, .borderImage, .outline, .margin, .marginBlock, .marginInline,
             .padding, .paddingBlock, .paddingInline, .scrollMargin, .scrollMarginBlock,
             .scrollMarginInline, .scrollPadding, .scrollPaddingBlock, .scrollPaddingInline,
             .inset, .insetBlock, .insetInline, .flex, .flexFlow, .gap, .placeContent,
             .placeSelf, .placeItems, .grid, .gridTemplate, .gridRow, .gridColumn, .gridArea,
             .font, .transition, .animation, .textDecoration, .textEmphasis, .listStyle,
             .mask, .maskBorder, .caret, .container, .overflow:
            true
        default:
            false
        }
    }

    /// Whether this property inherits by default per the CSS specification.
    public var inherits: Bool {
        switch self {
        // Color
        case .color:
            true

        // Font properties
        case .fontFamily, .fontSize, .fontStyle, .fontWeight, .fontStretch,
             .fontVariantCaps, .lineHeight, .font:
            true

        // Text properties
        case .textAlign, .textAlignLast, .textJustify, .textTransform, .textIndent,
             .textShadow, .textEmphasis, .textEmphasisStyle, .textEmphasisColor,
             .textEmphasisPosition, .letterSpacing, .wordSpacing, .whiteSpace,
             .wordBreak, .lineBreak, .hyphens, .overflowWrap, .wordWrap, .tabSize:
            true

        // Writing mode
        case .direction:
            true

        // Visibility & cursor
        case .visibility, .cursor:
            true

        // List properties
        case .listStyle, .listStyleType, .listStylePosition, .listStyleImage:
            true

        // SVG properties
        case .fill, .fillOpacity, .fillRule,
             .stroke, .strokeOpacity, .strokeWidth, .strokeLinecap,
             .strokeLinejoin, .strokeMiterlimit, .strokeDasharray, .strokeDashoffset,
             .marker, .markerStart, .markerMid, .markerEnd,
             .colorInterpolation, .colorRendering, .shapeRendering,
             .textRendering, .imageRendering:
            true

        // Color scheme
        case .colorScheme, .printColorAdjust:
            true

        // Border-spacing
        case .borderSpacing:
            true

        // Quotes
        case .quotes:
            true

        default:
            false
        }
    }
}

// MARK: - ToCss

extension CSSPropertyId: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write(name)
    }
}
