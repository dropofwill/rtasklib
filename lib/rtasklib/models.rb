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
    attribute :mask,          String, writer: :private
    attribute :imask,         String, writer: :private
    attribute :modified,      String, writer: :private

    # TODO: handle arbitrary UDA's

    # Setters for private attributes
    def set_mask value; self.mask = value end
    def set_imask value; self.imask = value end
    def set_modified value; self.modified = value end
    def set_status value; self.status = value end
    def set_uuid value; self.uuid = value end
    def set_date value; self.date = value end

    # Refactoring idea, need to understand Virtus internals a bit better
    # [:mask, :imask, :modified, :status, :uuid, :entry].each do |ro_attr|
    #   define_method("set_#{ro_attr.to_s}") do |value|
    #     self.class.find_by(ro_attr).send(".=", value)
    #   end
    # end
  end
end
