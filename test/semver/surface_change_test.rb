require_relative "surface_fixture"

class SurfaceChangeTest < Minitest::Test
  include SurfaceFixture

  def setup = setup_surface
  def teardown = teardown_repository

  def test_a_removed_token_fails_below_major
    change(VARIABLES, ":root {\n  --color-link: blue;\n}\n")
    verdict = surface_change.check(level("minor"))

    refute_predicate verdict, :passed?
    assert_includes verdict.lines.first, "token:--gap"
  end

  def test_a_removed_token_passes_at_major
    change(VARIABLES, ":root {\n  --color-link: blue;\n}\n")

    assert_predicate surface_change.check(level("major")), :passed?
  end

  def test_a_token_override_does_not_hide_a_class_removal
    change(VARIABLES, ":root {\n  --color-link: blue;\n}\n")
    change(CSS, "nav a { color: var(--color-link); }\n[data-theme=\"dark\"] .hub { margin: 0; }\n")
    verdict = surface_change.check(level("minor"), overrides: { "token" => "unused" })

    refute_predicate verdict, :passed?
    assert_equal [ "class:rail" ], surface_change.removed.grep(/\Aclass:/)
  end

  def test_each_kind_of_removed_surface_fails_below_major
    change(CSS, "nav a { color: red; }\n.hub { margin: 0; }\n")
    change(IMPORTMAP, "pin_all_from \"x\",\n  under: \"controllers\"\n")
    sh(@work, "git", "rm", "-q", "app/javascript/app.js")
    commit_all("remove file")
    kinds = surface_change.removed.map { |item| item.split(":").first }.uniq

    assert_equal %w[class data_attribute file importmap_pin], kinds.sort
    refute_predicate surface_change.check(level("patch")), :passed?
  end

  def test_a_deleted_stylesheet_is_a_removed_file
    sh(@work, "git", "rm", "-q", CSS)
    commit_all("delete the stylesheet")

    assert_includes surface_change.removed, "file:#{CSS}"
  end

  def test_a_class_in_a_comment_is_not_surface
    change(CSS, "/* .ghost */\nnav.rail a { color: red; }\n[data-theme=\"dark\"] .hub { margin: 0; }\n")
    change(CSS, "nav.rail a { color: red; }\n[data-theme=\"dark\"] .hub { margin: 0; }\n")

    assert_empty surface_change.removed
  end

  def test_removing_one_value_of_a_data_attribute_is_a_removal
    themes = "[data-theme=\"dark\"] .hub { margin: var(--gap); }\n"
    sh(@work, "git", "checkout", "-q", "main")
    change(CSS, "nav.rail a { color: var(--color-link); }\n#{themes}[data-theme=\"black\"] .hub { margin: 0; }\n")
    sh(@work, "git", "checkout", "-q", "feature")
    sh(@work, "git", "rebase", "-q", "main")
    change(CSS, "nav.rail a { color: var(--color-link); }\n#{themes}")

    assert_equal [ "data_attribute:data-theme=black" ], surface_change.removed
  end

  def test_a_quote_change_in_a_data_attribute_is_not_a_removal
    change(CSS, "nav.rail a { color: var(--color-link); }\n[data-theme=dark] .hub { margin: var(--gap); }\n")

    assert_empty surface_change.removed
  end

  def test_a_commented_out_token_is_a_removal
    change(VARIABLES, ":root {\n  /*\n  --gap: 1rem;\n  */\n  --color-link: blue;\n}\n")

    assert_equal [ "token:--gap" ], surface_change.removed
  end

  def test_a_commented_out_importmap_pin_is_a_removal
    change(IMPORTMAP, "# pin \"app\", to: \"app.js\"\npin_all_from \"x\",\n  under: \"controllers\"\n")

    assert_equal [ "importmap_pin:app" ], surface_change.removed
  end

  def test_a_token_reference_is_not_a_token
    change(VARIABLES, ":root {\n  --gap: 1rem;\n  --color-link: blue;\n  --other: var(--removed);\n}\n")
    change(VARIABLES, ":root {\n  --gap: 1rem;\n  --color-link: blue;\n}\n")

    assert_empty surface_change.removed
  end

  def test_an_importmap_reformat_is_not_a_removal
    change(IMPORTMAP, "pin 'app', to: 'app.js'\npin_all_from 'x', under: 'controllers'\n")

    assert_empty surface_change.removed
  end

  def test_a_selector_repeated_in_the_manifest_counts_once
    change("app/assets/stylesheets/mvpa/mvpa.css", "nav.rail a { color: red; }\n")
    sh(@work, "git", "rm", "-q", CSS)
    change("app/assets/stylesheets/mvpa/other.css",
"nav.rail a { color: red; }\n[data-theme=\"dark\"] .hub { margin: 0; }\n")

    assert_empty surface_change.removed.grep(/class/)
  end

  def test_removals_merged_to_main_are_not_blamed
    sh(@work, "git", "checkout", "-q", "main")
    change(VARIABLES, ":root {\n  --color-link: blue;\n}\n")
    sh(@work, "git", "checkout", "-q", "feature")
    change("README.md", "x\n")

    assert_empty surface_change.removed
  end

  def test_a_token_removed_on_both_branches_is_not_blamed
    sh(@work, "git", "checkout", "-q", "main")
    change(VARIABLES, ":root {\n  --color-link: blue;\n}\n")
    sh(@work, "git", "checkout", "-q", "feature")
    change(VARIABLES, ":root {\n  --color-link: blue;\n}\n")

    assert_empty surface_change.removed
    assert_predicate surface_change.check(level("patch")), :passed?
  end

  def test_removed_lists_removed_tokens_files_classes_data_attributes_and_pins
    change(VARIABLES, ":root {\n}\n")
    change(CSS, "a { color: red; }\n")
    change(IMPORTMAP, "")
    removed = surface_change.removed

    assert_equal %w[class data_attribute importmap_pin token], removed.map { |item| item.split(":").first }.uniq.sort
    assert_includes removed, "token:--gap"
    assert_includes removed, "data_attribute:data-theme=dark"
    assert_includes removed, "importmap_pin:app"
    assert_includes removed, "importmap_pin:controllers"
  end

  def test_an_override_passes_and_is_listed
    change(VARIABLES, ":root {\n  --color-link: blue;\n}\n")
    verdict = surface_change.check(level("minor"), overrides: { "token" => "no app uses it" })

    assert_predicate verdict, :passed?
    assert_equal [ "override token: no app uses it" ], verdict.lines
  end

  def test_an_override_does_not_cover_another_rule
    change(CSS, "nav a { color: red; }\n[data-theme=\"dark\"] .hub { margin: 0; }\n")
    verdict = surface_change.check(level("minor"), overrides: { "token" => "unused" })

    refute_predicate verdict, :passed?
  end

  def test_check_fails_for_a_removal_that_no_override_covers
    change(VARIABLES, ":root {\n}\n")

    refute_predicate surface_change.check(level("minor"), overrides: {}), :passed?
  end

  def test_verdict_lines_put_failures_first_and_then_each_override
    verdict = Semver::Verdict.new([ "token:--a was removed" ], [ "override class: why" ])

    assert_equal [ "token:--a was removed", "override class: why" ], verdict.lines
    refute_predicate verdict, :passed?
  end
end
