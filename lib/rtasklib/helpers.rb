
module Rtasklib

  module Helpers
    # make this module a stateless, singleton
    extend self

    # Filters should be a list of values
    # Ranges interpreted as ids
    #   1...5 : "1-5"
    #   1..5  : "1-4"
    #   1     : "1"
    #   and joined with ","
    #   [1...5, 8, 9] : "1-5,8,9"

    # Int needs to precede float because ints are also floats
    def determine_type value
      if boolean? value
        return Axiom::Types::Boolean
      elsif integer? value
        return Integer
      elsif float? value
        return Float
      else
        return String
      end
    end

    # Can the input be coerced to an integer without losing information?
    #
    # @return [Boolean]
    def integer? value
      value.to_i.to_s == value rescue false
    end

    # Can the input be coerced to a float without losing information?
    #
    # @return [Boolean]
    def float? value
      Float(value) rescue false
    end

    # Can the input be coerced to a boolean without losing information?
    #
    # @return [Boolean]
    def boolean? value
      ["on", "off", "yes", "no", "false", "true"]
        .include? value.to_s.downcase rescue false
    end
  end
end
