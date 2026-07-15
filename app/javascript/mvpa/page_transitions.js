// Tags each cross-document navigation as "forward" or "backward" by
// comparing the current page's position in the sidebar <nav> against the
// destination's position — not by relying on the browser back/forward
// button, since clicking deeper into the nav in a different order than
// the sidebar lists it should still animate correctly either way.
//
// Deliberately does NOT use event.viewTransition.types +
// :active-view-transition-type() — that mechanism was built and confirmed,
// via a test that makes the entire page flash a solid color whenever a
// type is active, to never actually take effect in real-world testing,
// despite every individual piece of the API (CSS.supports(), 'onpageswap'
// in window, event.viewTransition.types accepting .add() calls) reporting
// or behaving as if it were supported. sessionStorage + a plain
// data-attribute (set by a synchronous inline script at the top of each
// page's <head> — see README) is used instead; both are ordinary
// primitives with a long track record, unlike this specific corner of the
// View Transitions spec.
window.addEventListener("pageswap", (event) => {
  if (!event.viewTransition) return;
  if (!event.activation) return;

  const links = Array.from(document.querySelectorAll("body > header nav a[href]"));
  // Use event.activation.from/.entry rather than the ambient location
  // object — by the time this handler runs, the browser's location may
  // already reflect the destination, which would silently make
  // fromIndex === toIndex and break direction detection on every navigation.
  const fromIndex = links.findIndex((a) => a.href === event.activation.from.url);
  const toIndex = links.findIndex((a) => a.href === event.activation.entry.url);

  if (fromIndex === -1 || toIndex === -1) return; // destination isn't in the sidebar nav — no direction, plain fallback slide applies

  sessionStorage.setItem("mvpaTransitionDirection", toIndex > fromIndex ? "forward" : "backward");
});
