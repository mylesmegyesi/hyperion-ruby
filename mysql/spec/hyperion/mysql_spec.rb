require 'do_mysql'
require 'hyperion/mysql'
require 'hyperion/sql'
require 'hyperion/dev/ds_spec'
require 'hyperion/sql/transaction_spec'

describe Hyperion::Mysql do

  def execute(query)
    Hyperion::Sql.connection.create_command(query).execute_non_query
  end

  def create_table(table_name)
    execute <<-QUERY
    CREATE TABLE #{table_name} (
      id INTEGER NOT NULL AUTO_INCREMENT,
      name VARCHAR(35),
      inti INTEGER,
      data VARCHAR(32),
      PRIMARY KEY (id)
    );
    QUERY
  end

  def drop_table(table_name)
    execute "DROP TABLE IF EXISTS #{table_name};"
  end

  around :each do |example|
    Hyperion::Sql.with_connection('mysql://localhost/hyperion_ruby') do |connection|
      Hyperion::Core.datastore = Hyperion::Mysql.create_datastore
      example.run
    end
  end

  context 'Datastore' do
    around :each do |example|
      tables = ['testing', 'other_testing']
      begin
        tables.each { |table| create_table(table) }
        example.run
      ensure
        tables.each { |table| drop_table(table) }
      end
    end

    include_examples 'Datastore'
  end

  it_behaves_like 'Sql Transactions'
end
