# BooleanExpressionEvaluation

All notable changes to this project will be documented in this file. `BooleanExpressionEvaluation` adheres to [Semantic Versioning](http://semver.org).

---

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
