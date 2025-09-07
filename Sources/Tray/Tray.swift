import SwiftUI

// MARK: - Public API Surface

/// Navigation bar items for the tray, similar to SwiftUI's navigationBarTitleDisplayMode
public struct TrayNavigationBarItems: @unchecked Sendable {
    public var leading: AnyView?
    public var trailing: AnyView?
    
    public init(leading: AnyView? = nil, trailing: AnyView? = nil) {
        self.leading = leading
        self.trailing = trailing
    }
    
    public init<Leading: View>(leading: Leading) {
        self.leading = AnyView(leading)
        self.trailing = nil
    }
    
    public init<Trailing: View>(trailing: Trailing) {
        self.leading = nil
        self.trailing = AnyView(trailing)
    }
    
    public init<Leading: View, Trailing: View>(leading: Leading, trailing: Trailing) {
        self.leading = AnyView(leading)
        self.trailing = AnyView(trailing)
    }
}

/// Appearance and behavior configuration for the tray.
public struct TrayConfig: @unchecked Sendable {
    public var cornerRadius: CGFloat
    public var background: AnyShapeStyle
    public var backgroundApplier: ((AnyView) -> AnyView)?
    public var backgroundApplierWithRadii: ((AnyView, CGFloat, CGFloat) -> AnyView)?
    public var shadow: Color
    public var dimmingColor: Color
    public var maxHeight: CGFloat?
    public var dragToDismiss: Bool
    public var tapOutsideToDismiss: Bool
    /// Transition used for the whole tray surface when inserted/removed.
    public var transition: AnyTransition
    /// Transition applied when the page/content inside the tray changes.
    public var pageTransition: AnyTransition
    /// Whether to show the navigation bar
    public var showsNavigationBar: Bool
    /// Whether to show the navigation progress bar for multi-step flows
    public var showsNavigationProgressBar: Bool
    /// Custom navigation bar items (leading and trailing)
    public var trayNavigationBarItems: TrayNavigationBarItems?

    // Animations
    public var presentAnimation: Animation
    public var dismissAnimation: Animation
    public var dragResetAnimation: Animation
    public var flowNextAnimation: Animation
    public var flowBackAnimation: Animation
    
    // Compression effect
    public var compressionEnabled: Bool
    public var compressionScale: CGFloat
    public var compressionAnimation: Animation
    
    // Padding
    public var horizontalPadding: CGFloat
    public var bottomPadding: CGFloat
    
    // Height behavior
    public var preferMaxHeight: Bool


    public init(
        cornerRadius: CGFloat = TrayConstants.defaultCornerRadius,
        background: some ShapeStyle = Color.white,
        shadow: Color = TrayConstants.defaultShadowColor,
        dimmingColor: Color = TrayConstants.defaultDimmingColor,
        maxHeight: CGFloat? = nil,
        dragToDismiss: Bool = true,
        tapOutsideToDismiss: Bool = true,
        transition: AnyTransition = TrayConstants.defaultTrayTransition,
        pageTransition: AnyTransition = TrayConstants.defaultPageTransition,
        showsNavigationBar: Bool = true,
        showsNavigationProgressBar: Bool = false,
        trayNavigationBarItems: TrayNavigationBarItems? = nil,
        presentAnimation: Animation = TrayConstants.defaultPresentAnimation,
        dismissAnimation: Animation = TrayConstants.defaultDismissAnimation,
        dragResetAnimation: Animation = TrayConstants.defaultDragResetAnimation,
        flowNextAnimation: Animation = TrayConstants.defaultFlowNextAnimation,
        flowBackAnimation: Animation = TrayConstants.defaultFlowBackAnimation,
        compressionEnabled: Bool = true,
        compressionScale: CGFloat = TrayConstants.defaultCompressionScale,
        compressionAnimation: Animation = TrayConstants.defaultCompressionAnimation,
        horizontalPadding: CGFloat = TrayConstants.horizontalPadding,
        bottomPadding: CGFloat = TrayConstants.bottomPadding,
        preferMaxHeight: Bool = false
    ) {
        self.cornerRadius = cornerRadius
        self.background = AnyShapeStyle(background)
        self.backgroundApplier = nil
        self.backgroundApplierWithRadii = nil
        self.shadow = shadow
        self.dimmingColor = dimmingColor
        self.maxHeight = maxHeight
        self.dragToDismiss = dragToDismiss
        self.tapOutsideToDismiss = tapOutsideToDismiss
        self.transition = transition
        self.pageTransition = pageTransition
        self.showsNavigationBar = showsNavigationBar
        self.showsNavigationProgressBar = showsNavigationProgressBar
        self.trayNavigationBarItems = trayNavigationBarItems
        self.presentAnimation = presentAnimation
        self.dismissAnimation = dismissAnimation
        self.dragResetAnimation = dragResetAnimation
        self.flowNextAnimation = flowNextAnimation
        self.flowBackAnimation = flowBackAnimation
        self.compressionEnabled = compressionEnabled
        self.compressionScale = compressionScale
        self.compressionAnimation = compressionAnimation
        self.horizontalPadding = horizontalPadding
        self.bottomPadding = bottomPadding
        self.preferMaxHeight = preferMaxHeight
    }

    // Use a computed property to avoid storing shared global state under strict concurrency.
    public static var `default`: TrayConfig { TrayConfig() }
}

/// A lightweight controller that owns presentation state and a simple navigation stack.
@MainActor
public final class TrayController: ObservableObject {
    @Published public var isPresented: Bool = false
    @Published public var stack: [AnyView] = []
    @Published public var titles: [String] = []
    @Published public var navigationBarVisibility: [Bool?] = []

    public init() {}

    /// Present the tray with an initial view and optional title.
    public func present<V: View>(title: String? = nil, showsNavigationBar: Bool? = nil, @ViewBuilder content: () -> V) {
        stack = [AnyView(content())]
        titles = [title ?? ""]
        navigationBarVisibility = [showsNavigationBar]
        isPresented = true
    }

    public func dismiss() {
        isPresented = false
        stack.removeAll()
        titles.removeAll()
        navigationBarVisibility.removeAll()
    }

    public func push<V: View>(_ title: String? = nil, showsNavigationBar: Bool? = nil, @ViewBuilder _ builder: () -> V) {
        guard isPresented else { return }
        stack.append(AnyView(builder()))
        titles.append(title ?? "")
        navigationBarVisibility.append(showsNavigationBar)
    }

    public func pop() {
        guard stack.count > 1 else { 
            dismiss()
            return 
        }
        _ = stack.popLast()
        _ = titles.popLast()
        _ = navigationBarVisibility.popLast()
    }
}

// MARK: - Environment

private struct TrayControllerKey: @preconcurrency EnvironmentKey { @MainActor static let defaultValue = TrayController() }
public extension EnvironmentValues { var trayController: TrayController { get { self[TrayControllerKey.self] } set { self[TrayControllerKey.self] = newValue } } }

// MARK: - Public Modifier

public extension View {
    /// Attach a tray host to the view using a controller.
    /// Usage:
    /// let tray = TrayController()
    /// ContentView()
    ///   .environment(\.trayController, tray)
    ///   .tray(controller: tray) { InsideView() }
    func tray<Content: View>(
        controller: TrayController,
        config: TrayConfig = .default,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(TrayModifier(controller: controller, config: config, rootBuilder: content))
    }

    /// Convenience overload using a binding to control presentation directly.
    func tray<Content: View>(
        isPresented: Binding<Bool>,
        title: String? = nil,
        config: TrayConfig = .default,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        #if canImport(UIKit)
        return modifier(TrayBindingLaunchModifier(isPresented: isPresented, title: title, config: config, content: content))
        #else
        let controller = TrayController()
        return modifier(TrayBindingModifier(isPresented: isPresented, initialTitle: title, config: config, controller: controller, rootBuilder: content))
        #endif
    }
}

// MARK: - Tray Background Override

public extension ModifiedContent where Content: View {
    /// Attach a tray host to the view using a controller with custom background.
    @MainActor
    func tray<TrayContent: View, Background: ShapeStyle>(
        controller: TrayController,
        config: TrayConfig = .default,
        @ViewBuilder content: @escaping () -> TrayContent
    ) -> some View where Modifier == TrayBackgroundModifier<Background> {
        var modifiedConfig = config
        modifiedConfig.background = AnyShapeStyle(modifier.background)
        return self.content.modifier(TrayModifier(controller: controller, config: modifiedConfig, rootBuilder: content))
    }

    /// Convenience overload using a binding with custom background.
    @MainActor
    func tray<TrayContent: View, Background: ShapeStyle>(
        isPresented: Binding<Bool>,
        title: String? = nil,
        config: TrayConfig = .default,
        @ViewBuilder content: @escaping () -> TrayContent
    ) -> some View where Modifier == TrayBackgroundModifier<Background> {
        var modifiedConfig = config
        modifiedConfig.background = AnyShapeStyle(modifier.background)
        #if canImport(UIKit)
        return self.content.modifier(TrayBindingLaunchModifier(isPresented: isPresented, title: title, config: modifiedConfig, content: content))
        #else
        let controller = TrayController()
        return self.content.modifier(TrayBindingModifier(isPresented: isPresented, initialTitle: title, config: modifiedConfig, controller: controller, rootBuilder: content))
        #endif
    }
}

// MARK: - Internal Views/Modifiers

struct TrayModifier<Root: View>: ViewModifier {
    @ObservedObject var controller: TrayController
    let config: TrayConfig
    @ViewBuilder var rootBuilder: () -> Root

    @Environment(\.trayConfig) private var envConfig
    @State private var dragOffset: CGFloat = 0
    @State private var surfaceOffset: CGFloat = 0
    @State private var isOverlayVisible: Bool = false
    @State private var contentAnimation: Animation = .default
    @State private var currentHeight: CGFloat = TrayConstants.initialFixedHeight // Used when a fixed height is configured
    @State private var stretch: CGFloat = 0 // small elastic growth when dragging upward
    @State private var measuredHeight: CGFloat? = nil // Content-driven height when using automatic sizing

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if isOverlayVisible {
                    // Dimming background with progressive opacity tied to tray position.
                    envConfig.dimmingColor.opacity(dimmingOpacity)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture { if envConfig.tapOutsideToDismiss { controller.dismiss() } }
                        .overlay(alignment: .bottom) {
                            traySurface
                                .offset(y: surfaceOffset + dragOffset)
                                .simultaneousGesture(dragGesture)
                        }
                        .zIndex(TrayConstants.overlayZIndex)
                }
            }
            .environment(\.trayController, controller)
        .onChange(of: controller.stack.count) { old, new in
            let forward = envConfig.flowNextAnimation
            let backward = envConfig.flowBackAnimation
            contentAnimation = (new >= old) ? forward : backward
            
            // Update height based on configuration
            #if canImport(UIKit)
            let screenHeight = UIScreen.main.bounds.height
            #else
            let screenHeight: CGFloat = TrayConstants.macOSFallbackScreenHeight // fallback for macOS
            #endif
            
            if shouldUseFixedHeight {
                let newHeight = config.maxHeight ?? Tray.Detent.automatic.height(for: screenHeight)
                withAnimation(contentAnimation) {
                    currentHeight = newHeight
                }
            }
            // For content-hugging mode, height will be set by the preference change
        }
        .onChange(of: measuredHeight) { oldHeight, newHeight in
            // Animate height changes when content size changes
            if !shouldUseFixedHeight {
                let heightChangeAnim = envConfig.flowNextAnimation
                withAnimation(heightChangeAnim) {
                    // This will trigger a re-render with the new effectiveHeight
                }
            }
        }
        .onChange(of: controller.stack.count) { oldCount, newCount in
            // Force remeasurement when content changes
            if !shouldUseFixedHeight && !shouldUseScrollableMaxHeight {
                // Reset measured height to force a fresh measurement
                measuredHeight = nil
            }
        }
        .onChange(of: controller.isPresented) { _, newValue in
            if newValue && controller.stack.isEmpty {
                // If presented without content, load rootBuilder as default page.
                controller.present { rootBuilder() }
            }
            // Control mounting/unmounting to allow slide-out animation.
            if newValue {
                // Set initial height based on configuration
                if shouldUseFixedHeight {
                    #if canImport(UIKit)
                    let screenHeight = UIScreen.main.bounds.height
                    #else
                    let screenHeight: CGFloat = TrayConstants.macOSFallbackScreenHeight
                    #endif
                    currentHeight = config.maxHeight ?? Tray.Detent.automatic.height(for: screenHeight)
                }
                
                isOverlayVisible = true
                let presentAnim = envConfig.presentAnimation
                surfaceOffset = effectiveHeight + TrayConstants.presentationSurfaceOffset
                withAnimation(presentAnim) { surfaceOffset = 0 }
            } else {
                let dismissAnim = envConfig.dismissAnimation
                withAnimation(dismissAnim) { surfaceOffset = effectiveHeight + TrayConstants.dismissalSurfaceOffset }
            }
        }
    }

    @ViewBuilder private var traySurface: some View {
        let bottomCorner = deviceBottomCornerRadius()
        VStack(spacing: 0) {
            if envConfig.showsNavigationBar {
                TrayNavigationBar(
                    title: controller.titles.last ?? "",
                    canGoBack: controller.stack.count > 1,
                    onBack: controller.pop,
                    onClose: controller.dismiss,
                    stepIndex: nil,
                    stepCount: nil,
                    showsProgressBar: envConfig.showsNavigationProgressBar,
                    navigationBarItems: envConfig.trayNavigationBarItems
                )
                .padding(.horizontal)
                .padding(.top, TrayConstants.navigationBarTopPadding)
                .transition(.move(edge: .top).combined(with: .opacity))

                Divider().opacity(TrayConstants.dividerOpacity)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            Group { 
                if let top = controller.stack.last { 
                    top
                }
            }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding()
                .id(controller.stack.count)
                .transition(envConfig.pageTransition)
                .animation(contentAnimation, value: controller.stack.count)
        }
        .readTrayHeight($measuredHeight)
        .id("tray-measurement-\(controller.stack.count)-\(controller.titles.last ?? "")") // Force complete recreation
        .frame(maxWidth: .infinity)
        .frame(height: (shouldUseFixedHeight || shouldUseScrollableMaxHeight) ? (effectiveHeight + max(0, stretch)) : nil)
        .frame(minHeight: (shouldUseFixedHeight || shouldUseScrollableMaxHeight) ? nil : (effectiveHeight + max(0, stretch)))
        .animation(contentAnimation, value: effectiveHeight)
        .trayApplyBackground(config: envConfig, cornerRadius: envConfig.cornerRadius, bottomCorner: bottomCorner)
        .shadow(color: envConfig.shadow, radius: TrayConstants.shadowRadius, x: 0, y: TrayConstants.shadowYOffset)
        .ignoresSafeArea(edges: .bottom)
        .padding(.horizontal, envConfig.horizontalPadding)
        .padding(.bottom, envConfig.bottomPadding)
        .transition(envConfig.transition)
        .onAnimationCompleted(for: surfaceOffset) {
            if !controller.isPresented {
                isOverlayVisible = false
                dragOffset = 0
            }
        }
    }

    private var preferredHeight: CGFloat {
        return effectiveHeight
    }
    
    private var shouldUseFixedHeight: Bool {
        return envConfig.maxHeight != nil
    }
    
    private var shouldUseScrollableMaxHeight: Bool {
        // Use max height when explicitly configured or when content prefers it
        return envConfig.preferMaxHeight == true
    }
    
    private var effectiveHeight: CGFloat {
        #if canImport(UIKit)
        let screenHeight = UIScreen.main.bounds.height
        #else
        let screenHeight: CGFloat = 800
        #endif
        let cap = envConfig.maxHeight ?? Tray.Detent.automatic.height(for: screenHeight)
        
        if shouldUseFixedHeight { 
            return currentHeight
        }
        
        // For scrollable content without explicit height, use maximum height
        if shouldUseScrollableMaxHeight {
            return cap
        }
        
        // Use measured height if available, otherwise fall back to reasonable default
        let contentHeight = measuredHeight ?? TrayConstants.defaultFallbackHeight // Default if no measurement yet
        let result = min(max(TrayConstants.minimumHeight, contentHeight), cap)
        return result
    }

    // Opacity of the background dimming based on how far the tray is on-screen.
    private var dimmingOpacity: Double {
        let total = max(1, effectiveHeight + TrayConstants.dimmingSurfaceOffset)
        let y = max(0, surfaceOffset + dragOffset)
        let p = 1 - min(1, y / total)
        return Double(p)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: TrayConstants.minimumDragDistance)
            .onChanged { value in
                guard envConfig.dragToDismiss else { return }
                let dy = value.translation.height
                if dy >= 0 {
                    dragOffset = max(0, dy)
                    stretch = 0
                } else {
                    // Stretch upward a little. Cap for subtle visual effect.
                    let factor: CGFloat = TrayConstants.dragStretchFactor
                    let maxStretch: CGFloat = TrayConstants.maxDragStretch
                    stretch = min(maxStretch, -dy * factor)
                    dragOffset = 0
                }
            }
            .onEnded { value in
                guard envConfig.dragToDismiss else { return }
                let threshold: CGFloat = TrayConstants.dragDismissThreshold
                if value.translation.height > threshold {
                    controller.dismiss()
                    dragOffset = 0
                } else {
                    let dragAnim = envConfig.dragResetAnimation
                    withAnimation(dragAnim) {
                        dragOffset = 0
                        stretch = 0
                    }
                }
            }
    }
}

/// Modifier that maps a binding to a controller-backed tray.
struct TrayBindingModifier<Root: View>: ViewModifier {
    @Binding var isPresented: Bool
    let initialTitle: String?
    let config: TrayConfig
    @ObservedObject var controller: TrayController
    @ViewBuilder var rootBuilder: () -> Root

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _, new in
                if new {
                    controller.present(title: initialTitle, content: rootBuilder)
                } else if controller.isPresented {
                    controller.dismiss()
                }
            }
            // Keep the binding in sync when user dismisses via drag/tap.
            .onChange(of: controller.isPresented) { _, value in
                if value == false { isPresented = false }
            }
            .modifier(TrayModifier(controller: controller, config: config, rootBuilder: rootBuilder))
    }
}

#if canImport(UIKit)
/// Launches a UIWindow-based tray for iOS while preserving environment overrides (e.g., trayAnimation).
private struct TrayBindingLaunchModifier<Root: View>: ViewModifier {
    @Environment(\.trayConfig) private var envConfig
    @Binding var isPresented: Bool
    let title: String?
    let config: TrayConfig
    @ViewBuilder var content: () -> Root
    
    @StateObject private var controller = TrayController()

    func body(content host: Content) -> some View {
        host
            .environment(\.trayController, controller)
            .onChange(of: isPresented) { _, new in
                if new {
                    controller.present(title: title, content: self.content)
                    TrayWindowManager.shared.presentController(controller: controller, config: envConfig)
                } else {
                    controller.dismiss()
                }
            }
            .onChange(of: controller.isPresented) { _, controllerPresented in
                if !controllerPresented {
                    isPresented = false
                }
            }
    }
}
#endif

#Preview("Tray Example") {
    TrayExampleView()
}

// MARK: - Navigation Bar

public struct TrayNavigationBar: View {
    public var title: String
    public var canGoBack: Bool
    public var onBack: () -> Void
    public var onClose: () -> Void
    public var stepIndex: Int?
    public var stepCount: Int?
    public var showsProgressBar: Bool
    public var navigationBarItems: TrayNavigationBarItems?
    
    @Namespace private var namespace

    public init(
        title: String,
        canGoBack: Bool,
        onBack: @escaping () -> Void,
        onClose: @escaping () -> Void,
        stepIndex: Int? = nil,
        stepCount: Int? = nil,
        showsProgressBar: Bool = false,
        navigationBarItems: TrayNavigationBarItems? = nil
    ) {
        self.title = title
        self.canGoBack = canGoBack
        self.onBack = onBack
        self.onClose = onClose
        self.stepIndex = stepIndex
        self.stepCount = stepCount
        self.showsProgressBar = showsProgressBar
        self.navigationBarItems = navigationBarItems
    }

    public var body: some View {
        VStack(spacing: 8) {
            ZStack {
                HStack(spacing: 12) {
                    // Leading items or default back/close button
                    HStack(spacing: 8) {
                        if let leading = navigationBarItems?.leading {
                            leading
                        } else {
                            // Default back/close button
                            Button(action: canGoBack ? onBack : onClose) {
                                ZStack {
                                    Image(systemName: "chevron.backward")
                                        .opacity(canGoBack ? 1 : 0)
                                    Image(systemName: "xmark")
                                        .opacity(canGoBack ? 0 : 1)
                                }
                                .font(.system(size: TrayConstants.navigationButtonFontSize, weight: .semibold))
                                .frame(width: TrayConstants.navigationButtonSize, height: TrayConstants.navigationButtonSize)
                                .background(.thinMaterial)
                                .clipShape(Circle())
                            }
                        }
                    }
                    
                    Spacer(minLength: 0)
                    
                    // Trailing items or placeholder
                    HStack(spacing: 8) {
                        if let trailing = navigationBarItems?.trailing {
                            trailing
                        } else {
                            // Fixed placeholder keeps trailing side balanced
                            Color.clear.frame(width: TrayConstants.navigationButtonSize, height: TrayConstants.navigationButtonSize)
                        }
                    }
                }
                
                // Centered title
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .drawingGroup()
            }

            // Conditional progress bar
            if showsProgressBar, let idx = stepIndex, let total = stepCount, total > 1 {
                GeometryReader { geo in
                    let width = geo.size.width
                    let progress = CGFloat(idx + 1) / CGFloat(total)
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.secondary.opacity(TrayConstants.progressBarSecondaryOpacity))
                        Capsule().fill(Color.accentColor).frame(width: width * progress)
                    }
                }
                .frame(height: TrayConstants.progressBarHeight)
                .transition(.opacity)
            }
        }
    }
}

// MARK: - Local crossfade helper

private struct _TrayCrossfade<Value: Equatable, Content: View>: View {
    @Environment(\.trayConfig) private var config
    var value: Value
    var content: (Value) -> Content

    @State private var previous: Value? = nil
    @State private var progress: Double = 1 // 0 = old, 1 = new

    var body: some View {
        ZStack {
            if let prev = previous {
                content(prev).opacity(1 - progress)
            }
            content(value).opacity(progress)
        }
        .onChange(of: value) { old, _ in
            previous = old
            progress = 0
            let anim = TrayConstants.defaultCrossFadeAnimation
            withAnimation(anim) { progress = 1 }
        }
        .onAnimationCompleted(for: progress) {
            // Once the fade completes, drop the previous view to keep the tree small
            previous = nil
        }
    }
}


// MARK: - Utilities

struct VariableRoundedRectangle: Shape {
    var tl: CGFloat
    var tr: CGFloat
    var bl: CGFloat
    var br: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.size.width
        let h = rect.size.height
        let tl = max(0, min(min(self.tl, h/2), w/2))
        let tr = max(0, min(min(self.tr, h/2), w/2))
        let bl = max(0, min(min(self.bl, h/2), w/2))
        let br = max(0, min(min(self.br, h/2), w/2))

        p.move(to: CGPoint(x: w/2, y: 0))
        p.addLine(to: CGPoint(x: w - tr, y: 0))
        p.addQuadCurve(to: CGPoint(x: w, y: tr), control: CGPoint(x: w, y: 0))
        p.addLine(to: CGPoint(x: w, y: h - br))
        p.addQuadCurve(to: CGPoint(x: w - br, y: h), control: CGPoint(x: w, y: h))
        p.addLine(to: CGPoint(x: bl, y: h))
        p.addQuadCurve(to: CGPoint(x: 0, y: h - bl), control: CGPoint(x: 0, y: h))
        p.addLine(to: CGPoint(x: 0, y: tl))
        p.addQuadCurve(to: CGPoint(x: tl, y: 0), control: CGPoint(x: 0, y: 0))
        p.closeSubpath()
        return p
    }
}

@MainActor
func deviceBottomCornerRadius() -> CGFloat {
#if canImport(UIKit)
    // Try to read the actual display corner radius via KVC (mirrors BrainblastUI.RainbowRim approach)
    if let radius = (UIScreen.main as AnyObject).value(forKey: "_displayCornerRadius") as? CGFloat, radius > 0 {
        return radius
    }
    // Fallback: infer from safe area presence
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let win = windowScene.windows.first {
        return win.safeAreaInsets.bottom > 0 ? TrayConstants.deviceCornerRadiusWithSafeArea : TrayConstants.deviceCornerRadiusWithoutSafeArea
    }
#endif
    return TrayConstants.defaultDeviceCornerRadius
}

// MARK: - TrayConfig Extensions

public extension TrayConfig {
    /// Configure tray compression behavior on tap
    func trayCompress(enabled: Bool = true, scale: CGFloat = TrayConstants.defaultCompressionScale, animation: Animation = TrayConstants.defaultCompressionAnimation) -> TrayConfig {
        var config = self
        config.compressionEnabled = enabled
        config.compressionScale = scale
        config.compressionAnimation = animation
        return config
    }
    
    /// Configure tray padding around the tray surface
    func trayPadding(horizontal: CGFloat? = nil, bottom: CGFloat? = nil) -> TrayConfig {
        var config = self
        if let horizontal = horizontal {
            config.horizontalPadding = horizontal
        }
        if let bottom = bottom {
            config.bottomPadding = bottom
        }
        return config
    }
    
    /// Configure tray padding with a single value for all sides
    func trayPadding(_ padding: CGFloat) -> TrayConfig {
        var config = self
        config.horizontalPadding = padding
        config.bottomPadding = padding
        return config
    }
}
