require "multi_json"
require "oj"

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
    # @return [Array<Models::TaskModel>]
    # @api public
    def all
      all = []
      Execute.task_popen3(*@override_a, "export") do |i, o, e, t|
        all = MultiJson.load(o.read).map do |x|
          Rtasklib::Models::TaskModel.new(x)
        end
      end
      all
    end

    # Converts ids, tags, and dom queries to a single string ready to pass
    # directly to task.
    #
    # @param ids[Range, Array<String>, String, Fixnum]
    # @param tags[String, Array<String>]
    # @param dom[String, Array<String>]
    # @return [String] "#{id_s} #{tag_s} #{dom_s}"
    # @api private
    def filter ids: nil, tags: nil, dom: nil
      id_s = tag_s = dom_s = ""
      ids  = process_ids(ids)   unless ids.nil?
      tags = process_tags(tags) unless tags.nil?
      dom  = process_dom(dom)   unless dom.nil?
      return "#{id_s} #{tag_s} #{dom_s}"
    end
    private :filter

    # Converts arbitrary id input to a task safe string
    #
    # @param ids[Range, Array<String>, String, Fixnum]
    # @api private
    def process_ids ids
      case ids
      when Range
        id_range_to_s(ids)
      when Array
        ids.join(",")
      when String
        ids.delete(" ")
      when Fixnum
        ids
      end
    end
    private :process_ids

    # Convert a range to a comma separated strings, e.g. 1..4 -> "1,2,3,4"
    #
    # @param id_range [Range]
    # @return [Array<String>]
    # @api private
    def id_range_to_s id_range
      id_range.to_a.join(",")
    end
    private :id_range_to_s

    # @api private
    def id_a_to_s id_a
      ids.to_a.join(",")
    end
    private :id_range_to_s

    # @api private
    def process_tags tags
    end

    # @api private
    def process_dom dom
    end

    # @api public
    def add!
    end

    def modify! attr:, val:, ids: nil, tags: nil, dom: nil
      f = filter(ids, tags, dom)
      query = "#{f} modify #{attr} #{val}"
      Execute.task_popen3(*override_a, query) do |i, o, e, t|
        return t.value
      end
    end

    def undo!
      Execute.task_popen3(*override_a, "undo") do |i, o, e, t|
        return t.value
      end
    end

    def update_config! attr, val
      Execute.task_popen3(*override_a, "config #{attr} #{val}") do |i, o, e, t|
        return t.value
      end
    end

    # Retrieves a hash of hashes with info about the udas currently available
    def get_udas
      udas = {}
      taskrc.config.attributes
        .select { |attr, val| uda_attr? attr }
        .sort
        .chunk  { |attr, val| arbitrary_attr attr }
        .each do |attr, arr|
          uda = arr.map do |pair|
            key = deep_attr(pair[0])
            val = pair[1]
            [key, val]
          end
          udas[attr.to_sym] = Hash[uda]
        end
        return udas
    end

    # Is a given attribute dealing with udas?
    def uda_attr? attr
      attr.to_s.start_with? "uda"
    end
    private :uda_attr?

    # Returns part of attribute at a given depth
    def arbitrary_attr attr, depth: 1
      attr.to_s.split("_")[depth]
    end
    private :arbitrary_attr

    # Returns all attribute string after given depth
    def deep_attr attr, depth: 2
      attr.to_s.split("_")[depth..-1].join("_")
    end
    private :deep_attr

    #
    def add_udas_to_model! uda_hash, type=nil, model=Models::TaskModel
      uda_hash.each do |attr, val|
        val.each do |k, v|
          type = Helpers.determine_type(v) if type.nil?
          model.attribute attr, type
        end
      end
    end
    private :add_udas_to_model!
    
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
    def check_uda uda_name
      if get_udas.any? { |uda| uda == uda_name }
        true
      else
        false
      end
    end

    def create_uda name, type: "string", label: nil, values: nil,
                   default: nil, urgency: nil
      label = name if label.nil?
      p name, label, values, default, urgency

      update_config "uda.#{name}.type",  type
      update_config "uda.#{name}.label", label
      update_config "uda.#{name}.values",  values unless values.nil?
      update_config "uda.#{name}.default", default unless default.nil?
      update_config "uda.#{name}.urgency", urgency unless urgency.nil?
    end

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
  end
end
