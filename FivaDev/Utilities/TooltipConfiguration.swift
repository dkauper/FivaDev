//
//  TooltipConfiguration.swift
//  FivaDev
//
//  Enhanced tooltip positioning system for DiscardOverlay
//  Created: October 2, 2025, 9:45 AM PDT
//

import SwiftUI

// MARK: - Tooltip Position Offset
/// Defines the offset from the element's bottom-right corner
struct TooltipOffset {
    /// Horizontal offset in points from bottom-right corner (positive = right, negative = left)
    let x: CGFloat
    /// Vertical offset in points from bottom-right corner (positive = down, negative = up)
    let y: CGFloat
    
    /// Convenience initializer
    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    // MARK: - Common Presets
    static let aboveRight = TooltipOffset(x: 0, y: -8)      // Above, aligned to right edge
    static let aboveCenter = TooltipOffset(x: -50, y: -8)   // Above, centered (adjust x based on tooltip width)
    static let aboveLeft = TooltipOffset(x: -100, y: -8)    // Above, aligned to left edge
    
    static let belowRight = TooltipOffset(x: 0, y: 8)       // Below, aligned to right edge
    static let belowCenter = TooltipOffset(x: -50, y: 8)    // Below, centered
    static let belowLeft = TooltipOffset(x: -100, y: 8)     // Below, aligned to left edge
    
    static let rightTop = TooltipOffset(x: 8, y: -20)       // Right side, top aligned
    static let rightCenter = TooltipOffset(x: 8, y: -10)    // Right side, centered
    static let rightBottom = TooltipOffset(x: 8, y: 0)      // Right side, bottom aligned
    
    static let leftTop = TooltipOffset(x: -108, y: -20)     // Left side, top aligned
    static let leftCenter = TooltipOffset(x: -108, y: -10)  // Left side, centered
    static let leftBottom = TooltipOffset(x: -108, y: 0)    // Left side, bottom aligned
}

// MARK: - Tooltip Configuration
/// Complete tooltip configuration for a specific element
struct TooltipConfiguration {
    /// Text to display in tooltip
    let text: String
    
    /// Offset when overlay is in horizontal orientation
    let horizontalOffset: TooltipOffset
    
    /// Offset when overlay is in vertical orientation
    let verticalOffset: TooltipOffset
    
    /// Whether tooltip should be shown
    let enabled: Bool
    
    /// Maximum width for tooltip (optional, defaults to auto-sizing)
    let maxWidth: CGFloat?
    
    /// Font size for tooltip text
    let fontSize: CGFloat
    
    /// Background opacity (0.0 to 1.0)
    let backgroundOpacity: Double
    
    init(
        text: String,
        horizontalOffset: TooltipOffset = .belowCenter,
        verticalOffset: TooltipOffset = .rightCenter,
        enabled: Bool = true,
        maxWidth: CGFloat? = nil,
        fontSize: CGFloat = 12,
        backgroundOpacity: Double = 0.9
    ) {
        self.text = text
        self.horizontalOffset = horizontalOffset
        self.verticalOffset = verticalOffset
        self.enabled = enabled
        self.maxWidth = maxWidth
        self.fontSize = fontSize
        self.backgroundOpacity = backgroundOpacity
    }
}

// MARK: - Tooltip Configuration Manager
struct TooltipConfigurationManager {
    
    /// Get tooltip configuration for a specific element type
    static func configuration(
        for elementType: DiscardElementType,
        deviceType: DeviceType,
        orientation: AppOrientation
    ) -> TooltipConfiguration {
        
        switch (deviceType, orientation) {
        case (.iPhone, .portrait):
            return iPhonePortraitConfiguration(for: elementType)
        case (.iPhone, .landscape):
            return iPhoneLandscapeConfiguration(for: elementType)
        case (.iPad, .portrait):
            return iPadPortraitConfiguration(for: elementType)
        case (.iPad, .landscape):
            return iPadLandscapeConfiguration(for: elementType)
        case (.mac, .landscape):
            return macOSLandscapeConfiguration(for: elementType)
        default:
            return defaultConfiguration(for: elementType)
        }
    }
    
    // MARK: - iPhone Portrait Configurations
    private static func iPhonePortraitConfiguration(for elementType: DiscardElementType) -> TooltipConfiguration {
        switch elementType {
        case .lastDiscard:
            return TooltipConfiguration(
                text: "Most recent card discarded",
                horizontalOffset: TooltipOffset(x: -30, y: 12),    // Below, slightly left-centered
                verticalOffset: TooltipOffset(x: 12, y: -10),       // Right, top-aligned
                maxWidth: 120,
                fontSize: 11
            )
        case .lastPlayer:
            return TooltipConfiguration(
                text: "Previous player",
                horizontalOffset: TooltipOffset(x: -20, y: 12),     // Below, centered
                verticalOffset: TooltipOffset(x: 12, y: -10),
                maxWidth: 100
            )
        case .nextPlayer:
            return TooltipConfiguration(
                text: "Next player",
                horizontalOffset: TooltipOffset(x: -15, y: 12),     // Below, centered
                verticalOffset: TooltipOffset(x: 12, y: -10),
                maxWidth: 100
            )
        case .score:
            return TooltipConfiguration(
                text: "Current game score",
                horizontalOffset: TooltipOffset(x: -40, y: 12),     // Below, centered
                verticalOffset: TooltipOffset(x: 12, y: -10),
                maxWidth: 120
            )
        case .timer:
            return TooltipConfiguration(
                text: "Turn timer",
                horizontalOffset: TooltipOffset(x: -20, y: 12),     // Below, right-aligned
                verticalOffset: TooltipOffset(x: 12, y: -10),
                maxWidth: 80
            )
        }
    }
    
    // MARK: - iPhone Landscape Configurations
    private static func iPhoneLandscapeConfiguration(for elementType: DiscardElementType) -> TooltipConfiguration {
        switch elementType {
        case .lastDiscard:
            return TooltipConfiguration(
                text: "Most recent card discarded",
                horizontalOffset: TooltipOffset(x: 12, y: -10),     // Right, top-aligned
                verticalOffset: TooltipOffset(x: 12, y: -10),
                maxWidth: 140,
                fontSize: 11
            )
        case .lastPlayer:
            return TooltipConfiguration(
                text: "Previous player",
                horizontalOffset: TooltipOffset(x: 12, y: -5),      // Right, centered
                verticalOffset: TooltipOffset(x: 12, y: -5),
                maxWidth: 100
            )
        case .nextPlayer:
            return TooltipConfiguration(
                text: "Next player",
                horizontalOffset: TooltipOffset(x: 12, y: -5),      // Right, centered
                verticalOffset: TooltipOffset(x: 12, y: -5),
                maxWidth: 100
            )
        case .score:
            return TooltipConfiguration(
                text: "Current game score",
                horizontalOffset: TooltipOffset(x: 12, y: -5),      // Right, centered
                verticalOffset: TooltipOffset(x: 12, y: -5),
                maxWidth: 120
            )
        case .timer:
            return TooltipConfiguration(
                text: "Turn timer",
                horizontalOffset: TooltipOffset(x: 12, y: 0),       // Right, bottom-aligned
                verticalOffset: TooltipOffset(x: 12, y: 0),
                maxWidth: 80
            )
        }
    }
    
    // MARK: - iPad Portrait Configurations
    private static func iPadPortraitConfiguration(for elementType: DiscardElementType) -> TooltipConfiguration {
        switch elementType {
        case .lastDiscard:
            return TooltipConfiguration(
                text: "Most recent card discarded",
                horizontalOffset: TooltipOffset(x: 16, y: -12),     // Right, top-aligned
                verticalOffset: TooltipOffset(x: 16, y: -12),
                maxWidth: 160,
                fontSize: 13
            )
        case .lastPlayer:
            return TooltipConfiguration(
                text: "Previous player",
                horizontalOffset: TooltipOffset(x: 16, y: -8),      // Right, centered
                verticalOffset: TooltipOffset(x: 16, y: -8),
                maxWidth: 120,
                fontSize: 13
            )
        case .nextPlayer:
            return TooltipConfiguration(
                text: "Next player",
                horizontalOffset: TooltipOffset(x: 16, y: -8),      // Right, centered
                verticalOffset: TooltipOffset(x: 16, y: -8),
                maxWidth: 120,
                fontSize: 13
            )
        case .score:
            return TooltipConfiguration(
                text: "Current game score",
                horizontalOffset: TooltipOffset(x: 16, y: -8),      // Right, centered
                verticalOffset: TooltipOffset(x: 16, y: -8),
                maxWidth: 140,
                fontSize: 13
            )
        case .timer:
            return TooltipConfiguration(
                text: "Turn timer",
                horizontalOffset: TooltipOffset(x: 16, y: 0),       // Right, bottom-aligned
                verticalOffset: TooltipOffset(x: 16, y: 0),
                maxWidth: 100,
                fontSize: 13
            )
        }
    }
    
    // MARK: - iPad Landscape Configurations
    private static func iPadLandscapeConfiguration(for elementType: DiscardElementType) -> TooltipConfiguration {
        switch elementType {
        case .lastDiscard:
            return TooltipConfiguration(
                text: "Most recent card discarded",
                horizontalOffset: TooltipOffset(x: -60, y: 16),     // Below, centered
                verticalOffset: TooltipOffset(x: 16, y: -12),       // Right, top-aligned
                maxWidth: 160,
                fontSize: 13
            )
        case .lastPlayer:
            return TooltipConfiguration(
                text: "Previous player",
                horizontalOffset: TooltipOffset(x: -40, y: 16),     // Below, centered
                verticalOffset: TooltipOffset(x: 16, y: -8),
                maxWidth: 120,
                fontSize: 13
            )
        case .nextPlayer:
            return TooltipConfiguration(
                text: "Next player",
                horizontalOffset: TooltipOffset(x: -35, y: 16),     // Below, centered
                verticalOffset: TooltipOffset(x: 16, y: -8),
                maxWidth: 120,
                fontSize: 13
            )
        case .score:
            return TooltipConfiguration(
                text: "Current game score",
                horizontalOffset: TooltipOffset(x: -55, y: 16),     // Below, centered
                verticalOffset: TooltipOffset(x: 16, y: -8),
                maxWidth: 140,
                fontSize: 13
            )
        case .timer:
            return TooltipConfiguration(
                text: "Turn timer",
                horizontalOffset: TooltipOffset(x: -30, y: 16),     // Below, centered
                verticalOffset: TooltipOffset(x: 16, y: 0),
                maxWidth: 100,
                fontSize: 13
            )
        }
    }
    
    // MARK: - macOS Landscape Configurations
    private static func macOSLandscapeConfiguration(for elementType: DiscardElementType) -> TooltipConfiguration {
        switch elementType {
        case .lastDiscard:
            return TooltipConfiguration(
                text: "Most recent card discarded",
                horizontalOffset: TooltipOffset(x: -70, y: 18),     // Below, centered
                verticalOffset: TooltipOffset(x: 18, y: -14),       // Right, top-aligned
                maxWidth: 180,
                fontSize: 14
            )
        case .lastPlayer:
            return TooltipConfiguration(
                text: "Previous player",
                horizontalOffset: TooltipOffset(x: -50, y: 18),     // Below, centered
                verticalOffset: TooltipOffset(x: 18, y: -10),
                maxWidth: 140,
                fontSize: 14
            )
        case .nextPlayer:
            return TooltipConfiguration(
                text: "Next player",
                horizontalOffset: TooltipOffset(x: -40, y: 18),     // Below, centered
                verticalOffset: TooltipOffset(x: 18, y: -10),
                maxWidth: 140,
                fontSize: 14
            )
        case .score:
            return TooltipConfiguration(
                text: "Current game score",
                horizontalOffset: TooltipOffset(x: -65, y: 18),     // Below, centered
                verticalOffset: TooltipOffset(x: 18, y: -10),
                maxWidth: 160,
                fontSize: 14
            )
        case .timer:
            return TooltipConfiguration(
                text: "Turn timer",
                horizontalOffset: TooltipOffset(x: -35, y: 18),     // Below, centered
                verticalOffset: TooltipOffset(x: 18, y: 0),
                maxWidth: 110,
                fontSize: 14
            )
        }
    }
    
    // MARK: - Default/Fallback Configuration
    private static func defaultConfiguration(for elementType: DiscardElementType) -> TooltipConfiguration {
        switch elementType {
        case .lastDiscard:
            return TooltipConfiguration(
                text: "Most recent card discarded",
                horizontalOffset: .belowCenter,
                verticalOffset: .rightCenter
            )
        case .lastPlayer:
            return TooltipConfiguration(
                text: "Previous player",
                horizontalOffset: .belowCenter,
                verticalOffset: .rightCenter
            )
        case .nextPlayer:
            return TooltipConfiguration(
                text: "Next player",
                horizontalOffset: .belowCenter,
                verticalOffset: .rightCenter
            )
        case .score:
            return TooltipConfiguration(
                text: "Current game score",
                horizontalOffset: .belowCenter,
                verticalOffset: .rightCenter
            )
        case .timer:
            return TooltipConfiguration(
                text: "Turn timer",
                horizontalOffset: .belowCenter,
                verticalOffset: .rightCenter
            )
        }
    }
}

// MARK: - Enhanced Tooltip View
struct EnhancedTooltipView: View {
    let configuration: TooltipConfiguration
    let isVisible: Bool
    
    var body: some View {
        if isVisible && configuration.enabled {
            Group {
                if let maxWidth = configuration.maxWidth {
                    Text(configuration.text)
                        .font(.system(size: configuration.fontSize))
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: maxWidth)
                } else {
                    Text(configuration.text)
                        .font(.system(size: configuration.fontSize))
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(configuration.backgroundOpacity))
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            )
            .foregroundColor(.white)
        }
    }
}
