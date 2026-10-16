require "minitest/autorun"
require "yaml"

# The git hooks come from the shared dotfiles config, so a stale copy runs jobs that no longer exist there.
class GitHooksTest < Minitest::Test
  def test_every_shared_hook_config_is_refetched
    remotes.each do |remote|
      assert remote.key?("refetch_frequency"),
             "lefthook never refetches #{remote['git_url']} without refetch_frequency"
    end
  end

  private

  def remotes
    YAML.safe_load(File.read(File.expand_path("../lefthook.yml", __dir__))).fetch("remotes")
  end
end
