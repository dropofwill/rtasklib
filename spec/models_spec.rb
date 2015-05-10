require 'spec_helper'
require 'rtasklib/models'

describe Rtasklib::Models do

  it 'Rtasklib::Models exists in module' do
    expect(Rtasklib::Models).not_to be nil
  end

  describe Rtasklib::Models::TaskModel do
    # let(:data) { Hash.new(description: "Wash dishes") }
    context "Create a task with the bare minimum" do

      subject { Rtasklib::Models::TaskModel.new({description: "Wash dishes"}) }

      it "description is a String" do
        expect(subject.description.class).to eq String
      end

      it "description is 'Wash dishes'" do
        expect(subject.description).to eq "Wash dishes"
      end

      # it "private attributes are not accessible directly" do
      #   expect{subject.uuid = 1}.to raise_error NoMethodError
      # end

      # it "but can be set with dynamic private setters" do
      #   expect(subject.set_uuid("10")).to eq "10"
      # end
    end

  end
end
