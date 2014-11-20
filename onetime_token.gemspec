# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'onetime_token/version'

Gem::Specification.new do |spec|
  spec.name          = "onetime_token"
  spec.version       = OnetimeToken::VERSION
  spec.authors       = ["f-kubotar"]
  spec.email         = ["f.kubotar@paperboy.co.jp"]
  spec.summary       = %q{Generate a temporary token of secret associated with ActiveRecord. it is stored in redis.}
  spec.description   = %q{Generate a temporary token of secret associated with ActiveRecord. it is stored in redis.
You will be able to verify whether the token is correct.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'redis'
  spec.add_dependency 'redis-namespace'
  spec.add_dependency 'connection_pool'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
