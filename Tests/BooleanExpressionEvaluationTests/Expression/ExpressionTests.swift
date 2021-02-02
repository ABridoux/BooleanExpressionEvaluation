//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

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
                                      .logicInfixOperator(.and),
                                      .operand(.variable("input")), .comparisonOperator(.equal), .operand(.string("Test"))]
        test(#"variable >= 1.5 && input == "Test""#, expression)
    }

    func testInit_Brackets() {
        let expression: Expression = [.bracket(.opening),
                                      .operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)),
                                      .logicInfixOperator(.and),
                                        .operand(.variable("isCheck")), .comparisonOperator(.equal), .operand(.boolean(true)),
                                        .bracket(.closing),
                                      .logicInfixOperator(.or),
                                      .operand(.variable("input")), .comparisonOperator(.equal), .operand(.string("Test"))]

        test(#"(variable >= 1.5 && isCheck == true) || input == "Test""#, expression)
    }

    func testInit_ThrowsAnErrorIfIncorrectElement() throws {
        let string = "variable = 2*"

        XCTAssertErrorsEqual(try Expression(string), .invalidVariableName("="))
    }

    func testInit_ThrowsAnErrorIfEmptyExpression() {
        XCTAssertErrorsEqual(_ = try Expression(""), .emptyExpression)
    }

    func testInit_StringWithSpace() throws {
        let string = #"variable == "String with space""#
        let expression = try Expression(string)

        XCTAssertEqual(expression, [.operand(.variable("variable")), .comparisonOperator(.equal), .operand(.string("String with space"))])
    }

    func testInit_StringExtraSpaces() throws {
        let string = #"variable == " String with space " "#
        let expression = try Expression(string)

        XCTAssertEqual(expression, [.operand(.variable("variable")), .comparisonOperator(.equal), .operand(.string(" String with space "))])
    }

    func testNotOperator() throws {
        let string = #"!variable"#

        let expression = try Expression(string)

        let expectedExpression = Expression(.logicPrefixOperator(.not), .operand(.variable("variable")))
        XCTAssertEqual(expression, expectedExpression)
    }

    func testNotOperatorBeforeBrackets() throws {
        let string = #"!(variable == 2)"#

        let expression = try Expression(string)

        let expectedExpression = Expression(.logicPrefixOperator(.not),
                                            .bracket(.opening),
                                            .operand(.variable("variable")), .comparisonOperator(.equal), .operand(.number(2)),
                                            .bracket(.closing))
        XCTAssertEqual(expression, expectedExpression)
    }

    // MARK: Codable

    func testCanDecodeFromString() throws {
        let data = try JSONEncoder().encode("(variable >= 1.5)")
        let decoder = JSONDecoder()
        let expression = try? decoder.decode(Expression.self, from: data)

        XCTAssertEqual(expression, [.bracket(.opening), .operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)), .bracket(.closing)])
    }

    func testCanEncodeToString() throws {
        let expression: Expression = [.bracket(.opening), .operand(.variable("variable")), .comparisonOperator(.greaterThanOrEqual), .operand(.number(1.5)), .bracket(.closing)]
        let data = try JSONEncoder().encode(expression)

        let stringExpression = try JSONDecoder().decode(String.self, from: data)

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
