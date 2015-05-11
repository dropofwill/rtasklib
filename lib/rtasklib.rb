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
    attr_reader :version, :data_location, :taskrc, :create_new,
                :override, :override_a, :override_str

    include Controller

    DEFAULTS = {
      json_array:              'true',
      verbose:                 'nothing',
      confirmation:            'no',
      dependency_confirmation: 'no',
      exit_on_missing_db:      'yes', }

    LOWEST_VERSION = Gem::Version.new('2.4.0')

    def initialize data="#{Dir.home}/.task", override_h=DEFAULTS

      @data_location = data
      @override_h    = override_h.merge({data_location: data_location})
      @override      = Taskrc.new(DEFAULTS.merge(override_h), :hash)
      @override_str  = override.model_to_s
      @override_a    = override_str.split(" ")
      @config        = get_rc

      # Check TaskWarrior version, and throw warning if unavailable
      begin
        @version = check_version(get_version())
      rescue
        warn "Couldn't verify TaskWarrior's version"
      end
    end

    def check_version version
      if version < LOWEST_VERSION
        warn "The current TaskWarrior version, #{version}, is untested"
      end
      version
    end
  end
end
