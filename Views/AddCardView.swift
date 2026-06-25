import SwiftUI
import SwiftData

/// AddCardView sheet allowing users to add custom credit cards to the wallet.
/// Features a live-updating glass card preview that switches skins and logos dynamically
/// on user text entry (Visa, Mastercard, Amex BIN code checking).
public struct AddCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var holderName = ""
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Dark mesh backdrop gradient consistent with App dark mode
            LinearGradient(
                colors: [Color(hex: "#0F172A"), Color(hex: "#1E293B")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Drag Indicator Handle
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                
                Text("添加信用卡/借记卡")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // 1. Live Card Preview (Reflects input in real-time)
                CardPreview(
                    holderName: holderName.isEmpty ? "CARDHOLDER NAME" : holderName,
                    cardNumber: cardNumber,
                    expiryDate: expiryDate.isEmpty ? "MM/YY" : expiryDate
                )
                .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
                .padding(.top, 8)
                
                // 2. Card detail form (frosted glass rows)
                ScrollView {
                    VStack(spacing: 20) {
                        // Cardholder Name Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("持卡人姓名 (Cardholder Name)")
                                .font(.caption.bold())
                                .foregroundColor(.white.opacity(0.6))
                            
                            TextField("例如: ZHONG YONG", text: $holderName)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.04))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 1.0)
                                )
                                .autocorrectionDisabled()
                        }
                        
                        // Card Number Input (Auto formats spaces)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("卡号 (Card Number)")
                                .font(.caption.bold())
                                .foregroundColor(.white.opacity(0.6))
                            
                            TextField("0000 0000 0000 0000", text: $cardNumber)
                                .foregroundColor(.white)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.white.opacity(0.04))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 1.0)
                                )
                                .onChange(of: cardNumber) { _, newValue in
                                    formatCardNumberInput(newValue)
                                }
                        }
                        
                        // Expiration Date Input (MM/YY)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("有效期 (Expiry Date)")
                                .font(.caption.bold())
                                .foregroundColor(.white.opacity(0.6))
                            
                            TextField("MM/YY", text: $expiryDate)
                                .foregroundColor(.white)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.white.opacity(0.04))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 1.0)
                                )
                                .onChange(of: expiryDate) { _, newValue in
                                    formatExpiryDateInput(newValue)
                                }
                        }
                        
                        // Action Buttons
                        Button(action: saveCard) {
                            Text("保存并激活卡片")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(LiquidGlassButtonStyle())
                        .disabled(isFormInvalid)
                        .opacity(isFormInvalid ? 0.45 : 1.0)
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .colorScheme(.dark)
    }
    
    // Checks form inputs validation status
    private var isFormInvalid: Bool {
        let cleanNumber = cardNumber.filter { $0.isNumber }
        let cleanExpiry = expiryDate.filter { $0.isNumber }
        return holderName.isEmpty || cleanNumber.count < 12 || cleanExpiry.count < 4
    }
    
    // Formats card number input by placing spacing breaks every 4 characters
    private func formatCardNumberInput(_ value: String) {
        let digits = value.filter { $0.isNumber }
        let limited = String(digits.prefix(16)) // Limit to 16 digits
        
        var result = ""
        for (index, char) in limited.enumerated() {
            if index > 0 && index % 4 == 0 {
                result += " "
            }
            result += String(char)
        }
        cardNumber = result
    }
    
    // Formats expiry date to insert a slash separator
    private func formatExpiryDateInput(_ value: String) {
        let digits = value.filter { $0.isNumber }
        let limited = String(digits.prefix(4))
        
        if limited.count > 2 {
            let month = limited.prefix(2)
            let year = limited.suffix(limited.count - 2)
            expiryDate = "\(month)/\(year)"
        } else {
            expiryDate = limited
        }
    }
    
    // Saves card model to SwiftData database
    private func saveCard() {
        let newCard = Card(
            holderName: holderName,
            cardNumber: cardNumber,
            expiryDate: expiryDate
        )
        modelContext.insert(newCard)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Local Card Live Preview
struct CardPreview: View {
    let holderName: String
    let cardNumber: String
    let expiryDate: String
    
    // Brand detection logic for live preview rendering
    private var inferredCardType: String {
        let digits = cardNumber.filter { $0.isNumber }
        if digits.hasPrefix("4") { return "Visa" }
        if digits.hasPrefix("34") || digits.hasPrefix("37") { return "Amex" }
        for prefix in 51...55 {
            if digits.hasPrefix(String(prefix)) { return "Mastercard" }
        }
        return "Unknown"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card Brand & Wave icon
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(inferredCardType.uppercased())
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .italic()
                        .foregroundColor(.white)
                        .tracking(1)
                    Text("LIVE PREVIEW")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(0.5)
                }
                
                Spacer()
                
                Image(systemName: "wave.3.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
                    .rotationEffect(.degrees(-90))
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            // metallic chip
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 38, height: 28)
                
                VStack(spacing: 5) {
                    Divider().background(Color.black.opacity(0.2))
                    Divider().background(Color.black.opacity(0.2))
                }
                .padding(.vertical, 4)
            }
            .padding(.horizontal, 24)
            .padding(.top, 18)
            
            Spacer()
            
            // Live Card number string formatting
            Text(formatLiveCardNumber(cardNumber))
                .font(.system(size: 20, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.25), radius: 2)
                .padding(.horizontal, 24)
            
            Spacer()
            
            // Expiry & Holder
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CARDHOLDER")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                    Text(holderName.uppercased())
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("EXPIRES")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                    Text(expiryDate)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                // Card brand logos
                Group {
                    if inferredCardType == "Mastercard" {
                        HStack(spacing: -8) {
                            Circle()
                                .fill(Color.red.opacity(0.85))
                                .frame(width: 24, height: 24)
                            Circle()
                                .fill(Color.orange.opacity(0.85))
                                .frame(width: 24, height: 24)
                        }
                        .padding(.leading, 12)
                    } else if inferredCardType == "Visa" {
                        Text("VISA")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .italic()
                            .padding(.leading, 12)
                    } else if inferredCardType == "Amex" {
                        Text("AMEX")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .border(Color.white, width: 1.5)
                            .padding(.leading, 12)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 22)
        }
        .frame(width: 320, height: 200)
        .background(
            ZStack {
                // Live preview gradient switcher
                if inferredCardType == "Visa" {
                    LinearGradient(
                        colors: [Color(hex: "#1E3A8A"), Color(hex: "#3B82F6"), Color(hex: "#0F172A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else if inferredCardType == "Mastercard" {
                    LinearGradient(
                        colors: [Color(hex: "#111827"), Color(hex: "#1F2937"), Color(hex: "#78350F")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else if inferredCardType == "Amex" {
                    LinearGradient(
                        colors: [Color(hex: "#064E3B"), Color(hex: "#047857"), Color(hex: "#065F46")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    LinearGradient(
                        colors: [Color(hex: "#4B5563"), Color(hex: "#9CA3AF"), Color(hex: "#374151")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                
                Color.clear
                    .background(.ultraThinMaterial)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.35), .white.opacity(0.1), .black.opacity(0.2), .white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        )
    }
    
    // formats the typed text live into credit card spaced blocks
    private func formatLiveCardNumber(_ value: String) -> String {
        let digits = value.filter { $0.isNumber }
        var result = ""
        for i in 0..<16 {
            if i > 0 && i % 4 == 0 {
                result += "  "
            }
            if i < digits.count {
                let index = digits.index(digits.startIndex, offsetBy: i)
                result += String(digits[index])
            } else {
                result += "•"
            }
        }
        return result
    }
}
