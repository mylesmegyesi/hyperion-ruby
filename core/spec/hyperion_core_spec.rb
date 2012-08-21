require 'rspec'
require 'hyperion_core'

describe Hyperion::Core do
  let(:subject) { described_class }
  #let(:mock_record) { { kind: "games", title: "The Legend of Zelda", system: "Nintendo 64" } }

  describe 'datastore' do
    it 'will throw an error if the datastore is called before assignment' do
      expect{ subject.datastore }.to raise_error
    end
  end

  describe 'new?' do
    it 'returns true if a record exists' do
      record = { id: 1 }
      subject.new?(record).should be_true
    end

    it 'returns false if a record does not exist' do
      subject.new?({}).should be_false
    end
  end
end
