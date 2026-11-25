require "open3"

module Semver
  # Runs a command in a directory and returns its output; raises when it fails.
  class Shell
    class Failed < StandardError; end

    #: (String) -> void
    def initialize(root = Dir.pwd)
      @root = root
    end

    #: (Array[String]) -> String
    def call(command)
      output, status = Open3.capture2e(*command, chdir: @root)
      raise Failed, "#{command.join(' ')} failed: #{output}" unless status.success?

      output
    end
  end
end
