require 'spec_helper'

describe Rtasklib do
  it 'has a version number' do
    expect(Rtasklib::VERSION).not_to be nil
  end

  describe Rtasklib::TaskWarrior do
    subject{ Rtasklib::TaskWarrior.new('spec/data/.taskrc')}
    it 'has a version number' do
      expect(subject.version.class).to eq Gem::Version
    end
  end
end
