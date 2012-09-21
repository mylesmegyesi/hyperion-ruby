module Hyperion
  class Sort

    attr_reader :field, :order

    def initialize(field, order)
      @field = field
      @order = order
    end

    def ascending?
      order == :asc
    end

    def descending?
      order == :desc
    end

    def to_h
      {
        :field => field,
        :order => order
      }
    end
  end
end
