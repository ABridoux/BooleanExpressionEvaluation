//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import BooleanExpressionEvaluation

class BooleanExpressionTokenizorTestsIntegration: XCTestCase {

    // MARK: - Properties

    var variables = [String: String]()

    // MARK: - Setup and Teardown

    override func tearDown() {
        variables.removeAll()
    }

    // MARK: - Functions

    func testTokenization1() {
        variables["variable"] = "1"
        variables["isCheck"] = "true"
        variables["input"] = "Test"

        let expression: Expression = [.bracket(.opening),
                                            .operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)),
                                      .logicInfixOperator(.and),
                                            .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .bracket(.closing),
                                        .logicInfixOperator(.or),
                                            .operand(.variable("input")), .comparisonOperator(.equal), .operand(.string("Test"))]
        let expectedTokenizedExpression: Expression = [.bracket(.opening),
                                                            .operand(.boolean(false)),
                                                      .logicInfixOperator(.and),
                                                            .operand(.boolean(true)),
                                                        .bracket(.closing),
                                                        .logicInfixOperator(.or),
                                                            .operand(.boolean(true))]
        var sut = BooleanExpressionTokenizator(expression: expression, variables: variables)

        var tokenizedExpression = Expression()
        while let token = try? sut.nextToken() {
            tokenizedExpression.append(token)
        }

        XCTAssertEqual(tokenizedExpression, expectedTokenizedExpression)
    }

    func testTokenization2() {
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
        let expectedTokenizdExpression: Expression = [.bracket(.opening),
                                                            .operand(.boolean(false)),
                                                      .logicInfixOperator(.and),
                                                            .operand(.boolean(false)),
                                                        .bracket(.closing),
                                                        .logicInfixOperator(.or),
                                                            .operand(.boolean(true))]
        var sut = BooleanExpressionTokenizator(expression: expression, variables: variables)

        var tokenizedExpression = Expression()
        while let token = try? sut.nextToken() {
            tokenizedExpression.append(token)
        }

        XCTAssertEqual(tokenizedExpression, expectedTokenizdExpression)
    }

}
