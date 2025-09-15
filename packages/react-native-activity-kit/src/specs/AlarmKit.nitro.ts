import type { HybridObject } from 'react-native-nitro-modules'
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

export interface AlarmKitModule extends HybridObject<{ ios: 'swift' }> {
  // Permission methods
  requestAuthorization(): Promise<AuthStatus>
  getPermissionStatus(): AuthStatus

  authorizationUpdates(callback: (status: AuthStatus) => void): void

  alarmUpdates(callback: (alarms: Alarm[]) => void): void
  alarms(): Alarm[]

  createCountdown(
    alertTitle: string,
    stopText: string,
    countdownTitle: string,
  ): Promise<Alarm>
}
