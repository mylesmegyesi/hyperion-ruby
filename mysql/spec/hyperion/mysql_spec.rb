require 'hyperion/dev/ds_spec'
require 'hyperion/sql'
require 'hyperion/sql/transaction_spec'
require 'hyperion/mysql'

describe Hyperion::Mysql do

  CONNECTION_URL = 'mysql://localhost/hyperion_ruby'

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

  def create_foreign_key_test_tables
    execute <<-QUERY
    CREATE TABLE account (
    id INTEGER NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(35),
    inti INTEGER,
    data VARCHAR(32),
    PRIMARY KEY (id)
    );
    QUERY
    execute <<-QUERY
    CREATE TABLE shirt (
    id INTEGER NOT NULL AUTO_INCREMENT,
    account_id INTEGER,
    first_name VARCHAR(35),
    inti INTEGER,
    data VARCHAR(32),
    PRIMARY KEY (id),
    INDEX (account_id),
    FOREIGN KEY (account_id) REFERENCES account (id)
    );
    QUERY
  end

  def drop_table(table_name)
    execute "DROP TABLE IF EXISTS #{table_name};"
  end

  def drop_foreign_key_test_tables
    drop_table(:shirt)
    drop_table(:account)
  end

  TABLES = ['testing', 'other_testing']

  around :each do |example|
    Hyperion.with_datastore(:mysql, :connection_url => CONNECTION_URL) do
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

  context 'Sql Injection' do
    it 'escapes strings to be inserted' do
      evil_name = "my evil name' --"
      record = Hyperion.save(:kind => 'testing', :name => evil_name)
      found_record = Hyperion.find_by_key(record[:key])
      found_record[:name].should == evil_name
    end

    it 'escapes table names' do
      error_message = ""
      begin
        Hyperion.save(:kind => 'my evil name` --', :name => 'value')
      rescue Exception => e
        error_message = e.message
      end
      error_message.should include("Table 'hyperion_ruby.my_evil_name`___' doesn't exist")
    end

    it 'escapes column names' do
      error_message = ""
      begin
        Hyperion.save(:kind => 'testing', 'my evil name` --' => 'value')
      rescue Exception => e
        error_message = e.message
      end
      error_message.should include("Unknown column 'my evil name` --' in 'field list'")
    end
  end
end
