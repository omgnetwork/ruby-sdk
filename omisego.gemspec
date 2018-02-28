
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omisego/version'

Gem::Specification.new do |spec|
  spec.name          = 'omisego'
  spec.version       = OmiseGO::VERSION
  spec.authors       = ['Thibault']
  spec.email         = ['thibault@omisego.co']

  spec.summary       = 'OmiseGO Ruby SDK.'
  spec.description   = 'OmiseGO Ruby SDK.'
  spec.homepage      = 'https://omg.omise.co/'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 0.13.1'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.50.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.12'
  spec.add_development_dependency 'webmock', '~> 2.1'
  spec.add_development_dependency 'vcr', '~> 3.0'
  spec.add_development_dependency 'pry-byebug', '~> 3.4.2'
end
