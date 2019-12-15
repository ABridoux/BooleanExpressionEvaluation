![Swift](https://img.shields.io/badge/Swift-5.0+-f05138.svg?style=flat-square)
![iOS](https://img.shields.io/badge/iOS-12+-lightgrey.svg?style=flat-square)
![macOS](https://img.shields.io/badge/macOS-10.13+-lightgrey.svg?style=flat-square)

[![CocoaPods](https://img.shields.io/cocoapods/v/BooleanExpressionEvaluation.svg?style=flat-square)](https://cocoapods.org/pods/BooleanExpressionEvaluation)

#  About boolean expressions

This library is useful to evaluate a string expression like `variable1 >= 2 && variable2 = "Value"`. The variables are provided by a dictionary `[String : String]` representing the variables and their values. The complexity to evaluate a string expression is O(n)

## Usage

To add the library to your projet, add the pod in your podfile:
`pod 'BooleanExpressionEvaluation'`

## Evaluate a String

To evaluate a String, create an `Expression`, passing the string as the parameter of the init. Note that the initialisation can throw an error, as the string expression can contain incorrect elements. You can then call the `evaluate()` function of the expression. This function can also throw an error, as the expression can have an incorrect grammar.

For example:

(Note that the syntaxt `#""#` is used to allow the use of double quotes without quoting them with `\`)

```swift
let variables = ["userAge": "15", "userName": "Morty"]

let stringExpression = #"userAge > 10 && userName == "Morty""#
let expression: Expression
do {
    expression = try Expression(stringExpression)
} catch {
   // handle errors such as invalid elements in the expression
   return
}

do {
   let result = try expression.evaluate(with: variables)
   print("The user is allowed to travel across dimensions: \(result)")
} catch {
   // handle errors such as incorrect grammar in the expression
}
```

You can also create the `Expression` and evaluate it in the same `do{} catch{}` statement:

```swift
let variables = ["userAge": "15", "userName": "Morty"]

let stringExpression = #"userAge > 10 && userName == "Morty""#

do {
    let result = try Expression(stringExpression).evaluate(with: variables)
} catch {
   // handle errors such as invalid elements or incorrect grammar in the expression
   return
}
```

Finally, a simple use case is to implement an extension of `Expression` when you always evaluate them with a single source of variables, like a `VariablesManager` singleton in your overall project.

```swift
extension Expression {
    func evaluate() throws -> Bool {
        return try evaluate(with: VariablesManager.shared.variables)
    }
}
```


## Operators
There are two types of operators available in an expression: comparison operators, to compare a variable and an other operand, and logic operators, to compare to boolean operands.

### Comparison operators:
- `==` for *equal*
- `!=` for different
- `>` for *greater than*
- `>=` for *greater than or equal*
- `<` for *lesser than*
- `<=` for *lesser than or equal*
- `<:` for contains. The result is true is the left operand contains the right one. The left operand has to be filled with values separated by commas. For example: if the variable `Ducks` has "Riri, Fifi, Loulou" for value, the comparison `Ducks <: "Riri"` is evaluated as true.

### Logic operator
- `&&` for *and*
- `||` for *or*

### Custom operators

You can define cutom operators

## Operands

You can compare a variable and an operand with a comparison operator. There are four types of operands.
- `String` which are quoted with double quotes only
- `Number` which group all numeric values, including floating ones
- `Boolean` which are written as *true* or *false*
- `Variables` which have to begin by a letter (lower or upper case) and can contain hyphens `-` and underscores `_`. You can compare two variables. Note that the boolean variables can be written without the `==` to compare them to a boolean.

Given the following variables, here are examples for each operator.
#### Variables: 
- "isUserAWizard": "true"
- "userName": "Gandalf"
- "userAge": "400"
- "fellowship": "Gandalf, Frodo, Sam, Aragorn, Gimli, Legolas, Boromir, Merry, Pippin"
- "hobbit": "Bilbo"
- "passphrase": "You shall not pass!"

#### Expressions
- `isUserAWizard == true && hobbit == "Bilbo"` → true
- `userAge >= 400 || userName != "Saruman"` → true
- `fellowship <: hobbit` → false
- `userAge < 400 && userName == "Gandalf"` → false
- `(userAge < 400 && userName == "Gandalf) || fellowship <: "Aragorn"` → true
- `isUserAWizard && passphrase == "You shall not pass!"` → true

### Variables
Variables are provided to the `Expression` with a `[String: String]` dictionary. When comparing two operands with a comparison operator, one of the operands at least has to be a variable. Otherwise, the comparison expression result is already known and the expression do not need to be evaluated.

A useful property of an `Expression` is `variables`, which is an array of the names of all the variables involved in the expression. 

## Codable
`Expression` implements the `Codable` protocol, and it is encoded/decoded as a `String`. Thus, you can try to decode a `String` value as an expression. And encoding it will render a `String`, describing it as a literal boolean expression. 

## Details about the internal logic

### `ExpressionElement`

Represents an element of the expression, like  a variable, an operator or a number. There is four nested `Enum`s to group the different elements of an expression:
- `ComparisonOperator` like `>` or `=`  to evaluate a comparison between a variable and an other operand
- `LogicOperator` to evaluate a result with two booleans
- `Brackets`
- `Operands` which always have an associated value, like a double, a boolean, a string or a variable

### `Expression`
Act like an array of `ExpressionElement`, although it is a `struct` which implements the `Collection` protocol. 

### `BooleanExpressionTokenizator`

Converts an expression which contains comparison expressions to a boolean expression, which contains only logic operators, boolean operands and brackets.

### `ExpressionEvaluator`

Uses the `BooleanExpressionTokenizator`  to get the different elements of the boolean expression and evaluate it. A new array is added into the `expressionResults` array of arrays each time an opening bracket is met. When a closing bracket is met, the last created array is reduced to a boolean which is then injected into the previous array.  The last created array is then deleted.



