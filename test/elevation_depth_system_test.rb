require "minitest/autorun"

# Verifies the elevation/depth system change (canvas vs. surface bg tokens,
# floating sidebar gutter, card shadow, nav link hover polish) is present in
# both the source partials and the packaged mvpa.css manifest.
class ElevationDepthSystemTest < Minitest::Test
  def test_shell_gutter_token_defined
    assert_includes variables_css, "--shell-gutter: 0.625rem;"
    assert_includes packaged_manifest, "--shell-gutter: 0.625rem;"
  end

  private

  def variables_css
    read("0_base/0_variables.css")
  end

  def packaged_manifest
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/mvpa.css", __dir__))
  end

  def read(relative_path)
    File.read(File.expand_path("../app/assets/stylesheets/mvpa/#{relative_path}", __dir__))
  end
end
