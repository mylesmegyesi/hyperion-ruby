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
  end
end
