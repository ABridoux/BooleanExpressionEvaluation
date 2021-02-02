//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ExpressionElement {

    public struct LogicPrefixOperator: OperatorProtocol {

        // MARK: - Constants

        typealias Evaluation = (Bool) -> Bool

        // MARK: - Properties

        public var description: String

        public static var models: Set<LogicPrefixOperator> = [.not]

        /// Closure to evaluate two operands
        var evaluate: Evaluation

        // MARK: - Initialization

        init(_ description: String, evaluation: @escaping Evaluation) {
            self.description = description
            self.evaluate = evaluation
        }
    }
}

extension ExpressionElement.LogicPrefixOperator {

    public static func == (lhs: ExpressionElement.LogicPrefixOperator, rhs: ExpressionElement.LogicPrefixOperator) -> Bool {
        lhs.description == rhs.description
    }
}

extension ExpressionElement.LogicPrefixOperator {

    static var not: Self { Self("!") { !$0 }}
}
