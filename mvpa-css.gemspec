require_relative "lib/mvpa/css/version"

Gem::Specification.new do |spec|
  spec.name          = "mvpa-css"
  spec.version       = Mvpa::Css::VERSION
  spec.authors       = ["Etienne van Delden"]
  spec.email         = ["etienne@conductor.build"]
  spec.homepage      = "https://github.com/eirvandelden/mvpa.css"
  spec.summary       = "MVPA.css - Minimal Viable Product CSS Framework"
  spec.description   = "A classless CSS framework for semantic HTML5 with Rails/Turbo integration. Includes 4 professional themes, automatic dark mode, OKLCH color space, and 37signals spacing system."
  spec.license       = "osaassy"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,lib}/**/*", "LICENSE.md", "README.md", "CHANGELOG.md"]
  end

  spec.add_dependency "railties", ">= 6.0"
end
