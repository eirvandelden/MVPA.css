module Semver
  # A semantic version that knows how to bump itself.
  class Version
    include Comparable

    PATTERN = /\A(\d+)\.(\d+)\.(\d+)\z/

    #: (String) -> Version
    def self.parse(text)
      match = PATTERN.match(text.to_s) or raise ArgumentError, "not a version: #{text.inspect}"
      new(*match.captures.map(&:to_i))
    end

    #: (Integer, Integer, Integer) -> void
    def initialize(major, minor, patch)
      @parts = [ major, minor, patch ]
    end

    #: (Level) -> Version
    def bump(level)
      major, minor, patch = @parts
      case level.to_s
      when "major" then self.class.new(major + 1, 0, 0)
      when "minor" then self.class.new(major, minor + 1, 0)
      else self.class.new(major, minor, patch + 1)
      end
    end

    #: (Version) -> Integer
    def <=>(other)
      parts <=> other.parts
    end

    #: () -> String
    def to_s
      @parts.join(".")
    end

    protected

    attr_reader :parts
  end
end
