require 'do_sqlite3'
require 'hyperion/sql'

describe Hyperion::Sql do

  def sql
    Hyperion::Sql
  end

  context 'with_connection' do
    it 'assigns the connection' do
      sql.with_connection('sqlite3::memory:') do
        Thread.current[:connection].should be_a(DataObjects::Connection)
      end
    end

    it 'returns the block result' do
      sql.with_connection('sqlite3::memory:') do
        :return
      end.should == :return
    end

    it 'closes the connection' do
      sql.with_connection('sqlite3::memory:') do
        Thread.current[:connection].should_receive(:close)
      end
    end

    it 'closes the connection when an exception is raised' do
      expect {
        sql.with_connection('sqlite3::memory:') do
          Thread.current[:connection].should_receive(:close)
          raise
        end
      }.to raise_error
    end
  end
end
