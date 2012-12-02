# -*- encoding: utf-8 -*-

require File.expand_path('../../config', __FILE__)

Gem::Specification.new do |gem|
  gem.name                  = 'hyperion-sqlite'
  gem.description           = %q{SQLite Datastore for Hyperion}
  gem.summary               = %q{SQLite Datastore for Hyperion}
  gem.authors               = ['Steve Kim']
  gem.email                 = ['skim@8thlight.com']

  Hyperion.gem_config(gem)

  gem.add_dependency('hyperion-sql', Hyperion::VERSION)
  gem.add_dependency('do_sqlite3', '0.10.10')
end
