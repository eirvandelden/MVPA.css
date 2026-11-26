require "yaml"

module Semver
  # One PR's changelog entry. Validates itself on read.
  class Fragment
    class Invalid < StandardError; end

    SECTIONS = %w[Added Changed Fixed Upgrading].freeze

    #: (String) -> Fragment
    def self.read(path)
      front, body = split(File.read(path), path)
      Level.parse(front["level"])
      new(path, front, sections_of(body, path)).tap(&:validate)
    end

    #: (String, String) -> Array[untyped]
    def self.split(text, path)
      match = text.match(/\A---\n(.*?)\n---\n?(.*)\z/m) or raise Invalid, "#{path}: no front matter"
      front = YAML.safe_load(match[1]) || {}
      raise Invalid, "#{path}: the front matter is not a mapping" unless front.is_a?(Hash)

      [ front, match[2] ]
    rescue Psych::Exception => error
      raise Invalid, "#{path}: #{error.message}"
    end

    #: (String, String) -> Hash[String, String]
    def self.sections_of(body, path)
      stray, *rest = body.split(/^### (.+)$/)
      raise Invalid, "#{path}: text before the first ### heading" unless stray.to_s.strip.empty?

      pairs = rest.each_slice(2).map { |heading, text| [ heading.strip, text.strip ] }
      check_headings(pairs.map(&:first), path)
      pairs.to_h
    end

    #: (Array[String], String) -> void
    def self.check_headings(headings, path)
      raise Invalid, "#{path}: a fragment needs at least one section" if headings.empty?

      repeated = headings.tally.find { |_heading, count| count > 1 }
      raise Invalid, "#{path}: section #{repeated.first} appears twice" if repeated

      unknown = headings - SECTIONS
      raise Invalid, "#{path}: unknown section #{unknown.first}" if unknown.any?
    end

    private_class_method :split, :sections_of, :check_headings

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
      @overrides ||= begin
        raw = @front["overrides"] || {}
        raise Invalid, "#{path}: overrides must map a rule id to a reason" unless raw.is_a?(Hash)

        raw.to_h { |rule, reason| [ rule.to_s, reason ] }
      end
    end

    # Each numbered step of the ### Upgrading section, with its indented continuation lines.
    #: () -> Array[String]
    def upgrading_steps
      @upgrading_steps ||= steps_of(sections.fetch("Upgrading", ""))
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

    def steps_of(text)
      lines = text.lines(chomp: true).reject { |line| line.strip.empty? }
      lines.slice_before(/\A\d+\. /).map { |group| step_from(group) }
    end

    def step_from(group)
      head, *continuation = group
      unless head.match?(/\A\d+\. \S/) && continuation.all? { |line| line.match?(/\A {2,}\S/) }
        raise Invalid, "#{path}: ### Upgrading holds a line that is not a numbered step or its indented continuation"
      end

      [ head.sub(/\A\d+\. /, ""), *continuation ].join("\n")
    end

    def validate_upgrading
      if level.major?
        raise Invalid, "#{path}: a major fragment needs numbered ### Upgrading steps" if upgrading_steps.empty?
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
