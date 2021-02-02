//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import BooleanExpressionEvaluation

class ExpressionEvaluatorTestsIntegration: XCTestCase {

    // MARK: - Properties

    var variables = [String: String]()

    // MARK: - Setup and Teardown

    override func tearDown() {
        variables.removeAll()
    }

    // MARK: - Functions

    func testEvaluateString1() throws {
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi, Loulou"
        let expressionString = #"(variable == 1 && isCheck == false) || Ducks <: "Fifi""#
        var sut = try ExpressionEvaluator(string: expressionString, variables: variables)

        let result = try XCTUnwrap(sut?.evaluateExpression())

        XCTAssertTrue(result)
    }

    func testEvaluateString2() throws {
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi,  Loulou"
        variables["duck"] = "Riri"
        let expressionString = #"variable == 1 || isCheck && Ducks <: duck"#
        var sut = try ExpressionEvaluator(string: expressionString, variables: variables)

        let result = try XCTUnwrap(sut?.evaluateExpression())

        XCTAssertTrue(result)
    }

    func testEvaluateString3() throws {
        variables["name"] = "Benjamin Daniel or Benzaïe"
        variables["isCheck"] = "true"
        variables["isUserAWizard"] = "true"
        let expressionString = #"name == "Benjamin Daniel or Benzaïe" && isCheck && isUserAWizard"#
        var sut = try ExpressionEvaluator(string: expressionString, variables: variables)

        let result = try XCTUnwrap(sut?.evaluateExpression())

        XCTAssertTrue(result)
    }

    func testEvaluateString3SingleQuotes() throws {
        variables["name"] = "Benjamin Daniel or Benzaïe"
        variables["isCheck"] = "true"
        variables["isUserAWizard"] = "true"
        let expressionString = #"name == 'Benjamin Daniel or Benzaïe' && isCheck && isUserAWizard"#
        var sut = try ExpressionEvaluator(string: expressionString, variables: variables)

        let result = try XCTUnwrap(sut?.evaluateExpression())

        XCTAssertTrue(result)
    }

    func testEvaluateString_WithDebt() throws {
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi,  Loulou"
        variables["duck"] = "Riri"
        let expressionString = #"variable != 1 || isCheck != true && Ducks <: duck"#
        var sut = try ExpressionEvaluator(string: expressionString, variables: variables)

        let result = try XCTUnwrap(sut?.evaluateExpression())

        XCTAssertTrue(result)
    }

    func testEvaluateDoubleString() throws {
        variables["variable"] = "Installed"
        variables["var2"] = "Installed"
        let expressionString = #"variable != "Installed" && var2 == "Installed""#
        var sut = try ExpressionEvaluator(string: expressionString, variables: variables)

        let result = try XCTUnwrap(sut?.evaluateExpression())

        XCTAssertFalse(result)
    }

    func testEvaluateNotOperatorSingleVariable() throws {
        variables["bool"] = "true"
        let expressionString = "!bool"
        var sut = try ExpressionEvaluator(string: expressionString, variables: variables)

        let result = try XCTUnwrap(sut?.evaluateExpression())

        XCTAssertFalse(result)
    }

    func testEvaluateNotOperatorSingleExpression() throws {
        variables["variable"] = "10"
        let expressionString = "!(variable != 10)"
        var sut = try ExpressionEvaluator(string: expressionString, variables: variables)

        let result = try XCTUnwrap(sut?.evaluateExpression())

        XCTAssertTrue(result)
    }

    func testEvaluateNotOperatorDoubleExpression() throws {
        variables["variable"] = "10"
        variables["isReady"] = "true"
        let expressionString = "!(variable == 10 && isReady)"
        var sut = try ExpressionEvaluator(string: expressionString, variables: variables)

        let result = try XCTUnwrap(sut?.evaluateExpression())

        XCTAssertFalse(result)
    }

    func testEvaluateNotOperatorDoubleExpressionWithInvertedBool() throws {
        variables["variable"] = "10"
        variables["isReady"] = "true"
        let expressionString = "!(variable == 10 && !isReady)"
        var sut = try ExpressionEvaluator(string: expressionString, variables: variables)

        let result = try XCTUnwrap(sut?.evaluateExpression())

        XCTAssertTrue(result)
    }
}
