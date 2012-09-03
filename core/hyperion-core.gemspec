# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name                  = 'hyperion-core'
  gem.version               = '0.0.1'
  gem.authors               = ['8th Light, Inc.']
  gem.email                 = ['myles@8thlight.com']
  gem.license               = 'Eclipse Public License'
  gem.description           = %q{A Generic Persistence API for Ruby}
  gem.summary               = %q{A Generic Persistence API for Ruby}
  gem.homepage              = 'https://github.com/mylesmegyesi/hyperion-ruby'
  gem.required_ruby_version = '>= 1.8.7'

  gem.files                 = Dir['lib/**/*.rb']
  gem.test_files            = Dir['spec/**/*.rb']
  gem.require_paths         = ['lib']

  gem.add_development_dependency('rspec', '2.11.0')
end
