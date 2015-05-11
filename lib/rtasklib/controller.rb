require "multi_json"
require "oj"

module Rtasklib

  module Controller
    extend self

    def create
    end

    def update
    end

    def get
    end

    def all
      res, ec = Execute.each_popen3("task", *@override_a, "export")
      mj = res.map { |x| MultiJson.load(x) }
      p mj
      mm = mj.map { |x| Rtasklib::Models::TaskModel.new(x) }
    end

    def get_rc
      res = []
      Execute.task_popen3("task", *@override_a, "_show") do |i, o, e, t|
        ec = t.value
        handle_response(e, ec)
        o.read.each_line { |l| res.push(l.chomp) }
      end
      Taskrc.new(res, :array)
    end

    def get_version
      raw, ec = Execute.task(@override_str, "_version")
      if ec == 0
        return to_gem_version(raw)
      else
        return nil
      end
    end

    # Convert "1.6.2 (adf342jsd)" to Gem::Version object
    def to_gem_version raw
      std_ver = raw.chomp.gsub(' ','.').delete('(').delete(')')
      p std_ver
      Gem::Version.new std_ver
    end

    def handle_response stderr, ec, block=nil
      block.call unless block.nil?
      unless ec == 0
        puts stderr.read
        exit(-1)
      end
    end
  end
end
