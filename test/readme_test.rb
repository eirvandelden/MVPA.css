require "minitest/autorun"

# Verifies README examples match the packaged stylesheet layout.
class ReadmeTest < Minitest::Test
  def test_readme_stylesheet_links_exist
    stylesheet_links.each do |href|
      assert File.file?(stylesheet_path(href)), "#{href} does not exist"
    end
  end

  def test_readme_flash_example_matches_flash_selector
    assert_includes readme, '<section aria-label="Notifications" data-mvpa-flashes>'
    assert_includes readme, '<aside role="status">'
    refute_includes readme, '<section role="status">'
  end

  private

  def stylesheet_links
    readme.scan(/href="mvpa\/([^"]+\.css)"/).flatten
  end

  def readme
    File.read(File.expand_path("../README.md", __dir__))
  end

  def stylesheet_path(href)
    File.expand_path("../app/assets/stylesheets/mvpa/#{href}", __dir__)
  end
end
