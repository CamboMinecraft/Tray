import SwiftUI
import SwiftUIX

// MARK: - Tray Namespace

public enum Tray {}

public extension Tray {
    enum Detent: Sendable, Equatable {
        case fraction(CGFloat)
        case height(CGFloat)
        case automatic

        func height(for screenHeight: CGFloat) -> CGFloat {
            switch self {
            case .fraction(let f):
                return max(44, min(screenHeight, screenHeight * max(0.1, min(1.0, f))))
            case .height(let h):
                return max(44, min(h, screenHeight))
            case .automatic:
                return screenHeight * 0.95
            }
        }
    }
}

// MARK: - Page Trait

public struct TrayPageInfo: Sendable, Equatable {
    public var title: String?
    public var detent: Tray.Detent

    public init(title: String? = nil, detent: Tray.Detent = .automatic) {
        self.title = title
        self.detent = detent
    }
}

internal struct TrayPageKey: _ViewTraitKey {
    static var defaultValue: TrayPageInfo? { nil }
}

extension _ViewTraitKeys {
    internal var trayPage: TrayPageKey.Type { TrayPageKey.self }
}

public struct TrayPageModifier: ViewModifier {
    public var title: String?
    public var detent: Tray.Detent
    public func body(content: Content) -> some View {
        content._trait(\.trayPage, TrayPageInfo(title: title, detent: detent))
    }
}

public extension View {
    /// Declares a view as a tray page with optional metadata.
    func trayPage(title: String? = nil, detent: Tray.Detent = .automatic) -> ModifiedContent<Self, TrayPageModifier> {
        modifier(TrayPageModifier(title: title, detent: detent))
    }
}

// MARK: - Optional Per-Page Transition Trait

public struct TrayPageTransitionInfo {
    public var transition: AnyTransition
    public init(_ transition: AnyTransition) { self.transition = transition }
}

internal struct TrayPageTransitionKey: _ViewTraitKey {
    static var defaultValue: TrayPageTransitionInfo? { nil }
}

extension _ViewTraitKeys {
    internal var trayPageTransition: TrayPageTransitionKey.Type { TrayPageTransitionKey.self }
}

public struct TrayPageTransitionModifier: ViewModifier {
    public var transition: AnyTransition
    public func body(content: Content) -> some View {
        content._trait(\.trayPageTransition, TrayPageTransitionInfo(transition))
    }
}

public extension View {
    func trayPageTransition(_ transition: AnyTransition) -> ModifiedContent<Self, TrayPageTransitionModifier> {
        modifier(TrayPageTransitionModifier(transition: transition))
    }
}

// MARK: - Optional Per-Page Animation Trait

public struct TrayPageAnimationInfo {
    public var animation: Animation
    public init(_ animation: Animation) { self.animation = animation }
}

internal struct TrayPageAnimationKey: _ViewTraitKey {
    static var defaultValue: TrayPageAnimationInfo? { nil }
}

extension _ViewTraitKeys {
    internal var trayPageAnimation: TrayPageAnimationKey.Type { TrayPageAnimationKey.self }
}

public struct TrayPageAnimationModifier: ViewModifier {
    public var animation: Animation
    public func body(content: Content) -> some View {
        content._trait(\.trayPageAnimation, TrayPageAnimationInfo(animation))
    }
}

public extension View {
    /// Overrides the flow navigation animation (next/back) for this page.
    func trayPageAnimation(_ animation: Animation) -> ModifiedContent<Self, TrayPageAnimationModifier> {
        modifier(TrayPageAnimationModifier(animation: animation))
    }
}

// MARK: - Optional Per-Page Navigation Bar Visibility Trait

public struct TrayPageNavigationBarInfo {
    public var showsNavigationBar: Bool
    public init(_ showsNavigationBar: Bool) { self.showsNavigationBar = showsNavigationBar }
}

internal struct TrayPageNavigationBarKey: _ViewTraitKey {
    static var defaultValue: TrayPageNavigationBarInfo? { nil }
}

extension _ViewTraitKeys {
    internal var trayPageNavigationBar: TrayPageNavigationBarKey.Type { TrayPageNavigationBarKey.self }
}

public struct TrayPageNavigationBarModifier: ViewModifier {
    public var showsNavigationBar: Bool
    public func body(content: Content) -> some View {
        content._trait(\.trayPageNavigationBar, TrayPageNavigationBarInfo(showsNavigationBar))
    }
}

public extension View {
    /// Controls navigation bar visibility for this specific tray page.
    func trayShowsNavigationBar(_ shows: Bool) -> ModifiedContent<Self, TrayPageNavigationBarModifier> {
        modifier(TrayPageNavigationBarModifier(showsNavigationBar: shows))
    }
}

// MARK: - TrayConfig Environment

private struct TrayConfigKey: EnvironmentKey { 
    static let defaultValue = TrayConfig.default
}
public extension EnvironmentValues { 
    var trayConfig: TrayConfig { 
        get { self[TrayConfigKey.self] } 
        set { self[TrayConfigKey.self] = newValue } 
    } 
}

public struct TrayBackgroundModifier<Background: ShapeStyle>: ViewModifier {
    let background: Background
    
    public func body(content: Content) -> some View {
        content.transformEnvironment(\.trayConfig) { config in
            config.background = AnyShapeStyle(background)
            // Reset any custom applier when explicit ShapeStyle is provided
            config.backgroundApplier = nil
        }
    }
}

public struct TrayBackgroundApplierModifier: ViewModifier {
    let applier: (AnyView) -> AnyView
    public func body(content: Content) -> some View {
        content.transformEnvironment(\.trayConfig) { config in
            config.backgroundApplier = applier
            // Clear radii-applier to avoid ambiguity
            config.backgroundApplierWithRadii = nil
        }
    }
}

public struct TrayBackgroundApplierWithRadiiModifier: ViewModifier {
    let applier: (AnyView, CGFloat, CGFloat) -> AnyView
    public func body(content: Content) -> some View {
        content.transformEnvironment(\.trayConfig) { config in
            config.backgroundApplierWithRadii = applier
            // Clear simple applier to avoid ambiguity
            config.backgroundApplier = nil
        }
    }
}

public struct TrayBackgroundCombinedModifier<S: ShapeStyle, V: View>: ViewModifier {
    let style: S
    let applier: (AnyView, CGFloat, CGFloat) -> V
    public func body(content: Content) -> some View {
        content.transformEnvironment(\.trayConfig) { config in
            config.background = AnyShapeStyle(style)
            config.backgroundApplierWithRadii = { any, tltr, blbr in AnyView(applier(any, tltr, blbr)) }
            config.backgroundApplier = nil
        }
    }
}

public struct TrayAnimationModifier: ViewModifier {
    let animation: Animation
    public func body(content: Content) -> some View { 
        content.transformEnvironment(\.trayConfig) { config in
            config.presentAnimation = animation
            config.dismissAnimation = animation
            config.dragResetAnimation = animation
            config.flowNextAnimation = animation
            config.flowBackAnimation = animation
        }
    }
}

// MARK: - Tray Padding Modifier

public struct TrayGlobalPageTransitionModifier: ViewModifier {
    let transition: AnyTransition
    
    public func body(content: Content) -> some View {
        content.transformEnvironment(\.trayConfig) { config in
            config.pageTransition = transition
        }
    }
}

public struct TrayNavigationBarModifier: ViewModifier {
    let showsNavigationBar: Bool
    
    public func body(content: Content) -> some View {
        content.transformEnvironment(\.trayConfig) { config in
            config.showsNavigationBar = showsNavigationBar
        }
    }
}

public struct TrayNavigationProgressBarModifier: ViewModifier {
    let showsProgressBar: Bool
    
    public func body(content: Content) -> some View {
        content.transformEnvironment(\.trayConfig) { config in
            config.showsNavigationProgressBar = showsProgressBar
        }
    }
}

public struct TrayPaddingModifier: ViewModifier {
    let horizontalPadding: CGFloat?
    let bottomPadding: CGFloat?
    
    public func body(content: Content) -> some View {
        content.transformEnvironment(\.trayConfig) { config in
            if let horizontal = horizontalPadding {
                config.horizontalPadding = horizontal
            }
            if let bottom = bottomPadding {
                config.bottomPadding = bottom
            }
        }
    }
}

public extension View {
    /// Sets a custom background for all trays within scope.
    func trayBackground<S: ShapeStyle>(_ style: S) -> ModifiedContent<Self, TrayBackgroundModifier<S>> {
        modifier(TrayBackgroundModifier(background: style))
    }

    /// Provides full control over how the tray surface background is applied.
    /// The applier receives the tray surface as `AnyView` and should return a wrapped view
    /// (e.g., applying `.glassEffect(...)`, or any custom effects). If not provided,
    /// the configured ShapeStyle is used.
    func trayBackground<V: View>(@ViewBuilder _ applier: @escaping (AnyView) -> V) -> ModifiedContent<Self, TrayBackgroundApplierModifier> {
        modifier(TrayBackgroundApplierModifier(applier: { any in AnyView(applier(any)) }))
    }

    /// Combined API: sets a ShapeStyle fallback and also supplies a view applier that
    /// receives corner radii so you can match the surface shape for effects.
    func trayBackground<S: ShapeStyle, V: View>(_ style: S, @ViewBuilder _ applier: @escaping (AnyView, CGFloat, CGFloat) -> V) -> ModifiedContent<Self, TrayBackgroundCombinedModifier<S, V>> {
        modifier(TrayBackgroundCombinedModifier(style: style, applier: applier))
    }
    
    /// Sets a global animation override for all tray effects (present, dismiss, drag reset, next/back, close) within scope.
    func trayAnimation(_ animation: Animation) -> ModifiedContent<Self, TrayAnimationModifier> {
        modifier(TrayAnimationModifier(animation: animation))
    }
    
    /// Sets padding around all trays within scope.
    func trayPadding(horizontal: CGFloat? = nil, bottom: CGFloat? = nil) -> ModifiedContent<Self, TrayPaddingModifier> {
        modifier(TrayPaddingModifier(horizontalPadding: horizontal, bottomPadding: bottom))
    }
    
    /// Sets uniform padding around all trays within scope.
    func trayPadding(_ padding: CGFloat) -> ModifiedContent<Self, TrayPaddingModifier> {
        modifier(TrayPaddingModifier(horizontalPadding: padding, bottomPadding: padding))
    }
    
    /// Sets the default page transition for all trays within scope.
    func trayDefaultPageTransition(_ transition: AnyTransition) -> ModifiedContent<Self, TrayGlobalPageTransitionModifier> {
        modifier(TrayGlobalPageTransitionModifier(transition: transition))
    }
    
    /// Controls whether navigation bar is shown globally for all trays within scope.
    func trayGlobalShowsNavigationBar(_ shows: Bool) -> ModifiedContent<Self, TrayNavigationBarModifier> {
        modifier(TrayNavigationBarModifier(showsNavigationBar: shows))
    }
    
    /// Controls whether navigation progress bar is shown for all trays within scope.
    func trayShowsNavigationProgressBar(_ shows: Bool) -> ModifiedContent<Self, TrayNavigationProgressBarModifier> {
        modifier(TrayNavigationProgressBarModifier(showsProgressBar: shows))
    }
}
