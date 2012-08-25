require 'hyperion/core'

shared_examples_for 'kind formatting' do |actor|
  {
    'one'     => 'one',
    :one      => 'one',
    :TheKind  => 'the_kind',
    'TheKind' => 'the_kind'
  }.each_pair do |kind, result|

    it "#{kind} to #{result}" do
      actor.call(kind).should == result
    end

  end
end

shared_examples_for 'field formatting' do |actor|

  {
    'field' => :field,
    'Field' => :field,
    'FieldOne' => :field_one,
    'SomeBigAttr' => :some_big_attr,
    :SomeBigAttr => :some_big_attr,
    'one-two-three' => :one_two_three,
    'one two three' => :one_two_three
  }.each_pair do |field, result|

    it "#{field.inspect} to #{result.inspect}" do
      actor.call(field).should == result
    end

  end
end

shared_examples_for 'record formatting' do |actor|

  context 'formats kind' do
    include_examples 'kind formatting', lambda { |kind|
      record = actor.call({kind: kind})
      record[:kind]
    }
  end

  context 'formats fields' do
    include_examples 'field formatting', lambda { |field|
      record = actor.call({field => 'value'})
      record.delete(:kind)
      record.keys.first
    }
  end
end

shared_examples_for 'filtering' do |actor|

  context 'field' do
    include_examples 'field formatting', lambda { |field|
      actor.call([field, '=', 0]).field
    }
  end

  context 'operator' do

    {
      '='         => '=',
      'eq'        => '=',
      '<'         => '<',
      'lt'        => '<',
      '>'         => '>',
      'gt'        => '>',
      '<='        => '<=',
      'lte'       => '<=',
      '>='        => '>=',
      'gte'       => '>=',
      '!='        => '!=',
      'not'       => '!=',
      'contains'  => 'contains?',
      'contains?' => 'contains?',
      'in?'       => 'contains?',
      'in'        => 'contains?',
    }.each_pair do |filter, result|

        it "#{filter} to #{result}" do
          actor.call([:attr, filter, 0]).operator.should == result
        end

      end
  end

  it 'passes the value to the filter' do
    actor.call([:attr, '=', 0]).value.should == 0
  end
end

class FakeDatastore

  attr_accessor :saved_records, :queries, :returns

  def initialize
    @saved_records = []
    @returns = []
    @queries = []
  end

  def save(records)
    @saved_records += records
    returns.shift || []
  end

  def find(query)
    @queries << query
    returns.shift || []
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

describe Hyperion::Core do

  def core
    Hyperion::Core
  end

  context 'datastore' do
    it 'will throw an error if the datastore is called before assignment' do
      expect{ subject.datastore }.to raise_error
    end
  end

  context 'new?' do
    it 'false if a record exists' do
      core.new?({key: 1}).should be_false
    end

    it 'true if a record does not exist' do
      core.new?({}).should be_true
    end
  end

  context 'with fake datastore' do
    attr_reader :fake_ds

    before :each do
      @fake_ds = FakeDatastore.new
      core.datastore = @fake_ds
    end

    context 'save' do

      it 'saves a record' do
        record = {kind: 'one'}
        core.save(record)
        core.datastore.saved_records.first.should == record
      end

      it 'merges the given attrs' do
        core.save({kind: 'one'}, attr: 'value')
        core.datastore.saved_records.first.should == {kind: 'one', attr: 'value'}
      end

      it 'handles nil input to attrs' do
        core.save({kind: 'one'}, nil)
        core.datastore.saved_records.first.should == {kind: 'one'}
      end

      context 'record formatting on save' do
        include_examples 'record formatting', lambda { |record|
          Hyperion::Core.save(record)
          Hyperion::Core.datastore.saved_records.first
        }
      end

      context 'record formatting on return from datastore' do
        include_examples 'record formatting', lambda {|record|
          Hyperion::Core.datastore.returns = [[record]]
          Hyperion::Core.save({})
        }
      end
    end

    context 'save many' do

      context 'record formatting on save' do
        include_examples 'record formatting', lambda { |record|
          Hyperion::Core.save_many([record])
          Hyperion::Core.datastore.saved_records.first
        }
      end

      context 'record formatting on return from datastore' do
        include_examples 'record formatting', lambda { |record|
          Hyperion::Core.datastore.returns = [[record]]
          Hyperion::Core.save_many([{}]).first
        }
      end
    end

    context 'find by kind' do
      context 'parses kind' do
        include_examples 'kind formatting', lambda { |kind|
          Hyperion::Core.find_by_kind(kind)
          Hyperion::Core.datastore.queries.last.kind
        }
      end

      context 'parses filters' do
        include_examples 'filtering', lambda { |filter|
          Hyperion::Core.find_by_kind('kind', filters: [filter])
          Hyperion::Core.datastore.queries.last.filters.first
        }
      end

      context 'parses sorts' do

        def do_find(sort)
          core.find_by_kind('kind', sorts: [sort])
          query = fake_ds.queries.last
          query.sorts.first
        end

        context 'field' do
          include_examples 'field formatting', lambda { |field|
            Hyperion::Core.find_by_kind('kind', sorts: [[field, 'desc']])
            Hyperion::Core.datastore.queries.first.sorts.first.field
          }
        end

        context 'order' do
          {
            'desc' => :desc,
            :desc  => :desc,
            'asc'  => :asc,
            :asc   => :asc
          }.each_pair do |order, result|

            it "#{order.inspect} to #{result.inspect}" do
              do_find([:attr, order]).order.should == result
            end

          end
        end
      end

      it 'passes limit to the query' do
        core.find_by_kind('kind', limit: 1)
        fake_ds.queries.first.limit.should == 1
      end

      it 'passes offset to the query' do
        core.find_by_kind('kind', offset: 10)
        fake_ds.queries.first.offset.should == 10
      end
    end
  end

  context 'delete by kind' do
    context 'parses kind' do
      include_examples 'kind formatting', lambda { |kind|
        Hyperion::Core.delete_by_kind(kind)
        Hyperion::Core.datastore.queries.last.kind
      }
    end

    context 'parses filters' do
      include_examples 'filtering', lambda { |filter|
        Hyperion::Core.delete_by_kind('kind', filters: [filter])
        Hyperion::Core.datastore.queries.last.filters.first
      }
    end
  end

  context 'count by kind' do
    context 'parses kind' do
      include_examples 'kind formatting', lambda { |kind|
        Hyperion::Core.count_by_kind(kind)
        Hyperion::Core.datastore.queries.last.kind
      }
    end

    context 'parses filters' do
      include_examples 'filtering', lambda { |filter|
        Hyperion::Core.count_by_kind('kind', filters: [filter])
        Hyperion::Core.datastore.queries.last.filters.first
      }
    end
  end
end
