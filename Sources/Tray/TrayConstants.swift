import SwiftUI

// MARK: - Tray Constants

/// Centralized constants used throughout the Tray framework
public enum TrayConstants {
    
    // MARK: - Layout & Sizing
    
    /// Default corner radius for tray surfaces
    public static let defaultCornerRadius: CGFloat = 20
    
    /// Minimum height constraint for trays
    public static let minimumHeight: CGFloat = 44
    
    /// Default fallback height when measured height is not available
    public static let defaultFallbackHeight: CGFloat = 100
    
    /// Initial fixed height for controller-based trays
    public static let initialFixedHeight: CGFloat = 300
    
    /// Default screen height fallback for macOS
    public static let macOSFallbackScreenHeight: CGFloat = 800
    
    /// Z-index for tray overlay
    public static let overlayZIndex: Double = 1000
    
    // MARK: - Padding & Spacing
    
    /// Standard horizontal padding for tray content
    public static let horizontalPadding: CGFloat = 8
    
    /// Standard bottom padding for tray content
    public static let bottomPadding: CGFloat = 8
    
    /// Top padding for navigation bar
    public static let navigationBarTopPadding: CGFloat = 8
    
    /// Offset distance for off-screen measurement views
    public static let offScreenOffset: CGFloat = -2000
    
    /// Width for off-screen measurement views
    public static let measurementViewWidth: CGFloat = 370
    
    // MARK: - Animation Values
    
    /// Default present animation spring response
    public static let presentAnimationResponse: Double = 0.38
    
    /// Default present animation damping fraction
    public static let presentAnimationDamping: Double = 0.85
    
    /// Default dismiss animation spring response
    public static let dismissAnimationResponse: Double = 0.38
    
    /// Default dismiss animation damping fraction
    public static let dismissAnimationDamping: Double = 0.9
    
    /// Default drag reset animation spring response
    public static let dragResetAnimationResponse: Double = 0.35
    
    /// Default drag reset animation damping fraction
    public static let dragResetAnimationDamping: Double = 0.9
    
    /// Default flow next animation spring response
    public static let flowNextAnimationResponse: Double = 0.32
    
    /// Default flow next animation damping fraction
    public static let flowNextAnimationDamping: Double = 0.9
    
    /// Default flow back animation spring response
    public static let flowBackAnimationResponse: Double = 0.32
    
    /// Default flow back animation damping fraction
    public static let flowBackAnimationDamping: Double = 0.95
    
    /// Cross-fade animation duration
    public static let crossFadeAnimationDuration: Double = 0.22
    
    /// Page transition scale factor
    public static let pageTransitionScale: Double = 0.985
    
    // MARK: - Drag & Gesture
    
    /// Minimum drag distance to trigger gesture
    public static let minimumDragDistance: CGFloat = 8
    
    /// Drag threshold for dismissal
    public static let dragDismissThreshold: CGFloat = 120
    
    /// Stretch factor for upward drag
    public static let dragStretchFactor: CGFloat = 0.18
    
    /// Maximum stretch distance
    public static let maxDragStretch: CGFloat = 28
    
    // MARK: - Visual Effects
    
    /// Default shadow opacity
    public static let shadowOpacity: Double = 0.12
    
    /// Default dimming color opacity
    public static let dimmingColorOpacity: Double = 0.2
    
    /// Shadow radius
    public static let shadowRadius: CGFloat = 20
    
    /// Shadow Y offset
    public static let shadowYOffset: CGFloat = -8
    
    /// Divider opacity
    public static let dividerOpacity: Double = 0.15
    
    /// Progress bar opacity for secondary color
    public static let progressBarSecondaryOpacity: Double = 0.15
    
    /// Progress bar height
    public static let progressBarHeight: CGFloat = 4
    
    // MARK: - Surface Positioning
    
    /// Initial surface offset for presentation animation
    public static let presentationSurfaceOffset: CGFloat = 60
    
    /// Dismissal surface offset
    public static let dismissalSurfaceOffset: CGFloat = 80
    
    /// Surface offset calculation addition for dimming
    public static let dimmingSurfaceOffset: CGFloat = 60
    
    /// Initial base offset for flow trays
    public static let flowBaseOffset: CGFloat = 620
    
    // MARK: - Navigation Bar
    
    /// Navigation button font size
    public static let navigationButtonFontSize: CGFloat = 16
    
    /// Navigation button frame size
    public static let navigationButtonSize: CGFloat = 32
    
    /// Navigation bar horizontal spacing
    public static let navigationBarHorizontalSpacing: CGFloat = 12
    
    /// Navigation bar item spacing
    public static let navigationBarItemSpacing: CGFloat = 8
    
    /// Navigation bar vertical spacing
    public static let navigationBarVerticalSpacing: CGFloat = 8
    
    // MARK: - Device-Specific
    
    /// Corner radius for devices with safe area bottom insets
    public static let deviceCornerRadiusWithSafeArea: CGFloat = 44
    
    /// Corner radius for devices without safe area bottom insets
    public static let deviceCornerRadiusWithoutSafeArea: CGFloat = 20
    
    /// Default device corner radius fallback
    public static let defaultDeviceCornerRadius: CGFloat = 20
    
    // MARK: - Debugging
    
    /// Debug delay for measurement verification (milliseconds)
    public static let debugMeasurementDelayMS: UInt64 = 50
    
    // MARK: - Transitions
    
    /// Default blur radius for transitions
    public static let defaultBlurRadius: CGFloat = 16
    
    // MARK: - Computed Animation Values
    
    /// Default present animation
    public static var defaultPresentAnimation: Animation {
        .spring(response: presentAnimationResponse, dampingFraction: presentAnimationDamping)
    }
    
    /// Default dismiss animation
    public static var defaultDismissAnimation: Animation {
        .spring(response: dismissAnimationResponse, dampingFraction: dismissAnimationDamping)
    }
    
    /// Default drag reset animation
    public static var defaultDragResetAnimation: Animation {
        .spring(response: dragResetAnimationResponse, dampingFraction: dragResetAnimationDamping)
    }
    
    /// Default flow next animation
    public static var defaultFlowNextAnimation: Animation {
        .spring(response: flowNextAnimationResponse, dampingFraction: flowNextAnimationDamping)
    }
    
    /// Default flow back animation
    public static var defaultFlowBackAnimation: Animation {
        .spring(response: flowBackAnimationResponse, dampingFraction: flowBackAnimationDamping)
    }
    
    /// Default cross-fade animation
    public static var defaultCrossFadeAnimation: Animation {
        .easeInOut(duration: crossFadeAnimationDuration)
    }
    
    // MARK: - Computed Colors
    
    /// Default shadow color
    public static var defaultShadowColor: Color {
        Color(.sRGBLinear, white: 0, opacity: shadowOpacity)
    }
    
    /// Default dimming color
    public static var defaultDimmingColor: Color {
        Color.black.opacity(dimmingColorOpacity)
    }
    
    // MARK: - Computed Transitions
    
    /// Default page transition
    public static var defaultPageTransition: AnyTransition {
        .opacity.combined(with: .scale(scale: pageTransitionScale, anchor: .center))
    }
    
    /// Default tray transition
    public static var defaultTrayTransition: AnyTransition {
        .move(edge: .bottom).combined(with: .opacity)
    }
    
    // MARK: - Compression Effect
    
    /// Default compression scale (slightly smaller than 1.0)
    public static let defaultCompressionScale: CGFloat = 0.995
    
    /// Default compression animation
    public static var defaultCompressionAnimation: Animation {
        .spring(response: 0.05, dampingFraction: 0.9)
    }
}
