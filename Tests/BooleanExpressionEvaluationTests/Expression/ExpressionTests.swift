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

class ExpressionTests: XCTestCase {

    // MARK: - Functions

    func testInit_Minimum() {
        let expression: Expression = [.operand(.variable("variable")), .comparisonOperator(.equal), .operand(.number(2))]
        test("variable == 2", expression)
    }

    func testInit_MinimumWithExtraSpace() {
        let expression: Expression = [.operand(.variable("variable")), .comparisonOperator(.equal), .operand(.number(2))]
        test("variable  == 2", expression)
    }

    func testInit_MinimumWithExtraSpaceAfterBracket() {
        let expression: Expression = [.bracket(.opening), .operand(.variable("variable")), .comparisonOperator(.equal), .operand(.number(2)), .bracket(.closing)]
        test("( variable == 2)", expression)
    }

    func testInit_TwoOperands() {
        let expression: Expression = [.operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)),
                                      .logicOperator(.and),
                                      .operand(.variable("input")), .comparisonOperator(.equal), .operand(.string("Test"))]
        test(#"variable >= 1.5 && input == "Test""#, expression)
    }

    func testInit_Brackets() {
        let expression: Expression = [.bracket(.opening),
                                      .operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)),
                                      .logicOperator(.and),
                                        .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .bracket(.closing),
                                      .logicOperator(.or),
                                      .operand(.variable("input")), .comparisonOperator(.equal), .operand(.string("Test"))]
        test(#"(variable >= 1.5 && isCheck == true) || input == "Test""#, expression)
    }

    func testInit_ThrowsAnErrorIfIncorrectElement() {
        let string = "variable = 2*"
        do {
            _ = try Expression(string)
            XCTFail("Initializing the expression with an incorrect string should throw an error")
        } catch {
            guard case ExpressionError.invalidVariableName(_) = error else {
                XCTFail("Initizalizing an Expression with an empty string should have thrown a ExpressionError.invalidVariableName error")
                return
            }
        }
    }

    func testInit_ThrowsAnErrorIfEmptyExpression() {
        do {
            _ = try Expression("")
            XCTFail("Initializing the expression with an incorrect string should throw an error")
        } catch {
            guard case ExpressionError.emptyExpression = error else {
                XCTFail("Initialasing an Expression with an empty string should have thrown a ExpressionError.emptyExpression error")
                return
            }
        }
    }

    func testInit_StringWithSpace() {
        let string = #"variable == "String with space""#
        do {
            let expression = try Expression(string)
            XCTAssertEqual(expression, [.operand(.variable("variable")), .comparisonOperator(.equal), .operand(.string("String with space"))])
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testInit_StringExtraSpaces() {
        let string = #"variable == " String with space " "#
        do {
            let expression = try Expression(string)
            XCTAssertEqual(expression, [.operand(.variable("variable")), .comparisonOperator(.equal), .operand(.string(" String with space "))])
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    // MARK: Codable

    func testCanDecodeFromString() {
        guard let data = try? JSONEncoder().encode("(variable >= 1.5)") else {
            XCTFail("Unable to encode a String ? Strange 🤔")
            return
        }
        let decoder = JSONDecoder()
        let expression = try? decoder.decode(Expression.self, from: data)

        XCTAssertEqual(expression, [.bracket(.opening), .operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)), .bracket(.closing)])
    }

    func testCanEncodeToString() {

        let expression: Expression = [.bracket(.opening), .operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)), .bracket(.closing)]
        let data: Data
        do {
            data = try JSONEncoder().encode(expression)
        } catch {
            XCTFail("Unable to encode the expression \(expression.description): \(error.localizedDescription)")
            return
        }

        let decoder = JSONDecoder()
        let stringExpression = try? decoder.decode(String.self, from: data)

        XCTAssertEqual(stringExpression, expression.description)
    }

    // MARK: Helpers

    func test(_ stringExpression: String, _ expectedExpression: Expression, file: StaticString = #file, line: UInt = #line) {
        do {
            let expression = try Expression(stringExpression)
            XCTAssertEqual(expression, expectedExpression, file: file, line: line)
        } catch {
            XCTFail(error.localizedDescription, file: file, line: line)
        }
    }
}
