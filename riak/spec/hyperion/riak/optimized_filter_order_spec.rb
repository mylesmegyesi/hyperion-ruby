require 'hyperion/filter'
require 'hyperion/riak/optimized_filter_order'

describe Hyperion::Riak::OptimizedFilterOrder do

  def filter(field, operator, value)
    Hyperion::Filter.new(field, operator, value)
  end

  context "no filters" do
    it 'returns "$bucket" for optimal_index_field' do
      filters = []
      bucket_name = "hamburgers"

      o = described_class.new(filters, bucket_name)
      o.optimal_index_field.should == '$bucket'
    end

    it 'returns bucket name for optimal_index_value' do
      filters = []
      bucket_name = "hamburgers"

      o = described_class.new(filters, bucket_name)
      o.optimal_index_value.should == bucket_name
    end

    it 'returns an empty collection for filters' do
      filters = []
      bucket_name = "hamburgers"

      o = described_class.new(filters, bucket_name)
      o.filters.should == []
    end
  end

  context 'optimizes for an equals filter' do
    it 'returns the index field' do
      filters = [filter(:int, '=', 1)]
      o = described_class.new(filters, '')
      o.optimal_index_field.should == :int
    end

    it 'returns bucket name for optimal_index_value' do
      filters = [filter(:int, '=', 1)]
      bucket_name = "hamburgers"

      o = described_class.new(filters, bucket_name)
      o.optimal_index_value.should == '1'
    end

     it 'excludes the optimized filter' do
      filters = [filter(:int, '=', 1)]
      o = described_class.new(filters, '')
      o.filters.should be_empty
     end
  end

  context 'optimizes for a range filter' do
    it 'returns the index field' do
      filters = [filter(:int, '<', 1), filter(:int, '>', 2), filter(:int, '?', 3)]
      o = described_class.new(filters, '')
      o.optimal_index_field.should == :int
    end

    it 'returns bucket name for optimal_index_value' do
      filters = [filter(:int, '<', 1), filter(:int, '>', 2), filter(:int, '?', 3)]

      o = described_class.new(filters, '')
      o.optimal_index_value.should == ('1'..'2')
    end

     it 'excludes the optimized filters' do
      leftover_filter = filter(:int, '?', 3)
      filters = [filter(:int, '<', 1), filter(:int, '>', 2), leftover_filter]
      o = described_class.new(filters, '')
      o.filters.should == [leftover_filter]
     end
  end

  context 'cannot be optimized' do
    it 'returns "$bucket" for index_field if no optimal filter' do
      filters = [filter(:int, '?', 1)]
      o = described_class.new(filters, '')
      o.optimal_index_field.should == '$bucket'
    end

    it 'returns bucket name for optimal_index_value' do
      filters = [filter(:int, '?', 1)]
      o = described_class.new(filters, 'cheeseburgers')
      o.optimal_index_value.should == 'cheeseburgers'
    end

     it 'filters contains all filters' do
      filters = [filter(:int, '?', 1)]
      o = described_class.new(filters, '')
      o.filters.should == filters
     end
  end

  it 'chooses equals filter over bucket' do
    equal_filter = filter(:data, '=', 3)
    o = described_class.new([equal_filter], '')
    o.optimal_index_field.should == :data
    o.optimal_index_value.should == '3'
    o.filters.should == []
  end

  it 'chooses equals filter over range filter' do
    equal_filter = filter(:data, '=', 3)
    filters = [filter(:int, '<', 1), filter(:int, '>', 2)]
    o = described_class.new(filters + [equal_filter], '')
    o.optimal_index_field.should == :data
    o.optimal_index_value.should == '3'
    o.filters.should == filters
  end

  it 'chooses range filter over bucket filter' do
    filters = [filter(:int, '<', 1), filter(:int, '>', 2)]
    o = described_class.new(filters, '')
    o.optimal_index_field.should == :int
  end
end
