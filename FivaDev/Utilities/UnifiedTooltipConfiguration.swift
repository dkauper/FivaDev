//
//  UnifiedTooltipConfiguration.swift
//  FivaDev
//
//  Simplified, unified tooltip system with center-body placement
//  Created: October 2, 2025, 11:30 AM PDT
//  Updated: October 2, 2025, 11:45 AM PDT - Added text color control
//

import SwiftUI

// MARK: - Unified Tooltip Style
/// Defines the visual appearance of tooltips
struct TooltipStyle {
    /// Font size for tooltip text (default: .largeTitle)
    let fontSize: Font
    
    /// Font weight (default: .regular)
    let fontWeight: Font.Weight
    
    /// Font design (default: .default)
    let fontDesign: Font.Design
    
    /// Text/foreground color (default: .white)
    let textColor: Color
    
    /// Background color (default: .black)
    let backgroundColor: Color
    
    /// Background opacity (default: 0.85)
    let backgroundOpacity: Double
    
    /// Stroke/border color (default: .white)
    let strokeColor: Color
    
    /// Stroke width (default: 2)
    let strokeWidth: CGFloat
    
    /// Corner radius (default: 16)
    let cornerRadius: CGFloat
    
    /// Padding around text (default: 24)
    let padding: CGFloat
    
    /// Shadow radius (default: 8)
    let shadowRadius: CGFloat
    
    /// Maximum width as percentage of body width (default: 0.8)
    let maxWidthPercent: CGFloat
    
    init(
        fontSize: Font = .largeTitle,
        fontWeight: Font.Weight = .regular,
        fontDesign: Font.Design = .default,
        textColor: Color = .white,
        backgroundColor: Color = .mint,
        backgroundOpacity: Double = 0.85,
        strokeColor: Color = .white,
        strokeWidth: CGFloat = 2,
        cornerRadius: CGFloat = 16,
        padding: CGFloat = 24,
        shadowRadius: CGFloat = 8,
        maxWidthPercent: CGFloat = 0.4
    ) {
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.fontDesign = fontDesign
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.backgroundOpacity = backgroundOpacity
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.shadowRadius = shadowRadius
        self.maxWidthPercent = maxWidthPercent
    }
    
    /// Default style for all tooltips
    static let standard = TooltipStyle()
    
    /// Compact style for smaller devices
    static let compact = TooltipStyle(
        fontSize: .title,
        padding: 16,
        maxWidthPercent: 0.85
    )
    
    /// Emphasized style for important information
    static let emphasized = TooltipStyle(
        fontSize: .largeTitle,
        fontWeight: .bold,
        strokeWidth: 3,
        shadowRadius: 12
    )
    
    /// Example: Custom color scheme
    static let customExample = TooltipStyle(
        fontSize: .title,
        textColor: .yellow,
        backgroundColor: .blue,
        backgroundOpacity: 0.9,
        strokeColor: .cyan,
        strokeWidth: 3
    )
}

// MARK: - Tooltip Content
/// Defines the content structure for a tooltip
struct TooltipContent {
    /// Title text (element name)
    let title: String
    
    /// Description text (starting on second line)
    let description: String
    
    /// Whether this tooltip is enabled
    let enabled: Bool
    
    init(title: String, description: String, enabled: Bool = true) {
        self.title = title
        self.description = description
        self.enabled = enabled
    }
}

// MARK: - Unified Tooltip Configuration Manager
struct UnifiedTooltipConfiguration {
    
    /// Get tooltip content for a specific element type
    static func content(for elementType: DiscardElementType) -> TooltipContent {
        switch elementType {
        case .lastDiscard:
            return TooltipContent(
                title: "Last Discard",
                description: "Most recent card discarded by any player"
            )
        case .lastPlayer:
            return TooltipContent(
                title: "Previous Player",
                description: "Player who just completed their turn"
            )
        case .nextPlayer:
            return TooltipContent(
                title: "Next Player",
                description: "Player who will play after the current turn"
            )
        case .score:
            return TooltipContent(
                title: "Game Score",
                description: "Current score and progress for all players"
            )
        case .timer:
            return TooltipContent(
                title: "Turn Timer",
                description: "Time remaining for the current player's turn"
            )
        }
    }
    
    /// Get appropriate style for the device
    static func style(for deviceType: DeviceType) -> TooltipStyle {
        switch deviceType {
        case .iPhone:
            return .compact
        case .iPad:
            return .standard
        case .mac:
            return .standard
        }
    }
}

// MARK: - Center-Body Tooltip View
/// Unified tooltip view that always appears centered in the body view
struct CenterTooltipView: View {
    let content: TooltipContent
    let style: TooltipStyle
    let bodyWidth: CGFloat
    let bodyHeight: CGFloat
    let isVisible: Bool
    
    var body: some View {
        if isVisible && content.enabled {
            VStack(spacing: 12) {
                // Title line
                Text(content.title)
                    .font(style.fontSize)
                    .fontWeight(.bold)
                    .fontDesign(style.fontDesign)
                    .multilineTextAlignment(.center)
                
                // Description (starting on second line)
                Text(content.description)
                    .font(style.fontSize)
                    .fontWeight(style.fontWeight)
                    .fontDesign(style.fontDesign)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundColor(style.textColor)
            .padding(style.padding)
            .frame(maxWidth: bodyWidth * style.maxWidthPercent)
            .background(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(style.backgroundColor.opacity(style.backgroundOpacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: style.cornerRadius)
                            .stroke(style.strokeColor, lineWidth: style.strokeWidth)
                    )
                    .shadow(
                        color: .black.opacity(0.4),
                        radius: style.shadowRadius,
                        x: 0,
                        y: 4
                    )
            )
            .position(x: bodyWidth / 2, y: bodyHeight / 2)
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isVisible)
        }
    }
}

// MARK: - Preview Support
#Preview("Standard Tooltip") {
    ZStack {
        Color(hex: "B7E4CC")
            .ignoresSafeArea()
        
        CenterTooltipView(
            content: UnifiedTooltipConfiguration.content(for: .lastDiscard),
            style: .standard,
            bodyWidth: 400,
            bodyHeight: 600,
            isVisible: true
        )
    }
}

#Preview("Compact Tooltip") {
    ZStack {
        Color(hex: "B7E4CC")
            .ignoresSafeArea()
        
        CenterTooltipView(
            content: UnifiedTooltipConfiguration.content(for: .timer),
            style: .compact,
            bodyWidth: 350,
            bodyHeight: 700,
            isVisible: true
        )
    }
}

#Preview("Emphasized Tooltip") {
    ZStack {
        Color(hex: "B7E4CC")
            .ignoresSafeArea()
        
        CenterTooltipView(
            content: UnifiedTooltipConfiguration.content(for: .score),
            style: .emphasized,
            bodyWidth: 800,
            bodyHeight: 600,
            isVisible: true
        )
    }
}

#Preview("Custom Color Scheme") {
    ZStack {
        Color(hex: "B7E4CC")
            .ignoresSafeArea()
        
        CenterTooltipView(
            content: UnifiedTooltipConfiguration.content(for: .nextPlayer),
            style: .customExample,
            bodyWidth: 600,
            bodyHeight: 400,
            isVisible: true
        )
    }
}
