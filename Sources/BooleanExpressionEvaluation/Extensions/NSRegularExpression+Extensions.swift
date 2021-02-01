//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension NSRegularExpression {
    func matchFoundIn(_ string: String) -> Bool {
        guard let firstMatch = matches(in: string, options: [], range: NSRange(location: 0, length: string.count)).first,
        firstMatch.range.length > 0 else {
            return false
        }

        return string[firstMatch.range] == string
    }

    /// Characters that has to be quoted to be used in a regular expression
    static var charactersToQuote: [String] { ["*", "?", "+", "[", "(", ")", "{", "}", "^", "$", "|", "\\", ".", "/", "="] }

    /// - Parameter string: The string in which to look for a match
    /// - Returns: The first string match found, if any
    func firstMatchString(in string: String) -> String? {
        guard let range = firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count))?.range else {
            return nil
        }
        return string[range]
    }

    /// - Parameter string: The string to look for the matches in
    /// - Returns: The string matches found by the regular expression. Throws an error if an element of the string has no match.
    func matches(in string: String) throws -> [String] {
        let matches = self.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))

        var stringMatches = [String]()
        var lastMatchUpperBound = 0

        for match in matches {
            // check if we have ignored characters between the previous and current match
            if match.range.lowerBound > lastMatchUpperBound {
                let rangeBetweenMatches = NSRange(lastMatchUpperBound...match.range.lowerBound - 1)
                let subStringBetweenMatches = string[rangeBetweenMatches]
                if subStringBetweenMatches.trimmingCharacters(in: .whitespaces) != "" {
                    // we have something between those two matches, so it's an unmatched element.
                    throw ExpressionError.incorrectElement(subStringBetweenMatches)
                }
            }

            lastMatchUpperBound = match.range.upperBound
            stringMatches.append(string[match.range])
        }

        return stringMatches
    }
}
