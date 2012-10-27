require 'hyperion'
require 'hyperion/shared_examples'
require 'hyperion/fake_ds'

describe Hyperion do

  def api
    Hyperion
  end

  context 'datastore' do
    it 'will throw an error if the datastore is called before assignment' do
      expect{ subject.datastore }.to raise_error
    end

    it 'assigns the datastore with brute force' do
      api.datastore = :something
      api.datastore.should == :something
      api.datastore = nil
    end

    it 'assigns datastore with elegance and returns the result' do
      api.with_datastore(:memory) do
        api.datastore.should be_a(Hyperion::Memory)
        :return
      end.should == :return
    end

    it 'prefers the thread-local datastore over the global datastore' do
      api.datastore = :something_else
      api.with_datastore(:memory) do
        api.datastore.should be_a(Hyperion::Memory)
      end
      api.datastore = :something_else
      api.datastore = nil
    end
  end

  context 'factory' do
    it 'bombs on unknown implementations' do
      expect {api.new_datastore(:unknown)}.to raise_error("Can't find datastore implementation: unknown")
    end

    it 'creates a memory datastore' do
      api.new_datastore(:memory).class.should == Hyperion::Memory
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

  context 'packer_defined?' do
    it 'false if a packer has not been defined for the given type' do
      Hyperion.packer_defined?(:undefined_packer).should == false
    end

    it 'true if a packer has been defined for the given type' do
      Hyperion.pack(:thing) {|value| value}
      Hyperion.packer_defined?(:thing).should == true
    end
  end

  context 'unpacker_defined?' do
    it 'false if a packer has not been defined for the given type' do
      Hyperion.unpacker_defined?(:undefined_packer).should == false
    end

    it 'true if a packer has been defined for the given type' do
      Hyperion.unpack(:thing) {|value| value}
      Hyperion.unpacker_defined?(:thing).should == true
    end
  end

  context 'with fake datastore' do

    def fake_ds
      api.datastore
    end

    around :each do |example|
      api.with_datastore(:fake_ds) do
        example.run
      end
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

      context 'record packing on save' do
        include_examples 'record packing', lambda { |record|
          Hyperion.save(record)
          Hyperion.datastore.saved_records.last
        }
      end

      context 'record unpacking on return from datastore' do
        include_examples 'record unpacking', lambda {|record|
          Hyperion.datastore.returns = [[record]]
          Hyperion.save({})
        }
      end
    end

    context 'save many' do

      context 'record packing on save' do
        include_examples 'record packing', lambda { |record|
          Hyperion.save_many([record])
          Hyperion.datastore.saved_records.last
        }
      end

      context 'record unpacking on return from datastore' do
        include_examples 'record unpacking', lambda { |record|
          Hyperion.datastore.returns = [[record]]
          Hyperion.save_many([{}]).last
        }
      end
    end

    context 'find by kind' do
      context 'parses kind' do
        include_examples 'kind formatting', lambda { |kind|
          Hyperion.find_by_kind(kind)
          Hyperion.datastore.queries.last.kind
        }
      end

      context 'parses filters' do
        include_examples 'filtering', lambda { |filter|
          Hyperion.find_by_kind('kind', :filters => [filter])
          Hyperion.datastore.queries.last.filters.first
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
            Hyperion.find_by_kind('kind', :sorts => [[field, 'desc']])
            Hyperion.datastore.queries.first.sorts.first.field
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
        include_examples 'record unpacking', lambda {|record|
          Hyperion.datastore.returns = [[record]]
          Hyperion.find_by_kind('kind').first
        }
      end
    end

    context 'delete by kind' do
      context 'parses kind' do
        include_examples 'kind formatting', lambda { |kind|
          Hyperion.delete_by_kind(kind)
          Hyperion.datastore.queries.last.kind
        }
      end

      context 'parses filters' do
        include_examples 'filtering', lambda { |filter|
          Hyperion.delete_by_kind('kind', :filters => [filter])
          Hyperion.datastore.queries.last.filters.first
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
          Hyperion.count_by_kind(kind)
          Hyperion.datastore.queries.last.kind
        }
      end

      context 'parses filters' do
        include_examples 'filtering', lambda { |filter|
          Hyperion.count_by_kind('kind', :filters => [filter])
          Hyperion.datastore.queries.last.filters.first
        }
      end
    end

    context 'find by key' do
      it 'finds by key' do
        api.find_by_key('key')
        fake_ds.key_queries.first.should == 'key'
      end

      context 'formats records on return from ds' do
        include_examples 'record unpacking', lambda {|record|
          Hyperion.datastore.returns = [record]
          Hyperion.find_by_key('key')
        }
      end

    end

    Hyperion.defentity(:keyed) do |kind|
      kind.field(:spouse_key, :type => Hyperion::Types.foreign_key(:spouse))
    end

    it 'returns the packer key' do
      Hyperion::Types.foreign_key(:spouse).should == :spouse_key
    end

    it 'defines a packer for the given kind' do
      Hyperion.packer_defined?(:spouse_key)
    end

    it 'defines an unpacker for the given kind' do
      Hyperion.unpacker_defined?(:spouse_key)
    end

    it 'formats the kind' do
      Hyperion::Types.foreign_key(:SPouse).should == :spouse_key
    end

    it 'asks the current datastore to pack the key' do
      key = 'the key to pack'
      Hyperion.save(:kind => :keyed, :spouse_key => key)
      fake_ds.key_pack_queries.first[:kind].should == :spouse
      fake_ds.key_pack_queries.first[:key].should == key
    end

    it 'asks the current datastore to unpack the key' do
      key = 'the key to pack'
      fake_ds.returns = [[{:kind => :keyed, :spouse_key => key}]]
      Hyperion.save(:kind => :keyed)
      fake_ds.key_unpack_queries.first[:kind].should == :spouse
      fake_ds.key_unpack_queries.first[:key].should == key
    end
  end
end
