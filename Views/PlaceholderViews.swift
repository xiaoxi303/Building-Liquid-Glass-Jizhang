import SwiftUI
import SwiftData

// MARK: - Analytics View
public struct AnalyticsView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query(sort: \Category.name) private var categories: [Category]
    
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
                        Text("本月支出比例 (Monthly Breakdown)")
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
                            // Stacked Proportional Bar (Hand-written liquid glass progress segment)
                            VStack(spacing: 14) {
                                // Stacked bar container
                                HStack(spacing: 3) {
                                    ForEach(breakdown, id: \.category.id) { item in
                                        let catColor = Color(hex: item.category.hexColor)
                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [catColor, catColor.opacity(0.85)],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .frame(height: 20)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .scaleEffect(x: CGFloat(item.percentage), y: 1.0, anchor: .leading)
                                    }
                                }
                                .clipShape(Capsule())
                                .padding(4)
                                .background(Color.white.opacity(0.06))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                )
                                
                                // Legend grid details
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
                            .padding(22)
                            .liquidGlass(cornerRadius: 24, shadowRadius: 14, borderOpacity: 0.22)
                            // Apply chromatic aberration border to stats panel card
                            .chromaticEdgeGlow(cornerRadius: 24, lineWidth: 1.0, opacity: 0.20)
                            .padding(.horizontal)
                            
                            // Detailed Category Progression cards
                            VStack(spacing: 14) {
                                ForEach(breakdown, id: \.category.id) { item in
                                    VStack(spacing: 12) {
                                        HStack {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(hex: item.category.hexColor).opacity(0.12))
                                                    .frame(width: 36, height: 36)
                                                Image(systemName: item.category.icon)
                                                    .foregroundColor(Color(hex: item.category.hexColor))
                                                    .font(.system(size: 15, weight: .bold))
                                            }
                                            
                                            Text(item.category.name)
                                                .foregroundColor(.white)
                                                .font(.body.bold())
                                            
                                            Spacer()
                                            
                                            Text(String(format: "¥%.2f (%.1f%%)", item.totalAmount, item.percentage * 100))
                                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                                .foregroundColor(.white.opacity(0.85))
                                        }
                                        
                                        // Refraction glow bar
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                Capsule()
                                                    .fill(Color.white.opacity(0.06))
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
                                                    .shadow(color: Color(hex: item.category.hexColor).opacity(0.35), radius: 4)
                                            }
                                        }
                                        .frame(height: 8)
                                    }
                                    .padding(16)
                                    .liquidGlass(cornerRadius: 20, shadowRadius: 10, borderOpacity: 0.2)
                                    .chromaticEdgeGlow(cornerRadius: 20, lineWidth: 0.8, opacity: 0.15)
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
    
    // Interactive states
    @State private var widgetsEnabled = true
    @State private var selectedThemeColor = Color.cyan
    @State private var isSyncing = false
    @State private var showResetAlert = false
    @State private var showCategoriesSheet = false
    
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
                        // Brand and System Profile Card
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
                        .chromaticEdgeGlow(cornerRadius: 24, lineWidth: 1.0, opacity: 0.2)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // 1. Personalization & Categories
                        VStack(alignment: .leading, spacing: 12) {
                            Text("个性化与小组件")
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
                                
                                // Row 2: Default categories list launcher
                                SettingsRow(icon: "list.bullet.indent", iconColor: .orange, title: "自定义默认分类") {
                                    Button(action: { showCategoriesSheet = true }) {
                                        Text("查看分类")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.cyan)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // 2. Data Management (Sync, Reset)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("数据维护与备份")
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
                                
                                // Row 2: Clear ledger button with alert warning
                                SettingsRow(icon: "trash.fill", iconColor: .red, title: "一键清空账本") {
                                    Button(action: { showResetAlert = true }) {
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
            }
            .navigationTitle("系统设置")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showCategoriesSheet) {
                CategoriesListView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .alert("确认清空所有账单？", isPresented: $showResetAlert) {
                Button("取消", role: .cancel) {}
                Button("确认清空", role: .destructive, action: clearLedgerData)
            } message: {
                Text("此操作将永久抹除数据库中的所有历史记账流水，此步骤无法撤销。")
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
        .chromaticEdgeGlow(cornerRadius: 16, lineWidth: 0.8, opacity: 0.12)
    }
}

// MARK: - Subview: Categories List Sheet View
struct CategoriesListView: View {
    @Query(sort: \Category.name) private var categories: [Category]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#0F172A"), Color(hex: "#1E293B")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                
                Text("系统默认分类")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(categories) { category in
                            HStack(spacing: 16) {
                                let catColor = Color(hex: category.hexColor)
                                ZStack {
                                    Circle()
                                        .fill(catColor.opacity(0.15))
                                        .frame(width: 42, height: 42)
                                    Image(systemName: category.icon)
                                        .foregroundColor(catColor)
                                        .font(.title3)
                                }
                                
                                Text(category.name)
                                    .font(.body.bold())
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding()
                            .liquidGlass(cornerRadius: 16, shadowRadius: 8, borderOpacity: 0.15)
                            .chromaticEdgeGlow(cornerRadius: 16, lineWidth: 0.8, opacity: 0.1)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .colorScheme(.dark)
    }
}
