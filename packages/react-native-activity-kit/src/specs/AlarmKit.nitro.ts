import type { AnyMap, HybridObject } from 'react-native-nitro-modules'
import type { Alarm } from './Alarm.nitro'

export interface AlarmSound {
  name: string
  volume?: number
  useSystemDefault?: boolean
}

export enum AlarmPriority {
  Low = 'low',
  Normal = 'normal',
  High = 'high',
  Critical = 'critical',
}

export enum AlarmState {
  scheduled,
  alerting,
  countdown,
  paused,
}

export interface AlarmConfiguration {
  identifier: string
  title: string
  subtitle?: string
  fireDate: number // timestamp in milliseconds
  repeats?: boolean
  sound?: AlarmSound
  priority?: AlarmPriority
  userInfo?: Record<string, string | number | boolean>
}

export interface AlarmPresentation {
  identifier: string
  state: AlarmState
  configuration: AlarmConfiguration
  actualFireDate?: number
  nextFireDate?: number
}

export interface AlarmUpdateRequest {
  identifier: string
  fireDate?: number
  title?: string
  subtitle?: string
  repeats?: boolean
  sound?: AlarmSound
  priority?: AlarmPriority
  userInfo?: Record<string, string | number | boolean>
}

export enum AuthStatus {
  authorized,
  denied,
  notDetermined,
}

export interface AlarmPermissionStatus {
  granted: boolean
  canAskAgain: boolean
  status: AuthStatus
}

export interface RGBColor {
  red: number // 0-255
  green: number // 0-255
  blue: number // 0-255
  alpha?: number // 0-1, default 1
}

export interface AlarmButtonProps {
  text: string
  textColor: RGBColor
  systemImageName: string
}

enum SecondaryButtonBehavior {
  countdown = 'countdown',
  custom = 'custom',
  none = 'none',
}

export interface AlertPresentation {
  title: string
  stopButton: AlarmButtonProps
  secondaryButton?: AlarmButtonProps
  secondaryButtonBehavior?: SecondaryButtonBehavior // default 'none'
}

export interface CountdownPresentation {
  title: string
  pauseButton?: AlarmButtonProps
}

export interface PausedPresentation {
  title: string
  resumeButton: AlarmButtonProps
}

export interface CountdownProps {
  alert: AlertPresentation
  countdown: CountdownPresentation
  paused?: PausedPresentation

  tintColor: RGBColor

  sound?: string

  metadata: AnyMap

  preAlert: number // in seconds
  postAlert?: number // in seconds
}

export interface AlarmProps {
  alert: AlertPresentation
  paused?: PausedPresentation

  tintColor: RGBColor

  sound?: string

  metadata: AnyMap

  // let's just support exact time for now
  scheduledDate: Date // timestamp in milliseconds
}

export interface AlarmKitModule extends HybridObject<{ ios: 'swift' }> {
  // Permission methods
  requestAuthorization(): Promise<AuthStatus>
  getPermissionStatus(): AuthStatus

  authorizationUpdates(callback: (status: AuthStatus) => void): void

  alarmUpdates(callback: (alarms: Alarm[]) => void): void
  alarms(): Alarm[]

  createCountdown(props: CountdownProps): Promise<Alarm>
  createAlarm(props: AlarmProps): Promise<Alarm>
}
