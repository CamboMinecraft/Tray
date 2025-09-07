import SwiftUI

#if DEBUG
public struct TrayAppStoreExampleView: View {
    @State private var showTray = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Button {
                showTray = true
            } label: {
                Text("Show App Store Tray")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundStyle(Color.white)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .tray(isPresented: $showTray, title: "Featured Apps") {
            FeaturedAppsView()
        }
        .trayPadding(12)
        .trayShowsNavigationProgressBar(true)
        .trayDefaultPageTransition(.blur)
        .trayAnimation(.bouncy)
        .trayBackground(.regularMaterial)
        .trayPreferMaxHeight()
    }
}

internal struct FeaturedAppsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero Section
                VStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay {
                            VStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 60, height: 60)
                                Text("Hero App")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    
                    TrayNavigationLink(title: "App Details") {
                        AppDetailsView()
                    } label: {
                        Text("GET")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 32)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
                
                // Categories Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Categories")
                            .font(.title2.weight(.semibold))
                        Spacer()
                        Text("See All")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach(0..<6, id: \.self) { index in
                            TrayNavigationLink(title: "Category \(index + 1)") {
                                CategoryView(categoryName: "Category \(index + 1)")
                            } label: {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 80)
                                    .overlay {
                                        VStack(spacing: 4) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.gray.opacity(0.4))
                                                .frame(width: 30, height: 30)
                                            Text("Category")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                            }
                        }
                    }
                }
                
                // Top Charts Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Top Free Apps")
                            .font(.title2.weight(.semibold))
                        Spacer()
                        Text("See All")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { index in
                            TrayNavigationLink(title: "App \(index)") {
                                AppDetailsView(appName: "App \(index)")
                            } label: {
                                HStack(spacing: 12) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                        .overlay {
                                            Text("\(index)")
                                                .font(.title3.weight(.bold))
                                                .foregroundColor(.secondary)
                                        }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.gray.opacity(0.4))
                                            .frame(width: 120, height: 14)
                                        
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 80, height: 12)
                                        
                                        HStack(spacing: 2) {
                                            ForEach(0..<5, id: \.self) { _ in
                                                Circle()
                                                    .fill(Color.orange)
                                                    .frame(width: 10, height: 10)
                                            }
                                            
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 30, height: 10)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text("GET")
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 60, height: 28)
                                        .background(Color.blue)
                                        .clipShape(Capsule())
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                }
                
                // Editor's Choice Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Editor's Choice")
                        .font(.title2.weight(.semibold))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(1...4, id: \.self) { index in
                                TrayNavigationLink(title: "Featured App \(index)") {
                                    AppDetailsView(appName: "Featured App \(index)")
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 200, height: 120)
                                            .overlay {
                                                VStack {
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(Color.gray.opacity(0.5))
                                                        .frame(width: 40, height: 40)
                                                    Text("Featured")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.gray.opacity(0.4))
                                                .frame(width: 140, height: 12)
                                            
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 100, height: 10)
                                        }
                                    }
                                    .frame(width: 200)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal, -16)
                }
                
                // Bottom padding
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 20)
            }
            .padding()
        }
    }
}

private struct AppDetailsView: View {
    let appName: String
    
    init(appName: String = "Sample App") {
        self.appName = appName
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App Header
                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .overlay {
                            Text("📱")
                                .font(.largeTitle)
                        }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 160, height: 16)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 12)
                        
                        HStack(spacing: 2) {
                            ForEach(0..<5, id: \.self) { _ in
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 12, height: 12)
                            }
                            
                            Text("4.8")
                                .font(.caption.weight(.medium))
                                .foregroundColor(.secondary)
                        }
                        
                        TrayNavigationLink(title: "Install", showsNavigationBar: false) {
                            InstallationView()
                        } label: {
                            Text("GET")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white)
                                .frame(width: 100, height: 36)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Spacer()
                }
                
                // Screenshots
                VStack(alignment: .leading, spacing: 12) {
                    Text("Screenshots")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 180, height: 320)
                                    .overlay {
                                        Text("Screenshot \(index)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal, -16)
                }
                
                // Description
                VStack(alignment: .leading, spacing: 12) {
                    Text("About \(appName)")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        ForEach(0..<6, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 12)
                        }
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 200, height: 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                // Reviews
                VStack(alignment: .leading, spacing: 16) {
                    Text("Reviews")
                        .font(.headline)
                    
                    ForEach(0..<3, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 32, height: 32)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.gray.opacity(0.4))
                                        .frame(width: 100, height: 10)
                                    
                                    HStack(spacing: 2) {
                                        ForEach(0..<5, id: \.self) { _ in
                                            Circle()
                                                .fill(Color.orange)
                                                .frame(width: 8, height: 8)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 40, height: 8)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(0..<3, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 10)
                                }
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 150, height: 10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        if index < 2 {
                            Divider()
                        }
                    }
                }
                
                // Bottom padding
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 40)
            }
            .padding()
        }
    }
}

private struct CategoryView: View {
    let categoryName: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Category Header
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay {
                            Text("🎮")
                                .font(.largeTitle)
                        }
                    
                    Text(categoryName)
                        .font(.title2.weight(.semibold))
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 200, height: 12)
                }
                
                // Featured Apps in Category
                VStack(alignment: .leading, spacing: 12) {
                    Text("Top Apps")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 16) {
                        ForEach(1...8, id: \.self) { index in
                            TrayNavigationLink(title: "\(categoryName) App \(index)") {
                                AppDetailsView(appName: "\(categoryName) App \(index)")
                            } label: {
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 120)
                                        .overlay {
                                            VStack {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.gray.opacity(0.4))
                                                    .frame(width: 40, height: 40)
                                                Text("App \(index)")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    
                                    VStack(spacing: 4) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.gray.opacity(0.4))
                                            .frame(height: 10)
                                        
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 60, height: 8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Bottom padding
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 20)
            }
            .padding()
        }
    }
}

private struct InstallationView: View {
    @Environment(\.trayController) var tray
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 20) {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .overlay {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 80, height: 80)
                            .overlay {
                                Image(systemName: "checkmark")
                                    .font(.largeTitle.weight(.bold))
                                    .foregroundColor(.white)
                            }
                    }
                
                Text("Installation Complete!")
                    .font(.title2.weight(.semibold))
                
                Text("The app has been installed successfully and is ready to use.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button("Done") {
                tray.dismiss()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.blue)
            .clipShape(Capsule())
        }
        .padding()
    }
}

#Preview("App Store Tray Example") {
    TrayAppStoreExampleView()
}
#endif
