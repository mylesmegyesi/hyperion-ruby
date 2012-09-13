shared_examples_for 'Sql Transactions' do
  def write(query)
    command = Hyperion::Sql.connection.create_command(query)
    command.execute_non_query
  end

  def create_table(table_name)
    write("CREATE TABLE #{table_name} (name VARCHAR(20), age INTEGER)")
  end

  def drop_table(table_name)
    write("DROP TABLE IF EXISTS #{table_name}")
  end

  around :each do |example|
    begin
      create_table('test')
      example.run
    ensure
      drop_table('test')
    end
  end

  def test_count
    Hyperion::API.count_by_kind('test')
  end

  context 'rollback' do

    it 'rolls back all changes' do
      Hyperion::Sql.rollback do
        write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
        test_count.should == 1
      end
      test_count.should == 0
    end

    it 'rolls back multiple' do
      Hyperion::Sql.rollback do
        write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
        Hyperion::Sql.rollback do
          write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
          test_count.should == 2
        end
          test_count.should == 1
      end
      test_count.should == 0
    end

    it 'returns the result of the body' do
      Hyperion::Sql.rollback do
        :result
      end.should == :result
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

    it 'commits one and then rolls back the next' do
      Hyperion::Sql.transaction do
        write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
      end
      expect {
        Hyperion::Sql.transaction do
          write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
          raise
        end
      }.to raise_error
      test_count.should == 1
    end

    it 'rolls back when an exception is thrown' do
      expect {
        Hyperion::Sql.transaction do
          write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
          test_count.should == 1
          raise
        end
      }.to raise_error
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
      expect {
        Hyperion::Sql.transaction do
          write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
          Hyperion::Sql.transaction do
            write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
          end
          test_count.should == 2
          raise
        end
      }.to raise_error
      test_count.should == 0
    end

    it 'returns the result of the transaction' do
      Hyperion::Sql.transaction do
        :result
      end.should == :result
    end

  end

  it 'can handle outer rollback and inner transaction' do
    Hyperion::Sql.rollback do
      Hyperion::Sql.transaction do
        write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
      end
      test_count.should == 1
    end
    test_count.should == 0
  end

  it 'can handle outer transaction and inner rollback' do
    Hyperion::Sql.transaction do
      write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
      test_count.should == 1
      Hyperion::Sql.rollback do
        write("INSERT INTO test (name, age) VALUES ('Myles', 23)")
        test_count.should == 2
      end
      test_count.should == 1
    end
    test_count.should == 1
  end
end
