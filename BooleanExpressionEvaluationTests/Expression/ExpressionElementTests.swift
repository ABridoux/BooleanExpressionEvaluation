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

class ExpressionElementTests: XCTestCase {

    func testInitOperand_String() {
        XCTAssertEqual(ExpressionElement.Operand(#""StringValue""#), ExpressionElement.Operand.string("StringValue"))
    }

    func testInitOperand_NumberInt() {
        XCTAssertEqual(ExpressionElement.Operand("2"), ExpressionElement.Operand.number(2))
    }

    func testInitOperand_NumberDouble() {
        XCTAssertEqual(ExpressionElement.Operand("2.45"), .number(2.45))
    }

    func testInitOperand_Bool() {
        XCTAssertEqual(ExpressionElement.Operand("true"), ExpressionElement.Operand.boolean(true))
        XCTAssertEqual(ExpressionElement.Operand("false"), ExpressionElement.Operand.boolean(false))
    }

    func testInitOperand_Variable() {
        XCTAssertEqual(ExpressionElement.Operand("User_input"), ExpressionElement.Operand.variable("User_input"))
    }

    func testInitVariableFailsWithBracketPrefix() {
        XCTAssertNil(ExpressionElement.Operand("(variable"))
    }

    func testInitVariableFailsWithBracketSuffix() {
        XCTAssertNil(ExpressionElement.Operand("variable)"))
    }

    func testInitVariableFailsWithumberPrefix() {
        XCTAssertNil(ExpressionElement.Operand("1variable"))
    }
}
