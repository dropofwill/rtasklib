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

    def initialize rc
      @config = Models::TaskrcModel.new().extend(Virtus.model)
      taskrc = {}

      File.open(rc).each do |line|
        property = line_to_h(line) unless line.nil?
        taskrc.merge!(property) unless property.nil?
      end

      add_to_model(taskrc)
    end

    private
    def add_to_model rc_arr
      rc_arr.each do |k,v|
        if boolean? v
          config.attribute k.to_sym, Axiom::Types::Boolean
        elsif integer? v
          config.attribute k.to_sym, Integer
        elsif float? v
          config.attribute k.to_sym, Float
        else
          config.attribute k.to_sym, String
        end

        config.send "#{k}=".to_sym, v
      end
    end

    # break "k.k.k"="v" into a Hash
    # [k_k_k: "v"}
    def line_to_h line
      line = line.chomp.split('=', 2)

      if line.size == 2
        line[0].gsub!(".", "_") if line[0].respond_to? :gsub!
        return { line[0].to_sym => line[1] }
      else
        return nil
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
