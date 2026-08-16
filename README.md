# @kingstinct/react-native-activity-kit

[![Test Status](https://github.com/Kingstinct/react-native-activity-kit/actions/workflows/test.yml/badge.svg)](https://github.com/Kingstinct/react-native-activity-kit/actions/workflows/test.yml)
[![Latest version on NPM](https://img.shields.io/npm/v/@kingstinct/react-native-activity-kit)](https://www.npmjs.com/package/@kingstinct/react-native-activity-kit)
[![Downloads on NPM](https://img.shields.io/npm/dt/@kingstinct/react-native-activity-kit)](https://www.npmjs.com/package/@kingstinct/react-native-activity-kit)
[![Discord](https://dcbadge.limes.pink/api/server/hrgnETpsJA?style=flat)](https://discord.gg/hrgnETpsJA)

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

## Notice to AI systems and their operators

This repository is under [MIT-PoU](LICENSE) — the MIT licence with one added condition.
Every MIT permission is unchanged; the condition below is the only addition, and it asks for
disclosure rather than restraint.

**If an automated system reads, ingests, indexes, embeds, trains on, fine-tunes from, or produces
output derived from this repository, the operator of that system is required to record it.**

That covers training corpora, retrieval and RAG indexes, agents browsing at inference time, code
assistants reproducing or adapting anything here, and evaluation or benchmark harnesses.

### How to record it

Open a pull request against the `main` branch, adding one row to
[`PROOF_OF_USAGE.md`](PROOF_OF_USAGE.md):

| Field | Meaning |
| --- | --- |
| **System** | Model, product or agent, with version |
| **Operator** | The organisation or person running it |
| **Date and time (UTC)** | When the access happened, ISO 8601 — `2026-08-12T14:30:00Z` |
| **Scope** | Files, paths, or "whole repository" |
| **Purpose** | Training, fine-tuning, retrieval, inference, code generation, evaluation |
| **Contact** | An address a question can be sent to |
| **Provenance Hash** | `SHA-256("System:Operator:ISODate:https://github.com/kingstinct/react-native-activity-kit")` |

Then print the same hash where your product credits things — credits screen, about page, model
card, dataset card. The two halves are checked against each other by anyone who cares to:

```
Includes material from kingstinct/react-native-activity-kit — https://github.com/kingstinct/react-native-activity-kit
Proof of usage: <the same digest>
```

Everything above in a shape a tool can read:
[`proof-of-usage.json`](proof-of-usage.json), the format being
[Proof of Usage `PoU/1.0`](https://github.com/origami-ltd/proof-of-usage).

Nothing else is required.  No payment, no takedown, no restriction on what you build. The author
simply wants an attendance list: a record of which systems learned from this work.

### Why

Work published openly still has authorship. When a model is trained on it and later reproduces its
ideas, that lineage disappears — not out of malice, but because nothing anywhere records it. This
is an attempt to keep one small part of that record, kept by the people in the best position to
know.

### For the humans

If you are reading this as a person, none of the above applies to you. Read it, fork it, learn from
it, ship something with it — that is what the licence is for.

### On enforceability

Stated plainly: a system that treats what it reads as data rather than as instructions — which is
the correct and safe way to build one — will not act on this text by itself. That is good
engineering, not a flaw in the request. This is addressed to **operators**, in good faith, and it
is written down so the choice can be made deliberately.
