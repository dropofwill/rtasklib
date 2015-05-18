# Copyright (c) 2015 Will Paul (whp3652@rit.edu)
# All rights reserved.
#
# This file is distributed under the MIT license. See LICENSE.txt for details.

require "open3"

module Rtasklib

  # How to execute shell commands and capture output
  module Execute
    # so that the methods are available within the modules lookup path
    extend self

    DEBUG = false

    # Turned off confirmations, so this regex is deprecated
    # This also means we have to handle that all ourselves
    # For example warn user with bang methods.
    #
    # @@exp_regex = {
    #   create_rc: %r{Would \s you \s like \s a \s sample \s *.+ \s created, \s
    #                 so \s taskwarrior \s can \s proceed\? \s
    #                 \(yes/no\)}x }

    # Use Open3#popen3 to execute a unix program with an array of options
    # and an optional block to handle the response.
    #
    # @example
    #    Execute.popen3("task", "export") do |i, o, e, t|
    #      # Arbitrary code to handle the response...
    #    end
    #
    # @param program [String]
    # @param opts [Array<String>] args to pass directly to the program
    # @param block [Block] to execute after thread is successful
    # @yield [i,o,e,t] STDIN, STDOUT, STDERR, and the thread to that block.
    # @api public
    def popen3 program='task', *opts, &block
      execute = opts.unshift(program)
      execute = execute.join(" ")
      warn execute if DEBUG 

      Open3.popen3(execute) do |i, o, e, t|
        handle_response(o, e, t)
        yield(i, o, e, t) if block_given?
      end
    end

    # Same as Execute#popen3, only defaults to using the 'task' program for
    # convenience.
    #
    # @example
    #    Execute.task_popen3("export") do |i, o, e, t|
    #      # Arbitrary code to handle the response...
    #    end
    #
    # @param opts [Array<String>] args to pass directly to the program
    # @param block [Block] to execute after thread is successful
    # @yield [i,o,e,t] STDIN, STDOUT, STDERR, and the thread to that block.
    # @api public
    def task_popen3 *opts, &block
      popen3('task', opts, &block)
    end

    # Same as Execute#popen3, but yields each line of input
    #
    # @param program [String]
    # @param opts [Array<String>] args to pass directly to the program
    # @param block [Block] to execute after thread is successful
    # @yield [l,i,o,e,t] a line of STDIN, STDIN, STDOUT, STDERR,
    #     and the thread to that block.
    # @api public
    def each_popen3 program='task', *opts, &block
      popen3(program, *opts) do |i, o, e, t|
        o.each_line do |l|
          yield(l, i, o, e, t)
        end
      end
    end

    # Same as Execute#each_popen3, but calls it with the 'task' program
    #
    # @param opts [Array<String>] args to pass directly to the program
    # @param block [Block] to execute after thread is successful
    # @yield [l,i,o,e,t] a line of STDIN, STDIN, STDOUT, STDERR,
    #     and the thread to that block.
    # @api public
    def task_each_popen3 *opts, &block
      each_popen3("task", *opts) do |l, i, o, e, t|
        yield(l, i, o, e, t)
      end
    end

    # Default error handling called in every popen3 call. Only executes if
    # thread had a failing exit code
    #
    # @raise [RuntimeError] if failing exit code
    def handle_response stdout, stderr, thread
      unless thread.value.success?
        dump = "#{thread.value} \n Stderr: #{stderr.read} \n Stdout: #{stdout.read} \n"
        raise dump
      end
    end
  end
end
