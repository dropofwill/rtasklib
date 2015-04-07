require "open3"
require "pty"
require "expect"
require "ruby_expect"
require "stringio"

module Rtasklib

  class Execute
    @@exp_regex = {
      create_rc: %r{Would \s you \s like \s a \s sample \s *.+ \s created, \s
                    so \s taskwarrior \s can \s proceed\? \s
                    \(yes/no\)}x
    }

    # Use ruby_expect to manage procedures
    def self.run program="task", *opts
      options = opts.join(" ") unless opts.nil?
      execute = "#{program} #{options}"
      p execute

      exp = RubyExpect::Expect.spawn(execute)
      exp.procedure do
        yield
      end
    end

    def self.task create_new, *opts
      exp_regex = @@exp_regex
      retval = 0
      res = nil

      self.run("task", *opts) do
        res = any do
          expect exp_regex[:create_rc] do
            if create_new
              send "yes"
            else
              send "no"
            end
          end
          yield
        end

        retval = res unless res.nil?
      end
      return exp.buffer.clone.chomp!, retval
    end


    def self.task_run create_new, *opts
      options = opts.join(" ") unless opts.nil?
      execute = "task #{options}"
      p execute

      exp_regex = @@exp_regex
      retval = 0
      res = nil

      exp = RubyExpect::Expect.spawn(execute)
      exp.procedure do
        p exp_regex
        res = any do
          expect exp_regex[:create_rc] do
            if create_new
              send "yes"
            else
              send "no"
            end
          end
        end

        retval = res unless res.nil?
      end
      return exp.buffer.clone.chomp!, retval
    end

    # Spawns a process running the given program with an optional list of opts
    # Yields a block to handle user input as needed
    # See http://bit.ly/1NJymxb
    # def self.run program="task", *opts
    #   options = opts.join(" ") if opts.nil?
    #   execute = "#{program} #{options}"
    #   output = []
    #
    #   begin
    #     PTY.spawn(execute) do |stdout, stdin, pid|
    #       begin
    #         # puts stdout.each { |line| puts line }
    #       rescue Errno::EIO
    #       end
    #
    #       output = yield stdout, stdin, pid
    #     end
    #   rescue PTY::ChildExited
    #     puts "Child process exited"
    #   end
    #
    #   return output, $?.exitstatus
    # end
    #
    # def self.task create_new, *opts
    #   self.run("task", opts) do |stdout, stdin, pid|
    #     output = []
    #     until stdout.eof? do
    #       output << stdout.readline
    #     end
    #     print output
    #
    #     # Handle initialization of the TW database
    #     stdout.expect(@exp_regex[:create_rc], 5) do
    #       puts "yolo swag"
    #       # if create_new
    #       #   stdin.write "yes"
    #       # else
    #       stdin.write "no"
    #       # end
    #     end
    #   end
    #
    #   return output
    # end
  end
end
