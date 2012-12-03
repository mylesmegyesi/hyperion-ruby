# -*- encoding: utf-8 -*-

require File.expand_path('../../config', __FILE__)

Gem::Specification.new do |gem|
  gem.version               = '0.2.0'
  gem.name                  = 'hyperion-postgres'
  gem.description           = %q{Postgres Datastore for Hyperion}
  gem.summary               = %q{Postgres Datastore for Hyperion}
  gem.authors               = ['Myles Megyesi']
  gem.email                 = ['myles@8thlight.com']

  Hyperion.gem_config(gem)

  gem.add_dependency('hyperion-sql', '0.2.0')
  gem.add_dependency('do_postgres', '0.10.10')
end
