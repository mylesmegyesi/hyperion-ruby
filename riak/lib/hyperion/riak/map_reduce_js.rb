require 'erb'

module Hyperion
  module Riak
    class MapReduceJs
      class << self

        def filter(filters)
          template(:filter).result(binding)
        end

        def sort(sorts)
          template(:sort).result(binding)
        end

        def offset(offset)
          template(:offset).result(binding)
        end

        def offset(offset)
          template(:offset).result(binding)
        end

        def limit(limit)
          template(:limit).result(binding)
        end

        def count
          template(:count).result
        end

        def pass_thru
          template(:pass_thru).result
        end

        private

        def template(name)
          @templates ||= {}
          @templates[name] ||= ERB.new(file_contents(template_path(name)))
        end

        def template_path(name)
          File.expand_path(File.join('..', 'map_reduce', "#{name}.js.erb"), __FILE__)
        end

        def file_contents(path)
          File.open(path, 'rb') { |f| f.read }
        end
      end
    end
  end
end
