//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details
import Foundation

public protocol OperatorProtocol: CustomStringConvertible, Hashable {

    static var models: Set<Self> { get }
    var isKeyword: Bool { get }
}

extension OperatorProtocol {

    public var isKeyword: Bool { false }

    /// The pattern to identify an operator with a regular expression
    static var regexPattern: String {
        var uniqueCharactersPattern = Set<String>()
        for model in models where !model.isKeyword {
            model.description.forEach {  uniqueCharactersPattern.insert(String($0).quoted) }
        }
        return uniqueCharactersPattern.reduce("") { $0 + $1 }
    }

    /// Regex for the keywords (custom operators)
    static var regexKeywordPattern: String {
        let keywords = models.reduce([String]()) { (result, model) in
            if model.isKeyword {
                return result + [model.description]
            }
            return result
        }

        return keywords.joined(separator: "|")
    }

    /// - Parameter element: Element to compare to the description
    /// - Returns: `true` if the element is equal to `description`
    public func validate(element: String) -> Self? {
        if description == element {
            return self
        } else {
            return nil
        }
    }

    static func findModel(with element: String) -> Self? {
        return models.first { $0.description == element }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}
