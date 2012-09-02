require 'do_postgres'
require 'hyperion/postgres'
require 'hyperion/dev/ds_spec'

describe Hyperion::Postgres do

  around :each do |example|
    connection = DataObjects::Connection.new('postgres://localhost/hyperion-ruby')

    create_tables_command = connection.create_command <<-QUERY
    CREATE TABLE testing (
      id SERIAL PRIMARY KEY,
      name VARCHAR(35),
      inti INTEGER,
      data VARCHAR(32)
    );
    CREATE TABLE other_testing (
      id SERIAL PRIMARY KEY,
      name VARCHAR(35),
      inti INTEGER,
      data VARCHAR(32)
    )
    QUERY
    create_tables_command.execute_non_query

    Hyperion::Postgres.connection = connection
    Hyperion::Core.datastore = Hyperion::Postgres.new

    example.run

    drop_tables_command = connection.create_command <<-DROP
    DROP TABLE testing;
    DROP TABLE other_testing
    DROP
    drop_tables_command.execute_non_query

    connection.close
  end

  it_behaves_like 'Datastore'
end
