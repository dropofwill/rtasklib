require 'spec_helper'

describe Rtasklib::Helpers do
  puts Rtasklib::Helpers

  describe 'Rtasklib::Helpers#to_gem_version' do

    it 'can handle sub version numbers' do
      expect(Rtasklib::Helpers.to_gem_version("2.5.3 (afdj5)"))
        .to eq(Gem::Version.new("2.5.3.afdj5"))
    end
  end
end
