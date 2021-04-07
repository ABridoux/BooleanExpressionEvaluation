// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "BooleanExpressionEvaluation",
    platforms: [.macOS("10.12"), .iOS("10.0")],
    products: [
        .library(name: "BooleanExpressionEvaluation", targets: ["BooleanExpressionEvaluation"])
    ],
    dependencies: [],
    targets: [
        .target(name: "BooleanExpressionEvaluation"),
        .testTarget(name: "BooleanExpressionEvaluationTests", dependencies: ["BooleanExpressionEvaluation"])
    ]
)
