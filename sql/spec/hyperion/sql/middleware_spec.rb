require 'hyperion/sql/middleware'
require 'do_sqlite3'

describe Hyperion::Sql::Middleware do

  def middleware(app)
    midd = Hyperion::Sql::Middleware.new(app, {
      :connection_url => 'sqlite3::memory:',
      :ds => :memory,
      :ds_opts => {:someopts => 1}
    })
  end

  it 'passes the env' do
    mock_env = mock(:env)
    midd = middleware lambda { |env|
      env.should == mock_env
    }
    midd.call(mock_env)
  end

  it 'establishes a connection' do
    midd = middleware lambda { |env|
      expect {Hyperion::Sql.connection}.to_not raise_error
    }
    midd.call(nil)
    expect {Hyperion::Sql.connection}.to raise_error
  end

  it 'assigns the datastore' do
    midd = middleware lambda { |env|
      Hyperion::API.datastore.class.should == Hyperion::Memory
    }
    midd.call(nil)
    expect {Hyperion::API.datastore}.to raise_error
  end

  it 'starts a transaction' do
    midd = middleware lambda { |env|
      Thread.current[:transaction].should_not be_nil
    }
    midd.call(nil)
    Thread.current[:transaction].should be_nil
  end

  it 'returns the result' do
    midd = middleware lambda { |env|
      :return
    }
    midd.call(nil).should == :return
  end

end
