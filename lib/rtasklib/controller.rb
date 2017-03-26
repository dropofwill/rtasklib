# Copyright (c) 2015 Will Paul (whp3652@rit.edu)
# All rights reserved.
#
# This file is distributed under the MIT license. See LICENSE.txt for details.

require "multi_json"

module Rtasklib

  # Accessed through the main TW, which includes this module, e.g. `tw.all`
  #
  # This module contains the public, user-facing methods.
  #
  # By convention bang methods modify the task database, and non-bang read
  # from the database, e.g. `Controller#all` vs `Controller#modify!`
  #
  # Most methods accept filtering in the form of ids, tags, and dom
  #
  # Changes to the config are not effected by #undo!
  #
  # XXX: depends on TaskWarrior#override_a currently, which isn't great.
  #
  # @example ids: can be a single id as a String or Integer or Range
  #   tw.some(ids: 1)
  #   tw.some(ids: "1")
  #   tw.some(ids: 1..4)  # 1,2,3,4
  #   tw.some(ids: 1...4) # 1,2,3
  #
  # @example ids: can be an array of mixed types
  #   tw.some(ids: [1,2,4...10,"12"])
  #
  # @example ids: can be a TaskWarrior formatted string
  #   tw.some(ids: "1-3,10")
  #
  # @example tags: can be a single string
  #   tw.some(tags: "work") # converted to +work
  #   tw.some(tags: "-work")
  #
  # @example tags: can be an array and include relational operators
  #   tw.some(tags: ["work", "and", "-fun"])
  #
  # @example tags: work with TaskWarrior built-in virtual tags http://taskwarrior.org/docs/tags.html
  #   tw.some(tags: "+TODAY")
  #
  # @example dom: work as hashes
  #   require "date"
  #   today = DateTime.now
  #   tw.some(dom: {project: "Work", "due.before" => today})
  #
  # @example You can also pass in a TW style string if you prefer
  #   tw.some(dom: "project:Work due.before:#{today}")
  #
  module Controller
    extend self

    # Retrieves the current task list from the TaskWarrior database. Defaults
    # to just show active (waiting & pending) tasks, which is usually what is
    # exposed to the end user through the default reports. To see everything
    # including completed, deleted, and parent recurring tasks, set
    # `active: false`. For more granular control see Controller#some.
    #
    # @example
    #   tw.all.count #=> 200
    #   tw.all(active: true) #=> 200
    #   tw.all(active: false) #=> 578
    #
    # @param active [Boolean] return only pending & waiting tasks
    # @return [Array<Models::TaskModel>]
    # @api public
    def all active: true
      all = []
      f = Helpers.pending_or_waiting(active)
      Execute.task_popen3(*override_a, f, "export") do |i, o, e, t|
        all = MultiJson.load(o.read).map do |x|
          Rtasklib::Models::TaskModel.new(x)
        end
      end
      return all
    end

    # Retrieves the current task list filtered by id, tag, or a dom query
    #
    # @example filter by an array of ids
    #   tw.some(ids: [1..2, 5])
    # @example filter by tags
    #   tw.some(tags: ["+school", "or", "-work"]
    #   # You can also pass in a TW style string if you prefer
    #   tw.some(tags: "+school or -work"]
    # @example filter by a dom query
    #   require "date"
    #   today = DateTime.now
    #   # note that queries with dots need to be Strings, as they would be
    #   # invalid Symbols
    #   tw.some(dom: {project: "Work", "due.before" => today})
    #   # You can also pass in a TW style string if you prefer
    #   tw.some(dom: "project:Work due.before:#{today}")
    #
    # @param ids [Array<Range, Integer, String>, String, Range, Integer]
    # @param tags [Array<String>, String]
    # @param dom [Array<String>, String]
    # @param active [Boolean] return only pending & waiting tasks
    # @return [Array<Models::TaskModel>]
    # @api public
    def some ids: nil, tags: nil, dom: nil, active: true
      some = []
      f = Helpers.filter(ids: ids, tags: tags, dom: dom)
      a = Helpers.pending_or_waiting(active)
      Execute.task_popen3(*@override_a, f, a, "export") do |i, o, e, t|
        some = MultiJson.load(o.read).map do |x|
          Rtasklib::Models::TaskModel.new(x)
        end
      end
      return some
    end

    # Count the number of tasks that match a given filter. Faster than counting
    # an array returned by Controller#all or Controller#some.
    #
    # @param ids [Array<Range, Integer, String>, String, Range, Integer]
    # @param tags [Array<String>, String]
    # @param dom [Array<String>, String]
    # @param active [Boolean] return only pending & waiting tasks
    # @api public
    def count ids: nil, tags: nil, dom: nil, active: true
      f = Helpers.filter(ids: ids, tags: tags, dom: dom)
      a = Helpers.pending_or_waiting(active)
      Execute.task_popen3(*@override_a, f, a, "count") do |i, o, e, t|
        return Integer(o.read)
      end
    end
    alias_method :size,   :count
    alias_method :length, :count

    # Calls `task _show` with initial overrides returns a Taskrc object of the
    # result
    #
    # @return [Rtasklib::Taskrc]
    # @api public
    def get_rc
      res = []
      Execute.task_popen3(*@override_a, "_show") do |i, o, e, t|
        res = o.read.each_line.map { |l| l.chomp }
      end
      Taskrc.new(res, :array)
    end

    # Calls `task _version` and returns the result
    #
    # @return [String]
    # @api public
    def get_version
      version = nil
      Execute.task_popen3("_version") do |i, o, e, t|
        version = Helpers.to_gem_version(o.read.chomp)
      end
      version
    end

    # Mark the filter of tasks as started
    # Returns false if filter (ids:, tags:, dom:) is blank.
    #
    # @example
    #   tw.start!(ids: 1)
    #
    # @param ids [Array<Range, Integer, String>, String, Range, Integer]
    # @param tags [Array<String>, String]
    # @param dom [Array<String>, String]
    # @param active [Boolean] return only pending & waiting tasks
    # @return [Process::Status, False] the exit status of the thread or false
    #   if it exited early because filter was blank.
    # @api public
    def start! ids: nil, tags: nil, dom: nil, active: true
      f = Helpers.filter(ids: ids, tags: tags, dom: dom)
      a = Helpers.pending_or_waiting(active)
      return false if f.blank?

      Execute.task_popen3(*@override_a, f, a, "start") do |i, o, e, t|
        return t.value
      end
    end

    # Mark the filter of tasks as stopped
    # Returns false if filter (ids:, tags:, dom:) is blank.
    #
    # @param ids [Array<Range, Integer, String>, String, Range, Integer]
    # @param tags [Array<String>, String]
    # @param dom [Array<String>, String]
    # @param active [Boolean] return only pending & waiting tasks
    # @return [Process::Status, False] the exit status of the thread or false
    #   if it exited early because filter was blank.
    # @api public
    def stop! ids: nil, tags: nil, dom: nil, active: true
      f = Helpers.filter(ids: ids, tags: tags, dom: dom)
      a = Helpers.pending_or_waiting(active)
      return false if f.blank?

      Execute.task_popen3(*@override_a, f, a, "stop") do |i, o, e, t|
        return t.value
      end
    end

    # Add a single task to the database w/required description and optional
    # tags and dom queries (e.g. project:Work)
    #
    # @param description [String] the required desc of the task
    # @param tags [Array<String>, String]
    # @param dom [Array<String>, String]
    # @return [Process::Status] the exit status of the thread
    # @api public
    def add! description, tags: nil, dom: nil
      f = Helpers.filter(tags: tags, dom: dom)
      d = Helpers.wrap_string(description)
      Execute.task_popen3(*override_a, "add", d, f) do |i, o, e, t|
        return t.value
      end
    end

    # Modify a set of task the match the input filter with a single attr/value
    # pair.
    # Returns false if filter (ids:, tags:, dom:) is blank.
    #
    # @param attr [String]
    # @param val [String]
    # @param ids [Array<Range, Integer, String>, String, Range, Integer]
    # @param tags [Array<String>, String]
    # @param dom [Array<String>, String]
    # @param active [Boolean] return only pending & waiting tasks
    # @return [Process::Status] the exit status of the thread
    # @api public
    def modify! attr, val, ids: nil, tags: nil, dom: nil, active: true
      f = Helpers.filter(ids: ids, tags: tags, dom: dom)
      a = Helpers.pending_or_waiting(active)
      return false if f.blank?

      query = "#{f} #{a} modify #{attr}:#{val}"
      Execute.task_popen3(*override_a, query) do |i, o, e, t|
        return t.value
      end
    end

    # Finishes the filtered tasks.
    # Returns false if filter (ids:, tags:, dom:) is blank.
    #
    # @param ids [Array<Range, Integer, String>, String, Range, Integer]
    # @param tags [Array<String>, String]
    # @param dom [Array<String>, String]
    # @param active [Boolean] return only pending & waiting tasks
    # @return [Process::Status] the exit status of the thread
    # @api public
    def done! ids: nil, tags: nil, dom: nil, active: true
      f = Helpers.filter(ids: ids, tags: tags, dom: dom)
      a = Helpers.pending_or_waiting(active)
      return false if f.blank?

      Execute.task_popen3(*override_a, f, a, "done") do |i, o, e, t|
        return t.value
      end
    end

    # Returns false if filter is blank.
    #
    # @param ids [Array<Range, Integer, String>, String, Range, Integer]
    # @param tags [Array<String>, String]
    # @param dom [Array<String>, String]
    # @param active [Boolean] return only pending & waiting tasks
    # @return [Process::Status] the exit status of the thread
    # @api public
    def delete! ids: nil, tags: nil, dom: nil, active: true
      f = Helpers.filter(ids: ids, tags: tags, dom: dom)
      a = Helpers.pending_or_waiting(active)
      return false if f.blank?

      Execute.task_popen3(*override_a, f, a, "delete") do |i, o, e, t|
        return t.value
      end
    end

    # Directly call `task undo`, which only applies to edits to the task db
    # not configuration changes
    #
    # @api public
    def undo!
      Execute.task_popen3(*override_a, "undo") do |i, o, e, t|
        return t.value
      end
    end

    # Retrieves a hash of hashes with info about the UDAs currently available
    #
    # @return [Hash{Symbol=>Hash}]
    # @api public
    def get_udas
      udas = {}
      taskrc.config.attributes
        .select { |attr, val| Helpers.uda_attr? attr }
        .sort
        .chunk  { |attr, val| Helpers.arbitrary_attr attr }
        .each do |attr, arr|
          uda = arr.map do |pair|
            [Helpers.deep_attr(pair[0]), pair[1]]
          end
          udas[attr.to_sym] = Hash[uda]
        end
        return udas
    end

    # Update a configuration variable in the .taskrc
    #
    # @param attr [String]
    # @param val [String]
    # @return [Process::Status] the exit status of the thread
    # @api public
    def update_config! attr, val
      Execute.task_popen3(*override_a, "config #{attr} #{val}") do |i, o, e, t|
        return t.value
      end
    end

    # Add new found udas to our internal TaskModel
    #
    # @param uda_hash [Hash{Symbol=>Hash}]
    # @param type [Class, nil]
    # @param model [Models::TaskModel, Class]
    # @api protected
    def add_udas_to_model! uda_hash, type=nil, model=Models::TaskModel
      uda_hash.each do |attr, val|
        val.each do |k, v|
          type = Helpers.determine_type(v) if type.nil?
          model.attribute attr, type
        end
      end
    end
    protected :add_udas_to_model!

    # Retrieve an array of the uda names
    #
    # @return [Array<String>]
    # @api public
    def get_uda_names
      Execute.task_popen3(*@override_a, "_udas") do |i, o, e, t|
        return o.read.each_line.map { |l| l.chomp }
      end
    end

    # Checks if a given uda exists in the current task database
    #
    # @param uda_name [String] the uda name to check for
    # @return [Boolean] whether it matches or not
    # @api public
    def uda_exists? uda_name
      if get_udas.any? { |uda| uda == uda_name }
        true
      else
        false
      end
    end

    # Add a UDA to the users config/database
    #
    # @param name [String]
    # @param type [String]
    # @param label [String]
    # @param values [String]
    # @param default [String]
    # @param urgency [String]
    # @return [Boolean] success
    # @api public
    def create_uda! name, type: "string", label: nil, values: nil,
                   default: nil, urgency: nil
      label = name if label.nil?

      update_config("uda.#{name}.type",  type)
      update_config("uda.#{name}.label", label)
      update_config("uda.#{name}.values",  values)  unless values.nil?
      update_config("uda.#{name}.default", default) unless default.nil?
      update_config("uda.#{name}.urgency", urgency) unless urgency.nil?
    end

    # Sync the local TaskWarrior database changes to the remote databases.
    # Remotes need to be configured in the .taskrc.
    #
    # @example
    #   # make some local changes with add!, modify!, or the like
    #   tw.sync!
    #
    # @return [Process::Status] the exit status of the thread
    # @api public
    def sync!
      Execute.task_popen3(*override_a, "sync") do |i, o, e, t|
        return t.value
      end
    end

    # TODO: implement and test convenience methods for modifying tasks
    #
    # def annotate
    # end
    #
    # def denotate
    # end
    #
    # def append
    # end
    #
    # def prepend
    # end
  end
end
