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
      record = actor.call({:kind => kind})
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

shared_examples_for 'record packing' do |actor|
  include_examples 'record formatting', lambda { |record|
    actor.call(record)
  }

  Hyperion::API.defentity(:one_field) do |kind|
    kind.field(:field, :default => 'ABC')
  end

  it 'only packs fields defined in the entity' do
    result = actor.call(:kind => :one_field, :field => 'value', :foo => 'bar')
    result.should == {:kind => 'one_field', :field => 'value'}
  end

  it 'packs the key field if not defined' do
    result = actor.call(:kind => :one_field, :key => '1234', :field => 'value', :foo => 'bar')
    result.should == {:kind => 'one_field', :key => '1234', :field => 'value'}
  end

  Hyperion::API.defentity(:two_fields) do |kind|
    kind.field(:field1, :default => 'ABC')
    kind.field(:field2, :default => 'CBD')
  end

  it 'applies defaults' do
    actor.call(:kind => :two_fields).should == {:kind => 'two_fields', :field1 => 'ABC', :field2 => 'CBD'}
    actor.call(:kind => :two_fields, :field1 => 'john').should == {:kind => 'two_fields', :field1 => 'john', :field2 => 'CBD'}
  end

  context 'Timestamps' do

    Hyperion::API.defentity(:with_time) do |kind|
      kind.field(:created_at)
      kind.field(:updated_at)
    end

    Hyperion::API.defentity(:without_time) do |kind|
    end

    before :each do
      @now = mock(:now)
      Time.stub(:now).and_return(@now)
    end

    it 'auto populates created_at if it exists and if the record is new' do
      old_time = mock(:old_time)
      actor.call(:kind => :without_time).should == {:kind => 'without_time'}
      actor.call(:kind => :with_time, :key => '1234', :created_at => old_time)[:created_at].should == old_time
      actor.call(:kind => :with_time)[:created_at].should == @now
    end

    it 'auto populates updated_at if it exists and if the record is not new' do
      old_time = mock(:old_time)
      actor.call(:kind => :without_time).should == {:kind => 'without_time'}
      result = actor.call(:kind => :with_time, :key => '1234', :created_at => old_time, :updated_at => old_time)
      result[:created_at].should == old_time
      result[:updated_at].should == @now
    end
  end
end

shared_examples_for 'record unpacking' do |actor|
  include_examples 'record formatting', lambda { |record|
    actor.call(record)
  }

  it 'only unpacks defined fields' do
    result = actor.call(:kind => :one_field, :field => 'value', :foo => 'bar')
    result.should == {:kind=>"one_field", :field=>"value"}
  end

  it 'unpacks the key field if not defined' do
    result = actor.call(:kind => :one_field, :key => '1234', :field => 'value', :foo => 'bar')
    result.should == {:kind=>"one_field", :key => '1234', :field=>"value"}
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

