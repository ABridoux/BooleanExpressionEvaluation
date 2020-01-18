Pod::Spec.new do |s|

s.platform = :macos
s.macos.deployment_target = '10.13'
s.name = "BooleanExpressionEvaluation"
s.summary = "Evaluate string boolean expression with variables"
s.requires_arc = true

s.version = "1.2.2"

s.license = { :type => "GNU", :file => "LICENSE" }

s.author = { "Alexis Bridoux" => "alexis1bridoux@gmail.com" }

s.homepage = "https://github.com/ABridoux/BooleanExpressionEvaluation"

s.source = { :git => "https://github.com/ABridoux/BooleanExpressionEvaluation.git",
             :tag => "#{s.version}" }

s.source_files = "BooleanExpressionEvaluation/**/*.{swift}"

s.swift_version = "5"

end
