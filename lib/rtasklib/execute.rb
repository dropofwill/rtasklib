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

    # Use Open3#popen3 to execute a unix program with an array of options
    # and an optional block to handle the response. Passes:
    # STDIN, STDOUT, STDERR, and the thread to that block.
    #
    # For example:
    #
    # Execute.popen3("task", "export") do |i, o, e, t|
    #   # Arbitrary code to handle the response...
    # end
    #
    # @param program [String]
    # @param opts [Array<String>] args to pass directly to the program
    # @param block [Block] to execute after thread is successful
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

    # Default error handling called in every popen3 call. Only executes if
    # thread had a failing exit code
    #
    # @raise [RuntimeError] if failing exit code
    def handle_response stderr, thread
      unless thread.value.success?
        puts stderr.read
        raise thread.inspect
      end
    end
  end
end
