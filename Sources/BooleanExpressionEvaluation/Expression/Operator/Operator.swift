//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public struct Operator: OperatorProtocol {

    // MARK: - Constants

    public typealias Evaluation = (Any, Any) throws -> Bool

    // MARK: - Properties

    public var description: String
    public var isKeyword: Bool

    public static var models: Set<Operator> = [.equal, .nonEqual,
                                               .greaterThan, .greaterThanOrEqual,
                                               .lesserThan, .lesserThanOrEqual,
                                               .isIn, .contains, .matches,
                                               .hasPrefix, .hasSuffix]

    /// Closure to evaluate two operands
    var evaluate: Evaluation

    // MARK: - Initialization

    public init(_ description: String, isKeyword: Bool = false, evaluation: @escaping Evaluation) {
        self.description = description
        self.isKeyword = isKeyword
        self.evaluate = evaluation
    }
}

extension Operator {
    public static func == (lhs: Operator, rhs: Operator) -> Bool {
        return lhs.description == rhs.description
    }

    static func cast<T>(_ value: Any, as type: T.Type) throws -> T {
        if let casted = value as? T {
            return casted
        }
        throw ExpressionError.mismatchingType
    }
}

extension Operator {

    public static var equal: Operator { Operator("==") { (lhs, rhs) in
        if let lhs = lhs as? Double {
            let rhs = try cast(rhs, as: Double.self)
            return lhs == rhs
        } else if let lhs = lhs as? Bool {
            let rhs = try cast(rhs, as: Bool.self)
            return lhs == rhs
        } else if let lhs = lhs as? String {
            let rhs = try cast(rhs, as: String.self)
            return lhs == rhs
        }
        throw ExpressionError.mismatchingType
    }}

    public static var nonEqual: Operator { Operator("!=") { (lhs, rhs) in
        if let lhs = lhs as? Double {
            let rhs = try cast(rhs, as: Double.self)
            return lhs != rhs
        } else if let lhs = lhs as? Bool {
            let rhs = try cast(rhs, as: Bool.self)
            return lhs != rhs
        } else if let lhs = lhs as? String {
            let rhs = try cast(rhs, as: String.self)
            return lhs != rhs
        }
        throw ExpressionError.mismatchingType
    }}

    public static var greaterThan: Operator { Operator(">") { (lhs, rhs) in
        if let lhs = lhs as? Double {
            let rhs = try cast(rhs, as: Double.self)
            return lhs > rhs
        } else if let lhs = lhs as? String {
            let rhs = try cast(rhs, as: String.self)
            return lhs > rhs
        }
        throw ExpressionError.mismatchingType
    }}

    public static var greaterThanOrEqual: Operator { Operator(">=") { (lhs, rhs) in
        if let lhs = lhs as? Double {
            let rhs = try cast(rhs, as: Double.self)
            return lhs >= rhs
        } else if let lhs = lhs as? String {
            let rhs = try cast(rhs, as: String.self)
            return lhs >= rhs
        }
        throw ExpressionError.mismatchingType
    }}

    public static var lesserThan: Operator { Operator("<") { (lhs, rhs) in
        if let lhs = lhs as? Double {
            let rhs = try cast(rhs, as: Double.self)
            return lhs < rhs
        } else if let lhs = lhs as? String {
            let rhs = try cast(rhs, as: String.self)
            return lhs < rhs
        }
        throw ExpressionError.mismatchingType
    }}

    public static var lesserThanOrEqual: Operator { Operator("<=") { (lhs, rhs) in
        if let lhs = lhs as? Double {
            let rhs = try cast(rhs, as: Double.self)
            return lhs <= rhs
        } else if let lhs = lhs as? String {
            let rhs = try cast(rhs, as: String.self)
            return lhs <= rhs
        }
        throw ExpressionError.mismatchingType
    }}

    public static var contains: Operator { Operator("contains", isKeyword: true) { (lhs, rhs) in
        guard let lhs = lhs as? String, let rhs = rhs as? String else {
            throw ExpressionError.mismatchingType
        }
        return lhs.contains(rhs)
    }}

    public static var isIn: Operator { Operator("isIn", isKeyword: true) { (lhs, rhs) in
        guard let lhs = lhs as? String, let rhs = rhs as? String else {
            throw ExpressionError.mismatchingType
        }
        var escapedComma = false

        return rhs
            .split(separator: ",")
            .reduce([String]()) { (result, substring) in
                var result = result

                if escapedComma, let last = result.last {
                    result[result.count - 1] = last + "," + String(substring)
                } else {
                    result.append(String(substring))
                }

                escapedComma = substring.hasSuffix("\\")
                return result
            }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } // trim after a possible matches union
            .contains(lhs)
    }}

    public static var matches: Operator { Operator("matches", isKeyword: true) { (lhs, rhs) in
        guard
            let lhs = lhs as? String,
            let rhs = rhs as? String
        else {
            throw ExpressionError.mismatchingType
        }

        do {
            let regex = try NSRegularExpression(pattern: rhs)
            return regex.validate(lhs)
        } catch {
            throw ExpressionError.invalidOperand(description: "The regular expression '\(rhs)' is invalid")
        }
    }}

    public static var hasPrefix: Operator { Operator("hasPrefix", isKeyword: true) { (lhs, rhs) in
        guard let stringLhs = lhs as? String, let stringRhs = rhs as? String else {
            throw ExpressionError.mismatchingType
        }
        return stringLhs.hasPrefix(stringRhs)
    }}

    public static var hasSuffix: Operator { Operator("hasSuffix", isKeyword: true) { (lhs, rhs) in
        guard let lhs = lhs as? String, let rhs = rhs as? String else {
            throw ExpressionError.mismatchingType
        }
        return lhs.hasSuffix(rhs)
    }}
}

extension Operator {

    public static func removeFromModels(model: Operator) {
        models.remove(model)
    }
}
