require_relative "helper"

# A repository with a small stylesheet tree, a branch named "feature" and main as the base.
module SurfaceFixture
  include GitFixture

  VARIABLES = "app/assets/stylesheets/mvpa/0_base/0_variables.css".freeze
  CSS = "app/assets/stylesheets/mvpa/2_modules/nav.css".freeze
  IMPORTMAP = "config/importmap.rb".freeze

  def setup_surface
    setup_repository
    write(VARIABLES, ":root {\n  --gap: 1rem;\n  --color-link: blue;\n}\n")
    write(CSS, "nav.rail a { color: var(--color-link); }\n[data-theme=\"dark\"] .hub { margin: var(--gap); }\n")
    write(IMPORTMAP, "pin \"app\", to: \"app.js\"\npin_all_from \"x\",\n  under: \"controllers\"\n")
    write("app/javascript/app.js", "//\n")
    commit_all("surface")
    sh(@work, "git", "push", "-q", "origin", "HEAD:main")
    sh(@work, "git", "checkout", "-q", "-b", "feature")
  end

  def change(path, content)
    write(path, content)
    commit_all("change #{path}")
  end

  def surface_change
    Semver::SurfaceChange.between(base: "main", head: "feature", root: @work)
  end

  def level(name)
    Semver::Level.parse(name)
  end
end
