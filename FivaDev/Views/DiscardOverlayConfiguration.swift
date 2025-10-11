//
//  DiscardOverlayConfiguration.swift
//  FivaDev
//
//  Revised to match PlayerHandOverlay geometry system with SF Symbol icons
//  Created by Doron Kauper on 9/22/25.
//  Updated: October 11, 2025, Pacific Time
//

import SwiftUI

// MARK: - Discard Grid Element Types
enum DiscardElementType: String, CaseIterable {
    case lastDiscard = "lastDiscard"
    case lastPlayer = "lastPlayer"
    case nextPlayer = "nextPlayer"
    case score = "score"
    case timer = "timer"
    
    var displayName: String {
        switch self {
        case .lastDiscard: return "Last Discard"
        case .lastPlayer: return "Last Player"
        case .nextPlayer: return "Next Player"
        case .score: return "Score"
        case .timer: return "Timer"
        }
    }
    
    var sfSymbolName: String {
        switch self {
        case .lastDiscard: return "" // No icon, shows card
        case .lastPlayer: return "figure.walk.departure"
        case .nextPlayer: return "figure.walk.arrival"
        case .score: return "list.number"
        case .timer: return "timer"
        }
    }
    
    var tooltip: String {
        switch self {
        case .lastDiscard: return "Last Discard"
        case .lastPlayer: return "Last Player"
        case .nextPlayer: return "Next Player"
        case .score: return "Score" // Will append gameScore dynamically
        case .timer: return "" // Will append seconds from press dynamically
        }
    }
}

// MARK: - SF Symbol Rendering Mode
enum SFSymbolRenderingMode {
    case palette(primary: Color, secondary: Color, tertiary: Color?)
    case monochrome(color: Color)
    
    // Team colors for palette mode
    static func teamPalette(teamIndex: Int) -> SFSymbolRenderingMode {
        switch teamIndex {
        case 0: // Team 1 - Teal
            return .palette(primary: .teal, secondary: .red, tertiary: nil)
        case 1: // Team 2 - Red
            return .palette(primary: .red, secondary: .teal, tertiary: nil)
        default: // Fallback
            return .palette(primary: .gray, secondary: .gray, tertiary: nil)
        }
    }
}

// MARK: - Enhanced Element Content Type
enum ElementContentType {
    case card(placeholder: PlayingCardData?) // Playing card image with optional placeholder
    case sfSymbol(name: String, rendering: SFSymbolRenderingMode)
    case text(content: String)
    case dynamic // Content determined at runtime
}

// MARK: - Grid Element Layout
struct DiscardElementLayout {
    // Position as percentages of the overlay area (not body area)
    let topPadding: CGFloat      // % from top of overlay area
    let bottomPadding: CGFloat   // % from bottom of overlay area
    let leftPadding: CGFloat     // % from left of overlay area
    let rightPadding: CGFloat    // % from right of overlay area
    
    // Visual properties
    let isVisible: Bool          // Whether this element should be shown
    let priority: Int            // Drawing order (higher = on top)
    
    // Content type
    let contentType: ElementContentType
    
    // MARK: - Safe computed properties with bounds checking
    func topValue(_ overlayHeight: CGFloat) -> CGFloat {
        return max(0, min(topPadding * overlayHeight, overlayHeight))
    }
    
    func bottomValue(_ overlayHeight: CGFloat) -> CGFloat {
        return max(0, min(bottomPadding * overlayHeight, overlayHeight))
    }
    
    func leftValue(_ overlayWidth: CGFloat) -> CGFloat {
        return max(0, min(leftPadding * overlayWidth, overlayWidth))
    }
    
    func rightValue(_ overlayWidth: CGFloat) -> CGFloat {
        return max(0, min(rightPadding * overlayWidth, overlayWidth))
    }
    
    func elementWidth(_ overlayWidth: CGFloat) -> CGFloat {
        let left = leftValue(overlayWidth)
        let right = rightValue(overlayWidth)
        return max(0, overlayWidth - left - right)
    }
    
    func elementHeight(_ overlayHeight: CGFloat) -> CGFloat {
        let top = topValue(overlayHeight)
        let bottom = bottomValue(overlayHeight)
        return max(0, overlayHeight - top - bottom)
    }
}

// MARK: - Unified Discard Overlay Configuration
struct DiscardOverlayConfiguration {
    // MARK: - Overlay Positioning (relative to body area)
    let overlayPosition: OverlayPosition
    
    // MARK: - Grid Configuration
    let gridPadding: CGFloat                                    // Padding within overlay (0 = no padding)
    let elements: [DiscardElementType: DiscardElementLayout]    // Individual element configurations
    
    // MARK: - Device-Specific Configurations
    static func current(for deviceType: DeviceType, orientation: AppOrientation) -> DiscardOverlayConfiguration {
        switch (deviceType, orientation) {
        case (.iPhone, .portrait):
            return iPhonePortraitConfiguration()
        case (.iPhone, .landscape):
            return iPhoneLandscapeConfiguration()
        case (.iPad, .portrait):
            return iPadPortraitConfiguration()
        case (.iPad, .landscape):
            return iPadLandscapeConfiguration()
        case (.mac, .landscape):
            return macOSLandscapeConfiguration()
        default:
            return iPhonePortraitConfiguration()
        }
    }

    // MARK: - iPhone Portrait Configuration
    private static func iPhonePortraitConfiguration() -> DiscardOverlayConfiguration {
        return DiscardOverlayConfiguration(
            overlayPosition: OverlayPosition(
                topPadding: 0.016,      // 1.6% padding from top of BodyView
                bottomPadding: 0.89,    // 89% padding from bottom of BodyView
                leftPadding: 0.02,      // 2% padding from left side of BodyView
                rightPadding: 0.02      // 2% padding from right side of BodyView
            ),
            gridPadding: 0.02,  // 2% internal padding
            elements: [
                .lastDiscard: DiscardElementLayout(
                    topPadding: 0.06,       // 6% from top of overlay
                    bottomPadding: 0.065,   // 6.5% from bottom of overlay
                    leftPadding: 0.02,      // 2% from left of overlay
                    rightPadding: 0.82,     // 82% from right of overlay (leftmost card)
                    isVisible: true,
                    priority: 1,
                    contentType: .card(placeholder: PlayingCardData(suit: .hearts, rank: .king, isJoker: false, jokerColor: nil))
                ),
                .lastPlayer: DiscardElementLayout(
                    topPadding: 0.08,       // 8% from top of overlay
                    bottomPadding: 0.08,    // 8% from bottom of overlay
                    leftPadding: 0.197,     // 19.7% from left of overlay
                    rightPadding: 0.653,    // 65.3% from right of overlay
                    isVisible: true,
                    priority: 2,
                    contentType: .sfSymbol(name: "figure.walk.departure", rendering: .teamPalette(teamIndex: 0))
                ),
                .nextPlayer: DiscardElementLayout(
                    topPadding: 0.08,       // 8% from top of overlay
                    bottomPadding: 0.08,    // 8% from bottom of overlay
                    leftPadding: 0.35,      // 35% from left of overlay
                    rightPadding: 0.5,      // 50% from right of overlay
                    isVisible: true,
                    priority: 3,
                    contentType: .sfSymbol(name: "figure.walk.arrival", rendering: .teamPalette(teamIndex: 1))
                ),
                .score: DiscardElementLayout(
                    topPadding: 0.08,       // 8% from top of overlay
                    bottomPadding: 0.08,    // 8% from bottom of overlay
                    leftPadding: 0.503,     // 50.3% from left of overlay
                    rightPadding: 0.347,    // 34.7% from right of overlay
                    isVisible: true,
                    priority: 4,
                    contentType: .sfSymbol(name: "list.number", rendering: .teamPalette(teamIndex: 0))
                ),
                .timer: DiscardElementLayout(
                    topPadding: 0.08,       // 8% from top of overlay
                    bottomPadding: 0.08,    // 8% from bottom of overlay
                    leftPadding: 0.85,      // 85% from left of overlay
                    rightPadding: 0.02,     // 2% from right of overlay (rightmost icon)
                    isVisible: true,
                    priority: 5,
                    contentType: .sfSymbol(name: "timer", rendering: .teamPalette(teamIndex: 0))
                )
            ]
        )
    }
    
    // MARK: - iPhone Landscape Configuration
    private static func iPhoneLandscapeConfiguration() -> DiscardOverlayConfiguration {
        return DiscardOverlayConfiguration(
            overlayPosition: OverlayPosition(
                topPadding: 0.04,       // 4% padding from top of BodyView
                bottomPadding: 0.015,   // 1.5% padding from bottom of BodyView
                leftPadding: 0.033,     // 3.3% padding from left side of BodyView
                rightPadding: 0.86      // 86% padding from right side of BodyView
            ),
            gridPadding: 0.02,  // 2% internal padding
            elements: [
                .lastDiscard: DiscardElementLayout(
                    topPadding: 0.015,      // 1.5% from top of overlay (top card)
                    bottomPadding: 0.81,    // 81% from bottom of overlay
                    leftPadding: 0.22,      // 22% from left of overlay
                    rightPadding: 0.19,     // 19% from right of overlay
                    isVisible: true,
                    priority: 1,
                    contentType: .card(placeholder: PlayingCardData(suit: .hearts, rank: .king, isJoker: false, jokerColor: nil))
                ),
                .lastPlayer: DiscardElementLayout(
                    topPadding: 0.215,      // 21.5% from top of overlay
                    bottomPadding: 0.605,   // 60.5% from bottom of overlay
                    leftPadding: 0.275,     // 27.5% from left of overlay
                    rightPadding: 0.225,    // 22.5% from right of overlay
                    isVisible: true,
                    priority: 2,
                    contentType: .sfSymbol(name: "figure.walk.departure", rendering: .teamPalette(teamIndex: 0))
                ),
                .nextPlayer: DiscardElementLayout(
                    topPadding: 0.415,      // 41.5% from top of overlay
                    bottomPadding: 0.5,     // 50% from bottom of overlay
                    leftPadding: 0.072,     // 7.2% from left of overlay
                    rightPadding: 0.03,     // 3% from right of overlay
                    isVisible: true,
                    priority: 3,
                    contentType: .sfSymbol(name: "figure.walk.arrival", rendering: .teamPalette(teamIndex: 1))
                ),
                .score: DiscardElementLayout(
                    topPadding: 0.62,       // 62% from top of overlay
                    bottomPadding: 0.21,    // 21% from bottom of overlay
                    leftPadding: 0.275,     // 27.5% from left of overlay
                    rightPadding: 0.225,    // 22.5% from right of overlay
                    isVisible: true,
                    priority: 4,
                    contentType: .sfSymbol(name: "list.number", rendering: .teamPalette(teamIndex: 0))
                ),
                .timer: DiscardElementLayout(
                    topPadding: 0.817,      // 81.7% from top of overlay (bottom icon)
                    bottomPadding: 0.006,   // 0.6% from bottom of overlay
                    leftPadding: 0.22,      // 22% from left of overlay
                    rightPadding: 0.19,     // 19% from right of overlay
                    isVisible: true,
                    priority: 5,
                    contentType: .sfSymbol(name: "timer", rendering: .teamPalette(teamIndex: 0))
                )
            ]
        )
    }
    
    // MARK: - iPad Portrait Configuration
    private static func iPadPortraitConfiguration() -> DiscardOverlayConfiguration {
        return DiscardOverlayConfiguration(
            overlayPosition: OverlayPosition(
                topPadding: 0.2,        // 10% padding from top of BodyView
                bottomPadding: 0.2,    // 8% padding from bottom of BodyView
                leftPadding: 0.02,      // 2% padding from left side of BodyView
                rightPadding: 0.89      // 89% padding from right side of BodyView
            ),
            gridPadding: 0.02,  // 5% internal padding
            elements: [
                .lastDiscard: DiscardElementLayout(
                    topPadding: 0.03,       // 3% from top of overlay (top card)
                    bottomPadding: 0.81,    // 81% from bottom of overlay
                    leftPadding: 0.075,     // 7.5% from left of overlay
                    rightPadding: 0.0,      // 0% from right of overlay
                    isVisible: true,
                    priority: 1,
                    contentType: .card(placeholder: PlayingCardData(suit: .hearts, rank: .king, isJoker: false, jokerColor: nil))
                ),
                .lastPlayer: DiscardElementLayout(
                    topPadding: 0.24,       // 24% from top of overlay
                    bottomPadding: 0.63,    // 63% from bottom of overlay
                    leftPadding: 0.1,       // 10% from left of overlay
                    rightPadding: 0.0,      // 0% from right of overlay
                    isVisible: true,
                    priority: 2,
                    contentType: .sfSymbol(name: "figure.walk.departure", rendering: .teamPalette(teamIndex: 0))
                ),
                .nextPlayer: DiscardElementLayout(
                    topPadding: 0.44,       // 44% from top of overlay
                    bottomPadding: 0.43,    // 43% from bottom of overlay
                    leftPadding: 0.1,       // 10% from left of overlay
                    rightPadding: 0.0,      // 0% from right of overlay
                    isVisible: true,
                    priority: 3,
                    contentType: .sfSymbol(name: "figure.walk.arrival", rendering: .teamPalette(teamIndex: 1))
                ),
                .score: DiscardElementLayout(
                    topPadding: 0.64,       // 64% from top of overlay
                    bottomPadding: 0.23,    // 23% from bottom of overlay
                    leftPadding: 0.1,       // 10% from left of overlay
                    rightPadding: 0.0,      // 0% from right of overlay
                    isVisible: true,
                    priority: 4,
                    contentType: .sfSymbol(name: "list.number", rendering: .teamPalette(teamIndex: 0))
                ),
                .timer: DiscardElementLayout(
                    topPadding: 0.84,       // 84% from top of overlay (bottom icon)
                    bottomPadding: 0.03,    // 3% from bottom of overlay
                    leftPadding: 0.1,       // 10% from left of overlay
                    rightPadding: 0.0,      // 0% from right of overlay
                    isVisible: true,
                    priority: 5,
                    contentType: .sfSymbol(name: "timer", rendering: .teamPalette(teamIndex: 0))
                )
            ]
        )
    }
    
    // MARK: - iPad Landscape Configuration
    private static func iPadLandscapeConfiguration() -> DiscardOverlayConfiguration {
        return DiscardOverlayConfiguration(
            overlayPosition: OverlayPosition(
                topPadding: 0.09,       // 7% padding from top of BodyView
                bottomPadding: 0.09,    // 7% padding from bottom of BodyView
                leftPadding: 0.02,      // 1% padding from left side of BodyView
                rightPadding: 0.92      // 92% padding from right side of BodyView
            ),
            gridPadding: 0.03,  // 3% internal padding
            elements: [
                .lastDiscard: DiscardElementLayout(
                    topPadding: 0.05,       // 5% from top of overlay (top card)
                    bottomPadding: 0.65,    // 65% from bottom of overlay
                    leftPadding: 0.05,      // 5% from left of overlay
                    rightPadding: 0.5,      // 50% from right of overlay
                    isVisible: true,
                    priority: 1,
                    contentType: .card(placeholder: PlayingCardData(suit: .hearts, rank: .king, isJoker: false, jokerColor: nil))
                ),
                .lastPlayer: DiscardElementLayout(
                    topPadding: 0.05,       // 5% from top of overlay
                    bottomPadding: 0.65,    // 65% from bottom of overlay
                    leftPadding: 0.55,      // 55% from left of overlay
                    rightPadding: 0.05,     // 5% from right of overlay
                    isVisible: true,
                    priority: 2,
                    contentType: .sfSymbol(name: "figure.walk.departure", rendering: .teamPalette(teamIndex: 0))
                ),
                .nextPlayer: DiscardElementLayout(
                    topPadding: 0.45,       // 45% from top of overlay
                    bottomPadding: 0.35,    // 35% from bottom of overlay
                    leftPadding: 0.05,      // 5% from left of overlay
                    rightPadding: 0.5,      // 50% from right of overlay
                    isVisible: true,
                    priority: 3,
                    contentType: .sfSymbol(name: "figure.walk.arrival", rendering: .teamPalette(teamIndex: 1))
                ),
                .score: DiscardElementLayout(
                    topPadding: 0.45,       // 45% from top of overlay
                    bottomPadding: 0.35,    // 35% from bottom of overlay
                    leftPadding: 0.55,      // 55% from left of overlay
                    rightPadding: 0.05,     // 5% from right of overlay
                    isVisible: true,
                    priority: 4,
                    contentType: .sfSymbol(name: "list.number", rendering: .teamPalette(teamIndex: 0))
                ),
                .timer: DiscardElementLayout(
                    topPadding: 0.8,        // 80% from top of overlay (bottom icon)
                    bottomPadding: 0.05,    // 5% from bottom of overlay
                    leftPadding: 0.05,      // 5% from left of overlay
                    rightPadding: 0.05,     // 5% from right of overlay (full width)
                    isVisible: true,
                    priority: 5,
                    contentType: .sfSymbol(name: "timer", rendering: .teamPalette(teamIndex: 0))
                )
            ]
        )
    }
    
    // MARK: - macOS Landscape Configuration
    private static func macOSLandscapeConfiguration() -> DiscardOverlayConfiguration {
        return DiscardOverlayConfiguration(
            overlayPosition: OverlayPosition(
                topPadding: 0.06,       // 6% padding from top of BodyView
                bottomPadding: 0.06,    // 6% padding from bottom of BodyView
                leftPadding: 0.02,      // 2% padding from left side of BodyView
                rightPadding: 0.915     // 91.5% padding from right side of BodyView
            ),
            gridPadding: 0.05,  // 5% internal padding
            elements: [
                .lastDiscard: DiscardElementLayout(
                    topPadding: 0.05,       // 5% from top of overlay (top card)
                    bottomPadding: 0.6,     // 60% from bottom of overlay
                    leftPadding: 0.05,      // 5% from left of overlay
                    rightPadding: 0.8,      // 80% from right of overlay
                    isVisible: true,
                    priority: 1,
                    contentType: .card(placeholder: PlayingCardData(suit: .hearts, rank: .king, isJoker: false, jokerColor: nil))
                ),
                .lastPlayer: DiscardElementLayout(
                    topPadding: 0.05,       // 5% from top of overlay
                    bottomPadding: 0.7,     // 70% from bottom of overlay
                    leftPadding: 0.3,       // 30% from left of overlay
                    rightPadding: 0.45,     // 45% from right of overlay
                    isVisible: true,
                    priority: 2,
                    contentType: .sfSymbol(name: "figure.walk.departure", rendering: .teamPalette(teamIndex: 0))
                ),
                .nextPlayer: DiscardElementLayout(
                    topPadding: 0.05,       // 5% from top of overlay
                    bottomPadding: 0.7,     // 70% from bottom of overlay
                    leftPadding: 0.8,       // 80% from left of overlay
                    rightPadding: 0.05,     // 5% from right of overlay
                    isVisible: true,
                    priority: 3,
                    contentType: .sfSymbol(name: "figure.walk.arrival", rendering: .teamPalette(teamIndex: 1))
                ),
                .score: DiscardElementLayout(
                    topPadding: 0.4,        // 40% from top of overlay
                    bottomPadding: 0.35,    // 35% from bottom of overlay
                    leftPadding: 0.05,      // 5% from left of overlay
                    rightPadding: 0.8,      // 80% from right of overlay
                    isVisible: true,
                    priority: 4,
                    contentType: .sfSymbol(name: "list.number", rendering: .teamPalette(teamIndex: 0))
                ),
                .timer: DiscardElementLayout(
                    topPadding: 0.75,       // 75% from top of overlay (bottom)
                    bottomPadding: 0.05,    // 5% from bottom of overlay
                    leftPadding: 0.05,      // 5% from left of overlay
                    rightPadding: 0.05,     // 5% from right of overlay (full width)
                    isVisible: true,
                    priority: 5,
                    contentType: .sfSymbol(name: "timer", rendering: .teamPalette(teamIndex: 0))
                )
            ]
        )
    }
}

// MARK: - Overlay Position Structure
struct OverlayPosition {
    let topPadding: CGFloat      // % from top of body area
    let bottomPadding: CGFloat   // % from bottom of body area
    let leftPadding: CGFloat     // % from left of body area
    let rightPadding: CGFloat    // % from right of body area
    
    // Computed properties for actual values
    func topValue(_ bodyHeight: CGFloat) -> CGFloat {
        return topPadding * bodyHeight
    }
    
    func bottomValue(_ bodyHeight: CGFloat) -> CGFloat {
        return bottomPadding * bodyHeight
    }
    
    func leftValue(_ bodyWidth: CGFloat) -> CGFloat {
        return leftPadding * bodyWidth
    }
    
    func rightValue(_ bodyWidth: CGFloat) -> CGFloat {
        return rightPadding * bodyWidth
    }
    
    func overlayWidth(_ bodyWidth: CGFloat) -> CGFloat {
        return bodyWidth - leftValue(bodyWidth) - rightValue(bodyWidth)
    }
    
    func overlayHeight(_ bodyHeight: CGFloat) -> CGFloat {
        return bodyHeight - topValue(bodyHeight) - bottomValue(bodyHeight)
    }
}

// MARK: - Enhanced Configuration Validation
extension DiscardOverlayConfiguration {
    func validate() -> [String] {
        var issues: [String] = []
        
        if gridPadding < 0 || gridPadding > 0.5 {
            issues.append("Grid padding should be between 0 and 0.5")
        }
        
        // Enhanced element layout validation
        for (elementType, layout) in elements {
            if layout.topPadding + layout.bottomPadding > 1.0 {
                issues.append("\(elementType.displayName): top + bottom padding exceeds 100%")
            }
            
            if layout.leftPadding + layout.rightPadding > 1.0 {
                issues.append("\(elementType.displayName): left + right padding exceeds 100%")
            }
            
            if layout.priority < 0 {
                issues.append("\(elementType.displayName): priority must be non-negative")
            }
            
            // Validate padding ranges
            if layout.topPadding < 0 || layout.topPadding > 1 {
                issues.append("\(elementType.displayName): topPadding must be 0-1")
            }
            if layout.bottomPadding < 0 || layout.bottomPadding > 1 {
                issues.append("\(elementType.displayName): bottomPadding must be 0-1")
            }
            if layout.leftPadding < 0 || layout.leftPadding > 1 {
                issues.append("\(elementType.displayName): leftPadding must be 0-1")
            }
            if layout.rightPadding < 0 || layout.rightPadding > 1 {
                issues.append("\(elementType.displayName): rightPadding must be 0-1")
            }
        }
        
        return issues
    }
    
    // Safe debug information
    func debugInfo() -> String {
        let validation = validate()
        return """
        DiscardOverlayConfiguration Debug:
        - Elements: \(elements.count)
        - Issues: \(validation.isEmpty ? "None" : validation.joined(separator: ", "))
        """
    }
}
