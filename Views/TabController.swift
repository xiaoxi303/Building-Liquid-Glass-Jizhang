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
/// Houses the upgraded custom floating Liquid Glass TabBar with liquid stretching animations.
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
                
                // 2. Main screen view content
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
                    
                    HStack(spacing: 0) {
                        ForEach(Tab.allCases) { tab in
                            Button(action: {
                                // Specific low damping spring for fluid, bouncy water droplet merging effect
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.68, blendDuration: 0)) {
                                    selectedTab = tab
                                }
                            }) {
                                VStack(spacing: 6) {
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
                                .background(
                                    ZStack {
                                        if selectedTab == tab {
                                            // Water-droplet capsule background highlight
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.cyan.opacity(0.18), Color.blue.opacity(0.08)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .matchedGeometryEffect(id: "liquidBubble", in: tabBarNamespace)
                                                .overlay(
                                                    Capsule()
                                                        .stroke(
                                                            LinearGradient(
                                                                colors: [.cyan.opacity(0.45), .blue.opacity(0.15)],
                                                                startPoint: .top,
                                                                endPoint: .bottom
                                                            ),
                                                            lineWidth: 1.2
                                                        )
                                                        .matchedGeometryEffect(id: "liquidBubbleBorder", in: tabBarNamespace)
                                                )
                                                // Outer shadow to make the fluid droplet feel raised
                                                .shadow(color: Color.cyan.opacity(0.25), radius: 6, x: 0, y: 2)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                        }
                                    }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    // High refraction liquid glass capsule container
                    .liquidGlass(cornerRadius: 32, shadowRadius: 24, borderOpacity: 0.35)
                    // Inset from sides to look floating
                    .padding(.horizontal, 24)
                    // Dynamic padding so it floats perfectly above home bar or flat screen edge
                    .padding(.bottom, safeAreaBottom > 0 ? safeAreaBottom : 12)
                }
            }
            .ignoresSafeArea(.all, edges: .all)
        }
    }
}
