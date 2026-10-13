require "minitest/autorun"
require "nokogiri"

# demo.html shows the button hierarchy, the three action rows and the
# confirmation dialog, with plain semantic markup and no script.
class DemoButtonHierarchyTest < Minitest::Test
  def test_the_demo_links_the_dialog_partial
    hrefs = document.css('link[rel="stylesheet"]').map { |link| link["href"] }

    assert_includes hrefs, "app/assets/stylesheets/mvpa/2_modules/12_dialog.css"
  end

  def test_the_demo_has_a_main_page_header_with_a_link_and_a_patch_form
    header = document.at_css("main > header")

    assert_equal "Edit", header.at_css("nav a").text.strip
    assert_equal "patch", header.at_css('nav form input[name="_method"]')["value"]
    assert_equal "Tonen", header.at_css("nav form button").text.strip
    assert_equal %w[patch delete], header.css('nav form input[name="_method"]').map { |input| input["value"] }
    assert_equal "Uitloggen", header.css("nav form button").last.text.strip
  end

  def test_the_demo_shows_an_edit_row_with_delete_first
    assert_equal [ "Delete…", "Cancel", "Save" ], texts(footer("edit-row"))
    first, cancel, save = footer("edit-row").element_children

    assert_includes first["class"], "button-danger"
    assert_equal "button", first["type"]
    assert_equal "button", cancel["type"]
    refute_equal "button", save["type"]
  end

  def test_the_demo_shows_a_new_row_with_only_cancel_and_save
    assert_equal %w[Cancel Save], texts(footer("new-row"))
  end

  def test_the_demo_shows_a_save_sheet_with_dont_save_first
    footer = footer("save-sheet")

    assert_equal [ "Don't Save", "Cancel", "Save" ], texts(footer)
    assert_equal "button", footer.element_children.first["type"]
    assert_nil footer.element_children.first["class"]
  end

  def test_the_demo_confirmation_has_a_dialog_form_cancel_before_a_delete_form
    dialog = document.at_css("dialog#confirm-delete")
    cancel_form, delete_form = dialog.css("> footer > form")

    assert_equal "dialog", cancel_form["method"]
    assert_equal [ "Cancel" ], cancel_form.css("button").map { |button| button.text.strip }
    assert_nil cancel_form.at_css("button")["type"]
    assert_equal "delete", delete_form.at_css('input[name="_method"]')["value"]
    assert_equal [ "Delete" ], delete_form.css("button").map { |button| button.text.strip }
  end

  def test_the_demo_opens_the_dialog_with_an_invoker_command_not_a_script
    opener = document.at_css('button[commandfor="confirm-delete"]')

    assert_equal "show-modal", opener["command"]
    assert_includes opener["class"], "button-danger"
    assert_nil opener["onclick"]
  end

  def test_the_demo_shows_a_link_as_button_without_inline_styles
    link = document.at_css('#buttons a[role="button"]')

    assert_equal "Link as Button", link.text.strip
    assert_nil link["style"]
  end

  def test_each_new_button_example_sits_in_its_own_section_with_a_heading
    headings = document.css("#buttons > section > h3").map { |heading| heading.text.strip }

    [ "Button hierarchy", "Action row", "Confirmation dialog" ].each { |title| assert_includes headings, title }
  end

  private

  def document
    @document ||= Nokogiri::HTML(File.read(File.expand_path("../demo.html", __dir__)))
  end

  def texts(footer)
    footer.element_children.map { |button| button.text.strip }
  end

  def footer(id)
    document.at_css("##{id} > footer")
  end
end
