require_relative "rtasklib/version"
require_relative "rtasklib/models"
require_relative "rtasklib/execute"
require_relative "rtasklib/controller"
require_relative "rtasklib/serializer"
require_relative "rtasklib/rc"

# deprecated
require_relative "rtasklib/marshallable"

module Rtasklib

  class TaskWarrior

    def initialize rc="#{Dir.home}/.taskrc"

    end
  end
end
