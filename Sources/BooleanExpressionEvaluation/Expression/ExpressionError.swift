//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

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
        case .invalidVariableName(let name): return #"Invalid variable name or element: "\#(name)""#
        case .emptyExpression: return "The expression should not be empty"
        case .undefinedVariable(let variable): return "Undefined variable: \(variable)"
        case .incorrectElement(let element): return #"Incorrect element in the expression: "\#(element)""#
        case .invalidGrammar(let string): return "Invalid elements chaining: \(string)"
        case .unbalancedBrackets: return "The expression contains unbaled brackets"
        case .mismatchingType: return "The types of the two operands mistmatch"
        case .wrongOperatorAndOperandsAssociation: return "The operator cannot be applied to the operands because they do not have the rigth type"
        }
    }
}
