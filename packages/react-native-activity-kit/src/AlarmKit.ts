import { Platform } from 'react-native'
import { NitroModules } from 'react-native-nitro-modules'
import type { AlarmKitModule } from './specs/AlarmKitModule.nitro'
import type { AlarmKitError } from './types'
import { AlarmErrorCode } from './types'

const PLATFORM_IOS = Platform.OS === 'ios'
const MIN_IOS_VERSION = 26

export function isSupported(): void {
  if (!PLATFORM_IOS) {
    throw createError(
      AlarmErrorCode.UnsupportedPlatform,
      'AlarmKit is only supported on iOS 26.0+',
    )
  }

  const iosVersion = Platform.Version
  if (typeof iosVersion === 'string') {
    const majorVersion = Number.parseInt(iosVersion.split('.')[0] || '0', 10)
    if (majorVersion < MIN_IOS_VERSION) {
      throw createError(
        AlarmErrorCode.UnsupportedPlatform,
        `AlarmKit requires iOS ${MIN_IOS_VERSION}.0 or later. Current version: ${iosVersion}`,
      )
    }
  }
}

function createError(
  code: AlarmErrorCode,
  message: string,
  userInfo?: Record<string, string | number | boolean>,
): AlarmKitError {
  const error = new Error(message) as AlarmKitError
  error.code = code
  if (userInfo) {
    error.userInfo = userInfo
  }
  return error
}

export default NitroModules.createHybridObject<AlarmKitModule>('AlarmKitModule')
