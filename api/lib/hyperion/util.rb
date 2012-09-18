module Hyperion
  class Util

    class << self

      def camel_case(str)
        cameled = str.gsub(/[_| |\-][A-Za-z]/) { |a| a[1..-1].upcase } if str
        uncapitalize(cameled)
      end

      def class_name(str)
        capitalize(camel_case(str))
      end

      def snake_case(str)
        str.gsub(/([a-z0-9])([A-Z])/, '\1 \2').downcase.gsub(/[ |\-]/, '_') if str
      end

      def capitalize(str)
        do_to_first(str) do |first_letter|
          first_letter.upcase
        end
      end

      def uncapitalize(str)
        do_to_first(str) do |first_letter|
          first_letter.downcase
        end
      end

      def do_to_first(str)
        if str
          first = yield(str[0, 1])
          if str.length > 1
            last = str[1..-1]
            first + last
          else
            first
          end
        end
      end

    end

  end
end
