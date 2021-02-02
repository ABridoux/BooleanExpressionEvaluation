//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

struct ExpressionEvaluator {

    // MARK: - Properties

    var expressionResults = [[HalfBooleanExpression(boolean: false, logicOperator: .or)]]
    var tokenizator: BooleanExpressionTokenizator
    var currentOpenedBrackets = 0
    var previousToken: ExpressionElement?
    var previousTokenWasNotOperator = false

    /// Store the not operators indexed by the current opened brackets
    var notOperators = [Int]()

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

        while let token = try tokenizator.nextToken() {

            switch token {

            case .logicInfixOperator(let logicOperator):
                try evaluateExpressionHandle(logicOperator: logicOperator)

            case .bracket(.opening):
                expressionResults.append([HalfBooleanExpression]())
                currentOpenedBrackets += 1

                if case let .logicPrefixOperator(logicOperator) = previousToken, logicOperator == .not {
                    notOperators.append(currentOpenedBrackets)
                }

            case .operand(.boolean(let boolean)):
                let halfBooleanExpression = HalfBooleanExpression(boolean: boolean, logicOperator: nil)
                expressionResults[currentOpenedBrackets].append(halfBooleanExpression)

            case .bracket(.closing):
                try evaluateExpressionHandleClosingBracket()

            case .comparisonOperator, .operand:
                throw ExpressionError.incorrectElement(token.description)

            case .logicPrefixOperator:
                break
            }

            previousToken = token
        }

        // ensure we got one array left. Otherwise, something went wrong, like uncaught unbalanced brackets
        guard expressionResults.count == 1 else {
            throw ExpressionError.invalidExpression("Unable to flatten the expression for an uncaught error")
        }
        let flattenedBooleanExpression = expressionResults[0]

        // get the final result
        guard let finalResult = evaluate(booleanExpression: flattenedBooleanExpression)?.boolean else {
            throw ExpressionError.invalidExpression("Unable to evaluate the final flatten expression: \(flattenedBooleanExpression.description)")
        }

        return finalResult
    }

    // MARK: Helpers

    mutating func evaluateExpressionHandle(logicOperator: ExpressionElement.LogicInfixOperator) throws {
        guard
            let currentHalfBooleanExpression = expressionResults[currentOpenedBrackets].last,
            currentHalfBooleanExpression.logicOperator == nil
        else {
            throw ExpressionError.invalidGrammar("Logic operator should follow a closing bracket or a comparison expression")
        }

        let currentHalfBooleanExpressionWithLogicOperator = HalfBooleanExpression(boolean: currentHalfBooleanExpression.boolean, logicOperator: logicOperator)
        expressionResults[currentOpenedBrackets].removeLast()
        expressionResults[currentOpenedBrackets].append(currentHalfBooleanExpressionWithLogicOperator)
    }

    mutating func evaluateExpressionHandleClosingBracket() throws {
        guard !expressionResults.isEmpty, currentOpenedBrackets > 0 else {
            throw ExpressionError.unbalancedBrackets
        }
        var booleanExpression = expressionResults[currentOpenedBrackets]

        if let boolean = expressionResults[currentOpenedBrackets].last?.boolean {
            let halfExpressionElement = HalfBooleanExpression(boolean: boolean, logicOperator: nil)
            booleanExpression.append(halfExpressionElement)
        }

        if let bracketsResult = evaluate(booleanExpression: booleanExpression)?.boolean {
            let bool = invert(bool: bracketsResult, for: currentOpenedBrackets)
            let halfBooleanExpression = HalfBooleanExpression(boolean: bool, logicOperator: nil)
            expressionResults[currentOpenedBrackets - 1].append(halfBooleanExpression)
        }

        expressionResults.removeLast()
        currentOpenedBrackets -= 1
    }

    /// Reduce an array of `HalfBooleanExpression` to one
    func evaluate(booleanExpression: [HalfBooleanExpression]) -> HalfBooleanExpression? {
        // copy the boolean expression to modify it
        var booleanExpression = booleanExpression
        guard var result = booleanExpression.popFirst() else { return nil }

        /// When the case `boolean || boolean && boolean` is found, it's not possible to evaluate the two
        /// `HalfBooleanExpression`. The part `boolean ||` is stored here to evaluate when possible
        var debt: HalfBooleanExpression?

        booleanExpression.forEach { element in
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

    /// Invert the provided boolean if a not operator is registered matching the current openent brackets counts
    mutating func invert(bool: Bool, for openedBracket: Int) -> Bool {
        if let notOperatorIndex = notOperators.last, notOperatorIndex == openedBracket {
            notOperators.removeLast()
            return !bool
        }
        return bool
    }
}
