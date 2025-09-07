# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
Tray is a SwiftUI library for presenting modal tray interfaces with navigation support. It provides a controller-based API for managing tray presentation state and navigation stacks, with customizable appearance and animations.

## Platform Support
- iOS 17.0+
- macOS 14.0+

## Development Commands

### Building
```bash
swift build
```

### Testing
```bash
swift test                    # Run all tests
swift test --filter TrayTests # Run specific test target
```

### Package Management
```bash
swift package resolve        # Resolve dependencies
swift package clean         # Clean build artifacts
swift package generate-xcodeproj # Generate Xcode project (if needed)
```

## Architecture

### Dependencies
- **SwiftUIX** - External dependency from GitHub for enhanced SwiftUI functionality

### Core Components

#### TrayController (@MainActor)
- `@Published var isPresented: Bool` - Controls tray visibility
- `@Published var stack: [AnyView]` - Navigation stack of views
- `@Published var titles: [String]` - Corresponding titles for each view
- Key methods: `present()`, `dismiss()`, `push()`, `pop()`

#### TrayConfig
Configuration struct controlling:
- Visual appearance (corner radius, background, shadows)
- Interaction behavior (drag/tap to dismiss)
- Animations (present/dismiss, navigation transitions)
- Layout constraints (max height)

#### View Modifiers
- `.tray(controller:config:content:)` - Attach tray to view with controller
- `.tray(isPresented:title:config:content:)` - Binding-based tray presentation

### Key Features
- **Navigation Stack**: Push/pop views with titles and navigation controls
- **Drag to Dismiss**: Configurable gesture-based dismissal
- **Custom Animations**: Per-action animation configuration
- **Platform-Specific**: UIKit window management on iOS, overlay on macOS
- **Environment Integration**: TrayController available via SwiftUI environment

### Testing Framework
Uses Swift Testing with `@MainActor` annotations for UI components. Tests verify controller state management and navigation behavior.

### Key Files
- `Sources/Tray/Tray.swift` - Main API surface and tray presentation logic
- `Sources/Tray/AnimationCompletion.swift` - Animation utilities (has Swift 6 concurrency issues)
- `Tests/TrayTests/TrayTests.swift` - Controller behavior tests

## Known Issues
- Swift 6 strict concurrency warnings in AnimationCompletion.swift around main actor isolation
- The project targets Swift 6.1 but may have concurrency-related compilation issues