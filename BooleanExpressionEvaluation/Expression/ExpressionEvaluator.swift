//
//  GNU GPLv3
//
/*  Copyright © 2019-present Alexis Bridoux.

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

struct ExpressionEvaluator {

    // MARK: - Properties

    var expressionResults = [[HalfBooleanExpression(boolean: .boolean(false), logicOperator: .or)]]
    var tokenizator: BooleanExpressionTokenizator
    var currentOpenedBrackets = 0

    // MARK: - Init

    init(expression: Expression, variables: [String: String]) {
        self.tokenizator = BooleanExpressionTokenizator(expression: expression, variables: variables)
    }

    init?(string: String, variables: [String: String]) throws {
        let expression = try Expression(string)
        self.init(expression: expression, variables: variables)
    }

    // MARK: - Functions

    mutating func evaluateExpression() throws -> Bool {
        // setting the current token to an opening bracket to avoid to have an optional
        currentOpenedBrackets = 0

        while let nextToken = try tokenizator.nextToken() {
            switch nextToken {

            case .logicOperator(let logicOperator):
                try evaluateExpressionHandleToken(logicOperator: logicOperator)

            case .bracket(.opening):
                expressionResults.append([HalfBooleanExpression]())
                currentOpenedBrackets += 1

            case .operand(.boolean(let boolean)):
                let halfBooleanExpression = HalfBooleanExpression(boolean: .boolean(boolean), logicOperator: nil)
                expressionResults[currentOpenedBrackets].append(halfBooleanExpression)

            case .bracket(.closing):
                try evaluateExpressionHandleTokenClosingBracket()

            default:
                throw ExpressionError.incorrectElement(nextToken.description)
            }
        }
        // ensure we got one array left. Otherwise, something went wrong, like uncaught unbalanced brackets
        guard expressionResults.count == 1 else {
            throw ExpressionError.invalidExpression("Unable to flatten the expression for an uncaught error")
        }
        let flattenBooleanExpression = expressionResults[0]

        // get the final result
        guard let finalResultBooleanElement = evaluate(booleanExpression: flattenBooleanExpression)?.boolean,
            case let .boolean(finalResult) = finalResultBooleanElement else {
                throw ExpressionError.invalidExpression("Unable to evaluate the final flatten expression: \(flattenBooleanExpression.description)")
        }

        return finalResult
    }

    // MARK: Helpers

    mutating func evaluateExpressionHandleToken(logicOperator: ExpressionElement.LogicOperator) throws {
        guard let currentHalfBooleanExpression = expressionResults[currentOpenedBrackets].last,
            currentHalfBooleanExpression.logicOperator == nil else {
                throw ExpressionError.invalidGrammar("Logic operator should follow a closing bracket or a comparison expression")
        }

        let currentHalfBooleanExpressionWithLogicOperator = HalfBooleanExpression(boolean: currentHalfBooleanExpression.boolean, logicOperator: logicOperator)
        expressionResults[currentOpenedBrackets].removeLast()
        expressionResults[currentOpenedBrackets].append(currentHalfBooleanExpressionWithLogicOperator)
    }

    mutating func evaluateExpressionHandleTokenClosingBracket() throws {
        guard !expressionResults.isEmpty, currentOpenedBrackets > 0 else {
            throw ExpressionError.unbalancedBrackets
        }
        var booleanExpression = expressionResults[currentOpenedBrackets]

        if let boolean = expressionResults[currentOpenedBrackets].last?.boolean {
            let halfExpressionElement = HalfBooleanExpression(boolean: boolean, logicOperator: nil)
            booleanExpression.append(halfExpressionElement)
        }

        if let bracketsResult = evaluate(booleanExpression: booleanExpression)?.boolean {
            let halfBooleanExpression = HalfBooleanExpression(boolean: bracketsResult, logicOperator: nil)
            expressionResults[currentOpenedBrackets - 1].append(halfBooleanExpression)
        }

        expressionResults.removeLast()
        currentOpenedBrackets -= 1
    }

    /**
     Reduce an array of `HalfBooleanExpression` to one
     */
    func evaluate(booleanExpression: [HalfBooleanExpression]) -> HalfBooleanExpression? {
        // copy the boolean expression to modify it
        var booleanExpression = booleanExpression
        guard var result = booleanExpression.popFirst() else { return nil }

        /**
        When the case `boolean || boolean && boolean` is found, it's not possible to evaluate the two
        `HalfBooleanExpression`. The part `boolean ||` is stored here to evaluate when possible
         */
        var debt: HalfBooleanExpression?

        for element in booleanExpression {
            if let partialResult = result.evaluate(with: element) {
                // we are able to evaluate the result
                result = partialResult
            } else {
                // we are not able to evaluate the result so store the debt
                if debt == nil {
                    // there is no debt for now so just store it
                    debt = result
                } else {
                    // we already have a debt, we can evaluate it with the new one
                    debt = debt?.evaluate(with: result)
                }
                result = element
            }
        }
        return debt?.evaluate(with: result) ?? result
    }
}
