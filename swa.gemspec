lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "swa/version"

Gem::Specification.new do |spec|

  spec.name          = "swa"
  spec.version       = Swa::VERSION
  spec.authors       = ["Mike Williams"]
  spec.email         = ["mdub@dogbiscuit.org"]

  spec.summary       = "AWS, backwards"

  spec.homepage      = "https://github.com/mdub/swa"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rubocop", "~> 1.0"

  spec.add_runtime_dependency "aws-sdk-athena", "~> 1"
  spec.add_runtime_dependency "aws-sdk-cloudformation", "~> 1"
  spec.add_runtime_dependency "aws-sdk-cloudtrail", "~> 1"
  spec.add_runtime_dependency "aws-sdk-ec2", "~> 1"
  spec.add_runtime_dependency "aws-sdk-elasticloadbalancing", "~> 1"
  spec.add_runtime_dependency "aws-sdk-glue", "~> 1"
  spec.add_runtime_dependency "aws-sdk-iam", "~> 1"
  spec.add_runtime_dependency "aws-sdk-kms", "~> 1"
  spec.add_runtime_dependency "aws-sdk-lakeformation", "~> 1"
  spec.add_runtime_dependency "aws-sdk-s3", "~> 1"
  spec.add_runtime_dependency "csv"
  spec.add_runtime_dependency "openssl", ">= 3.3.1"
  spec.add_runtime_dependency "pry"

  spec.add_runtime_dependency "bytesize"
  spec.add_runtime_dependency "chronic"
  spec.add_runtime_dependency "clamp", ">= 1.1.0"
  spec.add_runtime_dependency "console_logger"
  spec.add_runtime_dependency "multi_json"
  spec.add_runtime_dependency "ox"
  spec.add_runtime_dependency "stackup", ">= 1.0.0"

end
