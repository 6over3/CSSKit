// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import CSSKit
import Testing

@Suite("Shorthand Registration Tests")
struct ShorthandRegistrationTests {
    @Test("border-color parses one to four typed values")
    func borderColor() throws {
        let declaration = try CSSParser(
            "border-color: red green blue black"
        ).declarations.first

        guard case let .borderColor(value) = declaration?.value else {
            Issue.record("Expected a typed border-color shorthand")
            return
        }

        var writer = StringCSSWriter()
        value.serialize(dest: &writer)
        #expect(
            writer.result
                == "rgb(255, 0, 0) rgb(0, 128, 0) rgb(0, 0, 255) rgb(0, 0, 0)"
        )
    }

    @Test("logical border shorthands use their typed pair grammars")
    func logicalBorderPairs() throws {
        let declarations = try CSSParser(
            """
            border-block-color: red blue;
            border-inline-style: solid dashed;
            border-block-width: 1px thick;
            """
        ).declarations

        guard declarations.count == 3 else {
            Issue.record("Expected three declarations")
            return
        }
        guard case let .borderBlockColor(colors) = declarations[0].value,
              case let .borderInlineStyle(styles) = declarations[1].value,
              case let .borderBlockWidth(widths) = declarations[2].value
        else {
            Issue.record("Expected typed logical border shorthands")
            return
        }

        #expect(colors.start != colors.end)
        #expect(styles.start == .solid)
        #expect(styles.end == .dashed)
        #expect(widths.start == .length(.px(1)))
        #expect(widths.end == .thick)
    }

    @Test("padding uses the longhand length-percentage grammar")
    func paddingGrammar() throws {
        let declarations = try CSSParser(
            "padding: 1px 2%; padding: auto"
        ).declarations

        guard case let .padding(value) = declarations[0].value else {
            Issue.record("Expected typed padding")
            return
        }
        #expect(value.top == .dimension(.px(1)))
        #expect(value.right == .percentage(CSSPercentage(0.02)))
        #expect(value.bottom == value.top)
        #expect(value.left == value.right)
        guard case .unparsed = declarations[1].value else {
            Issue.record("padding: auto must not enter the typed padding grammar")
            return
        }
    }

    @Test("layered background longhands preserve every layer")
    func backgroundLonghandLists() throws {
        let declarations = try CSSParser(
            """
            background-image: linear-gradient(red, blue), url(hero.png);
            background-position: left top, center;
            background-size: cover, 40px auto;
            background-repeat: no-repeat, repeat-x;
            background-attachment: fixed, scroll;
            background-clip: text, padding-box;
            background-origin: border-box, content-box;
            """
        ).declarations

        guard case let .backgroundImage(images) = declarations[0].value,
              case let .backgroundPosition(positions) = declarations[1].value,
              case let .backgroundSize(sizes) = declarations[2].value,
              case let .backgroundRepeat(repeats) = declarations[3].value,
              case let .backgroundAttachment(attachments) = declarations[4].value,
              case let .backgroundClip(clips) = declarations[5].value,
              case let .backgroundOrigin(origins) = declarations[6].value
        else {
            Issue.record(
                "Expected typed layered background longhands: \(String(reflecting: declarations.map(\.value)))"
            )
            return
        }

        #expect(images.values.count == 2)
        #expect(positions.values.count == 2)
        #expect(sizes.values.count == 2)
        #expect(repeats.values == [.init(x: .noRepeat, y: .noRepeat), .repeatX])
        #expect(attachments.values == [.fixed, .scroll])
        #expect(clips.values == [.text, .paddingBox])
        #expect(origins.values == [.borderBox, .contentBox])
    }

    @Test("font fallback families remain a typed ordered list")
    func fontFamilyList() throws {
        let declaration = try CSSParser(
            #"font-family: "Source Serif 4", Georgia, serif"#
        ).declarations.first

        guard case let .fontFamily(families) = declaration?.value else {
            Issue.record(
                "Expected a typed font-family list: \(String(reflecting: declaration?.value))"
            )
            return
        }

        #expect(families.values.count == 3)
        #expect(families.values.last == .generic(.serif))
    }

    @Test("transition and animation longhands preserve comma lists")
    func motionLonghandLists() throws {
        let declarations = try CSSParser(
            """
            transition-duration: 120ms, 0.4s;
            transition-timing-function: ease-out, linear;
            animation-name: reveal, settle;
            animation-iteration-count: 1, infinite;
            animation-timeline: auto, scroll(root block);
            """
        ).declarations

        guard case let .transitionDuration(durations, _) = declarations[0].value,
              case let .transitionTimingFunction(easings, _) = declarations[1].value,
              case let .animationName(names, _) = declarations[2].value,
              case let .animationIterationCount(counts, _) = declarations[3].value,
              case let .animationTimeline(timelines) = declarations[4].value
        else {
            Issue.record("Expected typed motion longhand lists")
            return
        }

        #expect(durations.values.map(\.inMilliseconds) == [120, 400])
        #expect(easings.values == [.easeOut, .linear])
        #expect(names.values.count == 2)
        #expect(counts.values == [.number(1), .infinite])
        #expect(timelines.values.count == 2)
    }

    @Test("background-position is a list-valued longhand")
    func backgroundPositionIsLonghand() {
        #expect(!CSSPropertyId.backgroundPosition.isShorthand)
    }

    @Test("mask shorthand and longhands preserve layer lists")
    func maskLists() throws {
        let declarations = try CSSParser(
            """
            mask: url(alpha.svg) center / cover no-repeat,
                  linear-gradient(black, transparent);
            mask-image: url(alpha.svg), url(beta.svg);
            mask-mode: alpha, luminance;
            """
        ).declarations

        guard case let .mask(masks, _) = declarations[0].value,
              case let .maskImage(images, _) = declarations[1].value,
              case let .maskMode(modes, _) = declarations[2].value
        else {
            Issue.record(
                "Expected typed mask lists: \(String(reflecting: declarations.map(\.value)))"
            )
            return
        }

        #expect(masks.values.count == 2)
        #expect(images.values.count == 2)
        #expect(modes.values == [.alpha, .luminance])
    }

    @Test("mask-border shorthand and longhands use CSS Masking initial grammars")
    func maskBorder() throws {
        let declarations = try CSSParser(
            """
            mask-border:
              url(mask.png) luminance 25 fill / 10px / 2 repeat round;
            mask-border-source: none;
            mask-border-mode: alpha;
            mask-border-slice: 0;
            mask-border-width: auto;
            mask-border-outset: 0;
            mask-border-repeat: stretch;
            """
        ).declarations

        guard case let .maskBorder(shorthand) = declarations[0].value,
              case .maskBorderSource(.none) = declarations[1].value,
              case .maskBorderMode(.alpha) = declarations[2].value,
              case let .maskBorderSlice(slice) = declarations[3].value,
              case let .maskBorderWidth(width) = declarations[4].value,
              case let .maskBorderOutset(outset) = declarations[5].value,
              case let .maskBorderRepeat(repeatValue) = declarations[6].value
        else {
            Issue.record(
                "Expected typed mask-border values: \(String(reflecting: declarations.map(\.value)))"
            )
            return
        }

        #expect(shorthand.source != .none)
        #expect(shorthand.mode == .luminance)
        #expect(shorthand.slice.fill)
        #expect(
            shorthand.repeat
                == CSSBorderImageRepeat(horizontal: .repeat, vertical: .round)
        )
        #expect(slice == CSSMaskBorder.initialSlice)
        #expect(width == CSSMaskBorder.initialWidth)
        #expect(outset == CSSMaskBorder.initialOutset)
        #expect(repeatValue == .default)

        var writer = StringCSSWriter()
        shorthand.serialize(dest: &writer)
        let roundTrip = try CSSParser(
            "mask-border: \(writer.result)"
        ).declarations.first
        guard case let .maskBorder(reparsed) = roundTrip?.value else {
            Issue.record("Expected serialized mask-border to remain typed")
            return
        }
        #expect(reparsed == shorthand)

        var initialWriter = StringCSSWriter()
        CSSMaskBorder.default.serialize(dest: &initialWriter)
        #expect(initialWriter.result == "none")
    }
}
