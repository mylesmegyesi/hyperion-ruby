require 'hyperion/types'

shared_examples_for 'Datastore' do

  def api
    Hyperion
  end

  context 'save' do

    it 'saves a hash and returns it' do
      record = api.save({:kind => 'testing', :name => 'ann'})
      record[:kind].should == 'testing'
      record[:name].should == 'ann'
    end

    it 'saves an empty record' do
      record = api.save({:kind => 'testing'})
      record[:kind].should == 'testing'
    end

    it 'assigns a key to new records' do
      record = api.save({:kind => 'testing', :name => 'ann'})
      record[:key].should_not be_nil
    end

    it 'saves an existing record' do
      record1 = api.save({:kind => 'other_testing', :name => 'ann'})
      record2 = api.save({:kind => 'other_testing', :key => record1[:key]}, :name => 'james')
      record1[:key].should == record2[:key]
      api.find_by_kind('other_testing').length.should == 1
    end

    it 'saves an existing record to be empty' do
      record1 = api.save({:kind => 'other_testing', :name => 'ann'})
      record2 = record1.dup
      record2.delete(:name)
      record2 = api.save(record2)
      record1[:key].should == record2[:key]
      api.find_by_kind('other_testing').length.should == 1
    end

    def ten_testing_records(kind = 'testing')
      (1..10).to_a.map do |i|
        {:kind => kind, :name => i.to_s}
      end
    end

    it 'assigns unique keys to each record' do
      keys = ten_testing_records.map do |record|
        api.save(record)[:key]
      end
      unique_keys = Set.new(keys)
      unique_keys.length.should == 10
    end

    it 'can save many records' do
      saved_records = api.save_many(ten_testing_records)
      saved_records.length.should == 10
      saved_names = Set.new(saved_records.map { |record| record[:name] })
      found_records = api.find_by_kind('testing')
      found_records.length.should == 10
      found_names = Set.new(found_records.map { |record| record[:name] })
      found_names.should == saved_names
    end

  end

  def remove_nils(record)
    record.reduce({}) do |non_nil_record, (field, value)|
      non_nil_record[field] = value unless value.nil?
      non_nil_record
    end
  end

  context 'find by key' do
    it 'finds by key' do
      record = api.save({:kind => 'testing', :inti => 5})
      remove_nils(api.find_by_key(record[:key])).should == remove_nils(record)
    end
  end

  context 'find by kind' do

    it 'filters by the kind' do
      api.save({:kind => 'other_testing', :inti => 5})
      found_records = api.find_by_kind('testing')
      found_records.each do |record|
        record[:kind].should == 'testing'
      end
    end

    it "can't filter on old values" do
      record = api.save(:kind => 'testing', :inti => 12)
      api.save(record, :inti => 2)
      api.find_by_kind('testing', :filters => [[:inti, '=', 12]]).should == []
    end

    context 'filters' do
      before :each do
        api.save_many([
          {:kind => 'testing', :inti => 1,   :data => 'one'    },
          {:kind => 'testing', :inti => 12,  :data => 'twelve' },
          {:kind => 'testing', :inti => 23,  :data => 'twenty3'},
          {:kind => 'testing', :inti => 34,  :data => 'thirty4'},
          {:kind => 'testing', :inti => 45,  :data => 'forty5' },
          {:kind => 'testing', :inti => 1,   :data => 'the one'},
          {:kind => 'testing', :inti => 44,  :data => 'forty4' },
          {:kind => 'testing', :inti => nil, :data => 'forty4' }
        ])
      end

      [
        [[[:inti, '<', 25]], [1, 12, 23], :inti],
        [[[:inti, '<=', 25]], [1, 12, 23], :inti],
        [[[:inti, '>', 25]], [34, 44, 45], :inti],
        [[[:inti, '=', 34]], [34], :inti],
        [[[:inti, '=', nil]], [nil], :inti],
        [[[:inti, '!=', nil]], [1, 1, 12, 23, 34, 44, 45], :inti],
        [[[:inti, '!=', 34]], [1, 12, 23, 44, 45, nil], :inti],
        [[[:inti, 'in', [12, 34]]], [12, 34], :inti],
        [[[:inti, '>', 10], [:inti, '<', 25]], [12, 23], :inti],
        [[[:inti, '<', 25], [:inti, '>', 10]], [12, 23], :inti],
        [[[:inti, '>', 25], [:data, '<', 'thirty4']], [44, 45], :inti],
        [[[:data, '<', 'thirty4'], [:inti, '>', 25]], [44, 45], :inti],
        [[[:inti, '>', 10], [:inti, '<', 25], [:inti, '=', 23]], [23], :inti],
        [[[:inti, '=', 23], [:inti, '>', 10], [:inti, '<', 25]], [23], :inti],
        [[[:inti, '<', 24], [:inti, '>', 25]], [], :inti],
        [[[:inti, '!=', 12], [:inti, '!=', 23], [:inti, '!=', 34]], [1, 44, 45, nil], :inti],
        [[[:data, '<', 'qux']], ['one', 'forty4', 'forty5'], :data],
        [[[:data, '<=', 'one']], ['one', 'forty4', 'forty5'], :data],
        [[[:data, '>=', 'thirty4']], ['twelve', 'twenty3', 'thirty4'], :data],
        [[[:data, '=', 'one']], ['one'], :data],
        [[[:data, '!=', 'one']], ['the one', 'twelve', 'twenty3', 'thirty4', 'forty4', 'forty5'], :data],
        [[[:data, 'in', ['one', 'twelve']]], ['one', 'twelve'], :data],
        [[[:data, '>', 'qux'], [:data, '<', 'qux']], [], :data],
        [[[:data, 'like', /forty/]], ['forty4', 'forty5'], :data],
        [[[:data, 'like', /twe/]], ['twenty3', 'twelve'], :data],
        [[[:data, '!=', 'one'], [:data, '!=', 'twelve'], [:data, '!=', 'twenty3']], ['the one', 'thirty4', 'forty4', 'forty5'], :data],
      ].each do |filters, result, field|

          it filters.map(&:to_s).join(', ') do
            found_records = api.find_by_kind('testing', :filters => filters)
            ints = Set.new(found_records.map {|record| record[field]})
            ints.should == Set.new(result)
          end
        end

    end

    context 'sorts' do
      before :each do
        api.save_many([
          {:kind => 'testing', :inti => 1,   :data => 'one'    },
          {:kind => 'testing', :inti => 12,  :data => 'twelve' },
          {:kind => 'testing', :inti => 23,  :data => 'twenty3'},
          {:kind => 'testing', :inti => 34,  :data => 'thirty4'},
          {:kind => 'testing', :inti => 45,  :data => 'forty5' },
          {:kind => 'testing', :inti => 1,   :data => 'the one'},
          {:kind => 'testing', :inti => 44,  :data => 'forty4' },
        ])
      end

      [
        [[[:inti, :asc]], [1, 1, 12, 23, 34, 44, 45], :inti],
        [[[:inti, :desc]], [45, 44, 34, 23, 12, 1, 1], :inti],
        [[[:data, :asc]], [44, 45, 1, 1, 34, 12, 23], :inti],
        [[[:data, :desc]], [23, 12, 34, 1, 1, 45, 44], :inti],
        [[[:inti, :asc], [:data, :asc]], ['one', 'the one', 'twelve', 'twenty3', 'thirty4', 'forty4', 'forty5'], :data],
        [[[:data, :asc], [:inti, :asc]], [44, 45, 1, 1, 34, 12, 23], :inti]
      ].each do |sorts, result, field|

        it sorts.map(&:to_s).join(', ') do
          found_records = api.find_by_kind('testing', :sorts => sorts)
          ints = found_records.map {|record| record[field]}
          ints.should == result
        end
      end
    end

    context 'limit and offset' do
      before :each do
        api.save_many([
          {:kind => 'testing', :inti => 1,   :data => 'one'    },
          {:kind => 'testing', :inti => 12,  :data => 'twelve' },
          {:kind => 'testing', :inti => 23,  :data => 'twenty3'},
          {:kind => 'testing', :inti => 34,  :data => 'thirty4'},
          {:kind => 'testing', :inti => 45,  :data => 'forty5' },
          {:kind => 'testing', :inti => 1,   :data => 'the one'},
          {:kind => 'testing', :inti => 44,  :data => 'forty4' },
        ])
      end

      specify 'offset n returns results starting at the nth record' do
        found_records = api.find_by_kind('testing', :sorts => [[:inti, :asc]], :offset => 2)
        ints = found_records.map {|record| record[:inti]}
        ints.should == [12, 23, 34, 44, 45]
      end

      specify 'limit n takes only the first n records' do
        found_records = api.find_by_kind('testing', :sorts => [[:inti, :asc]], :limit => 2)
        found_records.map {|record| record[:inti]}.should == [1, 1]

        found_records = api.find_by_kind('testing', :sorts => [[:inti, :asc]], :limit => 1_000_000)
        found_records.map {|record| record[:inti]}.should == [1, 1, 12, 23, 34, 44, 45]
      end

      [
        [{:limit => 2, :offset => 2}, [[:inti, :asc]],  [12, 23]],
        [{:limit => 2, :offset => 4}, [[:inti, :asc]],  [34, 44]],
        [{:limit => 2}              , [[:inti, :desc]], [45, 44]],
        [{:limit => 2, :offset => 2}, [[:inti, :desc]], [34, 23]],
        [{:limit => 2, :offset => 4}, [[:inti, :desc]], [12,  1]],
      ].each do |constraints, sorts, result|
          example constraints.inspect do
            found_records = api.find_by_kind 'testing', constraints.merge(:sorts => sorts)
            found_records.map { |record| record[:inti] }.should == result
          end
        end
    end
  end

  context 'delete' do

    before :each do
      api.save_many([
        {:kind => 'testing', :inti => 1,   :data => 'one'    },
        {:kind => 'testing', :inti => 12,  :data => 'twelve' },
        {:kind => 'testing', :inti => nil, :data => 'twelve' }
      ])
    end

    it 'deletes by key' do
      records = api.find_by_kind('testing')
      record_to_delete = records.first
      api.delete_by_key(record_to_delete[:key]).should be_nil
      api.find_by_kind('testing').should_not include(record_to_delete)
    end

    context 'filters' do

      [
        [[], []],
        [[[:inti, '=', 1]], [12, nil]],
        [[[:data, '=', 'one']], [12, nil]],
        [[[:inti, '!=', 1]], [1]],
        [[[:inti, '<=', 1]], [12, nil]],
        [[[:inti, '<=', 2]], [12, nil]],
        [[[:inti, '>=', 2]], [1, nil]],
        [[[:inti, '>', 1]], [1, nil]],
        [[[:inti, 'in', [1]]], [12, nil]],
        [[[:inti, 'in', [1, nil]]], [12]],
        [[[:inti, 'in', [1, 12]]], [nil]],
        [[[:inti, '=', 2]], [1, 12, nil]],
        [[[:inti, '=', nil]], [1, 12]],
        [[[:inti, '!=', nil]], [nil]],
      ].each do |filters, result|
        it filters.inspect do
          api.delete_by_kind('testing', :filters => filters)
          intis = api.find_by_kind('testing').map {|r| r[:inti]}
          intis.should =~ result
        end
      end

    end
  end

  context 'count' do

    before :each do
      api.save_many([
        {:kind => 'testing', :inti => 1,   :data => 'one'    },
        {:kind => 'testing', :inti => 12,  :data => 'twelve' },
        {:kind => 'testing', :inti => nil, :data => 'twelve' }
      ])
    end

    context 'filters' do

      [
        [[], 3],
        [[[:inti, '=', 1]], 1],
        [[[:data, '=', 'one']], 1],
        [[[:inti, '!=', 1]], 2],
        [[[:inti, '<=', 1]], 1],
        [[[:inti, '<=', 2]], 1],
        [[[:inti, '>=', 2]], 1],
        [[[:inti, '>', 1]], 1],
        [[[:inti, 'in', [1]]], 1],
        [[[:inti, 'in', [1, 12]]], 2],
        [[[:inti, '=', 2]], 0],
        [[[:inti, '=', nil]], 1],
        [[[:data, '~=', /twe/]], 2],
        [[[:inti, '!=', nil]], 2],
      ].each do |filters, result|
        it filters.inspect do
          api.count_by_kind('testing', :filters => filters).should == result
        end
      end

    end
  end

  Hyperion.defentity(:shirt) do |kind|
    kind.field(:account_key, :type => Hyperion::Types.foreign_key(:account), :db_name => :account_id)
  end

  Hyperion.defentity(:account) do |kind|
    kind.field(:first_name)
  end

  context 'foreign_keys' do
    it 'saves records with foreign keys' do
      account = api.save(:kind => :account)
      account_key = account[:key]
      shirt  = api.save(:kind => :shirt, :account_key => account_key)
      found_shirt = api.find_by_key(shirt[:key])
      found_account = api.find_by_key(account_key)
      shirt[:account_key].should == account_key
      found_shirt[:account_key].should == account_key
      found_account[:key].should == account_key
    end

    it 'filters on foreign keys' do
      account = api.save(:kind => :account)
      account_key = account[:key]
      shirt  = api.save(:kind => :shirt, :account_key => account_key)
      found_shirts = api.find_by_kind(:shirt, :filters => [[:account_key, '=', account_key]])
      found_shirts[0].should == shirt
    end

    it 'unpacks nil foreign keys' do
      shirt  = api.save(:kind => :shirt, :account_key => nil)
      shirt[:account_key].should be_nil
      found_shirt = api.find_by_kind(:shirt, :filters => [[:account_key, '=', nil]]).first
      found_shirt[:account_key].should be_nil
    end

    it 'filters on nil foreign key' do
      account = api.save(:kind => :account)
      shirt  = api.save(:kind => :shirt, :account_key => account[:key])
      nil_shirt  = api.save(:kind => :shirt, :account_key => nil)
      api.find_by_kind(:shirt, :filters => [[:account_key, '=', nil]]).should == [nil_shirt]
    end
  end
end
