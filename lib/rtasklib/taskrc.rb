require "virtus"

module Rtasklib

  class TaskrcModel
  end

  class Taskrc
    attr_reader :raw
    attr_accessor :config

    def initialize rc="#{Dir.home}/.taskrc"
      @raw = []

      File.open(rc).each do |l|
        @raw = to_a(l, @raw)
      end

      @raw = @raw.to_h
      init_model raw
    end

    private

    def init_model raw
      # config = Rtasklib::Models::Taskrc.new
      @config = TaskrcModel.new
      @config.extend(Virtus.model)

      raw.each do |k,v|
        if ["on", "off", "yes", "no", "false", "true"].include? v.downcase
          @config.attribute k.to_sym, Axiom::Types::Boolean
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
  end
end
