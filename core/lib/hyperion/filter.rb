module Hyperion
  class Filter

    attr_reader :operator, :field, :value

    def initialize(field, operator, value)
      @operator = operator
      @field = field
      @value = value
    end
  end
end
