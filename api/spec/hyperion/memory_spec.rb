require 'hyperion/memory'
require 'hyperion/dev/ds_spec'

describe Hyperion::Memory do

  around :each do |example|
    Hyperion::API.with_datastore(:memory) do
      example.run
    end
  end

  it_behaves_like 'Datastore'
end
