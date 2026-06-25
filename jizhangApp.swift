import SwiftUI
import SwiftData

@main
struct jizhangApp: App {
    // Custom container to perform seed logic on startup
    let container: ModelContainer

    init() {
        do {
            // Configure schema and storage for Categories and Transactions
            let schema = Schema([
                Category.self,
                Transaction.self,
                Card.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            
            // Create container
            let container = try ModelContainer(for: schema, configurations: [config])
            self.container = container
            
            // Perform database warm-up and data seeding on the MainActor
            Task { @MainActor in
                do {
                    try await Self.seedDefaultCategoriesIfNeeded(context: container.mainContext)
                    try await Self.seedDefaultCardsIfNeeded(context: container.mainContext)
                } catch {
                    print("Failed to seed database: \(error.localizedDescription)")
                }
            }
        } catch {
            fatalError("Could not initialize ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            TabController()
        }
        .modelContainer(container)
    }
    
    /// Seeds default categories if the database is empty.
    /// Accesses mainContext on the `@MainActor` to comply with Swift 6 concurrency rules.
    @MainActor
    private static func seedDefaultCategoriesIfNeeded(context: ModelContext) async throws {
        // Query to check if categories already exist
        var descriptor = FetchDescriptor<Category>()
        descriptor.fetchLimit = 1
        
        let existingCategories = try context.fetch(descriptor)
        guard existingCategories.isEmpty else {
            // Categories already seeded
            return
        }
        
        // Define default categories with hex colors and SF Symbols
        let defaultCategories = [
            Category(name: "餐饮", icon: "fork.knife", hexColor: "#FF9500"),       // Orange
            Category(name: "购物", icon: "cart.fill", hexColor: "#FF2D55"),         // Rose
            Category(name: "交通", icon: "tram.fill", hexColor: "#5AC8FA"),         // Light Blue
            Category(name: "娱乐", icon: "gamecontroller.fill", hexColor: "#AF52DE"), // Purple
            Category(name: "收入", icon: "yensign.circle.fill", hexColor: "#34C759") // Green
        ]
        
        // Insert all categories
        for category in defaultCategories {
            context.insert(category)
        }
        
        // Persist database changes
        try context.save()
        print("Successfully seeded default categories in SwiftData database.")
    }
    
    /// Seeds three classic credit cards (Visa, Mastercard, Amex) if the wallet is empty.
    @MainActor
    private static func seedDefaultCardsIfNeeded(context: ModelContext) async throws {
        var descriptor = FetchDescriptor<Card>()
        descriptor.fetchLimit = 1
        
        let existingCards = try context.fetch(descriptor)
        guard existingCards.isEmpty else {
            return
        }
        
        let defaultCards = [
            Card(holderName: "John Appleseed", cardNumber: "4000 1234 5678 9010", expiryDate: "12/28"),
            Card(holderName: "John Appleseed", cardNumber: "5200 9876 5432 1098", expiryDate: "09/30"),
            Card(holderName: "John Appleseed", cardNumber: "3700 1111 2222 3333", expiryDate: "05/29")
        ]
        
        for card in defaultCards {
            context.insert(card)
        }
        
        try context.save()
        print("Successfully seeded default credit cards in SwiftData database.")
    }
}
