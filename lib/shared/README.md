# Shared Components

This directory contains platform-agnostic code that is shared between web and mobile platforms.

## Structure

- **screens/**: Platform-agnostic screen implementations
- **widgets/**: Reusable components that work on all platforms
- **providers/**: State management (shared across platforms)
- **services/**: Business logic (shared across platforms)
- **models/**: Data models (shared across platforms)

## Usage

Components in this directory should not contain platform-specific code. Use the `PlatformDetector` utility to conditionally render platform-specific UI when needed.
