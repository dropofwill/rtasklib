require "open3"

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
      warn execute

      Open3.popen3(execute) do |i, o, e, t|
        handle_response(e, t)
        yield(i, o, e, t) if block_given?
      end
    end

    def task_popen3 *opts, &block
      popen3('task', opts, &block)
    end

    def each_popen3 program='task', *opts, &block
      popen3(program, *opts) do |i, o, e, t|
        o.each_line do |l|
          yield(l, i, o, e, t)
        end
      end
    end

    def task_each_popen3 *opts, &block
      popen3(program, *opts) do |i, o, e, t|
        yield(i, o, e, t)
      end
    end

    def handle_response stderr, thread
      unless thread.value.success?
        puts stderr.read
        exit(-1)
      end
    end

    # Non-greedy json object detection
    # if /\{.*\}/ =~ l
      # p l.chomp
      # res.push(l.chomp)
    # end
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

    # Filters should be a list of values
    # Ranges interpreted as ids
    #   1...5 : "1-5"
    #   1..5  : "1-4"
    #   1     : "1"
    #   and joined with ","
    #   [1...5, 8, 9] : "1-5,8,9"
  end
end
