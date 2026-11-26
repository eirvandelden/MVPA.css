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
    QUOTED = /"[^"]*"|'[^']*'/
    DATA_ATTRIBUTE = /\[\s*(data-[\w-]+(?:\s*[~|^$*]?=\s*(?:"[^"]*"|'[^']*'|[^\]\s]+))?)/

    #: () -> Array[Rule]
    def self.all
      [
        Rule.new("token", ->(snapshot) { tokens(snapshot) }),
        Rule.new("file", ->(snapshot) { files(snapshot) }),
        Rule.new("class", ->(snapshot) { selectors(snapshot, /\.(-?[_a-zA-Z][\w-]*)/) }),
        Rule.new("data_attribute", ->(snapshot) { data_attributes(snapshot) }),
        Rule.new("importmap_pin", ->(snapshot) { pins(snapshot) })
      ]
    end

    #: () -> Array[String]
    def self.ids
      all.map(&:id)
    end

    #: (Snapshot) -> Set[String]
    def self.tokens(snapshot)
      uncommented(snapshot.read(VARIABLES)).scan(/^\s*(--[\w-]+)\s*:/).flatten.to_set
    end

    #: (Snapshot) -> Set[String]
    def self.files(snapshot)
      snapshot.paths.select { |path| path.start_with?("app/") || path == IMPORTMAP }.to_set
    end

    #: (Snapshot, Regexp) -> Set[String]
    def self.selectors(snapshot, pattern)
      stylesheets(snapshot).flat_map { |css| preludes(css).flat_map { |prelude| prelude.scan(pattern).flatten } }.to_set
    end

    # `data-theme="dark"` and `data-theme=dark` are one name: removing a value removes a theme.
    #: (Snapshot) -> Set[String]
    def self.data_attributes(snapshot)
      preludes = stylesheets(snapshot).flat_map { |css| preludes(css, strings: true) }
      preludes.flat_map { |text| text.scan(DATA_ATTRIBUTE).flatten }.map { |name| attribute_name(name) }.to_set
    end

    # Quotes and the space around the operator do not make a different selector; a space inside the value does.
    #: (String) -> String
    def self.attribute_name(text)
      text.gsub(/\s*([~|^$*]?=)\s*/, "\\1").delete("\"'")
    end

    #: (Snapshot) -> Set[String]
    def self.pins(snapshot)
      source = snapshot.read(IMPORTMAP).lines.map { |line| line.sub(/(?:\A|\s)#.*\z/m, "") }.join
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
    #: (String, ?strings: bool) -> Array[String]
    def self.preludes(css, strings: false)
      texts = uncommented(css).scan(PRELUDE).map { |text| (strings ? text : text.gsub(QUOTED, "")).strip }
      texts.reject { |text| text.start_with?("@") }
    end

    #: (String) -> String
    def self.uncommented(css)
      css.gsub(%r{/\*.*?\*/}m, "")
    end

    private_class_method :tokens, :files, :selectors, :data_attributes, :attribute_name, :pins
    private_class_method :stylesheets, :preludes, :uncommented
  end
end
