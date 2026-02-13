module Mvpa
  module Css
    class Engine < ::Rails::Engine
      isolate_namespace Mvpa::Css

      initializer "mvpa-css.assets" do |app|
        if app.config.respond_to?(:assets)
          app.config.assets.paths << root.join("app/assets/stylesheets")
        end
      end
    end
  end
end
