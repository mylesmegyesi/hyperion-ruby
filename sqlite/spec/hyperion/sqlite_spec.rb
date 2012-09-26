require 'hyperion/dev/ds_spec'
require 'hyperion/sql'
require 'hyperion/sql/transaction_spec'
require 'hyperion/sqlite'

describe Hyperion::Sqlite do

  CONNECTION_URL = 'sqlite3::memory:'

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

  TABLES = ['testing', 'other_testing']

  around :each do |example|
    Hyperion.with_datastore(:sqlite, :connection_url => CONNECTION_URL) do
      example.run
    end
  end

  before :each do |example|
    Hyperion::Sql.with_connection(CONNECTION_URL) do
      TABLES.each { |table| create_table(table) }
    end
  end

  after :each do |example|
    Hyperion::Sql.with_connection(CONNECTION_URL) do
      TABLES.each { |table| drop_table(table) }
    end
  end

  include_examples 'Datastore'

  context 'Transactions' do
    around :each do |example|
      Hyperion::Sql.with_connection(CONNECTION_URL) do
        example.run
      end
    end

    include_examples 'Sql Transactions'
  end
end
