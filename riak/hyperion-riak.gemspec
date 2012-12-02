# -*- encoding: utf-8 -*-

require File.expand_path('../../config', __FILE__)

Gem::Specification.new do |gem|
  gem.name                  = 'hyperion-riak'
  gem.description           = %q{Riak datastore for Hyperion}
  gem.summary               = %q{Riak datastore for Hypeiron}
  gem.authors               = ['Myles Megyesi']
  gem.email                 = ['myles@8thlight.com']

  Hyperion.gem_config(gem)

  gem.files                 += Dir['lib/**/*.erb']

  gem.add_dependency('hyperion-api', Hyperion::VERSION)
  gem.add_dependency('riak-client', '1.1.0')
end

