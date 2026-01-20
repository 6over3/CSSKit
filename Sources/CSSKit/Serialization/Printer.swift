// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// Options for CSS output.
public struct PrinterOptions: Sendable {
    /// Whether to minify output (remove whitespace, newlines).
    public var minify: Bool

    /// Indentation size in spaces.
    public var indentWidth: Int

    /// Creates default printer options.
    public init(minify: Bool = false, indentWidth: Int = 2) {
        self.minify = minify
        self.indentWidth = indentWidth
    }
}

/// A printer for CSS output with formatting support.
public struct Printer: CSSWriter {
    /// The accumulated output.
    private var output: String = ""

    /// Current indentation level.
    private var indentLevel: Int = 0

    /// Whether to minify output.
    public let minify: Bool

    /// Indentation width in spaces.
    public let indentWidth: Int

    /// Current line number (for source maps).
    public private(set) var line: Int = 0

    /// Current column number.
    public private(set) var column: Int = 0

    /// Creates a new printer with the given options.
    public init(options: PrinterOptions = PrinterOptions()) {
        minify = options.minify
        indentWidth = options.indentWidth
    }

    /// The result string.
    public var result: String {
        output
    }

    // MARK: - CssWriter

    public mutating func write(_ str: String) {
        output += str
        // Track line/column for source maps
        for char in str {
            if char == "\n" {
                line += 1
                column = 0
            } else {
                column += 1
            }
        }
    }

    public mutating func write(_ char: Character) {
        output.append(char)
        if char == "\n" {
            line += 1
            column = 0
        } else {
            column += 1
        }
    }

    // MARK: - Formatting

    /// Write a space if not minifying.
    public mutating func whitespace() {
        if !minify {
            write(" ")
        }
    }

    /// Write a newline and indentation if not minifying.
    public mutating func newline() {
        if !minify {
            write("\n")
            writeIndent()
        }
    }

    /// Write current indentation.
    private mutating func writeIndent() {
        let spaces = String(repeating: " ", count: indentLevel * indentWidth)
        write(spaces)
    }

    /// Increase indentation level.
    public mutating func indent() {
        indentLevel += 1
    }

    /// Decrease indentation level.
    public mutating func dedent() {
        if indentLevel > 0 {
            indentLevel -= 1
        }
    }

    /// Write a delimiter with optional whitespace.
    public mutating func delim(_ char: Character, wsBefore: Bool = false) {
        if wsBefore {
            whitespace()
        }
        write(char)
        whitespace()
    }

    /// Write a colon with proper spacing.
    public mutating func colon() {
        write(":")
        whitespace()
    }

    /// Write a semicolon.
    public mutating func semicolon() {
        write(";")
    }

    /// Write an opening brace with proper formatting.
    public mutating func openBrace() {
        whitespace()
        write("{")
        indent()
    }

    /// Write a closing brace with proper formatting.
    public mutating func closeBrace() {
        dedent()
        newline()
        write("}")
    }
}

// MARK: - Convenience Extensions

public extension CSSSerializable {
    /// A string representation using default options.
    var string: String {
        string()
    }

    /// Returns a string representation with the given options.
    func string(options: PrinterOptions = .init()) -> String {
        var printer = Printer(options: options)
        serialize(dest: &printer)
        return printer.result
    }

    /// A minified string representation.
    var minified: String {
        string(options: .init(minify: true))
    }
}
