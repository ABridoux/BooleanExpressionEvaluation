//
//  ExpressionEvaluatorTestsIntegration.swift
//  BooleanExpressionEvaluationTests
//
//  Created by Alexis Bridoux on 30/11/2019.
//  Copyright © 2019 Alexis Bridoux. All rights reserved.
//

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

    func testEvaluateString1() {
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi, Loulou"
        let expressionString = #"(variable == 1 && isCheck == false) || Ducks <: "Fifi""#

        guard var sut = try? ExpressionEvaluator(string: expressionString, variables: variables) else {
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
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi,  Loulou"
        variables["duck"] = "Riri"
        let expressionString = #"variable == 1 || isCheck == true && Ducks <: duck"#

        guard var sut = try? ExpressionEvaluator(string: expressionString, variables: variables) else {
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

    func testEvaluateString3() {
        variables["name"] = "Benjamin Daniel or Benzaïe"
        variables["isCheck"] = "true"
        let expressionString = #"name == "Benjamin Daniel or Benzaïe" && isCheck"#

        guard var sut = try? ExpressionEvaluator(string: expressionString, variables: variables) else {
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
        variables["variable"] = "1"
        variables["isCheck"] = "false"
        variables["Ducks"] = "Riri, Fifi,  Loulou"
        variables["duck"] = "Riri"
        let expressionString = #"variable != 1 || isCheck != true && Ducks <: duck"#

        guard var sut = try? ExpressionEvaluator(string: expressionString, variables: variables) else {
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
}
