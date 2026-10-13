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

  def test_readme_explains_that_a_submit_is_filled_and_type_button_is_plain
    assert_includes buttons_section, "A submit is the filled default"
    assert_includes buttons_section, 'type="button"'
    assert_includes buttons_section, 'type="reset"'
    assert_includes buttons_section, "plain push button"
    assert_includes buttons_section, "DELETE"
  end

  def test_readme_shows_the_action_row_footer_markup
    assert_includes buttons_section, "<footer>"
    assert_includes buttons_section, '<button type="button" class="button-danger">Delete…</button>'
    assert_includes buttons_section, '<button type="button">Cancel</button>'
    assert_includes buttons_section, "<button>Save</button>"
  end

  def test_readme_shows_the_dialog_with_a_method_dialog_cancel
    assert_includes buttons_section, "<dialog"
    assert_includes buttons_section, '<form method="dialog"><button>Cancel</button></form>'
    assert_includes buttons_section, '<input type="hidden" name="_method" value="delete">'
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

  def buttons_section
    readme[/^### Buttons.*?(?=^### Tables)/m]
  end
end
