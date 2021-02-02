//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import BooleanExpressionEvaluation
import XCTest

extension XCTestCase {

    func XCTAssertErrorsEqual<T>(_ expression: @autoclosure () throws -> T,
                               _ expectedError: ExpressionError,
                               file: StaticString = #file, line: UInt = #line) {
        XCTAssertThrowsError(
        _ = try expression(), "", file: file, line: line) { error in
             guard
                let errorThrown = error as? ExpressionError,
                errorThrown == expectedError
            else {
                XCTFail("The expression did not throw the error \(expectedError). Error thrown: \(error)", file: file, line: line)
                return
            }
        }
    }

    func XCTAssertErrorsEqual<T>(_ expression: @autoclosure () throws -> T,
                               file: StaticString = #file, line: UInt = #line,
                               using testFunction: (ExpressionError) -> Bool) {
        XCTAssertThrowsError(
        _ = try expression(), "", file: file, line: line) { error in
             guard
                let errorThrown = error as? ExpressionError,
                testFunction(errorThrown)
            else {
                XCTFail("The error test function did not validate. Error thrown: \(error)", file: file, line: line)
                return
            }
        }
    }
}
