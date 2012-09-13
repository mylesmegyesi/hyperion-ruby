class FakeDatastore

  attr_accessor :saved_records, :queries, :key_queries, :returns

  def initialize
    @saved_records = []
    @returns = []
    @queries = []
    @key_queries = []
  end

  def save(records)
    @saved_records += records
    returns.shift || []
  end

  def find_by_key(key)
    @key_queries << key
    returns.shift || nil
  end

  def find(query)
    @queries << query
    returns.shift || []
  end

  def delete_by_key(key)
    @key_queries << key
    nil
  end

  def delete(query)
    @queries << query
    returns.shift || nil
  end

  def count(query)
    @queries << query
    returns.shift || 0
  end

end

