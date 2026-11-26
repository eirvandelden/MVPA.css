require "set"

module Semver
  # The outcome of the check: whether it passed and the lines to print, failures first, then each override.
  class Verdict
    #: (Array[String], Array[String]) -> void
    def initialize(failures, used_overrides)
      @failures = failures
      @used_overrides = used_overrides
    end

    #: () -> bool
    def passed?
      @failures.empty?
    end

    #: () -> Array[String]
    def lines
      @failures + @used_overrides
    end
  end

  # What a PR removed from the public surface. Generic: it only asks each rule in `Rules.all` to extract names.
  class SurfaceChange
    #: (base: String, head: String, ?root: String) -> SurfaceChange
    def self.between(base:, head:, root: Dir.pwd)
      runner = Shell.new(root)
      fork_point = runner.call([ "git", "merge-base", base, head ]).strip
      new(*[ fork_point, head, base ].map { |ref| surface(Snapshot.at(ref, runner: runner)) })
    end

    #: (Snapshot) -> Set[String]
    def self.surface(snapshot)
      Rules.all.flat_map { |rule| rule.extract.call(snapshot).map { |name| "#{rule.id}:#{name}" } }.to_set
    end

    private_class_method :surface

    #: (Set[String], Set[String], Set[String]) -> void
    def initialize(fork_surface, head_surface, base_surface)
      @removed = ((fork_surface - head_surface) & base_surface).to_a.sort
    end

    attr_reader :removed #: Array[String]

    #: (Level, ?overrides: Hash[String, String]) -> Verdict
    def check(level, overrides: {})
      return Verdict.new([], []) if level.major? || removed.empty?

      uncovered = removed.reject { |item| overrides.key?(item.split(":", 2).first) }
      Verdict.new(failures(level, uncovered), used(overrides))
    end

    private

    def failures(level, uncovered)
      uncovered.map { |item| "#{item} was removed or renamed, which needs level: major (this is #{level})" }
    end

    def used(overrides)
      rules = removed.map { |item| item.split(":", 2).first }.uniq
      overrides.slice(*rules).map { |rule, reason| "override #{rule}: #{reason}" }
    end
  end
end
