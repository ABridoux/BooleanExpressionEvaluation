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

class ExpressionEvaluatorTests: XCTestCase {

    // MARK: - Properties

    let stubExpression: Expression = [.operand(.number(1))]
    var sut: ExpressionEvaluator!
    var variablesProviderMock: VariablesProviderMock!

    // MARK: Setup and Teardown

    override func setUp() {
        variablesProviderMock = VariablesProviderMock()
        sut = ExpressionEvaluator(expression: stubExpression, variablesProvider: variablesProviderMock)
    }

    override func tearDown() {
        variablesProviderMock = nil
        sut = nil
    }

    // MARK: - Functions

    // MARK: Evaluate boolean expression

    func testEvaluateBooleanExpression1() {
        let booleanExpression = [HalfBooleanExpression(boolean: .boolean(true), logicOperator: .and),
                                 HalfBooleanExpression(boolean: .boolean(false), logicOperator: .or),
                                 HalfBooleanExpression(boolean: .boolean(false), logicOperator: nil)]

        let result = sut.evaluate(booleanExpression: booleanExpression)

        guard let resultBooleanElement = result?.boolean,
            case let .boolean(booleanResult) = resultBooleanElement else {
            XCTFail("The boolean expression has not properly been evaluated")
            return
        }
        XCTAssertFalse(booleanResult)
    }

    func testEvaluateBooleanExpression2() {
        let booleanExpression = [HalfBooleanExpression(boolean: .boolean(true), logicOperator: .and),
                                 HalfBooleanExpression(boolean: .boolean(true), logicOperator: .or),
                                 HalfBooleanExpression(boolean: .boolean(false), logicOperator: nil)]

        let result = sut.evaluate(booleanExpression: booleanExpression)

        guard let resultBooleanElement = result?.boolean,
            case let .boolean(booleanResult) = resultBooleanElement else {
            XCTFail("The boolean expression has not properly been evaluated")
            return
        }
        XCTAssertTrue(booleanResult)
    }

    func testEvaluateBooleanExpression3() {
        let booleanExpression = [HalfBooleanExpression(boolean: .boolean(false), logicOperator: .or),
                                 HalfBooleanExpression(boolean: .boolean(true), logicOperator: .and),
                                 HalfBooleanExpression(boolean: .boolean(true), logicOperator: nil)]

        let result = sut.evaluate(booleanExpression: booleanExpression)

        guard let resultBooleanElement = result?.boolean,
            case let .boolean(booleanResult) = resultBooleanElement else {
            XCTFail("The boolean expression has not properly been evaluated")
            return
        }
        XCTAssertTrue(booleanResult)
    }

    func testEvaluateBooleanExpression4() {
        let booleanExpression = [HalfBooleanExpression(boolean: .boolean(false), logicOperator: .or),
                                 HalfBooleanExpression(boolean: .boolean(true), logicOperator: .and),
                                 HalfBooleanExpression(boolean: .boolean(true), logicOperator: .and),
                                 HalfBooleanExpression(boolean: .boolean(false), logicOperator: .or),
                                 HalfBooleanExpression(boolean: .boolean(true), logicOperator: nil)]

        let result = sut.evaluate(booleanExpression: booleanExpression)

        guard let resultBooleanElement = result?.boolean,
            case let .boolean(booleanResult) = resultBooleanElement else {
            XCTFail("The boolean expression has not properly been evaluated")
            return
        }
        XCTAssertTrue(booleanResult)
    }

    // MARK: Evaluate expression - Integration tests

    func testEvaluateExpression1() {
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

        var sut = ExpressionEvaluator(expression: expression, variablesProvider: variablesProviderMock)

        do {
            let result = try sut.evaluateExpression()
            XCTAssertTrue(result)
        } catch {
            XCTFail("Unable to evaluate the expression: \(error.localizedDescription)")
        }
    }

    func testEvaluateExpression2_UnbalancedBracket() {
        variablesProviderMock.variables["variable"] = "1"
        variablesProviderMock.variables["isCheck"] = "false"
        variablesProviderMock.variables["Ducks"] = "Riri, Fifi, Loulou"

        let expression: Expression = [  .operand(.variable("variable")), .comparisonOperator(.lesserThanOrEqual), .operand(.number(1.5)),
                                      .logicOperator(.and),
                                            .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .bracket(.closing),
                                        .logicOperator(.or),
                                            .operand(.variable("Ducks")), .comparisonOperator(.contains), .operand(.string("Fifi"))]

        var sut = ExpressionEvaluator(expression: expression, variablesProvider: variablesProviderMock)

        do {
            _ = try sut.evaluateExpression()
             XCTFail("The function should have thrown an unbalanced bracket error")
        } catch {
            guard case ExpressionError.unbalancedBrackets = error else {
                XCTFail("The function should have thrown an unbalanced bracket error")
                return
            }
        }
    }

    func testEvaluateExpression2_UndefinedVariable() {
        variablesProviderMock.variables["variable"] = "1"
        variablesProviderMock.variables["isCheck"] = "false"
        variablesProviderMock.variables["Ducks"] = "Riri, Fifi, Loulou"

        let expression: Expression = [  .operand(.variable("variable")), .comparisonOperator(.lesserThanOrEqual), .operand(.number(1.5)),
                                      .logicOperator(.and),
                                            .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .logicOperator(.or),
                                            .operand(.variable("Ducks")), .comparisonOperator(.contains), .operand(.variable("Fifi"))]

        var sut = ExpressionEvaluator(expression: expression, variablesProvider: variablesProviderMock)

        do {
            let result = try sut.evaluateExpression()
            XCTAssertFalse(result)
        } catch {
            XCTFail("Unable to evaluate the expression: \(error.localizedDescription)")
        }
    }

    func testEvaluateExpression2_UselessBrackets1() {
        variablesProviderMock.variables["variable"] = "1"
        variablesProviderMock.variables["isCheck"] = "false"
        variablesProviderMock.variables["Ducks"] = "Riri, Fifi, Loulou"

         let expression: Expression = [.bracket(.opening),
                                            .operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)),
                                        .logicOperator(.and),
                                        .bracket(.opening),
                                            .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .logicOperator(.or),
                                            .operand(.variable("Ducks")), .comparisonOperator(.contains), .operand(.string("Fifi")),
                                        .bracket(.closing),
                                        .bracket(.closing)]

        var sut = ExpressionEvaluator(expression: expression, variablesProvider: variablesProviderMock)

        do {
            let result = try sut.evaluateExpression()
            XCTAssertFalse(result)
        } catch {
            XCTFail("Unable to evaluate the expression: \(error.localizedDescription)")
        }
    }

    func testEvaluateExpression2_UselessBrackets2() {
        variablesProviderMock.variables["variable"] = "1"
        variablesProviderMock.variables["isCheck"] = "false"
        variablesProviderMock.variables["Ducks"] = "Riri, Fifi, Loulou"

         let expression: Expression = [.bracket(.opening), .bracket(.opening), .bracket(.opening),
                                            .operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)),
                                        .logicOperator(.and),
                                            .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .logicOperator(.or),
                                            .operand(.variable("Ducks")), .comparisonOperator(.contains), .operand(.string("Fifi")),
                                        .bracket(.closing), .bracket(.closing), .bracket(.closing)]

        var sut = ExpressionEvaluator(expression: expression, variablesProvider: variablesProviderMock)

        do {
            let result = try sut.evaluateExpression()
            XCTAssertTrue(result)
        } catch {
            XCTFail("Unable to evaluate the expression: \(error.localizedDescription)")
        }
    }

    func testEvaluateExpression2_DebtTrueOr() {
        variablesProviderMock.variables["variable"] = "1"
        variablesProviderMock.variables["isCheck"] = "false"
        variablesProviderMock.variables["Ducks"] = "Riri, Fifi, Loulou"

        let expression: Expression = [.operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(0.5)),
                                      .logicOperator(.or),
                                      .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                      .logicOperator(.and),
                                      .operand(.variable("Ducks")), .comparisonOperator(.contains), .operand(.string("Fifi")),]

        var sut = ExpressionEvaluator(expression: expression, variablesProvider: variablesProviderMock)

        do {
            let result = try sut.evaluateExpression()
            XCTAssertTrue(result)
        } catch {
            XCTFail("Unable to evaluate the expression: \(error.localizedDescription)")
        }
    }

    // MARK: Evaluate strings - Integration tests

    func testEvaluateString1() {
        variablesProviderMock.variables["variable"] = "1"
        variablesProviderMock.variables["isCheck"] = "false"
        variablesProviderMock.variables["Ducks"] = "Riri, Fifi, Loulou"
        let expressionString = #"(variable == 1 && isCheck == false) || Ducks :: "Fifi""#

        guard var sut = try? ExpressionEvaluator(string: expressionString, variablesProvider: variablesProviderMock) else {
            XCTFail("Unable to init an ExpressionEvaluator from this expression: \(expressionString)")
            return
        }

        do {
            let result = try sut.evaluateExpression()
            XCTAssertTrue(result)
        } catch {
            XCTFail("Unable to evaluate the expression: \(error.localizedDescription)")
        }
    }

    func testEvaluateString2() {
        variablesProviderMock.variables["variable"] = "1"
        variablesProviderMock.variables["isCheck"] = "false"
        variablesProviderMock.variables["Ducks"] = "Riri, Fifi,  Loulou"
        variablesProviderMock.variables["duck"] = "Riri"
        let expressionString = #"variable == 1 || isCheck == true && Ducks :: duck"#

        guard var sut = try? ExpressionEvaluator(string: expressionString, variablesProvider: variablesProviderMock) else {
            XCTFail("Unable to init an ExpressionEvaluator from this expression: \(expressionString)")
            return
        }

        do {
            let result = try sut.evaluateExpression()
            XCTAssertTrue(result)
        } catch {
            XCTFail("Unable to evaluate the expression: \(error.localizedDescription)")
        }
    }

    func testEvaluateString_WtihDebt() {
        variablesProviderMock.variables["variable"] = "1"
        variablesProviderMock.variables["isCheck"] = "false"
        variablesProviderMock.variables["Ducks"] = "Riri, Fifi,  Loulou"
        variablesProviderMock.variables["duck"] = "Riri"
        let expressionString = #"variable != 1 || isCheck != true && Ducks :: duck"#

        guard var sut = try? ExpressionEvaluator(string: expressionString, variablesProvider: variablesProviderMock) else {
            XCTFail("Unable to init an ExpressionEvaluator from this expression: \(expressionString)")
            return
        }

        do {
            let result = try sut.evaluateExpression()
            XCTAssertFalse(result)
        } catch {
            XCTFail("Unable to evaluate the expression: \(error.localizedDescription)")
        }
    }
}
