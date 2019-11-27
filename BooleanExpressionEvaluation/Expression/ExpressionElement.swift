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

/// Represent an element in a boolean expression
public enum ExpressionElement: Equatable, CustomStringConvertible {

    case comparisonOperator(ComparisonOperator)
    case logicOperator(LogicOperator)
    case bracket(Bracket)
    case operand(Operand)

    public enum ComparisonOperator: String {
        case equal = "=="
        case nonEqual = "!="
        case greaterThan = ">"
        case greaterThanOrEqual = ">="
        case lesserThan = "<"
        case lesserThanOrEqual = "<="
        case contains = "::"

        func evaluate<T: Equatable>(_ leftOperand: T, _ rightOperand: T) -> Bool? {
            return leftOperand == rightOperand
        }

        func evaluate<T: Comparable>(_ leftOperand: T, _ rightOperand: T) -> Bool? {
            switch self {
            case .equal:
                return leftOperand == rightOperand
            case .nonEqual:
                return leftOperand != rightOperand
            case .greaterThan:
                return leftOperand > rightOperand
            case .greaterThanOrEqual:
                return leftOperand >= rightOperand
            case .lesserThan:
                return leftOperand < rightOperand
            case .lesserThanOrEqual:
                return leftOperand <= rightOperand
            case .contains:
                guard let leftString = leftOperand as? String,
                    let rightString = rightOperand as? String else { return false }
                let elements = leftString.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
                return elements.contains(rightString)
            }
        }
    }

    public enum LogicOperator: String {
        case or = "||"
        case and = "&&"

        func evaluate(_ leftBooleanElement: ExpressionElement.Operand, _ rightBooleanElement: ExpressionElement.Operand) -> ExpressionElement.Operand? {
            guard case let .boolean(leftBoolean) = leftBooleanElement,
            case let .boolean(rightBoolean) = rightBooleanElement else {
                return nil
            }
            switch self {
            case .and:
                return .boolean(leftBoolean && rightBoolean)
            case .or:
                return .boolean(leftBoolean || rightBoolean)
            }
        }
    }

    public enum Bracket: String {
        case opening = "("
        case closing = ")"
    }

    public enum Operand: Equatable, CustomStringConvertible {
        case variable(String)
        case string(String)
        case number(Double)
        case boolean(Bool)

        init?(_ element: String) {
            if element.first == "\"" && element.last == "\"" {
                var string = element
                string.removeFirst()
                string.removeLast()
                self = .string(string)
            } else if let double = Double(element) {
                self = .number(double)
            } else if let boolean = Bool(element) {
                self = .boolean(boolean)
            } else {
                guard let regex = try? NSRegularExpression(pattern: "[a-zA-Z]{1}[a-zA-Z0-9_-]*", options: []),
                regex.matchFoundIn(element) else {
                    return nil
                }
                self = .variable(element)
            }
        }

        public var description: String {
            switch self {
            case .variable(let variableName): return variableName
            case .string(let string): return  #""\#(string)""#
            case .number(let double): return double.description
            case .boolean(let boolean): return boolean.description
            }
        }
    }

    init?(element: String) {
        if let comparisonOperator = ComparisonOperator(rawValue: element) {
            self = .comparisonOperator(comparisonOperator)
        } else if let logicOperator = LogicOperator(rawValue: element) {
            self = .logicOperator(logicOperator)
        } else if let bracket = Bracket(rawValue: element) {
            self = .bracket(bracket)
        } else if let operand = Operand(element) {
            self = .operand(operand)
        } else {
            return nil
        }
    }

    public var description: String {
        switch self {
        case .comparisonOperator(let comparisonOperator): return comparisonOperator.rawValue
        case .logicOperator(let logicOperator): return logicOperator.rawValue
        case .bracket(let bracket): return bracket.rawValue
        case .operand(let operand): return operand.description
        }
    }
}
