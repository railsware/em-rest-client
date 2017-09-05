# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "em-rest-client"
  spec.version       = "0.0.1"
  spec.authors       = ["Andriy Yanko"]
  spec.email         = ["andriy.yanko@railsware.com"]

  spec.summary       = %q{EventMachine::HttpRequest adapter for HTTP REST client}
  spec.homepage      = "https://github.com/railsware/em-rest-client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rest-client", ">= 1.8"
  spec.add_development_dependency "em-http-request", "~> 1.1"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4.0"
  spec.add_development_dependency "webmock", "~> 3.0"
end
