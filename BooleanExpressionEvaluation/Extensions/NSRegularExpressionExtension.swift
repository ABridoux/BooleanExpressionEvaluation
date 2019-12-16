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

extension NSRegularExpression {
    func matchFoundIn(_ string: String) -> Bool {
        guard let firstMatch = matches(in: string, options: [], range: NSRange(location: 0, length: string.count)).first,
        firstMatch.range.length > 0 else {
            return false
        }

        return string.sliced(with: firstMatch.range) == string
    }

    static var charactersToQuote: [String] { ["*", "?", "+", "[", "(", ")", "{", "}", "^", "$", "|", "\\", ".", "/", "="] }

    /**
     - Parameter string: The string in which to look for a match
     - Returns: The first string match found, if any
     */
    func firstMatchString(in string: String) -> String? {
        guard let range = firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count))?.range else {
            return nil
        }
        return string.sliced(with: range)
    }

    /**
     - Parameter string: The string to look for the matches in
     - Returns: The string matches found by the regular expression. Throws an error if an element of the string has no match.
     */
    func matches(in string: String) throws -> [String] {
        let matches = self.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))

        var stringMatches = [String]()
        var lastMatchUpperBound = 0

        for match in matches {
            // check if we have ignored characters between the previous and current match
            if match.range.lowerBound > lastMatchUpperBound {
                let rangeBetweenMatches = NSRange(lastMatchUpperBound...match.range.lowerBound - 1)
                let subStringBetweenMatches = string.sliced(with: rangeBetweenMatches)
                if subStringBetweenMatches.trimmingCharacters(in: .whitespaces) != "" {
                    // we have something between those two matches, so it's an unmatched element.
                    throw ExpressionError.incorrectElement(subStringBetweenMatches)
                }
            }

            lastMatchUpperBound = match.range.upperBound
            stringMatches.append(string.sliced(with: match.range))
        }

        return stringMatches
    }
}
