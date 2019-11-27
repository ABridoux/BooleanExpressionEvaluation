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

import Foundation

/// Represents a boolean expression as an array of `ExpressionElements`
public typealias Expression = [ExpressionElement]

public extension Expression {

    init(_ stringExpression: String) throws {
        var evaluatedExpression = [ExpressionElement]()
        for element in stringExpression.split(separator: " ") {
            // remove the bracket if present as a prefix or suffiix of the element as they are authorized to be written without spacing
            var addClosingBracket = false
            var elementWithoutBrackets = String(element)

            // > 1 otherwise it is a sole bracket
            if elementWithoutBrackets.hasPrefix("("), element.count > 1 {
                evaluatedExpression.append(.bracket(.opening))
                elementWithoutBrackets.removeFirst()
            }
            if elementWithoutBrackets.hasSuffix(")"), element.count > 1 {
                addClosingBracket = true
                elementWithoutBrackets.removeLast()
            }

            if let element = ExpressionElement(element: elementWithoutBrackets) {
                evaluatedExpression.append(element)
            } else {
                throw ExpressionError.incorrectElement(elementWithoutBrackets)
            }

            if addClosingBracket {
                evaluatedExpression.append(.bracket(.closing))
            }
        }
        guard !evaluatedExpression.isEmpty else {
            throw ExpressionError.emptyExpression
        }
        self = evaluatedExpression
    }
}
