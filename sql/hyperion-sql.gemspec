# -*- encoding: utf-8 -*-

require File.expand_path('../../config', __FILE__)

Gem::Specification.new do |gem|
  gem.version               = '0.2.0'
  gem.name                  = 'hyperion-sql'
  gem.description           = %q{Shared behavior for Sql databases}
  gem.summary               = %q{Shared behavior for Sql databases}
  gem.authors               = ['Myles Megyesi']
  gem.email                 = ['myles@8thlight.com']

  Hyperion.gem_config(gem)

  gem.add_dependency('hyperion-api', '0.2.0')
  gem.add_development_dependency('do_sqlite3', '0.10.10')
end
