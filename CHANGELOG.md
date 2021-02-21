# BooleanExpressionEvaluation

All notable changes to this project will be documented in this file. `BooleanExpressionEvaluation` adheres to [Semantic Versioning](http://semver.org).

---
## [2.0.0](https://github.com/ABridoux/BooleanExpressionEvaluation/tree/2.0.0) (21/02/2021)

### Added
- 'not' `!` operator [#46]
- Single quote to specify a string are supported [#42]
- New operator `matches` to match a variable against a regular expression [#41]
- New operator `contains` between strings.
- Support for list with escaped commas with the "isIn" operator [#40]

### Changed
- Custom operators have been replaced for their names [#43]
- An operator function should now throws rather than returning an optional
- Default operator `<:` is no< `isIn` and has a reverse operand order.

### Fixed
- Using an undefined variable as a right operand will now throw an error
- Default operators were always treating operand as Strings


## [1.2.3](https://github.com/ABridoux/BooleanExpressionEvaluation/tree/1.2.3) (30/03/2020)

### Fixed
- The string regex pattern allowed to take anything between double quotes, even a double quote.

## [1.2.2](https://github.com/ABridoux/BooleanExpressionEvaluation/tree/1.2.2) (18/01/2019)

### Added
- Swift Package Manager compliance
- *hasPrefix* and *hasSuffix* operators

###  Removed
- Cocoa Pods dependencies

### Changed
- `String`  extension function `sliced` for a `subscript`

## [1.2.1](https://github.com/ABridoux/BooleanExpressionEvaluation/tree/1.2.1) (18/12/2019)

### Fixed
- Bug when evaluating single boolean variable followed by other elements

## [1.2.0](https://github.com/ABridoux/BooleanExpressionEvaluation/tree/1.2.0) (16/12/2019)

### Added

- Possibilty to define new operators, or to override the existing ones, via extensions
- Possibility to define another regular expression string pattern to parse variables when initializing an expression

### Fixed
- Evaluatation of two operands in the wrong order for comparison operator in `BooleanExpressionTokenizator`

### Changed
- Default `contains` operator from `::` to `<:`

## [1.1.3](https://github.com/ABridoux/BooleanExpressionEvaluation/tree/1.1.3) (30/11/2019)

### Hotfix
- Mark `Expression.description`  as `public`

## [1.1.2](https://github.com/ABridoux/BooleanExpressionEvaluation/tree/1.1.2) (30/11/2019)

### Hotfix
- Mark `Expression.evaluate()`  as `public`


## [1.1.1](https://github.com/ABridoux/BooleanExpressionEvaluation/tree/1.1.1) (30/11/2019)

### Hotfix
- Mark `Expression` inits as `public`

## [1.1.0](https://github.com/ABridoux/BooleanExpressionEvaluation/tree/1.1.0) (30/11/2019)

### Added

- Evaluation os `String` with spaces
- `Expression` codable as a `String` describing it as a literal boolean expression
- `Expression` variables property to get all the variables involved in the expression
- More specific error when initialazing an expression

### Removed

- `ExpressionEvaluator` is no more `public`. To evaluate an `Expression`, now call its `evaluate(with:)` function
- `VaraiblesProvider`. Variables are now provided by a `[String: String]` dictionary

## [1.0.1](https://github.com/ABridoux/BooleanExpressionEvaluation/tree/1.0.1) (28/11/2019)

### Added

- Conformance to codable for `ExpressionElement` and thus for `Expression` too
- `Expression` description and evaluation

## [1.0.0](https://github.com/ABridoux/BooleanExpressionEvaluation/tree/1.0.0) (27/11/2019)

Initiial release


## [0.1.0](https://github.com/ABridoux/BooleanExpressionEvaluation/tree/0.1.0) (27/11/2019)

Test release for CocoaPods 
