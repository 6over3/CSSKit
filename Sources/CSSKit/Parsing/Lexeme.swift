// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

final class LexemeStorage: @unchecked Sendable {
    enum Value {
        case borrowed(Substring)
        case owned(String)
    }

    var value: Value

    init(borrowed substring: Substring) {
        value = .borrowed(substring)
    }

    init(owned string: String) {
        value = .owned(string)
    }

    func copy() -> LexemeStorage {
        switch value {
        case let .borrowed(substring):
            LexemeStorage(borrowed: substring)
        case let .owned(string):
            LexemeStorage(owned: string)
        }
    }
}

/// A copy-on-write string that borrows from input when possible.
public struct Lexeme: Sendable {
    var storage: LexemeStorage

    /// Creates a Lexeme borrowing from a Substring (zero-copy).

    public init(_ substring: Substring) {
        storage = LexemeStorage(borrowed: substring)
    }

    /// Creates a Lexeme owning a String (allocates if escapes were processed).

    public init(owned string: String) {
        storage = LexemeStorage(owned: string)
    }

    /// Creates a Lexeme from a String literal.

    public init(_ string: String) {
        storage = LexemeStorage(owned: string)
    }

    /// Creates an empty Lexeme.

    public init() {
        storage = LexemeStorage(borrowed: Substring())
    }

    /// Access the underlying string value (read-only, no copy).

    public var value: String {
        switch storage.value {
        case let .borrowed(substring):
            String(substring)
        case let .owned(string):
            string
        }
    }

    /// Mutate the underlying string value with copy-on-write semantics.
    /// If this Lexeme shares storage with another instance, a copy is made first.

    public mutating func setValue(_ newValue: String) {
        if !isKnownUniquelyReferenced(&storage) {
            storage = LexemeStorage(owned: newValue)
        } else {
            storage.value = .owned(newValue)
        }
    }

    /// Returns true if this is an empty string.

    public var isEmpty: Bool {
        switch storage.value {
        case let .borrowed(substring):
            substring.isEmpty
        case let .owned(string):
            string.isEmpty
        }
    }

    /// Returns true if this Lexeme is borrowing from input (zero-copy).

    public var isBorrowed: Bool {
        if case .borrowed = storage.value {
            return true
        }
        return false
    }

    /// Returns true if this Lexeme owns its string data.

    public var isOwned: Bool {
        if case .owned = storage.value {
            return true
        }
        return false
    }

    /// The number of UTF-8 bytes.

    public var utf8Count: Int {
        switch storage.value {
        case let .borrowed(substring):
            substring.utf8.count
        case let .owned(string):
            string.utf8.count
        }
    }

    /// Access as Substring (may allocate if owned).

    public var asSubstring: Substring {
        switch storage.value {
        case let .borrowed(substring):
            substring
        case let .owned(string):
            Substring(string)
        }
    }
}

// MARK: - Equatable

extension Lexeme: Equatable {
    public static func == (lhs: Lexeme, rhs: Lexeme) -> Bool {
        // Compare by value, not by reference
        switch (lhs.storage.value, rhs.storage.value) {
        case let (.borrowed(lhs), .borrowed(rhs)):
            lhs == rhs
        case let (.owned(lhs), .owned(rhs)):
            lhs == rhs
        case let (.borrowed(lhs), .owned(rhs)):
            lhs == rhs[...]
        case let (.owned(lhs), .borrowed(rhs)):
            lhs[...] == rhs
        }
    }
}

// MARK: - Hashable

extension Lexeme: Hashable {
    public func hash(into hasher: inout Hasher) {
        // Hash the string value regardless of borrowed/owned
        switch storage.value {
        case let .borrowed(substring):
            hasher.combine(substring)
        case let .owned(string):
            hasher.combine(string)
        }
    }
}

// MARK: - ExpressibleByStringLiteral

extension Lexeme: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        storage = LexemeStorage(owned: value)
    }
}

// MARK: - CustomStringConvertible

extension Lexeme: CustomStringConvertible {
    public var description: String {
        value
    }
}

// MARK: - CustomDebugStringConvertible

extension Lexeme: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch storage.value {
        case let .borrowed(substring):
            "Lexeme.borrowed(\"\(substring)\")"
        case let .owned(string):
            "Lexeme.owned(\"\(string)\")"
        }
    }
}

// MARK: - StringProtocol-like methods

public extension Lexeme {
    /// Returns true if the string equals the given value, ignoring ASCII case.

    func eqIgnoreAsciiCase(_ other: String) -> Bool {
        let selfValue = value
        guard selfValue.utf8.count == other.utf8.count else { return false }
        return selfValue.lowercased() == other.lowercased()
    }

    /// Returns true if the string starts with the given prefix.

    func hasPrefix(_ prefix: String) -> Bool {
        switch storage.value {
        case let .borrowed(substring):
            substring.hasPrefix(prefix)
        case let .owned(string):
            string.hasPrefix(prefix)
        }
    }

    /// Returns true if the string ends with the given suffix.

    func hasSuffix(_ suffix: String) -> Bool {
        switch storage.value {
        case let .borrowed(substring):
            substring.hasSuffix(suffix)
        case let .owned(string):
            string.hasSuffix(suffix)
        }
    }

    /// Returns a Lexeme with the leading characters dropped.

    func dropFirst(_ count: Int = 1) -> Lexeme {
        switch storage.value {
        case let .borrowed(substring):
            Lexeme(substring.dropFirst(count))
        case let .owned(string):
            Lexeme(owned: String(string.dropFirst(count)))
        }
    }

    /// Lowercased version of the string.

    func lowercased() -> String {
        value.lowercased()
    }

    /// Uppercased version of the string.

    func uppercased() -> String {
        value.uppercased()
    }
}

// MARK: - Comparable

extension Lexeme: Comparable {
    public static func < (lhs: Lexeme, rhs: Lexeme) -> Bool {
        lhs.value < rhs.value
    }
}
