require "virtus"

module Rtasklib

  module Models
    # contents dynamically defined by what attributes are read from
    # `task config` or the given .taskrc
    class TaskrcModel
    end
  end

  class Taskrc
    attr_accessor :config

    def initialize rc_path=nil, data=nil
      @config = Models::TaskrcModel.new().extend(Virtus.model)

      if rc_path
        generate_from_file(rc_path)
      elsif data
        # TODO
        # generate_from_string(data)
        raise NotImplementedError
      else
        raise ArgumentError.new("Neither a path of a data object given")
      end
    end

    # -- Marshall data -- #

    def generate_from_file rc_path
      taskrc = {}

      File.open(rc_path).each do |line|
        property = line_to_h(line) unless line.nil?
        taskrc.merge!(property) unless property.nil?
      end

      hash_to_model(taskrc)
    end

    # break "k.k.k"="v" into a Hash
    # [k_k_k: "v"}
    def line_to_h line
      line = line.chomp.split('=', 2)

      if line.size == 2
        attr = get_hash_attr_from_rc line[0]
        return { attr.to_sym => line[1] }
      else
        return nil
      end
    end

    # Turn a hash of attribute, value pairs into a TaskrcModel object
    def hash_to_model taskrc_hash
      taskrc_hash.each do |attr, value|
        add_model_attr(attr, value)
        set_model_attr_value(attr, value)
      end
      return config
    end

    # Serialize the given attrs model back to taskrc format
    # If attrs is nil, then default to all attributes
    def model_to_rc *attrs
      serial = []

      attrs.each do |attr|
        puts attr
        value = get_model_attr_value attr
        hash_attr = get_rc_attr_from_hash attr.to_s
        puts hash_attr, value
        serial = serial.push("#{hash_attr}=#{value}")
      end
      return serial
    end

    # Dynamically add a Virtus attr, detect Boolean, Integer, and Float types
    # based on the value, otherwise just treat it like a string.
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
