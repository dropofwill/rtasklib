module Rtasklib

  class Rc
    attr_reader :rc

    def initialize rc="#{Dir.home}/.task"
      @rc = {}
      raw = []

      File.open(rc).each do |l|
        raw = to_a(l, raw)
      end

      @rc = raw.to_h
    end

    private
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
