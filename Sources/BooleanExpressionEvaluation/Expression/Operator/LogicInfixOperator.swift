//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ExpressionElement {

    public struct LogicInfixOperator: OperatorProtocol {

        // MARK: - Constants

        typealias Evaluation = (Bool, Bool) -> Bool

        // MARK: - Properties

        public var description: String

        public static var models: Set<LogicInfixOperator> = [.or, .and]

        /// Closure to evaluate two operands
        var evaluate: Evaluation

        // MARK: - Initialization

        init(_ description: String, evaluation: @escaping Evaluation) {
            self.description = description
            self.evaluate = evaluation
        }
    }
}

extension ExpressionElement.LogicInfixOperator {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.description == rhs.description
    }
}

// MARK: - Logic operators

extension ExpressionElement.LogicInfixOperator {
    static var and: Self { Self("&&") { (lhs, rhs) in
        return lhs && rhs
    }}

    static var or: Self { Self("||") { (lhs, rhs) in
        return lhs || rhs
    }}
}

extension ExpressionElement.LogicInfixOperator {

    /// Call this function if you want to prevent the default operator `&&` to work.
    // If you need to override the behavior of `&&`, simply insert a new operator with the same description
    func removeDefaultAnd() { Self.models.remove(.and) }

    /// Call this function if you want to prevent the default operator `||` to work.
    /// If you need to override the behavior of `||`, simply insert a new operator with the same description
    func removeDefaultOr() { Self.models.remove(.or) }
}
