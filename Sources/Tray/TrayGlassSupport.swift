import SwiftUI

// Internal helper to apply either a ShapeStyle background or a custom applier closure.
extension View {
    @ViewBuilder
    func trayApplyBackground(config: TrayConfig, cornerRadius: CGFloat, bottomCorner: CGFloat) -> some View {
        let clipShape = VariableRoundedRectangle(
            tl: cornerRadius, tr: cornerRadius, bl: bottomCorner, br: bottomCorner
        )
        if let applier2 = config.backgroundApplierWithRadii {
            applier2(AnyView(self), cornerRadius, bottomCorner).clipShape(clipShape)
        } else if let applier = config.backgroundApplier {
            applier(AnyView(self)).clipShape(clipShape)
        } else {
            self.background(config.background).clipShape(clipShape)
        }
    }
}
