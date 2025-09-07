# Tray

A SwiftUI library for presenting modal tray interfaces with smooth navigation and customizable animations.

## Overview

Tray provides a modern, iOS-style modal presentation system with:
- **Flexible Navigation**: Use `TrayNavigationLink` to navigate between any views
- **Dynamic Height**: Automatically adjusts to content size
- **Smooth Animations**: Configurable transitions and animations
- **Per-Page Control**: Individual navigation bar visibility and styling
- **Environment Configuration**: Global styling through environment modifiers

## Installation

Add Tray to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/Archetapp/Tray", branch: "main")
]
```

## Quick Start

### Basic Tray

```swift
import SwiftUI

struct ContentView: View {
    @State private var showTray = false
    
    var body: some View {
        Button("Show Tray") {
            showTray = true
        }
        .tray(isPresented: $showTray, title: "Welcome") {
            WelcomeView()
        }
    }
}
```

### Navigation Between Views

Use `TrayNavigationLink` to navigate between different views:

```swift
struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome!")
            
            TrayNavigationLink(title: "Settings") {
                SettingsView()
            } label: {
                Text("Open Settings")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}
```

### Dismissing the Tray

Access the tray controller from any view:

```swift
struct SettingsView: View {
    @Environment(\.trayController) var tray
    
    var body: some View {
        VStack {
            Text("Settings")
            
            Button("Close Tray") {
                tray.dismiss()
            }
        }
    }
}
```

## Configuration

### Global Styling

Configure tray appearance using environment modifiers:

```swift
ContentView()
    .tray(isPresented: $showTray) {
        MyTrayContent()
    }
    .trayPadding(16)                           // Padding around tray
    .trayAnimation(.spring())                  // Global animations
    .trayDefaultPageTransition(.slide)        // Page transitions
    .trayShowsNavigationProgressBar(true)     // Progress indicator
```

### Per-Page Navigation Bar Control

Hide or show the navigation bar for specific pages:

```swift
TrayNavigationLink(title: "Full Screen", showsNavigationBar: false) {
    FullScreenView()
} label: {
    Text("Go Full Screen")
}
```

### Custom Transitions

Configure different transitions for different interactions:

```swift
.trayAnimation(.bouncy)                    // All animations
.trayDefaultPageTransition(.blur)         // Content transitions
```

## Available Modifiers

### Environment Modifiers

Apply these to your view hierarchy to configure all trays within scope:

| Modifier | Purpose |
|----------|---------|
| `.trayPadding(_:)` | Set uniform padding around tray |
| `.trayPadding(horizontal:bottom:)` | Set specific padding |
| `.trayAnimation(_:)` | Configure all tray animations |
| `.trayDefaultPageTransition(_:)` | Set page transition animation |
| `.trayShowsNavigationBar(_:)` | Global navigation bar visibility |
| `.trayShowsNavigationProgressBar(_:)` | Show step progress indicator |

### TrayNavigationLink Parameters

Control navigation behavior per link:

```swift
TrayNavigationLink(
    title: "Page Title",              // Navigation bar title
    showsNavigationBar: false         // Hide nav bar for this page
) {
    DestinationView()                 // The view to navigate to
} label: {
    Text("Navigate")                  // The clickable content
}
```

## Advanced Usage

### Custom Configuration

Create a custom tray configuration:

```swift
let config = TrayConfig(
    cornerRadius: 24,
    background: Color.systemBackground,
    maxHeight: 600,
    pageTransition: .slide
)

ContentView()
    .tray(isPresented: $showTray, config: config) {
        MyContent()
    }
```

### Glass Background (iOS 18+)

Use modern iOS glass materials for beautiful translucent backgrounds:

```swift
ContentView()
    .tray(isPresented: $showTray) {
        MyContent()
    }
    .trayBackground(.regularMaterial)           // Standard glass
    .trayBackground(.thickMaterial)             // Thicker glass
    .trayBackground(.thinMaterial)              // Lighter glass
    .trayBackground(.ultraThinMaterial)         // Minimal glass
    .trayBackground(.ultraThickMaterial)        // Heavy glass
```

### Advanced Glass Effects

Combine materials with colors for custom glass effects:

```swift
// Tinted glass
ContentView()
    .tray(isPresented: $showTray) {
        MyContent()
    }
    .trayBackground(.regularMaterial.opacity(0.9))

// Custom glass with color
ContentView()
    .tray(isPresented: $showTray) {
        MyContent()
    }
    .trayBackground(
        .regularMaterial
        .blendMode(.overlay)
        .opacity(0.95)
    )
```

### Liquid Glass with Custom Appliers

For advanced effects, use custom background appliers that give you full control:

```swift
// Liquid Glass with fallback, preserving corners
ContentView()
    .tray(isPresented: $showTray) {
        MyContent()
    }
    .trayBackground(.ultraThinMaterial) { surface, topRadius, _ in
        if #available(iOS 18.0, macOS 15.0, *) {
            surface.glassEffect(.regular.interactive(), in: .rect(cornerRadius: topRadius))
        } else {
            surface.background(.ultraThinMaterial)
        }
    }

// Simple color background
ContentView()
    .tray(isPresented: $showTray) {
        MyContent()
    }
    .trayBackground { surface in
        surface.background(Color.blue)
    }

// Complex glass effect with multiple layers
ContentView()
    .tray(isPresented: $showTray) {
        MyContent()
    }
    .trayBackground(.regularMaterial) { surface, topRadius, bottomRadius in
        surface
            .background(.regularMaterial, in: .rect(cornerRadius: topRadius))
            .overlay {
                if #available(iOS 18.0, *) {
                    Color.clear
                        .glassEffect(.thin.nonInteractive(), in: .rect(cornerRadius: topRadius))
                }
            }
    }
```

### Dynamic Glass Based on Environment

Adapt glass style to user preferences:

```swift
struct AdaptiveGlassTray: View {
    @State private var showTray = false
    @Environment(\.colorScheme) var colorScheme
    
    var glassBackground: some ShapeStyle {
        colorScheme == .dark 
            ? .ultraThickMaterial 
            : .regularMaterial
    }
    
    var body: some View {
        Button("Show Adaptive Tray") {
            showTray = true
        }
        .tray(isPresented: $showTray) {
            MyContent()
        }
        .trayBackground(glassBackground)
    }
}
```

### Programmatic Navigation

Use the tray controller directly for programmatic navigation:

```swift
struct MyView: View {
    @Environment(\.trayController) var tray
    
    func navigateToSettings() {
        tray.push("Settings") {
            SettingsView()
        }
    }
    
    func goBack() {
        tray.pop()
    }
}
```

## Transitions

Tray supports various built-in transitions:

- `.slide` - Slides content in from the side
- `.blur` - Blurs and fades content
- `.scale` - Scales content in/out
- `.opacity` - Simple fade in/out
- Custom transitions using SwiftUI's `AnyTransition`

## Examples

### Multi-Step Flow

```swift
struct OnboardingFlow: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Step 1: Welcome")
            
            TrayNavigationLink(title: "Personal Info") {
                PersonalInfoStep()
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }
}

struct PersonalInfoStep: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Step 2: Personal Info")
            
            TrayNavigationLink(title: "Complete", showsNavigationBar: false) {
                CompletionStep()
            } label: {
                Text("Finish")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }
}

struct CompletionStep: View {
    @Environment(\.trayController) var tray
    
    var body: some View {
        VStack(spacing: 20) {
            Text("✓ Complete!")
                .font(.largeTitle)
            
            Button("Done") {
                tray.dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}
```

### Settings Panel

```swift
struct SettingsPanel: View {
    @State private var showSettings = false
    
    var body: some View {
        Button("Settings") {
            showSettings = true
        }
        .tray(isPresented: $showSettings, title: "Settings") {
            SettingsList()
        }
        .trayPadding(12)
        .trayAnimation(.spring(duration: 0.4))
    }
}

struct SettingsList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TrayNavigationLink(title: "Account") {
                AccountSettings()
            } label: {
                SettingsRow(title: "Account", icon: "person.circle")
            }
            
            TrayNavigationLink(title: "Privacy") {
                PrivacySettings()
            } label: {
                SettingsRow(title: "Privacy", icon: "lock.circle")
            }
            
            TrayNavigationLink(title: "About", showsNavigationBar: false) {
                AboutView()
            } label: {
                SettingsRow(title: "About", icon: "info.circle")
            }
        }
    }
}
```

## Platform Support

- iOS 17.0+
- macOS 14.0+

## Requirements

- Swift 5.9+
- SwiftUI
- SwiftUIX (for advanced view utilities)

## License

MIT License - see LICENSE file for details.
