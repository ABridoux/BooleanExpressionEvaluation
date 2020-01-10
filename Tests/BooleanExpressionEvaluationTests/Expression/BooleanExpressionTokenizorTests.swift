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

import XCTest
@testable import BooleanExpressionEvaluation

class BooleanExpressionTokenizorTests: XCTestCase {

    // MARK: - Properties

    let stubVariable = ExpressionElement.Operand.variable("variable")
    let stubComparisonOperator = Operator.equal
    let stubNumber = ExpressionElement.Operand.number(2)
    var stubExpression: Expression!

    var sut: BooleanExpressionTokenizator!
    var variables = [String: String]()

    // MARK: - Setup & Teardown

    override func setUp() {
        stubExpression = [.operand(stubVariable), .comparisonOperator(stubComparisonOperator), .operand(stubNumber)]
        variables["variable"] = "2"
        sut = BooleanExpressionTokenizator(expression: stubExpression, variables: variables)
    }

    override func tearDown() {
        variables.removeAll()
        sut = nil
    }

    // MARK: - Functions

    // MARK: Tokenization

    func testCurrentTokenBooleanNext_ThrowsErrorIfIncorrectNextToken() {
        sut.currentToken = .operand(.boolean(true))
        sut.expression = [.operand(.number(1))]

        XCTAssertThrowsError(try sut.currentTokenBooleanValidate(), "") { error in
            guard case ExpressionError.invalidExpression(_) = error else {
                XCTFail("Chaining a boolean with something else than a logic operator or a closing bracket should throw the invalidExpression error")
                return
            }
        }
    }

    func testCurrentTokenLogicOperatorNext() {
        sut.currentToken = .logicOperator(.and)
        sut.expression = stubExpression

        do {
            let element = try sut.currentTokenLogicOperatorOrOpeningBracketNextToken()
            guard let unwrappedElement = element,
                case let ExpressionElement.operand(.boolean(result)) = unwrappedElement else {
                XCTFail("Comparison expression after a logic operator or an opening bracket tokenization should be a non-nil boolean operand")
                return
            }
            XCTAssertTrue(result)
        } catch {
            XCTFail("Unwanted error: \(error.localizedDescription)")
        }
    }

    func testCurrentTokenOpeningBracketNext() {
        sut.currentToken = .bracket(.opening)
        sut.expression = stubExpression

        do {
            let element = try sut.currentTokenLogicOperatorOrOpeningBracketNextToken()
            guard let unwrappedElement = element,
                case let ExpressionElement.operand(.boolean(result)) = unwrappedElement else {
                XCTFail("Comparison expression after a logic operator or an opening bracket tokenization should be a non-nil boolean operand")
                return
            }
            XCTAssertTrue(result)
        } catch {
            XCTFail("Unwtanded error: \(error.localizedDescription)")
        }
    }

    func testCurrentTokenClosingBracketNext_ThrowsErrorIfNextTokenNotLogicOperator() {
        sut.currentToken = .bracket(.closing)
        sut.expression = [.operand(.string("gnōthi seauton"))]

        do {
            _ = try sut.currentTokenClosingBracketNextToken()
            XCTFail("Chaining something else than a logic operator or a closing bracket with a closing bracket should throw the invalidGrammar error")
        } catch {
            guard case ExpressionError.invalidGrammar(_) = error else {
                XCTFail("Chaining something else than a logic operator or a closing bracket with a closing bracket should throw the invalidGrammar error")
                return
            }
        }
    }

    // MARK: Evaluation

    func testEvaluateSingleBooleanExpression_ThrowsIfCountNot1() {
        let expression: Expression = [.operand(.variable("variable")), .comparisonOperator(.equal), .operand(.boolean(true))]
        XCTAssertThrowsError(try sut.evaluate(singleBooleanExpression: expression), "") { error in
            guard case ExpressionError.invalidGrammar = error else {
                XCTFail("Trying to evaluate a single boolean expression with more than 3 elements should throw the error ExpressionElement.incorrectGrammar")
                return
            }
        }
    }

    func testEvaluateSingleBooleanExpression_ThrowsIfNoVariableAsOperand() {
        let expression: Expression = [.operand(.boolean(true))]
        XCTAssertThrowsError(try sut.evaluate(singleBooleanExpression: expression), "") { error in
            guard case ExpressionError.invalidGrammar = error else {
                XCTFail("Trying to evaluate a single boolean expression with no undefined variable should throw the error ExpressionElement.undefinedVariable")
                return
            }
        }
    }

    func testEvaluateSingleBooleanExpression_ThrowsIfUndefinedVariable() {
        sut.variables.removeAll()
        let expression: Expression = [.operand(.variable("variable"))]
        XCTAssertThrowsError(try sut.evaluate(singleBooleanExpression: expression), "") { error in
            guard case ExpressionError.undefinedVariable = error else {
                XCTFail("Trying to evaluate a single boolean expression with no variable operand should throw the error ExpressionElement.undefinedVariable")
                return
            }
        }
    }

    func testEvaluateSingleBooleanExpression_ThrowsIfVariableWithNoBooleanValue1() {
        sut.variables["variable"] = "1.5"
        let expression: Expression = [.operand(.variable("variable"))]
        XCTAssertThrowsError(try sut.evaluate(singleBooleanExpression: expression), "") { error in
            guard case ExpressionError.invalidGrammar = error else {
                XCTFail("Trying to evaluate a single boolean expression with no boolean variable should throw the error ExpressionElement.invalidGrammar")
                return
            }
        }
    }

    func testEvaluateSingleBooleanExpression_ThrowsIfVariableWithNoBooleanValue2() {
        sut.variables["variable"] = "Hello"
        let expression: Expression = [.operand(.variable("variable"))]
        XCTAssertThrowsError(try sut.evaluate(singleBooleanExpression: expression), "") { error in
            guard case ExpressionError.invalidGrammar = error else {
                XCTFail("Trying to evaluate a single boolean expression with no boolean variable should throw the error ExpressionElement.invalidGrammar")
                return
            }
        }
    }

    func testEvaluateSingleBooleanExpression_True() {
        sut.variables["variable"] = "true"
        let expression: Expression = [.operand(.variable("variable"))]
        do {
            let result = try sut.evaluate(singleBooleanExpression: expression)
            XCTAssertTrue(result)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testEvaluateSingleBooleanExpression_False() {
        sut.variables["variable"] = "false"
        let expression: Expression = [.operand(.variable("variable"))]
        do {
            let result = try sut.evaluate(singleBooleanExpression: expression)
            XCTAssertFalse(result)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testEvaluateComparison_RightVariable() {
        sut.variables["variable"] = "2"
       do {
           let result = try sut.evaluate(comparison: [.operand(.number(3)), .comparisonOperator(.greaterThan), .operand(.variable("variable"))])
           XCTAssertTrue(result)
       } catch {
           XCTFail(error.localizedDescription)
       }
    }

    func testEvaluateComparison_ThrowsErrorIfCountLesserThanThanThree() {
        let expression: Expression = [.operand(.variable("a")), .comparisonOperator(.equal)]
        XCTAssertThrowsError(try sut.evaluate(comparison: expression), "") { error in
            guard error is ExpressionError else {
                XCTFail("Trying to evaluate a comparison which have less than three elements should throw an ExpressionError")
                return
            }
        }
     }

    func testEvaluateComparison_ThrowsErrorIfCountGreaterThanThree() {
        let expression: Expression = [.operand(.variable("a")), .comparisonOperator(.equal), .operand(.number(3)), .bracket(.closing)]

        XCTAssertThrowsError(try sut.evaluate(comparison: expression), "") { error in
            guard error is ExpressionError else {
                XCTFail("Error thrown isn't an ExpressionError")
                return
            }
        }
    }

    func testEvaluateComparison_ThrowsErrorDoesntHaveComparisonOperator() {
        let expression: Expression = [.operand(.variable("a")), .logicOperator(.and), .operand(.number(3))]

        XCTAssertThrowsError(try sut.evaluate(comparison: expression), "") { error in
            guard error is ExpressionError else {
                XCTFail("Error thrown isn't an ExpressionError")
                return
            }
        }
    }

    func testEvaluateComparison_ThrowsErrorUndefinedVariable() {
        let expression: Expression = [.operand(.variable("a")), .comparisonOperator(.equal), .operand(.number(3))]
        XCTAssertThrowsError(try sut.evaluate(comparison: expression), "") { error in
            guard case ExpressionError.undefinedVariable(_) = error else {
                XCTFail("Evaluate a comparison with an undefined variable should throw ExpressionError.undefinedVariable")
                return
            }
        }
    }

    func testEvaluateComparison_ThrowsErrorIFNoVariableFoundAsOperand() {
        let expression: Expression = [.operand(.number(1)), .comparisonOperator(.equal), .operand(.number(3))]
        XCTAssertThrowsError(try sut.evaluate(comparison: expression), "") { error in
            guard error is ExpressionError else {
                XCTFail("Error thrown isn't an ExpressionError")
                return
            }
        }
    }

    // MARK: Clean comparison evaluation

    func testThrowsErrorIfNoVariableAsOperand() {
        XCTAssertThrowsError(try sut.evaluateCleanComparison(.number(2), .greaterThan, .number(3)), "") { error in
            guard case ExpressionError.invalidExpression = error else {
                XCTFail()
                return
            }
        }
    }

    func testEvaluateComparison_EqualString() {
        sut.variables["variable"] = "Hello"

        do {
            let result = try sut.evaluateCleanComparison(.variable("variable"), .equal, .string("Hello"))
            XCTAssertEqual(result, true)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testEvaluateComparison_EqualNumber() {
        sut.variables["variable"] = "2.5"

        let result = try? sut.evaluateCleanComparison(.variable("variable"), .equal, .number(2.5))

        XCTAssertEqual(result, true)
    }

    func testEvaluateComparison_EqualBoolean() {
        sut.variables["variable"] = "true"

        let result = try? sut.evaluateCleanComparison(.variable("variable"), .equal, .boolean(true))

        XCTAssertEqual(result, true)
    }

    func testEvaluateComparison_GreaterNumber() {
        sut.variables["variable"] = "2.5"

        let result = try? sut.evaluateCleanComparison(.variable("variable"), .greaterThan, .number(2.0))

        XCTAssertEqual(result, true)
    }

    func testEvaluateComparison_LesserNumber() {
        sut.variables["variable"] = "2.5"

        let result = try? sut.evaluateCleanComparison(.variable("variable"), .greaterThan, .number(2.0))

        XCTAssertEqual(result, true)
    }

    func testEvaluateComparison_GreaterOrEqualNumber() {
        sut.variables["variable"] = "2.5"

        let result = try? sut.evaluateCleanComparison(.variable("variable"), .greaterThanOrEqual, .number(4))

        XCTAssertEqual(result, false)
    }

    func testEvaluateComparison_LesserOrEqualNumber() {
        sut.variables["variable"] = "2.5"

        let result = try? sut.evaluateCleanComparison(.variable("variable"), .lesserThanOrEqual, .number(4))

        XCTAssertEqual(result, true)
    }

    func testEvaluateComparison_ContainsLeftOperandVariable() {
        sut.variables["ducks"] = "Riri, Fifi, Loulou"

        let result = try? sut.evaluateCleanComparison(.variable("ducks"), .contains, .string("Riri"))

        XCTAssertEqual(result, true)
    }

    func testEvaluateComparison_ContainsRightOperandVariable() {
        sut.variables["duck"] = "Riri"

        let result = try? sut.evaluateCleanComparison(.string("Riri, Fifi, Loulou"), .contains, .variable("duck"))

        XCTAssertEqual(result, true)
    }

    func testEvaluateComparisonVariables_Equals() {
        let result = try? sut.evaluate(leftVariableValue: "Riri", comparisonOperator: .equal, rightVariableValue: "Riri")

        XCTAssertEqual(result, true)
    }

    func testEvaluateComparisonVariables_EqualsDouble() {
        let result = try? sut.evaluate(leftVariableValue: "2.6", comparisonOperator: .equal, rightVariableValue: "2.60")

        XCTAssertEqual(result, true)
    }

    func testEvaluateComparisonVariables_LesserThanOrDouble() {
        let result = try? sut.evaluate(leftVariableValue: "2.65", comparisonOperator: .greaterThanOrEqual, rightVariableValue: "2.650")

        XCTAssertEqual(result, true)
    }

    func testEvaluateComparisonVariables_LesserThanOrEqualDouble() {
        let result = try? sut.evaluate(leftVariableValue: "2.60", comparisonOperator: .greaterThanOrEqual, rightVariableValue: "2.650")

        XCTAssertEqual(result, false)
    }
}
