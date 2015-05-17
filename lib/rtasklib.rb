require_relative "rtasklib/version"
require_relative "rtasklib/models"
require_relative "rtasklib/execute"
require_relative "rtasklib/controller"
require_relative "rtasklib/helpers"
require_relative "rtasklib/taskrc"

require "pathname"

module Rtasklib

  class TaskWarrior
    attr_reader :version, :data_location, :taskrc, :udas,
                :override, :override_a, :override_str

    include Controller

    DEFAULTS = {
      json_array:              'true',
      verbose:                 'nothing',
      gc:                      'off',
      confirmation:            'no',
      dependency_confirmation: 'no',
      exit_on_missing_db:      'yes', }

    LOWEST_VERSION = Gem::Version.new('2.4.0')

    def initialize data="#{Dir.home}/.task", opts = {}
      # Check TaskWarrior version, and throw warning if unavailable
      begin
        @version = check_version
      rescue
        warn "Couldn't verify TaskWarrior's version"
      end

      @data_location = data
      override_h     = DEFAULTS.merge({data_location: data}).merge(opts)
      @override      = Taskrc.new(override_h, :hash)
      @override_a    = override.model_to_rc
      @taskrc        = get_rc
      @udas          = get_udas
      add_udas_to_model!(udas) unless udas.nil?
    end

    def check_version version=nil
      version = get_version if version.nil?
      if version < LOWEST_VERSION
        warn "The current TaskWarrior version, #{version}, is untested"
      end
      version
    end
  end

  # Add a convenience alias
  TW = TaskWarrior
end
