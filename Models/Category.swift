import Foundation
import SwiftData

/// Represents a financial category for grouping transactions.
@Model
public final class Category {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var icon: String // SF Symbol name, e.g., "cart.fill", "fork.knife"
    public var hexColor: String // Hex color representation for custom rendering
    
    // Establishing a one-to-many relationship. If a category is deleted,
    // its associated transactions will be cascade deleted.
    @Relationship(deleteRule: .cascade, inverse: \Transaction.category)
    public var transactions: [Transaction]?
    
    public init(id: UUID = UUID(), name: String, icon: String, hexColor: String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.hexColor = hexColor
        self.transactions = []
    }
}
