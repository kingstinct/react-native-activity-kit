export interface AlarmConfiguration {
  /** Unique identifier for the alarm */
  identifier: string
  /** Display title for the alarm */
  title: string
  /** Optional subtitle */
  subtitle?: string
  /** Scheduled fire date */
  fireDate: Date
  /** Whether the alarm repeats */
  repeats?: boolean
  /** Sound configuration */
  sound?: AlarmSound
  /** Priority level */
  priority?: AlarmPriority
  /** Custom user info */
  userInfo?: Record<string, string | number | boolean>
}

export interface AlarmSound {
  /** Sound name or path */
  name: string
  /** Volume level (0.0 - 1.0) */
  volume?: number
  /** Whether to use system default sound */
  useSystemDefault?: boolean
}

export enum AlarmPriority {
  Low = 'low',
  Normal = 'normal',
  High = 'high',
  Critical = 'critical',
}

export enum AlarmState {
  Scheduled = 'scheduled',
  Fired = 'fired',
  Dismissed = 'dismissed',
  Snoozed = 'snoozed',
  Cancelled = 'cancelled',
}

export interface AlarmPresentation {
  /** The alarm identifier */
  identifier: string
  /** Current state */
  state: AlarmState
  /** Configuration used to create the alarm */
  configuration: AlarmConfiguration
  /** Actual fire date */
  actualFireDate?: Date
  /** Next fire date for repeating alarms */
  nextFireDate?: Date
}

export interface AlarmUpdateRequest {
  /** Alarm identifier to update */
  identifier: string
  /** New fire date */
  fireDate?: Date
  /** New title */
  title?: string
  /** New subtitle */
  subtitle?: string
  /** Whether to enable/disable repeats */
  repeats?: boolean
  /** Sound configuration */
  sound?: AlarmSound
  /** Priority level */
  priority?: AlarmPriority
  /** Custom user info */
  userInfo?: Record<string, string | number | boolean>
}

export interface AlarmPermissionStatus {
  /** Whether alarm permissions are granted */
  granted: boolean
  /** Whether the user can be prompted again */
  canAskAgain: boolean
  /** Specific permission status */
  status: 'granted' | 'denied' | 'not-determined' | 'provisional'
}

export interface AlarmEventSubscription {
  /** Remove the event listener */
  remove: () => void
}

export type AlarmEventListener = (alarm: AlarmPresentation) => void

export interface AlarmKitError extends Error {
  code: AlarmErrorCode
  userInfo?: Record<string, string | number | boolean>
}

export enum AlarmErrorCode {
  PermissionDenied = 'PERMISSION_DENIED',
  AlarmNotFound = 'ALARM_NOT_FOUND',
  InvalidConfiguration = 'INVALID_CONFIGURATION',
  SystemError = 'SYSTEM_ERROR',
  UnsupportedPlatform = 'UNSUPPORTED_PLATFORM',
  AlarmLimitExceeded = 'ALARM_LIMIT_EXCEEDED',
}
