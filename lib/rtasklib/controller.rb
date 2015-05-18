require "multi_json"

module Rtasklib

  # Accessed through the main TW, which includes this module, e.g. `tw.all`
  #
  # Ideally should only be the well documented public, user-facing methods.
  # We're getting there.
  #
  # By convention bang methods modify the task database, and non-bang read
  # from the database, e.g. `Controller#all` vs `Controller#modify!`
  #
  # XXX: depends on @override_a currently, which isn't great.
  module Controller
    extend self

    # Retrieves the current task list from the TW database
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
    #
    # @param ids [Array<Range, Fixnum, String>, String, Range, Fixnum]
    # @param tags [Array<String>, String]
    # @param dom [Array<String>, String]
    # @return [Array<Models::TaskModel>]
    # @api public
    def some ids: nil, tags: nil, dom: nil
      some = []
      f = Helpers.filter(ids: ids, tags: tags, dom: dom)
      Execute.task_popen3(*@override_a, f, "export") do |i, o, e, t|
        some = MultiJson.load(o.read).map do |x|
          Rtasklib::Models::TaskModel.new(x)
        end
      end
      return some
    end

    # Add a single task to the database
    #
    # @param ids [Array<Range, Fixnum, String>, String, Range, Fixnum]
    # @param tags [Array<String>, String]
    # @param dom [Array<String>, String]
    # @api public
    def count ids: nil, tags: nil, dom: nil
      f = Helpers.filter(ids: ids, tags: tags, dom: dom)
      Execute.task_popen3(*@override_a, f, "count") do |i, o, e, t|
        return Integer(o.read)
      end
    end
    alias_method :size,   :count
    alias_method :length, :count

    # Calls `task _show` with initial overrides returns a Taskrc object of the
    # result
    #
    # @return [Taskrc]
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
    # @api public
    def start! ids: nil, tags: nil, dom: nil
      f = Helpers.filter(ids: ids, tags: tags, dom: dom)
      return false if f.blank?

      Execute.task_popen3(*@override_a, f, "start") do |i, o, e, t|
        return t.value
      end
    end

    # Mark the filter of tasks as stopped
    # Returns false if filter (ids:, tags:, dom:) is blank.
    #
    # @api public
    def stop! ids: nil, tags: nil, dom: nil
      f = Helpers.filter(ids: ids, tags: tags, dom: dom)
      return false if f.blank?

      Execute.task_popen3(*@override_a, f, "stop") do |i, o, e, t|
        return t.value
      end
    end

    # Add a single task to the database w/required description and optional
    # tags and dom queries (e.g. project:Work)
    #
    # @param description [String] the required desc of the task
    # @param tags [Array<String>, String]
    # @param dom [Array<String>, String]
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
    # @param ids [Array<Range, Fixnum, String>, String, Range, Fixnum]
    # @param tags [Array<String>, String]
    # @param dom [Array<String>, String]
    # @api public
    def modify! attr, val, ids: nil, tags: nil, dom: nil
      f = Helpers.filter(ids: ids, tags: tags, dom: dom)
      return false if f.blank?

      query = "#{f} modify #{attr} #{val}"
      Execute.task_popen3(*override_a, query) do |i, o, e, t|
        return t.value
      end
    end

    # Finishes the filtered tasks
    # Returns false if filter (ids:, tags:, dom:) is blank.
    #
    # @param ids [Array<Range, Fixnum, String>, String, Range, Fixnum]
    # @param tags [Array<String>, String]
    # @param dom [Array<String>, String]
    # @api public
    def done! ids: nil, tags: nil, dom: nil
      f = Helpers.filter(ids: ids, tags: tags, dom: dom)
      return false if f.blank?

      Execute.task_popen3(*override_a, f, "done") do |i, o, e, t|
        return t.value
      end
    end

    # Returns false if filter is blank.
    #
    # @param ids [Array<Range, Fixnum, String>, String, Range, Fixnum]
    # @param tags [Array<String>, String]
    # @param dom [Array<String>, String]
    # @api public
    def delete! ids: nil, tags: nil, dom: nil
      f = Helpers.filter(ids: ids, tags: tags, dom: dom)
      return false if f.blank?

      Execute.task_popen3(*override_a, f, "delete") do |i, o, e, t|
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
