
module Rtasklib

  # A collection of stateless, non-end-user facing functions available
  # throughout the library
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

    # Converts a string of format "1.6.2 (adf342jsd)" to Gem::Version object
    #
    # @param raw [String]
    # @return [Gem::Version]
    def to_gem_version raw
      std_ver = raw.chomp.gsub(' ','.').delete('(').delete(')')
      Gem::Version.new std_ver
    end
    private :to_gem_version

    # Determine the type that a value should be coerced to
    # Int needs to precede float because ints are also floats
    # Doesn't detect arrays, b/c task stores these as comma separated strings
    # which could just as easily be Strings....
    # If nothing works it defaults to String.
    #
    # @param value [Object] anything that needs to be coerced, probably string
    # @return [Axiom::Types::Boolean, Integer, Float, String]
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
