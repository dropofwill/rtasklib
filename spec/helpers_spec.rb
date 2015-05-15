require 'spec_helper'

describe Rtasklib::Helpers do

  describe 'Rtasklib::Helpers#to_gem_version' do

    it 'can handle sub version numbers' do
      expect(Rtasklib::Helpers.to_gem_version("2.5.3 (afdj5)"))
        .to eq(Gem::Version.new("2.5.3.afdj5"))
    end
  end

  describe 'Rtasklib::Helpers#determine_type' do

    it 'considers "10" an integer' do
      expect(Rtasklib::Helpers.determine_type("10")).to eq(Integer)
    end

    it 'considers "10.1" a float' do
      expect(Rtasklib::Helpers.determine_type("10.1")).to eq(Float)
    end

    it 'considers "on" a boolean' do
      expect(Rtasklib::Helpers.determine_type("on")).to eq(Axiom::Types::Boolean)
    end

    it 'considers "{"yolo":[1,2,3]}" a JSON object' do
      test_json = '{"id":1,"description":"Anonymous Book",
                   "entry":"20150115T190114Z","modified":"20150115T190114Z",
                   "project":"Read","status":"pending","tags":["stuff"],
                   "uuid":"c483b58d-a3f2-4a2a-b944-8b41414309cb",
                   "urgency":"2.45753"}'
      expect(Rtasklib::Helpers.determine_type(test_json)).to eq(MultiJson)
    end

    it 'considers "on off" a String' do
      expect(Rtasklib::Helpers.determine_type("on ")).to eq(String)
    end
  end

  describe 'Rtasklib::Helpers#filter' do

    it 'treats arrays of ranges properly' do
      expect(Rtasklib::Helpers.filter(ids: [1..3,5...6])).to eq("1,2,3,5")
    end

    it 'treats arrays of strings properly' do
      expect(Rtasklib::Helpers.filter(ids: ["1,2", "5"])).to eq("1,2,5")
    end

    it 'treats arrays of ints properly' do
      expect(Rtasklib::Helpers.filter(ids: [1,2,3,4,5])).to eq("1,2,3,4,5")
    end

    it 'treats arrays mixed objects properly' do
      expect(Rtasklib::Helpers.filter(ids: [1,2,3,4,5, 10..20, "7,8"]))
      .to eq("1,2,3,4,5,10,11,12,13,14,15,16,17,18,19,20,7,8")
    end
  end
end
