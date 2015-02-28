require 'bigdecimal'

module Rtasklib

  module Marshallable
    # TaskWarrior type => Ruby class:
    #   :string => String,
    #   :numeric => Fixnum or Float
    #   :date => Datetime
    #   :duration => Time

    # unmarshall values from `task <filter> export` json strings
    # frozen means .freeze, makes the data read only
    def unmarshall value, type=:string, frozen=false
      case type
      when :string
        marshalled = value.to_s
      when :numeric
        marshalled = to_numeric(value)
      when :datetime
      when :duration
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
