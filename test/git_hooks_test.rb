require "minitest/autorun"
require "yaml"

# The git hooks come from the shared dotfiles config, so a stale copy runs jobs that no longer exist there.
class GitHooksTest < Minitest::Test
  def test_the_shared_dotfiles_hooks_are_a_remote
    assert_includes remotes.map { |remote| remote["git_url"] }, "git@github.com:eirvandelden/dotfiles"
  end

  def test_every_shared_hook_config_is_refetched_daily
    remotes.each do |remote|
      assert_equal "24h", remote["refetch_frequency"],
                   "lefthook refetches #{remote['git_url']} only with refetch_frequency set to a duration"
    end
  end

  private

  def remotes
    YAML.safe_load(File.read(File.expand_path("../lefthook.yml", __dir__))).fetch("remotes")
  end
end
