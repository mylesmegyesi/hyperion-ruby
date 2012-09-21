# -*- encoding: utf-8 -*-

require File.expand_path('../../config', __FILE__)

Gem::Specification.new do |gem|
  gem.name                  = 'hyperion-mysql'
  gem.description           = %q{MySQL Datastore for Hyperion}
  gem.summary               = %q{MySQL Datastore for Hyperion}
  gem.authors               = ['Myles Megyesi']
  gem.email                 = ['myles@8thlight.com']

  Hyperion.gem_config(gem)

  gem.add_dependency('hyperion-sql', Hyperion::VERSION)
  gem.add_dependency('do_mysql', '0.10.8')
end
