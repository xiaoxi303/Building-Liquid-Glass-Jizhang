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
/// Houses the custom Liquid Glass TabBar and routes to DashboardView, AnalyticsView, and SettingsView.
/// Adheres strictly to Swift 6 concurrency and multi-window size classes (avoids UIScreen).
public struct TabController: View {
    @State private var selectedTab: Tab = .detail
    @Namespace private var tabBarNamespace
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Content View Router
            Group {
                switch selectedTab {
                case .detail:
                    DashboardView() // Linked to dedicated DashboardView.swift
                case .analytics:
                    AnalyticsView() // Linked to PlaceholderViews.swift
                case .settings:
                    SettingsView()  // Linked to PlaceholderViews.swift
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 2. Custom Liquid Glass Floating TabBar
            HStack(spacing: 0) {
                ForEach(Tab.allCases) { tab in
                    Button(action: {
                        // High-grade spring physics for the fluid "liquid glass" bubble transfer animation
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
                        .contentShape(Rectangle()) // Expand tappable area
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
            // Liquid Glass effect modifier applied to the TabBar capsule
            .liquidGlass(cornerRadius: 32, shadowRadius: 24, borderOpacity: 0.3)
            // Floating layout spacing: works on iPhone, iPad multi-window and macOS natively
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom) // Avoid shifting when keyboard appears
    }
}
