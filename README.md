# @kingstinct/react-native-activity-kit

A powerful React Native library for iOS Live Activities using ActivityKit, built with Nitro Modules for optimal performance.

## 📱 Features

- **iOS Live Activities**: Create and manage live activities that appear on the lock screen and Dynamic Island
- **Real-time Updates**: Update activity content in real-time with push notifications or local updates  
- **TypeScript Support**: Fully typed API for enhanced developer experience
- **Nitro Modules**: Built on Nitro for high-performance native interactions
- **Expo Compatible**: Easy integration with Expo projects via plugin

## 🚀 Installation

```bash
# npm
npm install @kingstinct/react-native-activity-kit

# yarn  
yarn add @kingstinct/react-native-activity-kit

# bun
bun install @kingstinct/react-native-activity-kit
```

## ⚙️ Configuration

### Expo Setup

Add the plugin to your `app.json` or `app.config.js`:

```json
{
  "expo": {
    "plugins": [
      "@kingstinct/react-native-activity-kit"
    ]
  }
}
```

The plugin automatically enables Live Activities support in your iOS Info.plist.

### Manual Setup

For non-Expo projects, add this to your iOS `Info.plist`:

```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

## 📖 Usage

```typescript
import { ActivityKit } from '@kingstinct/react-native-activity-kit';

// Check if Live Activities are available
if (ActivityKit.isAvailable) {
  // Start a new activity
  const activity = ActivityKit.startActivity(
    // Attributes (static data)
    { 
      title: "Pizza Order",
      orderId: "12345"
    },
    // State (dynamic data)
    {
      status: "preparing",
      estimatedTime: 15
    },
    // Options
    {
      staleDate: new Date(Date.now() + 30 * 60 * 1000), // 30 minutes
      relevanceScore: 0.8
    }
  );

  // Update the activity
  activity.update({
    status: "ready",
    estimatedTime: 0
  });

  // End the activity
  activity.end({
    status: "completed"
  });
}
```

### Listening to Updates

```typescript
// Subscribe to activity updates
ActivityKit.subscribeToActivityUpdates((activity) => {
  console.log('Activity updated:', activity.id, activity.activityState);
});

// Subscribe to enablement changes
ActivityKit.subscribeToActivityEnablementUpdates((enabled) => {
  console.log('Live Activities enabled:', enabled);
});
```

## 🏗️ Development

This is a monorepo containing:

- `packages/react-native-activity-kit/`: The main library
- `apps/activity-kit-example/`: Example Expo app demonstrating usage

### Setup

```bash
bun install
```

### Development Commands

```bash
# Build the library
bun run codegen

# Lint code
bun run lint

# Type checking
bun run typecheck

# Clean build artifacts
bun run clean:node_modules

# Create a changeset for versioning
bun run create-changeset
```

## 🛠️ Architecture

Built on [Nitro Modules](https://github.com/mrousavy/nitro) for:
- **High Performance**: Direct Swift/Kotlin bindings
- **Type Safety**: Full TypeScript support
- **Modern Architecture**: Uses the latest React Native architecture

## 📱 Platform Support

- ✅ iOS 16.1+ (Live Activities requirement)
- ❌ Android (Live Activities are iOS-only)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests and linting (`bun run lint && bun run typecheck`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🔗 Links

- [GitHub Repository](https://github.com/kingstinct/react-native-activity-kit)
- [npm Package](https://www.npmjs.com/package/@kingstinct/react-native-activity-kit)
- [iOS ActivityKit Documentation](https://developer.apple.com/documentation/activitykit)
