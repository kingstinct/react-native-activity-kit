---
"@kingstinct/react-native-activity-kit": patch
---

AlarmKit fixes found while debugging a focus timer that could not be stopped:

- `requestAuthorization()` left its continuation unresumed when AlarmKit threw, so the JS promise never settled. It now rejects.
- `cancel()`, `stop()`, `pause()`, `resume()` and `countdown()` throw an `AlarmOperationError` that names the operation, the alarm id, its state and the underlying AlarmKit error instead of a bare error.
- `cancel()` falls back to `stop(id:)` followed by a second `cancel(id:)` when AlarmKit refuses the first cancel, unless stopping already removed the alarm.
- An unknown `Alarm.State` from a newer iOS no longer crashes the app (`fatalError`); it maps to `scheduled`.
- `AlarmKitModule.nitro.ts` re-exports the `AlarmState` enum from `AlarmProxy.nitro.ts` instead of declaring a second enum with a different member order.
- Nitro 0.37: `nitrogen` and `react-native-nitro-modules` bumped to 0.37.1 (`AnyMap` `BigInt` → `Int64`), peer dependency `react-native-nitro-modules >= 0.37.0`.
