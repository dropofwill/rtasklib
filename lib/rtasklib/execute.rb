require "open3"
require "pty"
require "expect"
require "ruby_expect"
require "stringio"

module Rtasklib

  # How to execute shell commands and capture output
  module Execute
    # so that the methods are available within the modules lookup path
    extend self

    @@exp_regex = {
      create_rc: %r{Would \s you \s like \s a \s sample \s *.+ \s created, \s
                    so \s taskwarrior \s can \s proceed\? \s
                    \(yes/no\)}x }

    # popen versions
    #
    def popen3 program='task', *opts, &block
      execute = opts.unshift(program)
      execute = execute.join(" ")

      Open3.popen3(execute) do |i, o, e, t|
        yield(i, o, e, t) if block_given?
      end
    end

    def task_popen3 *opts, &block
      popen3('task', opts, &block)
    end

    def each_popen3 program='task', *opts, &block
      popen3(program, *opts) do |i, o, e, t|
        o.each_line do |l|
          # Non-greedy json object detection
          # if /\{.*\}/ =~ l
          yield(l, i, o, e, t)
            # p l.chomp
            # res.push(l.chomp)
          # end
        end
      end
    end

    # Use ruby_expect to manage procedures
    def run program="task", *opts
      options = opts.join(" ") unless opts.nil?
      execute = "#{program} #{options}"
      p execute

      exp = RubyExpect::Expect.spawn(execute)
      exp.procedure do
        yield(exp, self)
      end
    end

    # def task create_new, *opts, &block
    #   exp_regex = @@exp_regex
    #   retval = 0
    #   res = nil
    #   buff = ""
    #
    #   run("task", *opts) do |exp, procedure|
    #     res = procedure.any do
    #       puts exp
    #       expect exp_regex[:create_rc] do
    #         if create_new
    #           send "yes"
    #         else
    #           send "no"
    #         end
    #       end
    #       block.call if block_given?
    #     end
    #
    #     buff = exp.buffer.clone.chomp!
    #     retval = res unless res.nil?
    #   end
    #   return buff, retval
    # end
    #
    #
    # def task_run create_new, *opts
    #   options = opts.join(" ") unless opts.nil?
    #   execute = "task #{options}"
    #   p execute
    #
    #   exp_regex = @@exp_regex
    #   retval = 0
    #   res = nil
    #
    #   exp = RubyExpect::Expect.spawn(execute)
    #   exp.procedure do
    #     p exp_regex
    #     res = any do
    #       expect exp_regex[:create_rc] do
    #         if create_new
    #           send "yes"
    #         else
    #           send "no"
    #         end
    #       end
    #     end
    #
    #     retval = res unless res.nil?
    #   end
    #   return exp.buffer.clone.chomp!, retval
    # end

    # Filters should be a list of values
    # Ranges interpreted as ids
    #   1...5 : "1-5"
    #   1..5  : "1-4"
    #   1     : "1"
    #   and joined with ","
    #   [1...5, 8, 9] : "1-5,8,9"
  end
end
