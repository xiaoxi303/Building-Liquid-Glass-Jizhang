import SwiftUI

/// A reusable SwiftUI container that applies high-contrast Gaussian blur filters (Metaball algorithm)
/// to its content, enabling organic fluid stretching, snapping, and water-droplet fusion/splitting.
public struct LiquidFusionView<Content: View>: View {
    private let content: Content
    private let blurRadius: CGFloat
    private let contrastThreshold: CGFloat
    
    public init(
        blurRadius: CGFloat = 12,
        contrastThreshold: CGFloat = 18,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.blurRadius = blurRadius
        self.contrastThreshold = contrastThreshold
    }
    
    public var body: some View {
        content
            .blur(radius: blurRadius)
            .contrast(contrastThreshold)
    }
}

/// A View modifier that simulates a chromatic aberration (棱镜折射色散) edge glow on glass margins
/// by overlaying three sub-pixel offset sub-RGB strokes.
/// Syncs with global @AppStorage toggle to enable/disable the effect dynamically.
public struct ChromaticAberrationEdgeGlow: ViewModifier {
    public var cornerRadius: CGFloat
    public var lineWidth: CGFloat
    public var opacity: Double
    
    // Global customizable Chromatic Aberration toggle (AppStorage synced)
    @AppStorage("chromaticGlowEnabled") private var chromaticGlowEnabled: Bool = true
    
    public init(cornerRadius: CGFloat = 32, lineWidth: CGFloat = 1.0, opacity: Double = 0.35) {
        self.cornerRadius = cornerRadius
        self.lineWidth = lineWidth
        self.opacity = opacity
    }
    
    public func body(content: Content) -> some View {
        if chromaticGlowEnabled {
            content
                .overlay(
                    ZStack {
                        // 1. Red dispersion (offset top-left)
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.red.opacity(opacity), lineWidth: lineWidth)
                            .offset(x: -0.6, y: -0.4)
                            .blendMode(.plusLighter)
                        
                        // 2. Green dispersion (offset center-bottom)
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.green.opacity(opacity * 0.9), lineWidth: lineWidth)
                            .offset(x: 0, y: 0.3)
                            .blendMode(.plusLighter)
                        
                        // 3. Blue dispersion (offset bottom-right)
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.blue.opacity(opacity), lineWidth: lineWidth)
                            .offset(x: 0.6, y: 0.4)
                            .blendMode(.plusLighter)
                    }
                )
        } else {
            content
        }
    }
}

extension View {
    /// Applies a premium chromatic aberration edge glow effect.
    public func chromaticEdgeGlow(
        cornerRadius: CGFloat = 32,
        lineWidth: CGFloat = 1.0,
        opacity: Double = 0.35
    ) -> some View {
        self.modifier(
            ChromaticAberrationEdgeGlow(
                cornerRadius: cornerRadius,
                lineWidth: lineWidth,
                opacity: opacity
            )
        )
    }
}
