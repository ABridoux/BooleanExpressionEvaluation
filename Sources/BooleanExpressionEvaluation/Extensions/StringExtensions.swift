//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension String {

    subscript(_ range: NSRange) -> String {
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
