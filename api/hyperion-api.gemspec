# -*- encoding: utf-8 -*-

require File.expand_path('../../config', __FILE__)

Gem::Specification.new do |gem|
  gem.name                  = 'hyperion-api'
  gem.description           = %q{A Generic Persistence API for Ruby}
  gem.summary               = %q{A Generic Persistence API for Ruby}
  gem.authors               = ['Myles Megyesi']
  gem.email                 = ['myles@8thlight.com']

  Hyperion.gem_config(gem)

  gem.add_dependency('uuidtools', '2.1.3')
end
