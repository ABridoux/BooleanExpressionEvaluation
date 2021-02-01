//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import BooleanExpressionEvaluation

class VariablePatternTestsIntegration: XCTestCase {

    // MARK: - Constants

    let variablesRegexPattern = "[a-zA-Z#]{1}[a-zA-Z0-9#]+"

    func test1() {
        let expression = try? Expression("#variable >= 2", variablesRegexPattern: variablesRegexPattern)
        let expectedExpression: Expression = [.operand(.variable("#variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(2))]

        XCTAssertEqual(expression, expectedExpression)
    }

    func test2() {
        XCTAssertThrowsError(try Expression("#variable -= 2", variablesRegexPattern: variablesRegexPattern), "") { error in
            guard case let ExpressionError.incorrectElement(element) = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(element, " -= ")
        }
    }
}
