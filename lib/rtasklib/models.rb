require "virtus"
require "active_model"
require 'iso8601'
require 'date'

module Rtasklib::Models

  # A subclass of the ISO8601::Duration object that use `task calc` to parse
  # string names like 'weekly', 'biannual', and '3 quarters'
  #
  # Modifies the #initialize method, preserving the original string duration
  class TWDuration < ISO8601::Duration
    attr_accessor :negative
    attr_reader   :frozen_value

    def initialize input, base=nil
      @frozen_value = input.dup.freeze
      @negative = false
      parsed = `task calc #{input}`.chomp

      if parsed.include?("-")
        parsed.gsub!(/\-/, "")
        negative = true
      else
        negative = false
      end

      super parsed, base
    end
  end

  # Custom coercer to change a string input into an TWDuration object
  class VirtusDuration < Virtus::Attribute
    def coerce(v)
      if v.nil? || v.blank? then "" else TWDuration.new(v) end
    end
  end

  RcBooleans = Virtus.model do |mod|
    mod.coerce = true
    mod.coercer.config.string.boolean_map = {
      'yes' => true,  'on'  => true,
      'no'  => false, 'off' => false }
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
    attribute :recur,         VirtusDuration

    # Optional except for tasks with Recurring Parents
    attribute :due,           DateTime

    # Required only for tasks that have Recurring Child
    attribute :parent,        String

    # Internal attributes should be read-only
    attribute :mask,          String
    attribute :imask,         String
    attribute :modified,      DateTime

    # Refactoring idea, need to understand Virtus internals a bit better
    # [:mask, :imask, :modified, :status, :uuid, :entry].each do |ro_attr|
    #   define_method("set_#{ro_attr.to_s}") do |value|
    #     self.class.find_by(ro_attr).send(".=", value)
    #   end
    # end
  end
end
