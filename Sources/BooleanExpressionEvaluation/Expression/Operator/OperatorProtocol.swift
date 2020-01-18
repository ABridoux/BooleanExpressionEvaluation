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

public protocol OperatorProtocol: CustomStringConvertible, Hashable {

    static var models: Set<Self> { get }
}

extension OperatorProtocol {

    /// The pattern to identify an operator with a regular expression
    static var regexPattern: String {
        var uniqueCharactersPattern = Set<String>()
        models.forEach { $0.description.forEach {  uniqueCharactersPattern.insert(String($0).quoted) }}
        return uniqueCharactersPattern.reduce("") { $0 + $1 }
    }

    /**
     - Parameter element: Element to compare to the description
     - Returns: `true` if the element is equald to `description`
    */
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
