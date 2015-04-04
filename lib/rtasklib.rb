require_relative "rtasklib/version"
require_relative "rtasklib/models"
require_relative "rtasklib/execute"
require_relative "rtasklib/controller"
require_relative "rtasklib/serializer"
require_relative "rtasklib/taskrc"

require "open3"

module Rtasklib

  class TaskWarrior
    attr_reader :taskrc, :version, :rc_location, :data_location, :override

    DEFAULT_CONFIG = {
      json: {
        array: "true",
      },
      verbose: 'nothing',
      confirmation: 'no',
      dependency: {
        confirmation: 'no',
      },
    }

    def initialize rc="#{Dir.home}/.taskrc", override=DEFAULT_CONFIG,
                   create_new=false
      @rc_location = rc
      # TODO: use taskrc
      @data_location = rc.chomp('rc')
      puts @data_location
      @override = DEFAULT_CONFIG.merge(override)

      # Check TW version, and throw warning
      begin
        @version = check_version
      rescue
        warn "Couldn't find the task version"
      end

      # @taskrc =
    end

    private
    def check_version
      raw_version = Open3.capture2(
        "task rc.data.location=#{@data_location} _version")
      gem_version = Gem::Version.new(raw_version[0].chomp)

      if gem_version < Gem::Version.new('2.4.0')
        warn "#{@version} is untested"
      end
      gem_version
    end
  end
end
