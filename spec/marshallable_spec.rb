require 'spec_helper'

=begin
{id:"2",
description:"Some Task",
entry:"20150115T190311Z",
modified:"20150115T190311Z",
project:"Read",
status:"pending",
tags:["stuff"],
uuid:"d719fe0c-579f-484f-8dcb-a19a566fc890",
urgency:"2.03562",
random_ass_uda: "this should be treated as a string"}
=end

describe 'Rtasklib::Marshallable' do
  let(:test_instance) { (Class.new { include Rtasklib::Marshallable }).new }

  it 'Rtasklib::Marshallable exists in module' do
    expect(Rtasklib::Marshallable).not_to be nil
  end

  describe '#unmarshall' do

    describe "dealing with strings" do
      context "input string of type string" do
        it { expect(test_instance.unmarshall("Some Task")).to eq "Some Task" }
      end

      context "input symbol of type string" do
        it { expect(test_instance.unmarshall(:some_symbol)).to eq "some_symbol" }
      end

      context "input string of type read-only string" do
        let(:read_only_string) do
          test_instance.unmarshall("d719fe0c-579f-484f-8dcb-a19a566fc890", :string, true)
        end
        it "does not allow modifications to read_only strings" do
          expect { read_only_string << "blah" }.to raise_error RuntimeError
          expect(read_only_string).to eq "d719fe0c-579f-484f-8dcb-a19a566fc890"
        end
      end
    end

    describe "dealing with numerics" do
      context "input string int of type numeric" do
        subject { test_instance.unmarshall("22", :numeric) }
        it do
          expect(subject).to eq 22
          expect(subject.class).to eq Fixnum
        end
      end

      context "input string float of type numeric" do
        subject { test_instance.unmarshall("2.032562", :numeric) }
        it do
          expect(subject).to eq 2.032562
          expect(subject.class).to eq Float
        end
      end
    end

    describe "dealing with dates" do
      context "input string datestamp to datetime" do
      end
    end

    describe "dealing with duration" do
      context "input string duration to duration" do
      end
    end
  end
end
