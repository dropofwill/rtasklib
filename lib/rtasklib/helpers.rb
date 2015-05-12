
module Rtasklib

  module Helpers
    # make this module a stateless, singleton
    extend self

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

    def integer? value
      value.to_i.to_s == value
    end

    def float? value
      Float(value) rescue false
    end

    def boolean? value
      ["on", "off", "yes", "no", "false", "true"].include? value.to_s.downcase
    end
  end
end
