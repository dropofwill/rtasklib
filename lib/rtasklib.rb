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
                :override, :override_a,  :override_str, :create_new, :taskrc

    include Controller

    DEFAULTS = {
      json_array:              'false',
      verbose:                 'nothing',
      confirmation:            'no',
      dependency_confirmation: 'no',
      exit_on_missing_db:      'yes', }

    LOWEST_VERSION = Gem::Version.new('2.4.0')

    def initialize rc="#{Dir.home}/.taskrc", override_h=DEFAULTS

      @rc_location   = File.expand_path(rc)
      @taskrc        = Taskrc.new(rc_location)
      @data_location = File.expand_path(taskrc.config.data_location, Pathname.new(rc_location).dirname).to_s

      override_h     = override_h.merge({data_location: data_location})
      @override      = Taskrc.new(DEFAULTS.merge(override_h))
      @override_str  = override.model_to_s
      @override_a    = override_str.split(" ")

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
