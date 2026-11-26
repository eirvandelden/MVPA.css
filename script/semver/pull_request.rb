module Semver
  # What a pull request declares: the fragments it adds, and what that means for its surface check.
  class PullRequest
    #: (base: String, head: String, ?root: String) -> void
    def initialize(base:, head:, root: Dir.pwd)
      @base = base
      @head = head
      @root = root
      @runner = Shell.new(root)
    end

    #: () -> Verdict
    def verdict
      problems = foreign_changes
      return Verdict.new(problems, []) if problems.any?

      fragments = added.map { |path| Fragment.read(File.join(@root, path)) }
      level = fragments.map(&:level).max || Level.parse("patch")
      overrides = fragments.map(&:overrides).reduce({}, :merge)
      SurfaceChange.between(base: @base, head: @head, root: @root).check(level, overrides: overrides)
    rescue Fragment::Invalid => error
      Verdict.new([ error.message ], [])
    end

    private

    def foreign_changes
      changed("MDR").map { |path| "#{path}: a pull request may add a fragment, never edit or delete one" }
    end

    def changed(filter)
      names = @runner.call([ "git", "diff", "--name-only", "--diff-filter=#{filter}", "#{@base}...#{@head}", "--",
"changelog.d" ])
      names.lines.map(&:chomp).select { |path| path.end_with?(".md") } - [ "changelog.d/README.md" ]
    end

    def added
      changed("A")
    end
  end
end
