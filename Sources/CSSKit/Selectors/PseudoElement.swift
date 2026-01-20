// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// CSS pseudo-elements
public indirect enum PseudoElement: Equatable, Sendable, Hashable {
    // MARK: - Standard pseudo-elements

    /// ::before
    case before

    /// ::after
    case after

    /// ::first-line
    case firstLine

    /// ::first-letter
    case firstLetter

    /// ::marker
    case marker

    /// ::placeholder
    case placeholder

    /// ::selection
    case selection

    /// ::backdrop
    case backdrop

    /// ::file-selector-button
    case fileSelectorButton

    // MARK: - Media pseudo-elements

    /// ::cue
    case cue

    /// ::cue(S)
    case cueSelector(Selector)

    /// ::cue-region
    case cueRegion

    /// ::cue-region(S)
    case cueRegionSelector(Selector)

    // MARK: - Shadow DOM pseudo-elements

    /// ::slotted(S)
    case slotted(Selector)

    /// ::part(name)
    case part([String])

    // MARK: - View Transitions

    /// ::view-transition
    case viewTransition

    /// ::view-transition-group(name)
    case viewTransitionGroup(String?)

    /// ::view-transition-image-pair(name)
    case viewTransitionImagePair(String?)

    /// ::view-transition-old(name)
    case viewTransitionOld(String?)

    /// ::view-transition-new(name)
    case viewTransitionNew(String?)

    // MARK: - WebKit scrollbar pseudo-elements

    /// ::-webkit-scrollbar
    case webkitScrollbar

    /// ::-webkit-scrollbar-button
    case webkitScrollbarButton

    /// ::-webkit-scrollbar-track
    case webkitScrollbarTrack

    /// ::-webkit-scrollbar-track-piece
    case webkitScrollbarTrackPiece

    /// ::-webkit-scrollbar-thumb
    case webkitScrollbarThumb

    /// ::-webkit-scrollbar-corner
    case webkitScrollbarCorner

    /// ::-webkit-resizer
    case webkitResizer

    // MARK: - Custom/unknown pseudo-elements

    /// Unknown pseudo-element
    case custom(String)

    /// Unknown functional pseudo-element
    case customFunction(String, String)

    /// Whether this is a webkit scrollbar pseudo-element
    public var isWebkitScrollbar: Bool {
        switch self {
        case .webkitScrollbar, .webkitScrollbarButton, .webkitScrollbarTrack,
             .webkitScrollbarTrackPiece, .webkitScrollbarThumb, .webkitScrollbarCorner,
             .webkitResizer:
            true
        default:
            false
        }
    }

    /// Whether this is a view transition pseudo-element
    public var isViewTransition: Bool {
        switch self {
        case .viewTransition, .viewTransitionGroup, .viewTransitionImagePair,
             .viewTransitionOld, .viewTransitionNew:
            true
        default:
            false
        }
    }

    /// Whether this pseudo-element accepts state pseudo-classes after it
    public var acceptsStatePseudoClasses: Bool {
        switch self {
        case .webkitScrollbar, .webkitScrollbarButton, .webkitScrollbarTrack,
             .webkitScrollbarTrackPiece, .webkitScrollbarThumb, .webkitScrollbarCorner,
             .webkitResizer:
            true
        default:
            false
        }
    }

    /// Whether this pseudo-element is valid after ::slotted()
    public var validAfterSlotted: Bool {
        switch self {
        case .before, .after, .marker, .placeholder, .fileSelectorButton:
            true
        default:
            false
        }
    }
}

// MARK: - Serialization

extension PseudoElement: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .before:
            dest.write("::before")
        case .after:
            dest.write("::after")
        case .firstLine:
            dest.write("::first-line")
        case .firstLetter:
            dest.write("::first-letter")
        case .marker:
            dest.write("::marker")
        case .placeholder:
            dest.write("::placeholder")
        case .selection:
            dest.write("::selection")
        case .backdrop:
            dest.write("::backdrop")
        case .fileSelectorButton:
            dest.write("::file-selector-button")
        case .cue:
            dest.write("::cue")
        case let .cueSelector(selector):
            dest.write("::cue(")
            selector.serialize(dest: &dest)
            dest.write(")")
        case .cueRegion:
            dest.write("::cue-region")
        case let .cueRegionSelector(selector):
            dest.write("::cue-region(")
            selector.serialize(dest: &dest)
            dest.write(")")
        case let .slotted(selector):
            dest.write("::slotted(")
            selector.serialize(dest: &dest)
            dest.write(")")
        case let .part(names):
            dest.write("::part(")
            for (i, name) in names.enumerated() {
                if i > 0 { dest.write(" ") }
                dest.write(name)
            }
            dest.write(")")
        case .viewTransition:
            dest.write("::view-transition")
        case let .viewTransitionGroup(name):
            dest.write("::view-transition-group(")
            dest.write(name ?? "*")
            dest.write(")")
        case let .viewTransitionImagePair(name):
            dest.write("::view-transition-image-pair(")
            dest.write(name ?? "*")
            dest.write(")")
        case let .viewTransitionOld(name):
            dest.write("::view-transition-old(")
            dest.write(name ?? "*")
            dest.write(")")
        case let .viewTransitionNew(name):
            dest.write("::view-transition-new(")
            dest.write(name ?? "*")
            dest.write(")")
        case .webkitScrollbar:
            dest.write("::-webkit-scrollbar")
        case .webkitScrollbarButton:
            dest.write("::-webkit-scrollbar-button")
        case .webkitScrollbarTrack:
            dest.write("::-webkit-scrollbar-track")
        case .webkitScrollbarTrackPiece:
            dest.write("::-webkit-scrollbar-track-piece")
        case .webkitScrollbarThumb:
            dest.write("::-webkit-scrollbar-thumb")
        case .webkitScrollbarCorner:
            dest.write("::-webkit-scrollbar-corner")
        case .webkitResizer:
            dest.write("::-webkit-resizer")
        case let .custom(name):
            dest.write("::")
            dest.write(name)
        case let .customFunction(name, args):
            dest.write("::")
            dest.write(name)
            dest.write("(")
            dest.write(args)
            dest.write(")")
        }
    }
}
