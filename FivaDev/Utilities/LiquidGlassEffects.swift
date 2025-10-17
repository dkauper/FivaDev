//
//  LiquidGlassEffects.swift
//  FivaDev
//
//  Advanced Liquid Glass Effects for Player and Discard Overlays
//  Created by Doron Kauper on 9/22/25.
//  Updated: September 22, 2025, 4:15 PM PST
//

import SwiftUI

// MARK: - Liquid Glass Effect Styles
enum LiquidGlassStyle {
    case subtle         // Light, minimal glass effect
    case standard       // Balanced glass effect with moderate blur
    case dramatic       // Strong glass effect with heavy blur
    case crystalline    // Sharp, crystal-like appearance
    case frosted        // Heavy frosted glass look
    case holographic    // Iridescent, color-shifting effect
}

// MARK: - Advanced Liquid Glass View Modifier
struct LiquidGlassEffect: ViewModifier {
    let style: LiquidGlassStyle
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let shadowRadius: CGFloat
    let shadowOpacity: Double
    
    init(
        style: LiquidGlassStyle = .standard,
        cornerRadius: CGFloat = 12,
        borderWidth: CGFloat = 1.5,
        shadowRadius: CGFloat = 8,
        shadowOpacity: Double = 0.3
    ) {
        self.style = style
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.shadowRadius = shadowRadius
        self.shadowOpacity = shadowOpacity
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Main glass background
                    backgroundForStyle(style)
                    
                    // Border and highlights
                    borderForStyle(style)
                    
                    // Inner glow/highlight
                    innerGlowForStyle(style)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: shadowColorForStyle(style),
                radius: shadowRadius,
                x: 0,
                y: shadowRadius * 0.3
            )
    }
    
    // MARK: - Background Styles
    @ViewBuilder
    private func backgroundForStyle(_ style: LiquidGlassStyle) -> some View {
        switch style {
        case .subtle:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
                .opacity(0.7)
        
        case .standard:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.regularMaterial)
                .opacity(0.8)
        
        case .dramatic:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.thickMaterial)
                .opacity(0.9)
        
        case .crystalline:
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.clear,
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        
        case .frosted:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.thickMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.white.opacity(0.1))
                )
        
        case .holographic:
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.regularMaterial)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        AngularGradient(
                            colors: [
                                Color.blue.opacity(0.1),
                                Color.purple.opacity(0.1),
                                Color.pink.opacity(0.1),
                                Color.orange.opacity(0.1),
                                Color.blue.opacity(0.1)
                            ],
                            center: .center
                        )
                    )
            }
        }
    }
    
    // MARK: - Border Styles
    @ViewBuilder
    private func borderForStyle(_ style: LiquidGlassStyle) -> some View {
        switch style {
        case .subtle:
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.2), lineWidth: borderWidth * 0.7)
        
        case .standard:
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.3), lineWidth: borderWidth)
        
        case .dramatic:
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.4), lineWidth: borderWidth * 1.3)
        
        case .crystalline:
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.6),
                            Color.clear,
                            Color.white.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: borderWidth
                )
        
        case .frosted:
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.5), lineWidth: borderWidth * 1.2)
        
        case .holographic:
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.cyan.opacity(0.4),
                            Color.purple.opacity(0.4),
                            Color.pink.opacity(0.4),
                            Color.cyan.opacity(0.4)
                        ],
                        center: .center
                    ),
                    lineWidth: borderWidth
                )
        }
    }
    
    // MARK: - Inner Glow Styles
    @ViewBuilder
    private func innerGlowForStyle(_ style: LiquidGlassStyle) -> some View {
        switch style {
        case .subtle:
            EmptyView()
        
        case .standard:
            RoundedRectangle(cornerRadius: cornerRadius - 1)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                .padding(1)
        
        case .dramatic:
            RoundedRectangle(cornerRadius: cornerRadius - 2)
                .stroke(Color.white.opacity(0.25), lineWidth: 2)
                .padding(2)
        
        case .crystalline:
            VStack {
                HStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 20, height: 2)
                    Spacer()
                }
                Spacer()
            }
            .padding(8)
        
        case .frosted:
            RoundedRectangle(cornerRadius: cornerRadius - 2)
                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                .padding(2)
        
        case .holographic:
            RoundedRectangle(cornerRadius: cornerRadius - 1)
                .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
                .padding(1)
        }
    }
    
    // MARK: - Shadow Colors
    private func shadowColorForStyle(_ style: LiquidGlassStyle) -> Color {
        switch style {
        case .subtle:
            return Color.black.opacity(0.1)
        case .standard:
            return Color.black.opacity(0.2)
        case .dramatic:
            return Color.black.opacity(0.4)
        case .crystalline:
            return Color.blue.opacity(0.2)
        case .frosted:
            return Color.gray.opacity(0.3)
        case .holographic:
            return Color.purple.opacity(0.2)
        }
    }
}

// MARK: - Animated Liquid Glass Effect
struct AnimatedLiquidGlass: ViewModifier {
    let style: LiquidGlassStyle
    let cornerRadius: CGFloat
    let animationSpeed: Double
    
    @State private var shimmerOffset: CGFloat = -1
    @State private var pulseOpacity: Double = 0.3
    
    init(
        style: LiquidGlassStyle = .holographic,
        cornerRadius: CGFloat = 12,
        animationSpeed: Double = 3.0
    ) {
        self.style = style
        self.cornerRadius = cornerRadius
        self.animationSpeed = animationSpeed
    }
    
    func body(content: Content) -> some View {
        content
            .modifier(LiquidGlassEffect(style: style, cornerRadius: cornerRadius))
            .overlay(
                // Animated shimmer effect
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: shimmerOffset * 300)
                    .mask(
                        RoundedRectangle(cornerRadius: cornerRadius)
                    )
                    .opacity(pulseOpacity)
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: animationSpeed)
                        .repeatForever(autoreverses: false)
                ) {
                    shimmerOffset = 1
                }
                
                withAnimation(
                    Animation.easeInOut(duration: animationSpeed * 0.5)
                        .repeatForever(autoreverses: true)
                ) {
                    pulseOpacity = 0.8
                }
            }
    }
}

// MARK: - Player Hand Specific Glass Effect
struct PlayerHandGlassEffect: ViewModifier {
    let isExpanded: Bool
    let deviceType: DeviceType
    
    func body(content: Content) -> some View {
        let glassStyle: LiquidGlassStyle = {
            switch deviceType {
            case .iPhone:
                return isExpanded ? .dramatic : .standard
            case .iPad:
                return isExpanded ? .crystalline : .standard
            case .mac:
                return .frosted
//            case .appleTV:
//                return .dramatic
            }
        }()
        
        content
            .modifier(LiquidGlassEffect(
                style: glassStyle,
                cornerRadius: 16,
                borderWidth: isExpanded ? 2.0 : 1.5,
                shadowRadius: isExpanded ? 12 : 8,
                shadowOpacity: isExpanded ? 0.4 : 0.3
            ))
    }
}

// MARK: - Discard Overlay Specific Glass Effect
struct DiscardOverlayGlassEffect: ViewModifier {
    let deviceType: DeviceType
    let orientation: AppOrientation
    
    func body(content: Content) -> some View {
        let glassStyle: LiquidGlassStyle = {
            switch (deviceType, orientation) {
            case (.iPhone, .portrait):
                return .subtle
            case (.iPhone, .landscape):
                return .standard
            case (.iPad, _):
                return .crystalline
            case (.mac, _):
                return .holographic
            }
        }()
        
        content
            .modifier(LiquidGlassEffect(
                style: glassStyle,
                cornerRadius: 12,
                borderWidth: 1.5,
                shadowRadius: 10,
                shadowOpacity: 0.35
            ))
    }
}

// MARK: - Interactive Glass Effect (for Cards)
struct InteractiveGlassEffect: ViewModifier {
    let isHovered: Bool
    let isPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .modifier(LiquidGlassEffect(
                style: isHovered ? .crystalline : .standard,
                cornerRadius: 8,
                borderWidth: isPressed ? 2.5 : (isHovered ? 2.0 : 1.0),
                shadowRadius: isPressed ? 15 : (isHovered ? 12 : 6),
                shadowOpacity: isPressed ? 0.5 : (isHovered ? 0.4 : 0.2)
            ))
            .scaleEffect(isPressed ? 0.95 : (isHovered ? 1.05 : 1.0))
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}

// MARK: - Convenience View Extensions
extension View {
    // Basic liquid glass effect
    func liquidGlass(
        style: LiquidGlassStyle = .standard,
        cornerRadius: CGFloat = 12
    ) -> some View {
        modifier(LiquidGlassEffect(style: style, cornerRadius: cornerRadius))
    }
    
    // Animated liquid glass effect
    func animatedLiquidGlass(
        style: LiquidGlassStyle = .holographic,
        cornerRadius: CGFloat = 12,
        speed: Double = 3.0
    ) -> some View {
        modifier(AnimatedLiquidGlass(style: style, cornerRadius: cornerRadius, animationSpeed: speed))
    }
    
    // Player hand specific glass
    func playerHandGlass(isExpanded: Bool, deviceType: DeviceType) -> some View {
        modifier(PlayerHandGlassEffect(isExpanded: isExpanded, deviceType: deviceType))
    }
    
    // Discard overlay specific glass
    func discardOverlayGlass(deviceType: DeviceType, orientation: AppOrientation) -> some View {
        modifier(DiscardOverlayGlassEffect(deviceType: deviceType, orientation: orientation))
    }
    
    // Interactive glass for cards
    func interactiveGlass(isHovered: Bool = false, isPressed: Bool = false) -> some View {
        modifier(InteractiveGlassEffect(isHovered: isHovered, isPressed: isPressed))
    }
}

// MARK: - Preview Examples
#Preview("Liquid Glass Styles") {
    VStack(spacing: 20) {
        HStack(spacing: 15) {
            Text("Subtle")
                .padding()
                .liquidGlass(style: .subtle)
            
            Text("Standard")
                .padding()
                .liquidGlass(style: .standard)
            
            Text("Dramatic")
                .padding()
                .liquidGlass(style: .dramatic)
        }
        
        HStack(spacing: 15) {
            Text("Crystalline")
                .padding()
                .liquidGlass(style: .crystalline)
            
            Text("Frosted")
                .padding()
                .liquidGlass(style: .frosted)
            
            Text("Holographic")
                .padding()
                .animatedLiquidGlass(style: .holographic)
        }
    }
    .padding()
    .background(
        LinearGradient(
            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
