<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.0+-f05138.svg?style=flat-square" />
    <img src="https://img.shields.io/badge/iOS-12+-lightgrey.svg?style=flat-square" />
    <img src="https://img.shields.io/badge/macOS-10.13+-lightgrey.svg?style=flat-square" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/swiftpm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
</p>

#  About boolean expressions

This library is useful to evaluate a string expression like `variable1 >= 2 && variable2 == "Value"`. The variables are provided by a dictionary `[String : String]` representing the variables and their values. The complexity to evaluate a string expression is O(n)

## Alternatives

Both [Expression](https://github.com/nicklockwood/Expression) from Nick Lockwood and [Eval](https://github.com/tevelee/Eval) from Lázló Teveli are interesintg alternatives. Exression is a ready to use framework and Lázló Teveli has produced a great work to deeply customize the usage of his framework. The goal of BooleanExpressionEvaluation is to focus on boolean expressions, when other expressions evaluation is not needed. Thus, the framework bears a little less complexity in its usage and customization.

## Usage

### Swift Package Manager

Add the package to your dependencies in your *Package.swift* file

```swift
let package = Package (
    ...
    dependencies: [
        .package(url: "https://github.com/ABridoux/BooleanExpressionEvaluation.git", from: "1.0.0")
    ],
    ...
)
```

Or simply use Xcode menu *File* > *Swift Packages* > *Add Package Dependency*  and copy/paste the git URL: https://github.com/ABridoux/BooleanExpressionEvaluation.git

Then import BooleanExpressionEvaluation in your file:

```swift
import BooleanExpressionEvaluation
```

## Evaluate a String

To evaluate a String, create an `Expression`, passing the string as the parameter of the init. Note that the initialisation can throw an error, as the string expression can contain incorrect elements. You can then call the `evaluate()` function of the expression. This function can also throw an error, as the expression can have an incorrect grammar.

For example:

(Note that the use of the raw string syntaxt `#""#`  from Swift 5.0 is used to allow the use of double quotes without quoting them with `\`)

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

### Default comparison operators
- `==` for *equal*
- `!=` for different
- `>` for *greater than*
- `>=` for *greater than or equal*
- `<` for *lesser than*
- `<=` for *lesser than or equal*
- `<:` for contains. The result is true is the left operand contains the right one. The left operand has to be filled with values separated by commas. For example: if the variable `Ducks` has "Riri, Fifi, Loulou" for value, the comparison `Ducks <: "Riri"` is evaluated as true.
- `~=` for *hasPrefix*
- `=~` for *hasSuffix*

### Default logic operators
- `&&` for *and*
- `||` for *or*

### Custom operators

You can define cutom operators in an extension of the `Operator` struct. Then add this operator to the `Operator.models` set. The same applies for the `LogicOperator` struct.

For example, you can define the `hasPrefix` and `hasSuffix` operators  (note that those operators already exist and that their symbols are chosen arbitrarily):

```swift
extension Operator {
    static var hasPrefix: Operator { Operator("~=") { (lhs, rhs) -> Bool? in
        guard let lhs = lhs as? String, let rhs = rhs as? String else { return nil }
        return lhs.hasPrefix(rhs)
    }}

    static var hasSuffix: Operator { Operator("=~") { (lhs, rhs) -> Bool? in
        guard let lhs = lhs as? String, let rhs = rhs as? String else { return nil }
        return lhs.hasSuffix(rhs)
    }}
}
```
Then, in the setup of your app:

```swift
Operator.models.insert(.hasPrefix)
Operator.models.insert(.hasSuffix)
```

Finally, you can simply add an operator directly:

```swift
Operator.models.insert(Operator("~=") { (lhs, rhs) in
    guard let lhs = lhs as? String, let rhs = rhs as? String else { return nil }
    return lhs.hasSuffix(rhs)
})

```

You can remove if you want the default operators, by calling the proper `Operator.removeDefault[Operator_Name]()` method. You can also directly override the behavior of a default operator, by updating the `Operator.models`  set with an operator which has the same description.

<u>Note</u><br>
As it is not possible for now to restrict a closure signature to a protocol without specifying the type as generic in the structure, we cannot allow only `Comparable` operands in an operator `evaluate` closure. Nonetheless, only strings, boolean and double are allowed as operands in this framework now. Moreover, you might want to compare a double and a string, with an opeator like `count` for example. This would no be possible if the two operands were comparable with the same type.

## Operands

You can compare a variable and an operand with a comparison operator. There are four types of operands.
- `String` which are quoted with double quotes only
- `Number` which group all numeric values, including floating ones
- `Boolean` which are written as *true* or *false*
- `Variables` which have to begin by a letter (lower or upper case) and can contain hyphens `-` and underscores `_`. You can compare two variables. Note that the boolean variables can be written without the `==` to evaluate if their state is `true`.

Given the following variables, here are some examples:

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

The default regular expression to match a variable is `[a-zA-Z]{1}[a-zA-Z0-9_-]+`. You can choose to use an other regular expression by providing it when initializing an expression:

```swift
let expression = try? Expression("#variable >= 2", variablesRegexPattern: "[a-zA-Z#]{1}[a-zA-Z0-9#]+")
```
If you always use the same regular expresion, you should consider to write an extension of `Expression` to add the initializer with this default expression. So with our last example:

```swift
extension Expression {
    init(stringExpression: String) throws {
        try self.init(stringExpression, variablesRegexPattern: "[a-zA-Z#]{1}[a-zA-Z0-9#]+")
    }
}
```

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


