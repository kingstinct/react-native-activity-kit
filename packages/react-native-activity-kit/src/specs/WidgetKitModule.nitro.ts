// TODO: Export specs that extend HybridObject<...> here

import type { AnyMap } from 'react-native-nitro-modules'
import type { HybridObject } from 'react-native-nitro-modules/lib/typescript/HybridObject'
import type { ActivityProxy } from './ActivityProxy.nitro'


export interface WidgetKitModule extends HybridObject<{ ios: 'swift' }> {
  reloadTimeline(
    ofKind: string,
  ): void

  reloadAllTimelines(): void

  reloadControls(
    ofKind: string,
  ): void

    reloadAllControls(): void

    currentConfigurations(): Promise<Array<AnyMap>>

    invalidateRelevance(
    ofKind: string,
  ): void

  invalidateConfigurationRecommendations(
    
  ): void
}
