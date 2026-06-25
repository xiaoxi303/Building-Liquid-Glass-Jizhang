import SwiftUI
import SwiftData

/// Main entry dashboard displaying assets, list of transactions, and a floating glass action button.
public struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query(sort: \Category.name) private var categories: [Category]
    
    @State private var showAddTransactionSheet = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // Background deep mesh gradient matching Liquid Glass aesthetics
                LinearGradient(
                    colors: [Color(hex: "#0F172A"), Color(hex: "#1E293B"), Color(hex: "#020617")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 1. Air-like Premium Glass Balance Panel (Displays stats for current calendar month)
                        VStack(spacing: 18) {
                            Text("本月净资产 (Monthly Net Balance)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                                .tracking(1)
                            
                            let (income, expense, balance) = calculateMonthlyTotals()
                            
                            Text(String(format: "¥%.2f", balance))
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .white.opacity(0.15), radius: 8)
                            
                            HStack(spacing: 0) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.down.circle.fill")
                                            .foregroundColor(.green)
                                        Text("本月收入")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    Text(String(format: "¥%.2f", income))
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 1, height: 32)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .foregroundColor(.red)
                                        Text("本月支出")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    Text(String(format: "¥%.2f", expense))
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(24)
                        .liquidGlass(cornerRadius: 28, shadowRadius: 20, borderOpacity: 0.3)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // 2. Transactions List Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("最近账单 (Transactions)")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            if transactions.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "tray.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.3))
                                    Text("暂无账单数据，请点击右下角按钮记一笔")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                                .liquidGlass(cornerRadius: 20, shadowRadius: 10, borderOpacity: 0.15)
                                .padding(.horizontal)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(transactions) { transaction in
                                        HStack(spacing: 16) {
                                            let catColor = Color(hex: transaction.category?.hexColor ?? "#8E8E93")
                                            ZStack {
                                                Circle()
                                                    .fill(catColor.opacity(0.15))
                                                    .frame(width: 44, height: 44)
                                                Image(systemName: transaction.category?.icon ?? "square.grid.2x2.fill")
                                                    .foregroundColor(catColor)
                                                    .font(.title3)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(transaction.category?.name ?? "未分类")
                                                    .font(.body.bold())
                                                    .foregroundColor(.white)
                                                if !transaction.note.isEmpty {
                                                    Text(transaction.note)
                                                        .font(.caption)
                                                        .foregroundColor(.white.opacity(0.6))
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text(transaction.type == .income ? "+\(String(format: "%.2f", transaction.amount))" : "-\(String(format: "%.2f", transaction.amount))")
                                                    .font(.body.bold())
                                                    .foregroundColor(transaction.type == .income ? .green : .red)
                                                
                                                Text(transaction.date.formatted(date: .omitted, time: .shortened))
                                                    .font(.caption2)
                                                    .foregroundColor(.white.opacity(0.4))
                                            }
                                        }
                                        .padding()
                                        .liquidGlass(cornerRadius: 16, shadowRadius: 8, borderOpacity: 0.2)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                modelContext.delete(transaction)
                                            } label: {
                                                Label("删除账单", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 120) // Padding so bottom tabbar doesn't clip lists
                            }
                        }
                    }
                }
                
                // 3. Floating Action Button (FAB)
                Button(action: {
                    showAddTransactionSheet = true
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.cyan.opacity(0.8), Color.blue.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.cyan.opacity(0.4), radius: 10, x: 0, y: 4)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 24)
                .padding(.bottom, 110) // Placed right above the bottom tab controller
                .buttonStyle(ShrinkButtonStyle())
            }
            .navigationTitle("账目明细")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddTransactionSheet) {
                AddTransactionView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func calculateMonthlyTotals() -> (Double, Double, Double) {
        let calendar = Calendar.current
        let now = Date()
        let currentComponents = calendar.dateComponents([.year, .month], from: now)
        
        var income = 0.0
        var expense = 0.0
        
        for tx in transactions {
            let txComponents = calendar.dateComponents([.year, .month], from: tx.date)
            if txComponents.year == currentComponents.year && txComponents.month == currentComponents.month {
                if tx.type == .income {
                    income += tx.amount
                } else {
                    expense += tx.amount
                }
            }
        }
        return (income, expense, income - expense)
    }
}

/// Button shrink animation style for physical pop feeling on tap
public struct ShrinkButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
