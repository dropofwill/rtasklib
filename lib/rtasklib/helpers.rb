require "multi_json"
require "oj"

module Rtasklib

  # A collection of stateless, non-end-user facing functions available
  # throughout the library
  module Helpers
    # make this module a stateless, singleton
    extend self

    # Wrap a string with quotes to make it safe to pass to `task`
    #
    # @param string [String]
    # @api public
    def wrap_string string
      "\"#{string.to_s}\""
    end

    # Converts ids, tags, and dom queries to a single string ready to pass
    # directly to task.
    #
    # @param ids[Range, Array<String, Range, Fixnum>, String, Fixnum]
    # @param tags[String, Array<String>]
    # @param dom[String, Array<String>]
    # @return [String] a string with ids tags and dom joined by a space
    # @api public
    def filter ids: nil, tags: nil, dom: nil
      id_s = tag_s = dom_s = ""
      id_s   = process_ids(ids)   unless ids.nil?
      tag_s  = process_tags(tags) unless tags.nil?
      dom_s  = process_dom(dom)   unless dom.nil?
      return "#{id_s} #{tag_s} #{dom_s}".strip
    end

    # Filters should be a list of values
    # Ranges interpreted as ids
    # 1...5 : "1,2,3,4,5"
    # 1..5  : "1,2,3,4"
    # 1     : "1"
    # and joined with ","
    # [1...5, 8, 9] : "1,2,3,4,5,8,9"
    #
    # @param id_a [Array<String, Range, Fixnum>]
    # @return [String]
    # @api public
    def id_a_to_s id_a
      id_a.map do |el|
         proc_ids = process_ids(el)
         proc_ids
      end.compact.join(",")
    end

    # Converts arbitrary id input to a task safe string
    #
    # @param ids[Range, Array<String, Range, Fixnum>, String, Fixnum]
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

    # Convert a range to a comma separated strings, e.g. 1..4 -> "1,2,3,4"
    #
    # @param id_range [Range]
    # @return [Array<String>]
    # @api public
    def id_range_to_s id_range
      id_range.to_a.join(",")
    end

    # Convert a tag string or an array of strings to a space separated string
    #
    # @param tags [String, Array<String>]
    # @api private
    def process_tags tags
      case tags
      when String
        tags.split(" ").map { |t| process_tag t }.join(" ")
      when Array
        tags.map { |t| process_tags t }.join(" ")
      end
    end

    # Ensures that a tag begins with a + or -
    #
    # @return [String]
    # @api public
    def process_tag tag
      reserved_symbols = %w{+ - and or xor < <= = != >=  > ( )}

      # convert plain tags to plus tags
      unless tag.start_with?(*reserved_symbols)
        tag = "+#{tag}"
      end
      return tag
    end

    # Process string and array input of the likes of project:Work or 
    # description.contains:yolo
    #
    # @todo handle Hash parameters
    # @param [String, Array<String>]
    # @api private
    def process_dom dom
      case dom
      when String
        dom
      when Array
        dom.join(" ")
      when Hash
        raise NotImplemtedError
      end
    end

    # Is a given taskrc attribute dealing with udas?
    #
    # @api public
    def uda_attr? attr
      attr.to_s.start_with? "uda"
    end

    # Returns part of attribute at a given depth
    #
    # @api public
    def arbitrary_attr attr, depth: 1
      attr.to_s.split("_")[depth]
    end

    # Returns all attribute string after given depth
    #
    # @api public
    def deep_attr attr, depth: 2
      attr.to_s.split("_")[depth..-1].join("_")
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
