module Hyperion
  class Util

    class << self

      def camel_case(str)
        str.gsub(/[_| |\-][A-Za-z]/) { |a| a[1..-1].upcase }
      end

      def class_name(str)
        cameled = camel_case(str)
        cameled[0] = cameled[0].capitalize
        cameled
      end

    end

  end
end
