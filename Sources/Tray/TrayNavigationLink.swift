import SwiftUI

// MARK: - TrayNavigationLink

/// A view that controls a navigation presentation in a tray stack.
public struct TrayNavigationLink<Label: View, Destination: View>: View {
    let destination: () -> Destination
    let label: () -> Label
    let title: String?
    let showsNavigationBar: Bool?
    
    @Environment(\.trayController) private var controller
    @Environment(\.trayConfig) private var trayConfig
    
    public init(
        title: String? = nil,
        showsNavigationBar: Bool? = nil,
        @ViewBuilder destination: @escaping () -> Destination,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.title = title
        self.showsNavigationBar = showsNavigationBar
        self.destination = destination
        self.label = label
    }
    
    public var body: some View {
        Button(action: navigate) {
            label()
        }
        .buttonStyle(TrayNavigationLinkButtonStyle())
    }
    
    private func navigate() {
        withAnimation(trayConfig.flowNextAnimation) {
            controller.push(title, showsNavigationBar: showsNavigationBar) {
                destination()
            }
        }
    }
}

// MARK: - Convenience Initializers

public extension TrayNavigationLink where Label == Text {
    /// Creates a navigation link with a text label.
    init(
        _ titleKey: String,
        title: String? = nil,
        showsNavigationBar: Bool? = nil,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.init(title: title, showsNavigationBar: showsNavigationBar, destination: destination) {
            Text(titleKey)
        }
    }
}

/// Programmatic navigation link with binding support
public struct TrayNavigationProgrammaticLink<Destination: View>: View {
    let destination: () -> Destination
    let title: String?
    @Binding var isActive: Bool
    
    @Environment(\.trayController) private var controller
    
    public init(
        title: String? = nil,
        isActive: Binding<Bool>,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.title = title
        self._isActive = isActive
        self.destination = destination
    }
    
    public var body: some View {
        EmptyView()
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    controller.push(title) {
                        destination()
                    }
                    // Reset the binding after navigation
                    Task { @MainActor in
                        isActive = false
                    }
                }
            }
    }
}

// MARK: - Button Style

/// A button style that doesn't interfere with the content's appearance
private struct TrayNavigationLinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}