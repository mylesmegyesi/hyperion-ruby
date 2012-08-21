# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'hyperion-core'
  gem.version       = '0.0.1'
  gem.authors       = ['Myles Megyesi', 'Ben Voss']
  gem.email         = ['mylesmegyesi@me.com']
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ''

  gem.files = Dir['lib/**/*.rb']
  gem.test_files = Dir['spec/**/*.rb']
  gem.require_paths = ['lib']

  gem.add_development_dependency('rspec', '2.11.0')
end
