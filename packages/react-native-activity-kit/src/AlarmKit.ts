import { Platform } from 'react-native'
import { NitroModules } from 'react-native-nitro-modules'
import type { Alarm } from './specs/Alarm.nitro'
import type { AlarmKitModule, AuthStatus } from './specs/AlarmKit.nitro'
import type {
  AlarmConfiguration,
  AlarmEventListener,
  AlarmEventSubscription,
  AlarmKitError,
  AlarmPermissionStatus,
  AlarmPresentation,
  AlarmUpdateRequest,
} from './types'
import { AlarmErrorCode } from './types'

const PLATFORM_IOS = Platform.OS === 'ios'
const MIN_IOS_VERSION = 16

function checkPlatformSupport(): void {
  if (!PLATFORM_IOS) {
    throw createError(
      AlarmErrorCode.UnsupportedPlatform,
      'AlarmKit is only supported on iOS 16.0+',
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

class AlarmKit {
  private hybridObject: AlarmKitModule

  constructor() {
    checkPlatformSupport()
    this.hybridObject =
      NitroModules.createHybridObject<AlarmKitModule>('AlarmKitModule')
  }

  // Permission methods
  async requestAuthorization(): Promise<AuthStatus> {
    try {
      return await this.hybridObject.requestAuthorization()
    } catch (error: any) {
      throw createError(
        AlarmErrorCode.PermissionDenied,
        'Failed to request alarm permissions',
        {
          originalError: error?.message || 'Unknown error',
        },
      )
    }
  }

  async createCountdown(
    alertTitle: string,
    stopText: string,
    countdownTitle: string,
    countdownDurationInSeconds: number = 60,
  ): Promise<Alarm> {
    return this.hybridObject.createCountdown({
      tintColor: { red: 0, green: 0.478, blue: 1, alpha: 1 },
      alert: {
        title: alertTitle,
        stopButton: {
          text: stopText,
          systemImageName: 'stop.fill',
          textColor: { red: 1, green: 1, blue: 1, alpha: 1 },
        },
      },
      countdown: {
        title: countdownTitle,
      },
      preAlert: countdownDurationInSeconds,
      metadata: {
        timerFiringAt: Date.now() + countdownDurationInSeconds * 1000,
      },
    })
  }

  /*async getPermissionStatus(): Promise<AlarmPermissionStatus> {
    try {
      return await this.hybridObject.getPermissionStatus()
    } catch (error: any) {
      throw createError(
        AlarmErrorCode.SystemError,
        'Failed to get permission status',
        {
          originalError: error?.message || 'Unknown error',
        },
      )
    }
  }

  // Alarm management
  async scheduleAlarm(configuration: AlarmConfiguration): Promise<string> {
    try {
      this.validateAlarmConfiguration(configuration)

      const serializedConfig = {
        ...configuration,
        fireDate: configuration.fireDate.getTime(),
      }

      return await this.hybridObject.scheduleAlarm(serializedConfig)
    } catch (error: any) {
      if (error.code) {
        throw error // Re-throw AlarmKitError
      }
      throw createError(
        AlarmErrorCode.SystemError,
        'Failed to schedule alarm',
        {
          originalError: error?.message || 'Unknown error',
        },
      )
    }
  }

  async updateAlarm(request: AlarmUpdateRequest): Promise<boolean> {
    try {
      const serializedRequest = {
        ...request,
        fireDate: request.fireDate?.getTime(),
      }

      return await this.hybridObject.updateAlarm(serializedRequest)
    } catch (error: any) {
      throw createError(AlarmErrorCode.SystemError, 'Failed to update alarm', {
        originalError: error?.message || 'Unknown error',
      })
    }
  }

  async cancelAlarm(identifier: string): Promise<boolean> {
    try {
      if (!identifier || identifier.trim().length === 0) {
        throw createError(
          AlarmErrorCode.InvalidConfiguration,
          'Alarm identifier cannot be empty',
        )
      }

      return await this.hybridObject.cancelAlarm(identifier)
    } catch (error: any) {
      if (error.code) {
        throw error
      }
      throw createError(
        AlarmErrorCode.AlarmNotFound,
        'Failed to cancel alarm',
        {
          identifier,
          originalError: error?.message || 'Unknown error',
        },
      )
    }
  }

  async cancelAllAlarms(): Promise<number> {
    try {
      return await this.hybridObject.cancelAllAlarms()
    } catch (error: any) {
      throw createError(
        AlarmErrorCode.SystemError,
        'Failed to cancel all alarms',
        {
          originalError: error?.message || 'Unknown error',
        },
      )
    }
  }

  // Alarm queries
  async getScheduledAlarms(): Promise<AlarmPresentation[]> {
    try {
      const alarms = await this.hybridObject.getScheduledAlarms()
      return alarms.map(this.deserializeAlarmPresentation)
    } catch (error: any) {
      throw createError(
        AlarmErrorCode.SystemError,
        'Failed to get scheduled alarms',
        {
          originalError: error?.message || 'Unknown error',
        },
      )
    }
  }

  async getAlarm(identifier: string): Promise<AlarmPresentation | null> {
    try {
      if (!identifier || identifier.trim().length === 0) {
        throw createError(
          AlarmErrorCode.InvalidConfiguration,
          'Alarm identifier cannot be empty',
        )
      }

      const alarm = await this.hybridObject.getAlarm(identifier)
      return alarm ? this.deserializeAlarmPresentation(alarm) : null
    } catch (error: any) {
      if (error.code) {
        throw error
      }
      throw createError(AlarmErrorCode.AlarmNotFound, 'Failed to get alarm', {
        identifier,
        originalError: error?.message || 'Unknown error',
      })
    }
  }

  async getAlarmCount(): Promise<number> {
    try {
      return await this.hybridObject.getAlarmCount()
    } catch (error: any) {
      throw createError(
        AlarmErrorCode.SystemError,
        'Failed to get alarm count',
        {
          originalError: error?.message || 'Unknown error',
        },
      )
    }
  }

  // Alarm actions
  async dismissAlarm(identifier: string): Promise<boolean> {
    try {
      if (!identifier || identifier.trim().length === 0) {
        throw createError(
          AlarmErrorCode.InvalidConfiguration,
          'Alarm identifier cannot be empty',
        )
      }

      return await this.hybridObject.dismissAlarm(identifier)
    } catch (error: any) {
      if (error.code) {
        throw error
      }
      throw createError(
        AlarmErrorCode.AlarmNotFound,
        'Failed to dismiss alarm',
        {
          identifier,
          originalError: error?.message || 'Unknown error',
        },
      )
    }
  }

  async snoozeAlarm(
    identifier: string,
    snoozeInterval: number,
  ): Promise<boolean> {
    try {
      if (!identifier || identifier.trim().length === 0) {
        throw createError(
          AlarmErrorCode.InvalidConfiguration,
          'Alarm identifier cannot be empty',
        )
      }

      if (snoozeInterval <= 0) {
        throw createError(
          AlarmErrorCode.InvalidConfiguration,
          'Snooze interval must be greater than 0',
        )
      }

      return await this.hybridObject.snoozeAlarm(identifier, snoozeInterval)
    } catch (error: any) {
      if (error.code) {
        throw error
      }
      throw createError(
        AlarmErrorCode.AlarmNotFound,
        'Failed to snooze alarm',
        {
          identifier,
          originalError: error?.message || 'Unknown error',
        },
      )
    }
  }

  // Event subscription
  addAlarmFireListener(listener: AlarmEventListener): AlarmEventSubscription {
    this.hybridObject.addAlarmFireListener((alarm) => {
      listener(this.deserializeAlarmPresentation(alarm))
    })

    return {
      remove: () => {
        // In a full implementation, we would track listeners and remove them
        // For now, this is a placeholder
      },
    }
  }

  addAlarmDismissListener(
    listener: AlarmEventListener,
  ): AlarmEventSubscription {
    this.hybridObject.addAlarmDismissListener((alarm) => {
      listener(this.deserializeAlarmPresentation(alarm))
    })

    return {
      remove: () => {
        // Placeholder - would need proper listener management
      },
    }
  }

  addAlarmSnoozeListener(listener: AlarmEventListener): AlarmEventSubscription {
    this.hybridObject.addAlarmSnoozeListener((alarm) => {
      listener(this.deserializeAlarmPresentation(alarm))
    })

    return {
      remove: () => {
        // Placeholder - would need proper listener management
      },
    }
  }

  addAlarmCancelListener(listener: AlarmEventListener): AlarmEventSubscription {
    this.hybridObject.addAlarmCancelListener((alarm) => {
      listener(this.deserializeAlarmPresentation(alarm))
    })

    return {
      remove: () => {
        // Placeholder - would need proper listener management
      },
    }
  }

  // Private methods
  private validateAlarmConfiguration(config: AlarmConfiguration): void {
    if (!config.identifier || config.identifier.trim().length === 0) {
      throw createError(
        AlarmErrorCode.InvalidConfiguration,
        'Alarm identifier is required',
      )
    }

    if (!config.title || config.title.trim().length === 0) {
      throw createError(
        AlarmErrorCode.InvalidConfiguration,
        'Alarm title is required',
      )
    }

    if (!(config.fireDate instanceof Date)) {
      throw createError(
        AlarmErrorCode.InvalidConfiguration,
        'Fire date must be a Date object',
      )
    }

    if (config.fireDate <= new Date()) {
      throw createError(
        AlarmErrorCode.InvalidConfiguration,
        'Fire date must be in the future',
      )
    }

    if (config.sound?.volume !== undefined) {
      if (config.sound.volume < 0 || config.sound.volume > 1) {
        throw createError(
          AlarmErrorCode.InvalidConfiguration,
          'Sound volume must be between 0 and 1',
        )
      }
    }
  }

  private deserializeAlarmPresentation(alarm: any): AlarmPresentation {
    return {
      ...alarm,
      configuration: {
        ...alarm.configuration,
        fireDate: new Date(alarm.configuration.fireDate),
      },
      actualFireDate: alarm.actualFireDate
        ? new Date(alarm.actualFireDate)
        : undefined,
      nextFireDate: alarm.nextFireDate
        ? new Date(alarm.nextFireDate)
        : undefined,
    }
  }*/
}

export default new AlarmKit()
