require_relative "rtasklib/version"
require_relative "rtasklib/models"
require_relative "rtasklib/execute"
require_relative "rtasklib/controller"
require_relative "rtasklib/serializer"
require_relative "rtasklib/taskrc"

require "open3"
require "pathname"

module Rtasklib

  class TaskWarrior
    attr_reader :taskrc, :version, :rc_location, :data_location,
                :override, :create_new, :config

    DEFAULT_CONFIG = {
      json: {
        array: 'true',
      },
      verbose: 'nothing',
      confirmation: 'no',
      dependency: {
        confirmation: 'no',
      },
    }

    def initialize rc="#{Dir.home}/.taskrc", data="#{Dir.home}/.task/",
                   override=DEFAULT_CONFIG, create_new=false
      @rc_location = Pathname.new(rc)
      @data_location = Pathname.new(data)
      @override = DEFAULT_CONFIG.merge(override)
      @create_new = create_new
      @config = Rtasklib::Taskrc.new(rc)

      # Check TW version, and throw warning
      # begin
      @version = check_version
      # rescue
      #   warn "Couldn't find the task version"
      # end
    end

    private
    def check_version
      raw_ver, retval = Rtasklib::Execute.task(@create_new,
                                           "rc.data.location=#{@data_location}",
                                           "_version")
      gem_ver = Gem::Version.new(raw_ver.chomp) if retval == 0

      if gem_ver < Gem::Version.new('2.4.0')
        warn "#{gem_ver} is untested"
      end
      gem_ver
    end
  end
end
