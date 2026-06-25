import SwiftUI
import SwiftData

/// Active popup dialog options
enum ActivePopup {
    case none
    case monthlyStartDay
    case pangkaReply
    case currency
    case resetConfirm
    case feedbackSuccess
    case aboutApp
}

/// SettingsView fully redesigned to align with premium competitor layouts.
/// Incorporates custom-engineered liquid toggles, dynamic nested push sub-panels, 
/// spring-bouncy checkmarks, and 0.5px micro-glow line partitions.
public struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]
    
    // Group 1: Basic configuration settings stored in AppStorage
    @AppStorage("monthlyStartDay") private var monthlyStartDay: Int = 1
    @AppStorage("pangkaReplyStyle") private var pangkaReplyStyle: String = "逗趣幽默"
    @AppStorage("currencyUnit") private var currencyUnit: String = "人民币"
    @AppStorage("currencyCode") private var currencyCode: String = "CNY"
    @AppStorage("currencySymbol") private var currencySymbol: String = "¥"
    @AppStorage("showRecordImages") private var showRecordImages: Bool = true
    @AppStorage("showLocations") private var showLocations: Bool = true
    @AppStorage("showPromos") private var showPromos: Bool = false
    
    // Group 2: Push services and nested checkmarks
    @AppStorage("isPushEnabled") private var isPushEnabled: Bool = false
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled: Bool = true
    @AppStorage("budgetWarningEnabled") private var budgetWarningEnabled: Bool = true
    @AppStorage("featurePromoEnabled") private var featurePromoEnabled: Bool = false
    @AppStorage("weeklyReviewEnabled") private var weeklyReviewEnabled: Bool = true
    
    // Glass Lab Customizations (Engine parameters)
    @AppStorage("glassBlurRadius") private var glassBlurRadius: Double = 16.0
    @AppStorage("chromaticGlowEnabled") private var chromaticGlowEnabled: Bool = true
    
    // Active popup selector
    @State private var activePopup: ActivePopup = .none
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background deep mesh gradient matching Liquid Glass aesthetics (ignores all safe areas)
                LinearGradient(
                    colors: [Color(hex: "#0F172A"), Color(hex: "#1E293B"), Color(hex: "#020617")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title header
                        HStack {
                            Text("系统设置")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // 1. Group 1: Basic configurations (Liquid Glass Card)
                        VStack(spacing: 0) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                                    activePopup = .monthlyStartDay
                                }
                            }) {
                                SettingsRow(icon: "calendar", iconColor: .cyan, title: "月统计起始日") {
                                    HStack(spacing: 6) {
                                        Text("每月\(monthlyStartDay)日")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.5))
                                        ShimmerChevron()
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            CustomDivider()
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                                    activePopup = .pangkaReply
                                }
                            }) {
                                SettingsRow(icon: "message.fill", iconColor: .purple, title: "胖咔回复设置") {
                                    HStack(spacing: 6) {
                                        Text(pangkaReplyStyle)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.5))
                                        ShimmerChevron()
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            CustomDivider()
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                                    activePopup = .currency
                                }
                            }) {
                                SettingsRow(icon: "dollarsign.circle.fill", iconColor: .green, title: "货币单位") {
                                    HStack(spacing: 6) {
                                        Text("\(currencyUnit) (\(currencyCode))")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.5))
                                        ShimmerChevron()
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
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
                                            dailyReminderEnabled.toggle()
                                        }
                                    }
                                    
                                    CustomDivider()
                                    
                                    SettingsNestedRow(title: "预算超限提醒") {
                                        SettingsCheckmark(isChecked: budgetWarningEnabled) {
                                            budgetWarningEnabled.toggle()
                                        }
                                    }
                                    
                                    CustomDivider()
                                    
                                    SettingsNestedRow(title: "新功能推荐通知") {
                                        SettingsCheckmark(isChecked: featurePromoEnabled) {
                                            featurePromoEnabled.toggle()
                                        }
                                    }
                                    
                                    CustomDivider()
                                    
                                    SettingsNestedRow(title: "每周账单回顾") {
                                        SettingsCheckmark(isChecked: weeklyReviewEnabled) {
                                            weeklyReviewEnabled.toggle()
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
                        
                        // 3. Group 3: Help and About App
                        VStack(spacing: 0) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                                    activePopup = .feedbackSuccess
                                }
                            }) {
                                SettingsRow(icon: "questionmark.circle.fill", iconColor: .teal, title: "帮助与反馈") {
                                    ShimmerChevron()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            CustomDivider()
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                                    activePopup = .aboutApp
                                }
                            }) {
                                SettingsRow(icon: "info.circle.fill", iconColor: .gray, title: "关于App") {
                                    HStack(spacing: 6) {
                                        Text("v1.0.0")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.5))
                                        ShimmerChevron()
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .liquidGlass(cornerRadius: 24, shadowRadius: 16, borderOpacity: 0.25)
                        .chromaticEdgeGlow(cornerRadius: 24, lineWidth: 1.0, opacity: 0.20)
                        .padding(.horizontal)
                        
                        // 4. Group 4: Liquid Glass Lab (Rendering Sandbox controls)
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 8) {
                                Image(systemName: "wand.and.stars")
                                    .foregroundColor(.cyan)
                                Text("液态玻璃实验室")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 14)
                            
                            CustomDivider()
                            
                            SettingsRow(icon: "sparkles", iconColor: .pink, title: "棱镜彩虹色散 (Chromatic)") {
                                LiquidToggle(isOn: $chromaticGlowEnabled)
                            }
                            
                            CustomDivider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("磨砂模糊程度 (Blur Radius)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                    Spacer()
                                    Text(String(format: "%.1f px", glassBlurRadius))
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.cyan)
                                }
                                
                                GlassSlider(value: $glassBlurRadius, range: 5.0...30.0)
                                    .padding(.top, 4)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                        .liquidGlass(cornerRadius: 24, shadowRadius: 16, borderOpacity: 0.25)
                        .chromaticEdgeGlow(cornerRadius: 24, lineWidth: 1.0, opacity: 0.20)
                        .padding(.horizontal)
                        
                        // 5. Group 5: Danger Zone
                        VStack(spacing: 0) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                                    activePopup = .resetConfirm
                                }
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: 14, weight: .bold))
                                        .frame(width: 32, height: 32)
                                    
                                    Text("一键清空账本")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                    
                                    Text("清空数据")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.red.opacity(0.8))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .frame(height: 52)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .liquidGlass(cornerRadius: 24, shadowRadius: 16, borderOpacity: 0.25)
                        .chromaticEdgeGlow(cornerRadius: 24, lineWidth: 1.0, opacity: 0.20)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 140)
                }
                
                // 6. Interactive Modal Glass dialog boxes
                if activePopup != .none {
                    Color.black.opacity(0.55)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                activePopup = .none
                            }
                        }
                        .zIndex(10)
                    
                    Group {
                        switch activePopup {
                        case .monthlyStartDay:
                            monthlyStartDayPopup
                        case .pangkaReply:
                            pangkaReplyPopup
                        case .currency:
                            currencyPopup
                        case .resetConfirm:
                            resetConfirmPopup
                        case .feedbackSuccess:
                            feedbackSuccessPopup
                        case .aboutApp:
                            aboutAppPopup
                        case .none:
                            EmptyView()
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .zIndex(11)
                }
            }
            .navigationTitle("")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
    
    // MARK: - Dialog Popups Elements
    
    private var monthlyStartDayPopup: some View {
        VStack(spacing: 20) {
            Text("选择月统计起始日")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("账单统计和分析将从每个月的此日期开始计算。")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Grid of starting days: 1, 5, 10, 15, 20, 25, 28, 30
            let days = [1, 5, 10, 15, 20, 25, 28, 30]
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(days, id: \.self) { day in
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            monthlyStartDay = day
                            activePopup = .none
                        }
                    }) {
                        Text("\(day)日")
                            .font(.subheadline.bold())
                            .foregroundColor(monthlyStartDay == day ? .cyan : .white)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(monthlyStartDay == day ? Color.cyan.opacity(0.2) : Color.white.opacity(0.06))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(monthlyStartDay == day ? Color.cyan : Color.white.opacity(0.12), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
            
            Button("取消") {
                withAnimation(.easeOut(duration: 0.2)) {
                    activePopup = .none
                }
            }
            .buttonStyle(LiquidGlassButtonStyle())
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .padding(24)
        .liquidGlass(cornerRadius: 24, shadowRadius: 20, borderOpacity: 0.35)
        .chromaticEdgeGlow(cornerRadius: 24, lineWidth: 1.2, opacity: 0.25)
        .padding(.horizontal, 36)
    }
    
    private var pangkaReplyPopup: some View {
        VStack(spacing: 20) {
            Text("胖咔回复设置")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("选择智能助手胖咔回答您记账请求时的语气风格：")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                let options = ["逗趣幽默", "温柔鼓励", "理性严厉"]
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            pangkaReplyStyle = option
                            activePopup = .none
                        }
                    }) {
                        HStack {
                            Text(option)
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                            Spacer()
                            if pangkaReplyStyle == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.cyan)
                                    .font(.system(size: 18))
                            } else {
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                    .frame(width: 18, height: 18)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(pangkaReplyStyle == option ? Color.cyan.opacity(0.15) : Color.white.opacity(0.04))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(pangkaReplyStyle == option ? Color.cyan.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            
            Button("取消") {
                withAnimation(.easeOut(duration: 0.2)) {
                    activePopup = .none
                }
            }
            .buttonStyle(LiquidGlassButtonStyle())
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .padding(24)
        .liquidGlass(cornerRadius: 24, shadowRadius: 20, borderOpacity: 0.35)
        .chromaticEdgeGlow(cornerRadius: 24, lineWidth: 1.2, opacity: 0.25)
        .padding(.horizontal, 36)
    }
    
    private var currencyPopup: some View {
        VStack(spacing: 20) {
            Text("选择货币单位")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                let currencies = [
                    ("人民币", "CNY", "¥"),
                    ("美元", "USD", "$"),
                    ("欧元", "EUR", "€"),
                    ("英镑", "GBP", "£"),
                    ("日元", "JPY", "¥")
                ]
                ForEach(currencies, id: \.1) { name, code, symbol in
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            currencyUnit = name
                            currencyCode = code
                            currencySymbol = symbol
                            activePopup = .none
                        }
                    }) {
                        HStack {
                            Text("\(name) (\(code))")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                            Spacer()
                            Text(symbol)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.trailing, 8)
                            
                            if currencyUnit == name {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.cyan)
                                    .font(.system(size: 18))
                            } else {
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                    .frame(width: 18, height: 18)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(currencyUnit == name ? Color.cyan.opacity(0.15) : Color.white.opacity(0.04))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(currencyUnit == name ? Color.cyan.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            
            Button("取消") {
                withAnimation(.easeOut(duration: 0.2)) {
                    activePopup = .none
                }
            }
            .buttonStyle(LiquidGlassButtonStyle())
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .padding(24)
        .liquidGlass(cornerRadius: 24, shadowRadius: 20, borderOpacity: 0.35)
        .chromaticEdgeGlow(cornerRadius: 24, lineWidth: 1.2, opacity: 0.25)
        .padding(.horizontal, 36)
    }
    
    private var resetConfirmPopup: some View {
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
                        activePopup = .none
                    }
                }
                .buttonStyle(LiquidGlassButtonStyle())
                .frame(maxWidth: .infinity)
                
                Button("确认清空") {
                    clearLedger()
                    withAnimation(.easeOut(duration: 0.25)) {
                        activePopup = .none
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
    
    private var feedbackSuccessPopup: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 44))
                .foregroundColor(.cyan)
                .shadow(color: .cyan.opacity(0.4), radius: 8)
            
            Text("反馈提交成功")
                .font(.title3.bold())
                .foregroundColor(.white)
            
            Text("我们已复制系统诊断日志至剪贴板，并将您的宝贵意见加密传输至开发组。我们的客服将在24小时内给您答复。")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("好") {
                withAnimation(.easeOut(duration: 0.25)) {
                    activePopup = .none
                }
            }
            .buttonStyle(LiquidGlassButtonStyle())
            .frame(width: 140)
            .padding(.top, 10)
        }
        .padding(24)
        .liquidGlass(cornerRadius: 24, shadowRadius: 20, borderOpacity: 0.35)
        .chromaticEdgeGlow(cornerRadius: 24, lineWidth: 1.2, opacity: 0.25)
        .padding(.horizontal, 36)
    }
    
    private var aboutAppPopup: some View {
        VStack(spacing: 20) {
            // App Logo Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cyan.opacity(0.15))
                    .frame(width: 64, height: 64)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.cyan.opacity(0.4), lineWidth: 1.5)
                    )
                
                Image(systemName: "banknote.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.cyan)
                    .shadow(color: .cyan.opacity(0.4), radius: 8)
            }
            
            VStack(spacing: 4) {
                Text("苹果极简记账")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                
                Text("Version 1.0.0 (Build 26.2)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Text("基于 Apple iOS 26 设计准则与 Metal Shader 开发。\n融入真液态水滴物理融合引擎与棱镜光学折射边缘，为您呈现极致的毛玻璃视觉美学体验。")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .lineSpacing(4)
            
            Button("关闭") {
                withAnimation(.easeOut(duration: 0.25)) {
                    activePopup = .none
                }
            }
            .buttonStyle(LiquidGlassButtonStyle())
            .frame(width: 120)
            .padding(.top, 10)
        }
        .padding(24)
        .liquidGlass(cornerRadius: 24, shadowRadius: 20, borderOpacity: 0.35)
        .chromaticEdgeGlow(cornerRadius: 24, lineWidth: 1.2, opacity: 0.25)
        .padding(.horizontal, 36)
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
    
    // Water drop ripple effect variables
    @State private var rippleScale: CGFloat = 0.0
    @State private var rippleOpacity: Double = 0.0
    @State private var isPressing = false
    
    var body: some View {
        Button(action: {
            // Trigger spring toggle animation
            withAnimation(.spring(response: 0.32, dampingFraction: 0.62)) {
                isOn.toggle()
            }
            
            // Trigger water-droplet ripple expansion
            rippleScale = 0.3
            rippleOpacity = 0.7
            withAnimation(.easeOut(duration: 0.55)) {
                rippleScale = 2.2
                rippleOpacity = 0.0
            }
        }) {
            ZStack {
                // Background Track
                Capsule()
                    .fill(isOn ? Color.cyan.opacity(0.2) : Color.white.opacity(0.06))
                    .frame(width: 52, height: 30)
                    .overlay(
                        Capsule()
                            .stroke(isOn ? Color.cyan.opacity(0.5) : Color.white.opacity(0.12), lineWidth: 1.0)
                    )
                
                // Water-droplet ripple diffusion (Liquid diffusion effect)
                Circle()
                    .fill(Color.cyan.opacity(0.35))
                    .frame(width: 26, height: 26)
                    .scaleEffect(rippleScale)
                    .opacity(rippleOpacity)
                    .offset(x: isOn ? 11 : -11)
                
                // Slider thumb simulating a melting liquid bead
                Capsule()
                    .fill(isOn ? Color.cyan : Color.white.opacity(0.7))
                    .frame(width: isPressing ? 32 : 22, height: 22)
                    .offset(x: isOn ? (isPressing ? 6 : 11) : (isPressing ? -6 : -11))
                    .shadow(color: isOn ? Color.cyan.opacity(0.4) : .clear, radius: 4)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        isPressing = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        isPressing = false
                    }
                }
        )
    }
}

// MARK: - Premium checkmark button with scale bounce physical transition
struct SettingsCheckmark: View {
    let isChecked: Bool
    let action: () -> Void
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            // Physical bounce scale effect
            scale = 0.8
            withAnimation(.spring(response: 0.22, dampingFraction: 0.45)) {
                scale = 1.15
            }
            // Settle back to 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
            action()
        }) {
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
            .scaleEffect(scale)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Shimmering Chevron Indicator
struct ShimmerChevron: View {
    @State private var shimmerOffset: CGFloat = -15
    
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(.white.opacity(0.35))
            .overlay(
                // Shimmering white mask moving across the arrow
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.8), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 10)
                    .offset(x: shimmerOffset)
                    .mask(
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                    )
                }
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 2.0)
                    .repeatForever(autoreverses: false)
                ) {
                    shimmerOffset = 15
                }
            }
    }
}

// MARK: - Premium Glass Slider Control
struct GlassSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let percent = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
            let thumbOffset = percent * (width - 24)
            
            ZStack(alignment: .leading) {
                // Slider Track
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 8)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                
                // Active Track Progress
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.cyan.opacity(0.8), .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: thumbOffset + 12, height: 8)
                    .shadow(color: .cyan.opacity(0.4), radius: 4)
                
                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(Color.cyan, lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 3)
                    .offset(x: thumbOffset)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                let dragLocation = gesture.location.x
                                let newPercent = max(0, min(1, dragLocation / width))
                                let newValue = range.lowerBound + Double(newPercent) * (range.upperBound - range.lowerBound)
                                value = newValue
                            }
                    )
            }
        }
        .frame(height: 24)
    }
}
