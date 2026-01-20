// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// Parses the *An+B* notation, returning `(A, B)`.
func parseNth(_ input: Parser) -> Result<(Int32, Int32), BasicParseError> {
    switch input.next() {
    case let .failure(error):
        return .failure(error)

    case let .success(.number(numeric)):
        guard let offset = numeric.intValue else {
            return .failure(input.newBasicError(.endOfInput))
        }
        return .success((0, offset))

    case let .success(.dimension(numeric, unit)):
        guard let step = numeric.intValue else {
            return .failure(input.newBasicError(.endOfInput))
        }
        let unitStr = unit.value

        if unitStr.lowercased() == "n" {
            return parseB(input, step: step)
        } else if unitStr.lowercased() == "n-" {
            return parseSignlessB(input, step: step, offsetSign: -1)
        } else {
            if let offset = parseNDashDigits(unitStr) {
                return .success((step, offset))
            } else {
                return .failure(input.newBasicUnexpectedTokenError(.ident(unit)))
            }
        }

    case let .success(.ident(value)):
        let valueStr = value.value

        switch valueStr.lowercased() {
        case "even":
            return .success((2, 0))
        case "odd":
            return .success((2, 1))
        case "n":
            return parseB(input, step: 1)
        case "-n":
            return parseB(input, step: -1)
        case "n-":
            return parseSignlessB(input, step: 1, offsetSign: -1)
        case "-n-":
            return parseSignlessB(input, step: -1, offsetSign: -1)
        default:
            let (slice, step): (String, Int32)
            if valueStr.hasPrefix("-") {
                slice = String(valueStr.dropFirst())
                step = -1
            } else {
                slice = valueStr
                step = 1
            }

            if let offset = parseNDashDigits(slice) {
                return .success((step, offset))
            } else {
                return .failure(input.newBasicUnexpectedTokenError(.ident(value)))
            }
        }

    case .success(.delim("+")):
        switch input.nextIncludingWhitespace() {
        case let .failure(error):
            return .failure(error)

        case let .success(.ident(value)):
            let valueStr = value.value

            switch valueStr.lowercased() {
            case "n":
                return parseB(input, step: 1)
            case "n-":
                return parseSignlessB(input, step: 1, offsetSign: -1)
            default:
                if let offset = parseNDashDigits(valueStr) {
                    return .success((1, offset))
                } else {
                    return .failure(input.newBasicUnexpectedTokenError(.ident(value)))
                }
            }

        case let .success(token):
            return .failure(input.newBasicUnexpectedTokenError(token))
        }

    case let .success(token):
        return .failure(input.newBasicUnexpectedTokenError(token))
    }
}

/// Parses the B value in "An+B" after we've parsed "An".
private func parseB(_ input: Parser, step: Int32) -> Result<(Int32, Int32), BasicParseError> {
    let start = input.state()

    switch input.next() {
    case .success(.delim("+")):
        return parseSignlessB(input, step: step, offsetSign: 1)

    case .success(.delim("-")):
        return parseSignlessB(input, step: step, offsetSign: -1)

    case let .success(.number(numeric)) where numeric.hasSign:
        guard let offset = numeric.intValue else {
            input.reset(start)
            return .success((step, 0))
        }
        return .success((step, offset))

    default:
        input.reset(start)
        return .success((step, 0))
    }
}

/// Parses a signless B value.
private func parseSignlessB(_ input: Parser, step: Int32, offsetSign: Int32) -> Result<(Int32, Int32), BasicParseError> {
    switch input.next() {
    case let .failure(error):
        return .failure(error)

    case let .success(.number(numeric)) where !numeric.hasSign:
        guard let offset = numeric.intValue else {
            return .failure(input.newBasicError(.endOfInput))
        }
        return .success((step, offsetSign * offset))

    case let .success(token):
        return .failure(input.newBasicUnexpectedTokenError(token))
    }
}

/// Parses a string like "n-123" and extracts the number.
private func parseNDashDigits(_ string: String) -> Int32? {
    // Must be at least "n-X"
    guard string.count >= 3 else {
        return nil
    }

    let bytes = Array(string.utf8)

    // Check if it starts with "n-"
    guard bytes[0] == UInt8(ascii: "n") || bytes[0] == UInt8(ascii: "N"),
          bytes[1] == UInt8(ascii: "-")
    else {
        return nil
    }

    // Check that all remaining characters are digits
    for i in 2 ..< bytes.count {
        let byte = bytes[i]
        guard byte >= UInt8(ascii: "0"), byte <= UInt8(ascii: "9") else {
            return nil
        }
    }

    // Parse the number
    let numberStr = String(string.dropFirst()) // Drop the "n", keep "-123"
    return parseNumberSaturate(numberStr)
}

/// Parses a number string, saturating at Int32 bounds.
private func parseNumberSaturate(_ string: String) -> Int32? {
    let input = ParserInput(string)
    let parser = Parser(input)

    guard case let .success(.number(numeric)) = parser.nextIncludingWhitespaceAndComments(),
          let int = numeric.intValue
    else {
        return nil
    }

    guard parser.isExhausted else {
        return nil
    }

    return int
}
