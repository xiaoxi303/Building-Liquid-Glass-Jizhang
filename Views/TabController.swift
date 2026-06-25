import SwiftUI

/// Tab categories for navigation
public enum Tab: String, CaseIterable, Identifiable {
    case detail
    case analytics
    case settings
    
    public var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .detail: return "doc.text.fill"
        case .analytics: return "chart.bar.xaxis"
        case .settings: return "gearshape.fill"
        }
    }
    
    var title: String {
        switch self {
        case .detail: return "明细"
        case .analytics: return "统计"
        case .settings: return "设置"
        }
    }
}

/// The root UI container of the application.
/// Houses the custom floating Liquid Glass TabBar with liquid water-droplet metaball transitions.
public struct TabController: View {
    @State private var selectedTab: Tab = .detail
    @Namespace private var tabBarNamespace
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geometry in
            let safeAreaBottom = geometry.safeAreaInsets.bottom
            
            ZStack(alignment: .bottom) {
                // 1. Full Screen deep mesh gradient background
                LinearGradient(
                    colors: [Color(hex: "#0F172A"), Color(hex: "#1E293B"), Color(hex: "#020617")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 2. Main screen view content (bleeds to screen edges)
                Group {
                    switch selectedTab {
                    case .detail:
                        DashboardView()
                    case .analytics:
                        AnalyticsView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)
                
                // 3. Upgraded Liquid Water Droplet Capsule TabBar
                VStack {
                    Spacer()
                    
                    ZStack {
                        // Background: Liquid Metaball Layer (uses LiquidFusionView)
                        LiquidFusionView(blurRadius: 10, contrastThreshold: 16) {
                            ZStack {
                                // Small static guide dots
                                HStack(spacing: 0) {
                                    ForEach(Tab.allCases) { tab in
                                        Circle()
                                            .fill(Color.cyan.opacity(0.7))
                                            .frame(width: 14, height: 14)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.horizontal, 10)
                                
                                // Sliding active capsule indicator (interpolates position)
                                HStack(spacing: 0) {
                                    ForEach(Tab.allCases) { tab in
                                        Group {
                                            if selectedTab == tab {
                                                Capsule()
                                                    .fill(Color.cyan)
                                                    .matchedGeometryEffect(id: "liquidBubble", in: tabBarNamespace)
                                                    .frame(width: 58, height: 32)
                                                    .padding(.horizontal, 6)
                                            } else {
                                                Color.clear
                                                    .frame(width: 58, height: 32)
                                                    .padding(.horizontal, 6)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.horizontal, 10)
                            }
                        }
                        .frame(height: 52)
                        
                        // Foreground: Tab Icons & Text Buttons (rendered clear on top of the indicators)
                        HStack(spacing: 0) {
                            ForEach(Tab.allCases) { tab in
                                Button(action: {
                                    // Custom spring for the water bubble stretch-and-snap interaction matching video details
                                    withAnimation(.spring(response: 0.40, dampingFraction: 0.70, blendDuration: 0)) {
                                        selectedTab = tab
                                    }
                                }) {
                                    VStack(spacing: 5) {
                                        Image(systemName: tab.icon)
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(selectedTab == tab ? .cyan : .white.opacity(0.4))
                                            .frame(height: 24)
                                        
                                        Text(tab.title)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(selectedTab == tab ? .cyan : .white.opacity(0.4))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                    .padding(.vertical, 8)
                    // High refraction liquid glass capsule container
                    .liquidGlass(cornerRadius: 32, shadowRadius: 24, borderOpacity: 0.35)
                    // Apply chromatic aberration edge glow overlay to simulate glass color dispersion
                    .chromaticEdgeGlow(cornerRadius: 32, lineWidth: 1.0, opacity: 0.25)
                    .padding(.horizontal, 24)
                    // Dynamic padding to float cleanly above home bar or flat screen edge
                    .padding(.bottom, safeAreaBottom > 0 ? safeAreaBottom : 12)
                }
            }
            .ignoresSafeArea(.all, edges: .all)
        }
    }
}
