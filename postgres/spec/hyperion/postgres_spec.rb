require 'do_postgres'
require 'hyperion/postgres'
require 'hyperion/sql'
require 'hyperion/dev/ds_spec'
require 'hyperion/sql/transaction_spec'

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
    Hyperion::Sql.with_connection('postgres://localhost/hyperion_ruby') do |connection|
      Hyperion::Core.datastore = Hyperion::Postgres.create_datastore
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
  end

  it_behaves_like 'Sql Transactions'
end
