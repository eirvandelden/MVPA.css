module Mvpa
  module Css
    class Engine < ::Rails::Engine
      isolate_namespace Mvpa::Css

      initializer "mvpa-css.assets" do |app|
        # Register asset paths for both Sprockets and Propshaft
        # Both support config.assets.paths but with different implementations
        app.config.assets.paths << root.join("app/assets/stylesheets").to_s
        app.config.assets.paths << root.join("app/javascript").to_s

        # Sprockets-specific: Precompile manifest
        # Only runs if Sprockets is loaded
        if defined?(Sprockets)
          app.config.assets.precompile += %w[mvpa/mvpa.css]
        end
      end

      initializer "mvpa-css.importmap", before: "importmap" do |app|
        if app.config.respond_to?(:importmap)
          app.config.importmap.paths << root.join("config/importmap.rb")
        end
      end
    end
  end
end
