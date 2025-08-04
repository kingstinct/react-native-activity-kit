// TODO: Export specs that extend HybridObject<...> here

import type { AnyMap } from 'react-native-nitro-modules'
import type { HybridObject } from 'react-native-nitro-modules/lib/typescript/HybridObject'

interface Activity {
  id: string
}

export interface ActivityKitModule extends HybridObject<{ios:'swift'}> {
  startActivity(data: AnyMap): Promise<Activity>
  updateActivity(activityId: string, data: AnyMap): Promise<Activity>
  endActivity(activityId: string): Promise<void>
  listActivities(): Promise<Activity[]>
}
