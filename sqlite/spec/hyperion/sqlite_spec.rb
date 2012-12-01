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

  def create_foreign_key_test_tables
    execute <<-QUERY
    CREATE TABLE account (
    id INTEGER PRIMARY KEY,
    first_name VARCHAR(35),
    inti INTEGER,
    data VARCHAR(32)
    );
    QUERY
    execute <<-QUERY
    CREATE TABLE shirt (
    id INTEGER PRIMARY KEY,
    account_id INTEGER,
    first_name VARCHAR(35),
    inti INTEGER,
    data VARCHAR(32),
    FOREIGN KEY (account_id) REFERENCES account(id)
    );
    QUERY
  end

  def drop_foreign_key_test_tables
    drop_table(:shirt)
    drop_table(:account)
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
      create_foreign_key_test_tables
    end
  end

  after :each do |example|
    Hyperion::Sql.with_connection(CONNECTION_URL) do
      TABLES.each { |table| drop_table(table) }
      drop_foreign_key_test_tables
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
