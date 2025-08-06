/** @type {import('@bacons/apple-targets/app.plugin').ConfigFunction} */
module.exports = (_config) => ({
  type: 'widget',
  icon: 'https://github.com/expo.png',
  entitlements: {
    /* Add entitlements */
  },
  deploymentTarget: '18.0', // Required for ActivityKit support
})
