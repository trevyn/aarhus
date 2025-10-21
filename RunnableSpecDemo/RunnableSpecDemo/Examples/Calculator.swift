import Foundation

// Example implementation: Simple Calculator
public class Calculator {
    public init() {}

    public func add(_ a: Int, _ b: Int) -> Int {
        return a + b
    }

    public func subtract(_ a: Int, _ b: Int) -> Int {
        return a - b
    }

    public func multiply(_ a: Int, _ b: Int) -> Int {
        return a * b
    }

    public func divide(_ a: Int, _ b: Int) throws -> Int {
        guard b != 0 else {
            throw CalculatorError.divisionByZero
        }
        return a / b
    }

    // Intentionally buggy method for demonstration
    public func power(_ base: Int, _ exponent: Int) -> Int {
        // Bug: This doesn't handle negative exponents
        guard exponent >= 0 else { return 0 }
        return Int(pow(Double(base), Double(exponent)))
    }
}

public enum CalculatorError: Error {
    case divisionByZero
}
