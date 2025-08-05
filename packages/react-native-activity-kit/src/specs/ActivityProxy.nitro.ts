import type { AnyMap, HybridObject } from 'react-native-nitro-modules'

export enum ActivityState {
  active,
  dismissed,
  ended,
  stale,
  none,
}

export interface ActivityProxy extends HybridObject<{ ios: 'swift' }> {
  readonly id: string
  readonly activityState: ActivityState
  readonly pushToken?: string

  update(state: AnyMap): void
  end(state: AnyMap): void
}
