require 'do_sqlite3'
require 'hyperion/sqlite'
require 'hyperion/sql'
require 'hyperion/dev/ds_spec'
require 'hyperion/sql/transaction_spec'

describe Hyperion::Sqlite do

  def execute(query)
    Hyperion::Sql.connection.create_command(query).execute_non_query
  end

  def create_table(table_name)
    execute <<-QUERY
    CREATE TABLE #{table_name} (
      id INTEGER PRIMARY KEY,
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
    Hyperion::Sql.with_connection('sqlite3::memory:') do |connection|
      Hyperion::API.datastore = Hyperion::Sqlite.create_datastore
      example.run
    end
  end

  context 'Datastore' do
    around :each do |example|
      Hyperion::Sql.rollback do
        tables = ['testing', 'other_testing']
        tables.each do |table|
          create_table(table)
        end
        example.run
      end
    end

    include_examples 'Datastore'
  end

  it_behaves_like 'Sql Transactions'
end
