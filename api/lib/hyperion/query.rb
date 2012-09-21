module Hyperion
  class Query
    attr_reader :kind, :filters, :sorts, :limit, :offset

    def initialize(kind, filters, sorts, limit, offset)
      @kind = kind
      @filters = filters || []
      @sorts = sorts || []
      @limit = limit
      @offset = offset
    end

    def to_h
      {
        :kind    => kind,
        :filters => filters.map(&:to_h),
        :sorts   => sorts.map(&:to_h),
        :limit   => limit,
        :offset  => offset
      }
    end

  end
end
