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
                
                // 3. Upgraded Liquid Water Droplet Capsule TabBar (Strict Layer Depth Hierarchy)
                ZStack {
                    // LAYER 1 (BOTTOM): Glass Outer Capsule Shell
                    Capsule()
                        .fill(Color.clear.background(.ultraThinMaterial))
                        .overlay(
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.35),
                                            .white.opacity(0.1),
                                            .black.opacity(0.2),
                                            .white.opacity(0.25)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.8
                                )
                        )
                        .chromaticEdgeGlow(cornerRadius: 27, lineWidth: 1.0, opacity: 0.25)
                        .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 10)
                    
                    // LAYER 2 (MIDDLE): Liquid Active Indicator (Gradient masked by LiquidFusionView)
                    LinearGradient(
                        colors: [Color(hex: "#22D3EE"), Color(hex: "#06B6D4"), Color(hex: "#2563EB")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(
                        LiquidFusionView(blurRadius: 10, contrastThreshold: 18) {
                            ZStack {
                                // Guide dots (white, subtle, small)
                                HStack(spacing: 0) {
                                    ForEach(Tab.allCases) { tab in
                                        Circle()
                                            .fill(Color.white.opacity(0.5))
                                            .frame(width: 8, height: 8)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.horizontal, 10)
                                
                                // Sliding active capsule (white)
                                HStack(spacing: 0) {
                                    ForEach(Tab.allCases) { tab in
                                        Group {
                                            if selectedTab == tab {
                                                Capsule()
                                                    .fill(Color.white)
                                                    .matchedGeometryEffect(id: "liquidBubble", in: tabBarNamespace)
                                                    .frame(width: 64, height: 38)
                                            } else {
                                                Color.clear
                                                    .frame(width: 64, height: 38)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.horizontal, 10)
                            }
                        }
                    )
                    
                    // LAYER 3 (TOP): Tab Icons & Text Buttons (Completely crisp, no blur)
                    HStack(spacing: 0) {
                        ForEach(Tab.allCases) { tab in
                            Button(action: {
                                // Custom spring for the water bubble stretch-and-snap interaction
                                withAnimation(.spring(response: 0.38, dampingFraction: 0.68, blendDuration: 0)) {
                                    selectedTab = tab
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 19, weight: .semibold))
                                        .foregroundColor(selectedTab == tab ? Color(hex: "#0F172A") : .white.opacity(0.45))
                                        .frame(height: 22)
                                    
                                    Text(tab.title)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(selectedTab == tab ? Color(hex: "#0F172A") : .white.opacity(0.45))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 10)
                }
                .frame(height: 54)
                .padding(.horizontal, 24)
                // Dynamic padding to float cleanly above home bar or flat screen edge
                .padding(.bottom, safeAreaBottom > 0 ? safeAreaBottom : 12)
            }
            .ignoresSafeArea(.all, edges: .all)
        }
    }
}
