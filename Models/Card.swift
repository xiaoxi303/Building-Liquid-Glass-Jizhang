import Foundation
import SwiftData

/// Represents a physical or virtual credit/debit card stored in the user's wallet.
/// Supports SwiftData persistence and BIN-based card type auto-inference.
@Model
public final class Card {
    @Attribute(.unique) public var id: UUID
    public var holderName: String
    public var cardNumber: String // Obfuscated or plain card number string
    public var expiryDate: String // MM/YY format
    public var cardType: String // Stored card type override
    
    public init(
        id: UUID = UUID(),
        holderName: String,
        cardNumber: String,
        expiryDate: String,
        cardType: String = ""
    ) {
        self.id = id
        self.holderName = holderName
        self.cardNumber = cardNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        self.expiryDate = expiryDate
        self.cardType = cardType
    }
    
    /// Auto-identifies card brand (Visa, Mastercard, Amex) based on BIN prefix rules.
    public var inferredCardType: String {
        // Strip out non-numeric characters for BIN validation
        let digits = cardNumber.filter { $0.isNumber }
        
        if digits.hasPrefix("4") {
            return "Visa"
        } else if digits.hasPrefix("34") || digits.hasPrefix("37") {
            return "Amex"
        }
        
        // Mastercard BIN ranges: 51-55
        for prefix in 51...55 {
            if digits.hasPrefix(String(prefix)) {
                return "Mastercard"
            }
        }
        
        return "Unknown"
    }
}
