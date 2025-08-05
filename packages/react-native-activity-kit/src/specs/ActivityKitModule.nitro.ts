// TODO: Export specs that extend HybridObject<...> here

import type { AnyMap } from 'react-native-nitro-modules'
import type { HybridObject } from 'react-native-nitro-modules/lib/typescript/HybridObject'
import type { ActivityProxy } from './ActivityProxy.nitro'

export interface ActivityKitModule extends HybridObject<{ ios: 'swift' }> {
  startActivity(attributes: AnyMap, state: AnyMap): ActivityProxy
  getActivityById(activityId: string): ActivityProxy | null | undefined
  getAllActivities(): ActivityProxy[]
}
