//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import XCTest
@testable import BooleanExpressionEvaluation

final class StringExtensionsTests: XCTestCase {

    func testQuotedOperatorCharactersIdentity() {
        XCTAssertEqual("hasPrefix".quoted, "hasPrefix")
    }
}
