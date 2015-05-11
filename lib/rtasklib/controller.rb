require "multi_json"
require "oj"

module Rtasklib

  module Controller
    extend self

    def all
      all = []
      Execute.task_popen3(*@override_a, "export") do |i, o, e, t|
        all = MultiJson.load(o.read).map do |x|
          Rtasklib::Models::TaskModel.new(x)
        end
      end
      all
    end

    def update_config attr, val
      Execute.task_popen3(*override_a, "config #{attr} #{val}") do |i, o, e, t|
        return t.value
      end
    end

    def get_udas
      Execute.task_popen3(*@override_a, "_udas") do |i, o, e, t|
        return o.read.each_line.map { |l| l.chomp }
      end
    end

    # Checks if a given uda exists in the current task database
    #
    #
    def check_uda uda_name
      if get_udas.any? { |uda| uda == uda_name }
        true
      else
        false
      end
    end

    def create_uda name, label: nil, values: nil, default: nil, urgency: nil
      label = name if label.nil?
      p name, label, values, default, urgency
    end

    def get_rc
      res = []
      Execute.task_popen3(*@override_a, "_show") do |i, o, e, t|
        res = o.read.each_line.map { |l| l.chomp }
      end
      Taskrc.new(res, :array)
    end

    def get_version
      version = nil
      Execute.task_popen3(*@override_a, "_version") do |i, o, e, t|
        version = to_gem_version(o.read.chomp)
      end
      version
    end

    # Convert "1.6.2 (adf342jsd)" to Gem::Version object
    def to_gem_version raw
      std_ver = raw.chomp.gsub(' ','.').delete('(').delete(')')
      Gem::Version.new std_ver
    end
  end
end
