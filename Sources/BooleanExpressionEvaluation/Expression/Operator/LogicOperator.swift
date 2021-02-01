//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public struct LogicOperator: OperatorProtocol {

    // MARK: - Constants

    typealias Evaluation = (Bool, Bool) -> Bool

    // MARK: - Properties

    public var description: String

    public static var models: Set<LogicOperator> = [.or, .and]

    /// Closure to evaluate two operands
    var evaluate: Evaluation

    // MARK: - Initialization

    init(_ description: String, evaluation: @escaping Evaluation) {
        self.description = description
        self.evaluate = evaluation
    }
}

extension LogicOperator {
    public static func == (lhs: LogicOperator, rhs: LogicOperator) -> Bool {
        return lhs.description == rhs.description
    }
}

// MARK: - Logic operators

extension LogicOperator {
    static var and: LogicOperator { LogicOperator("&&") { (lhs, rhs) in
        return lhs && rhs
    }}

    static var or: LogicOperator { LogicOperator("||") { (lhs, rhs) in
        return lhs || rhs
    }}
}

extension LogicOperator {
    /// Call this function if you want to prevent the default operator `&&` to work.
    // If you need to override the behavior of `&&`, simply insert a new operator with the same description
    func removeDefaultAnd() { Self.models.remove(.and) }

    /// Call this function if you want to prevent the default operator `||` to work.
    /// If you need to override the behavior of `||`, simply insert a new operator with the same description
    func removeDefaultOr() { Self.models.remove(.or) }
}
