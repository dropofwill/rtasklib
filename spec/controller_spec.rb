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
    subject { Rtasklib::TaskWarrior.new("spec/data/.task").uda_exists?("client")}

    it 'should return false if a uda is not found that matches the input' do
      expect(subject).to eq(false)
    end
  end

  describe 'Rtasklib::Controller#count' do

    describe '#count should count existing tasks' do

      subject { Rtasklib::TaskWarrior.new("spec/data/.task").count ids:[1,2] }

      it 'should return an integer' do
        expect(subject.is_a? Integer).to eq(true)
      end

      it 'should return 2 for ids 1,2' do
        expect(subject).to eq(2)
      end
    end

    describe '#count should return 0 for non existing tasks' do

      subject { Rtasklib::TaskWarrior.new("spec/data/.task").count ids:1000 }

      it 'should return 0 for ids 1000' do
        expect(subject).to eq(0)
      end
    end
  end

  describe 'Rtasklib::Controller#add!' do
    before(:context) do
      @tw = Rtasklib::TaskWarrior.new("spec/data/.task")
      @pre_count = @tw.all.count
      @count_of_undos = 0
      @tw.add!("Test adding methods")
    end

    it 'should add another task' do
      expect(@tw.all.count).to eq(@pre_count + 1)
    end

    after(:context) do
      @tw.undo!
    end
  end

  describe 'Rtasklib::Controller#modify!' do
    before(:context) do
      @tw = Rtasklib::TaskWarrior.new("spec/data/.task")
      @pre_task = @tw.some(ids: 1).first
      @tw.modify!("description", "Modified description", ids: 1)
      @after_task = @tw.some(ids: 1).first
      @tw.undo!
    end

    it 'should have a different description after modification' do
      expect(@pre_task.description).not_to eq(@after_task.description)
    end

    it 'should have the same description after undo' do
      expect(@pre_task.description).to eq(@tw.some(ids: 1).first.description)
    end
  end

  describe 'Rtasklib::Controller#undo!' do
    describe '#undo! should fix changes from add!' do
      before(:context) do
        @tw = Rtasklib::TaskWarrior.new("spec/data/.task")
        @pre_count = @tw.all.count
        @tw.add!("#undo! test")
        @after_count = @tw.all.count
        @tw.undo!
      end

      it 'should have the same count as before the "undo! test" task was created' do
        expect(@tw.all.count).to eq(@pre_count)
        expect(@tw.all.count).not_to eq(@after_count)
      end
    end

    describe '#undo! should fix changes from modify!' do
    end
  end
end
