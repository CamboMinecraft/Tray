import SwiftUI

/// A set of convenience transitions for Tray.
public extension AnyTransition {
    /// A smooth blur + opacity transition.
    /// - Parameter radius: Maximum blur radius at the peak of the transition.
    /// - Returns: A transition that animates blur and opacity together.
    static func blurOpacity(radius: CGFloat = TrayConstants.defaultBlurRadius) -> AnyTransition {
        .modifier(
            active: _TrayBlurOpacity(progress: 1, maxRadius: radius),
            identity: _TrayBlurOpacity(progress: 0, maxRadius: radius)
        )
    }

    /// Convenience alias so you can write `.trayPageTransition(.blur)`.
    static var blur: AnyTransition { .blurOpacity(radius: TrayConstants.defaultBlurRadius) }
}

private struct _TrayBlurOpacity: AnimatableModifier {
    var progress: CGFloat // 0 = identity, 1 = fully transitioned
    var maxRadius: CGFloat

    // Animatable requires a nonisolated requirement under Swift 6 concurrency.
    nonisolated var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content
            .opacity(1 - progress)
            .blur(radius: progress * maxRadius)
    }
}
