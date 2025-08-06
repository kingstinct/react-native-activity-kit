const {
  withPlugins,
  createRunOncePlugin,
  withInfoPlist,
} = require('@expo/config-plugins')

/**
 * @typedef ConfigPlugin
 * @type {import('@expo/config-plugins').ConfigPlugin<T>}
 * @template T = void
 */

/**
 * @typedef ActivityKitConfig
 * @type {{
 *   NSSupportsLiveActivities?: boolean,
 *   NSSupportsLiveActivitiesFrequentUpdates?: boolean
 * }}
 */

/**
 * Adds NSSupportsLiveActivities to Info.plist for iOS Live Activities support
 * @type {ConfigPlugin<ActivityKitConfig>}
 */
const withInfoPlistPlugin = (config, props) =>
  withInfoPlist(config, (configPlist) => {
    // Enable Live Activities support by default, allow opt-out
    const supportsLiveActivities = props?.NSSupportsLiveActivities !== false
    configPlist.modResults.NSSupportsLiveActivities = supportsLiveActivities

    // Only enable FrequentUpdates if explicitly set to true
    if (props?.NSSupportsLiveActivitiesFrequentUpdates === true) {
      configPlist.modResults.NSSupportsLiveActivitiesFrequentUpdates = true
    }

    return configPlist
  })

/**
 * Main plugin that configures iOS for Live Activities
 * @type {ConfigPlugin<ActivityKitConfig>}
 */
const activityKitAppPlugin = (config, props) =>
  withPlugins(config, [[withInfoPlistPlugin, props]])

const pkg = require('./package.json')

/**
 * @type {ConfigPlugin<ActivityKitConfig>}
 */
module.exports = createRunOncePlugin(
  activityKitAppPlugin,
  pkg.name,
  pkg.version,
)
