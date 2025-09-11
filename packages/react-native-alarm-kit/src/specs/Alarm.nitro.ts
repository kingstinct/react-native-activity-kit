import type { HybridObject } from 'react-native-nitro-modules'

export enum AlarmState {
  scheduled,
  countdown,
  paused,
  alerting,
}

export interface Alarm extends HybridObject<{ ios: 'swift' }> {
  // Permission methods
  id: string
  state: AlarmState

  postAlert?: number
  preAlert?: number
}
