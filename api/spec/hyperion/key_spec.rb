require 'hyperion/key'

describe Hyperion::Key do

  def encode_key(value)
    Hyperion::Key.encode_key(value)
  end

  def decode_key(value)
    Hyperion::Key.decode_key(value)
  end

  specify 'encoding' do
    encode_key('a').should == 'YQ'
    encode_key('ab').should == 'YWI'
    encode_key('abc').should == 'YWJj'
    encode_key('abcd').should == 'YWJjZA'
    encode_key('abcde').should == 'YWJjZGU'
    encode_key('abcdef').should == 'YWJjZGVm'
  end

  specify 'decoding' do
    decode_key('YQ').should == 'a'
    decode_key('YWI').should == 'ab'
    decode_key('YWJj').should == 'abc'
    decode_key('YWJjZA').should == 'abcd'
    decode_key('YWJjZGU').should == 'abcde'
    decode_key('YWJjZGVm').should == 'abcdef'
  end

  it 'composes unique keys' do
    keys = (0...100).map {Hyperion::Key.compose_key('foo')}
    Set.new(keys).length.should == 100
    keys = (0...100).map {Hyperion::Key.compose_key(:foo)}
    Set.new(keys).length.should == 100
    Hyperion::Key.compose_key(:foo, 1).should == Hyperion::Key.compose_key(:foo, 1)
  end

  it 'composes and decomposes a large id' do
    kind = 'testing'
    id = 'BLODQF0Z1DMEfQr7S3eBwfsX4ku'
    key = Hyperion::Key.compose_key(kind, id)
    Hyperion::Key.decompose_key(key).should == [kind, id]
  end

  it 'decomposes keys' do
    key = Hyperion::Key.compose_key(:thing, 1)
    Hyperion::Key.decompose_key(key).should == ['thing', '1']
  end

  it 'decomposes keys with a :' do
    key = Hyperion::Key.compose_key(:thing, 'my:key')
    Hyperion::Key.decompose_key(key).should == ['thing', 'my:key']
  end

  it 'decomposes kinds with a :' do
    key = Hyperion::Key.compose_key("thing:one", 'key')
    Hyperion::Key.decompose_key(key).should == ['thing:one', 'key']
  end

end
