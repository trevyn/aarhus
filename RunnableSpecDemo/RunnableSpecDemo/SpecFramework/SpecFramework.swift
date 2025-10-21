import Foundation

// MARK: - Spec Result Types

public enum SpecResult: Equatable {
    case passed
    case failed(String)
    case pending

    var isPassing: Bool {
        if case .passed = self { return true }
        return false
    }

    var message: String {
        switch self {
        case .passed:
            return "Passed"
        case .failed(let reason):
            return "Failed: \(reason)"
        case .pending:
            return "Pending"
        }
    }
}

// MARK: - Spec Types

public class Spec: Identifiable, ObservableObject {
    public let id = UUID()
    public let description: String
    public let block: () -> SpecResult
    @Published public var result: SpecResult = .pending
    @Published public var hasRun: Bool = false

    public init(_ description: String, _ block: @escaping () -> SpecResult) {
        self.description = description
        self.block = block
    }

    public func run() {
        result = block()
        hasRun = true
    }
}

public class Feature: Identifiable, ObservableObject {
    public let id = UUID()
    public let name: String
    public let description: String
    @Published public var specs: [Spec]

    public init(name: String, description: String, specs: [Spec] = []) {
        self.name = name
        self.description = description
        self.specs = specs
    }

    public func runAll() {
        for spec in specs {
            spec.run()
        }
    }

    public var passCount: Int {
        specs.filter { $0.result.isPassing }.count
    }

    public var failCount: Int {
        specs.filter { !$0.result.isPassing && $0.hasRun }.count
    }

    public var totalCount: Int {
        specs.count
    }
}

// MARK: - Spec Builder DSL

@resultBuilder
public struct SpecBuilder {
    public static func buildBlock(_ components: Spec...) -> [Spec] {
        components
    }
}

@resultBuilder
public struct FeatureBuilder {
    public static func buildBlock(_ components: Feature...) -> [Feature] {
        components
    }
}

// MARK: - Assertion Helpers

public func expect<T: Equatable>(_ actual: T, toEqual expected: T) -> SpecResult {
    if actual == expected {
        return .passed
    } else {
        return .failed("Expected \(expected) but got \(actual)")
    }
}

public func expect(_ condition: Bool, _ message: String = "Condition was false") -> SpecResult {
    condition ? .passed : .failed(message)
}

public func expectNotNil<T>(_ value: T?, _ message: String = "Expected non-nil value") -> SpecResult {
    value != nil ? .passed : .failed(message)
}

public func expectNil<T>(_ value: T?, _ message: String = "Expected nil value") -> SpecResult {
    value == nil ? .passed : .failed(message)
}

public func expectThrows<T>(_ block: () throws -> T) -> SpecResult {
    do {
        _ = try block()
        return .failed("Expected to throw but didn't")
    } catch {
        return .passed
    }
}

public func expectNoThrow<T>(_ block: () throws -> T) -> SpecResult {
    do {
        _ = try block()
        return .passed
    } catch {
        return .failed("Unexpected error: \(error)")
    }
}

// MARK: - Spec Suite Manager

public class SpecSuite: ObservableObject {
    @Published public var features: [Feature]

    public init(features: [Feature]) {
        self.features = features
    }

    public func runAll() {
        for feature in features {
            feature.runAll()
        }
    }

    public var totalSpecs: Int {
        features.reduce(0) { $0 + $1.totalCount }
    }

    public var totalPassed: Int {
        features.reduce(0) { $0 + $1.passCount }
    }

    public var totalFailed: Int {
        features.reduce(0) { $0 + $1.failCount }
    }
}
