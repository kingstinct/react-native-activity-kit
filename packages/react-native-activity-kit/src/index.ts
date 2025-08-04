// TODO: Export all HybridObjects here for the user

import { NitroModules } from 'react-native-nitro-modules'
import type { ActivityKitModule } from './specs/ActivityKitModule.nitro'

export const ActivityKit =
  NitroModules.createHybridObject<ActivityKitModule>('ActivityKitModule')
