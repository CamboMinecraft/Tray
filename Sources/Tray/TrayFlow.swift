import SwiftUI
import SwiftUIX

// MARK: - Flow Controller (for trait-based navigation)

@MainActor
public final class TrayFlowController: ObservableObject {
    public var next: () -> Void = {}
    public var back: () -> Void = {}
    public var close: () -> Void = {}
    public init() {}
}

private struct TrayFlowControllerKey: @preconcurrency EnvironmentKey { @MainActor static let defaultValue = TrayFlowController() }
public extension EnvironmentValues { var trayFlow: TrayFlowController { get { self[TrayFlowControllerKey.self] } set { self[TrayFlowControllerKey.self] = newValue } } }

// MARK: - Flow Modifier

public struct TrayFlowModifier<Pages: View>: ViewModifier {
    @Binding var isPresented: Bool
    let config: TrayConfig
    @ViewBuilder var pages: () -> Pages

    @Environment(\.trayConfig) private var envConfig
    @State private var index: Int = 0
    @StateObject private var flow = TrayFlowController()
    @State private var dragOffset: CGFloat = 0
    @State private var surfaceOffset: CGFloat = 0
    @State private var isOverlayVisible: Bool = false
    @State private var resolvedAnim: Animation? = nil
    @State private var baseOffset: CGFloat = TrayConstants.flowBaseOffset // starting off-screen distance (height + 60)
    @State private var stretch: CGFloat = 0
    @State private var measuredHeight: CGFloat? = nil

    public func body(content: Content) -> some View {
        #if canImport(UIKit)
        content
            .environment(\.trayConfig, config)
            .onChange(of: isPresented) { _, newValue in
                if newValue {
                    TrayWindowManager.shared.presentFlow(isPresented: $isPresented, config: envConfig, pages: pages)
                } else {
                    // Window root animates dismissal and then removes itself.
                }
            }
        #else
        content
            .environment(\.trayConfig, config)
            .overlay(alignment: .bottom) {
                if isOverlayVisible {
                    // Progressive dimming based on how far the tray surface is on-screen
                    let total = max(1, baseOffset)
                    let y = max(0, surfaceOffset + dragOffset)
                    let dimOpacity = 1 - min(1, y / total)
                    config.dimmingColor.opacity(dimOpacity)
                        .ignoresSafeArea()
                        .onTapGesture { if config.tapOutsideToDismiss { isPresented = false } }
                        .overlay(alignment: .bottom) {
                            // Build pages via variadic adapter so we can read traits
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
                                    let height = detent == .automatic
                                    ? min(max(140, measuredHeight ?? 0), cap)
                                    : detent.height(for: proxy.size.height)
                                    let bottomCorner: CGFloat = proxy.safeAreaInsets.bottom > 0 ? 44 : 20

                                    VStack(spacing: 0) {
                                        let showsNavBar = pageNavBarInfo?.showsNavigationBar ?? config.showsNavigationBar
                                        if showsNavBar {
                                            TrayNavigationBar(
                                                title: title,
                                                canGoBack: clamped > 0,
                                                onBack: {
                                                    let backAnim = pageAnim ?? envConfig.flowBackAnimation
                                                    withAnimation(backAnim) { index = max(0, clamped - 1) }
                                                },
                                                onClose: {
                                                    let closeAnim = pageAnim ?? envConfig.dismissAnimation
                                                    withAnimation(closeAnim) { isPresented = false }
                                                },
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
                                        }
                                    }
                                    .readTrayHeight($measuredHeight)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: height + max(0, stretch))
                                    .animation(pageAnim ?? envConfig.flowNextAnimation, value: measuredHeight)
                                    .trayApplyBackground(config: config, cornerRadius: config.cornerRadius, bottomCorner: bottomCorner)
                                    .shadow(color: config.shadow, radius: 20, x: 0, y: -8)
                                    .ignoresSafeArea(edges: .bottom)
                                    .padding(.horizontal, 8)
                                    .padding(.bottom, 8)
                                    .offset(y: surfaceOffset + dragOffset)
                                    .gesture(
                                        DragGesture(minimumDistance: 8)
                                            .onChanged { value in
                                                guard config.dragToDismiss else { return }
                                                let dy = value.translation.height
                                                if dy >= 0 {
                                                    dragOffset = max(0, dy)
                                                    stretch = 0
                                                } else {
                                                    let factor: CGFloat = 0.18
                                                    let maxStretch: CGFloat = 28
                                                    stretch = min(maxStretch, -dy * factor)
                                                    dragOffset = 0
                                                }
                                            }
                                            .onEnded { value in
                                                guard config.dragToDismiss else { return }
                                                if value.translation.height > 120 {
                                                    isPresented = false
                                                    dragOffset = 0
                                                } else {
                                                    let dragAnim = pageAnim ?? envConfig.dragResetAnimation
                                                    withAnimation(dragAnim) {
                                                        dragOffset = 0
                                                        stretch = 0
                                                    }
                                                }
                                            }
                                    )
                                    .environment(\.trayFlow, flow)
                                    .onAppear {
                                        let presentAnim = pageAnim ?? envConfig.presentAnimation
                                        resolvedAnim = pageAnim
                                        surfaceOffset = height + 60
                                        baseOffset = height + 60
                                        withAnimation(presentAnim) { surfaceOffset = 0 }
                                        let nextAnim = pageAnim ?? envConfig.flowNextAnimation
                                        let backAnim = pageAnim ?? envConfig.flowBackAnimation
                                        let closeAnim = pageAnim ?? envConfig.dismissAnimation
                                        flow.next = { withAnimation(nextAnim) { index = min(children.count - 1, index + 1) } }
                                        flow.back = { withAnimation(backAnim) { index = max(0, index - 1) } }
                                        flow.close = { withAnimation(closeAnim) { isPresented = false } }
                                    }
                                    .onAnimationCompleted(for: surfaceOffset) {
                                        if !isPresented {
                                            isOverlayVisible = false
                                            dragOffset = 0
                                            index = 0
                                        }
                                    }
                                    .onChange(of: clamped) { _, _ in
                                        resolvedAnim = pageAnim
                                        baseOffset = height + 60
                                        let nextAnim = pageAnim ?? envConfig.flowNextAnimation
                                        let backAnim = pageAnim ?? envConfig.flowBackAnimation
                                        let closeAnim = pageAnim ?? envConfig.dismissAnimation
                                        flow.next = { withAnimation(nextAnim) { index = min(children.count - 1, index + 1) } }
                                        flow.back = { withAnimation(backAnim) { index = max(0, index - 1) } }
                                        flow.close = { withAnimation(closeAnim) { isPresented = false } }
                                    }
                                    .onChange(of: measuredHeight) { _, _ in
                                        // keep base offset in sync when auto-sizing
                                        if detent == .automatic {
                                            baseOffset = height + 60
                                        }
                                    }
                                }
                            }
                        }
                        .zIndex(1000)
                }
            }
            .onChange(of: isPresented) { _, newValue in
                if newValue {
                    isOverlayVisible = true
                } else {
                    let anim = resolvedAnim ?? envConfig.dismissAnimation
                    withAnimation(anim) { surfaceOffset = 10000 } // ensure goes off-screen
                }
            }
            .environment(\.trayFlow, flow)
        #endif
    }
}

public extension View {
    /// Presents a multi-step tray using view traits to describe pages.
    func trayFlow<Pages: View>(
        isPresented: Binding<Bool>,
        config: TrayConfig = .default,
        @ViewBuilder pages: @escaping () -> Pages
    ) -> some View {
        modifier(TrayFlowModifier(isPresented: isPresented, config: config, pages: pages))
    }
}

// MARK: - Tray Flow Background Override

public extension ModifiedContent where Content: View {
    /// Presents a multi-step tray with custom background.
    @MainActor
    func trayFlow<Pages: View, Background: ShapeStyle>(
        isPresented: Binding<Bool>,
        config: TrayConfig = .default,
        @ViewBuilder pages: @escaping () -> Pages
    ) -> some View where Modifier == TrayBackgroundModifier<Background> {
        var modifiedConfig = config
        modifiedConfig.background = AnyShapeStyle(modifier.background)
        return content.modifier(TrayFlowModifier(isPresented: isPresented, config: modifiedConfig, pages: pages))
    }
}
