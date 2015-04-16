require "virtus"

module Rtasklib

  module Models
    # contents dynamically defined by what attributes are read from
    # `task config` or the given .taskrc
    class TaskrcModel
    end
  end

  class Taskrc
    attr_reader :config

    def initialize rc
      taskrc = []

      File.open(rc).each do |line|
        taskrc.push(process(line.chomp)) unless line.empty?
        # taskrc = to_a(l, taskrc)
      end
      puts taskrc.class

      # taskrc = taskrc.to_h
      # init_model taskrc
    end

    private

    def init_model rc_arr
      @config = Models::TaskrcModel.new
      @config.extend(Virtus.model)

      rc_arr.each do |k,v|
        if boolean? v
          @config.attribute k.to_sym, Axiom::Types::Boolean
        elsif integer? v
          @config.attribute k.to_sym, Integer
        elsif float? v
          @config.attribute k.to_sym, Float
        else
          @config.attribute k.to_sym, String
        end

        @config.send "#{k}=".to_sym, v
      end
    end

    #
    def to_a line, rc_arr
      line = process(line.chomp)
      rc_arr.push(line) unless line.empty?
      rc_arr
    end

    def process line
      line = line.split('=', 2)
      line[0].gsub!(".", "_") if line[0].respond_to? :gsub!
      line
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
