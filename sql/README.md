Hyperion::Sql
=============

This gem encapsulates the common behavior of the SQL datastores:

  * Query building
  * Query executing via [DataObjects](https://github.com/datamapper/do)
  * Connections
  * Transactions

The cases where you will have to use the SQL package directly are detailed here.

## Instantiating a datastore

When a SQL datastore is instantiated the connection-url must passed in as a parameter. This is the connection url that the datastore will use when attemting to communicate with the database.

``` ruby
connection_url = 'postgres://cspvswmv:bwTTUFRBRgnb@ec2-23-23-234-187.compute-1.amazonaws.com:5432/d1uh0jkh0n8j3l'
Hyperion.new_datastore(:postgres, connection_url: connection_url)
```

The datastore, however, will not open any connections until you perform an action which requires it to communicate with the database (saving a value, loading a value, etc.).

## Connection Pooling

By default, all connections in Hyperion are pooled by connection url.

## Opening a connection manually

Sometimes it may be useful to open a connection manually, like at the start of a web request, or to start a transaction.

``` ruby
require 'hyperion/sql'

connection_url = 'postgres://cspvswmv:bwTTUFRBRgnb@ec2-23-23-234-187.compute-1.amazonaws.com:5432/d1uh0jkh0n8j3l'
Hyperion::Sql.with_connection(connection_url) do
  # code that needs a connection
end
```

Make sure that the connection url passed in here is the same connection url passed into the datastore upon instantiation.

## Transactions

Before you start a transaction, you must have an open connection. This means you will have to open a connection manually (see above).

``` ruby
require 'hyperion/sql'

Hyperion::Sql.transaction do
  # everything that happens here is in a transaction
end
```

If an exception is thrown in a transaction block, the transaction will be rolled back.

Hyperion also supports nested transactions.

``` ruby
begin
  Hyperion::Sql.transaction do
    Hyperion.save(kind: :person, name: 'Myles')
    Hyperion.count_by_kind(:person) #=> 1
    begin
      Hyperion::Sql.transaction do
        Hyperion.save(kind: :person, name: 'Myles')
        Hyperion.count_by_kind(:person) #=> 2
        raise
      end
    rescue
    end
    Hyperion.count_by_kind(:person) #=> 1
    raise
rescue
end
Hyperion.count_by_kind(:person) #=> 0
```

## Contributing

Clone the master branch, build, and run all the tests:

``` bash
git clone git@github.com:mylesmegyesi/hyperion-ruby.git
cd hyperion-ruby/sql
bundle install
bundle exec rspec
```

## Issues

Post issues on the hyperion-ruby github project:

* [https://github.com/mylesmegyesi/hyperion-ruby/issues](https://github.com/mylesmegyesi/hyperion-ruby/issues)


## License

Copyright (C) 2012 8th Light All Rights Reserved.

Distributed under the Eclipse Public License
