require_relative "rtasklib/version"
require_relative "rtasklib/models"
require_relative "rtasklib/execute"
require_relative "rtasklib/controller"
require_relative "rtasklib/serializer"
require_relative "rtasklib/taskrc"

# deprecated
require_relative "rtasklib/marshallable"

module Rtasklib

  class TaskWarrior
    attr_reader :taskrc, :version

    def initialize rc="#{Dir.home}/.taskrc"
      # Need to check TW version
      @version = `task _version`.chomp

      if Gem::Version.new(@version) < Gem::Version.new('2.4.0')
        warn "#{@version} is untested"
      end

      # @taskrc = 
    end
  end
end
