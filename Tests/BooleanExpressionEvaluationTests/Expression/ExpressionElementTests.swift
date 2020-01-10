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
        do {
            let element = try ExpressionElement.Operand(#""StringValue""#)
            XCTAssertEqual(element, ExpressionElement.Operand.string("StringValue"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testInitOperand_NumberInt() {
        do {
            let element = try ExpressionElement.Operand("2")
            XCTAssertEqual(element, ExpressionElement.Operand.number(2))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testInitOperand_NumberDouble() {
        do {
            let element = try ExpressionElement.Operand("2.45")
            XCTAssertEqual(element, .number(2.45))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testInitOperand_Bool() {
        XCTAssertEqual(try? ExpressionElement.Operand("true"), ExpressionElement.Operand.boolean(true))
        XCTAssertEqual(try? ExpressionElement.Operand("false"), ExpressionElement.Operand.boolean(false))
    }

    func testInitOperand_Variable() {
        do {
            let element = try ExpressionElement.Operand("User_input")
            XCTAssertEqual(element, ExpressionElement.Operand.variable("User_input"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testInitVariableFailsWithBracketPrefix() {
        XCTAssertThrowsError(try ExpressionElement.Operand("(variable"), "") { error in
            guard case ExpressionError.invalidVariableName = error else {
                XCTFail("Wrong variable name should throw ExpressionError.invalidVariableName")
                return
            }
        }
    }

    func testInitVariableFailsWithBracketSuffix() {
        XCTAssertThrowsError(try ExpressionElement.Operand("variable)"), "") { error in
            guard case ExpressionError.invalidVariableName = error else {
                XCTFail("Wrong variable name should throw ExpressionError.invalidVariableName")
                return
            }
        }
    }

    func testInitVariableFailsWithumberPrefix() {
        XCTAssertThrowsError(try ExpressionElement.Operand("1variable"), "") { error in
            guard case ExpressionError.invalidVariableName = error else {
                XCTFail("Wrong variable name should throw ExpressionError.invalidVariableName")
                return
            }
        }
    }
}
