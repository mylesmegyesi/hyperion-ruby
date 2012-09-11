require 'do_sqlite3'
require 'hyperion/sqlite'
require 'hyperion/sql/connection'
require 'hyperion/dev/ds_spec'

def create_table_sql(table_name)
  <<-QUERY
    CREATE TABLE #{table_name} (
      id INTEGER PRIMARY KEY,
      name VARCHAR(35),
      inti INTEGER,
      data VARCHAR(32)
    );
  QUERY
end

def drop_table_sql(table_name)
  "DROP TABLE IF EXISTS #{table_name};"
end

describe Hyperion::Sqlite do

  around :each do |example|
    connection = DataObjects::Connection.new('sqlite3::memory:')

    tables = ['testing', 'other_testing']

    tables.each do |table|
      connection.create_command(drop_table_sql(table)).execute_non_query
    end

    tables.each do |table|
      connection.create_command(create_table_sql(table)).execute_non_query
    end

    Hyperion::Sql::Connection.connection = connection
    Hyperion::Core.datastore = Hyperion::Sqlite.create_datastore

    example.run

    tables.each do |table|
      connection.create_command(drop_table_sql(table)).execute_non_query
    end

    connection.close
  end

  it_behaves_like 'Datastore'
end
