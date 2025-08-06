import type { AnyMap, HybridObject } from 'react-native-nitro-modules'

export enum ActivityState {
  active,
  dismissed,
  ended,
  stale,
  none,
}

export interface AlertConfiguration {
  title: string
  body: string
  sound?: string
}

export interface UpdateOptions {
  timestamp?: Date
  alertConfiguration?: AlertConfiguration
  staleDate?: Date
  relevanceScore?: number
  mergeWithPreviousState?: boolean
}

export interface EndOptions {
  timestamp?: Date
  dismissalPolicy?: Date // undefined = default, less than now = end immediately, greater than now = end at that time
  staleDate?: Date
  relevanceScore?: number
  mergeWithPreviousState?: boolean
}

export interface ActivityStateUpdate {
  state: AnyMap
  staleDate?: Date
  relevanceScore?: number
}

export interface ActivityProxy extends HybridObject<{ ios: 'swift' }> {
  readonly id: string
  readonly activityState: ActivityState
  readonly pushToken?: string

  readonly attributes: AnyMap
  readonly state: AnyMap
  readonly staleDate?: Date
  readonly relevanceScore?: number
  
  subscribeToPushTokenUpdates(callback: (token: string) => void): void
  subscribeToActivityStateUpdates(callback: (state: ActivityState) => void): void
  subscribeToStateUpdates(callback: (state: ActivityStateUpdate) => void): void

  update(state: AnyMap, options?: UpdateOptions): void
  end(state: AnyMap, options?: EndOptions): void
}
