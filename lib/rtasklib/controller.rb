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
      all = []
      Execute.task_popen3(*@override_a, "export") do |i, o, e, t|
        all = MultiJson.load(o.read).map do |x|
          Rtasklib::Models::TaskModel.new(x)
        end
      end
      return all
    end

    def get_rc
      res = []
      Execute.task_popen3(*@override_a, "_show") do |i, o, e, t|
        o.read.each_line { |l| res.push(l.chomp) }
      end
      Taskrc.new(res, :array)
    end

    def get_version
      version = nil
      Execute.task_popen3(*@override_a, "_version") do |i, o, e, t|
        version = to_gem_version(o.read.chomp)
      end
      return version
    end

    # Convert "1.6.2 (adf342jsd)" to Gem::Version object
    def to_gem_version raw
      std_ver = raw.chomp.gsub(' ','.').delete('(').delete(')')
      Gem::Version.new std_ver
    end
  end
end
