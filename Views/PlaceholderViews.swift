import SwiftUI
import SwiftData

// MARK: - Subview: Categories List Sheet View
/// Displays the lists of categories pre-populated in SwiftData.
public struct CategoriesListView: View {
    @Query(sort: \Category.name) private var categories: [Category]
    
    public init() {}
    
    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#0F172A"), Color(hex: "#1E293B")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Drag indicator handle
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                
                Text("系统默认分类 (Default Categories)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(categories) { category in
                            HStack(spacing: 16) {
                                let catColor = Color(hex: category.hexColor)
                                ZStack {
                                    Circle()
                                        .fill(catColor.opacity(0.15))
                                        .frame(width: 42, height: 42)
                                    Image(systemName: category.icon)
                                        .foregroundColor(catColor)
                                        .font(.title3)
                                }
                                
                                Text(category.name)
                                    .font(.body.bold())
                                    .foregroundColor(.white)
                                
                                Spacer()
                              }
                              .padding()
                              .liquidGlass(cornerRadius: 16, shadowRadius: 8, borderOpacity: 0.15)
                              .chromaticEdgeGlow(cornerRadius: 16, lineWidth: 0.8, opacity: 0.1)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .colorScheme(.dark)
    }
}
