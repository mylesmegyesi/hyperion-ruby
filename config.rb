module Hyperion
  VERSION = '0.1.1'

  def self.gem_config(gem)
    gem.version               = VERSION
    gem.license               = 'Eclipse Public License'
    gem.homepage              = 'https://github.com/mylesmegyesi/hyperion-ruby'
    gem.required_ruby_version = '>=1.8.7'

    gem.files                 = Dir['lib/**/*.rb']
    gem.test_files            = Dir['spec/**/*.rb']
    gem.require_paths         = ['lib']

    gem.add_development_dependency('rspec', '2.11.0')
  end

end
