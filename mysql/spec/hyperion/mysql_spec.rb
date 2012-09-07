require 'do_mysql'
require 'hyperion/mysql'
require 'hyperion/sql/connection'
require 'hyperion/dev/ds_spec'

def create_table_sql(table_name)
  <<-QUERY
    CREATE TABLE #{table_name} (
      id INTEGER NOT NULL AUTO_INCREMENT,
      name VARCHAR(35),
      inti INTEGER,
      data VARCHAR(32),
      PRIMARY KEY (id)
    );
  QUERY
end

def drop_table_sql(table_name)
  "DROP TABLE IF EXISTS #{table_name};"
end

describe Hyperion::Mysql do

  around :each do |example|
    connection = DataObjects::Connection.new('mysql://localhost:3306/hyperion_ruby?user=root')

    tables = ['testing', 'other_testing']

    tables.each do |table|
      connection.create_command(drop_table_sql(table)).execute_non_query
    end

    tables.each do |table|
      connection.create_command(create_table_sql(table)).execute_non_query
    end

    Hyperion::Sql::Connection.connection = connection
    Hyperion::Core.datastore = Hyperion::Mysql.create_datastore

    example.run

    tables.each do |table|
      connection.create_command(drop_table_sql(table)).execute_non_query
    end

    connection.close
  end

  it_behaves_like 'Datastore'
end
