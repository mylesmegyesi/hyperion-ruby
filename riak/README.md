Hyperion::Riak
=============

A Hyperion datastore for the [Riak](http://basho.com/products/riak-overview/) database.

## Installation

```ruby
gem 'hyperion-riak'
```

## Usage

### Instantiating a datastore

```ruby
require 'hyperion'
Hyperion.new_datastore(:riak, :app => 'my_app_development', :protocol => :pbc)
```

#### Options

`:app` The app name. This will add a namespace to all buckets. For instance, if the app name if 'app_development_' and the kind is 'people', Hyperion will save and load data from the 'app_development_people' bucket. This is useful for using evironment specific buckets.

All options except `:app` will be passed into the Riak client. See [this](https://github.com/basho/riak-ruby-client/wiki/Connecting-to-Riak) page for information on how to configure the Riak client. 

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
