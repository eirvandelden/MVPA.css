module Mvpa
  module Css
    VERSION = `git -C #{__dir__} rev-parse --short HEAD 2>/dev/null`.strip.then { |sha|
      sha.empty? ? "unknown" : sha
    }
  end
end
