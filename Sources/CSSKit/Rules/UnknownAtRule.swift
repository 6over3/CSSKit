// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// An unknown at-rule, stored as raw tokens.
public struct UnknownAtRule: Equatable, Sendable, Hashable {
    /// The name of the at-rule (without the @).
    public let name: String

    /// The prelude of the rule (raw text).
    public let prelude: String

    /// The contents of the block, if any (raw text).
    public let block: String?

    /// The location of the rule in the source file.
    public let location: SourceLocation

    /// Creates an unknown at-rule.
    public init(name: String, prelude: String, block: String?, location: SourceLocation = .init()) {
        self.name = name
        self.prelude = prelude
        self.block = block
        self.location = location
    }
}

// MARK: - Serialization

extension UnknownAtRule: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("@")
        dest.write(name)

        if !prelude.isEmpty {
            dest.write(" ")
            dest.write(prelude)
        }

        if let block {
            dest.write(" {\n")
            dest.write(block)
            dest.write("\n}")
        } else {
            dest.write(";")
        }
    }
}
