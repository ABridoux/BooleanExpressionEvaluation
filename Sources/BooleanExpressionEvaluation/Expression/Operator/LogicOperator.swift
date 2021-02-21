//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension ExpressionElement {

    public enum LogicOperator: Equatable {
        case prefix(LogicPrefixOperator)
        case infix(LogicInfixOperator)
    }
}
