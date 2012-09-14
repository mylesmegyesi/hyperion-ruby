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
      Hyperion::API.datastore = Hyperion::Mysql.create_datastore
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

    context 'Sql Injection' do
      it 'escapes strings to be inserted' do
        evil_name = "my evil name' --"
        record = Hyperion::API.save(:kind => 'testing', :name => evil_name)
        found_record = Hyperion::API.find_by_key(record[:key])
        found_record[:name].should == evil_name
      end

      it 'escapes table names' do
        error_message = ""
        begin
          Hyperion::API.save(:kind => 'my evil name` --', :name => 'value')
        rescue Exception => e
          error_message = e.message
        end
        error_message.should include("Table 'hyperion_ruby.my_evil_name`___' doesn't exist")
      end

      it 'escapes column names' do
        error_message = ""
        begin
          Hyperion::API.save(:kind => 'testing', 'my evil name` --' => 'value')
        rescue Exception => e
          error_message = e.message
        end
        error_message.should include("Unknown column 'my_evil_name`___' in 'field list'")
      end
    end
  end

  it_behaves_like 'Sql Transactions'
end
