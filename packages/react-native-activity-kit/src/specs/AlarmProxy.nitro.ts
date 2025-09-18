import type { HybridObject } from 'react-native-nitro-modules'

export enum AlarmState {
  scheduled,
  countdown,
  paused,
  alerting,
}

export interface AlarmProxy extends HybridObject<{ ios: 'swift' }> {
  // Permission methods
  readonly id: string
  readonly state: AlarmState

  readonly postAlert?: number
  readonly preAlert?: number

  cancel(): void
  countdown(): void
  pause(): void
  resume(): void
  stop(): void
}
