module Semver
  # Repo-specific: the files a release stamps and how.
  module Stamp
    VERSION_PATH = "lib/mvpa/css/version.rb"
    CHANGELOG_PATH = "CHANGELOG.md"
    PATHS = [ VERSION_PATH, CHANGELOG_PATH ].freeze
    CHECKS = [ %w[bundle exec rake test], %w[gem build mvpa-css.gemspec --output /dev/null] ].freeze

    #: (String) -> String
    def self.version_in(source)
      source[/VERSION = "([^"]+)"/, 1].to_s
    end

    #: (String, Version) -> String
    def self.version_source(source, version)
      source.sub(/VERSION = "[^"]*"/, %(VERSION = "#{version}"))
    end

    #: (String, Release) -> String
    def self.changelog_text(text, release)
      heading = release.notes[/\A## .*$/]
      raise ArgumentError, "#{heading} exists" if text.include?("#{heading}\n")

      first = text.index(/^## \d/) or raise ArgumentError, "no release heading in the changelog"
      text.dup.insert(first, "#{release.notes}\n")
    end
  end
end
