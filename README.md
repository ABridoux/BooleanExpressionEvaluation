#  About Expressions

This library is useful to evaluate a string expression like `variable1 >= 2 && variable2 = "Value"`. The variables are provided by an object implementing the `VariablesProvider` protocol, which only requires the object to be able to return an array of  `[String : String]` representing the variables and their values.

## Requirements
- Swift 5
- macOS 10.13
- iOS 12

## Usage

To add the library to your projet, add the pod in your podfile:
`pod 'BooleanExpressionEvaluation'`

## Evaluate a String

To evaluate a String, create an `ExpresionEvaluator`, passing the string as the parameter of the init. Note that the initialisation can throw an error, as the string expression can contains incorrect elements. You can then call the `evaluateExpression` function of the evaluator. This function can also throw an error, as the expression can has an incorrect grammar.

For example:

```swift
struct Variables: VariablesProvider {
   var variables = ["userAge": "15", "userName": "Morty"]
}

let expression = #"userAge > 10 && userName == "Morty""#
do {
   let evaluator = try ExpressionEvaluator(string: expression, variablesProvider: Variables())
} catch {
   // handle errors such as invalid elements in the expression
}

do {
   let result = try evaluator.evaluateExpression()
   print("The user is allowed to travel across dimensions: \(result)")
} catch {
   // handle errors such as incorrect grammar in the expression
}
```

Note that the syntaxt `#""#` is used to allow the use of double quotes without quoting them with `\`

## Operators
There are two types of operators available in an expression: comparison operators, to compare a variable and an other operand, and logic operators, to compare to boolean operands.

### Comparison operators:
- `==` for *equal*
- `!=` for different
- `>` for *greater than*
- `>=` for *greater than or equal*
- `<` for *lesser than*
- `<=` for *lesser than or equal*
- `::` for contains. The result is true is the left operand contains the right one. The left operand has to be filled with values separated by commas. For example: if the variable `Ducks` has "Riri, Fifi, Loulou" for value, the comparison `Ducks :: "Riri"` is evaluated as true.

### Logic operator
- `&&` for *and*
- `||` for *or*

## Operands

You can compare a variable and an operand with a comparison operator. There are four types of operands.
- `String` which are quoted
- `Number` which group all numeric values, including floating ones
- `Boolean` which are written as *true* or *false*
- `Variables` which have to begin by a letter (lower or upper case) and can contain scores `-` and underscores `_`. You can compare two variables.

Given the following variables, here are examples for each operator.
#### Variables: 
- "isUserAWizard": "true"
- "userName": "Gandalf"
- "userAge": "400"
- "fellowship": "Gandalf, Frodo, Sam, Aragorn, Gimli, Legolas, Boromir, Merry, Pippin"
- "hobbit": "Bilbo"

#### Expressions
- `isUserAWizard == true && hobbit == "Bilbo"` → true
- `userAge >= 400 || userName == "Gandalf"` → true
- `fellowship :: hobbit` → false
- `userAge < 400 && userName == "Gandalf"` → false
- `(userAge < 400 && userName == "Gandalf) || fellowship :: "Aragorn"` → true

### Variables
Variables are provided to the `ExpressionEvaluator` with an object implementing the `VariablesProvider` protocol. When comparing two operands with a comparison operator, one of the operands at least has to be a variable. Otherwise, the comparison expression result is already known and the expression do not need to be evaluated.

## Details about the internal logic

### `ExpressionElement`

Represents an element of the expression, like  a variable, an operator or a number. There is four nested `Enum`s to group the different elements of an expression:
- `ComparisonOperator` like `>` or `=`  to evaluate a comparison between a variable and an other operand
- `LogicOperator` to evaluate a result with two booleans
- `Brackets`
- `Operands`  which always have an associated value, like a double or a boolean
    
### `BooleanExpressionTokenizator`

Converts an expression which contains comparison expressions to a boolean expression, which contains only logic operators, boolean operands and brackets.

### `ExpressionEvaluator`

Uses the `BooleanExpressionTokenizator`  to get the different elements of the boolean expression and evaluate it. A new array is added into the `expressionResults` array of arrays each time an opening bracket is met. When a closing bracket is met, the last created array is reduced to a boolean which is then injected into the previous array.  The last created array is then deleted.



