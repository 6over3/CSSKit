// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A position from the start of the input, counted in UTF-8 bytes.
public struct SourcePosition: Equatable, Comparable, Hashable, Sendable {
    /// The byte index in the original input.
    public let byteIndex: Int

    public init(_ byteIndex: Int) {
        self.byteIndex = byteIndex
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.byteIndex < rhs.byteIndex
    }
}

/// The line and column number for a given position within the input.
public struct SourceLocation: Equatable, Hashable, Sendable {
    /// The line number, starting at 0 for the first line.
    public var line: UInt32

    /// The column number within a line, starting at 1 for the first character of the line.
    /// Column numbers are counted in UTF-16 code units.
    public var column: UInt32

    /// The source file this location refers to, if known.
    public var sourceFile: String?

    public init() {
        line = 0
        column = 0
        sourceFile = nil
    }

    public init(line: UInt32 = 0, column: UInt32 = 1, sourceFile: String? = nil) {
        self.line = line
        self.column = column
        self.sourceFile = sourceFile
    }
}

extension SourceLocation: CustomDebugStringConvertible {
    public var debugDescription: String {
        if let file = sourceFile {
            return "SourceLocation(\(file):\(line):\(column))"
        }
        return "SourceLocation(line: \(line), column: \(column))"
    }
}
