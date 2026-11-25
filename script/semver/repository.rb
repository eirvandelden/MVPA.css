require "date"

module Semver
  # The checkout the run works in. Owns every git and gh call.
  class Repository
    ATTEMPTS = 3
    RELEASE_SUBJECT = /\ARelease v(\d+\.\d+\.\d+)\z/
    FRAGMENTS = "changelog.d"

    #: (?root: String, ?branch: String, ?runner: untyped, ?clock: untyped) -> void
    def initialize(root: Dir.pwd, branch: "main", runner: Shell.new(root), clock: -> { Date.today })
      @root = root
      @branch = branch
      @runner = runner
      @clock = clock
    end

    #: () -> bool
    def unreleased?
      last = release_commits.last
      last ? git("rev-list", "--count", "#{last.first}..HEAD").to_i.positive? : true
    end

    #: () -> Version
    def latest_version
      tagged = git("tag", "--list", "v*").lines.map { |tag| tag.strip.delete_prefix("v") }
      current = Stamp.version_in(File.read(File.join(@root, Stamp::VERSION_PATH)))
      [ current, *tagged ].filter_map { |text| parse(text) }.max
    end

    #: () -> Array[Fragment]
    def fragments
      fragment_paths.map { |path| Fragment.read(File.join(@root, path)) }
    end

    #: () -> void
    def publish
      ATTEMPTS.times do
        refresh
        reconcile
        return unless unreleased?

        version = attempt
        return create_release("v#{version}", git("rev-parse", "HEAD").strip) if version
      end
      raise Shell::Failed, "the release push was rejected #{ATTEMPTS} times"
    end

    #: () -> void
    def reconcile
      commits = release_commits
      released = published
      newest = commits.rindex { |_sha, version| released.include?("v#{version}") }
      commits.drop(newest ? newest + 1 : 0).each { |sha, version| repair(sha, version) }
    end

    private

    # Oldest first: [sha, version] of every release commit on the branch.
    def release_commits
      git("log", "--reverse", "--format=%H%x09%s").lines.filter_map do |line|
        sha, subject = line.chomp.split("\t", 2)
        [ sha, Regexp.last_match(1) ] if subject.to_s.match(RELEASE_SUBJECT)
      end
    end

    def git(*arguments)
      @runner.call([ "git", *arguments ])
    end

    def parse(text)
      Version.parse(text)
    rescue ArgumentError
      nil
    end

    def fragment_paths
      listed = git("ls-files", FRAGMENTS).lines.map(&:chomp).select { |path| path.end_with?(".md") }
      (listed - [ "#{FRAGMENTS}/README.md" ]).sort_by { |path| [ added_at(path), path ] }
    end

    def added_at(path)
      git("log", "--diff-filter=A", "--format=%ct", "--", path).lines.last.to_i
    end

    def refresh
      git("fetch", "origin", @branch, "--tags")
      git("reset", "--hard", "origin/#{@branch}")
    end

    def published
      @runner.call([ "gh", "release", "list", "--limit", "200", "--json", "tagName", "--jq",
".[].tagName" ]).lines.map(&:strip)
    end

    def repair(sha, version)
      tag = "v#{version}"
      remote = git("ls-remote", "--tags", "origin", "refs/tags/#{tag}").split.first
      raise Shell::Failed, "tag #{tag} points at #{remote}, not #{sha}" if remote && remote != sha

      unless remote
        git("update-ref", "refs/tags/#{tag}", sha)
        git("push", "origin", "refs/tags/#{tag}")
      end
      create_release(tag, sha)
    end

    def create_release(tag, sha)
      notes = section(git("show", "#{sha}:#{Stamp::CHANGELOG_PATH}"), tag.delete_prefix("v"))
      @runner.call([ "gh", "release", "create", tag, "--verify-tag", "--title", tag, "--notes", notes ])
    end

    def section(changelog, version)
      changelog[/^## #{Regexp.escape(version)} - .*?(?=^## |\z)/m].to_s.strip
    end

    def attempt
      release = Release.plan(latest: latest_version, fragments: fragments, date: @clock.call)
      commit(release)
      pushed?(release.version) ? release.version : rollback
    rescue StandardError
      rollback
      raise
    end

    def commit(release)
      tag = "v#{release.version}"
      raise Shell::Failed, "tag #{tag} already exists" unless git("tag", "--list", tag).strip.empty?

      git("rm", "-q", "--", *release.consumed) if release.consumed.any?
      write(Stamp::VERSION_PATH) { |source| Stamp.version_source(source, release.version) }
      write(Stamp::CHANGELOG_PATH) { |text| Stamp.changelog_text(text, release) }
      Stamp::CHECKS.each { |command| @runner.call(command) }
      git("add", *Stamp::PATHS)
      git("commit", "-q", "-m", "Release #{tag}", "-m", "[skip ci]")
      verify_commit
    end

    def write(path)
      full = File.join(@root, path)
      File.write(full, yield(File.read(full)))
    end

    def verify_commit
      changed = git("diff-tree", "--no-commit-id", "--name-only", "-r", "HEAD").lines.map(&:chomp)
      stray = changed.reject { |path| Stamp::PATHS.include?(path) || path.start_with?("#{FRAGMENTS}/") }
      raise Shell::Failed, "the release commit would hold #{stray.join(', ')}" if stray.any?
    end

    def pushed?(version)
      git("update-ref", "refs/tags/v#{version}", "HEAD")
      git("push", "--atomic", "origin", "HEAD:refs/heads/#{@branch}", "refs/tags/v#{version}")
      true
    rescue Shell::Failed
      false
    end

    def rollback
      git("tag", "--list", "v*").lines.map(&:strip).each do |tag|
        git("tag", "-d", tag) if git("ls-remote", "--tags", "origin", "refs/tags/#{tag}").strip.empty?
      end
      git("reset", "--hard", "origin/#{@branch}")
      nil
    end
  end
end
