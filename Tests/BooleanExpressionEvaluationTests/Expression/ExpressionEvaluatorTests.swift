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

    func testEvaluateBooleanExpression1() throws {
        let booleanExpression = [HalfBooleanExpression(boolean: true, logicOperator: .and),
                                 HalfBooleanExpression(boolean: false, logicOperator: .or),
                                 HalfBooleanExpression(boolean: false, logicOperator: nil)]

        let result = sut.evaluate(booleanExpression: booleanExpression)

        let booleanResult = try XCTUnwrap(result?.boolean)
        XCTAssertFalse(booleanResult)
    }

    func testEvaluateBooleanExpression2() throws {
        let booleanExpression = [HalfBooleanExpression(boolean: true, logicOperator: .and),
                                 HalfBooleanExpression(boolean: true, logicOperator: .or),
                                 HalfBooleanExpression(boolean: false, logicOperator: nil)]

        let result = sut.evaluate(booleanExpression: booleanExpression)

        let booleanResult = try XCTUnwrap(result?.boolean)
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

    func testEvaluateBooleanExpression4() throws {
        let booleanExpression = [HalfBooleanExpression(boolean: false, logicOperator: .or),
                                 HalfBooleanExpression(boolean: true, logicOperator: .and),
                                 HalfBooleanExpression(boolean: true, logicOperator: .and),
                                 HalfBooleanExpression(boolean: false, logicOperator: .or),
                                 HalfBooleanExpression(boolean: true, logicOperator: nil)]

        let result = sut.evaluate(booleanExpression: booleanExpression)

        let booleanResult = try XCTUnwrap(result?.boolean)
        XCTAssertTrue(booleanResult)
    }

    // MARK: Evaluate expression - Integration tests

    func testEvaluateExpression() throws {
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi, Loulou"

        let expression: Expression = [.bracket(.opening),
                                            .operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)),
                                      .logicInfixOperator(.and),
                                            .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .bracket(.closing),
                                        .logicInfixOperator(.or),
                                        .operand(.string("Fifi")), .comparisonOperator(.isIn), .operand(.variable("Ducks"))]

        var sut = ExpressionEvaluator(expression: expression, variables: variables)

        XCTAssertTrue(try sut.evaluateExpression())
    }

    func testEvaluateExpression_UnbalancedBracketThrowsError() {
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi, Loulou"

        let expression: Expression = [  .operand(.variable("variable")), .comparisonOperator(.lesserThanOrEqual), .operand(.number(1.5)),
                                      .logicInfixOperator(.and),
                                            .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .bracket(.closing),
                                        .logicInfixOperator(.or),
                                            .operand(.variable("Ducks")), .comparisonOperator(.isIn), .operand(.string("Fifi"))]

        var sut = ExpressionEvaluator(expression: expression, variables: variables)

        XCTAssertErrorsEqual(try sut.evaluateExpression(), .unbalancedBrackets)
    }

    func testEvaluateExpression_UndefinedVariable() throws {
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi, Loulou"

        let expression: Expression = [  .operand(.variable("variable")), .comparisonOperator(.lesserThanOrEqual), .operand(.number(1.5)),
                                      .logicInfixOperator(.and),
                                            .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .logicInfixOperator(.or),
                                            .operand(.variable("Ducks")), .comparisonOperator(.isIn), .operand(.variable("Fifi"))]
        var sut = ExpressionEvaluator(expression: expression, variables: variables)

        XCTAssertErrorsEqual(try sut.evaluateExpression(), .undefinedVariable("Fifi"))
    }

    func testEvaluateExpression_UselessBrackets1() throws {
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi, Loulou"

         let expression: Expression = [.bracket(.opening),
                                            .operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)),
                                        .logicInfixOperator(.and),
                                        .bracket(.opening),
                                            .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .logicInfixOperator(.or),
                                            .operand(.variable("Ducks")), .comparisonOperator(.isIn), .operand(.string("Fifi")),
                                        .bracket(.closing),
                                        .bracket(.closing)]

        var sut = ExpressionEvaluator(expression: expression, variables: variables)

        let result = try sut.evaluateExpression()
        XCTAssertFalse(result)
    }

    func testEvaluateExpression_UselessBrackets2() throws {
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi, Loulou"

         let expression: Expression = [.bracket(.opening), .bracket(.opening), .bracket(.opening),
                                            .operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)),
                                        .logicInfixOperator(.and),
                                            .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .logicInfixOperator(.or),
                                        .operand(.string("Fifi")), .comparisonOperator(.isIn), .operand(.variable("Ducks")),
                                        .bracket(.closing), .bracket(.closing), .bracket(.closing)]

        var sut = ExpressionEvaluator(expression: expression, variables: variables)

        let result = try sut.evaluateExpression()
        XCTAssertTrue(result)
    }

    func testEvaluateExpression_DebtTrueOr() throws {
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi, Loulou"

        let expression: Expression = [.operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(0.5)),
                                      .logicInfixOperator(.or),
                                      .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                      .logicInfixOperator(.and),
                                      .operand(.variable("Ducks")), .comparisonOperator(.isIn), .operand(.string("Fifi")) ]

        var sut = ExpressionEvaluator(expression: expression, variables: variables)

        let result = try sut.evaluateExpression()
        XCTAssertTrue(result)
    }
}
