import SwiftUI
import SwiftData

/// Displays a premium glassmorphic analysis report with hand-written liquid color progress indicators.
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
                            VStack(spacing: 12) {
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
                                        
                                        // Refraction glow progress bar
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
                                    .liquidGlass(cornerRadius: 20, shadowRadius: 10, borderOpacity: 0.25)
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
