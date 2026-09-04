export default {
  ignoreFiles: ["app/assets/stylesheets/mvpa/mvpa.css"],
  plugins: ["stylelint-no-unsupported-browser-features", "stylelint-csstree-validator"],
  rules: {
    "at-rule-no-unknown": [true, { ignoreAtRules: ["view-transition"] }],
    "csstree/validator": true,
    "plugin/no-unsupported-browser-features": [
      true,
      {
        ignore: ["css-resize", "css-scrollbar", "css3-cursors"],
        ignorePartialSupport: true
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
