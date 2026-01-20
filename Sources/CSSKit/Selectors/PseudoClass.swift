// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// The type of :nth- pseudo-class
public enum NthType: Equatable, Sendable, Hashable {
    case child
    case lastChild
    case onlyChild
    case ofType
    case lastOfType
    case onlyOfType
    case col
    case lastCol

    public var isOnly: Bool {
        self == .onlyChild || self == .onlyOfType
    }

    public var isOfType: Bool {
        self == .ofType || self == .lastOfType || self == .onlyOfType
    }

    public var isFromEnd: Bool {
        self == .lastChild || self == .lastOfType || self == .lastCol
    }

    public var allowsOfSelector: Bool {
        self == .child || self == .lastChild
    }
}

/// Data for :nth- pseudo-classes (e.g., nth-child(2n+1))
public struct NthSelectorData: Equatable, Sendable, Hashable {
    public let type: NthType
    public let a: Int32
    public let b: Int32

    public init(type: NthType, a: Int32, b: Int32) {
        self.type = type
        self.a = a
        self.b = b
    }

    /// Creates data for :first-child or :first-of-type
    public static func first(ofType: Bool) -> Self {
        Self(type: ofType ? .ofType : .child, a: 0, b: 1)
    }

    /// Creates data for :last-child or :last-of-type
    public static func last(ofType: Bool) -> Self {
        Self(type: ofType ? .lastOfType : .lastChild, a: 0, b: 1)
    }

    /// Creates data for :only-child or :only-of-type
    public static func only(ofType: Bool) -> Self {
        Self(type: ofType ? .onlyOfType : .onlyChild, a: 0, b: 1)
    }

    /// Whether this is a functional form
    public var isFunction: Bool {
        a != 0 || b != 1
    }
}

/// Direction for :dir() pseudo-class
public enum Direction: String, Equatable, Sendable, Hashable {
    case ltr
    case rtl
}

/// CSS pseudo-classes
public indirect enum PseudoClass: Equatable, Sendable, Hashable {
    // MARK: - Tree-structural pseudo-classes

    /// :root
    case root

    /// :empty
    case empty

    /// :scope
    case scope

    /// :first-child, :last-child, :only-child, :nth-child(), etc.
    case nth(NthSelectorData)

    /// :nth-child(An+B of S) - Selectors Level 4
    case nthOf(NthSelectorData, SelectorList)

    // MARK: - Logical pseudo-classes

    /// :not(S)
    case not(SelectorList)

    /// :is(S)
    case `is`(SelectorList)

    /// :where(S) - zero specificity
    case `where`(SelectorList)

    /// :has(S) - relational pseudo-class
    case has(SelectorList)

    /// :-webkit-any(S), :-moz-any(S)
    case any(String, SelectorList) // prefix, selectors

    // MARK: - User action pseudo-classes

    /// :hover
    case hover

    /// :active
    case active

    /// :focus
    case focus

    /// :focus-visible
    case focusVisible

    /// :focus-within
    case focusWithin

    // MARK: - Link pseudo-classes

    /// :link
    case link

    /// :visited
    case visited

    /// :any-link
    case anyLink

    /// :local-link
    case localLink

    /// :target
    case target

    /// :target-within
    case targetWithin

    // MARK: - Input pseudo-classes

    /// :enabled
    case enabled

    /// :disabled
    case disabled

    /// :read-only
    case readOnly

    /// :read-write
    case readWrite

    /// :placeholder-shown
    case placeholderShown

    /// :default
    case `default`

    /// :checked
    case checked

    /// :indeterminate
    case indeterminate

    /// :blank
    case blank

    /// :valid
    case valid

    /// :invalid
    case invalid

    /// :in-range
    case inRange

    /// :out-of-range
    case outOfRange

    /// :required
    case required

    /// :optional
    case optional

    /// :user-valid
    case userValid

    /// :user-invalid
    case userInvalid

    /// :autofill
    case autofill

    // MARK: - Language pseudo-classes

    /// :lang(en)
    case lang([String])

    /// :dir(ltr) or :dir(rtl)
    case dir(Direction)

    // MARK: - Shadow DOM pseudo-classes

    /// :host or :host(S)
    case host(Selector?)

    /// :host-context(S)
    case hostContext(Selector)

    /// :defined
    case defined

    // MARK: - Fullscreen/modal pseudo-classes

    /// :fullscreen
    case fullscreen

    /// :modal
    case modal

    /// :picture-in-picture
    case pictureInPicture

    // MARK: - Media pseudo-classes

    /// :playing
    case playing

    /// :paused
    case paused

    /// :seeking
    case seeking

    /// :buffering
    case buffering

    /// :stalled
    case stalled

    /// :muted
    case muted

    /// :volume-locked
    case volumeLocked

    // MARK: - Time pseudo-classes

    /// :current
    case current

    /// :current(S)
    case currentSelector(SelectorList)

    /// :past
    case past

    /// :future
    case future

    // MARK: - Page pseudo-classes

    /// :left
    case left

    /// :right
    case right

    /// :first
    case firstPage

    /// :blank
    case blankPage

    // MARK: - Popover pseudo-class

    /// :popover-open
    case popoverOpen

    // MARK: - Custom/unknown pseudo-classes

    /// Unknown pseudo-class
    case custom(String)

    /// Unknown functional pseudo-class
    case customFunction(String, String)

    public var isActiveOrHover: Bool {
        self == .active || self == .hover
    }

    public var isUserActionState: Bool {
        switch self {
        case .hover, .active, .focus, .focusVisible, .focusWithin:
            true
        default:
            false
        }
    }

    public var isValidBeforeWebkitScrollbar: Bool {
        !isUserActionState
    }

    public var isValidAfterWebkitScrollbar: Bool {
        switch self {
        case .hover, .active, .focus:
            return true
        case .enabled, .disabled:
            return true
        case .nth:
            // :first-child, :last-child, etc. are valid
            return true
        case let .custom(name):
            // WebKit-specific pseudo-classes
            let lower = name.lowercased()
            return lower == "horizontal" || lower == "vertical" ||
                lower == "decrement" || lower == "increment" ||
                lower == "start" || lower == "end" ||
                lower == "double-button" || lower == "single-button" ||
                lower == "no-button" || lower == "corner-present" ||
                lower == "window-inactive"
        default:
            return false
        }
    }

    public var isValidAfterViewTransition: Bool {
        switch self {
        case let .nth(data):
            data.type.isOnly
        default:
            false
        }
    }

    public var isValidAfterPseudoElement: Bool {
        false
    }

    public var isTreeStructural: Bool {
        switch self {
        case .root, .empty, .scope, .nth, .nthOf:
            true
        default:
            false
        }
    }

    public var containsSelectors: Bool {
        switch self {
        case .not, .is, .where, .has, .any, .nthOf, .host, .hostContext, .currentSelector:
            true
        default:
            false
        }
    }
}

// MARK: - Serialization

extension NthSelectorData: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        let isFunction = isFunction

        switch type {
        case .child:
            dest.write(isFunction ? ":nth-child(" : ":first-child")
        case .lastChild:
            dest.write(isFunction ? ":nth-last-child(" : ":last-child")
        case .onlyChild:
            dest.write(":only-child")
            return
        case .ofType:
            dest.write(isFunction ? ":nth-of-type(" : ":first-of-type")
        case .lastOfType:
            dest.write(isFunction ? ":nth-last-of-type(" : ":last-of-type")
        case .onlyOfType:
            dest.write(":only-of-type")
            return
        case .col:
            dest.write(":nth-col(")
        case .lastCol:
            dest.write(":nth-last-col(")
        }

        if isFunction {
            serializeAnB(a: a, b: b, dest: &dest)
            dest.write(")")
        }
    }
}

/// Serialize An+B notation
private func serializeAnB(a: Int32, b: Int32, dest: inout some CSSWriter) {
    switch (a, b) {
    case (0, 0):
        dest.write("0")
    case (1, 0):
        dest.write("n")
    case (-1, 0):
        dest.write("-n")
    case (_, 0):
        dest.write("\(a)n")
    case (2, 1):
        dest.write("odd")
    case (0, _):
        dest.write("\(b)")
    case (1, _) where b > 0:
        dest.write("n+\(b)")
    case (1, _):
        dest.write("n\(b)")
    case (-1, _) where b > 0:
        dest.write("-n+\(b)")
    case (-1, _):
        dest.write("-n\(b)")
    case (_, _) where b > 0:
        dest.write("\(a)n+\(b)")
    default:
        dest.write("\(a)n\(b)")
    }
}

extension PseudoClass: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .root:
            dest.write(":root")
        case .empty:
            dest.write(":empty")
        case .scope:
            dest.write(":scope")
        case let .nth(data):
            data.serialize(dest: &dest)
        case let .nthOf(data, selectors):
            let isFunction = data.isFunction
            switch data.type {
            case .child:
                dest.write(":nth-child(")
            case .lastChild:
                dest.write(":nth-last-child(")
            default:
                fatalError(":nth-of with of-selector requires child or lastChild type")
            }
            if isFunction {
                serializeAnB(a: data.a, b: data.b, dest: &dest)
            } else {
                dest.write("1")
            }
            dest.write(" of ")
            selectors.serialize(dest: &dest)
            dest.write(")")
        case let .not(selectors):
            dest.write(":not(")
            selectors.serialize(dest: &dest)
            dest.write(")")
        case let .is(selectors):
            dest.write(":is(")
            selectors.serialize(dest: &dest)
            dest.write(")")
        case let .where(selectors):
            dest.write(":where(")
            selectors.serialize(dest: &dest)
            dest.write(")")
        case let .has(selectors):
            dest.write(":has(")
            selectors.serialize(dest: &dest)
            dest.write(")")
        case let .any(prefix, selectors):
            dest.write(":")
            dest.write(prefix)
            dest.write("any(")
            selectors.serialize(dest: &dest)
            dest.write(")")
        case .hover:
            dest.write(":hover")
        case .active:
            dest.write(":active")
        case .focus:
            dest.write(":focus")
        case .focusVisible:
            dest.write(":focus-visible")
        case .focusWithin:
            dest.write(":focus-within")
        case .link:
            dest.write(":link")
        case .visited:
            dest.write(":visited")
        case .anyLink:
            dest.write(":any-link")
        case .localLink:
            dest.write(":local-link")
        case .target:
            dest.write(":target")
        case .targetWithin:
            dest.write(":target-within")
        case .enabled:
            dest.write(":enabled")
        case .disabled:
            dest.write(":disabled")
        case .readOnly:
            dest.write(":read-only")
        case .readWrite:
            dest.write(":read-write")
        case .placeholderShown:
            dest.write(":placeholder-shown")
        case .default:
            dest.write(":default")
        case .checked:
            dest.write(":checked")
        case .indeterminate:
            dest.write(":indeterminate")
        case .blank:
            dest.write(":blank")
        case .valid:
            dest.write(":valid")
        case .invalid:
            dest.write(":invalid")
        case .inRange:
            dest.write(":in-range")
        case .outOfRange:
            dest.write(":out-of-range")
        case .required:
            dest.write(":required")
        case .optional:
            dest.write(":optional")
        case .userValid:
            dest.write(":user-valid")
        case .userInvalid:
            dest.write(":user-invalid")
        case .autofill:
            dest.write(":autofill")
        case let .lang(langs):
            dest.write(":lang(")
            for (i, lang) in langs.enumerated() {
                if i > 0 { dest.write(", ") }
                dest.write(lang)
            }
            dest.write(")")
        case let .dir(dir):
            dest.write(":dir(")
            dest.write(dir.rawValue)
            dest.write(")")
        case let .host(selector):
            if let sel = selector {
                dest.write(":host(")
                sel.serialize(dest: &dest)
                dest.write(")")
            } else {
                dest.write(":host")
            }
        case let .hostContext(selector):
            dest.write(":host-context(")
            selector.serialize(dest: &dest)
            dest.write(")")
        case .defined:
            dest.write(":defined")
        case .fullscreen:
            dest.write(":fullscreen")
        case .modal:
            dest.write(":modal")
        case .pictureInPicture:
            dest.write(":picture-in-picture")
        case .playing:
            dest.write(":playing")
        case .paused:
            dest.write(":paused")
        case .seeking:
            dest.write(":seeking")
        case .buffering:
            dest.write(":buffering")
        case .stalled:
            dest.write(":stalled")
        case .muted:
            dest.write(":muted")
        case .volumeLocked:
            dest.write(":volume-locked")
        case .current:
            dest.write(":current")
        case let .currentSelector(selectors):
            dest.write(":current(")
            selectors.serialize(dest: &dest)
            dest.write(")")
        case .past:
            dest.write(":past")
        case .future:
            dest.write(":future")
        case .left:
            dest.write(":left")
        case .right:
            dest.write(":right")
        case .firstPage:
            dest.write(":first")
        case .blankPage:
            dest.write(":blank")
        case .popoverOpen:
            dest.write(":popover-open")
        case let .custom(name):
            dest.write(":")
            dest.write(name)
        case let .customFunction(name, args):
            dest.write(":")
            dest.write(name)
            dest.write("(")
            dest.write(args)
            dest.write(")")
        }
    }
}
