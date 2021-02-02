//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// Store a left operand boolean and a logic operator for easier evaluation purposes.
/// #### Representation examples
///    - true &&
///    - false ||
///    - true
struct HalfBooleanExpression {

    /// Left boolean operand
    let boolean: Bool

    /// Logic operator. Can be nil if the `HalfBooleanExpression` is at the end of the expression as the last operand.
    let logicOperator: ExpressionElement.LogicInfixOperator?

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
                let result = logicOperator.evaluate(boolean, otherExpression.boolean)
                return HalfBooleanExpression(boolean: result, logicOperator: .or)
            case .and:
                switch logicOperator {
                case .and:
                    /** `boolean && boolean && ...boolean` → `boolean && ...boolean` */
                    let result = logicOperator.evaluate(boolean, otherExpression.boolean)
                    return HalfBooleanExpression(boolean: result, logicOperator: .and)
                case .or:
                    /**
                     `boolean || boolean && ...boolean` → `boolean || boolean && ...boolean`
                     we are not able to evaluate the expression as the right operand of the `&&` is unknown. Return nil
                     */
                    return nil

                default: return nil // other logic operators not allowed
                }

            default: return nil // other logic operators not allowed
            }
        } else {
            // the other expression doesn't have a logic operator, so we can simply return a boolean
            let result = logicOperator.evaluate(boolean, otherExpression.boolean)
            return HalfBooleanExpression(boolean: result, logicOperator: nil)
        }
    }
}
