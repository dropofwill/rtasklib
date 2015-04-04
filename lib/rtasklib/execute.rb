require "open3"
require "pty"
require "expect"

module Rtasklib

  class Execute
    attr_reader :wait_regexs

    @wait_regexs = {
      create_rc: "Would you like a sample *.+ created, so taskwarrior can proceed\? \(yes/no\)"
    }

    # Spawns a process running the given program with an optional list of opts
    # Yields a block to handle user input as needed
    def self.run program="task", *opts
      options = opts.join(" ") if opts?
      execute = "#{program} #{options}"

      PTY.spawn(execute) do |reader, writer, pid|
        yield i, o, pid
      end
    end

    def self.task *opts
      self.run("task", opts) do |reader, writer, pid|

        # Handle initialization of the TW database
        reader.expect(@wait_regexs[:create_rc]) do |output|
          if Rtasklib::TaskWarrior.create_new
            writer.puts "yes"
          else
            writer.puts "no"
          end
        end
      end
    end
  end
end
