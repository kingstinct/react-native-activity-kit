# react-native-activity-kit

## 0.0.11

### Patch Changes

- 9fda584: AlarmKit fixes found while debugging a focus timer that could not be stopped:

  - `requestAuthorization()` left its continuation unresumed when AlarmKit threw, so the JS promise never settled. It now rejects.
  - `cancel()`, `stop()`, `pause()`, `resume()` and `countdown()` throw an `AlarmOperationError` that names the operation, the alarm id, its state and the underlying AlarmKit error instead of a bare error.
  - `cancel()` falls back to `stop(id:)` followed by a second `cancel(id:)` when AlarmKit refuses the first cancel, unless stopping already removed the alarm.
  - An unknown `Alarm.State` from a newer iOS no longer crashes the app (`fatalError`); it maps to `scheduled`.
  - `AlarmKitModule.nitro.ts` re-exports the `AlarmState` enum from `AlarmProxy.nitro.ts` instead of declaring a second enum with a different member order.
  - Nitro 0.37: `nitrogen` and `react-native-nitro-modules` bumped to 0.37.1 (`AnyMap` `BigInt` → `Int64`), peer dependency `react-native-nitro-modules >= 0.37.0`.

## 0.0.10

### Patch Changes

- 259c88e: fix peer deps

## 0.0.9

### Patch Changes

- 3c72e64: fix color conversion

## 0.0.8

### Patch Changes

- eec0382: remove rgbcolors again

## 0.0.7

### Patch Changes

- c382ed2: fix archiving issue

## 0.0.6

### Patch Changes

- 2ef0176: Add alertkit

## 0.0.5

### Patch Changes

- 94e0fa6: fix release

## 0.0.4

### Patch Changes

- f558ff2: fix publishing

## 0.0.3

### Patch Changes

- 5b23def: update readme

## 0.0.2

### Patch Changes

- ecc7881: initial release
