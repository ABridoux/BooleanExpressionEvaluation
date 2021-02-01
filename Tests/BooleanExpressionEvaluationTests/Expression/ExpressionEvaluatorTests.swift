//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import BooleanExpressionEvaluation

class ExpressionEvaluatorTests: XCTestCase {

    // MARK: - Properties

    let stubExpression: Expression = [.operand(.number(1))]
    var sut: ExpressionEvaluator!
    var variables = [String: String]()

    // MARK: - Setup and Teardown

    override func setUp() {
        sut = ExpressionEvaluator(expression: stubExpression, variables: variables)
    }

    override func tearDown() {
        variables.removeAll()
        sut = nil
    }

    // MARK: - Functions

    // MARK: Evaluate boolean expression

    func testEvaluateBooleanExpression1() {
        let booleanExpression = [HalfBooleanExpression(boolean: true, logicOperator: .and),
                                 HalfBooleanExpression(boolean: false, logicOperator: .or),
                                 HalfBooleanExpression(boolean: false, logicOperator: nil)]

        let result = sut.evaluate(booleanExpression: booleanExpression)

        guard let booleanResult = result?.boolean else {
            XCTFail("The boolean expression has not properly been evaluated")
            return
        }
        XCTAssertFalse(booleanResult)
    }

    func testEvaluateBooleanExpression2() {
        let booleanExpression = [HalfBooleanExpression(boolean: true, logicOperator: .and),
                                 HalfBooleanExpression(boolean: true, logicOperator: .or),
                                 HalfBooleanExpression(boolean: false, logicOperator: nil)]

        let result = sut.evaluate(booleanExpression: booleanExpression)

        guard let booleanResult = result?.boolean else {
            XCTFail("The boolean expression has not properly been evaluated")
            return
        }
        XCTAssertTrue(booleanResult)
    }

    func testEvaluateBooleanExpression3() {
        let booleanExpression = [HalfBooleanExpression(boolean: false, logicOperator: .or),
                                 HalfBooleanExpression(boolean: true, logicOperator: .and),
                                 HalfBooleanExpression(boolean: true, logicOperator: nil)]

        let result = sut.evaluate(booleanExpression: booleanExpression)

        guard let booleanResult = result?.boolean else {
            XCTFail("The boolean expression has nt properly beened")
            return
        }
        XCTAssertTrue(booleanResult)
    }

    func testEvaluateBooleanExpression4() {
        let booleanExpression = [HalfBooleanExpression(boolean: false, logicOperator: .or),
                                 HalfBooleanExpression(boolean: true, logicOperator: .and),
                                 HalfBooleanExpression(boolean: true, logicOperator: .and),
                                 HalfBooleanExpression(boolean: false, logicOperator: .or),
                                 HalfBooleanExpression(boolean: true, logicOperator: nil)]

        let result = sut.evaluate(booleanExpression: booleanExpression)

        guard let booleanResult = result?.boolean else {
            XCTFail("The boolean expression has not properly been evaluated")
            return
        }
        XCTAssertTrue(booleanResult)
    }

    // MARK: Evaluate expression - Integration tests

    func testEvaluateExpression1() {
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi, Loulou"

        let expression: Expression = [.bracket(.opening),
                                            .operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)),
                                      .logicOperator(.and),
                                            .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .bracket(.closing),
                                        .logicOperator(.or),
                                            .operand(.variable("Ducks")), .comparisonOperator(.contains), .operand(.string("Fifi"))]

        var sut = ExpressionEvaluator(expression: expression, variables: variables)

        do {
            let result = try sut.evaluateExpression()
            XCTAssertTrue(result)
        } catch {
            XCTFail("Unable to evaluate the expression: \(error.localizedDescription)")
        }
    }

    func testEvaluateExpression2_UnbalancedBracketThrowsError() {
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi, Loulou"

        let expression: Expression = [  .operand(.variable("variable")), .comparisonOperator(.lesserThanOrEqual), .operand(.number(1.5)),
                                      .logicOperator(.and),
                                            .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .bracket(.closing),
                                        .logicOperator(.or),
                                            .operand(.variable("Ducks")), .comparisonOperator(.contains), .operand(.string("Fifi"))]

        var sut = ExpressionEvaluator(expression: expression, variables: variables)
        XCTAssertThrowsError(try sut.evaluateExpression(), "") { error in
            guard case ExpressionError.unbalancedBrackets = error else {
                XCTFail("The function should have thrown an unbalanced bracket error")
                return
            }
        }
    }

    func testEvaluateExpression2_UndefinedVariable() {
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi, Loulou"

        let expression: Expression = [  .operand(.variable("variable")), .comparisonOperator(.lesserThanOrEqual), .operand(.number(1.5)),
                                      .logicOperator(.and),
                                            .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .logicOperator(.or),
                                            .operand(.variable("Ducks")), .comparisonOperator(.contains), .operand(.variable("Fifi"))]

        var sut = ExpressionEvaluator(expression: expression, variables: variables)

        do {
            let result = try sut.evaluateExpression()
            XCTAssertFalse(result)
        } catch {
            XCTFail("Unable to evaluate the expression: \(error.localizedDescription)")
        }
    }

    func testEvaluateExpression2_UselessBrackets1() {
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi, Loulou"

         let expression: Expression = [.bracket(.opening),
                                            .operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)),
                                        .logicOperator(.and),
                                        .bracket(.opening),
                                            .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .logicOperator(.or),
                                            .operand(.variable("Ducks")), .comparisonOperator(.contains), .operand(.string("Fifi")),
                                        .bracket(.closing),
                                        .bracket(.closing)]

        var sut = ExpressionEvaluator(expression: expression, variables: variables)

        do {
            let result = try sut.evaluateExpression()
            XCTAssertFalse(result)
        } catch {
            XCTFail("Unable to evaluate the expression: \(error.localizedDescription)")
        }
    }

    func testEvaluateExpression2_UselessBrackets2() {
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi, Loulou"

         let expression: Expression = [.bracket(.opening), .bracket(.opening), .bracket(.opening),
                                            .operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)),
                                        .logicOperator(.and),
                                            .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .logicOperator(.or),
                                            .operand(.variable("Ducks")), .comparisonOperator(.contains), .operand(.string("Fifi")),
                                        .bracket(.closing), .bracket(.closing), .bracket(.closing)]

        var sut = ExpressionEvaluator(expression: expression, variables: variables)

        do {
            let result = try sut.evaluateExpression()
            XCTAssertTrue(result)
        } catch {
            XCTFail("Unable to evaluate the expression: \(error.localizedDescription)")
        }
    }

    func testEvaluateExpression2_DebtTrueOr() {
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi, Loulou"

        let expression: Expression = [.operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(0.5)),
                                      .logicOperator(.or),
                                      .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                      .logicOperator(.and),
                                      .operand(.variable("Ducks")), .comparisonOperator(.contains), .operand(.string("Fifi")),]

        var sut = ExpressionEvaluator(expression: expression, variables: variables)

        do {
            let result = try sut.evaluateExpression()
            XCTAssertTrue(result)
        } catch {
            XCTFail("Unable to evaluate the expression: \(error.localizedDescription)")
        }
    }
}
