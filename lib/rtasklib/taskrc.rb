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
      end
    end

    # -- Marshall data -- #

    def generate_from_file rc_path
      taskrc = {}

      File.open(rc_path).each do |line|
        property = line_to_h(line) unless line.nil?
        taskrc.merge!(property) unless property.nil?
      end

      setup_model(taskrc)
    end

    # break "k.k.k"="v" into a Hash
    # [k_k_k: "v"}
    def line_to_h line
      line = line.chomp.split('=', 2)

      if line.size == 2
        attr = line[0].gsub(".", "_") if line[0].respond_to? :gsub
        return { attr.to_sym => line[1] }
      else
        return nil
      end
    end

    # Turn a hash of attribute, value pairs into a TaskrcModel object
    def setup_model taskrc_hash
      taskrc_hash.each do |attr, value|
        add_model_attr(config, attr, value)
        set_model_attr_value(config, attr, value)
      end
    end

    # Dynamically add a Virtus attr, detect Boolean, Integer, and Float types
    # based on the value, otherwise just treat it like a string.
    # TODO: May also be able to detect arrays
    def add_model_attr model, attr, value
      if boolean? value
        model.attribute attr.to_sym, Axiom::Types::Boolean
      elsif integer? value
        model.attribute attr.to_sym, Integer
      elsif float? value
        model.attribute attr.to_sym, Float
      else
        model.attribute attr.to_sym, String
      end
    end

    def set_model_attr_value model, attr, value
      model.send("#{attr}=".to_sym, value)
    end

    # -- Unmarshall data -- #

    def model_to_h model, *props
    end

    def hash_to_s hash
    end

    private
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
