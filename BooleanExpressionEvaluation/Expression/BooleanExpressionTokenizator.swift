//
//  GNU GPLv3
//
/*
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see https://www.gnu.org/licenses
    for more information.
*/

import Foundation

/**
 Responsible to transform an `Expression` with contains comparison as `variable > 2` to a boolean expression which
 contains only `false` and `true`, the logic operators and brackets
 */
struct BooleanExpressionTokenizator {

    // MARK: - Properties

    var expression: Expression
    var currentToken = ExpressionElement.logicOperator(.or)

    /// Stores the variables which are present present in the expression
    var variables: [String: String]

    // MARK: - Init

    /**
     - Parameters:
        - expression: The expression to tokenize
        - variables: Variables which arepresent in the expression
     */
    init(expression: Expression, variables: [String: String]) {
        self.expression = expression
        self.variables = variables
    }

    // MARK: - Functions

    // MARK: Token validation

    /**
    Consume the next token in the expression
     - returns: A token if one was found, or `nil` if the end of the expression is reached.
     - note: Throws an error if a token chaining doesn't respect the grammar rule. The possible returned token are the following:
        - LogicOperator
        - Bracket
        - Operand.Boolean
    */
    mutating func nextToken() throws -> ExpressionElement? {
        var nextToken: ExpressionElement?

        switch currentToken {
        case .operand(.boolean):
            nextToken = try currentTokenBooleanValidate()
        case .logicOperator, .bracket(.opening):
            nextToken = try currentTokenLogicOperatorOrOpeningBracketNextToken()
        case .bracket(.closing):
            nextToken = try currentTokenClosingBracketNextToken()
        default:
            break
        }
        currentToken = nextToken ?? currentToken
        return nextToken
    }

    mutating func currentTokenBooleanValidate() throws -> ExpressionElement? {
        guard let nextToken = expression.popFirst() else {
            return nil
        }
        switch nextToken {
        case .logicOperator, .bracket(.closing):
            return nextToken
        default:
            throw ExpressionError.invalidExpression("Chaining a boolean with \(nextToken.description) is invalid")
        }
    }

    /// Validate a next token when the current one is a logic operator or an opening bracket and returns it
    mutating func currentTokenLogicOperatorOrOpeningBracketNextToken() throws -> ExpressionElement? {
        guard let nextElement = expression.popFirst() else {
            return nil
        }

        // validated if the next element is an opening bracket
        if case let ExpressionElement.bracket(bracket) = nextElement, bracket == .opening {
            return nextElement
        }
        // try to get an expression from the next three elements (only a comparison expression can follow an operator or an opening bracket)
        let comparisonExpression = [nextElement, expression.popFirst(), expression.popFirst()].compactMap { $0 }
        guard !comparisonExpression.isEmpty else {
            throw ExpressionError.invalidGrammar("Only a comparison expression can follow a \(currentToken.description)")
        }
        let result = try evaluate(comparison: Expression(comparisonExpression)) // using .map seems to prevent to initialize the Expression as an array literal
        return .operand(.boolean(result))
    }

    /// Validate a next token when the current one is a closing bracket and returns it
    mutating func currentTokenClosingBracketNextToken() throws -> ExpressionElement? {
        guard let nextToken = expression.popFirst() else {
            return nil
        }

        switch nextToken {
        case .logicOperator, .bracket(.closing):
            return nextToken
        default:
            throw ExpressionError.invalidGrammar("Chaining a closing bracket with \(nextToken.description) is invalid")
        }
    }

    // MARK: Evaluation

    /**
     Evaluate a comparison expression like `variable = 2`
     - note: A comparison expression should have at least one variable element as an operand. Otherwise, the expression can already be evaluated without
     the need of a computer, since with only take care of boolean expressions
     */
    func evaluate(comparison expression: Expression) throws -> Bool {
        if expression.count != 3 {
            // try to evaluate a single boolean variable like isUserLoggedIn
            return try evaluate(singleBooleanExpression: expression)
        }

        guard expression.count == 3 else {
            throw ExpressionError.invalidExpression("Trying to evaluate a comparison which has not exactly three elements")
        }
        guard case let ExpressionElement.comparisonOperator(comparisonOperator) = expression[1] else {
            throw ExpressionError.invalidExpression("Trying to evaluate a comparison which doesn't have a comparison operator")
        }
        guard case let ExpressionElement.operand(leftOperand) = expression[0] else {
            throw ExpressionError.invalidExpression("Trying to evaluate a comparison which doesn't have a left operand")
        }
        guard case let ExpressionElement.operand(rightOperand) = expression[2] else {
            throw ExpressionError.invalidExpression("Trying to evaluate a comparison which doesn't have a right operand")
        }
        return try evaluateCleanComparison(leftOperand, comparisonOperator, rightOperand)
    }

    func evaluate(singleBooleanExpression expression: Expression) throws -> Bool {
        guard expression.count == 1 else {
            throw ExpressionError.invalidGrammar("Single boolean expression with more than two elements: \(expression.description)")
        }
        guard case let ExpressionElement.operand(.variable(variableName)) = expression[0] else {
            throw ExpressionError.invalidGrammar("Trying to evaluate a single element which is not a variable: \(expression.description)")
        }
        guard let variableValue = variables[variableName] else {
            throw ExpressionError.undefinedVariable(variableName)
        }
        guard let boolean = Bool(variableValue) else {
            throw ExpressionError.invalidGrammar("Trying to evaluate a single variable which has not a boolean value: \(expression.description)")
        }
        return boolean
    }

    /**
     Evaluate a comparison expression which has passed the check. This function should not be called directly
     */
    func evaluateCleanComparison(_ leftOperand: ExpressionElement.Operand,
                                 _ comparisonOperator: Operator,
                                 _ rightOperand: ExpressionElement.Operand) throws -> Bool {

        // get the left or right variable value
        let variableName: String
        let isLeftOperandAVariable: Bool
        var remainingOperand: ExpressionElement.Operand

        if case let ExpressionElement.Operand.variable(name) = leftOperand {
            variableName = name
            isLeftOperandAVariable = true
            remainingOperand = rightOperand
        } else if case let ExpressionElement.Operand.variable(name) = rightOperand {
            variableName = name
            isLeftOperandAVariable = false
            remainingOperand = leftOperand
        } else {
            let expressionDescription = "\(leftOperand.description) \(comparisonOperator.description), \(rightOperand.description)"
            throw ExpressionError.invalidExpression("Trying to evaluate a comparison which doesn't have at least one variable for operand: \(expressionDescription)")
        }

        guard let variableValue = variables[variableName] else {
            throw ExpressionError.undefinedVariable(variableName)
        }

        var result: Bool?

        switch remainingOperand {

        case .string(let string):
            result = isLeftOperandAVariable ? comparisonOperator.evaluate(variableValue, string) : comparisonOperator.evaluate(string, variableValue)

        case .number(let double):
            guard let doubleVariableValue = Double(variableValue) else {
                throw ExpressionError.mismatchingType
            }
            result = isLeftOperandAVariable ? comparisonOperator.evaluate(doubleVariableValue, double) : comparisonOperator.evaluate(double, doubleVariableValue)

        case .boolean(let boolean):
            guard let booleanVariableValue = Bool(variableValue) else {
                throw ExpressionError.mismatchingType
            }
            result = isLeftOperandAVariable ? comparisonOperator.evaluate(booleanVariableValue, boolean) : comparisonOperator.evaluate(boolean, booleanVariableValue)

        case .variable(let otherVariableName):
            guard let otherVariableValue = variables[otherVariableName] else { return false }
            result = isLeftOperandAVariable ? try evaluate(leftVariableValue: variableValue, comparisonOperator: comparisonOperator, rightVariableValue: otherVariableValue)
            : try evaluate(leftVariableValue: otherVariableValue, comparisonOperator: comparisonOperator, rightVariableValue: variableValue)
        }

        guard let unwrappedResult = result else {
            throw ExpressionError.wrongOperatorAndOperandsAssociation
        }
        return unwrappedResult
    }

    /// Helper to evaluate a comparison expression with two variables as operands
    func evaluate(leftVariableValue: String, comparisonOperator: Operator, rightVariableValue: String) throws -> Bool {
        var result: Bool?

        if let leftDouble = Double(leftVariableValue), let rightDouble = Double(rightVariableValue) {
            result = comparisonOperator.evaluate(leftDouble, rightDouble)
        } else if let leftBoolean = Bool(leftVariableValue), let rightBoolean = Bool(rightVariableValue) {
            result = comparisonOperator.evaluate(leftBoolean, rightBoolean)
        } else {
            // string comparison
            result = comparisonOperator.evaluate(leftVariableValue, rightVariableValue)
        }

        if let unwrappedResult = result {
            return unwrappedResult
        } else {
            throw ExpressionError.wrongOperatorAndOperandsAssociation
        }
    }
}
