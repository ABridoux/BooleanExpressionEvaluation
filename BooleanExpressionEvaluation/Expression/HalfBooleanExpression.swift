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

/**
 Store a left operand boolean and a logic operator for easier evaluation purposes.
 #### Representation examples
    - true &&
    - false ||
    - true
 */
struct HalfBooleanExpression {

    /// Left boolean operand
    let boolean: ExpressionElement.Operand

    /// Logic operator. Can be nil if the `HalfBooleanExpression` is at the end of the expression as the last operand.
    let logicOperator: ExpressionElement.LogicOperator?

    /**
     Evaluate a `HalfBooleanExpression` with another one as the right operand.
     - returns: The new `HalfBooleanExpression`, or `nil` is the evaluation is not possible
     */
    func evaluate(with otherExpression: HalfBooleanExpression) -> HalfBooleanExpression? {
        guard let logicOperator = self.logicOperator else {
            // if we don't have an operator to evaluate our boolean with an other one, we return self
            return self
        }

        if let otherLogicOperator = otherExpression.logicOperator {
            switch otherLogicOperator {
            case .or:
                /**
                 `boolean && boolean || ...boolean` → `boolean || ...boolean`
                 `boolean || boolean || ...boolean` → `boolean || ...boolean`
                 */
                guard let result = logicOperator.evaluate(boolean, otherExpression.boolean) else { return nil}
                return HalfBooleanExpression(boolean: result, logicOperator: .or)
            case .and:
                switch logicOperator {
                case .and:
                    /** `boolean && boolean && ...boolean` → `boolean && ...boolean` */
                    guard let result = logicOperator.evaluate(boolean, otherExpression.boolean) else { return nil}
                    return HalfBooleanExpression(boolean: result, logicOperator: .and)
                case .or:
                    /**
                     `boolean || boolean && ...boolean` → `boolean || boolean && ...boolean`
                     we are not able to evaluate the expression as the right operand of the `&&` is unknown. Return nil
                     */
                    return nil
                }
            }
        } else {
            // the other expression doesn't have a logic operator, so we can simply return a boolean
            guard let result = logicOperator.evaluate(boolean, otherExpression.boolean) else { return nil }
            return HalfBooleanExpression(boolean: result , logicOperator: nil)
        }
    }
}
