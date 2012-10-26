require 'hyperion/query'
require 'hyperion/filter'
require 'hyperion/sort'
require 'hyperion/util'
require 'hyperion/format'

module Hyperion

  def self.defentity(kind)
    kind = Format.format_kind(kind)
    kind_spec = KindSpec.new(kind)
    yield(kind_spec)
    save_kind_spec(kind_spec)
    pack(kind.to_sym) {|value| pack_record((value || {}).merge(:kind => kind))}
    unpack(kind.to_sym) {|value| unpack_record((value || {}).merge(:kind => kind))}
  end

  def self.pack(type, &block)
    packers[type] = block
  end

  def self.packer_defined?(type)
    packers.has_key?(type)
  end

  def self.unpack(type, &block)
    unpackers[type] = block
  end

  def self.unpacker_defined?(type)
    unpackers.has_key?(type)
  end

  # Sets the active datastore
  def self.datastore=(datastore)
    @datastore = datastore
  end

  # Returns the current datastore instance
  def self.datastore
    Thread.current[:datastore] || @datastore || raise('No Datastore installed')
  end

  # Assigns the datastore within the given block
  def self.with_datastore(name, opts={})
    Util.bind(:datastore, new_datastore(name, opts)) do
      yield
    end
  end

  def self.new_datastore(name, opts={})
    begin
      require "hyperion/#{name}"
    rescue LoadError
      raise "Can't find datastore implementation: #{name}"
    end
    ds_klass = Hyperion.const_get(Util.class_name(name.to_s))
    ds_klass.new(opts)
  end

  #  Saves a record. Any additional parameters will get merged onto the record before it is saved.
  #
  #  Hyperion.save({:kind => :foo})
  #  => {:kind=>"foo", :key=>"<generated key>"}
  #  Hyperion.save({:kind => :foo}, :value => :bar)
  #  => {:kind=>"foo", :value=>:bar, :key=>"<generated key>"}
  def self.save(record, attrs={})
    save_many([record.merge(attrs || {})]).first
  end

  # Saves multiple records at once.
  def self.save_many(records)
    unpack_records(datastore.save(pack_records(records)))
  end

  # Returns true if the record is new (not saved/doesn't have a :key), false otherwise.
  def self.new?(record)
    !record.has_key?(:key)
  end

  # Retrieves the value associated with the given key from the datastore. nil if it doesn't exist.
  def self.find_by_key(key)
    unpack_record(datastore.find_by_key(key))
  end

  # Returns all records of the specified kind that match the filters provided.
  #
  #   find_by_kind(:dog) # returns all records with :kind of \"dog\"
  #   find_by_kind(:dog, :filters => [[:name, '=', "Fido"]]) # returns all dogs whos name is Fido
  #   find_by_kind(:dog, :filters => [[:age, '>', 2], [:age, '<', 5]]) # returns all dogs between the age of 2 and 5 (exclusive)
  #   find_by_kind(:dog, :sorts => [[:name, :asc]]) # returns all dogs in alphebetical order of their name
  #   find_by_kind(:dog, :sorts => [[:age, :desc], [:name, :asc]]) # returns all dogs ordered from oldest to youngest, and gos of the same age ordered by name
  #   find_by_kind(:dog, :limit => 10) # returns upto 10 dogs in undefined order
  #   find_by_kind(:dog, :sorts => [[:name, :asc]], :limit => 10) # returns upto the first 10 dogs in alphebetical order of their name
  #   find_by_kind(:dog, :sorts => [[:name, :asc]], :limit => 10, :offset => 10) # returns the second set of 10 dogs in alphebetical order of their name
  #
  # Filter operations and acceptable syntax:
  #   "=" "eq"
  #   "<" "lt"
  #   "<=" "lte"
  #   ">" "gt"
  #   ">=" "gte"
  #   "!=" "not"
  #   "contains?" "contains" "in?" "in"
  #
  # Sort orders and acceptable syntax:
  #   :asc "asc" :ascending "ascending"
  #   :desc "desc" :descending "descending"
  def self.find_by_kind(kind, args={})
    unpack_records(datastore.find(build_query(kind, args)))
  end

  # Removes the record stored with the given key. Returns nil no matter what.
  def self.delete_by_key(key)
    datastore.delete_by_key(key)
  end

  # Deletes all records of the specified kind that match the filters provided.
  def self.delete_by_kind(kind, args={})
    datastore.delete(build_query(kind, args))
  end

  # Counts records of the specified kind that match the filters provided.
  def self.count_by_kind(kind, args={})
    datastore.count(build_query(kind, args))
  end

  private

  def self.packers
    @packers ||= {}
  end

  def self.unpackers
    @unpackers ||= {}
  end

  def self.build_query(kind, args)
    kind = Format.format_kind(kind)
    filters = build_filters(args[:filters])
    sorts = build_sorts(args[:sorts])
    Query.new(kind, filters, sorts, args[:limit], args[:offset])
  end

  def self.build_filters(filters)
    (filters || []).map do |(field, operator, value)|
      operator = Format.format_operator(operator)
      field = Format.format_field(field)
      Filter.new(field, operator, value)
    end
  end

  def self.build_sorts(sorts)
    (sorts || []).map do |(field, order)|
      field = Format.format_field(field)
      order = Format.format_order(order)
      Sort.new(field, order)
    end
  end

  def self.unpack_records(records)
    records.map do |record|
      unpack_record(record)
    end
  end

  def self.unpack_record(record)
    if record
      create_entity(record) do |field_spec, value|
        field_spec.unpack(value)
      end
    end
  end

  def self.pack_records(records)
    records.map do |record|
      pack_record(record)
    end
  end

  def self.pack_record(record)
    if record
      entity = create_entity(record) do |field_spec, value|
        field_spec.pack(value || field_spec.default)
      end
      update_timestamps(entity)
    end
  end

  def self.packer_for(type)
    @packers[type]
  end

  def self.unpacker_for(type)
    @unpackers[type]
  end

  def self.update_timestamps(record)
    new?(record) ? update_created_at(record) : update_updated_at(record)
  end

  def self.update_updated_at(record)
    spec = kind_spec_for(record[:kind])
    if spec && spec.fields.include?(:updated_at)
      record[:updated_at] = Time.now
    end
    record
  end

  def self.update_created_at(record)
    spec = kind_spec_for(record[:kind])
    if spec && spec.fields.include?(:created_at)
      record[:created_at] = Time.now
    end
    record
  end

  def self.create_entity(record)
    record = Format.format_record(record)
    kind = record[:kind]
    spec = kind_spec_for(kind)
    unless spec
      record
    else
      key = record[:key]
      base_record = {:kind => kind}
      base_record[:key] = key if key
      spec.fields.reduce(base_record) do |new_record, (name, spec)|
        new_record[name] = yield(spec, record[name])
        new_record
      end
    end
  end

  def self.kind_spec_for(kind)
    @kind_specs ||= {}
    @kind_specs[kind]
  end

  def self.save_kind_spec(kind_spec)
    @kind_specs ||= {}
    @kind_specs[kind_spec.kind] = kind_spec
  end

  class FieldSpec

    attr_reader :name, :default

    def initialize(name, opts={})
      @name = name
      @default = opts[:default]
      @type = opts[:type]
      @packer = opts[:packer]
      @unpacker = opts[:unpacker]
    end

    def pack(value)
      if @packer && @packer.respond_to?(:call)
        @packer.call(value)
      elsif @type
        type_packer = Hyperion.packer_for(@type)
        type_packer ? type_packer.call(value) : value
      else
        value
      end
    end

    def unpack(value)
      if @unpacker && @unpacker.respond_to?(:call)
        @unpacker.call(value)
      elsif @type
        type_packer = Hyperion.unpacker_for(@type)
        type_packer ? type_packer.call(value) : value
      else
        value
      end
    end

  end

  class KindSpec

    attr_reader :kind, :fields

    def initialize(kind)
      @kind = kind
      @fields = {}
    end

    def field(name, opts={})
      name = Format.format_field(name)
      @fields[name] = FieldSpec.new(name, opts)
    end

  end

end
