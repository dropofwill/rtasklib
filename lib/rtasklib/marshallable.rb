require 'bigdecimal'
require 'ISO8601'
require 'date'

module Rtasklib

  module Marshallable
    # TaskWarrior type => Ruby class:
    #   :string => String,
    #   :numeric => Fixnum or Float
    #   :date => Datetime
    #   :duration => Time

    TW_DATE_FORMAT = "%Y%m%dT%H%M%SZ"

    # unmarshall values from `task <filter> export` json strings
    # frozen means .freeze, makes the data read only
    def unmarshall value, type=:string, frozen=false
      case type
      when :string
        marshalled = value.to_s
      when :numeric
        marshalled = to_numeric(value)
      when :datetime
        marshalled = DateTime.strptime(value, TW_DATE_FORMAT)
      when :duration
        marshalled = TwDuration.new(value)
      end

      return marshalled.freeze if frozen
      return marshalled
    end

    def marshall value, type=:string
    end

    def normalize value, type=:string
    end

    private

    def to_numeric(anything)
      num = BigDecimal.new(anything.to_s)
      if num.frac == 0
        num.to_i
      else
        num.to_f
      end
    end
  end
end

class TwDuration < ISO8601::Duration
  attr_accessor :original, :negative

  def initialize input, base = nil
    @original = input
    @original.freeze

    new_input = `task calc #{input}`.chomp

    if new_input.include?("-")
      new_input.gsub!(/\-/, "")
      @negative = true
    else
      @negative = false
    end

    super new_input, base
  end
end
