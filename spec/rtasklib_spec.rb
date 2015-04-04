require 'spec_helper'

describe Rtasklib do
  it 'has a version number' do
    expect(Rtasklib::VERSION).not_to be nil
  end

  describe Rtasklib::TaskWarrior do
    describe "Rtasklib::TaskWarrior.new('spec/data/.taskrc')" do
      subject{ Rtasklib::TaskWarrior.new('spec/data/.taskrc') }
      it 'has a version number' do
        expect(subject.version.class).to eq Gem::Version
      end

      it 'uses a default configuration override' do
      end
    end

    describe "Rtasklib::TaskWarrior.new('spec/data/.taskrc', {color: off})" do
      subject{ Rtasklib::TaskWarrior.new('spec/data/.taskrc', {verbose: 'on'}) }
      it 'updates the default configuration override' do
      end
    end
  end
end
