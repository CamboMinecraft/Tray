import SwiftUI

// MARK: - Height Measurement Utility

struct _TrayHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    // Use latest reported value so height can shrink as well as grow.
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

struct TrayHeightReader: ViewModifier {
    @Binding var height: CGFloat?
    var isDragging: Bool = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { proxy in
                    Color.clear.preference(key: _TrayHeightKey.self, value: proxy.size.height)
                }
                .allowsHitTesting(false)
            )
            .onPreferenceChange(_TrayHeightKey.self) { h in
                // Only update if we get a meaningful measurement (> 0) and we're not dragging
                // Also prevent height increases that might be due to stretch effects
                if h > 0 && !isDragging && (height == nil || h <= (height! + 10)) {
                    height = h
                }
            }
    }
}

extension View {
    func readTrayHeight(_ height: Binding<CGFloat?>, isDragging: Bool = false) -> some View { 
        modifier(TrayHeightReader(height: height, isDragging: isDragging)) 
    }
}

