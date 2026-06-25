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
/// Houses the custom floating Liquid Glass TabBar and routes to DashboardView, AnalyticsView, and SettingsView.
/// Solves safe area bleeding for full screen displays and floats above the Home indicator.
public struct TabController: View {
    @State private var selectedTab: Tab = .detail
    @Namespace private var tabBarNamespace
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geometry in
            // Read safe area bottom padding (e.g., Home indicator area height)
            let safeAreaBottom = geometry.safeAreaInsets.bottom
            
            ZStack(alignment: .bottom) {
                // 1. Full Screen deep mesh gradient background
                LinearGradient(
                    colors: [Color(hex: "#0F172A"), Color(hex: "#1E293B"), Color(hex: "#020617")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 2. Content View Router (ignores safe area to allow scroll views to bleed to edge)
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
                
                // 3. Floating Capsule Liquid Glass TabBar
                VStack {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        ForEach(Tab.allCases) { tab in
                            Button(action: {
                                // High-grade spring physics for bubble transfer
                                withAnimation(.spring(response: 0.38, dampingFraction: 0.76, blendDuration: 0)) {
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
                                .contentShape(Rectangle()) // Expand interactive tap target area
                                .background(
                                    ZStack {
                                        if selectedTab == tab {
                                            // Sliding capsule liquid highlight bubble
                                            Capsule()
                                                .fill(Color.cyan.opacity(0.12))
                                                .matchedGeometryEffect(id: "liquidBubble", in: tabBarNamespace)
                                                .overlay(
                                                    Capsule()
                                                        .stroke(
                                                            LinearGradient(
                                                                colors: [.cyan.opacity(0.4), .cyan.opacity(0.1)],
                                                                startPoint: .top,
                                                                endPoint: .bottom
                                                            ),
                                                            lineWidth: 1
                                                        )
                                                        .matchedGeometryEffect(id: "liquidBubbleBorder", in: tabBarNamespace)
                                                )
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                        }
                                    }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    // Apply visual refraction styling
                    .liquidGlass(cornerRadius: 32, shadowRadius: 24, borderOpacity: 0.3)
                    // Float spacing: horizontal capsule shape inset
                    .padding(.horizontal, 24)
                    // Dynamic bottom gap to float cleanly above home indicator (or default to 12 on flat screens)
                    .padding(.bottom, safeAreaBottom > 0 ? safeAreaBottom : 12)
                }
            }
            .ignoresSafeArea(.all, edges: .all) // Root ZStack ignores all safe areas
        }
    }
}
