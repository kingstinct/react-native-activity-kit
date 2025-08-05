// TODO: Export specs that extend HybridObject<...> here

import type { AnyMap } from 'react-native-nitro-modules'
import type { HybridObject } from 'react-native-nitro-modules/lib/typescript/HybridObject'
import type { ActivityProxy } from './ActivityProxy.nitro'

interface PushTypeToken {
  token: true
}

interface PushTypeChannelName {
  channelName: string
}

export interface StartActivityOptions {
  staleDate?: Date
  relevanceScore?: number
  style?: ActivityStyle
  // requires push permissions
  pushType?: PushTypeToken | PushTypeChannelName
}

export enum ActivityStyle {
  standard,
  transient,
}

export interface ActivityKitModule extends HybridObject<{ ios: 'swift' }> {
  startActivity(
    attributes: AnyMap,
    state: AnyMap,
    options?: StartActivityOptions
  ): ActivityProxy
  getActivityById(activityId: string): ActivityProxy | null | undefined
  getAllActivities(): ActivityProxy[]
}
