require "virtus"
require "active_model"

module Rtasklib::Models

  ValidationError = Class.new RuntimeError

  class UUID < Virtus::Attribute
    def coerce(value)
      value
    end
  end

  class Task
    include Virtus.model(finalize: false)
    # perhaps use Veto
    include ActiveModel::Validations

    # Default attributes from TW
    # Should match: http://taskwarrior.org/docs/design/task.html
    #
    # Required for every task
    attribute :description,   String
    # But on creation these should be set by `task`
    attribute :status,        String, writer: :private
    attribute :uuid,          UUID,   writer: :private
    attribute :entry,         Date,   writer: :private

    # Optional for every task
    attribute :start,         Date
    attribute :until,         Date
    attribute :scheduled,     Date
    attribute :annotation,    Array[String]
    attribute :tags,          Array[String]
    attribute :project,       String
    attribute :depends,       String
    # is calculated, so maybe private?
    attribute :priority,      String
    # Required only for tasks that are Deleted or Completed
    attribute :end,           Date
    # Required only for tasks that are Waiting
    attribute :wait,          Date
    # Required only for tasks that are Recurring or have Recurring Parent
    attribute :recur,         Date
    # Optional except for tasks with Recurring Parents
    attribute :due,           Date
    # Required only for tasks that have Recurring Child
    attribute :parent,        UUID
    # Internal attributes should be read-only
    attribute :mask,          String
    attribute :imask,         String
    attribute :modified,      String

    # TODO: handle arbitrary UDA's
  end

  Virtus.finalize
end
