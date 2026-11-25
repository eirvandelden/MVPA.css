module Semver
  # One of patch, minor or major. Ranked, so max works.
  class Level
    include Comparable

    NAMES = %w[patch minor major].freeze

    #: (String) -> Level
    def self.parse(name)
      NAMES.include?(name.to_s) ? new(name.to_s) : raise(Fragment::Invalid, "unknown level #{name.inspect}")
    end

    #: (String) -> void
    def initialize(name)
      @name = name
    end

    #: (Level) -> Integer
    def <=>(other)
      rank <=> other.rank
    end

    #: () -> bool
    def major?
      @name == "major"
    end

    #: () -> String
    def to_s
      @name
    end

    protected

    #: () -> Integer
    def rank
      NAMES.index(@name)
    end
  end
end
