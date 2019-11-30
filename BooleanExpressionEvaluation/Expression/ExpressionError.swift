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

public enum ExpressionError: Error, LocalizedError {
    /// General error for undefined errors
    case invalidExpression(String)
    case invalidStringQuotation(String)
    case invalidVariableName(String)
    case emptyExpression
    case undefinedVariable(String)
    case incorrectElement(String)
    case invalidGrammar(String)
    case unbalancedBrackets
    case mismatchingType
    case wrongOperatorAndOperandsAssociation

    public var errorDescription: String? {
        switch self {
        case .invalidExpression(let description): return description
        case .invalidStringQuotation(let string): return "Invalid string quotation: \(string)"
        case .invalidVariableName(let name): return "Invalid variable name or element: \(name). Variable name must start with a letter and can contains letters, numbers, - and _"
        case .emptyExpression: return "The expression should not be empty"
        case .undefinedVariable(let variable): return "Undefined variable: \(variable)"
        case .incorrectElement(let element): return "Incorrect element in the expression: \(element)"
        case .invalidGrammar(let string): return "Invalid elements chaining: \(string)"
        case .unbalancedBrackets: return "The expression contains unbaled brackets"
        case .mismatchingType: return "The types of the two operands mistmatch"
        case .wrongOperatorAndOperandsAssociation: return "The operator cannot be applied to the operands because they do not have the rigth type"
        }
    }
}
