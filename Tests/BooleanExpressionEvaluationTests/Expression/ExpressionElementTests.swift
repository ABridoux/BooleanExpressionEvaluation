//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import BooleanExpressionEvaluation

class ExpressionElementTests: XCTestCase {

    func testInitOperand_StringDoubleQuotes() {
        do {
            let element = try ExpressionElement.Operand(#""StringValue""#)
            XCTAssertEqual(element, ExpressionElement.Operand.string("StringValue"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testInitOperand_StringSingleQuotes() {
        do {
            let element = try ExpressionElement.Operand("'StringValue'")
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
