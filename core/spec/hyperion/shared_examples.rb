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

