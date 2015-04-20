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
                :override, :override_str, :create_new,  :taskrc

    include Controller

    DEFAULT_CONFIG = {
      json_array:              'true',
      verbose:                 'nothing',
      confirmation:            'no',
      dependency_confirmation: 'no',
      exit_on_missing_db:      'yes', }

    LOWEST_VERSION = Gem::Version.new('2.4.0')

    def initialize rc="#{Dir.home}/.taskrc", override_h=DEFAULT_CONFIG

      @rc_location   = Pathname.new(rc)
      @taskrc        = Rtasklib::Taskrc.new(rc_location)
      @data_location = taskrc.config.data_location
      override_h     = override_h.merge({data_location: data_location})
      @override      = Rtasklib::Taskrc.new(DEFAULT_CONFIG.merge(override_h))
      @override_str  = override.model_to_s

      # Check TaskWarrior version, and throw warning if unavailable
      begin
        @version = get_version
        check_version(version)
      rescue
        warn "Couldn't verify TaskWarrior's version"
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
