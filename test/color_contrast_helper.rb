# WCAG contrast of the OKLCH colors declared in a stylesheet rule body.
module ColorContrastHelper
  private

  # The three dark renderings and the default light one: the palette body and the scale mapping body of each.
  def renderings(css)
    system_dark = rule_bodies(css, ":root").find { |body| body.include?("--color-bg-0: oklch(26.88%") }
    light = rule_bodies(css, ":root").find { |body| body.include?("--color-bg-0: oklch(97.35%") }

    assert system_dark, "no :root body holds the system-dark palette (--color-bg-0: oklch(26.88%)"
    assert light, "no :root body holds the default light palette (--color-bg-0: oklch(97.35%)"
    { "system dark" => { palette: system_dark, mapping: system_dark },
      "solunized-dark" => theme(css, "solunized-dark"),
      "solunized-black" => theme(css, "solunized-black"),
      "system light" => { palette: light, mapping: light } }
  end

  def theme(css, name)
    selector = %([data-theme="#{name}"])
    { palette: rule_bodies(css, selector).find { |body| body.include?("--color-bg-0:") },
      mapping: rule_bodies(css, selector).find { |body| body.include?("--color-bg:") } }
  end

  # The OKLCH color a scale or palette token resolves to, following var() references through the mapping.
  def resolved(rendering, token)
    name = token
    3.times do
      reference = rendering[:mapping][/--color-#{name}:\s*var\(--color-([\w-]+)\)/, 1]
      break unless reference

      name = reference
    end
    oklch(rendering[:palette], name)
  end

  def contrast_between(rendering, foreground, background)
    contrast(luminance(*resolved(rendering, foreground)), luminance(*resolved(rendering, background)))
  end

  def oklch(body, token)
    declared(body, token).match(/oklch\(([\d.]+)%\s+([\d.]+)\s+([\d.]+)\)/).captures.map(&:to_f).tap do |values|
      values[0] /= 100
    end
  end

  def declared(body, token)
    body[/--color-#{token}:\s*([^;]+);/, 1]
  end

  def contrast(first, second)
    light, dark = [ first, second ].max, [ first, second ].min
    (light + 0.05) / (dark + 0.05)
  end

  # Relative luminance (WCAG) of an OKLCH color, through OKLab and linear sRGB.
  def luminance(lightness, chroma, hue)
    a = chroma * Math.cos(hue * Math::PI / 180)
    b = chroma * Math.sin(hue * Math::PI / 180)
    l, m, s = [ lightness + 0.3963377774 * a + 0.2158037573 * b,
                lightness - 0.1055613458 * a - 0.0638541728 * b,
                lightness - 0.0894841775 * a - 1.2914855480 * b ].map { |value| value**3 }
    red = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
    green = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
    blue = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
    0.2126 * red.clamp(0, 1) + 0.7152 * green.clamp(0, 1) + 0.0722 * blue.clamp(0, 1)
  end
end
