import SwiftUI
import SwiftData

/// SettingsView rewritten to align with premium settings panel layouts.
/// Incorporates custom-engineered liquid toggles, dynamic nested push sub-panels, 
/// glass checkmarks, and 0.5px micro-glow line partitions.
public struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]
    
    // Group 1: Basic configuration settings stored in AppStorage
    @AppStorage("monthlyStartDay") private var monthlyStartDay: Int = 1
    @AppStorage("showRecordImages") private var showRecordImages: Bool = true
    @AppStorage("showLocations") private var showLocations: Bool = true
    @AppStorage("showPromos") private var showPromos: Bool = false
    
    // Group 2: Push services and nested checkmarks
    @AppStorage("isPushEnabled") private var isPushEnabled: Bool = false
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled: Bool = true
    @AppStorage("budgetWarningEnabled") private var budgetWarningEnabled: Bool = true
    @AppStorage("featurePromoEnabled") private var featurePromoEnabled: Bool = false
    @AppStorage("weeklyReviewEnabled") private var weeklyReviewEnabled: Bool = true
    
    // Interactive Modal alert triggers
    @State private var showResetConfirmModal = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background deep mesh gradient matching Liquid Glass aesthetics
                LinearGradient(
                    colors: [Color(hex: "#0F172A"), Color(hex: "#1E293B"), Color(hex: "#020617")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // 1. Group 1: Basic configurations (Liquid Glass Card)
                        VStack(spacing: 0) {
                            SettingsRow(icon: "calendar", iconColor: .cyan, title: "月统计起始日") {
                                HStack(spacing: 6) {
                                    Text("每月\(monthlyStartDay)日")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.5))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white.opacity(0.3))
                                }
                            }
                            
                            CustomDivider()
                            
                            SettingsRow(icon: "message.fill", iconColor: .purple, title: "胖咔回复设置") {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            
                            CustomDivider()
                            
                            SettingsRow(icon: "dollarsign.circle.fill", iconColor: .green, title: "货币单位") {
                                HStack(spacing: 6) {
                                    Text("人民币 (CNY)")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.5))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white.opacity(0.3))
                                }
                            }
                            
                            CustomDivider()
                            
                            SettingsRow(icon: "photo.fill", iconColor: .blue, title: "展示记录图片") {
                                LiquidToggle(isOn: $showRecordImages)
                            }
                            
                            CustomDivider()
                            
                            SettingsRow(icon: "mappin.and.ellipse", iconColor: .red, title: "地点展示") {
                                LiquidToggle(isOn: $showLocations)
                            }
                            
                            CustomDivider()
                            
                            SettingsRow(icon: "gift.fill", iconColor: .orange, title: "优惠推荐") {
                                LiquidToggle(isOn: $showPromos)
                            }
                        }
                        .liquidGlass(cornerRadius: 24, shadowRadius: 16, borderOpacity: 0.25)
                        .chromaticEdgeGlow(cornerRadius: 24, lineWidth: 1.0, opacity: 0.20)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // 2. Group 2: Nested pushing controls (Dynamic slide animation card)
                        VStack(spacing: 0) {
                            SettingsRow(icon: "bell.fill", iconColor: .yellow, title: "推送服务") {
                                LiquidToggle(isOn: $isPushEnabled)
                            }
                            
                            if isPushEnabled {
                                VStack(spacing: 0) {
                                    CustomDivider()
                                    
                                    SettingsNestedRow(title: "每日记账提醒") {
                                        SettingsCheckmark(isChecked: dailyReminderEnabled) {
                                            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                                dailyReminderEnabled.toggle()
                                            }
                                        }
                                    }
                                    
                                    CustomDivider()
                                    
                                    SettingsNestedRow(title: "预算超限提醒") {
                                        SettingsCheckmark(isChecked: budgetWarningEnabled) {
                                            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                                budgetWarningEnabled.toggle()
                                            }
                                        }
                                    }
                                    
                                    CustomDivider()
                                    
                                    SettingsNestedRow(title: "新功能推荐通知") {
                                        SettingsCheckmark(isChecked: featurePromoEnabled) {
                                            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                                featurePromoEnabled.toggle()
                                            }
                                        }
                                    }
                                    
                                    CustomDivider()
                                    
                                    SettingsNestedRow(title: "每周账单回顾") {
                                        SettingsCheckmark(isChecked: weeklyReviewEnabled) {
                                            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                                weeklyReviewEnabled.toggle()
                                            }
                                        }
                                    }
                                }
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .liquidGlass(cornerRadius: 24, shadowRadius: 16, borderOpacity: 0.25)
                        .chromaticEdgeGlow(cornerRadius: 24, lineWidth: 1.0, opacity: 0.20)
                        .padding(.horizontal)
                        .animation(.spring(response: 0.36, dampingFraction: 0.74, blendDuration: 0), value: isPushEnabled)
                        
                        // 3. Group 3: Help, info & ledger clean
                        VStack(spacing: 0) {
                            SettingsRow(icon: "questionmark.circle.fill", iconColor: .teal, title: "帮助与反馈") {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            
                            CustomDivider()
                            
                            SettingsRow(icon: "info.circle.fill", iconColor: .gray, title: "关于App") {
                                HStack(spacing: 6) {
                                    Text("v1.0.0 @ WWDC26 Spec")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.5))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white.opacity(0.3))
                                }
                            }
                            
                            CustomDivider()
                            
                            SettingsRow(icon: "trash.fill", iconColor: .red, title: "一键清空账本") {
                                Button(action: {
                                    withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                                        showResetConfirmModal = true
                                    }
                                }) {
                                    Text("清空数据")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .liquidGlass(cornerRadius: 24, shadowRadius: 16, borderOpacity: 0.25)
                        .chromaticEdgeGlow(cornerRadius: 24, lineWidth: 1.0, opacity: 0.20)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 140)
                }
                
                // 4. Custom Liquid Glass Modal Alert Box for database reset
                if showResetConfirmModal {
                    ZStack {
                        // Blurred dark backdrop
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .transition(.opacity)
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.25)) {
                                    showResetConfirmModal = false
                                }
                            }
                        
                        // Liquid Glass Alert Window
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.red)
                                .shadow(color: .red.opacity(0.4), radius: 8)
                            
                            Text("警告：确认清空账本")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                            
                            Text("此操作将安全抹除 SwiftData 数据库中存储的全部记账流水，且该操作无法撤销。")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            HStack(spacing: 16) {
                                Button("取消") {
                                    withAnimation(.easeOut(duration: 0.25)) {
                                        showResetConfirmModal = false
                                    }
                                }
                                .buttonStyle(LiquidGlassButtonStyle())
                                .frame(maxWidth: .infinity)
                                
                                Button("确认清空") {
                                    clearLedger()
                                    withAnimation(.easeOut(duration: 0.25)) {
                                        showResetConfirmModal = false
                                    }
                                }
                                .buttonStyle(LiquidGlassButtonStyle())
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.red)
                            }
                            .padding(.top, 10)
                        }
                        .padding(24)
                        .liquidGlass(cornerRadius: 24, shadowRadius: 20, borderOpacity: 0.35)
                        .chromaticEdgeGlow(cornerRadius: 24, lineWidth: 1.2, opacity: 0.25)
                        .padding(.horizontal, 36)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.88)))
                }
            }
            .navigationTitle("系统设置")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
    
    private func clearLedger() {
        for tx in transactions {
            modelContext.delete(tx)
        }
        try? modelContext.save()
    }
}

// MARK: - Reusable settings row widget
struct SettingsRow<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let content: Content
    
    init(icon: String, iconColor: Color, title: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 14, weight: .bold))
            }
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 52)
    }
}

// MARK: - Reusable nested row widget
struct SettingsNestedRow<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .padding(.leading, 46)
            
            Spacer()
            
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(height: 46)
    }
}

// MARK: - Hand-written 0.5px white glow partition divider
struct CustomDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(height: 0.5)
            .padding(.horizontal, 16)
    }
}

// MARK: - Premium custom liquid toggle
struct LiquidToggle: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.68)) {
                isOn.toggle()
            }
        }) {
            Capsule()
                .fill(isOn ? Color.cyan.opacity(0.25) : Color.white.opacity(0.06))
                .frame(width: 48, height: 28)
                .overlay(
                    Capsule()
                        .stroke(isOn ? Color.cyan.opacity(0.6) : Color.white.opacity(0.12), lineWidth: 1.0)
                )
                .overlay(
                    Circle()
                        .fill(isOn ? Color.cyan : Color.white.opacity(0.6))
                        .padding(3)
                        .offset(x: isOn ? 10 : -10)
                        .shadow(color: isOn ? Color.cyan.opacity(0.4) : .clear, radius: 4)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Premium checkmark button
struct SettingsCheckmark: View {
    let isChecked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isChecked ? Color.cyan.opacity(0.18) : Color.white.opacity(0.04))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(isChecked ? Color.cyan : Color.white.opacity(0.15), lineWidth: 1.2)
                    )
                
                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.cyan)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
