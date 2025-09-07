import SwiftUI

#if DEBUG
public struct TrayExampleView: View {
    @State private var showFlow = false
    @State private var showBinding = false
    
    public init() {
        
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            FeaturedAppsView()
            Button {
                showFlow = true
            } label: {
                Text("Show Tray")
                    .frame(
                        maxWidth: .infinity,
                        alignment: .center
                    )
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundStyle(Color.white)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .tray(isPresented: $showFlow, title: "Welcome") {
            ChooseGroupStep()
        }
        .trayPadding(8)
        .trayShowsNavigationProgressBar(true)
        .trayDefaultPageTransition(.blur)
        .trayAnimation(.bouncy)
        .trayBackground { surface in
            if #available(iOS 18.0, macOS 15.0, *) {
                if #available(iOS 26.0, *) {
                    surface.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
                }
            } else {
                surface.background(.ultraThinMaterial)
            }
        }
        
    }
}

private struct ChooseGroupStep: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose a group to continue.").foregroundStyle(.secondary)
            ForEach(1...5, id: \.self) { idx in
                TrayNavigationLink(title: "Are you sure?") {
                    ConfirmStep()
                } label: {
                    Text("Wallet Group \(idx)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.systemGray6)
                        .cornerRadius(8)
                }
            }
        }
    }
}

private struct ConfirmStep: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Creating a new wallet group means a new recovery phrase.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            TrayNavigationLink(title: "Done", showsNavigationBar: false) {
                DoneStep()
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundStyle(Color.white)
                    .clipShape(Capsule())
            }
        }
    }
}

private struct DoneStep: View {
    @Environment(\.trayController) var tray
    var body: some View {
        VStack(spacing: 16) {
            Text("All set!").font(.title3).fontWeight(.semibold)
            Spacer(minLength: 200)
            Button("Close") { tray.dismiss() }
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
                .frame(height: 50)
                .background(Color.blue)
                .foregroundStyle(Color.white)
                .clipShape(Capsule())
        }
    }
}

#Preview("Tray Example") {
    TrayExampleView()
}
#endif
