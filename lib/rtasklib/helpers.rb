require "multi_json"
require "oj"

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
    #
    # Converts ids, tags, and dom queries to a single string ready to pass
    # directly to task.
    #
    # @param ids[Range, Array<String>, String, Fixnum]
    # @param tags[String, Array<String>]
    # @param dom[String, Array<String>]
    # @return [String] "#{id_s} #{tag_s} #{dom_s}"
    # @api public
    def filter ids: nil, tags: nil, dom: nil
      id_s = tag_s = dom_s = ""
      id_s   = process_ids(ids)   unless ids.nil?
      tag_s  = process_tags(tags) unless tags.nil?
      dom_s  = process_dom(dom)   unless dom.nil?
      return "#{id_s} #{tag_s} #{dom_s}"
    end

    # Converts arbitrary id input to a task safe string
    #
    # @param ids[Range, Array<String>, String, Fixnum]
    # @api public
    def process_ids ids
      case ids
      when Range
        return id_range_to_s(ids)
      when Array
        return id_a_to_s(ids)
      when String
        return ids.delete(" ")
      when Fixnum
        return ids
      end
    end
    # private :process_ids

    # Convert a range to a comma separated strings, e.g. 1..4 -> "1,2,3,4"
    #
    # @param id_range [Range]
    # @return [Array<String>]
    # @api public
    def id_range_to_s id_range
      id_range.to_a.join(",")
    end
    # private :id_range_to_s

    # @api public
    def id_a_to_s id_a
      id_a.map do |el|
         proc_ids = process_ids(el)
         proc_ids
      end
      .compact.join(",")
    end
    # private :id_range_to_s

    # @api private
    def process_tags tags
    end

    # @api private
    def process_dom dom
    end

    # Converts a string of format "1.6.2 (adf342jsd)" to Gem::Version object
    #
    # @param raw [String]
    # @return [Gem::Version]
    # @api public
    def to_gem_version raw
      std_ver = raw.chomp.gsub(' ','.').delete('(').delete(')')
      Gem::Version.new std_ver
    end

    # Determine the type that a value should be coerced to
    # Int needs to precede float because ints are also floats
    # Doesn't detect arrays, b/c task stores these as comma separated strings
    # which could just as easily be Strings....
    # If nothing works it defaults to String.
    # TODO: JSON parse
    #
    # @param value [Object] anything that needs to be coerced, probably string
    # @return [Axiom::Types::Boolean, Integer, Float, String]
    # @api public
    def determine_type value
      if boolean? value
        return Axiom::Types::Boolean
      elsif integer? value
        return Integer
      elsif float? value
        return Float
      elsif json? value
        return MultiJson
      else
        return String
      end
    end

    # Can the input be coerced to an integer without losing information?
    #
    # @return [Boolean] true if coercible, false if not
    # @api private
    def integer? value
      value.to_i.to_s == value rescue false
    end
    private :integer?

    # Can the input be coerced to a JSON object without losing information?
    #
    # @return [Boolean] true if coercible, false if not
    # @api private
    def json? value
      begin 
        return false unless value.is_a? String
        MultiJson.load(value)
        true 
      rescue MultiJson::ParseError
        false
      end
    end
    private :json?

    # Can the input be coerced to a float without losing information?
    #
    # @return [Boolean] true if coercible, false if not
    # @api private
    def float? value
      begin
        true if Float(value)
      rescue
        false
      end
    end
    private :float?

    # Can the input be coerced to a boolean without losing information?
    #
    # @return [Boolean] true if coercible, false if not
    # @api private
    def boolean? value
      ["on", "off", "yes", "no", "false", "true"]
        .include? value.to_s.downcase rescue false
    end
    private :boolean?
  end
end
