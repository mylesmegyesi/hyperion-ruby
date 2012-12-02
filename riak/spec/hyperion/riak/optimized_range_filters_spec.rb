require 'hyperion/filter'
require 'hyperion/riak/optimized_range_filters'

describe Hyperion::Riak::OptimizedRangeFilters do
  let(:test_less_than_filter) { filter(:test, '<', 1) }
  let(:test_greater_than_filter) { filter(:test, '>', 1) }
  let(:test_equals_filter) { filter(:test, '=', 1) }
  let(:nil_test_equals_filter) { filter(:test, '=', nil) }
  let(:other_test_less_than_filter) { filter(:other_test, '<', 1) }
  let(:other_test_greater_than_filter) { filter(:other_test, '>', 1) }

  it 'returns the filters' do
    optimizer = described_class.new([])
    optimizer.remaining_filters.should == []
  end

  def filter(field, operator, value)
    Hyperion::Filter.new(field, operator, value)
  end

  it 'returns the optimal filters' do
    optimizer = described_class.new([test_less_than_filter, test_greater_than_filter])
    optimizer.less_than_filter.should == test_less_than_filter
    optimizer.greater_than_filter.should == test_greater_than_filter
    optimizer.remaining_filters.should == []
  end

  it 'returns the optimal filters' do
    optimizer = described_class.new([test_greater_than_filter, test_less_than_filter])
    optimizer.less_than_filter.should == test_less_than_filter
    optimizer.greater_than_filter.should == test_greater_than_filter
    optimizer.remaining_filters.should == []
  end

  it 'returns non-range filter as remaining filter' do
    optimizer = described_class.new([
      test_greater_than_filter,
      test_less_than_filter,
      test_equals_filter
    ])
    optimizer.remaining_filters.should == [test_equals_filter]
  end

  it 'does not return a less than filter if there is no greater than' do
    filters = [test_less_than_filter, test_equals_filter]
    optimizer = described_class.new(filters)
    optimizer.remaining_filters.should == filters
    optimizer.less_than_filter.should be_nil
  end

  it 'does not return a less than filter if there is no matching greater than' do
    filters = [
      filter(:test, '<', 1),
      filter(:other_test, '>', 1),
      test_equals_filter
    ]
    optimizer = described_class.new(filters)
    optimizer.remaining_filters.should == filters
    optimizer.less_than_filter.should be_nil
    optimizer.greater_than_filter.should be_nil
  end

  it 'returns a matching range when there are other candidates' do
    filters = [
      test_less_than_filter,
      other_test_less_than_filter,
      other_test_greater_than_filter,
      test_equals_filter
    ]
    optimizer = described_class.new(filters)
    optimizer.remaining_filters.should == [test_less_than_filter, test_equals_filter]
    optimizer.less_than_filter.should == other_test_less_than_filter
    optimizer.greater_than_filter.should == other_test_greater_than_filter
  end

  it 'returns a matching range when there are other candidates' do
    filters = [
      test_greater_than_filter,
      other_test_greater_than_filter,
      test_less_than_filter,
      test_equals_filter
    ]
    optimizer = described_class.new(filters)
    optimizer.remaining_filters.should == [other_test_greater_than_filter, test_equals_filter]
    optimizer.less_than_filter.should == test_less_than_filter
    optimizer.greater_than_filter.should == test_greater_than_filter
  end
end
