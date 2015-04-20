require 'spec_helper'

describe Rtasklib::Controller do
  include Rtasklib::Controller

  it 'can handle sub version numbers' do
    expect(to_gem_version("2.5.3 (afdj5)"))
      .to eq(Gem::Version.new("2.5.3.afdj5"))
  end
end
