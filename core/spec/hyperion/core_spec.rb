require 'hyperion/core'

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

  shared_examples_for 'record formatting' do |actor|

    it 'converts the kind to a string when it is a symbol' do
      record = actor.call({kind: :one})
      record[:kind].should == 'one'
    end

    it 'keeps the kind as a string' do
      record = actor.call({kind: 'one'})
      record[:kind].should == 'one'
    end

    it 'converts attributes to symbols' do
      record = actor.call({'kind' => 'one', 'attr' => 'value'})
      record.should == {kind: 'one', attr: 'value'}
    end

    it 'converts the attributes to snake case' do
      record = actor.call({'Kind' => 'one', 's_a' => 'value', 'SomeAttr' => 'val', 'SomeBigAttr' => 'val', 'one-two-three' => 'val', 'one three two' => 'val'})
      record.should == {kind: 'one', s_a: 'value', some_attr: 'val', some_big_attr: 'val', one_two_three: 'val', one_three_two: 'val'}
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
        it_behaves_like 'record formatting', lambda { |record|
          Hyperion::Core.save(record)
          Hyperion::Core.datastore.saved_records.first
        }
      end

      context 'record formatting on return from datastore' do
        it_behaves_like 'record formatting', lambda {|record|
          Hyperion::Core.datastore.returns = [[record]]
          Hyperion::Core.save({})
        }
      end
    end

    context 'save many' do

      context 'record formatting on save' do
        it_behaves_like 'record formatting', lambda { |record|
          Hyperion::Core.save_many([record])
          Hyperion::Core.datastore.saved_records.first
        }
      end

      context 'record formatting on return from datastore' do
        it_behaves_like 'record formatting', lambda { |record|
          Hyperion::Core.datastore.returns = [[record]]
          Hyperion::Core.save_many([{}]).first
        }
      end
    end

    context 'find by kind' do
      it 'creates a query and passes the kind as string' do
        core.find_by_kind('one')
        query = fake_ds.queries.first
        query.kind.should == 'one'
      end

      it 'creates a query and passes the kind as symbol' do
        core.find_by_kind(:one)
        query = fake_ds.queries.first
        query.kind.should == 'one'
      end

      it 'creates a query and passes the kind as symbol' do
        core.find_by_kind(:one)
        query = fake_ds.queries.first
        query.kind.should == 'one'
      end

      it 'formats kind as snake case' do
        core.find_by_kind(:TheKind)
        query = fake_ds.queries.first
        query.kind.should == 'the_kind'
      end

      context 'parses filters' do

        def do_find(filter)
          core.find_by_kind('TheKind', filters: [filter])
          query = fake_ds.queries.first
          query.filters.first
        end

        context 'field' do

          {
            'field' => :field,
            'Field' => :field,
            'FieldOne' => :field_one,
            'SomeBigAttr' => :some_big_attr,
            :SomeBigAttr => :some_big_attr,
            'one-two-three' => :one_two_three,
            'one two three' => :one_two_three
          }.each_pair do |field, result|

            it "parses #{field} into #{result}" do
              do_find([field, '=', 0]).field.should == result
            end

          end
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

              it "parses the #{filter} to #{result}" do
                do_find([:attr, filter, 0]).operator.should == result
              end

            end
        end

        context 'value' do

          it 'passes the value to the filter' do
            do_find([:attr, '=', 0]).value.should == 0
          end

        end
      end
    end
  end
end
