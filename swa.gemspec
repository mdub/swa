# frozen_string_literal: true

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
  spec.required_ruby_version = ">= 2.7"

  spec.files         = Dir.glob("lib/**/*.rb") + ["README.md", "LICENSE.txt"]
  spec.bindir        = "exe"
  spec.executables   = ["swa"]
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk-athena", "~> 1"
  spec.add_dependency "aws-sdk-cloudformation", "~> 1"
  spec.add_dependency "aws-sdk-cloudtrail", "~> 1"
  spec.add_dependency "aws-sdk-ec2", "~> 1"
  spec.add_dependency "aws-sdk-elasticloadbalancing", "~> 1"
  spec.add_dependency "aws-sdk-glue", "~> 1"
  spec.add_dependency "aws-sdk-iam", "~> 1"
  spec.add_dependency "aws-sdk-kms", "~> 1"
  spec.add_dependency "aws-sdk-lakeformation", "~> 1"
  spec.add_dependency "aws-sdk-s3", "~> 1"
  spec.add_dependency "csv"
  spec.add_dependency "openssl", ">= 3.3.1"
  spec.add_dependency "pry"

  spec.add_dependency "bytesize"
  spec.add_dependency "chronic"
  spec.add_dependency "clamp", ">= 1.1.0"
  spec.add_dependency "console_logger"
  spec.add_dependency "multi_json"
  spec.add_dependency "ox"
  spec.add_dependency "stackup", ">= 1.0.0"

  spec.metadata["rubygems_mfa_required"] = "true"
end
