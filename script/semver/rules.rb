require "set"

module Semver
  # Repo-specific: the public-surface rules for this repository.
  module Rules
    Rule = Data.define(
      :id,      #: untyped
      :extract  #: untyped
    )

    STYLESHEETS = "app/assets/stylesheets/"
    VARIABLES = "app/assets/stylesheets/mvpa/0_base/0_variables.css"
    IMPORTMAP = "config/importmap.rb"
    PRELUDE = /[^{};]*(?=\{)/

    #: () -> Array[Rule]
    def self.all
      [
        Rule.new("token", ->(snapshot) { tokens(snapshot) }),
        Rule.new("file", ->(snapshot) { files(snapshot) }),
        Rule.new("class", ->(snapshot) { selectors(snapshot, /\.(-?[_a-zA-Z][\w-]*)/) }),
        Rule.new("data_attribute", ->(snapshot) { selectors(snapshot, /\[\s*(data-[\w-]+)/) }),
        Rule.new("importmap_pin", ->(snapshot) { pins(snapshot) })
      ]
    end

    #: () -> Array[String]
    def self.ids
      all.map(&:id)
    end

    #: (Snapshot) -> Set[String]
    def self.tokens(snapshot)
      snapshot.read(VARIABLES).scan(/^\s*(--[\w-]+)\s*:/).flatten.to_set
    end

    #: (Snapshot) -> Set[String]
    def self.files(snapshot)
      snapshot.paths.select { |path| path.start_with?("app/") || path == IMPORTMAP }.to_set
    end

    #: (Snapshot, Regexp) -> Set[String]
    def self.selectors(snapshot, pattern)
      stylesheets(snapshot).flat_map { |css| preludes(css).flat_map { |prelude| prelude.scan(pattern).flatten } }.to_set
    end

    #: (Snapshot) -> Set[String]
    def self.pins(snapshot)
      source = snapshot.read(IMPORTMAP)
      names = source.scan(/\bpin\s+["']([^"']+)["']/)
      names += source.scan(/\bpin_all_from\b(?:(?!\bpin(?:_all_from)?\b).)*?under:\s*["']([^"']+)["']/m)
      names.flatten.to_set
    end

    #: (Snapshot) -> Array[String]
    def self.stylesheets(snapshot)
      snapshot.paths.filter_map do |path|
        snapshot.read(path) if path.start_with?(STYLESHEETS) && path.end_with?(".css")
      end
    end

    # The text before each `{`, without comments, strings and at-rule preludes.
    #: (String) -> Array[String]
    def self.preludes(css)
      texts = css.gsub(%r{/\*.*?\*/}m, "").scan(PRELUDE).map { |text| text.gsub(/"[^"]*"|'[^']*'/, "").strip }
      texts.reject { |text| text.start_with?("@") }
    end
  end
end
