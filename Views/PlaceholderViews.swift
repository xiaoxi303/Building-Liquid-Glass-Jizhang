import SwiftUI
import SwiftData

// MARK: - Analytics View
public struct AnalyticsView: View {
    @Query private var transactions: [Transaction]
    @Query private var categories: [Category]
    
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
                    VStack(alignment: .leading, spacing: 24) {
                        Text("本月支出结构占比")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.top, 16)
                        
                        let breakdown = calculateBreakdown()
                        
                        if breakdown.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "chart.pie.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.white.opacity(0.3))
                                Text("没有足够的支出数据，请先添加账单")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                            .liquidGlass(cornerRadius: 24, shadowRadius: 12, borderOpacity: 0.15)
                            .padding(.horizontal)
                        } else {
                            // Stacked Proportional Bar (Visual Horizontal Chart)
                            VStack(spacing: 12) {
                                // Stacked bar container
                                HStack(spacing: 2) {
                                    ForEach(breakdown, id: \.category.id) { item in
                                        let catColor = Color(hex: item.category.hexColor)
                                        Rectangle()
                                            .fill(catColor)
                                            .frame(height: 18)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .scaleEffect(x: CGFloat(item.percentage), y: 1.0, anchor: .leading)
                                    }
                                }
                                .clipShape(Capsule())
                                .padding(4)
                                .background(Color.white.opacity(0.08))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                                
                                // Legend grid
                                HStack(spacing: 12) {
                                    ForEach(breakdown.prefix(3), id: \.category.id) { item in
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(Color(hex: item.category.hexColor))
                                                .frame(width: 8, height: 8)
                                            Text(item.category.name)
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.6))
                                            Text(String(format: "%.0f%%", item.percentage * 100))
                                                .font(.caption.bold())
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            }
                            .padding(20)
                            .liquidGlass(cornerRadius: 24, shadowRadius: 12, borderOpacity: 0.2)
                            .padding(.horizontal)
                            
                            // Detailed category progression cards
                            VStack(spacing: 14) {
                                ForEach(breakdown, id: \.category.id) { item in
                                    VStack(spacing: 10) {
                                        HStack {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(hex: item.category.hexColor).opacity(0.15))
                                                    .frame(width: 36, height: 36)
                                                Image(systemName: item.category.icon)
                                                    .foregroundColor(Color(hex: item.category.hexColor))
                                                    .font(.system(size: 16, weight: .bold))
                                            }
                                            
                                            Text(item.category.name)
                                                .foregroundColor(.white)
                                                .font(.body.bold())
                                            
                                            Spacer()
                                            
                                            Text(String(format: "¥%.2f (%.1f%%)", item.totalAmount, item.percentage * 100))
                                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                                .foregroundColor(.white.opacity(0.85))
                                        }
                                        
                                        // Refraction glow bar
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                Capsule()
                                                    .fill(Color.white.opacity(0.08))
                                                    .frame(height: 8)
                                                
                                                Capsule()
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [Color(hex: item.category.hexColor), Color(hex: item.category.hexColor).opacity(0.6)],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                                    .frame(width: geo.size.width * CGFloat(item.percentage), height: 8)
                                                    .shadow(color: Color(hex: item.category.hexColor).opacity(0.3), radius: 4)
                                            }
                                        }
                                        .frame(height: 8)
                                    }
                                    .padding(16)
                                    .liquidGlass(cornerRadius: 20, shadowRadius: 10, borderOpacity: 0.25)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 120)
                        }
                    }
                }
            }
            .navigationTitle("统计分析")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
    
    struct CategoryBreakdownItem {
        let category: Category
        let totalAmount: Double
        let percentage: Double
    }
    
    private func calculateBreakdown() -> [CategoryBreakdownItem] {
        let expenses = transactions.filter { $0.type == .expense }
        let totalExpense = expenses.reduce(0.0) { $0 + $1.amount }
        guard totalExpense > 0 else { return [] }
        
        var categoryMap: [UUID: Double] = [:]
        for tx in expenses {
            if let cat = tx.category {
                categoryMap[cat.id, default: 0.0] += tx.amount
            }
        }
        
        return categoryMap.compactMap { (catId, amount) -> CategoryBreakdownItem? in
            guard let cat = categories.first(where: { $0.id == catId }) else { return nil }
            return CategoryBreakdownItem(
                category: cat,
                totalAmount: amount,
                percentage: amount / totalExpense
            )
        }.sorted { $0.totalAmount > $1.totalAmount }
    }
}

// MARK: - Settings View
public struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @Query private var transactions: [Transaction]
    
    // Interactive states for premium options
    @State private var widgetsEnabled = true
    @State private var selectedThemeColor = Color.cyan
    @State private var isSyncing = false
    @State private var showResetAlert = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
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
                            
                            Text("Version 1.0.0 (Liquid Glass Native)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.40))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .liquidGlass(cornerRadius: 24, shadowRadius: 15, borderOpacity: 0.3)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // 1. Personalization & Themes
                        VStack(alignment: .leading, spacing: 12) {
                            Text("个性化与组件")
                                .font(.subheadline.bold())
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                // Row 1: Widget toggle
                                SettingsRow(icon: "square.grid.3x3.fill", iconColor: .cyan, title: "自定义桌面小组件") {
                                    Toggle("", isOn: $widgetsEnabled)
                                        .labelsHidden()
                                        .tint(.cyan)
                                }
                                
                                // Row 2: Fluid Theme selector
                                SettingsRow(icon: "paintpalette.fill", iconColor: .purple, title: "液态主题皮肤") {
                                    HStack(spacing: 10) {
                                        ForEach([Color.cyan, Color.purple, Color.orange, Color.green], id: \.self) { color in
                                            Circle()
                                                .fill(color)
                                                .frame(width: 18, height: 18)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: selectedThemeColor == color ? 1.5 : 0)
                                                )
                                                .onTapGesture {
                                                    withAnimation(.spring()) {
                                                        selectedThemeColor = color
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // 2. Data Management (Backup, iCloud sync, Clear database)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("数据管理与备份")
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
                                    .disabled(isSyncing)
                                }
                                
                                // Row 2: Statistics info
                                SettingsRow(icon: "tray.2.fill", iconColor: .orange, title: "当前存储账单条数") {
                                    Text("\(transactions.count) 条")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                // Row 3: Clear all
                                SettingsRow(icon: "trash.fill", iconColor: .red, title: "重置并清空所有账单") {
                                    Button(action: { showResetAlert = true }) {
                                        Text("清空数据")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("系统设置")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .alert("确认清空所有数据？", isPresented: $showResetAlert) {
                Button("取消", role: .cancel) {}
                Button("确认清空", role: .destructive, action: clearDatabase)
            } message: {
                Text("此操作将永久删除数据库中记录的所有账单明细，且无法撤销。")
            }
        }
    }
    
    private func startSync() {
        isSyncing = true
        // Simulate iCloud Sync delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isSyncing = false
        }
    }
    
    private func clearDatabase() {
        for tx in transactions {
            modelContext.delete(tx)
        }
        try? modelContext.save()
    }
}

// MARK: - Reusable Settings Cell Row (Liquid Glass)
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
        HStack {
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
        .padding(14)
        .liquidGlass(cornerRadius: 16, shadowRadius: 8, borderOpacity: 0.15)
    }
}
