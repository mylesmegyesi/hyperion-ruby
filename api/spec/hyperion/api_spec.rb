require 'hyperion/api'
require 'hyperion/shared_examples'
require 'hyperion/fake_ds'

describe Hyperion::API do

  def api
    Hyperion::API
  end

  context 'datastore' do
    it 'will throw an error if the datastore is called before assignment' do
      expect{ subject.datastore }.to raise_error
    end
  end

  context 'new?' do
    it 'false if a record exists' do
      api.new?({:key => 1}).should be_false
    end

    it 'true if a record does not exist' do
      api.new?({}).should be_true
    end
  end

  context 'with fake datastore' do
    attr_reader :fake_ds

    before :each do
      @fake_ds = FakeDatastore.new
      api.datastore = @fake_ds
    end

    context 'save' do

      it 'saves a record' do
        record = {:kind => 'one'}
        api.save(record)
        api.datastore.saved_records.first.should == record
      end

      it 'merges the given attrs' do
        api.save({:kind => 'one'}, :attr =>'value')
        api.datastore.saved_records.first.should == {:kind => 'one', :attr => 'value'}
      end

      it 'handles nil input to attrs' do
        api.save({:kind => 'one'}, nil)
        api.datastore.saved_records.first.should == {:kind => 'one'}
      end

      context 'record formatting on save' do
        include_examples 'record formatting', lambda { |record|
          Hyperion::API.save(record)
          Hyperion::API.datastore.saved_records.first
        }
      end

      context 'record formatting on return from datastore' do
        include_examples 'record formatting', lambda {|record|
          Hyperion::API.datastore.returns = [[record]]
          Hyperion::API.save({})
        }
      end
    end

    context 'save many' do

      context 'record formatting on save' do
        include_examples 'record formatting', lambda { |record|
          Hyperion::API.save_many([record])
          Hyperion::API.datastore.saved_records.first
        }
      end

      context 'record formatting on return from datastore' do
        include_examples 'record formatting', lambda { |record|
          Hyperion::API.datastore.returns = [[record]]
          Hyperion::API.save_many([{}]).first
        }
      end
    end

    context 'find by kind' do
      context 'parses kind' do
        include_examples 'kind formatting', lambda { |kind|
          Hyperion::API.find_by_kind(kind)
          Hyperion::API.datastore.queries.last.kind
        }
      end

      context 'parses filters' do
        include_examples 'filtering', lambda { |filter|
          Hyperion::API.find_by_kind('kind', :filters => [filter])
          Hyperion::API.datastore.queries.last.filters.first
        }
      end

      context 'parses sorts' do

        def do_find(sort)
          api.find_by_kind('kind', :sorts => [sort])
          query = fake_ds.queries.last
          query.sorts.first
        end

        context 'field' do
          include_examples 'field formatting', lambda { |field|
            Hyperion::API.find_by_kind('kind', :sorts => [[field, 'desc']])
            Hyperion::API.datastore.queries.first.sorts.first.field
          }
        end

        context 'order' do
          {
            'desc'       => :desc,
            :desc        => :desc,
            'descending' => :desc,
            'asc'        => :asc,
            :asc         => :asc,
            'ascending'  => :asc
          }.each_pair do |order, result|

            it "#{order.inspect} to #{result.inspect}" do
              do_find([:attr, order]).order.should == result
            end

          end
        end
      end

      it 'passes limit to the query' do
        api.find_by_kind('kind', :limit => 1)
        fake_ds.queries.first.limit.should == 1
      end

      it 'passes offset to the query' do
        api.find_by_kind('kind', :offset => 10)
        fake_ds.queries.first.offset.should == 10
      end

      context 'formats records on return from ds' do
        include_examples 'record formatting', lambda {|record|
          Hyperion::API.datastore.returns = [[record]]
          Hyperion::API.find_by_kind('kind').first
        }
      end
    end

    context 'delete by kind' do
      context 'parses kind' do
        include_examples 'kind formatting', lambda { |kind|
          Hyperion::API.delete_by_kind(kind)
          Hyperion::API.datastore.queries.last.kind
        }
      end

      context 'parses filters' do
        include_examples 'filtering', lambda { |filter|
          Hyperion::API.delete_by_kind('kind', :filters => [filter])
          Hyperion::API.datastore.queries.last.filters.first
        }
      end
    end

    it 'deletes by key' do
      api.delete_by_key('delete_key')
      fake_ds.key_queries.first.should == 'delete_key'
    end

    context 'count by kind' do
      context 'parses kind' do
        include_examples 'kind formatting', lambda { |kind|
          Hyperion::API.count_by_kind(kind)
          Hyperion::API.datastore.queries.last.kind
        }
      end

      context 'parses filters' do
        include_examples 'filtering', lambda { |filter|
          Hyperion::API.count_by_kind('kind', :filters => [filter])
          Hyperion::API.datastore.queries.last.filters.first
        }
      end
    end

    context 'find by key' do
      it 'finds by key' do
        api.find_by_key('key')
        fake_ds.key_queries.first.should == 'key'
      end

      context 'formats records on return from ds' do
        include_examples 'record formatting', lambda {|record|
          Hyperion::API.datastore.returns = [record]
          Hyperion::API.find_by_key('key')
        }
      end

    end
  end
end
