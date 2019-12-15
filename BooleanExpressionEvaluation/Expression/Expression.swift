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
public struct Expression: Collection, Equatable {

    public typealias Element = ExpressionElement
    public typealias ArrayType = [ExpressionElement]

    // MARK: - Constants

    static let operatorsPattern = "[\(Operator.regexPattern)\(LogicOperator.regexPattern)]+"
    static let operandsGeneralPattern = #"[a-zA-Z0-9()\._-]+"#
    static let stringRegexPattern = #"".*""#
    static let regexPattern: String = {
        var regexPattern = #"(?<=\s|^)"#
        regexPattern.append("(\(Self.operatorsPattern))")
        regexPattern.append(#"|(\#(Self.operandsGeneralPattern))"#)
        regexPattern.append(#"|(\#(Self.stringRegexPattern))"#)
        regexPattern.append(#"(?=\s|$)"#)
        return regexPattern
    }()

    // MARK: - Properties

    private var elements = ArrayType()

    public var startIndex: Int { elements.startIndex }
    public var endIndex: Int { elements.endIndex }

    public var description: String {
        var description = ""

        for element in elements {
            description.append(element.description)
            if case ExpressionElement.bracket(.opening) = element {
                // don't add space after opening bracket
                continue
            }
            if case ExpressionElement.bracket(.closing) = element {
                // remove prevoious space before
                _ = description.popLast()
            }
            description.append(" ")
        }
        // remove last unwanted space
        _ = description.popLast()
        return description
    }

    /// The variables involved the the expression
    public var variables: Set<String> {
        var variableNames = Set<String>()
        for element in self {
            if case let ExpressionElement.operand(.variable(name)) = element {
                variableNames.insert(name)
            }
        }
        return variableNames
    }

    // MARK: - Initialiation

    public init(_ stringExpression: String) throws {
        // split the string expression
        let regex = try NSRegularExpression(pattern: Self.regexPattern, options: [])
        let stringElements = regex.matches(in: stringExpression)

        var evaluatedExpression = [ExpressionElement]()

        for element in stringElements {
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

            let element = try ExpressionElement(element: elementWithoutBrackets)
            evaluatedExpression.append(element)

            if addClosingBracket {
                evaluatedExpression.append(.bracket(.closing))
            }
        }
        guard !evaluatedExpression.isEmpty else {
            throw ExpressionError.emptyExpression
        }

        elements = evaluatedExpression
    }

    public init(_ elements: ArrayType) {
        self.elements = elements
    }

    // MARK: - Functions

    // MARK: Collection

    public func index(after i: Int) -> Int {
        return elements.index(after: i)
    }

    public subscript(elementIndex: Int) -> ExpressionElement {
        assert(elementIndex >= startIndex && elementIndex <= endIndex)
        return elements[elementIndex]
    }

    mutating func append(_ element: ExpressionElement) {
        elements.append(element)
    }

    mutating func popFirst() -> ExpressionElement? {
        if let firstElement = elements.first {
            elements.removeFirst()
            return firstElement
        }
        return nil
    }

    // MARK: Evaluation

    public func evaluate(with variables: [String: String]) throws -> Bool {
        var evaluator = ExpressionEvaluator(expression: self, variables: variables)
        return try evaluator.evaluateExpression()
    }
}

extension Expression: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = ExpressionElement

    public init(arrayLiteral elements: ExpressionElement...) {
        self.elements = elements
    }
}

extension Expression: Codable {
    public init(from decoder: Decoder) throws {
        let stringExpression = try decoder.singleValueContainer().decode(String.self)
        try self.init(stringExpression)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}
