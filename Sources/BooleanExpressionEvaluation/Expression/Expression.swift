//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// Represents a boolean expression as an array of `ExpressionElements`
public struct Expression: Collection, CustomStringConvertible {

    public typealias Element = ExpressionElement
    public typealias Elements = [ExpressionElement]

    // MARK: - Constants

    static var operatorsPattern: String {
        "[\(Operator.regexPattern)" +
        ExpressionElement.LogicInfixOperator.regexPattern +
        "\(ExpressionElement.LogicPrefixOperator.regexPattern)]+" +
        "|(\(Operator.regexKeywordPattern))+"
    }
    static let bracketsPattern = #"[\(\)]+"#

    // MARK: - Properties

    // MARK: Collection

    private var elements = Elements()

    public var startIndex: Int { elements.startIndex }
    public var endIndex: Int { elements.endIndex }

    // MARK: CustomStringConvertible

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

    // MARK: Expression

    /// The pattern used for the regular expression to split the string expression
    let regexPattern: String

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

    /// The operators involved the the expression
    public var operators: [Operator] {
        elements.compactMap { element in
            if case let .comparisonOperator(comparisonOperator) = element {
                return comparisonOperator
            }
            return nil
        }
    }

    // MARK: - Initialiation

    public init(_ stringExpression: String, variablesRegexPattern: String? = nil) throws {
        // split the string expression
        regexPattern = Self.computeRegexPattern(variablesRegexPattern: variablesRegexPattern)
        let regex = try NSRegularExpression(pattern: regexPattern, options: [])
        let stringElements = try regex.matches(in: stringExpression)

        var evaluatedExpression = [ExpressionElement]()

        for element in stringElements {
            // remove the bracket if present as a prefix or suffiix of the element as they are authorized to be written without spacing
            var addClosingBracket = false
            var elementWithoutBrackets = String(element)

            // > 1 otherwise it is a sole bracket
            if elementWithoutBrackets.hasPrefix(ExpressionElement.Bracket.opening.rawValue), element.count > 1 {
                evaluatedExpression.append(.bracket(.opening))
                elementWithoutBrackets.removeFirst()
            }
            if elementWithoutBrackets.hasSuffix(ExpressionElement.Bracket.closing.rawValue), element.count > 1 {
                addClosingBracket = true
                elementWithoutBrackets.removeLast()
            }

            let element = try ExpressionElement(element: elementWithoutBrackets, variablesRegexPattern: variablesRegexPattern)
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

    public init(_ elements: Elements) {
        regexPattern = Self.computeRegexPattern()
        self.elements = elements
    }

    public init(_ elements: Element...) {
        self.init(elements)
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

    private static func computeRegexPattern(variablesRegexPattern: String? = nil) -> String {
        let operandsRegexPattern = ExpressionElement.Operand.getRegexPattern(variablesRegexPattern: variablesRegexPattern)

        var regexPattern = #"(?<=\s|^)"#
        regexPattern.append("(\(Self.operatorsPattern))")
        regexPattern.append("|(\(Self.bracketsPattern))")
        regexPattern.append("|(\(operandsRegexPattern))")
        regexPattern.append(#"(?=\s|$)"#)
        return regexPattern
    }
}

extension Expression: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = ExpressionElement

    public init(arrayLiteral elements: ExpressionElement...) {
        self.elements = elements
        regexPattern = Self.computeRegexPattern()
    }
}

extension Expression: Equatable {
    public static func == (lhs: Expression, rhs: Expression) -> Bool {
        return lhs.elements == rhs.elements
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
