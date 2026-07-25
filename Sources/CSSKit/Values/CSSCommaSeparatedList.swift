// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

/// A non-empty comma-separated CSS value list.
///
/// Many CSS longhands are lists even when their initial value has one item.
/// Keeping the list in the typed value model preserves layer boundaries for
/// backgrounds, masks, transitions, animations, and font fallback families.
public struct CSSCommaSeparatedList<
    Element: Equatable & Sendable & CSSSerializable
>: Equatable, Sendable {
    /// The values in source order. This collection is always non-empty.
    public let values: [Element]

    /// Creates a list from a required first value and any remaining values.
    public init(first: Element, rest: [Element] = []) {
        var values = [first]
        values.append(contentsOf: rest)
        self.values = values
    }

    /// Creates a list when `values` contains at least one item.
    public init?(values: [Element]) {
        guard !values.isEmpty else {
            return nil
        }
        self.values = values
    }

    private init(nonEmptyValues values: [Element]) {
        self.values = values
    }
}

extension CSSCommaSeparatedList: Hashable where Element: Hashable {}

extension CSSCommaSeparatedList where Element: CSSParseable {
    static func parse(
        _ input: Parser
    ) -> Result<CSSCommaSeparatedList<Element>, BasicParseError> {
        guard case let .success(first) = Element.parse(input) else {
            return .failure(input.newBasicError(.endOfInput))
        }

        var values = [first]
        while input.tryParse({ $0.expectComma() }).isOK {
            guard case let .success(value) = Element.parse(input) else {
                return .failure(input.newBasicError(.endOfInput))
            }
            values.append(value)
        }

        return .success(CSSCommaSeparatedList(nonEmptyValues: values))
    }
}

extension CSSCommaSeparatedList: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        for (index, value) in values.enumerated() {
            if index > 0 {
                dest.write(", ")
            }
            value.serialize(dest: &dest)
        }
    }
}

// MARK: - Semantic list names

public typealias CSSImageList = CSSCommaSeparatedList<CSSImage>
public typealias CSSBackgroundPositionList =
    CSSCommaSeparatedList<CSSBackgroundPosition>
public typealias CSSBackgroundSizeList =
    CSSCommaSeparatedList<CSSBackgroundSize>
public typealias CSSBackgroundRepeatList =
    CSSCommaSeparatedList<CSSBackgroundRepeat>
public typealias CSSBackgroundAttachmentList =
    CSSCommaSeparatedList<CSSBackgroundAttachment>
public typealias CSSBackgroundClipList =
    CSSCommaSeparatedList<CSSBackgroundClip>
public typealias CSSBackgroundOriginList =
    CSSCommaSeparatedList<CSSBackgroundOrigin>
public typealias CSSFontFamilyList =
    CSSCommaSeparatedList<CSSFontFamily>
public typealias CSSTransitionPropertyList =
    CSSCommaSeparatedList<CSSTransitionPropertyId>
public typealias CSSTimeList = CSSCommaSeparatedList<CSSTime>
public typealias CSSEasingFunctionList =
    CSSCommaSeparatedList<CSSEasingFunction>
public typealias CSSAnimationNameList =
    CSSCommaSeparatedList<CSSAnimationName>
public typealias CSSAnimationIterationCountList =
    CSSCommaSeparatedList<CSSAnimationIterationCount>
public typealias CSSAnimationDirectionList =
    CSSCommaSeparatedList<CSSAnimationDirection>
public typealias CSSAnimationFillModeList =
    CSSCommaSeparatedList<CSSAnimationFillMode>
public typealias CSSAnimationPlayStateList =
    CSSCommaSeparatedList<CSSAnimationPlayState>
public typealias CSSAnimationCompositionList =
    CSSCommaSeparatedList<CSSAnimationComposition>
public typealias CSSMaskModeList =
    CSSCommaSeparatedList<CSSMaskMode>
public typealias CSSPositionList =
    CSSCommaSeparatedList<CSSPosition>
public typealias CSSMaskClipList =
    CSSCommaSeparatedList<CSSMaskClip>
public typealias CSSGeometryBoxList =
    CSSCommaSeparatedList<CSSGeometryBox>
public typealias CSSMaskCompositeList =
    CSSCommaSeparatedList<CSSMaskComposite>

// MARK: - List element parsing

extension CSSImage: CSSParseable {}
extension CSSBackgroundPosition: CSSParseable {}
extension CSSBackgroundSize: CSSParseable {}
extension CSSBackgroundRepeat: CSSParseable {}
extension CSSBackgroundAttachment: CSSParseable {}
extension CSSBackgroundClip: CSSParseable {}
extension CSSBackgroundOrigin: CSSParseable {}
extension CSSFontFamily: CSSParseable {}
extension CSSTransitionPropertyId: CSSParseable {}
extension CSSTime: CSSParseable {}
extension CSSEasingFunction: CSSParseable {}
extension CSSAnimationName: CSSParseable {}
extension CSSAnimationIterationCount: CSSParseable {}
extension CSSAnimationDirection: CSSParseable {}
extension CSSAnimationFillMode: CSSParseable {}
extension CSSAnimationPlayState: CSSParseable {}
extension CSSAnimationComposition: CSSParseable {}
extension CSSMaskMode: CSSParseable {}
extension CSSPosition: CSSParseable {}
extension CSSMaskClip: CSSParseable {}
extension CSSGeometryBox: CSSParseable {}
extension CSSMaskComposite: CSSParseable {}
