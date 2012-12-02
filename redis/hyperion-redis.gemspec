# -*- encoding: utf-8 -*-

require File.expand_path('../../config', __FILE__)

Gem::Specification.new do |gem|
  gem.name                  = 'hyperion-redis'
  gem.description           = %q{Redis datastore for Hyperion}
  gem.summary               = %q{Redis datastore for Hypeiron}
  gem.authors               = ['Patrick Gombert']
  gem.email                 = ['patrickgombert@gmail.com']

  Hyperion.gem_config(gem)

  gem.files                 += Dir['lib/**/*.erb']

  gem.add_dependency('hyperion-api', Hyperion::VERSION)
  gem.add_dependency('redis', '3.0.2')
end

