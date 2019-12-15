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

extension String {

    /**
    - Parameter range: The range to slice the `string`
    - Returns: A substring defined by the slicing of the string with the specified range
    */
    func sliced(with range: NSRange) -> String {
        let sliceStartIndex = index(startIndex, offsetBy: range.location)
        let sliceEndIndex = index(startIndex, offsetBy: range.upperBound - 1)
        return String(self[sliceStartIndex...sliceEndIndex])
    }

    /// Quote the characters if necessary to be used in a regular expression
    var quoted: String {
        var quotedString = ""
        forEach { character in
            let character = String(character)
            quotedString += NSRegularExpression.charactersToQuote.contains(character) ? "\\" : ""
            quotedString += character
        }
        return quotedString
    }
}
