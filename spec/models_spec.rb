require 'spec_helper'
require 'rtasklib/models'

describe "Rtasklib::Models" do

  it 'Rtasklib::Models exists in module' do
    expect(Rtasklib::Models).not_to be nil
  end

  describe "Rtasklib::Models::Task" do
    # let(:data) { Hash.new(description: "Wash dishes") }
    context "Create a task with the bare minimum" do
      subject { Task.new({description: "Wash dishes"}) }
      it do
        expect(subject.description.class).to eq String
        expect(subject.description).to eq "Wash dishes"
      end
    end

  end
end
