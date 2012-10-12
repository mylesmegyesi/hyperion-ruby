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
      record2 = api.save(record1.merge(:name => 'james'))
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
    before :each do
      api.save_many([
        {:kind => 'testing', :inti => 1,  :data => 'one'    },
        {:kind => 'testing', :inti => 12, :data => 'twelve' },
        {:kind => 'testing', :inti => 23, :data => 'twenty3'},
        {:kind => 'testing', :inti => 34, :data => 'thirty4'},
        {:kind => 'testing', :inti => 45, :data => 'forty5' },
        {:kind => 'testing', :inti => 1,  :data => 'the one'},
        {:kind => 'testing', :inti => 44, :data => 'forty4' }
      ])
    end

    it 'filters by the kind' do
      api.save({:kind => 'other_testing', :inti => 5})
      found_records = api.find_by_kind('testing')
      found_records.each do |record|
        record[:kind].should == 'testing'
      end
    end

    it "can't filter on old values" do
      record = api.find_by_kind('testing', :filters => [[:inti, '=', 12]]).first
      api.save(record, :inti => 2)
      api.find_by_kind('testing', :filters => [[:inti, '=', 12]]).should == []
    end

    context 'filters' do

      [
        [[[:inti, '<', 25]], [1, 12, 23], :inti],
        [[[:inti, '<=', 25]], [1, 12, 23], :inti],
        [[[:inti, '>', 25]], [34, 44, 45], :inti],
        [[[:inti, '=', 34]], [34], :inti],
        [[[:inti, '!=', 34]], [1, 12, 23, 44, 45], :inti],
        [[[:inti, 'in', [12, 34]]], [12, 34], :inti],
        [[[:inti, '<', 24], [:inti, '>', 25]], [], :inti],
        [[[:inti, '!=', 12], [:inti, '!=', 23], [:inti, '!=', 34]], [1, 44, 45], :inti],
        [[[:data, '<', 'qux']], ['one', 'forty4', 'forty5'], :data],
        [[[:data, '<=', 'one']], ['one', 'forty4', 'forty5'], :data],
        [[[:data, '>=', 'thirty4']], ['twelve', 'twenty3', 'thirty4'], :data],
        [[[:data, '=', 'one']], ['one'], :data],
        [[[:data, '!=', 'one']], ['the one', 'twelve', 'twenty3', 'thirty4', 'forty4', 'forty5'], :data],
        [[[:data, 'in', ['one', 'twelve']]], ['one', 'twelve'], :data],
        [[[:data, '>', 'qux'], [:data, '<', 'qux']], [], :data],
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
        {:kind => 'testing', :inti => 1,  :data => 'one'    },
        {:kind => 'testing', :inti => 12, :data => 'twelve' }
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
        [[[:inti, '=', 1]], [12]],
        [[[:data, '=', 'one']], [12]],
        [[[:inti, '!=', 1]], [1]],
        [[[:inti, '<=', 1]], [12]],
        [[[:inti, '<=', 2]], [12]],
        [[[:inti, '>=', 2]], [1]],
        [[[:inti, '>', 1]], [1]],
        [[[:inti, 'in', [1]]], [12]],
        [[[:inti, 'in', [1, 12]]], []],
        [[[:inti, '=', 2]], [1, 12]]
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
        {:kind => 'testing', :inti => 1,  :data => 'one'    },
        {:kind => 'testing', :inti => 12, :data => 'twelve' }
      ])
    end

    context 'filters' do

      [
        [[], 2],
        [[[:inti, '=', 1]], 1],
        [[[:data, '=', 'one']], 1],
        [[[:inti, '!=', 1]], 1],
        [[[:inti, '<=', 1]], 1],
        [[[:inti, '<=', 2]], 1],
        [[[:inti, '>=', 2]], 1],
        [[[:inti, '>', 1]], 1],
        [[[:inti, 'in', [1]]], 1],
        [[[:inti, 'in', [1, 12]]], 2],
        [[[:inti, '=', 2]], 0]
      ].each do |filters, result|
        it filters.inspect do
          api.count_by_kind('testing', :filters => filters).should == result
        end
      end

    end
  end
end
