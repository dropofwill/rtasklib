# Copyright (c) 2015 Will Paul (whp3652@rit.edu)
# All rights reserved.
#
# This file is distributed under the MIT license. See LICENSE.txt for details.

require_relative "rtasklib/version"
require_relative "rtasklib/models"
require_relative "rtasklib/execute"
require_relative "rtasklib/controller"
require_relative "rtasklib/helpers"
require_relative "rtasklib/taskrc"

require "pathname"

# Top level namespace for all `rtasklib` functionality
module Rtasklib

  # To interact with the TaskWarrior database simply instantiate this with a
  # path to the .task folder where data is stored. If left out it will look
  # for a database in the default location `~/.task`
  #
  # Optionally pass in a hash of taskrc options to override what is in your
  # .taskrc on every command. By default `rtasklib` provides a set of sensible
  # defaults:
  #
  # @example
  #   # Use the default path and overrides
  #   tw = Rtasklib::TaskWarrior.new
  #   # TaskWarrior is also available aliased as TW:
  #   tw = Rtasklib::TW.new
  #   # Custom path, in this case the test db in spec/
  #   tw = Rtasklib::TW.new("./spec/data/.task")
  #   # Custom override, in this case calling the gc everytime
  #   # This will change id numbers whenever the task list changes
  #   # By default this is off, but may have some performance implications.
  #   tw = Rtasklib::TW.new(opts={gc: "on"})
  #
  # @example
  #   DEFAULTS = {
  #     json_array:              'true',
  #     verbose:                 'nothing',
  #     gc:                      'off',
  #     confirmation:            'no',
  #     dependency_confirmation: 'no',
  #     exit_on_missing_db:      'yes', }
  #
  # These of course can be overridden with opts param as well
  #
  # In general `rtasklib` is only feature complete on TaskWarrior installs 2.4
  # and greater and it will warn you if yours is lower or can't be determined,
  # but will still allow you to interact with it. Proceed at your own risk.
  #
  # @!attribute [r] version
  #   @return [Gem::Version] The version of the current TaskWarrior install
  # @!attribute [r] data_location
  #   @return [String] The file path that you passed in at initialization
  # @!attribute [r] taskrc
  #   @return [Rtasklib::Taskrc] Your current TaskWarrior configuration
  # @!attribute [r] udas
  #   @return [Hash{Symbol=>Hash}] Currently configured User Defined Attributes
  # @!attribute [r] override
  #   @return [Rtasklib::Taskrc] The options to override the default .taskrc
  # @!attribute [r] override_a
  #   @return [Array] override in array form, useful for passing to shell
  # @!attribute [r] override_str
  #   @return [String] override in string form, useful for passing to shell
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

    # @param data [String, Pathname] path to the .task database
    # @param opts [Hash] overrides to the .taskrc to run on each command
    # @api public
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

    # Check the state of the TaskWarrior install. Either pass a Gem::Version
    # representation passed to the version param or call with no args for
    # it to make a call to the shell to figure that out itself.
    #
    # @param version [Gem::Version, nil] version to check
    # @return [Gem::Version]
    # @api public
    def check_version version=nil
      version = get_version if version.nil?
      if version < LOWEST_VERSION
        warn "The current TaskWarrior version, #{version}, is untested"
      end
      version
    end
  end

  # Add a convenience alias to Rtasklib::TaskWarrior => Rtasklib:TW
  TW = TaskWarrior
end
