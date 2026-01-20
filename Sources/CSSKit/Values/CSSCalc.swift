// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

/// A protocol for values that can participate in calc() expressions.
public protocol CSSCalcValue: Equatable, Sendable, Hashable, CSSSerializable {
    /// Multiplies the value by a scalar.
    static func * (lhs: Self, rhs: Double) -> Self
}

/// Internal protocol for calc-parseable values.
protocol CSSCalcParseable: CSSCalcValue {
    static func parseCalcValue(_ input: Parser) -> Result<Self, BasicParseError>
}

/// A CSS calc() expression or math function. https://www.w3.org/TR/css-values-4/#calc-notation
public indirect enum CSSCalc<V: CSSCalcValue>: Equatable, Sendable {
    /// A concrete value.
    case value(V)

    /// A number literal within a calc expression.
    case number(Double)

    /// A sum of two calc expressions.
    case sum(CSSCalc<V>, CSSCalc<V>)

    /// A product of a calc expression and a number.
    case product(CSSCalc<V>, Double)

    /// A math function.
    case function(CSSMathFunction<V>)
}

/// CSS math functions.
/// https://www.w3.org/TR/css-values-4/#math
public indirect enum CSSMathFunction<V: CSSCalcValue>: Equatable, Sendable {
    /// calc() function - the basic math expression wrapper.
    case calc(CSSCalc<V>)

    /// min() function - returns the smallest value.
    case min([CSSCalc<V>])

    /// max() function - returns the largest value.
    case max([CSSCalc<V>])

    /// clamp() function - clamps a value between a minimum and maximum.
    case clamp(CSSCalc<V>, CSSCalc<V>, CSSCalc<V>)

    /// round() function - rounds a value according to a rounding strategy.
    case round(CSSRoundingStrategy, CSSCalc<V>, CSSCalc<V>)

    /// mod() function - returns the modulus.
    case mod(CSSCalc<V>, CSSCalc<V>)

    /// rem() function - returns the remainder.
    case rem(CSSCalc<V>, CSSCalc<V>)

    /// abs() function - returns the absolute value.
    case abs(CSSCalc<V>)

    /// sign() function - returns the sign (-1, 0, or 1).
    case sign(CSSCalc<V>)

    // Trigonometric functions

    /// sin() function.
    case sin(CSSCalc<V>)

    /// cos() function.
    case cos(CSSCalc<V>)

    /// tan() function.
    case tan(CSSCalc<V>)

    /// asin() function.
    case asin(CSSCalc<V>)

    /// acos() function.
    case acos(CSSCalc<V>)

    /// atan() function.
    case atan(CSSCalc<V>)

    /// atan2() function.
    case atan2(CSSCalc<V>, CSSCalc<V>)

    // Exponential functions

    /// pow() function - base raised to exponent power.
    case pow(CSSCalc<V>, CSSCalc<V>)

    /// sqrt() function.
    case sqrt(CSSCalc<V>)

    /// hypot() function - returns the square root of sum of squares.
    case hypot([CSSCalc<V>])

    /// log() function - logarithm.
    case log(CSSCalc<V>, CSSCalc<V>?)

    /// exp() function - e raised to a power.
    case exp(CSSCalc<V>)
}

/// Rounding strategy for round() function.
public enum CSSRoundingStrategy: String, Equatable, Sendable {
    /// Round to nearest (default).
    case nearest
    /// Round up (ceiling).
    case up
    /// Round down (floor).
    case down
    /// Round toward zero (truncate).
    case toZero = "to-zero"
}

// MARK: - Hashable

extension CSSCalc: Hashable where V: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .value(v):
            hasher.combine(0)
            hasher.combine(v)
        case let .number(n):
            hasher.combine(1)
            hasher.combine(n)
        case let .sum(a, b):
            hasher.combine(2)
            hasher.combine(a)
            hasher.combine(b)
        case let .product(a, b):
            hasher.combine(3)
            hasher.combine(a)
            hasher.combine(b)
        case let .function(f):
            hasher.combine(4)
            hasher.combine(f)
        }
    }
}

extension CSSMathFunction: Hashable where V: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .calc(c):
            hasher.combine(0)
            hasher.combine(c)
        case let .min(args):
            hasher.combine(1)
            hasher.combine(args)
        case let .max(args):
            hasher.combine(2)
            hasher.combine(args)
        case let .clamp(a, b, c):
            hasher.combine(3)
            hasher.combine(a)
            hasher.combine(b)
            hasher.combine(c)
        case let .round(s, a, b):
            hasher.combine(4)
            hasher.combine(s)
            hasher.combine(a)
            hasher.combine(b)
        case let .mod(a, b):
            hasher.combine(5)
            hasher.combine(a)
            hasher.combine(b)
        case let .rem(a, b):
            hasher.combine(6)
            hasher.combine(a)
            hasher.combine(b)
        case let .abs(a):
            hasher.combine(7)
            hasher.combine(a)
        case let .sign(a):
            hasher.combine(8)
            hasher.combine(a)
        case let .sin(a):
            hasher.combine(9)
            hasher.combine(a)
        case let .cos(a):
            hasher.combine(10)
            hasher.combine(a)
        case let .tan(a):
            hasher.combine(11)
            hasher.combine(a)
        case let .asin(a):
            hasher.combine(12)
            hasher.combine(a)
        case let .acos(a):
            hasher.combine(13)
            hasher.combine(a)
        case let .atan(a):
            hasher.combine(14)
            hasher.combine(a)
        case let .atan2(a, b):
            hasher.combine(15)
            hasher.combine(a)
            hasher.combine(b)
        case let .pow(a, b):
            hasher.combine(16)
            hasher.combine(a)
            hasher.combine(b)
        case let .sqrt(a):
            hasher.combine(17)
            hasher.combine(a)
        case let .hypot(args):
            hasher.combine(18)
            hasher.combine(args)
        case let .log(a, b):
            hasher.combine(19)
            hasher.combine(a)
            hasher.combine(b)
        case let .exp(a):
            hasher.combine(20)
            hasher.combine(a)
        }
    }
}

extension CSSRoundingStrategy: Hashable {}

// MARK: - Arithmetic

public extension CSSCalc {
    static func * (lhs: CSSCalc<V>, rhs: Double) -> CSSCalc<V> {
        .product(lhs, rhs)
    }
}

// MARK: - ToCss

extension CSSCalc: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .value(v):
            v.serialize(dest: &dest)

        case let .number(n):
            n.serialize(dest: &dest)

        case let .sum(a, b):
            dest.write("calc(")
            a.serialize(dest: &dest)
            dest.write(" + ")
            b.serialize(dest: &dest)
            dest.write(")")

        case let .product(a, b):
            dest.write("calc(")
            a.serialize(dest: &dest)
            dest.write(" * ")
            b.serialize(dest: &dest)
            dest.write(")")

        case let .function(f):
            f.serialize(dest: &dest)
        }
    }
}

extension CSSMathFunction: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .calc(c):
            dest.write("calc(")
            c.serialize(dest: &dest)
            dest.write(")")

        case let .min(args):
            dest.write("min(")
            for (i, arg) in args.enumerated() {
                if i > 0 { dest.write(", ") }
                arg.serialize(dest: &dest)
            }
            dest.write(")")

        case let .max(args):
            dest.write("max(")
            for (i, arg) in args.enumerated() {
                if i > 0 { dest.write(", ") }
                arg.serialize(dest: &dest)
            }
            dest.write(")")

        case let .clamp(min, val, max):
            dest.write("clamp(")
            min.serialize(dest: &dest)
            dest.write(", ")
            val.serialize(dest: &dest)
            dest.write(", ")
            max.serialize(dest: &dest)
            dest.write(")")

        case let .round(strategy, a, b):
            dest.write("round(")
            if strategy != .nearest {
                dest.write(strategy.rawValue)
                dest.write(", ")
            }
            a.serialize(dest: &dest)
            dest.write(", ")
            b.serialize(dest: &dest)
            dest.write(")")

        case let .mod(a, b):
            dest.write("mod(")
            a.serialize(dest: &dest)
            dest.write(", ")
            b.serialize(dest: &dest)
            dest.write(")")

        case let .rem(a, b):
            dest.write("rem(")
            a.serialize(dest: &dest)
            dest.write(", ")
            b.serialize(dest: &dest)
            dest.write(")")

        case let .abs(a):
            dest.write("abs(")
            a.serialize(dest: &dest)
            dest.write(")")

        case let .sign(a):
            dest.write("sign(")
            a.serialize(dest: &dest)
            dest.write(")")

        case let .sin(a):
            dest.write("sin(")
            a.serialize(dest: &dest)
            dest.write(")")

        case let .cos(a):
            dest.write("cos(")
            a.serialize(dest: &dest)
            dest.write(")")

        case let .tan(a):
            dest.write("tan(")
            a.serialize(dest: &dest)
            dest.write(")")

        case let .asin(a):
            dest.write("asin(")
            a.serialize(dest: &dest)
            dest.write(")")

        case let .acos(a):
            dest.write("acos(")
            a.serialize(dest: &dest)
            dest.write(")")

        case let .atan(a):
            dest.write("atan(")
            a.serialize(dest: &dest)
            dest.write(")")

        case let .atan2(a, b):
            dest.write("atan2(")
            a.serialize(dest: &dest)
            dest.write(", ")
            b.serialize(dest: &dest)
            dest.write(")")

        case let .pow(a, b):
            dest.write("pow(")
            a.serialize(dest: &dest)
            dest.write(", ")
            b.serialize(dest: &dest)
            dest.write(")")

        case let .sqrt(a):
            dest.write("sqrt(")
            a.serialize(dest: &dest)
            dest.write(")")

        case let .hypot(args):
            dest.write("hypot(")
            for (i, arg) in args.enumerated() {
                if i > 0 { dest.write(", ") }
                arg.serialize(dest: &dest)
            }
            dest.write(")")

        case let .log(a, b):
            dest.write("log(")
            a.serialize(dest: &dest)
            if let b {
                dest.write(", ")
                b.serialize(dest: &dest)
            }
            dest.write(")")

        case let .exp(a):
            dest.write("exp(")
            a.serialize(dest: &dest)
            dest.write(")")
        }
    }
}

// MARK: - CSSCalcValue Conformances

extension CSSDimensionPercentage: CSSCalcValue {}

// MARK: - Parsing

extension CSSCalc where V: CSSCalcParseable {
    static func parse(_ input: Parser) -> Result<CSSCalc<V>, BasicParseError> {
        parseWithIdent(input) { _ in nil }
    }

    static func parseWithIdent(
        _ input: Parser,
        _ parseIdent: @escaping (String) -> CSSCalc<V>?
    ) -> Result<CSSCalc<V>, BasicParseError> {
        let location = input.currentSourceLocation()

        guard case let .success(fnToken) = input.expectFunction() else {
            return .failure(location.newBasicError(.endOfInput))
        }

        let fnName = fnToken.value.lowercased()

        guard let (nested, blockType) = input.enterNestedBlock() else {
            return .failure(location.newBasicError(.endOfInput))
        }
        let result = parseCalcFunction(nested, fnName: fnName, parseIdent: parseIdent)
        input.finishNestedBlock(blockType)
        return result
    }

    private static func parseValueInternal(
        _ input: Parser,
        _ parseIdent: @escaping (String) -> CSSCalc<V>?
    ) -> Result<CSSCalc<V>, BasicParseError> {
        // Try nested calc/math function
        if case let .success(fnToken) = input.tryParse({ $0.expectFunction() }) {
            let fnName = fnToken.value.lowercased()
            guard let (nested, blockType) = input.enterNestedBlock() else {
                return .failure(input.newBasicError(.endOfInput))
            }
            let result = parseCalcFunction(nested, fnName: fnName, parseIdent: parseIdent)
            input.finishNestedBlock(blockType)
            switch result {
            case let .success(calc):
                if case let .function(.calc(inner)) = calc {
                    return .success(inner)
                }
                return .success(calc)
            case let .failure(error):
                return .failure(error)
            }
        }

        // Try parenthesized expression
        if case .success = input.tryParse({ $0.expectParenthesisBlock() }) {
            guard let (nested, blockType) = input.enterNestedBlock() else {
                return .failure(input.newBasicError(.endOfInput))
            }
            let result = parseSum(nested, parseIdent)
            input.finishNestedBlock(blockType)
            return result
        }

        // Try number
        if case let .success(num) = input.tryParse({ CSSNumber.parse($0) }) {
            return .success(.number(num))
        }

        // Try custom ident
        let state = input.state()
        if case let .success(ident) = input.tryParse({ $0.expectIdent() }) {
            if let value = parseIdent(ident.value) {
                return .success(value)
            }
            input.reset(state)
        }

        // Try the value type
        switch V.parseCalcValue(input) {
        case let .success(value):
            return .success(.value(value))
        case let .failure(error):
            return .failure(error)
        }
    }
}

// MARK: - Calc Parsing Helpers

private enum CalcParseOp {
    case add
    case subtract
    case multiply
    case divide
}

private struct CalcParseFrame<V: CSSCalcValue> {
    var parser: Parser
    var blockType: BlockType
    var fnName: String
    var sumLhs: CSSCalc<V>?
    var sumOp: CalcParseOp?
    var productLhs: CSSCalc<V>?
    var productOp: CalcParseOp?
    var phase: CalcParsePhase
}

private enum CalcParsePhase {
    case parseValue
    case afterValue
    case afterProduct
}

extension CSSCalc where V: CSSCalcParseable {
    fileprivate static func parseCalcFunction(
        _ startParser: Parser,
        fnName: String,
        parseIdent: @escaping (String) -> CSSCalc<V>?
    ) -> Result<CSSCalc<V>, BasicParseError> {
        // Handle non-calc functions that don't need deep iteration
        switch fnName {
        case "calc":
            parseSum(startParser, parseIdent)
        case "min", "max", "clamp", "round", "mod", "rem", "abs", "sign",
             "sin", "cos", "tan", "asin", "acos", "atan", "atan2",
             "pow", "sqrt", "hypot", "log", "exp":
            parseMathFunction(startParser, fnName: fnName, parseIdent: parseIdent)
        default:
            .failure(startParser.newBasicError(.endOfInput))
        }
    }

    fileprivate static func parseSum(
        _ startParser: Parser,
        _ parseIdent: @escaping (String) -> CSSCalc<V>?
    ) -> Result<CSSCalc<V>, BasicParseError> {
        var stack: [CalcParseFrame<V>] = []
        var parser = startParser
        var sumLhs: CSSCalc<V>?
        var sumOp: CalcParseOp?
        var productLhs: CSSCalc<V>?
        var productOp: CalcParseOp?
        var phase: CalcParsePhase = .parseValue

        while true {
            switch phase {
            case .parseValue:
                // Try nested function
                if case let .success(fnToken) = parser.tryParse({ $0.expectFunction() }) {
                    let fnName = fnToken.value.lowercased()
                    guard let (nested, blockType) = parser.enterNestedBlock() else {
                        return .failure(parser.newBasicError(.endOfInput))
                    }
                    stack.append(CalcParseFrame(
                        parser: parser, blockType: blockType, fnName: fnName,
                        sumLhs: sumLhs, sumOp: sumOp,
                        productLhs: productLhs, productOp: productOp,
                        phase: .afterValue
                    ))
                    parser = nested
                    sumLhs = nil
                    sumOp = nil
                    productLhs = nil
                    productOp = nil
                    phase = .parseValue
                    continue
                }

                // Try parenthesized expression
                if case .success = parser.tryParse({ $0.expectParenthesisBlock() }) {
                    guard let (nested, blockType) = parser.enterNestedBlock() else {
                        return .failure(parser.newBasicError(.endOfInput))
                    }
                    stack.append(CalcParseFrame(
                        parser: parser, blockType: blockType, fnName: "",
                        sumLhs: sumLhs, sumOp: sumOp,
                        productLhs: productLhs, productOp: productOp,
                        phase: .afterValue
                    ))
                    parser = nested
                    sumLhs = nil
                    sumOp = nil
                    productLhs = nil
                    productOp = nil
                    continue
                }

                // Try number
                if case let .success(num) = parser.tryParse({ CSSNumber.parse($0) }) {
                    let value: CSSCalc<V> = .number(num)
                    productLhs = applyProductOp(productLhs, productOp, value)
                    productOp = nil
                    phase = .afterValue
                    continue
                }

                // Try custom ident
                let identState = parser.state()
                if case let .success(ident) = parser.tryParse({ $0.expectIdent() }) {
                    if let value = parseIdent(ident.value) {
                        productLhs = applyProductOp(productLhs, productOp, value)
                        productOp = nil
                        phase = .afterValue
                        continue
                    }
                    parser.reset(identState)
                }

                // Try the value type
                switch V.parseCalcValue(parser) {
                case let .success(v):
                    let value: CSSCalc<V> = .value(v)
                    productLhs = applyProductOp(productLhs, productOp, value)
                    productOp = nil
                    phase = .afterValue
                case let .failure(error):
                    return .failure(error)
                }

            case .afterValue:
                let state = parser.state()
                guard case let .success(token) = parser.next() else {
                    phase = .afterProduct
                    continue
                }

                switch token {
                case .delim("*"):
                    productOp = .multiply
                    phase = .parseValue
                case .delim("/"):
                    productOp = .divide
                    phase = .parseValue
                default:
                    parser.reset(state)
                    phase = .afterProduct
                }

            case .afterProduct:
                guard let product = productLhs else {
                    return .failure(parser.newBasicError(.endOfInput))
                }
                sumLhs = applySumOp(sumLhs, sumOp, product)
                productLhs = nil
                sumOp = nil

                let state = parser.state()
                guard case let .success(token) = parser.nextIncludingWhitespace() else {
                    // End of input - check if we need to pop
                    if let frame = stack.popLast() {
                        let result = sumLhs!
                        let finalResult: CSSCalc<V> = if frame.fnName == "calc" || frame.fnName.isEmpty {
                            frame.fnName.isEmpty ? result : .function(.calc(result))
                        } else {
                            result
                        }
                        frame.parser.finishNestedBlock(frame.blockType)
                        parser = frame.parser
                        sumLhs = frame.sumLhs
                        sumOp = frame.sumOp
                        productLhs = applyProductOp(frame.productLhs, frame.productOp, finalResult)
                        productOp = nil
                        phase = .afterValue
                        continue
                    }
                    return .success(sumLhs!)
                }

                guard case .whiteSpace = token else {
                    parser.reset(state)
                    if let frame = stack.popLast() {
                        let result = sumLhs!
                        let finalResult: CSSCalc<V> = if frame.fnName == "calc" || frame.fnName.isEmpty {
                            frame.fnName.isEmpty ? result : .function(.calc(result))
                        } else {
                            result
                        }
                        frame.parser.finishNestedBlock(frame.blockType)
                        parser = frame.parser
                        sumLhs = frame.sumLhs
                        sumOp = frame.sumOp
                        productLhs = applyProductOp(frame.productLhs, frame.productOp, finalResult)
                        productOp = nil
                        phase = .afterValue
                        continue
                    }
                    return .success(sumLhs!)
                }

                if parser.isExhausted {
                    if let frame = stack.popLast() {
                        let result = sumLhs!
                        let finalResult: CSSCalc<V> = if frame.fnName == "calc" || frame.fnName.isEmpty {
                            frame.fnName.isEmpty ? result : .function(.calc(result))
                        } else {
                            result
                        }
                        frame.parser.finishNestedBlock(frame.blockType)
                        parser = frame.parser
                        sumLhs = frame.sumLhs
                        sumOp = frame.sumOp
                        productLhs = applyProductOp(frame.productLhs, frame.productOp, finalResult)
                        productOp = nil
                        phase = .afterValue
                        continue
                    }
                    return .success(sumLhs!)
                }

                guard case let .success(opToken) = parser.next() else {
                    parser.reset(state)
                    if let frame = stack.popLast() {
                        let result = sumLhs!
                        let finalResult: CSSCalc<V> = if frame.fnName == "calc" || frame.fnName.isEmpty {
                            frame.fnName.isEmpty ? result : .function(.calc(result))
                        } else {
                            result
                        }
                        frame.parser.finishNestedBlock(frame.blockType)
                        parser = frame.parser
                        sumLhs = frame.sumLhs
                        sumOp = frame.sumOp
                        productLhs = applyProductOp(frame.productLhs, frame.productOp, finalResult)
                        productOp = nil
                        phase = .afterValue
                        continue
                    }
                    return .success(sumLhs!)
                }

                switch opToken {
                case .delim("+"):
                    sumOp = .add
                    phase = .parseValue
                case .delim("-"):
                    sumOp = .subtract
                    phase = .parseValue
                default:
                    parser.reset(state)
                    if let frame = stack.popLast() {
                        let result = sumLhs!
                        let finalResult: CSSCalc<V> = if frame.fnName == "calc" || frame.fnName.isEmpty {
                            frame.fnName.isEmpty ? result : .function(.calc(result))
                        } else {
                            result
                        }
                        frame.parser.finishNestedBlock(frame.blockType)
                        parser = frame.parser
                        sumLhs = frame.sumLhs
                        sumOp = frame.sumOp
                        productLhs = applyProductOp(frame.productLhs, frame.productOp, finalResult)
                        productOp = nil
                        phase = .afterValue
                        continue
                    }
                    return .success(sumLhs!)
                }
            }
        }
    }

    private static func applyProductOp(
        _ lhs: CSSCalc<V>?,
        _ op: CalcParseOp?,
        _ rhs: CSSCalc<V>
    ) -> CSSCalc<V> {
        guard let lhs, let op else {
            return rhs
        }
        switch op {
        case .multiply:
            if case let .number(n) = rhs {
                return lhs * n
            } else if case let .number(n) = lhs {
                return rhs * n
            }
            return lhs // Invalid but don't crash
        case .divide:
            if case let .number(n) = rhs, n != 0 {
                return lhs * (1.0 / n)
            }
            return lhs // Invalid but don't crash
        default:
            return lhs
        }
    }

    private static func applySumOp(
        _ lhs: CSSCalc<V>?,
        _ op: CalcParseOp?,
        _ rhs: CSSCalc<V>
    ) -> CSSCalc<V> {
        guard let lhs, let op else {
            return rhs
        }
        switch op {
        case .add:
            return .sum(lhs, rhs)
        case .subtract:
            return .sum(lhs, rhs * -1.0)
        default:
            return lhs
        }
    }

    private static func parseMathFunction(
        _ parser: Parser,
        fnName: String,
        parseIdent: @escaping (String) -> CSSCalc<V>?
    ) -> Result<CSSCalc<V>, BasicParseError> {
        switch fnName {
        case "min":
            var args: [CSSCalc<V>] = []
            while true {
                switch parseSum(parser, parseIdent) {
                case let .success(arg):
                    args.append(arg)
                case let .failure(error):
                    if args.isEmpty { return .failure(error) }
                }
                if case .failure = parser.tryParse({ $0.expectComma() }) { break }
            }
            if args.isEmpty { return .failure(parser.newBasicError(.endOfInput)) }
            if args.count == 1 { return .success(args[0]) }
            return .success(.function(.min(args)))

        case "max":
            var args: [CSSCalc<V>] = []
            while true {
                switch parseSum(parser, parseIdent) {
                case let .success(arg):
                    args.append(arg)
                case let .failure(error):
                    if args.isEmpty { return .failure(error) }
                }
                if case .failure = parser.tryParse({ $0.expectComma() }) { break }
            }
            if args.isEmpty { return .failure(parser.newBasicError(.endOfInput)) }
            if args.count == 1 { return .success(args[0]) }
            return .success(.function(.max(args)))

        case "clamp":
            guard case let .success(min) = parseSum(parser, parseIdent),
                  case .success = parser.expectComma(),
                  case let .success(val) = parseSum(parser, parseIdent),
                  case .success = parser.expectComma(),
                  case let .success(max) = parseSum(parser, parseIdent)
            else {
                return .failure(parser.newBasicError(.endOfInput))
            }
            return .success(.function(.clamp(min, val, max)))

        case "round":
            var strategy: CSSRoundingStrategy = .nearest
            if case let .success(ident) = parser.tryParse({ $0.expectIdent() }) {
                switch ident.value.lowercased() {
                case "nearest": strategy = .nearest
                case "up": strategy = .up
                case "down": strategy = .down
                case "to-zero": strategy = .toZero
                default: break
                }
                _ = parser.tryParse { $0.expectComma() }
            }
            guard case let .success(val) = parseSum(parser, parseIdent),
                  case .success = parser.expectComma(),
                  case let .success(step) = parseSum(parser, parseIdent)
            else {
                return .failure(parser.newBasicError(.endOfInput))
            }
            return .success(.function(.round(strategy, val, step)))

        case "mod":
            guard case let .success(a) = parseSum(parser, parseIdent),
                  case .success = parser.expectComma(),
                  case let .success(b) = parseSum(parser, parseIdent)
            else {
                return .failure(parser.newBasicError(.endOfInput))
            }
            return .success(.function(.mod(a, b)))

        case "rem":
            guard case let .success(a) = parseSum(parser, parseIdent),
                  case .success = parser.expectComma(),
                  case let .success(b) = parseSum(parser, parseIdent)
            else {
                return .failure(parser.newBasicError(.endOfInput))
            }
            return .success(.function(.rem(a, b)))

        case "abs":
            guard case let .success(v) = parseSum(parser, parseIdent) else {
                return .failure(parser.newBasicError(.endOfInput))
            }
            return .success(.function(.abs(v)))

        case "sign":
            guard case let .success(v) = parseSum(parser, parseIdent) else {
                return .failure(parser.newBasicError(.endOfInput))
            }
            return .success(.function(.sign(v)))

        case "sin":
            guard case let .success(v) = parseSum(parser, parseIdent) else {
                return .failure(parser.newBasicError(.endOfInput))
            }
            return .success(.function(.sin(v)))

        case "cos":
            guard case let .success(v) = parseSum(parser, parseIdent) else {
                return .failure(parser.newBasicError(.endOfInput))
            }
            return .success(.function(.cos(v)))

        case "tan":
            guard case let .success(v) = parseSum(parser, parseIdent) else {
                return .failure(parser.newBasicError(.endOfInput))
            }
            return .success(.function(.tan(v)))

        case "asin":
            guard case let .success(v) = parseSum(parser, parseIdent) else {
                return .failure(parser.newBasicError(.endOfInput))
            }
            return .success(.function(.asin(v)))

        case "acos":
            guard case let .success(v) = parseSum(parser, parseIdent) else {
                return .failure(parser.newBasicError(.endOfInput))
            }
            return .success(.function(.acos(v)))

        case "atan":
            guard case let .success(v) = parseSum(parser, parseIdent) else {
                return .failure(parser.newBasicError(.endOfInput))
            }
            return .success(.function(.atan(v)))

        case "atan2":
            guard case let .success(y) = parseSum(parser, parseIdent),
                  case .success = parser.expectComma(),
                  case let .success(x) = parseSum(parser, parseIdent)
            else {
                return .failure(parser.newBasicError(.endOfInput))
            }
            return .success(.function(.atan2(y, x)))

        case "pow":
            guard case let .success(base) = parseSum(parser, parseIdent),
                  case .success = parser.expectComma(),
                  case let .success(exp) = parseSum(parser, parseIdent)
            else {
                return .failure(parser.newBasicError(.endOfInput))
            }
            return .success(.function(.pow(base, exp)))

        case "sqrt":
            guard case let .success(v) = parseSum(parser, parseIdent) else {
                return .failure(parser.newBasicError(.endOfInput))
            }
            return .success(.function(.sqrt(v)))

        case "hypot":
            var args: [CSSCalc<V>] = []
            while true {
                switch parseSum(parser, parseIdent) {
                case let .success(arg):
                    args.append(arg)
                case let .failure(error):
                    if args.isEmpty { return .failure(error) }
                }
                if case .failure = parser.tryParse({ $0.expectComma() }) { break }
            }
            return args.isEmpty ? .failure(parser.newBasicError(.endOfInput)) : .success(.function(.hypot(args)))

        case "log":
            guard case let .success(v) = parseSum(parser, parseIdent) else {
                return .failure(parser.newBasicError(.endOfInput))
            }
            if case .success = parser.tryParse({ $0.expectComma() }),
               case let .success(base) = parseSum(parser, parseIdent)
            {
                return .success(.function(.log(v, base)))
            }
            return .success(.function(.log(v, nil)))

        case "exp":
            guard case let .success(v) = parseSum(parser, parseIdent) else {
                return .failure(parser.newBasicError(.endOfInput))
            }
            return .success(.function(.exp(v)))

        default:
            return .failure(parser.newBasicError(.endOfInput))
        }
    }
}

// MARK: - Simplification

private enum CalcSimplifyWork<V: CSSCalcValue> {
    case calc(CSSCalc<V>)
    case mathFn(CSSMathFunction<V>)
    case combineSum
    case combineProduct(Double)
    case combineFunction
    case combineCalc
    case combineMin(Int)
    case combineMax(Int)
    case combineClamp
    case combineAbs
    case combineSign
    case combineRound(CSSRoundingStrategy)
    case combineMod
    case combineRem
    case combineSin
    case combineCos
    case combineTan
    case combineAsin
    case combineAcos
    case combineAtan
    case combineAtan2
    case combinePow
    case combineSqrt
    case combineHypot(Int)
    case combineLog(hasBase: Bool)
    case combineExp
}

private enum CalcSimplifyResult<V: CSSCalcValue> {
    case calc(CSSCalc<V>)
    case mathFn(CSSMathFunction<V>)

    var asCalc: CSSCalc<V> {
        switch self {
        case let .calc(c): c
        case let .mathFn(fn): .function(fn)
        }
    }
}

public extension CSSCalc {
    /// Returns a simplified version of this calc expression.
    func simplified() -> CSSCalc<V> {
        var work: [CalcSimplifyWork<V>] = [.calc(self)]
        var results: [CalcSimplifyResult<V>] = []

        while let item = work.popLast() {
            switch item {
            case let .calc(c):
                switch c {
                case .value, .number:
                    results.append(.calc(c))
                case let .sum(lhs, rhs):
                    work.append(.combineSum)
                    work.append(.calc(rhs))
                    work.append(.calc(lhs))
                case let .product(expr, mult):
                    work.append(.combineProduct(mult))
                    work.append(.calc(expr))
                case let .function(fn):
                    work.append(.combineFunction)
                    work.append(.mathFn(fn))
                }

            case let .mathFn(fn):
                switch fn {
                case let .calc(inner):
                    work.append(.combineCalc)
                    work.append(.calc(inner))
                case let .min(args):
                    work.append(.combineMin(args.count))
                    for arg in args.reversed() {
                        work.append(.calc(arg))
                    }
                case let .max(args):
                    work.append(.combineMax(args.count))
                    for arg in args.reversed() {
                        work.append(.calc(arg))
                    }
                case let .clamp(min, val, max):
                    work.append(.combineClamp)
                    work.append(.calc(max))
                    work.append(.calc(val))
                    work.append(.calc(min))
                case let .abs(inner):
                    work.append(.combineAbs)
                    work.append(.calc(inner))
                case let .sign(inner):
                    work.append(.combineSign)
                    work.append(.calc(inner))
                case let .round(strategy, val, interval):
                    work.append(.combineRound(strategy))
                    work.append(.calc(interval))
                    work.append(.calc(val))
                case let .mod(a, b):
                    work.append(.combineMod)
                    work.append(.calc(b))
                    work.append(.calc(a))
                case let .rem(a, b):
                    work.append(.combineRem)
                    work.append(.calc(b))
                    work.append(.calc(a))
                case let .sin(inner):
                    work.append(.combineSin)
                    work.append(.calc(inner))
                case let .cos(inner):
                    work.append(.combineCos)
                    work.append(.calc(inner))
                case let .tan(inner):
                    work.append(.combineTan)
                    work.append(.calc(inner))
                case let .asin(inner):
                    work.append(.combineAsin)
                    work.append(.calc(inner))
                case let .acos(inner):
                    work.append(.combineAcos)
                    work.append(.calc(inner))
                case let .atan(inner):
                    work.append(.combineAtan)
                    work.append(.calc(inner))
                case let .atan2(y, x):
                    work.append(.combineAtan2)
                    work.append(.calc(x))
                    work.append(.calc(y))
                case let .pow(base, exp):
                    work.append(.combinePow)
                    work.append(.calc(exp))
                    work.append(.calc(base))
                case let .sqrt(inner):
                    work.append(.combineSqrt)
                    work.append(.calc(inner))
                case let .hypot(args):
                    work.append(.combineHypot(args.count))
                    for arg in args.reversed() {
                        work.append(.calc(arg))
                    }
                case let .log(val, base):
                    work.append(.combineLog(hasBase: base != nil))
                    if let b = base { work.append(.calc(b)) }
                    work.append(.calc(val))
                case let .exp(inner):
                    work.append(.combineExp)
                    work.append(.calc(inner))
                }

            case .combineSum:
                let lhs = results.removeLast().asCalc
                let rhs = results.removeLast().asCalc
                let result: CSSCalc<V> = if case let .number(a) = lhs, case let .number(b) = rhs {
                    .number(a + b)
                } else if case .number(0) = rhs {
                    lhs
                } else if case .number(0) = lhs {
                    rhs
                } else {
                    .sum(lhs, rhs)
                }
                results.append(.calc(result))

            case let .combineProduct(mult):
                let expr = results.removeLast().asCalc
                let result: CSSCalc<V> = if case let .number(n) = expr {
                    .number(n * mult)
                } else if mult == 1 {
                    expr
                } else if mult == 0 {
                    .number(0)
                } else if case let .product(inner, innerMult) = expr {
                    .product(inner, innerMult * mult)
                } else {
                    .product(expr, mult)
                }
                results.append(.calc(result))

            case .combineFunction:
                let fn = results.removeLast()
                if case let .mathFn(m) = fn {
                    results.append(.calc(.function(m)))
                } else {
                    results.append(fn)
                }

            case .combineCalc:
                let inner = results.removeLast().asCalc
                results.append(.mathFn(.calc(inner)))

            case let .combineMin(count):
                var args: [CSSCalc<V>] = []
                for _ in 0 ..< count {
                    args.append(results.removeLast().asCalc)
                }
                let numbers = args.compactMap(\.numericValue)
                if numbers.count == args.count, let minVal = numbers.min() {
                    results.append(.mathFn(.calc(.number(minVal))))
                } else {
                    results.append(.mathFn(.min(args)))
                }

            case let .combineMax(count):
                var args: [CSSCalc<V>] = []
                for _ in 0 ..< count {
                    args.append(results.removeLast().asCalc)
                }
                let numbers = args.compactMap(\.numericValue)
                if numbers.count == args.count, let maxVal = numbers.max() {
                    results.append(.mathFn(.calc(.number(maxVal))))
                } else {
                    results.append(.mathFn(.max(args)))
                }

            case .combineClamp:
                let sMin = results.removeLast().asCalc
                let sVal = results.removeLast().asCalc
                let sMax = results.removeLast().asCalc
                if let minN = sMin.numericValue, let valN = sVal.numericValue, let maxN = sMax.numericValue {
                    results.append(.mathFn(.calc(.number(Swift.min(Swift.max(valN, minN), maxN)))))
                } else {
                    results.append(.mathFn(.clamp(sMin, sVal, sMax)))
                }

            case .combineAbs:
                let s = results.removeLast().asCalc
                if let n = s.numericValue {
                    results.append(.mathFn(.calc(.number(Swift.abs(n)))))
                } else {
                    results.append(.mathFn(.abs(s)))
                }

            case .combineSign:
                let s = results.removeLast().asCalc
                if let n = s.numericValue {
                    if n > 0 { results.append(.mathFn(.calc(.number(1)))) } else if n < 0 { results.append(.mathFn(.calc(.number(-1)))) } else { results.append(.mathFn(.calc(.number(0)))) }
                } else {
                    results.append(.mathFn(.sign(s)))
                }

            case let .combineRound(strategy):
                let sVal = results.removeLast().asCalc
                let sInt = results.removeLast().asCalc
                if let v = sVal.numericValue, let i = sInt.numericValue, i != 0 {
                    let rounded: Double = switch strategy {
                    case .nearest: Foundation.round(v / i) * i
                    case .up: Foundation.ceil(v / i) * i
                    case .down: Foundation.floor(v / i) * i
                    case .toZero: Foundation.trunc(v / i) * i
                    }
                    results.append(.mathFn(.calc(.number(rounded))))
                } else {
                    results.append(.mathFn(.round(strategy, sVal, sInt)))
                }

            case .combineMod:
                let sA = results.removeLast().asCalc
                let sB = results.removeLast().asCalc
                if let an = sA.numericValue, let bn = sB.numericValue, bn != 0 {
                    results.append(.mathFn(.calc(.number(an.truncatingRemainder(dividingBy: bn)))))
                } else {
                    results.append(.mathFn(.mod(sA, sB)))
                }

            case .combineRem:
                let sA = results.removeLast().asCalc
                let sB = results.removeLast().asCalc
                if let an = sA.numericValue, let bn = sB.numericValue, bn != 0 {
                    results.append(.mathFn(.calc(.number(an - Foundation.trunc(an / bn) * bn))))
                } else {
                    results.append(.mathFn(.rem(sA, sB)))
                }

            case .combineSin:
                let s = results.removeLast().asCalc
                if let n = s.numericValue {
                    results.append(.mathFn(.calc(.number(Foundation.sin(n)))))
                } else {
                    results.append(.mathFn(.sin(s)))
                }

            case .combineCos:
                let s = results.removeLast().asCalc
                if let n = s.numericValue {
                    results.append(.mathFn(.calc(.number(Foundation.cos(n)))))
                } else {
                    results.append(.mathFn(.cos(s)))
                }

            case .combineTan:
                let s = results.removeLast().asCalc
                if let n = s.numericValue {
                    results.append(.mathFn(.calc(.number(Foundation.tan(n)))))
                } else {
                    results.append(.mathFn(.tan(s)))
                }

            case .combineAsin:
                let s = results.removeLast().asCalc
                if let n = s.numericValue, n >= -1, n <= 1 {
                    results.append(.mathFn(.calc(.number(Foundation.asin(n)))))
                } else {
                    results.append(.mathFn(.asin(s)))
                }

            case .combineAcos:
                let s = results.removeLast().asCalc
                if let n = s.numericValue, n >= -1, n <= 1 {
                    results.append(.mathFn(.calc(.number(Foundation.acos(n)))))
                } else {
                    results.append(.mathFn(.acos(s)))
                }

            case .combineAtan:
                let s = results.removeLast().asCalc
                if let n = s.numericValue {
                    results.append(.mathFn(.calc(.number(Foundation.atan(n)))))
                } else {
                    results.append(.mathFn(.atan(s)))
                }

            case .combineAtan2:
                let sY = results.removeLast().asCalc
                let sX = results.removeLast().asCalc
                if let yn = sY.numericValue, let xn = sX.numericValue {
                    results.append(.mathFn(.calc(.number(Foundation.atan2(yn, xn)))))
                } else {
                    results.append(.mathFn(.atan2(sY, sX)))
                }

            case .combinePow:
                let sBase = results.removeLast().asCalc
                let sExp = results.removeLast().asCalc
                if let b = sBase.numericValue, let e = sExp.numericValue {
                    results.append(.mathFn(.calc(.number(Foundation.pow(b, e)))))
                } else {
                    results.append(.mathFn(.pow(sBase, sExp)))
                }

            case .combineSqrt:
                let s = results.removeLast().asCalc
                if let n = s.numericValue, n >= 0 {
                    results.append(.mathFn(.calc(.number(Foundation.sqrt(n)))))
                } else {
                    results.append(.mathFn(.sqrt(s)))
                }

            case let .combineHypot(count):
                var args: [CSSCalc<V>] = []
                for _ in 0 ..< count {
                    args.append(results.removeLast().asCalc)
                }
                let numbers = args.compactMap(\.numericValue)
                if numbers.count == args.count {
                    results.append(.mathFn(.calc(.number(Foundation.sqrt(numbers.reduce(0) { $0 + $1 * $1 })))))
                } else {
                    results.append(.mathFn(.hypot(args)))
                }

            case let .combineLog(hasBase):
                let sVal = results.removeLast().asCalc
                let sBase: CSSCalc<V>? = hasBase ? results.removeLast().asCalc : nil
                if let v = sVal.numericValue, v > 0 {
                    if let b = sBase?.numericValue, b > 0, b != 1 {
                        results.append(.mathFn(.calc(.number(Foundation.log(v) / Foundation.log(b)))))
                    } else if sBase == nil {
                        results.append(.mathFn(.calc(.number(Foundation.log(v)))))
                    } else {
                        results.append(.mathFn(.log(sVal, sBase)))
                    }
                } else {
                    results.append(.mathFn(.log(sVal, sBase)))
                }

            case .combineExp:
                let s = results.removeLast().asCalc
                if let n = s.numericValue {
                    results.append(.mathFn(.calc(.number(Foundation.exp(n)))))
                } else {
                    results.append(.mathFn(.exp(s)))
                }
            }
        }

        return results.first?.asCalc ?? self
    }

    /// Whether this calc expression can be reduced to a single numeric value.
    var isNumeric: Bool {
        if case .number = simplified() { return true }
        return false
    }

    /// Returns the numeric value if this expression is purely numeric, nil otherwise.
    var numericValue: Double? {
        if case let .number(n) = simplified() { return n }
        return nil
    }
}

extension CSSMathFunction {
    func simplified() -> CSSMathFunction<V> {
        let calc = CSSCalc<V>.function(self)
        let simplified = calc.simplified()
        if case let .function(fn) = simplified {
            return fn
        }
        return .calc(simplified)
    }
}
