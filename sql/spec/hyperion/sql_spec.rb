require 'do_sqlite3'
require 'hyperion/sql'

def write(query)
  command = Hyperion::Sql.connection.create_command(query)
  command.execute_non_query
end

def create_table(connection, table_name)
  write("CREATE TABLE #{table_name} (name VARCHAR(20), age INTEGER)")
end

def drop_table(connection, table_name)
  write("DROP TABLE IF EXISTS #{table_name}")
end

describe Hyperion::Sql do
  around :each do |example|
    Hyperion::Sql.with_connection('sqlite3::memory:') do |connection|
      begin
        create_table(connection, 'test')
        example.run
      ensure
        drop_table(connection, 'test')
      end
    end
  end

  def test_count
    query = "SELECT COUNT(*) FROM test"
    command = Hyperion::Sql.connection.create_command(query)
    result = command.execute_reader.to_a
    result[0]['COUNT(*)']
  end

  context 'rollback' do

    it 'rolls back all changes' do
      Hyperion::Sql.rollback do
        write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
        test_count.should == 1
      end
      test_count.should == 0
    end

  end

  context 'transaction' do

    it 'commits' do
      Hyperion::Sql.transaction do
        write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
        test_count.should == 1
      end
      test_count.should == 1
    end

    it 'commits multiple' do
      Hyperion::Sql.transaction do
        write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
      end
      Hyperion::Sql.transaction do
        write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
      end
      test_count.should == 2
    end

    it 'commits one and then rollsback the next' do
      Hyperion::Sql.transaction do
        write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
      end
      Hyperion::Sql.transaction do
        write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
        raise
      end
      test_count.should == 1
    end

    it 'rollsback when an exception is thrown' do
      Hyperion::Sql.transaction do
        write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
        test_count.should == 1
        raise
      end
      test_count.should == 0
    end

    it 'commits nested transactions' do
      Hyperion::Sql.transaction do
        write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
        Hyperion::Sql.transaction do
          write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
        end
      end
      test_count.should == 2
    end

    it 'rolls back nested transactions' do
      Hyperion::Sql.transaction do
        write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
        Hyperion::Sql.transaction do
          write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
        end
        test_count.should == 2
        raise
      end
      test_count.should == 0
    end

  end
end
