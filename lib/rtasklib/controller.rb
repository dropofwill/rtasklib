require "multi_json"
require "oj"

module Rtasklib

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

    def filter ids: nil, tags: nil, query: nil
    end

    def add!
    end

    # def modify! attr:, val:, ids: nil, tags: nil, query: nil
    # end

    def undo!
    end

    def update_config! attr, val
      Execute.task_popen3(*override_a, "config #{attr} #{val}") do |i, o, e, t|
        return t.value
      end
    end

    # Retrieves an array of hashes with info about the udas currently available
    def get_udas
      taskrc.config.attributes
        .select { |attr, val| uda_attr? attr }
        .sort
        .chunk  { |attr, val| arbitrary_attr attr }
        .map do |attr, arr|
          uda = arr.map do |pair|
            key = deep_attr(pair[0])
            val = pair[1]
            [key, val]
          end
          {attr.to_sym => Hash[uda]}
        end
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

    # Returns all attribute string after given depth
    def deep_attr attr, depth: 2
      attr.to_s.split("_")[depth..-1].join("_")
    end
    private :deep_attr
    

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

    def get_rc
      res = []
      Execute.task_popen3(*@override_a, "_show") do |i, o, e, t|
        res = o.read.each_line.map { |l| l.chomp }
      end
      Taskrc.new(res, :array)
    end

    def get_version
      version = nil
      Execute.task_popen3(*@override_a, "_version") do |i, o, e, t|
        version = to_gem_version(o.read.chomp)
      end
      version
    end

    # Converts a string of format "1.6.2 (adf342jsd)" to Gem::Version object
    #
    #
    def to_gem_version raw
      std_ver = raw.chomp.gsub(' ','.').delete('(').delete(')')
      Gem::Version.new std_ver
    end
    private :to_gem_version

  end
end
