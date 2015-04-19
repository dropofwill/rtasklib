require "virtus"

module Rtasklib

  module Models
    # A base Virtus model whose attributes are created dynamically based on the
    # given attributes are read from a .taskrc or Hash
    class TaskrcModel
    end
  end

  class Taskrc
    # @attr config [Models::TaskrcModel] a custom Virtus domain model
    attr_accessor :config

    # Generate a dynamic Virtus model, with the attributes defined by the input
    #
    # @param rc [Hash, Pathname] either a hash of attribute value pairs
    #   or a Pathname to the raw taskrc file.
    # @raise [TypeError] if rc is not of type Hash, String, or Pathname
    # @raise [RuntimeError] if rc is a path and does not exist on the fs
    def initialize rc
      @config = Models::TaskrcModel.new().extend(Virtus.model)

      if rc.is_a? Hash
        hash_to_model(rc)
      elsif rc.is_a? String or rc.is_a? Pathname
        if path_exist?(rc)
          file_to_model(rc)
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
    def hash_to_model taskrc_hash
      taskrc_hash.each do |attr, value|
        add_model_attr(attr, value)
        set_model_attr_value(attr, value)
      end
      config
    end

    # Converts a .taskrc file path into a Hash that can be converted into a
    # TaskrcModel object
    #
    # @param rc_path [String,Pathname] a valid pathname to a .taskrc file
    # @return [Models::TaskrcModel] the instance variable config
    def file_to_model rc_path
      taskrc = Hash[File.open(rc_path).map do |l|
        line_to_tuple(l)
      end.compact!]

      hash_to_model(taskrc)
    end

    # Converts a line of the form "json.array=on" to [ :json_array, true ]
    #
    # @param line [String] a line from a .taskrc file
    # @return [Array<Symbol, Object>, nil] a valid line returns an array of
    #   length 2, invalid input returns nil
    def line_to_tuple line
      line = line.chomp.split('=', 2)

      if line.size == 2
        attr = get_hash_attr_from_rc line[0]
        return [ attr.to_sym, line[1] ]
      else
        return nil
      end
    end

    def to_s *attrs
      model_to_rc(*attrs).join("\n")
    end

    # Serialize the given attrs model back to taskrc format
    # If attrs is nil, then default to all attributes
    def part_of_model_to_rc *attrs
      attrs.map do |attr|
        value = get_model_attr_value attr
        hash_attr = get_rc_attr_from_hash attr.to_s
        attr = "#{hash_attr}=#{value}"
      end
    end

    def model_to_rc
      part_of_model_to_rc config.attributes.keys
    end

    # Dynamically add a Virtus attr, detect Boolean, Integer, and Float types
    # based on the value, otherwise just treat it like a string.
    # Int needs to precede float because ints are also floats
    # TODO: May also be able to detect arrays
    def add_model_attr attr, value
      if boolean? value
        config.attribute attr.to_sym, Axiom::Types::Boolean
      elsif integer? value
        config.attribute attr.to_sym, Integer
      elsif float? value
        config.attribute attr.to_sym, Float
      else
        config.attribute attr.to_sym, String
      end
    end

    def set_model_attr_value attr, value
      config.send("#{attr}=".to_sym, value)
    end

    def get_model_attr_value attr
      config.send("#{attr.to_s}".to_sym)
    end


    private
    def get_hash_attr_from_rc attr
      return attr.gsub(".", "_")
    end

    def get_rc_attr_from_hash attr
      return attr.gsub("_", ".")
    end


    def path_exist? path
      if path.is_a? Pathname
        return path.exist?
      elsif path.is_a? String
        return Pathname.new(path).exist?
      else
        return false
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
