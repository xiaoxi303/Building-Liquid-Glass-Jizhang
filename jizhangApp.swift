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
                Transaction.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            
            // Create container
            let container = try ModelContainer(for: schema, configurations: [config])
            self.container = container
            
            // Perform database warm-up and data seeding on the MainActor
            Task { @MainActor in
                do {
                    try await Self.seedDefaultCategoriesIfNeeded(context: container.mainContext)
                } catch {
                    print("Failed to seed default categories: \(error.localizedDescription)")
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
}
