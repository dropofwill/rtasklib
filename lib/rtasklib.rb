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
    attr_reader :version,  :rc_location, :data_location,
                :override, :create_new,  :config

    include Controller

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

    LOWEST_VERSION = Gem::Version.new('2.4.0')

    def initialize rc="#{Dir.home}/.taskrc", data="#{Dir.home}/.task/",
                   override=DEFAULT_CONFIG,  create_new=false
      @rc_location   = Pathname.new(rc)
      @data_location = Pathname.new(data)
      @override      = DEFAULT_CONFIG.merge(override)
      @config        = Rtasklib::Taskrc.new(rc_location)
      @create_new    = create_new

      # Check TaskWarrior version, and throw warning
      begin
        @version = get_version
        check_version(version)
      rescue
        warn "Couldn't find TaskWarrior's version"
        @version = nil
      end
    end

    def check_version version
      if version < LOWEST_VERSION
        warn "The current TaskWarrior version, #{version}, is untested"
      end
    end

  end
end
