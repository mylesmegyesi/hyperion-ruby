Hyperion::Redis
=============

A Hyperion datastore for the [Redis](http://redis.io/) database.

## Installation

```ruby
gem 'hyperion-redis'
```

## Usage

### Instantiating a datastore

```ruby
require 'hyperion'
Hyperion.new_datastore(:redis, options)
```

#### Initialization Options

`:host` The host on which the Redis server is located. Default is `localhost`.

`:port` The port on which the Redis server is located. Default is `6379`.

`:timeout` The amount of time (in seconds) before timing out on a single request: default is `5`.

`:password` The password to use on the Redis server: default is `nil`.

`:db` A specific Database to use on the Redis server: default is `0`.

### Note

Currently, all filtering, sorts, offsets, and limits happen within ruby and can become slow as a `kind` adds more and more records. Saving, lookup by id, and deletion by id are all still completed within Redis.

## Contributing

Clone the master branch, build, and run all the tests:

``` bash
git clone git@github.com:mylesmegyesi/hyperion-ruby.git
cd hyperion-ruby/riak
bundle install
bundle exec rspec
```

## Issues

Post issues on the hyperion-ruby github project:

* [https://github.com/mylesmegyesi/hyperion-ruby/issues](https://github.com/mylesmegyesi/hyperion-ruby/issues)


## License

Copyright (C) 2012 8th Light All Rights Reserved.

Distributed under the Eclipse Public License
