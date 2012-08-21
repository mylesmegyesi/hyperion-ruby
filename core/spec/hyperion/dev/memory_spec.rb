require 'hyperion/dev/memory'

describe Hyperion::Dev::Memory do

  before :each do
    Hyperion::Core.datastore = Hyperion::Dev::Memory.new
  end

  def ds
    Hyperion::Core
  end

  it 'saves a hash with kind as a string and returns it' do
    record = ds.save({kind: "testing", name: "ann"})
    record[:kind].should == "testing"
    record[:name].should == "ann"
  end

  it 'saves a hash with kind as a symbol and returns it' do
    record = ds.save({kind: :testing, name: "ann"})
    record[:kind].should == 'testing'
    record[:name].should == 'ann'
  end

  it 'assigns a key to new records' do
    record = ds.save({kind: 'testing', name: 'ann'})
    record[:key].should_not be_nil
  end

  it 'it saves an existing record' do
    record1 = ds.save({kind: 'other_testing', name: 'ann'})
    record2 = ds.save(record1.merge(name: 'james'))
    record1[:key].should == record2[:key]
    ds.find_by_kind('other_testing').length.should == 1
  end

  def ten_testing_records(kind = 'testing')
    (1..10).to_a.map do |i|
      {kind: kind, name: i.to_s}
    end
  end

  it 'assigned keys are unique' do
    keys = ten_testing_records.map do |record|
      ds.save(record)[:key]
    end
    unique_keys = Set.new(keys)
    unique_keys.length.should == 10
  end

  it 'can save many records with kind as string' do
    records = ds.save_many(ten_testing_records)
    records.length.should == 10
    found_records = ds.find_by_kind('testing')
    found_records.length.should == 10
    names = found_records.map { |record| record[:name] }
    names.should == (1..10).to_a.map { |i| i.to_s }
  end

  it 'can save many records with kind as symbol' do
    records = ds.save_many(ten_testing_records(:testing))
    records.length.should == 10
    found_records = ds.find_by_kind('testing')
    found_records.length.should == 10
    names = found_records.map { |record| record[:name] }
    names.should == (1..10).to_a.map { |i| i.to_s }
  end
end
