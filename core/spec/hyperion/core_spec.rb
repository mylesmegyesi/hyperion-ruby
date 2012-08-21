require 'hyperion/core'

describe Hyperion::Core do
  let(:subject) { described_class }

  describe 'datastore' do
    it 'will throw an error if the datastore is called before assignment' do
      expect{ subject.datastore }.to raise_error
    end
  end

  describe 'new?' do
    it 'false if a record exists' do
      subject.new?({key: 1}).should be_false
    end

    it 'true if a record does not exist' do
      subject.new?({}).should be_true
    end
  end
end
