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

public struct Operator: OperatorProtocol {

    // MARK: - Constants

    public typealias Evaluation = (Any, Any) -> Bool?

    // MARK: - Properties

    public var description: String

    public static var models: Set<Operator> = [.equal, .nonEqual, .greaterThan, .greaterThanOrEqual, .lesserThan, .lesserThanOrEqual, .contains]

    /// Closure to evaluate two operands
    var evaluate: Evaluation

    // MARK: - Initialization

    public init(_ description: String, evaluation: @escaping Evaluation) {
        self.description = description
        self.evaluate = evaluation
    }
}

extension Operator {
    public static func == (lhs: Operator, rhs: Operator) -> Bool {
        return lhs.description == rhs.description
    }
}

extension Operator {
    static var equal: Operator { Operator("==") { (lhs, rhs) in
        if let lhs = lhs as? String, let rhs = rhs as? String {
            return lhs == rhs
        } else if let lhs = lhs as? Double, let rhs = rhs as? Double {
            return lhs == rhs
        } else if let lhs = lhs as? Bool, let rhs = rhs as? Bool {
            return lhs == rhs
        }
        return nil
    }}

    static var nonEqual: Operator { Operator("!=") { (lhs, rhs) in
        if let lhs = lhs as? String, let rhs = rhs as? String {
            return lhs != rhs
        } else if let lhs = lhs as? Double, let rhs = rhs as? Double {
            return lhs != rhs
        } else if let lhs = lhs as? Bool, let rhs = rhs as? Bool {
            return lhs != rhs
        }
        return nil
    }}

    static var greaterThan: Operator { Operator(">") { (lhs, rhs) in
        if let lhs = lhs as? String, let rhs = rhs as? String {
            return lhs > rhs
        } else if let lhs = lhs as? Double, let rhs = rhs as? Double {
            return lhs > rhs
        }
        return nil
    }}

    static var greaterThanOrEqual: Operator { Operator(">=") { (lhs, rhs) in
        if let lhs = lhs as? String, let rhs = rhs as? String {
            return lhs >= rhs
        } else if let lhs = lhs as? Double, let rhs = rhs as? Double {
            return lhs >= rhs
        }
        return nil
    }}

    static var lesserThan: Operator { Operator("<") { (lhs, rhs) in
        if let lhs = lhs as? String, let rhs = rhs as? String {
            return lhs < rhs
        } else if let lhs = lhs as? Double, let rhs = rhs as? Double {
            return lhs < rhs
        }
        return nil
    }}

    static var lesserThanOrEqual: Operator { Operator("<=") { (lhs, rhs) in
        if let lhs = lhs as? String, let rhs = rhs as? String {
            return lhs <= rhs
        } else if let lhs = lhs as? Double, let rhs = rhs as? Double {
            return lhs <= rhs
        }
        return nil
    }}

    static var contains: Operator { Operator("<:") { (lhs, rhs) in
        guard let lhs = lhs as? String, let rhs = rhs as? String else { return nil }
        let splittedLhs = lhs.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        return splittedLhs.contains(rhs)
    }}
}

extension Operator {
    /** Call this function if you want to prevent the default operator `==` to work.
    If you need to override the behavior of `==`, simply insert a new operator with the same description*/
    func removeDefaultEqual() { Self.models.remove(.equal) }

    /** Call this function if you want to prevent the default operator `!=` to work.
    If you need to override the behavior of `!=`, simply insert a new operator with the same description*/
    func removeDefaultNonEqual() { Self.models.remove(.nonEqual) }

    /** Call this function if you want to prevent the default operator `>` to work.
    If you need to override the behavior of `>`, simply insert a new operator with the same description*/
    func removeDefaultGreaterThan() { Self.models.remove(.greaterThan) }

    /** Call this function if you want to prevent the default operator `>=` to work.
    If you need to override the behavior of `>=`, simply insert a new operator with the same description*/
    func removeDefaultGreaterThanOrEqual() { Self.models.remove(.greaterThanOrEqual) }

    /** Call this function if you want to prevent the default operator `<` to work.
    If you need to override the behavior of `<`, simply insert a new operator with the same description*/
    func removeDefaultLesserThan() { Self.models.remove(.lesserThan) }

    /** Call this function if you want to prevent the default operator `<=` to work.
    If you need to override the behavior of `<=`, simply insert a new operator with the same description*/
    func removeDefaultLesserThanOrEqual() { Self.models.remove(.lesserThanOrEqual) }

    /** Call this function if you want to prevent the default operator `<:` to work.
    If you need to override the behavior of `<:`, simply insert a new operator with the same description*/
    func removeDefaultContains() { Self.models.remove(.contains) }
}
