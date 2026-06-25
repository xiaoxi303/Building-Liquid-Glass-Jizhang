import SwiftUI

/// A custom view modifier that applies a premium "Liquid Glass" effect to any SwiftUI view.
/// This style leverages iOS native ultraThinMaterial combined with custom specular highlight overlays
/// and depth shadows to simulate refractive glass.
/// Supports global @AppStorage customization of blur values.
public struct LiquidGlassModifier: ViewModifier {
    public var cornerRadius: CGFloat
    public var shadowRadius: CGFloat
    public var borderOpacity: Double
    
    // Global User Customizable Glass Blur Radius (AppStorage synced)
    @AppStorage("glassBlurRadius") private var globalBlurRadius: Double = 16.0
    
    public init(cornerRadius: CGFloat = 24, shadowRadius: CGFloat = 16, borderOpacity: Double = 0.25) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.borderOpacity = borderOpacity
    }
    
    public func body(content: Content) -> some View {
        content
            // 1. Dynamic customizable glass material background
            .background(
                Color.clear
                    .background(.ultraThinMaterial)
                    .blur(radius: CGFloat(globalBlurRadius))
            )
            // 2. Continuous corner radius clipping
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            // 3. Multi-directional 0.5px edge micro-glow border (top lit, bottom deep)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(borderOpacity * 1.6),
                                .white.opacity(borderOpacity * 0.4),
                                .black.opacity(0.15),
                                .white.opacity(borderOpacity * 0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            // 4. Double shadows
            .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: shadowRadius * 0.4)
            .shadow(color: Color.white.opacity(0.15), radius: 1, x: 0, y: -0.5) // Edge refraction top highlight
    }
}

/// A button style that simulates a thick piece of glass that undergoes physical optical changes when pressed.
/// Includes dynamic specular highlight tracking at the user's touch location.
public struct LiquidGlassButtonStyle: ButtonStyle {
    @State private var touchLocation: CGPoint = .zero
    
    // Global User Customizable Glass Blur Radius
    @AppStorage("glassBlurRadius") private var globalBlurRadius: Double = 16.0
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // 1. Scale shrink on press
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
            // 2. Liquid Glass Material Background (synced blur)
            .background(
                ZStack {
                    // Thick glass body
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.clear.background(.ultraThinMaterial))
                        .blur(radius: CGFloat(globalBlurRadius))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .opacity(configuration.isPressed ? 0.80 : 1.0)
                        // Darkens internal material on press
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.black.opacity(configuration.isPressed ? 0.15 : 0.0))
                        )
                    
                    // Dynamic Specular Glow (Glow-Flow highlight centered at touch coordinate)
                    if configuration.isPressed {
                        GeometryReader { geo in
                            RadialGradient(
                                colors: [Color.white.opacity(0.20), .clear],
                                center: .init(x: touchLocation.x / geo.size.width, y: touchLocation.y / geo.size.height),
                                startRadius: 0,
                                endRadius: geo.size.width * 0.6
                            )
                            .blendMode(.plusLighter)
                        }
                        .transition(.opacity.animation(.easeOut(duration: 0.25)))
                    }
                }
            )
            // 3. Edge Micro-Glow Border
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(configuration.isPressed ? 0.25 : 0.5),
                                .white.opacity(0.1),
                                .black.opacity(0.2),
                                .white.opacity(configuration.isPressed ? 0.2 : 0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: configuration.isPressed ? 0.8 : 1.2
                    )
            )
            // 4. Soft shadows
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.15 : 0.08), radius: 10, x: 0, y: 5)
            // Touch location tracker
            .background(
                GeometryReader { geo in
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    touchLocation = value.location
                                }
                        )
                }
            )
    }
}

extension View {
    /// Applies a premium Liquid Glass effect.
    public func liquidGlass(
        cornerRadius: CGFloat = 24,
        shadowRadius: CGFloat = 16,
        borderOpacity: Double = 0.25
    ) -> some View {
        self.modifier(
            LiquidGlassModifier(
                cornerRadius: cornerRadius,
                shadowRadius: shadowRadius,
                borderOpacity: borderOpacity
            )
        )
    }
    
    /// Applies an inner shadow effect to simulate hollow indentation or specular refraction.
    public func innerShadow<S: Shape>(
        shape: S,
        color: Color,
        radius: CGFloat,
        offsetY: CGFloat = 1
    ) -> some View {
        self.overlay(
            shape
                .stroke(color, lineWidth: radius)
                .blur(radius: radius)
                .offset(y: offsetY)
                .mask(shape)
        )
    }
}

extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

