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
      # Check TW version, and throw warning
      @version = Gem::Version.new(`task _version`.chomp)

      if @version < Gem::Version.new('2.4.0')
        warn "#{@version} is untested"
      end

      # @taskrc =
    end
  end
end
