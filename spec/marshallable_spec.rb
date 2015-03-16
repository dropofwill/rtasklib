require 'spec_helper'

=begin
{id:'2',
description:'Some Task',
entry:'20150115T190311Z',
modified:'20150115T190311Z',
project:'Read',
status:'pending',
tags:['stuff'],
uuid:'d719fe0c-579f-484f-8dcb-a19a566fc890',
urgency:'2.03562',
random_ass_uda: 'this should be treated as a string'}
=end

=begin
Duration strings we need to support
See: https://git.tasktools.org/projects/TM/repos/task/browse/src/Duration.cpp
  {'annual',     365 * DAY,    true},
  {'biannual',   730 * DAY,    true},
  {'bimonthly',   61 * DAY,    true},
  {'biweekly',    14 * DAY,    true},
  {'biyearly',   730 * DAY,    true},
  {'daily',        1 * DAY,    true},
  {'days',         1 * DAY,    false},
  {'day',          1 * DAY,    true},
  {'d',            1 * DAY,    false},
  {'fortnight',   14 * DAY,    true},
  {'hours',        1 * HOUR,   false},
  {'hour',         1 * HOUR,   true},
  {'h',            1 * HOUR,   false},
  {'minutes',      1 * MINUTE, false},
  {'minute',       1 * MINUTE, false},
  {'min',          1 * MINUTE, false},
  {'monthly',     30 * DAY,    true},
  {'months',      30 * DAY,    false},
  {'month',       30 * DAY,    true},
  {'mo',          30 * DAY,    false},
  {'quarterly',   91 * DAY,    true},
  {'quarters',    91 * DAY,    false},
  {'quarter',     91 * DAY,    true},
  {'q',           91 * DAY,    false},
  {'semiannual', 183 * DAY,    true},
  {'sennight',    14 * DAY,    false},
  {'seconds',      1 * SECOND, false},
  {'second',       1 * SECOND, true},
  {'s',            1 * SECOND, false},
  {'weekdays',     1 * DAY,    true},
  {'weekly',       7 * DAY,    true},
  {'weeks',        7 * DAY,    false},
  {'week',         7 * DAY,    true},
  {'w',            7 * DAY,    false},
  {'yearly',     365 * DAY,    true},
  {'years',      365 * DAY,    false},
  {'year',       365 * DAY,    true},
  {'y',          365 * DAY,    false},
=end

describe Rtasklib::Marshallable do
  let(:test_instance) { (Class.new { include Rtasklib::Marshallable }).new }

  it 'Rtasklib::Marshallable exists in module' do
    expect(Rtasklib::Marshallable).not_to be nil
  end

  describe '#unmarshall' do

    describe 'dealing with strings' do
      context 'input string of type string' do
        it { expect(test_instance.unmarshall('Some Task')).to eq 'Some Task' }
      end

      context 'input symbol of type string' do
        it { expect(test_instance.unmarshall(:some_symbol)).to eq 'some_symbol' }
      end

      context 'input string of type read-only string' do
        let(:read_only_string) do
          test_instance.unmarshall('d719fe0c-579f-484f-8dcb-a19a566fc890', :string, true)
        end
        it 'does not allow modifications to read_only strings' do
          expect { read_only_string << 'blah' }.to raise_error RuntimeError
          expect(read_only_string).to eq 'd719fe0c-579f-484f-8dcb-a19a566fc890'
        end
      end
    end

    describe 'dealing with numerics' do
      context 'input string int of type numeric' do
        subject { test_instance.unmarshall('22', :numeric) }
        it do
          expect(subject).to eq 22
          expect(subject.class).to eq Fixnum
        end
      end

      context 'input string float of type numeric' do
        subject { test_instance.unmarshall('2.032562', :numeric) }
        it do
          expect(subject).to eq 2.032562
          expect(subject.class).to eq Float
        end
      end
    end

    describe 'dealing with dates' do
      context 'input string datestamp to datetime' do
        subject { test_instance.unmarshall('20150115T190311Z', :datetime) }
        it do
          expect(subject.class).to eq DateTime
          expect(subject.year).to eq 2015
          expect(subject.month).to eq 1
          expect(subject.day).to eq 15
          expect(subject.hour).to eq 19
          expect(subject.minute).to eq 3
          expect(subject.second).to eq 11
        end
      end
    end

    describe 'dealing with duration' do
      context 'input string duration to duration' do
        subject { test_instance.unmarshall('monthly', :duration) }
        it do
          expect(subject.class).to eq TwDuration
          # expect(subject.month).to eq 1
          # expect(subject.to_s).to eq 'monthly'
          # expect(subject.negative).to eq false
        end

        subject { test_instance.unmarshall('4w', :duration) }
        it do
          expect(subject.class).to eq TwDuration
          # expect(subject.week).to eq 4
          # expect(subject.to_s).to eq '4w'
          # expect(subject.negative).to eq true
        end
      end
    end
  end
end
