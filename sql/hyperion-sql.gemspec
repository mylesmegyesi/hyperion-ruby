# -*- encoding: utf-8 -*-

require File.expand_path('../../config', __FILE__)

Gem::Specification.new do |gem|
  gem.name                  = 'hyperion-sql'
  gem.description           = %q{Shared behavior for Sql databases}
  gem.summary               = %q{Shared behavior for Sql databases}

  Hyperion.gem_config(gem)

  gem.add_dependency('hyperion-core', Hyperion::VERSION)
end
