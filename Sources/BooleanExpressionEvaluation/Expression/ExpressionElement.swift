//
//  GNU GPLv3
//
/*
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
public enum ExpressionElement: Equatable, CustomStringConvertible, Codable {

    // MARK: - Properties

    // MARK: Cases

    case comparisonOperator(Operator)
    case logicOperator(LogicOperator)
    case bracket(Bracket)
    case operand(Operand)

    // MARK: - Associated enums

    public enum Bracket: String {
        case opening = "("
        case closing = ")"
    }

    public enum Operand: Equatable, CustomStringConvertible {
        case variable(String)
        case string(String)
        case number(Double)
        case boolean(Bool)

        init(_ element: String, variablesRegexPattern: String? = nil) throws {
            if element.first == "\"" && element.last == "\"" {
                var string = element
                string.removeFirst()
                string.removeLast()
                guard !string.contains("\"") else {
                    throw ExpressionError.invalidStringQuotation(element)
                }
                self = .string(string)
            } else if let double = Double(element) {
                self = .number(double)
            } else if let boolean = Bool(element) {
                self = .boolean(boolean)
            } else {
                let pattern = variablesRegexPattern ?? Self.variableRegexPattern
                guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
                regex.matchFoundIn(element) else {
                    throw ExpressionError.invalidVariableName(element)
                }
                self = .variable(element)
            }
        }

        public var description: String {
            switch self {
            case .variable(let variableName): return variableName
            case .string(let string): return  "'\(string)'"
            case .number(let double): return double.description
            case .boolean(let boolean): return boolean.description
            }
        }

        static let booleanRegexPattern = "true|false"
        static let numberRegexPattern = #"[0-9\.]+"#
        static let stringRegexPattern =  #""[^"]*""#
        static let variableRegexPattern = "[a-zA-Z]{1}[a-zA-Z0-9_-]+"

        static func getRegexPattern(variablesRegexPattern: String? = nil) -> String {
            var pattern = #"\(*("#
            pattern += #"(\#(booleanRegexPattern))|"#
            pattern += #"(\#(numberRegexPattern))|"#
            pattern += #"(\#(stringRegexPattern))|"#
            pattern += #"(\#(variablesRegexPattern ?? variableRegexPattern))"#
            pattern += #")\)*"#

            return pattern
        }
    }

    // MARK: - Properties

    public var description: String {
        switch self {
        case .comparisonOperator(let comparisonOperator): return comparisonOperator.description
        case .logicOperator(let logicOperator): return logicOperator.description
        case .bracket(let bracket): return bracket.rawValue
        case .operand(let operand): return operand.description
        }
    }

    // MARK: - Initialization

    init(element: String, variablesRegexPattern: String? = nil) throws {
        if let comparisonOperator = Operator.findModel(with: element) {
            self = .comparisonOperator(comparisonOperator)
        } else if let logicOperator = LogicOperator.findModel(with: element) {
            self = .logicOperator(logicOperator)
        } else if let bracket = Bracket(rawValue: element) {
            self = .bracket(bracket)
        } else {
            self = .operand(try Operand(element, variablesRegexPattern: variablesRegexPattern))
        }
    }

    public init(from decoder: Decoder) throws {
        let key = try decoder.singleValueContainer().decode(String.self)
        self = try ExpressionElement(element: key)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
