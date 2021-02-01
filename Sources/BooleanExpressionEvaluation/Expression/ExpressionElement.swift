//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details
import Foundation

/// Represent an element in a boolean expression
public enum ExpressionElement: Equatable, CustomStringConvertible, Codable {

    // MARK: - Properties

    case comparisonOperator(Operator)
    case logicOperator(LogicOperator)
    case bracket(Bracket)
    case operand(Operand)

    // MARK: - Associated enums

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

extension ExpressionElement {

    public enum Bracket: String {
        case opening = "("
        case closing = ")"
    }
}

extension ExpressionElement {

    public enum Operand: Equatable, CustomStringConvertible {
        case variable(String)
        case string(String)
        case number(Double)
        case boolean(Bool)

        init(_ element: String, variablesRegexPattern: String? = nil) throws {
            if element.isEnclosed(by: "\"") || element.isEnclosed(by: "'") {
                let enclosingQuote = element.first !! "The element should be enclosed with quotes here"
                var string = element
                string.removeFirst()
                string.removeLast()
                guard !string.contains(enclosingQuote) else {
                    throw ExpressionError.invalidStringQuotation(element)
                }
                self = .string(string)
            } else if let double = Double(element) {
                self = .number(double)
            } else if let boolean = Bool(element) {
                self = .boolean(boolean)
            } else {
                let pattern = variablesRegexPattern ?? Self.variableRegexPattern
                guard
                    let regex = try? NSRegularExpression(pattern: pattern),
                    regex.matchFoundIn(element)
                else {
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
        static let stringRegexPattern =  #""[^"]*"|'[^']*'"#
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
}
