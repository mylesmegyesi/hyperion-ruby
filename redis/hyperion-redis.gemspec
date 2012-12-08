# -*- encoding: utf-8 -*-

require File.expand_path('../../config', __FILE__)

Gem::Specification.new do |gem|
  gem.version               = '0.2.0'
  gem.name                  = 'hyperion-redis'
  gem.description           = %q{Redis datastore for Hyperion}
  gem.summary               = %q{Redis datastore for Hypeiron}
  gem.authors               = ['Patrick Gombert']
  gem.email                 = ['patrickgombert@gmail.com']

  Hyperion.gem_config(gem)

  gem.add_dependency('hyperion-api', '0.2.0')
  gem.add_dependency('redis', '3.0.2')
  gem.add_dependency('json', '1.7.3')
end

