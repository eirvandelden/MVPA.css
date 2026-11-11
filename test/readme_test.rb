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

  def test_readme_places_the_notifications_container_outside_main
    assert_includes readme, "outside `<main>`"
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

  def test_readme_shows_view_switch_and_form_choice_markup
    assert_includes segmented_section, '<menu><li><a href="?period=month" aria-current="page">Deze maand</a></li>'
    assert_includes segmented_section, '<menu><li><label><input type="radio" name="role" value="lid"> Lid</label></li>'
    assert_includes segmented_section, "<legend>Rol</legend>"
    assert_includes segmented_section, "aria-current"
    assert_includes segmented_section, "main > header nav"
  end

  def test_readme_shows_the_count_badge_markup
    assert_includes badges_section, '<a href="/categorise">Categoriseren <data value="12">12</data></a>'
    assert_includes badges_section, 'value="0"'
    assert_includes readme, "main > header h1"
  end

  def test_readme_shows_the_period_navigation_markup
    assert_includes period_section, "<nav>"
    assert_includes period_section, "<h2>Week 43, 2026 <a href="
    refute_includes period_section[/```html.*?```/m], "class="
  end

  def test_readme_links_the_period_navigation_partial_right_after_the_count_badge
    links = stylesheet_links

    assert_equal %w[2_modules/14_count_badge.css 2_modules/15_period_navigation.css],
links[links.index("2_modules/14_count_badge.css"), 2]
    assert_includes readme, "│   ├── 14_count_badge.css\n│   ├── 15_period_navigation.css\n│   └── 16_rail.css"
  end

  def test_readme_links_the_rail_partial_right_after_the_period_navigation
    links = stylesheet_links

    assert_equal %w[2_modules/15_period_navigation.css 2_modules/16_rail.css],
links[links.index("2_modules/15_period_navigation.css"), 2]
  end

  def test_the_readme_shows_the_rail_shell_markup
    markup = rail_section[/```html.*?```/m].to_s

    [ '<nav class="rail">', "<search>", '<span aria-hidden="true">', 'aria-current="true"', 'aria-current="page"',
"<details>", "<summary>", "<h2>" ].each do |text|
      assert_includes markup, text
    end
    assert_equal [ 'class="rail"' ], markup.scan(/class="[^"]*"/)
    assert_includes rail_section, "1024px"
    assert_includes readme, "--rail-width"
  end

  def test_the_readme_shows_the_landing_tiles_markup
    markup = tiles_section[/```html.*?```/m].to_s

    assert_includes markup, "<nav>\n"
    assert_includes markup, "<li><a href="
    assert_includes markup, "0 rekeningen nog niet ingedeeld"
    refute_includes markup, "class="
    refute_includes markup, "<data"
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

  def segmented_section
    readme[/^### Segmented control.*?(?=^### )/m].to_s
  end

  def badges_section
    readme[/^### Count badges.*?(?=^### )/m].to_s
  end

  def period_section
    readme[/^### Period navigation.*?(?=^### )/m].to_s
  end

  def rail_section
    readme[/^### Rail and hub column.*?(?=^### )/m].to_s
  end

  def tiles_section
    readme[/^### Landing tiles.*?(?=^### )/m].to_s
  end
end
