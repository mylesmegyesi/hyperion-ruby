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

  Hyperion.defentity(:one_field) do |kind|
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

  Hyperion.defentity(:two_fields) do |kind|
    kind.field(:field1, :default => 'ABC')
    kind.field(:field2, :default => 'CBD')
  end

  it 'applies defaults' do
    actor.call(:kind => :two_fields).should == {:kind => 'two_fields', :field1 => 'ABC', :field2 => 'CBD'}
    actor.call(:kind => :two_fields, :field1 => 'john').should == {:kind => 'two_fields', :field1 => 'john', :field2 => 'CBD'}
  end

  Hyperion.pack(Integer) do |value|
    value ? value.to_i : value
  end

  Hyperion.pack(:up) do |value|
    value ? value.upcase : value
  end

  Hyperion.pack(:down) do |value|
    value ? value.downcase : value
  end

  Hyperion.defentity('nestedType') do |kind|
    kind.field(:thingy, :type => Integer, :default => '2')
    kind.field(:upped, :type => :up, :default => 'asdf')
  end

  Hyperion.defentity(:packable) do |kind|
    kind.field(:widget,     :type   => Integer)
    kind.field(:downed,     :type   => :down)
    kind.field(:thing,      :type   => :nested_type)
    kind.field(:bauble,     :packer => lambda {|value| value ? value.reverse : value})
    kind.field(:bad_packer, :packer => true)
    kind.field(:two_packer, :type   => Integer, :packer => lambda {|value| value ? value.reverse : value})
  end

  it 'packs the given type' do
    result = actor.call(:kind => :packable, :downed => 'ABC', :widget => '1')
    result[:downed].should == 'abc'
    result[:widget].should == 1
  end

  it 'packs nested types' do
    result = actor.call(:kind => :packable, :downed => 'ABC', :widget => '1')
    result[:thing].should == {:kind => 'nested_type', :thingy => 2, :upped => 'ASDF'}
  end

  it 'packs nested types and merges existing data' do
    result = actor.call(:kind => :packable, :downed => 'ABC', :widget => '1', :thing => {:upped => 'FDAS'})
    result[:thing].should == {:kind => 'nested_type', :thingy => 2, :upped => 'FDAS'}
  end

  it 'packs with custom callables' do
    result = actor.call(:kind => :packable, :bauble => 'cba')
    result[:bauble].should == 'abc'
  end

  it 'custom callable must respond to `call`' do
    result = actor.call(:kind => :packable, :bad_packer => 'thing')
    result[:bad_packer].should == 'thing'
  end

  it 'prefers the custom packer over the type packer' do
    result = actor.call(:kind => :packable, :two_packer => 'thing')
    result[:two_packer].should == 'gniht'

  Hyperion.defentity(:keyed) do |kind|
    kind.field(:widget,     :type   => Integer)
    kind.field(:downed,     :type   => :down)
    kind.field(:thing,      :type   => :nested_type)
    kind.field(:bauble,     :packer => lambda {|value| value ? value.reverse : value})
    kind.field(:bad_packer, :packer => true)
    kind.field(:two_packer, :type   => Integer, :packer => lambda {|value| value ? value.reverse : value})
  end
 end

  context 'Timestamps' do

    Hyperion.defentity(:with_time) do |kind|
      kind.field(:created_at)
      kind.field(:updated_at)
    end

    Hyperion.defentity(:without_time) do |kind|
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

  Hyperion.unpack(Integer) do |value|
    value ? value.to_i : value
  end

  Hyperion.unpack(:up) do |value|
    value ? value.upcase : value
  end

  Hyperion.unpack(:down) do |value|
    value ? value.downcase : value
  end

  Hyperion.defentity('nested') do |kind|
    kind.field(:thingy, :type => Integer, :default => '2')
    kind.field(:upped, :type => :up, :default => 'asdf')
  end

  Hyperion.defentity(:unpackable) do |kind|
    kind.field(:widget,     :type   => Integer)
    kind.field(:downed,     :type   => :down)
    kind.field(:thing,      :type   => :nested_type)
    kind.field(:bauble,     :unpacker => lambda {|value| value ? value.reverse : value})
    kind.field(:bad_packer, :unpacker => true)
    kind.field(:two_packer, :type   => Integer, :unpacker => lambda {|value| value ? value.reverse : value})
  end

  it 'unpacks the given type' do
    result = actor.call(:kind => :unpackable, :downed => 'ABC', :widget => '1')
    result[:downed].should == 'abc'
    result[:widget].should == 1
  end

  it 'unpacks nested types' do
    result = actor.call(:kind => :unpackable, :downed => 'ABC', :widget => '1')
    result[:thing].should == {:kind => 'nested_type', :thingy => nil, :upped => nil}
  end

  it 'unpacks nested types and merges existing data' do
    result = actor.call(:kind => :unpackable, :downed => 'ABC', :widget => '1', :thing => {:upped => 'FDAS'})
    result[:thing].should == {:kind => 'nested_type', :thingy => nil, :upped => 'FDAS'}
  end

  it 'unpacks with custom callables' do
    result = actor.call(:kind => :unpackable, :bauble => 'cba')
    result[:bauble].should == 'abc'
  end

  it 'custom callable must respond to `call`' do
    result = actor.call(:kind => :unpackable, :bad_packer => 'thing')
    result[:bad_packer].should == 'thing'
  end

  it 'prefers the custom packer over the type packer' do
    result = actor.call(:kind => :unpackable, :two_packer => 'thing')
    result[:two_packer].should == 'gniht'
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

  it 'packs filter values' do
    actor.call([:test, '=', 0]).value.should == 'i was packed'
  end
end

