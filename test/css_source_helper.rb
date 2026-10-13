# Reads the stylesheet partials and the packaged manifest, and finds rule bodies by selector.
module CssSourceHelper
  STYLE_ROOT = File.expand_path("../app/assets/stylesheets/mvpa", __dir__)

  def partial(path)
    File.read(File.join(STYLE_ROOT, path))
  end

  def bundle
    @bundle ||= partial("mvpa.css")
  end

  # Bodies of every rule whose selector list contains +selector+ as one whole entry.
  def rule_bodies(css, selector)
    entry = /(?:\A|[,{};]|\*\/)\s*#{Regexp.escape(selector)}\s*(?:,[^{}]*)?\{([^{}]*)\}/m
    css.scan(entry).flatten
  end

  def rule_body(css, selector)
    rule_bodies(css, selector).first.to_s
  end

  # Yields [source name, css] for the partial and the bundle, so each assertion covers both.
  def each_source(path)
    yield path, partial(path)
    yield "mvpa.css", bundle
  end
end
