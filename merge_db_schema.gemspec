# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "merge_db_schema/version"

Gem::Specification.new do |spec|
  spec.name          = "merge_db_schema"
  spec.version       = MergeDBSchema::VERSION
  spec.authors       = ["Masataka Kuwabara"]
  spec.email         = ["kuwabara@pocke.me"]

  spec.summary       = %q{It is a git merge driver for db/schema.rb of Ruby on Rails. It resolves some of the conflict automatically.}
  spec.description   = %q{It is a git merge driver for db/schema.rb of Ruby on Rails. It resolves some of the conflict automatically.}
  spec.homepage      = "https://github.com/pocke/merge_db_schema"
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.3.0'

  spec.add_dependency "rainbow"

  spec.add_development_dependency "pry"
  spec.add_development_dependency "bundler", "< 3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.10"
end
