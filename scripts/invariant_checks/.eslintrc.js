module.exports = {
    "extends": "airbnb-base",
    "env": {
      "browser": true,
      "mocha": true,
    },
    "globals": {
      "$": false,
      "moj": true,
    },
    "rules": {
      "camelcase": ["off"],
      "no-alert": ["off"],
      "import/no-dynamic-require": ["off"],
      "no-use-before-define": ["error", { "classes": false }],
      "no-param-reassign": ["error", { "props": false }],
      "no-underscore-dangle": ["error", { "allow": ["_json"] }],
    }
  };
