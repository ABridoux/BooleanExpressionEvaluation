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

    func matches(in string: String) -> [String] {
        let matches = self.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        return matches.map { string.sliced(with: $0.range) }
    }
}
