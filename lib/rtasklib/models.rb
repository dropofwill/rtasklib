require "virtus"
require "active_model"

module Rtasklib::Models
  ValidationError = Class.new RuntimeError

  class UUID < Virtus::Attribute
    def coerce(value)
      value.to_s
    end
  end

  RcBooleans = Virtus.model do |mod|
    mod.coerce = true
    mod.coercer.config.string.boolean_map = {
      'no'  => false,
      'yes' => true,
      'on'  => true,
      'off' => false }
  end

  class TaskrcModel
    # A base Virtus model whose attributes are created dynamically based on the
    # given attributes are read from a .taskrc or Hash
    #
    # Dynamically add convert Boolean Strings to Ruby's Boolean values
    include RcBooleans
  end

  class TaskModel
    include Virtus.model
    # perhaps use Veto
    # include ActiveModel::Validations

    # Default attributes from TW
    # Should match: http://taskwarrior.org/docs/design/task.html
    #
    # Required for every task
    attribute :description,   String
    # But on creation these should be set by `task`
    attribute :status,        String
    attribute :uuid,          String
    attribute :entry,         DateTime

    # Optional for every task
    attribute :start,         DateTime
    attribute :until,         DateTime
    attribute :scheduled,     DateTime
    attribute :annotation,    Array[String]
    attribute :tags,          Array[String]
    attribute :project,       String
    attribute :depends,       String
    attribute :urgency,       Float
    # is calculated, so maybe private?
    attribute :priority,      String

    # Required only for tasks that are Deleted or Completed
    attribute :end,           DateTime

    # Required only for tasks that are Waiting
    attribute :wait,          DateTime

    # Required only for tasks that are Recurring or have Recurring Parent
    attribute :recur,         DateTime

    # Optional except for tasks with Recurring Parents
    attribute :due,           DateTime

    # Required only for tasks that have Recurring Child
    attribute :parent,        String

    # Internal attributes should be read-only
    attribute :mask,          String
    attribute :imask,         String
    attribute :modified,      DateTime

    # TODO: handle arbitrary UDA's

    # Refactoring idea, need to understand Virtus internals a bit better
    # [:mask, :imask, :modified, :status, :uuid, :entry].each do |ro_attr|
    #   define_method("set_#{ro_attr.to_s}") do |value|
    #     self.class.find_by(ro_attr).send(".=", value)
    #   end
    # end
  end
end
