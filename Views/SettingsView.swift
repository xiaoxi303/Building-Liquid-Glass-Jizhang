import SwiftUI
import SwiftData

/// Displays the premium Apple-style control center settings page.
/// Configures global glass blur, chromatic edges, default categories sheet, and custom modal alert boxes.
public struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @Query private var transactions: [Transaction]
    
    // Synced AppStorage settings for global visual adaptations
    @AppStorage("glassBlurRadius") private var glassBlurRadius: Double = 16.0
    @AppStorage("chromaticGlowEnabled") private var chromaticGlowEnabled: Bool = true
    
    // Interactive states
    @State private var isSyncing = false
    @State private var showCategoriesSheet = false
    @State private var showCustomResetModal = false // Custom liquid warning alert overlay trigger
    
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
                        // Brand Profile header
                        VStack(spacing: 14) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 48))
                                .foregroundColor(.cyan)
                                .shadow(color: .cyan.opacity(0.6), radius: 12)
                                .padding(.top, 8)
                            
                            Text("苹果记账 (jizhang)")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            
                            Text("Version 1.0.0 (WWDC26 Spec)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.40))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .liquidGlass(cornerRadius: 24, shadowRadius: 15, borderOpacity: 0.3)
                        .chromaticEdgeGlow(cornerRadius: 24, lineWidth: 1.0, opacity: 0.20)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // 1. Visual customization controls (Blur & Chromatic aberration)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("视觉自定义调节")
                                .font(.subheadline.bold())
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                // Row 1: Blur radius slider
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color.purple.opacity(0.15))
                                                .frame(width: 32, height: 32)
                                            Image(systemName: "drop.fill")
                                                .foregroundColor(.purple)
                                                .font(.system(size: 14, weight: .bold))
                                        }
                                        
                                        Text("液态玻璃模糊度")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Text(String(format: "%.0f px", glassBlurRadius))
                                            .font(.subheadline.bold())
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    
                                    Slider(value: $glassBlurRadius, in: 0...30, step: 1)
                                        .tint(.cyan)
                                }
                                .padding(14)
                                .liquidGlass(cornerRadius: 16, shadowRadius: 8, borderOpacity: 0.15)
                                .chromaticEdgeGlow(cornerRadius: 16, lineWidth: 0.8, opacity: 0.12)
                                .padding(.horizontal)
                                
                                // Row 2: Chromatic glow toggle
                                SettingsRow(icon: "rainbow", iconColor: .cyan, title: "边缘彩虹色散微光") {
                                    Toggle("", isOn: $chromaticGlowEnabled)
                                        .labelsHidden()
                                        .tint(.cyan)
                                }
                            }
                        }
                        
                        // 2. Data management (sync, categories list, custom clear warning modal)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("数据管理与维护")
                                .font(.subheadline.bold())
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                // Row 1: iCloud sync button
                                SettingsRow(icon: "icloud.and.arrow.up.fill", iconColor: .blue, title: "iCloud 备份与同步") {
                                    Button(action: startSync) {
                                        HStack(spacing: 6) {
                                            if isSyncing {
                                                ProgressView()
                                                    .tint(.cyan)
                                                    .scaleEffect(0.8)
                                            }
                                            Text(isSyncing ? "同步中..." : "立即同步")
                                                .font(.subheadline.bold())
                                                .foregroundColor(.cyan)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .disabled(isSyncing)
                                }
                                
                                // Row 2: Default categories list launcher
                                SettingsRow(icon: "list.bullet.indent", iconColor: .orange, title: "查看系统默认分类") {
                                    Button(action: { showCategoriesSheet = true }) {
                                        Text("查看分类")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.cyan)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                // Row 3: Clear ledger button (triggers custom modal alert)
                                SettingsRow(icon: "trash.fill", iconColor: .red, title: "一键清空账本") {
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                                            showCustomResetModal = true
                                        }
                                    }) {
                                        Text("立即清空")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 120)
                }
                
                // 3. Custom Liquid Glass Warning Alert Overlay
                if showCustomResetModal {
                    ZStack {
                        // Blurred dark backdrop
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .transition(.opacity)
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.25)) {
                                    showCustomResetModal = false
                                }
                            }
                        
                        // Custom glass popup modal box
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.red)
                                .shadow(color: .red.opacity(0.4), radius: 8)
                            
                            Text("警告：清空账本数据")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                            
                            Text("您确定要清空所有的历史记账账单吗？此操作将彻底删除数据，且无法撤销。")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            HStack(spacing: 16) {
                                Button("取消") {
                                    withAnimation(.easeOut(duration: 0.25)) {
                                        showCustomResetModal = false
                                    }
                                }
                                .buttonStyle(LiquidGlassButtonStyle()) // Styled with interactive touch specularity
                                .frame(maxWidth: .infinity)
                                
                                Button("确认清空") {
                                    clearLedgerData()
                                    withAnimation(.easeOut(duration: 0.25)) {
                                        showCustomResetModal = false
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
            .sheet(isPresented: $showCategoriesSheet) {
                CategoriesListView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func startSync() {
        isSyncing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isSyncing = false
        }
    }
    
    private func clearLedgerData() {
        for tx in transactions {
            modelContext.delete(tx)
        }
        try? modelContext.save()
    }
}
