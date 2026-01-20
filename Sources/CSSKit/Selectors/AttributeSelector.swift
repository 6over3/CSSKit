// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// Operators for attribute selectors.
public enum AttributeSelectorOperator: Equatable, Sendable, Hashable {
    /// `=` - Exact match
    case equal

    /// `~=` - Word match
    case includes

    /// `|=` - Prefix match with dash
    case dashMatch

    /// `^=` - Starts with
    case prefix

    /// `$=` - Ends with
    case suffix

    /// `*=` - Contains substring
    case substring
}

extension AttributeSelectorOperator: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case .equal:
            dest.write("=")
        case .includes:
            dest.write("~=")
        case .dashMatch:
            dest.write("|=")
        case .prefix:
            dest.write("^=")
        case .suffix:
            dest.write("$=")
        case .substring:
            dest.write("*=")
        }
    }
}

/// Case sensitivity for attribute value matching.
public enum AttributeCaseSensitivity: Equatable, Sendable, Hashable {
    /// Case sensitive matching
    case caseSensitive

    /// ASCII case insensitive matching
    case asciiCaseInsensitive

    /// Case sensitive if in HTML element in HTML document
    case caseSensitiveIfHtmlElement
}

/// Namespace constraint for attribute selectors.
public enum NamespaceConstraint: Equatable, Sendable, Hashable {
    /// Any namespace
    case any

    /// No namespace
    case none

    /// Specific namespace URL
    case specific(String)
}

/// An attribute selector like `[href]`, `[type="text"]`, or `[class~="foo" i]`.
public struct AttributeSelector: Equatable, Sendable, Hashable {
    /// The attribute name
    public let name: String

    /// The lowercase version of the attribute name
    public let nameLower: String

    /// Namespace constraint
    public let namespace: NamespaceConstraint?

    /// The operation to perform
    public let operation: AttributeOperation?

    /// Whether this selector can never match
    public let neverMatches: Bool

    public init(
        name: String,
        nameLower: String? = nil,
        namespace: NamespaceConstraint? = nil,
        operation: AttributeOperation? = nil
    ) {
        self.name = name
        self.nameLower = nameLower ?? name.lowercased()
        self.namespace = namespace
        self.operation = operation

        // Check for never-matching patterns
        if let op = operation {
            switch op.operator {
            case .includes, .substring:
                // ~= and *= with empty string never match
                neverMatches = op.value.isEmpty
            default:
                neverMatches = false
            }
        } else {
            neverMatches = false
        }
    }

    /// Creates an existence-only attribute selector `[attr]`
    public static func exists(name: String, namespace: NamespaceConstraint? = nil) -> Self {
        Self(name: name, namespace: namespace, operation: nil)
    }
}

/// The operation part of an attribute selector (operator + value + case sensitivity).
public struct AttributeOperation: Equatable, Sendable, Hashable {
    /// The comparison operator
    public let `operator`: AttributeSelectorOperator

    /// The value to compare against
    public let value: String

    /// Case sensitivity for the comparison
    public let caseSensitivity: AttributeCaseSensitivity

    public init(
        operator: AttributeSelectorOperator,
        value: String,
        caseSensitivity: AttributeCaseSensitivity = .caseSensitiveIfHtmlElement
    ) {
        self.operator = `operator`
        self.value = value
        self.caseSensitivity = caseSensitivity
    }
}

// MARK: - Serialization

extension AttributeSelector: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("[")

        // Namespace prefix
        if let ns = namespace {
            switch ns {
            case .any:
                dest.write("*|")
            case .none:
                dest.write("|")
            case let .specific(prefix):
                dest.write(prefix)
                dest.write("|")
            }
        }

        // Attribute name
        dest.write(name)

        // Operation
        if let op = operation {
            op.operator.serialize(dest: &dest)
            dest.write("\"")
            // Escape the value for CSS string
            for char in op.value {
                switch char {
                case "\"":
                    dest.write("\\\"")
                case "\\":
                    dest.write("\\\\")
                case "\n":
                    dest.write("\\n")
                default:
                    dest.write(String(char))
                }
            }
            dest.write("\"")

            // Case sensitivity flag
            switch op.caseSensitivity {
            case .asciiCaseInsensitive:
                dest.write(" i")
            case .caseSensitive:
                dest.write(" s")
            case .caseSensitiveIfHtmlElement:
                // Default, no flag needed
                break
            }
        }

        dest.write("]")
    }
}
