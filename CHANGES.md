# 0.1.2

* adds support for filtering on foreign keys
* fixes Hyperion riak gemspec to include javascript templates

# 0.1.1

* adds support for foreign keys

# 0.1.0

* refactors usage of thread local bindings
* adds entities with fields, timestamps, defaults, packers, unpackers, and types
* collapses Hyperion::API into the root Hyperion module
* refactors datastore setters
* connection pooling
* adds Riak implementation

# 0.0.1.alpha5

* use GUIDs for savepoint names
* refactor API string utils
* fixes missing requires
* fixes bug with API.with_datastore to return the block result

# 0.0.1.alpha4

* ruby 1.8.7 compatibility fixes

# 0.0.1.alpha3

* adds a datastore factory and refactors all datastores to be compatible with it
* moves Hyperion::Dev::Memory to Hyperion::Memory to work with the new factory
* adds Rack middleware for Sql implementations
