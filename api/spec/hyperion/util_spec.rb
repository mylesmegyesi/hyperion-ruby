require 'hyperion/util'

describe Hyperion::Util do

  def util
    Hyperion::Util
  end

  it 'camel cases words' do
    util.camel_case('fake_ds').should == 'fakeDs'
    util.camel_case('defaultSceneName').should == 'defaultSceneName'
    util.camel_case('set defaultSceneName').should == 'setDefaultSceneName'
    util.camel_case('class_name').should == 'className'
    util.camel_case('once_upon_a_time').should == 'onceUponATime'
    util.camel_case('with spaces').should == 'withSpaces'
    util.camel_case('with-dash').should == 'withDash'
    util.camel_case('starting Capital').should == 'startingCapital'
    util.camel_case('StartingCapital').should == 'startingCapital'
    util.camel_case('O').should == 'o'
    util.camel_case('').should == ''
    util.camel_case(nil).should == nil
  end

  it 'snake cases words' do
    util.snake_case('fake_ds').should == 'fake_ds'
    util.snake_case('defaultSceneName').should == 'default_scene_name'
    util.snake_case('set defaultSceneName').should == 'set_default_scene_name'
    util.snake_case('class_name').should == 'class_name'
    util.snake_case('once_upon_a_time').should == 'once_upon_a_time'
    util.snake_case('with spaces').should == 'with_spaces'
    util.snake_case('with-dash').should == 'with_dash'
    util.snake_case('starting Capital').should == 'starting_capital'
    util.snake_case('StartingCapital').should == 'starting_capital'
    util.snake_case('O').should == 'o'
    util.snake_case('').should == ''
    util.snake_case(nil).should == nil
  end

  it 'converts to class name' do
    util.class_name('fake_ds').should == 'FakeDs'
    util.class_name('defaultSceneName').should == 'DefaultSceneName'
    util.class_name('set defaultSceneName').should == 'SetDefaultSceneName'
    util.class_name('class_name').should == 'ClassName'
    util.class_name('once_upon_a_time').should == 'OnceUponATime'
    util.class_name('with spaces').should == 'WithSpaces'
    util.class_name('with-dash').should == 'WithDash'
    util.class_name('starting Capital').should == 'StartingCapital'
    util.class_name('StartingCapital').should == 'StartingCapital'
    util.class_name('S').should == 'S'
    util.class_name('s').should == 'S'
    util.class_name('').should == ''
    util.class_name(nil).should == nil
  end

  context 'binding' do
    it 'assigns the thread local var within the block' do
      called = false
      util.bind(:thing, 1) do
        called = true
        Thread.current[:thing].should == 1
      end
      called.should be_true
    end

    it 'reassigns the previous value' do
      Thread.current[:thing].should == nil
      util.bind(:thing, 1) do
        util.bind(:thing, 2) do
          Thread.current[:thing].should == 2
        end
        Thread.current[:thing].should == 1
      end
      Thread.current[:thing].should == nil
    end

    it 'reassigns when an exception is thrown' do
      Thread.current[:thing].should == nil
      util.bind(:thing, 1) do
        expect {
          util.bind(:thing, 2) do
            raise 'my exception'
          end
        }.to raise_error('my exception')
        Thread.current[:thing].should == 1
      end
      Thread.current[:thing].should == nil
    end

    it 'return the result of the block' do
      util.bind(:thing, 1) do
        :return
      end.should == :return
    end
  end
end
