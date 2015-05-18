# Copyright (c) 2015 Will Paul (whp3652@rit.edu)
# All rights reserved.
#
# This file is distributed under the MIT license. See LICENSE.txt for details.

require "virtus"
require 'iso8601'
require 'date'

module Rtasklib::Models

  # A subclass of the ISO8601::Duration object that use `task calc` to parse
  # string names like 'weekly', 'biannual', and '3 quarters'
  #
  # Modifies the #initialize method, preserving the original string duration
  class TWDuration < ISO8601::Duration
    attr_reader :frozen_value

    def initialize input, base=nil
      @frozen_value = input.dup.freeze
      parsed = `task calc #{input}`.chomp

      super parsed, base
    end
  end

  # Custom coercer that changes a string input into an TWDuration object
  # If nil? or blank? it returns nil
  # 
  # Modifies the #coerce method.
  class VirtusDuration < Virtus::Attribute
    # @param [Object] any value that we are trying to coerce, probably String
    # @return [TWDuration, nil]
    def coerce(v)
      if v.nil? || v.blank? then nil else TWDuration.new(v) end
    end
  end

  # Allows us to treat the strings "on", "off", "no", "yes" as Booleans,
  # Which is how TaskWarrior does it.
  RcBooleans = Virtus.model do |mod|
    mod.coerce = true
    mod.coercer.config.string.boolean_map = {
      'yes' => true,  'on'  => true,
      'no'  => false, 'off' => false }
  end

  # A base Virtus model whose attributes are created dynamically based on the
  # given attributes are read from a .taskrc or Hash
  #
  # attr_accessors are available for all attributes, and more can be added
  # See Rtasklib::Controller for methods to do this
  class TaskrcModel
    # Dynamically add attrs that use Boolean Strings to Ruby's Boolean values
    include RcBooleans
  end

  # Defines a Virtus model for a single task, defining the data types for all
  # the default attributes
  #
  class TaskModel
    include Virtus.model
    # TODO: perhaps use Veto to validate these, if we ever implement mutable
    # changes, e.g. task_model.save!

    # Default attributes from TW
    # Should match: http://taskwarrior.org/docs/design/task.html
    #
    # Required for every task
    attribute :description,   String
    # But on creation these should be set by `task`
    attribute :status,        String
    attribute :uuid,          String
    attribute :id,            Fixnum
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
