require 'spec_helper'

describe Rtasklib::Controller do
  include Rtasklib::Controller

  shared_examples_for 'export' do
    it 'should return an Array' do
      expect(subject.class).to eq Array
    end

    it 'should return an Array<TaskModel>' do
      expect(subject.each do |t|
        expect(t.class).to eq(Rtasklib::Models::TaskModel)
      end)
    end
  end

  shared_examples_for 'export all' do
    it_behaves_like 'export'

    # Number changes to often
    # it 'should load in the correct number of task models' do
    #   expect(subject.size).to eq(4)
    # end
  end

  describe 'Rtasklib::Controller#all' do
    subject { Rtasklib::TaskWarrior.new("spec/data/.task").all }
    it_behaves_like 'export all'
  end

  describe 'Rtasklib::Controller#some' do

    describe '#some without arguments should behave like #all' do
      subject { Rtasklib::TaskWarrior.new("spec/data/.task").some }
      it_behaves_like 'export all'
    end

    describe '#some should accept filter parameters' do
      subject { Rtasklib::TaskWarrior.new("spec/data/.task").some ids:[1,2] }
      it_behaves_like 'export'

      it 'should load in the correct number of task models' do
        expect(subject.size).to eq(2)
      end
    end
  end

  describe 'Rtasklib::Controller#uda_exists?' do
    it 'should return true if a uda is found that matches the input' do
    end
  end

  describe 'Rtasklib::Controller#all' do
  end

  describe 'Rtasklib::Controller#add!' do
    before(:context) do
      @tw = Rtasklib::TaskWarrior.new("spec/data/.task")
      @pre_count = @tw.all.count
      @count_of_undos = 0
    end

    # after(:context) do
    #   @tw.undo!
    # end

    # subject { @tw.add!("Test") }
    #
    # it 'should add another task' do
    #   expect(@tw.all.count).to eq(@pre_count + 1)
    # end
  end

  describe 'Rtasklib::Controller#modify!' do
  end

  describe 'Rtasklib::Controller#undo!' do
    before(:context) do
      @tw = Rtasklib::TaskWarrior.new("spec/data/.task")
      @pre_count = @tw.all.count
      @tw.add!("#undo! test")
      @tw.undo!
    end

    it 'should have the same count as before the "undo! test" task was created' do
      expect(@tw.all.count).to eq(@pre_count)
    end
  end
end
