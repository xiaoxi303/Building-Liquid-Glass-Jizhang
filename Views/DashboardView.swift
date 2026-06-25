import SwiftUI
import SwiftData

/// Main dashboard with decompression glow balance card, list of bills, and breathing glow action button.
public struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query(sort: \Category.name) private var categories: [Category]
    
    @State private var showAddTransactionSheet = false
    @State private var glowOffset: CGSize = .zero // Track drag displacement for decompression aurora glow flow
    @State private var isBreathing = false // Track breathing ring animation
    
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
                        // 1. Thick Glass Balance Panel with Decompression Aurora Glow Flow
                        ZStack {
                            // Dynamic Shifting Aurora Gradients
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(Color.white.opacity(0.01))
                                .background(
                                    ZStack {
                                        Color(hex: "#0F172A").opacity(0.4) // Semi-transparent overlay to increase refraction
                                        
                                        // Purple flow center
                                        RadialGradient(
                                            colors: [Color.purple.opacity(0.35), .clear],
                                            center: .init(
                                                x: 0.35 + Double(glowOffset.width) / 1200.0,
                                                y: 0.35 + Double(glowOffset.height) / 1200.0
                                            ),
                                            startRadius: 0,
                                            endRadius: 200
                                        )
                                        
                                        // Cyan flow center
                                        RadialGradient(
                                            colors: [Color.cyan.opacity(0.35), .clear],
                                            center: .init(
                                                x: 0.65 - Double(glowOffset.width) / 1200.0,
                                                y: 0.65 - Double(glowOffset.height) / 1200.0
                                            ),
                                            startRadius: 0,
                                            endRadius: 200
                                        )
                                    }
                                )
                            
                            // Card Info Details (Blends text into the glowing background)
                            VStack(spacing: 18) {
                                Text("本月净资产 (Monthly Net Balance)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white.opacity(0.5))
                                    .tracking(1.2)
                                    .blendMode(.plusLighter) // Blends cleanly into glass
                                
                                let (income, expense, balance) = calculateMonthlyTotals()
                                
                                Text(String(format: "¥%.2f", balance))
                                    .font(.system(size: 42, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: .cyan.opacity(0.3), radius: 10)
                                    .blendMode(.plusLighter)
                                
                                HStack(spacing: 0) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.down.circle.fill")
                                                .foregroundColor(.green)
                                            Text("本月收入")
                                                .font(.caption.bold())
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                        Text(String(format: "¥%.2f", income))
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .blendMode(.plusLighter)
                                    
                                    Rectangle()
                                        .fill(Color.white.opacity(0.18))
                                        .frame(width: 1, height: 32)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.up.circle.fill")
                                                .foregroundColor(.red)
                                            Text("本月支出")
                                                .font(.caption.bold())
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                        Text(String(format: "¥%.2f", expense))
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .blendMode(.plusLighter)
                                }
                            }
                            .padding(24)
                        }
                        // Applies the premium 0.5px edge micro-glow and shadow refraction
                        .liquidGlass(cornerRadius: 28, shadowRadius: 24, borderOpacity: 0.3)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .scaleEffect(1.0 - (abs(glowOffset.width) + abs(glowOffset.height)) / 8000.0)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    withAnimation(.interactiveSpring()) {
                                        glowOffset = value.translation
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                                        glowOffset = .zero
                                    }
                                }
                        )
                        
                        // 2. Transactions List Section (Thin glass overlapping slices)
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
                                // Laying out list items with slight overlapping/thin glass feel
                                LazyVStack(spacing: -8) { // Slight negative spacing to overlap glass slices
                                    ForEach(transactions) { transaction in
                                        HStack(spacing: 16) {
                                            let catColor = Color(hex: transaction.category?.hexColor ?? "#8E8E93")
                                            ZStack {
                                                Circle()
                                                    .fill(catColor.opacity(0.12))
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
                                        // Very thin glass slice styling
                                        .liquidGlass(cornerRadius: 16, shadowRadius: 12, borderOpacity: 0.18)
                                        .padding(.horizontal)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                modelContext.delete(transaction)
                                            } label: {
                                                Label("删除账单", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                                .padding(.bottom, 120)
                            }
                        }
                    }
                }
                
                // 3. Upgraded FAB with Breathing Glow Ring
                Button(action: {
                    showAddTransactionSheet = true
                }) {
                    ZStack {
                        Circle()
                            .stroke(Color.cyan.opacity(0.45), lineWidth: 1.5)
                            .frame(width: 76, height: 76)
                            .scaleEffect(isBreathing ? 1.28 : 0.95)
                            .opacity(isBreathing ? 0.0 : 0.9)
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.cyan.opacity(0.85), Color.blue.opacity(0.95)],
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
                .padding(.bottom, 110)
                .buttonStyle(ShrinkButtonStyle())
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
                        isBreathing = true
                    }
                }
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
