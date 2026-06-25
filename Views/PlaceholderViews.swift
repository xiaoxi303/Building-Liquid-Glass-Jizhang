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
                LinearGradient(
                    colors: [Color(hex: "#0F172A"), Color(hex: "#1E293B"), Color(hex: "#020617")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("支出结构比例")
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
                                Text("没有足够的支出数据，请先模拟记账")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                            .liquidGlass(cornerRadius: 24, shadowRadius: 12, borderOpacity: 0.15)
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(breakdown, id: \.category.id) { item in
                                    VStack(spacing: 10) {
                                        HStack {
                                            Image(systemName: item.category.icon)
                                                .foregroundColor(Color(hex: item.category.hexColor))
                                                .frame(width: 24)
                                            Text(item.category.name)
                                                .foregroundColor(.white)
                                                .font(.body.bold())
                                            Spacer()
                                            Text(String(format: "¥%.2f (%.1f%%)", item.totalAmount, item.percentage * 100))
                                                .font(.subheadline.monospacedDigit())
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        
                                        // Custom Glass Progress Bar
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                Capsule()
                                                    .fill(Color.white.opacity(0.08))
                                                    .frame(height: 8)
                                                Capsule()
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [Color(hex: item.category.hexColor), Color(hex: item.category.hexColor).opacity(0.7)],
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
                                    .padding()
                                    .liquidGlass(cornerRadius: 18, shadowRadius: 8, borderOpacity: 0.2)
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
                            
                            Text("Version 1.0.0 (Liquid Glass Native)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.40))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .liquidGlass(cornerRadius: 24, shadowRadius: 15, borderOpacity: 0.3)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // Database & Storage Settings Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("系统状态")
                                .font(.subheadline.bold())
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    Text("记录账单总数")
                                    Spacer()
                                    Text("\(transactions.count) 条")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding()
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                HStack {
                                    Text("所属分类数量")
                                    Spacer()
                                    Text("\(categories.count) 个")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding()
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                Button(action: clearDatabase) {
                                    HStack {
                                        Text("清空测试账单数据")
                                            .foregroundColor(.red.opacity(0.9))
                                        Spacer()
                                        Image(systemName: "trash.fill")
                                            .foregroundColor(.red.opacity(0.7))
                                    }
                                }
                                .padding()
                            }
                            .foregroundColor(.white)
                            .liquidGlass(cornerRadius: 20, shadowRadius: 10, borderOpacity: 0.2)
                            .padding(.horizontal)
                        }
                        
                        // Tech Spec Info
                        VStack(alignment: .leading, spacing: 12) {
                            Text("技术架构")
                                .font(.subheadline.bold())
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    Text("运行环境")
                                    Spacer()
                                    Text("iOS 17+ / Xcode 26")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding()
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                HStack {
                                    Text("存储引擎")
                                    Spacer()
                                    Text("SwiftData Framework")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding()
                            }
                            .foregroundColor(.white)
                            .liquidGlass(cornerRadius: 20, shadowRadius: 10, borderOpacity: 0.2)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("系统设置")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
    
    private func clearDatabase() {
        for tx in transactions {
            modelContext.delete(tx)
        }
        try? modelContext.save()
    }
}
