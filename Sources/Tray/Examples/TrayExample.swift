import SwiftUI

#if DEBUG
public struct TrayExampleView: View {
    @State private var showFlow = false
    @State private var showBinding = false
    
    public init() {
        
    }
    
    public var body: some View {
        TabView {
            VStack(spacing: 16) {
                FeaturedAppsView()
                Button {
                    showFlow = true
                } label: {
                    Text("Show Tray")
                        .blueButton()
                }
            }
            .padding()
            .tray(isPresented: $showFlow, title: "Welcome") {
                ChooseGroupStep()
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
                        .blueButton()
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
                    .blueButton()
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
                .blueButton()
        }
    }
}

#Preview("Tray Example") {
    TrayExampleView()
}
#endif


extension View {
    func blueButton() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 50)
            .background(Color.blue)
            .foregroundStyle(Color.white)
            .clipShape(Capsule())
    }
}
