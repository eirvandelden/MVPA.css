module Semver
  # A read-only view of the tree at one git ref: the generic input of every rule.
  class Snapshot
    #: (String, ?runner: untyped) -> Snapshot
    def self.at(ref, runner: Shell.new)
      new(ref, runner)
    end

    #: (String, untyped) -> void
    def initialize(ref, runner)
      @ref = ref
      @runner = runner
    end

    #: () -> Array[String]
    def paths
      @paths ||= @runner.call([ "git", "ls-tree", "-r", "--name-only", @ref ]).lines.map(&:chomp)
    end

    #: (String) -> String
    def read(path)
      return "" unless paths.include?(path)

      @runner.call([ "git", "show", "#{@ref}:#{path}" ])
    end
  end
end
