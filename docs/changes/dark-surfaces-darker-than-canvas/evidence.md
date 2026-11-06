# Evidence: dark-surfaces-darker-than-canvas

Browser check of plan step 10, run on 2026-11-06 against commit b63d45d with headless Google Chrome (`--screenshot`) on `demo.html` and on a minimal page that links the same partials.

## Seen

- `data-theme="solunized-dark"`: the sidebar card and the articles are darker than the page. Links are the brighter blue. The current-page sidebar link text reads on its blue fill.
- `data-theme="solunized-black"`: the same layering. Links and the current-page link text read.
- `solunized-light`: page and surfaces look as on `main`.
- Segmented control, `solunized-dark`: the selected segment is darker than its track. On `main` it was lighter. The CHANGELOG says so.
- Period navigation inside an article, `solunized-dark`: the bar is lighter than the article. On `main` it was darker. This is the accepted inset exception.
- Mobile tab bar at 600px wide, `solunized-dark`: the tab items are lighter pills on a darker bar. The current tab is blue.
- Unvisited links in a period navigation and in an article paragraph show the brighter blue.

## Not seen

- System dark with no `data-theme`: headless Chrome ignored `--blink-settings=preferredColorScheme=1`, so the default rendering was not emulated. `test/dark_surface_layering_test.rb` and `test/link_colour_test.rb` cover it from the CSS.
- A visited link: headless Chrome paints no visited state, so the brighter violet is covered by `test_visited_links_on_the_dark_canvas_reach_4_5` only.
