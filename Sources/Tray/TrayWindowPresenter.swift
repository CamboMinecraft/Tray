import SwiftUI
import SwiftUIX
#if canImport(UIKit)
import UIKit
#endif


// MARK: - UIWindow Presenter

#if canImport(UIKit)
@MainActor
final class TrayWindowManager {
    static let shared = TrayWindowManager()
    private var trayWindow: UIWindow?
    private var isPresenting = false
    
    func presentBinding<Content: View>(
        isPresented: Binding<Bool>,
        config: TrayConfig,
        title: String?,
        @ViewBuilder content: @escaping () -> Content
    ) {
        guard !isPresenting else { return }
        isPresenting = true
        
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene ??
            UIApplication.shared.connectedScenes.first as? UIWindowScene else { 
            print("TrayWindowManager: Failed to find window scene")
            return 
        }
        
        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .clear
        window.windowLevel = .alert
        let host = UIHostingController(rootView: TrayBindingWindowRoot(
            isPresented: isPresented,
            config: config,
            title: title,
            content: content,
            onDismiss: { [weak self] in self?.dismiss() }
        ))
        host.view.backgroundColor = .clear
        window.rootViewController = host
        trayWindow = window
        window.makeKeyAndVisible()
    }
    
    func presentController(
        controller: TrayController,
        config: TrayConfig
    ) {
        guard !isPresenting else { return }
        isPresenting = true
        
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene ??
            UIApplication.shared.connectedScenes.first as? UIWindowScene else { 
            print("TrayWindowManager: Failed to find window scene")
            return 
        }
        
        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .clear
        window.windowLevel = .alert
        let host = UIHostingController(rootView: TrayControllerWindowRoot(
            controller: controller,
            config: config,
            onDismiss: { [weak self] in self?.dismiss() }
        ))
        host.view.backgroundColor = .clear
        window.rootViewController = host
        trayWindow = window
        window.makeKeyAndVisible()
    }
    
    func presentFlow<Pages: View>(
        isPresented: Binding<Bool>,
        config: TrayConfig,
        @ViewBuilder pages: @escaping () -> Pages
    ) {
        guard !isPresenting else { return }
        isPresenting = true
        
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene ??
            UIApplication.shared.connectedScenes.first as? UIWindowScene else { 
            print("TrayWindowManager: Failed to find window scene")
            return 
        }
        
        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .clear
        window.windowLevel = .alert
        let host = UIHostingController(rootView: TrayFlowWindowRoot(
            isPresented: isPresented,
            config: config,
            pages: pages,
            onDismiss: { [weak self] in self?.dismiss() }
        ))
        host.view.backgroundColor = .clear
        window.rootViewController = host
        trayWindow = window
        window.makeKeyAndVisible()
    }
    
    func dismiss() {
        trayWindow?.isHidden = true
        trayWindow = nil
        isPresenting = false
    }
}

// MARK: - Window Roots

private struct TraySurface<Inner: View>: View {
    let height: CGFloat
    let config: TrayConfig
    let inner: () -> Inner
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
    let presentAnimation: Animation
    let dismissAnimation: Animation
    let dragResetAnimation: Animation
    @Binding var dimmingProgress: CGFloat
    @Binding var measuredHeight: CGFloat?
    @Binding var isDragging: Bool
    
    @State private var dragOffset: CGFloat = 0
    @State private var surfaceOffset: CGFloat = 0
    @State private var stretch: CGFloat = 0
    @State private var isPressed: Bool = false
    
    init(height: CGFloat,
         config: TrayConfig,
         isPresented: Binding<Bool>,
         onDismiss: @escaping () -> Void,
         presentAnimation: Animation,
         dismissAnimation: Animation,
         dragResetAnimation: Animation,
         dimmingProgress: Binding<CGFloat>,
         measuredHeight: Binding<CGFloat?>,
         isDragging: Binding<Bool>,
         @ViewBuilder inner: @escaping () -> Inner) {
        self.height = height
        self.config = config
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.inner = inner
        self.presentAnimation = presentAnimation
        self.dismissAnimation = dismissAnimation
        self.dragResetAnimation = dragResetAnimation
        self._dimmingProgress = dimmingProgress
        self._measuredHeight = measuredHeight
        self._isDragging = isDragging
    }
    
    var body: some View {
        GeometryReader { proxy in
            let bottomCorner: CGFloat = deviceBottomCornerRadius()
            Color.clear
                .overlay(alignment: .bottom) {
                    VStack(spacing: 0) { inner() }
                        .frame(maxWidth: .infinity)
                        .frame(height: height + max(0, stretch))
                        .overlay(alignment: .topLeading) {
                            // Off-screen measurement for natural content height
                            VStack(spacing: 0) {
                                inner()
                            }
                            .frame(width: TrayConstants.measurementViewWidth) // Match tray width
                            .readTrayHeight($measuredHeight, isDragging: isDragging)
                            .id("surface-measure-\(height)") // Recreate when height changes
                            .offset(x: TrayConstants.offScreenOffset, y: TrayConstants.offScreenOffset) // Position off-screen
                            .opacity(0) // Make invisible
                        }
                        .trayApplyBackground(config: config, cornerRadius: config.cornerRadius, bottomCorner: bottomCorner)
                        .shadow(color: config.shadow, radius: TrayConstants.shadowRadius, x: 0, y: TrayConstants.shadowYOffset)
                        .padding(.horizontal, config.horizontalPadding)
                        .padding(.bottom, config.bottomPadding)
                        .offset(y: surfaceOffset + dragOffset)
                        .scaleEffect(config.compressionEnabled && isPressed ? config.compressionScale : 1.0)
                        .gesture(
                            SimultaneousGesture(
                                // Compression gesture - responds immediately to touch
                                config.compressionEnabled ?
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        if !isPressed {
                                            withAnimation(config.compressionAnimation) {
                                                isPressed = true
                                            }
                                        }
                                    }
                                    .onEnded { _ in
                                        if isPressed {
                                            withAnimation(config.compressionAnimation) {
                                                isPressed = false
                                            }
                                        }
                                    } : nil,
                                // Drag gesture for dismissal
                                DragGesture(minimumDistance: TrayConstants.minimumDragDistance)
                                .onChanged { value in
                                    isDragging = true
                                    let dy = value.translation.height
                                    if dy >= 0 {
                                        dragOffset = max(0, dy)
                                        stretch = 0
                                    } else {
                                        let factor: CGFloat = TrayConstants.dragStretchFactor
                                        let maxStretch: CGFloat = TrayConstants.maxDragStretch
                                        stretch = min(maxStretch, -dy * factor)
                                        dragOffset = 0
                                    }
                                }
                                .onEnded { value in
                                    isDragging = false
                                    if value.translation.height > TrayConstants.dragDismissThreshold {
                                        // Keep current dragOffset; slide down from current position
                                        isPresented = false
                                    } else {
                                        withAnimation(dragResetAnimation) {
                                            dragOffset = 0
                                            stretch = 0
                                        }
                                    }
                                }
                            )
                        )
                        .onAppear {
                            surfaceOffset = height + 60
                            updateDimming()
                            withAnimation(presentAnimation) { surfaceOffset = 0 }
                        }
                }
                .ignoresSafeArea()
                .onChange(of: isPresented) { _, newValue in
                    if !newValue {
                        withAnimation(dismissAnimation) { surfaceOffset = height + 80 }
                    }
                }
                .onChange(of: surfaceOffset) { _, _ in updateDimming() }
                .onChange(of: dragOffset) { _, _ in updateDimming() }
                .onAnimationCompleted(for: surfaceOffset) {
                    if !isPresented {
                        onDismiss()
                        dragOffset = 0
                    }
                }
        }
    }
    
    private func updateDimming() {
        let total = max(1, height + 60)
        let y = max(0, surfaceOffset + dragOffset)
        let p = 1 - min(1, y / total)
        dimmingProgress = p
    }
}

private struct TrayBindingWindowRoot<Content: View>: View {
    @Binding var isPresented: Bool
    let config: TrayConfig
    let title: String?
    let content: () -> Content
    let onDismiss: () -> Void
    @Environment(\.trayConfig) private var trayConfig
    @State private var dimOpacity: CGFloat = 0
    @State private var measuredHeight: CGFloat? = nil
    @State private var surfaceHeight: CGFloat = 300
    @State private var isDragging: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            config.dimmingColor.opacity(dimOpacity)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
            TraySurface(height: surfaceHeight,
                        config: config,
                        isPresented: $isPresented,
                        onDismiss: onDismiss,
                        presentAnimation: trayConfig.presentAnimation,
                        dismissAnimation: trayConfig.dismissAnimation,
                        dragResetAnimation: trayConfig.dragResetAnimation,
                        dimmingProgress: $dimOpacity,
                        measuredHeight: $measuredHeight,
                        isDragging: $isDragging) {
                VStack(spacing: 0) {
                    if config.showsNavigationBar {
                        TrayNavigationBar(
                            title: title ?? "",
                            canGoBack: false,
                            onBack: {},
                            onClose: { isPresented = false },
                            stepIndex: nil,
                            stepCount: nil,
                            showsProgressBar: config.showsNavigationProgressBar,
                            navigationBarItems: config.trayNavigationBarItems
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        
                        Divider().opacity(0.15)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    content()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding()
                }
                .readTrayHeight($measuredHeight, isDragging: isDragging)
            }
                        .onAppear { surfaceHeight = clampedHeight }
                        .onChange(of: measuredHeight) { _, _ in
                            withAnimation(trayConfig.presentAnimation) {
                                surfaceHeight = clampedHeight
                            }
                        }
        }
        // TraySurface handles animated dismissal then calls onDismiss.
    }
    
    private var clampedHeight: CGFloat {
#if canImport(UIKit)
        let screenHeight = UIScreen.main.bounds.height
#else
        let screenHeight: CGFloat = 800
#endif
        let cap = config.maxHeight ?? Tray.Detent.automatic.height(for: screenHeight)
        
        // Use max height when explicitly requested via preferMaxHeight
        if config.preferMaxHeight {
            return cap
        }
        
        return min(max(TrayConstants.minimumHeight, measuredHeight ?? TrayConstants.defaultFallbackHeight), cap)
    }
}

private struct TrayFlowWindowRoot<Pages: View>: View {
    @Binding var isPresented: Bool
    let config: TrayConfig
    @ViewBuilder var pages: () -> Pages
    let onDismiss: () -> Void
    
    @State private var index: Int = 0
    @StateObject private var flow = TrayFlowController()
    @Environment(\.trayConfig) private var trayConfig
    @State private var dimOpacity: CGFloat = 0
    @State private var measuredHeight: CGFloat? = nil
    @State private var surfaceHeight: CGFloat = 300
    @State private var isDragging: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            config.dimmingColor.opacity(dimOpacity)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
            _VariadicViewAdapter(pages()) { container in
                GeometryReader { proxy in
                    let children = container.children
                    let clamped = children.isEmpty ? 0 : max(0, min(index, children.count - 1))
                    let info = children.isEmpty ? nil : children[clamped].traits.trayPage
                    let pageAnim = children.isEmpty ? nil : children[clamped].traits.trayPageAnimation?.animation
                    let pageNavBarInfo = children.isEmpty ? nil : children[clamped].traits.trayPageNavigationBar
                    let title = info?.title ?? ""
                    let detent = info?.detent ?? .automatic
                    let cap = config.maxHeight ?? Tray.Detent.automatic.height(for: proxy.size.height)
                    let targetHeight = detent == .automatic ? (config.preferMaxHeight ? cap : min(max(TrayConstants.minimumHeight, measuredHeight ?? TrayConstants.defaultFallbackHeight), cap)) : detent.height(for: proxy.size.height)
                    let presentAnim = pageAnim ?? trayConfig.presentAnimation
                    let dismissAnim = pageAnim ?? trayConfig.dismissAnimation
                    let dragResetAnim = pageAnim ?? trayConfig.dragResetAnimation
                    let backAnim = pageAnim ?? trayConfig.flowBackAnimation
                    TraySurface(height: surfaceHeight,
                                config: config,
                                isPresented: $isPresented,
                                onDismiss: onDismiss,
                                presentAnimation: presentAnim,
                                dismissAnimation: dismissAnim,
                                dragResetAnimation: dragResetAnim,
                                dimmingProgress: $dimOpacity,
                                measuredHeight: $measuredHeight,
                                isDragging: $isDragging) {
                        VStack(spacing: 0) {
                            let showsNavBar = pageNavBarInfo?.showsNavigationBar ?? config.showsNavigationBar
                            if showsNavBar {
                                TrayNavigationBar(
                                    title: title,
                                    canGoBack: clamped > 0,
                                    onBack: { withAnimation(backAnim) { index = max(0, clamped - 1) } },
                                    onClose: { isPresented = false },
                                    stepIndex: clamped,
                                    stepCount: children.count,
                                    showsProgressBar: config.showsNavigationProgressBar,
                                    navigationBarItems: config.trayNavigationBarItems
                                )
                                .padding(.horizontal)
                                .padding(.top, 8)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                
                                Divider().opacity(0.15)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            if !children.isEmpty {
                                let pageTransition = children[clamped].traits.trayPageTransition?.transition ?? config.pageTransition
                                children[clamped]
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                    .padding()
                                    .id(clamped)
                                    .transition(pageTransition)
                                    .environment(\.trayFlow, flow)
                            }
                        }
                        .readTrayHeight($measuredHeight, isDragging: isDragging)
                    }
                                .environment(\.trayFlow, flow)
                                .onAppear {
                                    surfaceHeight = targetHeight
                                    // ensure initial measured height is captured
                                    // no-op here; height updates come via readTrayHeight below
                                    let nextAnim = pageAnim ?? trayConfig.flowNextAnimation
                                    let backAnim = pageAnim ?? trayConfig.flowBackAnimation
                                    let closeAnim = pageAnim ?? trayConfig.dismissAnimation
                                    flow.next = {
                                        let oldIndex = index
                                        let newIndex = min(children.count - 1, index + 1)
                                        withAnimation(nextAnim) { index = newIndex }
                                    }
                                    flow.back = {
                                        let oldIndex = index
                                        let newIndex = max(0, index - 1)
                                        withAnimation(backAnim) { index = newIndex }
                                    }
                                    flow.close = {
                                        withAnimation(closeAnim) { isPresented = false }
                                    }
                                }
                                .onChange(of: clamped) { _, _ in
                                    withAnimation(presentAnim) { surfaceHeight = targetHeight }
                                    let nextAnim = pageAnim ?? trayConfig.flowNextAnimation
                                    let backAnim = pageAnim ?? trayConfig.flowBackAnimation
                                    let closeAnim = pageAnim ?? trayConfig.dismissAnimation
                                    flow.next = {
                                        let oldIndex = index
                                        let newIndex = min(children.count - 1, index + 1)
                                        withAnimation(nextAnim) { index = newIndex }
                                    }
                                    flow.back = {
                                        let oldIndex = index
                                        let newIndex = max(0, index - 1)
                                        withAnimation(backAnim) { index = newIndex }
                                    }
                                    flow.close = {
                                        withAnimation(closeAnim) { isPresented = false }
                                    }
                                }
                                .onChange(of: index) { oldIndex, newIndex in
                                    // Force remeasurement when flow navigation happens
                                    measuredHeight = nil
                                    
                                    // Force complete remeasurement by invalidating the view tree
                                }
                                .onChange(of: measuredHeight) { _, _ in
                                    if detent == .automatic {
                                        withAnimation(presentAnim) { surfaceHeight = targetHeight }
                                    }
                                }
                    // measurement attached to inner VStack above
                }
            }
        }
        .environment(\.trayFlow, flow)
        // TraySurface handles animated dismissal then calls onDismiss.
    }
}

private struct TrayControllerWindowRoot: View {
    @ObservedObject var controller: TrayController
    let config: TrayConfig
    let onDismiss: () -> Void
    @Environment(\.trayConfig) private var trayConfig
    @State private var dimOpacity: CGFloat = 0
    @State private var measuredHeight: CGFloat? = nil
    @State private var surfaceHeight: CGFloat = 300
    @State private var isDragging: Bool = false
    @State private var contentAnimation: Animation = .default
    
    var body: some View {
        ZStack(alignment: .bottom) {
            config.dimmingColor.opacity(dimOpacity)
                .ignoresSafeArea()
                .onTapGesture { controller.dismiss() }
            TraySurface(height: surfaceHeight,
                        config: config,
                        isPresented: $controller.isPresented,
                        onDismiss: onDismiss,
                        presentAnimation: trayConfig.presentAnimation,
                        dismissAnimation: trayConfig.dismissAnimation,
                        dragResetAnimation: trayConfig.dragResetAnimation,
                        dimmingProgress: $dimOpacity,
                        measuredHeight: $measuredHeight,
                        isDragging: $isDragging) {
                VStack(spacing: 0) {
                    // Check if current view has navigation bar trait, fallback to global config
                    let currentIndex = controller.stack.count - 1
                    let pageNavBarVisibility = currentIndex >= 0 && currentIndex < controller.navigationBarVisibility.count ? controller.navigationBarVisibility[currentIndex] : nil
                    let showsNavBar = pageNavBarVisibility ?? config.showsNavigationBar

                    if showsNavBar {
                        TrayNavigationBar(
                            title: controller.titles.last ?? "",
                            canGoBack: controller.stack.count > 1,
                            onBack: { 
                                withAnimation(trayConfig.flowBackAnimation) { 
                                    controller.pop() 
                                }
                            },
                            onClose: { 
                                withAnimation(trayConfig.dismissAnimation) { 
                                    controller.dismiss() 
                                }
                            },
                            stepIndex: controller.stack.count > 0 ? controller.stack.count - 1 : 0,
                            stepCount: controller.stack.count,
                            showsProgressBar: config.showsNavigationProgressBar,
                            navigationBarItems: config.trayNavigationBarItems
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        
                        Divider().opacity(0.15)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    if let currentView = controller.stack.last {
                        currentView
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .padding()
                            .environment(\.trayController, controller)
                            .id(controller.stack.count) // Force view recreation on navigation
                            .transition(config.pageTransition) // Use page transition from config
                            .animation(contentAnimation, value: controller.stack.count)
                    }
                }
                .readTrayHeight($measuredHeight, isDragging: isDragging)
            }
                        .onAppear { surfaceHeight = clampedHeight }
                        .onChange(of: controller.stack.count) { old, new in
                            // Detect navigation direction and set appropriate animation
                            let forward = trayConfig.flowNextAnimation
                            let backward = trayConfig.flowBackAnimation
                            contentAnimation = (new >= old) ? forward : backward
                            
                            // Force remeasurement when navigation happens
                            measuredHeight = nil
                        }
                        .onChange(of: measuredHeight) { _, newHeight in
                            withAnimation(trayConfig.presentAnimation) {
                                surfaceHeight = clampedHeight
                            }
                        }
        }
        // TraySurface handles animated dismissal then calls onDismiss.
    }
    
    private var clampedHeight: CGFloat {
#if canImport(UIKit)
        let screenHeight = UIScreen.main.bounds.height
#else
        let screenHeight: CGFloat = 800
#endif
        let cap = config.maxHeight ?? Tray.Detent.automatic.height(for: screenHeight)
        
        // Use max height when explicitly requested via preferMaxHeight
        if config.preferMaxHeight {
            return cap
        }
        
        let result = min(max(TrayConstants.minimumHeight, measuredHeight ?? TrayConstants.defaultFallbackHeight), cap)
        return result
    }
}
#endif
