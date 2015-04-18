require 'spec_helper'

describe Rtasklib::Taskrc do

  describe "initialize with a test .taskrc" do
    subject { Rtasklib::Taskrc.new("spec/data/.taskrc").config }

    it "creates a Virtus model representation" do
      expect(subject.class).to eq Rtasklib::Models::TaskrcModel
    end

    it "attribute name dot paths are converted to underscores" do
      expect(subject.data_location).to eq "./.task"
    end

    it "top level configs are possible" do
      expect(subject.color).to eq true
    end

    it "empty configs are possible" do
      expect(subject.color_pri_H).to eq ""
    end

    it "treats 'on' as true" do
      expect(subject.color).to eq true
    end

    it "treats 'yes' as true" do
      expect(subject.calendar_legend).to eq true
    end

    it "treats 'no' as false" do
      expect(subject.calendar_offset).to eq false
    end

    it "treats 'off' as false" do
      expect(subject.json_array).to eq false
    end

    it "treats integers correctly" do
      expect(subject.recurrence_limit).to eq 1
    end

    it "treats floats correctly" do
      expect(subject.urgency_waiting_coefficient).to eq(-3.0)
    end
  end

  describe "convert a TaskrcModel back to a string" do
    subject do
      taskrc = Rtasklib::Taskrc.new("spec/data/.taskrc")
      taskrc.model_to_rc(:color, :calendar_offset, :json_array)
    end

    it "returns an array" do
      expect(subject.class).to eq Array
    end

    it "returns an array of strings" do
      expect(subject.first.class).to eq String
    end

    it "which are dot separated and use =" do
      expect(subject.last).to eq "json.array=false"
    end
  end
end
