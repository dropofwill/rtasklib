require "virtus"

module Rtasklib

  module Models
    class TaskrcModel
    end
  end

  class Taskrc
    attr_reader :config

    def initialize rc="#{Dir.home}/.taskrc"
      raw = []

      File.open(rc).each do |l|
        raw = to_a(l, raw)
      end

      raw = raw.to_h
      init_model raw
    end

    private

    def init_model raw
      @config = Models::TaskrcModel.new
      @config.extend(Virtus.model)

      raw.each do |k,v|
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

    def to_a l, raw
      line = process(l.chomp)
      raw.push(line) unless line.empty?
      raw
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
