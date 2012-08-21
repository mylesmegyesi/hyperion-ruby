module Hyperion
  class Query
    attr_reader :kind, :filters

    def initialize(kind, filters)
      @kind = kind
      @filters = filters
    end

  end
end
