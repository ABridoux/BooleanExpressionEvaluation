# BooleanExpressionEvaluation

All notable changes to this project will be documented in this file. `BooleanExpressionEvaluation` adheres to [Semantic Versioning](http://semver.org).

---

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
