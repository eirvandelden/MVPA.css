module Semver
  # The next version and its notes. Pure: no git, no clock.
  class Release
    ORDER = %w[Added Changed Fixed].freeze

    #: (latest: Version, fragments: Array[Fragment], date: Date) -> Release
    def self.plan(latest:, fragments:, date:)
      level = fragments.map(&:level).max || Level.parse("patch")
      new(latest.bump(level), fragments, date)
    end

    attr_reader :version #: Version

    #: (Version, Array[Fragment], Date) -> void
    def initialize(version, fragments, date)
      @version = version
      @fragments = fragments
      @date = date
    end

    #: () -> String
    def notes
      [ "## #{version} - #{@date.strftime('%Y-%m-%d')}", *bulleted, upgrading ].compact.join("\n\n") + "\n"
    end

    #: () -> Array[String]
    def consumed
      @fragments.map(&:path)
    end

    private

    def bulleted
      ORDER.filter_map do |heading|
        texts = @fragments.filter_map { |fragment| fragment.sections[heading] }
        "### #{heading}\n#{texts.join("\n")}" if texts.any?
      end
    end

    def upgrading
      steps = @fragments.flat_map(&:upgrading_steps)
      return if steps.empty?

      "### Upgrading\n" + steps.each_with_index.map { |step, index| "#{index + 1}. #{step}" }.join("\n")
    end
  end
end
