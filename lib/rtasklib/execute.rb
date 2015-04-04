require "open3"
require "pty"
require "expect"

module Rtasklib

  class Execute
    def self.run program="task"
      puts "running #{program}"
      PTY.spawn(program) do |input, output, pid|
        yield
      end
    end
  end
end
