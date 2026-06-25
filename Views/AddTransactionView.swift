import SwiftUI
import SwiftData

/// Modal View sheet allowing the user to record an income or expense transaction.
/// Features a liquid material card design, category bubbles with water-ripple feedback, and a liquid glass button.
public struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Category.name) private var categories: [Category]
    
    @State private var amountString = ""
    @State private var selectedCategory: Category?
    @State private var transactionType: TransactionType = .expense
    @State private var date = Date()
    @State private var note = ""
    
    // Ripple trigger states for category circles
    @State private var rippleCategoryId: UUID? = nil
    @State private var rippleScale: CGFloat = 1.0
    @State private var rippleOpacity: Double = 0.0
    
    @Namespace private var segmentNamespace
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Dark unified background to prevent default white sheet styling leakage
            LinearGradient(
                colors: [Color(hex: "#0F172A"), Color(hex: "#1E293B")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header bar handle marker
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                
                Text("记一笔 (New Transaction)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ScrollView {
                    VStack(spacing: 22) {
                        // 1. Transaction Type Segment Control (Expense / Income)
                        HStack(spacing: 0) {
                            ForEach(TransactionType.allCases, id: \.self) { type in
                                Button(action: {
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                                        transactionType = type
                                        adjustCategorySelection(for: type)
                                    }
                                }) {
                                    Text(type == .expense ? "支出" : "收入")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(transactionType == type ? .white : .white.opacity(0.4))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            ZStack {
                                                if transactionType == type {
                                                    // Sliding capsule indicator
                                                    Capsule()
                                                        .fill(type == .expense ? Color.red.opacity(0.25) : Color.green.opacity(0.25))
                                                        .matchedGeometryEffect(id: "activeSegment", in: segmentNamespace)
                                                        .overlay(
                                                            Capsule()
                                                                .stroke(type == .expense ? Color.red.opacity(0.4) : Color.green.opacity(0.4), lineWidth: 1)
                                                        )
                                                }
                                            }
                                        )
                                }
                            }
                        }
                        .padding(4)
                        .background(Color.white.opacity(0.06))
                        .clipShape(Capsule())
                        .padding(.horizontal)
                        
                        // 2. Amount Numeric Entry Card (Liquid Glass)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("记账金额")
                                .font(.caption.bold())
                                .foregroundColor(.white.opacity(0.5))
                            
                            HStack(spacing: 8) {
                                Text("¥")
                                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                TextField("0.00", text: $amountString)
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .keyboardType(.decimalPad)
                                    .tint(.cyan)
                            }
                        }
                        .padding(18)
                        .liquidGlass(cornerRadius: 20, shadowRadius: 10, borderOpacity: 0.2)
                        .padding(.horizontal)
                        
                        // 3. Category Horizontal Slider Selector with Water-Ripple expansion Feedback
                        VStack(alignment: .leading, spacing: 12) {
                            Text("选择分类")
                                .font(.caption.bold())
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    let filteredCats = categories.filter { cat in
                                        if transactionType == .income {
                                            return cat.name == "收入"
                                        } else {
                                            return cat.name != "收入"
                                        }
                                    }
                                    
                                    ForEach(filteredCats) { category in
                                        let isSelected = selectedCategory?.id == category.id
                                        let catColor = Color(hex: category.hexColor)
                                        
                                        Button(action: {
                                            // Trigger Ripple Expansion
                                            rippleCategoryId = category.id
                                            rippleScale = 1.0
                                            rippleOpacity = 0.8
                                            
                                            withAnimation(.easeOut(duration: 0.45)) {
                                                rippleScale = 1.45
                                                rippleOpacity = 0.0
                                            }
                                            
                                            withAnimation(.spring(response: 0.25, dampingFraction: 0.70)) {
                                                selectedCategory = category
                                            }
                                        }) {
                                            VStack(spacing: 8) {
                                                ZStack {
                                                    // Water-Ripple Effect Ring
                                                    if rippleCategoryId == category.id {
                                                        Circle()
                                                            .stroke(catColor.opacity(rippleOpacity), lineWidth: 2.5)
                                                            .frame(width: 58, height: 58)
                                                            .scaleEffect(rippleScale)
                                                    }
                                                    
                                                    Circle()
                                                        .fill(isSelected ? catColor.opacity(0.2) : Color.white.opacity(0.04))
                                                        .frame(width: 58, height: 58)
                                                        .shadow(color: isSelected ? catColor.opacity(0.5) : .clear, radius: 10)
                                                    
                                                    Image(systemName: category.icon)
                                                        .font(.title3)
                                                        .foregroundColor(isSelected ? catColor : .white.opacity(0.5))
                                                    
                                                    // Breath glow indicator ring
                                                    if isSelected {
                                                        Circle()
                                                            .stroke(
                                                                LinearGradient(
                                                                    colors: [catColor, catColor.opacity(0.2)],
                                                                    startPoint: .topLeading,
                                                                    endPoint: .bottomTrailing
                                                                ),
                                                                lineWidth: 2
                                                            )
                                                            .frame(width: 58, height: 58)
                                                    }
                                                }
                                                
                                                Text(category.name)
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 10) // Give space for ripple scaling
                            }
                        }
                        
                        // 4. Time and Notes Settings (Liquid Glass Card)
                        VStack(spacing: 16) {
                            DatePicker(
                                selection: $date,
                                displayedComponents: [.date, .hourAndMinute]
                            ) {
                                HStack(spacing: 10) {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.cyan)
                                    Text("交易时间")
                                        .font(.body.bold())
                                        .foregroundColor(.white)
                                }
                            }
                            .colorScheme(.dark)
                            
                            Divider().background(Color.white.opacity(0.12))
                            
                            HStack {
                                Image(systemName: "pencil.line")
                                    .foregroundColor(.cyan)
                                    .frame(width: 24)
                                
                                Text("备注说明")
                                    .font(.body.bold())
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                TextField("添加描述...", text: $note)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.white)
                                    .tint(.cyan)
                            }
                        }
                        .padding(18)
                        .liquidGlass(cornerRadius: 20, shadowRadius: 12, borderOpacity: 0.2)
                        .padding(.horizontal)
                        
                        // 5. Upgraded Specular Liquid Glass Save Button
                        Button(action: saveTransaction) {
                            Text("确认保存")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(LiquidGlassButtonStyle()) // Styled with dynamic specular highlight tracker
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .disabled(amountString.isEmpty || Double(amountString) == nil || selectedCategory == nil)
                        .opacity((amountString.isEmpty || Double(amountString) == nil || selectedCategory == nil) ? 0.45 : 1.0)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .colorScheme(.dark)
        .onAppear {
            adjustCategorySelection(for: transactionType)
        }
    }
    
    private func adjustCategorySelection(for type: TransactionType) {
        if type == .income {
            selectedCategory = categories.first { $0.name == "收入" }
        } else {
            selectedCategory = categories.first { $0.name != "收入" }
        }
    }
    
    private func saveTransaction() {
        guard let amount = Double(amountString), let category = selectedCategory else { return }
        
        let newTx = Transaction(
            amount: amount,
            note: note,
            date: date,
            type: transactionType,
            category: category
        )
        
        modelContext.insert(newTx)
        try? modelContext.save()
        
        dismiss()
    }
}
