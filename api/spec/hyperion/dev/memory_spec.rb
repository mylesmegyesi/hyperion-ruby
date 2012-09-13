require 'hyperion/dev/memory'
require 'hyperion/dev/ds_spec'

describe Hyperion::Dev::Memory do

  before :each do
    Hyperion::API.datastore = Hyperion::Dev::Memory.new
  end

  it_behaves_like 'Datastore'
end
