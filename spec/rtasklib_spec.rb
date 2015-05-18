# Copyright (c) 2015 Will Paul (whp3652@rit.edu)
# All rights reserved.
#
# This file is distributed under the MIT license. See LICENSE.txt for details.

require 'spec_helper'

describe Rtasklib do
  it 'has a version number' do
    expect(Rtasklib::VERSION).not_to be nil
  end

  describe Rtasklib::TaskWarrior do
    describe "Rtasklib::TaskWarrior.new('spec/data/.task')" do
      subject{ Rtasklib::TaskWarrior.new('spec/data/.task') }
      it 'has a version number' do
        expect(subject.version.class).to eq Gem::Version
      end

      it 'uses a default configuration override' do
      end
    end

    describe "Rtasklib::TaskWarrior.new('spec/data/.task', {color: off})" do
      subject{ Rtasklib::TaskWarrior.new('spec/data/.task', {verbose: 'on'}) }
      it 'updates the default configuration override' do
      end
    end
  end
end
