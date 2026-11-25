require "yaml"

module Semver
  # One PR's changelog entry. Validates itself on read.
  class Fragment
    class Invalid < StandardError; end

    SECTIONS = %w[Added Changed Fixed Upgrading].freeze

    #: (String) -> Fragment
    def self.read(path)
      front, body = split(File.read(path), path)
      new(path, front, sections_of(body, path)).tap(&:validate)
    end

    #: (String, String) -> Array[untyped]
    def self.split(text, path)
      match = text.match(/\A---\n(.*?)\n---\n?(.*)\z/m) or raise Invalid, "#{path}: no front matter"
      [ YAML.safe_load(match[1]) || {}, match[2] ]
    rescue Psych::Exception => error
      raise Invalid, "#{path}: #{error.message}"
    end

    #: (String, String) -> Hash[String, String]
    def self.sections_of(body, path)
      parts = body.split(/^### (.+)$/)
      parts.drop(1).each_slice(2).to_h { |heading, text| [ heading.strip, text.strip ] }.tap do |sections|
        unknown = sections.keys - SECTIONS
        raise Invalid, "#{path}: unknown section #{unknown.first}" if unknown.any?
      end
    end

    #: (String, Hash[String, untyped], Hash[String, String]) -> void
    def initialize(path, front, sections)
      @path = path
      @front = front
      @sections = sections
    end

    #: () -> Level
    def level
      @level ||= Level.parse(@front["level"])
    end

    #: () -> Hash[String, String]
    def overrides
      @overrides ||= (@front["overrides"] || {}).to_h { |rule, reason| [ rule.to_s, reason ] }
    end

    attr_reader :sections #: Hash[String, String]

    attr_reader :path #: String

    #: () -> void
    def validate
      level
      validate_upgrading
      validate_overrides
    end

    private

    def validate_upgrading
      steps = sections["Upgrading"]
      if level.major?
        raise Invalid, "#{path}: a major fragment needs numbered ### Upgrading steps" unless steps&.match?(/^1\. \S/)
      elsif sections.key?("Upgrading")
        raise Invalid, "#{path}: ### Upgrading belongs to a major fragment"
      end
    end

    def validate_overrides
      overrides.each do |rule, reason|
        raise Invalid, "#{path}: unknown rule id #{rule}" unless Rules.ids.include?(rule)
        raise Invalid, "#{path}: override #{rule} has no reason" unless reason.is_a?(String) && !reason.strip.empty?
      end
    end
  end
end
