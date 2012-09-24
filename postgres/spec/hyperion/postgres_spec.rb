require 'hyperion/dev/ds_spec'
require 'hyperion/sql'
require 'hyperion/sql/transaction_spec'
require 'hyperion/postgres'

describe Hyperion::Postgres do

  def execute(query)
    Hyperion::Sql.connection.create_command(query).execute_non_query
  end

  def create_table(table_name)
    execute <<-QUERY
    CREATE TABLE #{table_name} (
      id SERIAL PRIMARY KEY,
      name VARCHAR(35),
      inti INTEGER,
      data VARCHAR(32)
    );
    QUERY
  end

  def drop_table(table_name)
    execute "DROP TABLE IF EXISTS #{table_name};"
  end

  around :each do |example|
    Hyperion::Sql.with_connection_and_ds('postgres://localhost/hyperion_ruby', :postgres) do
      example.run
    end
  end

  context 'Datastore' do
    around :each do |example|
      Hyperion::Sql.rollback do
        tables = ['testing', 'other_testing']
        tables.each { |table| create_table(table) }
        example.run
      end
    end

    include_examples 'Datastore'

    context 'Sql Injection' do
      it 'escapes strings to be inserted' do
        evil_name = "my evil name' --"
        record = Hyperion.save(:kind => 'testing', :name => evil_name)
        found_record = Hyperion.find_by_key(record[:key])
        found_record[:name].should == evil_name
      end

      it 'escapes table names' do
        evil_name = 'my evil name" --'
        error_message = ""
        begin
          Hyperion.save(:kind => 'my evil name" --', :name => evil_name)
        rescue Exception => e
          error_message = e.message
        end
        error_message.should include('relation "my_evil_name"___" does not exist')
      end

      it 'escapes column names' do
        evil_name = 'my evil name" --'
        error_message = ""
        begin
          Hyperion.save(:kind => 'testing', evil_name => 'value')
        rescue Exception => e
          error_message = e.message
        end
        error_message.should include('column "my_evil_name"___" of relation "testing" does not exist')
      end
    end
  end

  it_behaves_like 'Sql Transactions'
end
