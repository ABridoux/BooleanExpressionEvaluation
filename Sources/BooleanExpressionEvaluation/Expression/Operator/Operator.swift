//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public struct Operator: OperatorProtocol {

    // MARK: - Constants

    public typealias Evaluation = (Any, Any) -> Bool?

    // MARK: - Properties

    public var description: String

    public static var models: Set<Operator> = [.equal, .nonEqual,
                                               .greaterThan, .greaterThanOrEqual,
                                               .lesserThan, .lesserThanOrEqual,
                                               .contains,
                                               .hasPrefix, .hasSuffix]

    /// Closure to evaluate two operands
    var evaluate: Evaluation

    // MARK: - Initialization

    public init(_ description: String, evaluation: @escaping Evaluation) {
        self.description = description
        self.evaluate = evaluation
    }
}

extension Operator {
    public static func == (lhs: Operator, rhs: Operator) -> Bool {
        return lhs.description == rhs.description
    }
}

extension Operator {
    static var equal: Operator { Operator("==") { (lhs, rhs) in
        if let lhs = lhs as? String, let rhs = rhs as? String {
            return lhs == rhs
        } else if let lhs = lhs as? Double, let rhs = rhs as? Double {
            return lhs == rhs
        } else if let lhs = lhs as? Bool, let rhs = rhs as? Bool {
            return lhs == rhs
        }
        return nil
    }}

    static var nonEqual: Operator { Operator("!=") { (lhs, rhs) in
        if let lhs = lhs as? String, let rhs = rhs as? String {
            return lhs != rhs
        } else if let lhs = lhs as? Double, let rhs = rhs as? Double {
            return lhs != rhs
        } else if let lhs = lhs as? Bool, let rhs = rhs as? Bool {
            return lhs != rhs
        }
        return nil
    }}

    static var greaterThan: Operator { Operator(">") { (lhs, rhs) in
        if let lhs = lhs as? String, let rhs = rhs as? String {
            return lhs > rhs
        } else if let lhs = lhs as? Double, let rhs = rhs as? Double {
            return lhs > rhs
        }
        return nil
    }}

    static var greaterThanOrEqual: Operator { Operator(">=") { (lhs, rhs) in
        if let lhs = lhs as? String, let rhs = rhs as? String {
            return lhs >= rhs
        } else if let lhs = lhs as? Double, let rhs = rhs as? Double {
            return lhs >= rhs
        }
        return nil
    }}

    static var lesserThan: Operator { Operator("<") { (lhs, rhs) in
        if let lhs = lhs as? String, let rhs = rhs as? String {
            return lhs < rhs
        } else if let lhs = lhs as? Double, let rhs = rhs as? Double {
            return lhs < rhs
        }
        return nil
    }}

    static var lesserThanOrEqual: Operator { Operator("<=") { (lhs, rhs) in
        if let lhs = lhs as? String, let rhs = rhs as? String {
            return lhs <= rhs
        } else if let lhs = lhs as? Double, let rhs = rhs as? Double {
            return lhs <= rhs
        }
        return nil
    }}

    static var contains: Operator { Operator("<:") { (lhs, rhs) in
        guard let lhs = lhs as? String, let rhs = rhs as? String else { return nil }
        let splittedLhs = lhs.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        return splittedLhs.contains(rhs)
    }}

    static var hasPrefix: Operator { Operator("~=") { (lhs, rhs) in
        guard let lhs = lhs as? String, let rhs = rhs as? String else { return nil }
        return lhs.hasPrefix(rhs)
    }}

    static var hasSuffix: Operator { Operator("=~") { (lhs, rhs) in
        guard let lhs = lhs as? String, let rhs = rhs as? String else { return nil }
        return lhs.hasSuffix(rhs)
    }}
}

extension Operator {
    
    /// Call this function if you want to prevent the default operator `==` to work.
    /// If you need to override the behavior of `==`, simply update a new operator with the same description
    func removeDefaultEqual() { Self.models.remove(.equal) }

    /// Call this function if you want to prevent the default operator `!=` to work.
    /// If you need to override the behavior of `!=`, simplyupdate a new operator with the same description
    func removeDefaultNonEqual() { Self.models.remove(.nonEqual) }

    /// Call this function if you want to prevent the default operator `>` to work.
    /// If you need to override the behavior of `>`, simply update a new operator with the same description
    func removeDefaultGreaterThan() { Self.models.remove(.greaterThan) }

    /// Call this function if you want to prevent the default operator `>=` to work.
    /// If you need to override the behavior of `>=`, simply update a new operator with the same description
    func removeDefaultGreaterThanOrEqual() { Self.models.remove(.greaterThanOrEqual) }

    /// Call this function if you want to prevent the default operator `<` to work.
    /// If you need to override the behavior of `<`, simply update a new operator with the same description
    func removeDefaultLesserThan() { Self.models.remove(.lesserThan) }

    /// Call this function if you want to prevent the default operator `<=` to work.
    /// If you need to override the behavior of `<=`, simply update a new operator with the same description
    func removeDefaultLesserThanOrEqual() { Self.models.remove(.lesserThanOrEqual) }

    /// Call this function if you want to prevent the default operator `<:` to work.
    /// If you need to override the behavior of `<:`, simply update a new operator with the same description
    func removeDefaultContains() { Self.models.remove(.contains) }
}
