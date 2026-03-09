export default {
  ignoreFiles: ["app/assets/stylesheets/mvpa/mvpa.css"],
  plugins: ["stylelint-no-unsupported-browser-features"],
  rules: {
    "at-rule-no-unknown": [true, { ignoreAtRules: ["view-transition"] }],
    "plugin/no-unsupported-browser-features": [
      true,
      {
        ignore: ["css-resize", "css-scrollbar", "css3-cursors"],
        ignorePartialSupport: true,
        severity: "warning"
      }
    ],
    "selector-pseudo-element-no-unknown": [
      true,
      {
        ignorePseudoElements: ["view-transition-new", "view-transition-old"]
      }
    ],
    "selector-type-no-unknown": [
      true,
      {
        ignore: ["custom-elements"]
      }
    ]
  }
};
