import Foundation
import SwiftData

/// The type of a financial transaction: expense or income.
public enum TransactionType: String, Codable, CaseIterable, Sendable {
    case expense
    case income
}

/// Represents an individual financial transaction (income or expense).
@Model
public final class Transaction {
    @Attribute(.unique) public var id: UUID
    public var amount: Double
    public var note: String
    public var date: Date
    public var typeString: String // Internal rawValue storage for transaction type
    
    // Establishing a relationship back to the Category.
    public var category: Category?
    
    // Computed property to interface with the raw TransactionType enum
    public var type: TransactionType {
        get {
            TransactionType(rawValue: typeString) ?? .expense
        }
        set {
            typeString = newValue.rawValue
        }
    }
    
    public init(id: UUID = UUID(), amount: Double, note: String, date: Date = Date(), type: TransactionType, category: Category? = nil) {
        self.id = id
        self.amount = amount
        self.note = note
        self.date = date
        self.typeString = type.rawValue
        self.category = category
    }
}
