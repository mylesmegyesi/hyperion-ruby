require 'do_postgres'
require 'hyperion/postgres'
require 'hyperion/sql'
require 'hyperion/dev/ds_spec'

def execute(connection, query)
  connection.create_command(query).execute_non_query
end

def create_table(connection, table_name)
  execute connection, <<-QUERY
    CREATE TABLE #{table_name} (
      id SERIAL PRIMARY KEY,
      name VARCHAR(35),
      inti INTEGER,
      data VARCHAR(32)
    );
  QUERY
end

def drop_table_sql(table_name)
  execute connection, "DROP TABLE IF EXISTS #{table_name};"
end

describe Hyperion::Postgres do

  around :each do |example|
    Hyperion::Sql.with_connection('postgres://localhost/hyperion_ruby') do |connection|
      tables = ['testing', 'other_testing']
      begin
        tables.each do |table|
          create_table(table)
        end
        Hyperion::Core.datastore = Hyperion::Postgres.create_datastore
        example.run
      ensure
        tables.each do |table|
          drop_table(table)
        end
      end
    end
  end

  it_behaves_like 'Datastore'
end
