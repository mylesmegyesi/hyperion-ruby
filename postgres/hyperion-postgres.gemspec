# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name                  = 'hyperion-postgres'
  gem.version               = '0.0.1'
  gem.authors               = ['8th Light, Inc.']
  gem.email                 = ['myles@8thlight.com']
  gem.license               = 'Eclipse Public License'
  gem.description           = %q{Postgres Datastore for Hyperion}
  gem.summary               = %q{Postgres Datastore for Hyperion}
  gem.homepage              = 'https://github.com/mylesmegyesi/hyperion-ruby'
  gem.required_ruby_version = '1.9.1'

  gem.files                 = Dir['lib/**/*.rb']
  gem.test_files            = Dir['spec/**/*.rb']
  gem.require_paths         = ['lib']

  gem.add_dependency('hyperion-core', '0.0.1')
  gem.add_dependency('do_postgres', '0.10.8')
  gem.add_development_dependency('rspec', '2.11.0')
end
