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
    let stubComparisonOperator = ExpressionElement.ComparisonOperator.equal
    let stubNumber = ExpressionElement.Operand.number(2)
    var stubExpression: Expression!

    var sut: BooleanExpressionTokenizator!
    var variablesProviderMock: VariablesProviderMock!

    // MARK: - Setup & Teardown

    override func setUp() {
        stubExpression = [.operand(stubVariable), .comparisonOperator(stubComparisonOperator), .operand(stubNumber)]
        variablesProviderMock = VariablesProviderMock()
        variablesProviderMock.variables["variable"] = "2"
        sut = BooleanExpressionTokenizator(expression: stubExpression, variablesProvider: variablesProviderMock)
    }

    override func tearDown() {
        variablesProviderMock = nil
        sut = nil
    }

    // MARK: - Functions

    // MARK: Tokenization

    func testCurrentTokenBooleanNext_ThrowsErrorIfIncorrectNextToken() {
        sut.currentToken = .operand(.boolean(true))
        sut.expression = [.operand(.number(1))]

        do {
            _ = try sut.currentTokenBooleanValidate()
            XCTFail("Chaining a boolean with something else than a logic operator or a closing bracket should throw the invalidExpression error")
        } catch {
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
            XCTFail("Unwtanded error: \(error.localizedDescription)")
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

    // MARK: Tokenization - Integration tests

    func testTokenization1() {
        variablesProviderMock.variables["variable"] = "1"
        variablesProviderMock.variables["isCheck"] = "true"
        variablesProviderMock.variables["input"] = "Test"

        let expression: Expression = [.bracket(.opening),
                                            .operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)),
                                      .logicOperator(.and),
                                            .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .bracket(.closing),
                                        .logicOperator(.or),
                                            .operand(.variable("input")), .comparisonOperator(.equal), .operand(.string("Test"))]
        let expectedTokenizedExpression: Expression = [.bracket(.opening),
                                                            .operand(.boolean(false)),
                                                      .logicOperator(.and),
                                                            .operand(.boolean(true)),
                                                        .bracket(.closing),
                                                        .logicOperator(.or),
                                                            .operand(.boolean(true))]
        var sut = BooleanExpressionTokenizator(expression: expression, variablesProvider: variablesProviderMock)

        var tokenizedExpression = Expression()
        while let token = try? sut.nextToken() {
            tokenizedExpression.append(token)
        }

        XCTAssertEqual(tokenizedExpression, expectedTokenizedExpression)
    }

    func testTokenization2() {
        variablesProviderMock.variables["variable"] = "1"
        variablesProviderMock.variables["isCheck"] = "false"
        variablesProviderMock.variables["Ducks"] = "Riri, Fifi, Loulou"

        let expression: Expression = [.bracket(.opening),
                                            .operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)),
                                      .logicOperator(.and),
                                            .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .bracket(.closing),
                                        .logicOperator(.or),
                                            .operand(.variable("Ducks")), .comparisonOperator(.contains), .operand(.string("Fifi"))]
        let expectedTokenizdExpression: Expression = [.bracket(.opening),
                                                            .operand(.boolean(false)),
                                                      .logicOperator(.and),
                                                            .operand(.boolean(false)),
                                                        .bracket(.closing),
                                                        .logicOperator(.or),
                                                            .operand(.boolean(true))]
        var sut = BooleanExpressionTokenizator(expression: expression, variablesProvider: variablesProviderMock)

        var tokenizedExpression = Expression()
        while let token = try? sut.nextToken() {
            tokenizedExpression.append(token)
        }

        XCTAssertEqual(tokenizedExpression, expectedTokenizdExpression)
    }

    // MARK: Evaluation

    func testEvaluateComparison_ThrowsErrorIfCountLesserThanThanThree() {
        do {
            _ = try sut.evaluate(comparison: [.operand(.variable("a")), .comparisonOperator(.equal)])
        } catch {
            guard error is ExpressionError else {
                XCTFail("Trying to evaluate a comparison which have less than three elements should throw an ExpressionError")
                return
            }
        }
     }

    func testEvaluateComparison_ThrowsErrorIfCountGreaterThanThree() {
       do {
            _ = try sut.evaluate(comparison: [.operand(.variable("a")), .comparisonOperator(.equal), .operand(.number(3)), .bracket(.closing)])
            XCTFail("Trying to evaluate a comparison which have more than three elements should throw an ExpressionError")
       } catch {
           guard error is ExpressionError else {
               XCTFail("Error thrown isn't an ExpressionError")
               return
           }
       }
    }

    func testEvaluateComparison_ThrowsErrorDoesntHaveComparisonOperator() {
       do {
            _ = try sut.evaluate(comparison: [.operand(.variable("a")), .logicOperator(.and), .operand(.number(3))])
            XCTFail("Trying to evaluate a comparison which doesn't have a comparison  operator should throw an ExpressionError")
       } catch {
           guard error is ExpressionError else {
               XCTFail("Error thrown isn't an ExpressionError")
               return
           }
       }
    }

    func testEvaluateComparison_ThrowsErrorUndefinedVariable() {
       do {
            _ = try sut.evaluate(comparison: [.operand(.variable("a")), .comparisonOperator(.equal), .operand(.number(3))])
            XCTFail("Evaluate a comparison with an undefined variable should throw ExpressionError.undefinedVariable")
       } catch {
            guard case ExpressionError.undefinedVariable(_) = error else {
                XCTFail("Evaluate a comparison with an undefined variable should throw ExpressionError.undefinedVariable")
                return
            }
       }
    }

    func testEvaluateComparison_ThrowsErrorIFNoVariableFoundAsOperand() {
       do {
            _ = try sut.evaluate(comparison: [.operand(.number(1)), .comparisonOperator(.equal), .operand(.number(3))])
            XCTFail("Trying to evaluate a comparison which doesn't have a variable as operand should throw an error")
       } catch {
           guard error is ExpressionError else {
               XCTFail("Error thrown isn't an ExpressionError")
               return
           }
       }
    }

    func testEvaluateComparison_EqualString() {
        variablesProviderMock.variables["variable"] = "Hello"

        let result = try? sut.evaluateCleanComparison(.variable("variable"), .equal, .string("Hello"))

        XCTAssertEqual(result, true)
    }

    func testEvaluateComparison_EqualNumber() {
        variablesProviderMock.variables["variable"] = "2.5"

        let result = try? sut.evaluateCleanComparison(.variable("variable"), .equal, .number(2.5))

        XCTAssertEqual(result, true)
    }

    func testEvaluateComparison_EqualBoolean() {
        variablesProviderMock.variables["variable"] = "true"

        let result = try? sut.evaluateCleanComparison(.variable("variable"), .equal, .boolean(true))

        XCTAssertEqual(result, true)
    }

    func testEvaluateComparison_GreaterNumber() {
        variablesProviderMock.variables["variable"] = "2.5"

        let result = try? sut.evaluateCleanComparison(.variable("variable"), .greaterThan, .number(2.0))

        XCTAssertEqual(result, true)
    }

    func testEvaluateComparison_LesserNumber() {
        variablesProviderMock.variables["variable"] = "2.5"

        let result = try? sut.evaluateCleanComparison(.variable("variable"), .greaterThan, .number(2.0))

        XCTAssertEqual(result, true)
    }

    func testEvaluateComparison_GreaterOrEqualNumber() {
        variablesProviderMock.variables["variable"] = "2.5"

        let result = try? sut.evaluateCleanComparison(.variable("variable"), .greaterThanOrEqual, .number(4))

        XCTAssertEqual(result, false)
    }

    func testEvaluateComparison_LesserOrEqualNumber() {
        variablesProviderMock.variables["variable"] = "2.5"

        let result = try? sut.evaluateCleanComparison(.variable("variable"), .lesserThanOrEqual, .number(4))

        XCTAssertEqual(result, true)
    }

    func testEvaluateComparisonVariables_Contains() {
        let result = try? sut.evaluate(leftVariableValue: "Riri, Fifi, Loulou", comparisonOperator: .contains, rightVariableValue: "Riri")

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
