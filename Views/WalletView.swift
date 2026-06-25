import SwiftUI
import SwiftData

/// WalletView implementing a 1:1 Apple Pay visual layout with interactive card stacking,
/// drag gesture card extraction, dynamic surrounding offset displacement,
/// and customized premium card brand skins.
public struct WalletView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Card.cardNumber) private var cards: [Card]
    
    @State private var showAddCardSheet = false
    @State private var expandedCardId: UUID? = nil
    
    // Tracks active dragging translation heights for individual cards
    @State private var dragOffsets: [UUID: CGFloat] = [:]
    
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
                
                VStack(spacing: 0) {
                    // Header Bar with Apple Pay Title and Plus Add Button
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("电子卡包")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            Text("APPLE PAY SPEC")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.cyan)
                                .tracking(2.0)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showAddCardSheet = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.08))
                                    .frame(width: 42, height: 42)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1.0)
                                    )
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(ShrinkButtonStyle())
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                    
                    if cards.isEmpty {
                        // Empty State view
                        VStack(spacing: 16) {
                            Image(systemName: "creditcard.and.123")
                                .font(.system(size: 64))
                                .foregroundColor(.white.opacity(0.2))
                                .padding(.top, 120)
                            Text("暂无卡片，点击右上角添加您的卡片")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                        }
                    } else {
                        // Scrollable card stack package
                        ScrollView {
                            ZStack(alignment: .top) {
                                // Dynamic Card Stack with offsets fanning out
                                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                                    let isExpanded = expandedCardId == card.id
                                    let currentDrag = dragOffsets[card.id] ?? 0
                                    
                                    CardView(card: card)
                                        .zIndex(isExpanded ? 100 : Double(index))
                                        .scaleEffect(isExpanded ? 1.03 : (expandedCardId == nil ? 1.0 : 0.95))
                                        .shadow(color: isExpanded ? cardColor(for: card).opacity(0.35) : .black.opacity(0.2), radius: isExpanded ? 24 : 10)
                                        .offset(y: calculateCardOffset(index: index, cardId: card.id))
                                        .offset(y: currentDrag) // Real-time finger offset tracking
                                        .gesture(
                                            DragGesture(minimumDistance: 10)
                                                .onChanged { value in
                                                    // Allow drag up, limit drag down unless expanded
                                                    let delta = value.translation.height
                                                    if isExpanded {
                                                        dragOffsets[card.id] = delta > 0 ? delta : delta * 0.2
                                                    } else {
                                                        dragOffsets[card.id] = delta < 0 ? delta : delta * 0.2
                                                    }
                                                }
                                                .onEnded { value in
                                                    let delta = value.translation.height
                                                    let velocity = value.predictedEndTranslation.height - delta
                                                    
                                                    withAnimation(.spring(response: 0.36, dampingFraction: 0.72)) {
                                                        if isExpanded {
                                                            // If dragged down, collapse it
                                                            if delta > 70 || velocity > 120 {
                                                                expandedCardId = nil
                                                            }
                                                        } else {
                                                            // If dragged up, expand it
                                                            if delta < -70 || velocity < -120 {
                                                                expandedCardId = card.id
                                                            } else {
                                                                // Toggle expand/collapse on simple tap
                                                                if abs(delta) < 15 {
                                                                    expandedCardId = card.id
                                                                }
                                                            }
                                                        }
                                                        dragOffsets[card.id] = 0
                                                    }
                                                }
                                        )
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.36, dampingFraction: 0.72)) {
                                                if isExpanded {
                                                    expandedCardId = nil
                                                } else {
                                                    expandedCardId = card.id
                                                }
                                            }
                                        }
                                }
                            }
                            .frame(height: CGFloat(cards.count * 45) + 240)
                            .padding(.horizontal, 24)
                            .padding(.top, 10)
                        }
                    }
                }
                .padding(.bottom, 100) // Float above bottom bar
            }
            .sheet(isPresented: $showAddCardSheet) {
                AddCardView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // Calculates card vertical coordinate offsets to simulate overlapping or fanning out
    private func calculateCardOffset(index: Int, cardId: UUID) -> CGFloat {
        let baseOffset = CGFloat(index * 45)
        
        guard let expandedId = expandedCardId else {
            return baseOffset // Standard overlap stack
        }
        
        if expandedId == cardId {
            // Squeezes selection up to clear the rest of the pack
            if let expandedIndex = cards.firstIndex(where: { $0.id == expandedId }) {
                return CGFloat(expandedIndex * 45) - 95
            }
            return baseOffset - 95
        }
        
        if let expandedIndex = cards.firstIndex(where: { $0.id == expandedId }) {
            if index < expandedIndex {
                // Dimmed cards sitting behind active card slide up slightly
                return baseOffset - 25
            } else {
                // Cards sitting below active card sink downwards to clear space
                return baseOffset + 140
            }
        }
        
        return baseOffset
    }
    
    // Gets primary brand coloring for active shadow casting
    private func cardColor(for card: Card) -> Color {
        switch card.inferredCardType {
        case "Visa": return Color(hex: "#1E40AF")
        case "Mastercard": return Color(hex: "#D97706")
        case "Amex": return Color(hex: "#047857")
        default: return Color(hex: "#6B7280")
        }
    }
}

// MARK: - Apple Pay Individual Card View
struct CardView: View {
    let card: Card
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card Brand Logo & Contactless Indicator
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(card.inferredCardType.uppercased())
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .italic()
                        .foregroundColor(.white)
                        .tracking(1)
                    Text("ELECTRONIC CARD")
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
            
            // Smart Card Chip
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.black.opacity(0.15), lineWidth: 0.8)
                    )
                
                // Chip texture grid lines
                VStack(spacing: 5) {
                    Divider().background(Color.black.opacity(0.2))
                    Divider().background(Color.black.opacity(0.2))
                }
                .padding(.vertical, 4)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
            
            // Card Number Masked representation
            Text(formatMaskedCardNumber(card.cardNumber))
                .font(.system(size: 20, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                .padding(.horizontal, 24)
            
            Spacer()
            
            // Card Holder & Expire date bottom details
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CARDHOLDER")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                    Text(card.holderName.uppercased())
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("EXPIRES")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                    Text(card.expiryDate)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                // Brand Graphical Logo Accent
                Group {
                    if card.inferredCardType == "Mastercard" {
                        HStack(spacing: -8) {
                            Circle()
                                .fill(Color.red.opacity(0.85))
                                .frame(width: 24, height: 24)
                            Circle()
                                .fill(Color.orange.opacity(0.85))
                                .frame(width: 24, height: 24)
                        }
                        .padding(.leading, 12)
                    } else if card.inferredCardType == "Visa" {
                        Text("VISA")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .italic()
                            .padding(.leading, 12)
                    } else if card.inferredCardType == "Amex" {
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
                // Customized dynamic glass skin shaders based on inferred card brand
                if card.inferredCardType == "Visa" {
                    // Deep cobalt blue mesh
                    LinearGradient(
                        colors: [Color(hex: "#1E3A8A"), Color(hex: "#3B82F6"), Color(hex: "#0F172A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else if card.inferredCardType == "Mastercard" {
                    // Dark charcoal gold
                    LinearGradient(
                        colors: [Color(hex: "#111827"), Color(hex: "#1F2937"), Color(hex: "#78350F")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else if card.inferredCardType == "Amex" {
                    // Centurion Sage Jade
                    LinearGradient(
                        colors: [Color(hex: "#064E3B"), Color(hex: "#047857"), Color(hex: "#065F46")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    // Silver chrome default
                    LinearGradient(
                        colors: [Color(hex: "#4B5563"), Color(hex: "#9CA3AF"), Color(hex: "#374151")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                
                // Frosted glass refractive filter
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
    
    // Formats card card number to show space partitions and obfuscate intermediate digits
    private func formatMaskedCardNumber(_ rawNumber: String) -> String {
        let digits = rawNumber.filter { $0.isNumber }
        guard digits.count >= 4 else {
            return "•••• •••• •••• ••••"
        }
        
        let lastFour = digits.suffix(4)
        return "••••  ••••  ••••  \(lastFour)"
    }
}
