require "virtus"
require "enumerator"

module Rtasklib

  # A class that wraps a single Virtus domain model with a number of creation
  # and manipulation methods
  class Taskrc
    # @attr config [Models::TaskrcModel] a custom Virtus domain model
    attr_accessor :config

    # Generate a dynamic Virtus model, with the attributes defined by the input
    #
    # @param rc [Hash, Pathname] either a hash of attribute value pairs
    #   or a Pathname to the raw taskrc file.
    # @raise [TypeError] if rc is not of type Hash, String, or Pathname
    # @raise [RuntimeError] if rc is a path and does not exist on the fs
    def initialize rc, type=:array
      @config = Models::TaskrcModel.new().extend(Virtus.model)

      case type
      when :array
        mappable_to_model(rc)
      when :hash
        hash_to_model(rc)
      when :path
        if path_exist?(rc)
          mappable_to_model(File.open(rc))
        else
          raise RuntimeError.new("rc path does not exist on the file system")
        end
      else
        raise TypeError.new("no implicit conversion to Hash, String, or Pathname")
      end
    end

    # Turn a hash of attribute => value pairs into a TaskrcModel object.
    # There can be only one TaskrcModel object per Taskrc, it's saved to the
    # instance variable `config`
    #
    # @param taskrc_hash [Hash{Symbol=>String}]
    # @return [Models::TaskrcModel] the instance variable config
    # @api private
    def hash_to_model taskrc_hash
      taskrc_hash.each do |attr, value|
        add_model_attr(attr, value)
        set_model_attr_value(attr, value)
      end
      config
    end
    private :hash_to_model

    # Converts a .taskrc file path into a Hash that can be converted into a
    # TaskrcModel object
    #
    # @param rc_path [String,Pathname] a valid pathname to a .taskrc file
    # @return [Models::TaskrcModel] the instance variable config
    # @api private
    def mappable_to_model rc_file
      rc_file.map! { |l| line_to_tuple(l) }.compact!
      taskrc = Hash[rc_file]
      hash_to_model(taskrc)
    end
    private :mappable_to_model

    # Converts a line of the form "json.array=on" to [ :json_array, true ]
    #
    # @param line [String] a line from a .taskrc file
    # @return [Array<Symbol, Object>, nil] a valid line returns an array of
    #   length 2, invalid input returns nil
    # @api private
    def line_to_tuple line
      line = line.chomp.split('=', 2)

      if line.size == 2 and not line.include? "#"
        attr = get_hash_attr_from_rc line[0]
        return [ attr.to_sym, line[1] ]
      else
        return nil
      end
    end
    private :line_to_tuple

    # Serialize the given attrs model back to the taskrc format
    #
    # @param attrs [Array] a splat of attributes
    # @return [Array<String>] an array of CLI formatted strings
    # @api public
    def part_of_model_to_rc *attrs
      attrs.map do |attr|
        value = get_model_attr_value attr
        hash_attr = get_rc_attr_from_hash attr.to_s
        attr = "rc.#{hash_attr}=#{value}"
      end
    end

    # Serialize all attrs of the model to the taskrc format
    #
    # @return [Array<String>] an array of CLI formatted strings
    # @api public
    def model_to_rc
      part_of_model_to_rc(*config.attributes.keys)
    end

    # Serialize the given attrs model back to the taskrc format and reduce them
    # to a string that can be passed directly to Execute
    #
    # @param attrs [Array] a splat of attributes
    # @return [String] a CLI formatted string
    # @api public
    def part_of_model_to_s *attrs
      part_of_model_to_rc(*attrs).join(" ")
    end

    # Serialize all attrs model back to the taskrc format and reduce them
    # to a string that can be passed directly to Execute
    #
    # @return [String] a CLI formatted string
    # @api public
    def model_to_s
      model_to_rc().join(" ")
    end

    # Dynamically add a Virtus attr, detect Boolean, Integer, and Float types
    # based on the value, otherwise just treat it like a string.
    # Modifies the config instance variable
    # TODO: May also be able to detect arrays
    #
    # @param attr [#to_sym] the name for the attr, e.g. "json_array"
    # @param value [String] the value of the attr, e.g. "yes"
    # @return [undefined]
    # @api private
    def add_model_attr attr, value
      config.attribute(attr.to_sym, Helpers.determine_type(value))
      # if boolean? value
      #   config.attribute attr.to_sym, Axiom::Types::Boolean
      # elsif integer? value
      #   config.attribute attr.to_sym, Integer
      # elsif float? value
      #   config.attribute attr.to_sym, Float
      # else
      #   config.attribute attr.to_sym, String
      # end
    end
    private :add_model_attr

    # Modifies the value of a given attr in the config object
    #
    # @param attr [#to_s] the name for the attr, e.g. "json_array"
    # @param attr [String] the value of the attr, e.g. "yes"
    # @return [undefined]
    # @api public
    def set_model_attr_value attr, value
      config.send("#{attr}=".to_sym, value)
    end

    # Gets the current value of a given attr in the config object
    #
    # @param attr [#to_s] the name for the attr, e.g. "json_array"
    # @return [Object] the type varies depending on the type attr
    # @api public
    def get_model_attr_value attr
      config.send("#{attr.to_s}".to_sym)
    end

    # @param attr [String] the name for the attr, e.g. "json_array"
    # @return [String]
    # @api private
    def get_hash_attr_from_rc attr
      return attr.gsub(".", "_")
    end
    private :get_hash_attr_from_rc

    # @param attr [String] the name for the attr, e.g. "json_array"
    # @return [String]
    # @api private
    def get_rc_attr_from_hash attr
      return attr.gsub("_", ".")
    end
    private :get_rc_attr_from_hash

    # Check whether a given object is a path and it exists on the file system
    #
    # @param path [Object]
    # @return [Boolean]
    # @api private
    def path_exist? path
      if path.is_a? Pathname
        return path.exist?
      elsif path.is_a? String
        return Pathname.new(path).exist?
      else
        return false
      end
    end
    private :path_exist?
  end
end
