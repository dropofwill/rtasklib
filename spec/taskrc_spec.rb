require 'spec_helper'

describe Rtasklib::Taskrc do

  describe 'initialize with a test .taskrc' do
    subject { Rtasklib::Taskrc.new("spec/data/.taskrc") }

    it "dot paths are converted to underscores" do
      expect(subject.raw["data_location"]).to eq "./.task"
    end

    it "top level configs are possible" do
      expect(subject.raw["color"]).to eq "on"
    end

    it "empty configs are possible" do
      expect(subject.raw["color_label"]).to eq ""
    end

    it "creates a Virtus model representation" do
      expect(subject.config.class).to eq Rtasklib::TaskrcModel
    end
  end
end
