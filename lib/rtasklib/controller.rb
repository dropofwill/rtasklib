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
      raw, ec = Execute.task(@override_str, "_show")
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

    def handle_response raw, ec
    end
  end
end
