require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "date"
require_relative "../../script/semver/semver"

# Builds a throwaway git repository with a bare repository as origin.
module GitFixture
  VERSION_FILE = %(module Mvpa\n  module Css\n    VERSION = "1.0.0"\n  end\nend\n).freeze
  CHANGELOG = "# Changelog\n\n## 1.0.0 - 2026-01-01\n\n### Added\n- first\n".freeze

  # Runs gh as a recording fake and the test commands as a stub; everything else is real git.
  class Runner
    attr_reader :gh_calls
    attr_accessor :tests_pass, :before_push, :list_fails, :create_fails

    def initialize(root)
      @shell = Semver::Shell.new(root)
      @gh_calls = []
      @tests_pass = true
      @gh_releases = []
    end

    def releases(*tags)
      @gh_releases = tags
    end

    def call(command)
      case command.first
      when "gh" then gh(command)
      when "bundle", "gem" then tests_pass ? "" : raise(Semver::Shell::Failed, "tests failed")
      else
        before_push&.call if command[1] == "push" && command.include?("--atomic")
        @shell.call(command)
      end
    end

    private

    def gh(command)
      @gh_calls << command
      list = command[1..2] == %w[release list]
      raise Semver::Shell::Failed, "gh failed" if list ? list_fails : create_fails

      @gh_releases << command[3] unless list
      list ? "#{@gh_releases.join("\n")}\n" : ""
    end
  end

  def setup_repository
    @tmp = Dir.mktmpdir
    @origin = File.join(@tmp, "origin.git")
    @work = File.join(@tmp, "work")
    sh(@tmp, "git", "init", "-q", "--bare", "-b", "main", @origin)
    sh(@tmp, "git", "clone", "-q", @origin, @work)
    configure(@work)
    write("lib/mvpa/css/version.rb", VERSION_FILE)
    write("CHANGELOG.md", CHANGELOG)
    write("changelog.d/README.md", "readme\n")
    commit_all("initial")
    sh(@work, "git", "push", "-q", "-u", "origin", "HEAD:main")
    @runner = Runner.new(@work)
  end

  def teardown_repository
    FileUtils.remove_entry(@tmp)
  end

  def repository(**options)
    Semver::Repository.new(root: @work, runner: @runner, clock: -> { Date.new(2026, 2, 3) }, **options)
  end

  def configure(dir)
    sh(dir, "git", "config", "user.email", "test@example.com")
    sh(dir, "git", "config", "user.name", "Test")
    sh(dir, "git", "config", "core.hooksPath", "/dev/null")
    sh(dir, "git", "config", "commit.gpgsign", "false")
    sh(dir, "git", "checkout", "-q", "-B", "main")
  end

  def sh(dir, *command)
    Semver::Shell.new(dir).call(command)
  end

  def write(path, content, dir: @work)
    full = File.join(dir, path)
    FileUtils.mkdir_p(File.dirname(full))
    File.write(full, content)
  end

  def commit_all(message, dir: @work)
    sh(dir, "git", "add", "-A")
    sh(dir, "git", "commit", "-q", "-m", message)
  end

  def fragment(level, name: level, dir: @work, upgrading: nil)
    steps = upgrading || (level == "major" ? "\n### Upgrading\n1. Do the thing.\n" : "")
    write("changelog.d/#{name}.md", "---\nlevel: #{level}\n---\n\n### Added\n- **#{name}** text\n#{steps}", dir: dir)
  end

  def merge(level, name: level)
    fragment(level, name: name)
    commit_all("merge #{name}")
    sh(@work, "git", "push", "-q", "origin", "HEAD:main")
  end

  def origin_log
    sh(@origin, "git", "log", "--format=%s", "main").lines.map(&:chomp)
  end

  def origin_tags
    sh(@origin, "git", "tag", "--list").lines.map(&:chomp)
  end
end
