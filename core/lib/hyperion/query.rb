module Hyperion
  class Query
    attr_reader :kind

    def initialize(kind)
      @kind = kind
    end

  end
end
