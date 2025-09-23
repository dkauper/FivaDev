//
//  Globals.swift
//  FivaDev
//
//  Cleaned up with Discard Overlay constants moved to unified configuration system
//  Created by Doron Kauper on 9/17/25.
//  Updated: September 22, 2025, 3:50 PM PST
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

// MARK: - Device Type Detection
enum DeviceType {
    case iPhone
    case iPad
    case mac
    case appleTV
    
    static var current: DeviceType {
        #if os(iOS)
        #if canImport(UIKit)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .iPad
        } else {
            return .iPhone
        }
        #else
        return .iPhone // fallback
        #endif
        #elseif os(macOS)
        return .mac
        #elseif os(tvOS)
        return .appleTV
        #else
        return .iPhone // fallback
        #endif
    }
}

// MARK: - Orientation Detection
enum AppOrientation {
    case portrait
    case landscape
    
    static func current(geometry: GeometryProxy) -> AppOrientation {
        return geometry.size.width > geometry.size.height ? .landscape : .portrait
    }
}

// MARK: - Anchor Positions
enum AnchorPosition {
    case topLeft
    case bottomLeft
}

// MARK: - Game State Variables
struct GameState {
    static var numPlayers: Int = 2
    static var numTeams: Int = 2
    static var currentPlayer: Int = 0
    
    // Cards dealt based on player count (from CLAUDE.md section 4)
    static var cardsPerPlayer: Int {
        switch numPlayers {
        case 2: return 7
        case 3, 4: return 6
        case 5, 6: return 5
        case 7, 8, 9: return 4
        case 10, 11, 12: return 3
        default: return 7
        }
    }
}

// MARK: - Overlay Layout Protocol for Future Consistency
protocol OverlayLayoutConstants {
    var topPadding: CGFloat { get }
    var bottomPadding: CGFloat { get }
    var leftPadding: CGFloat { get }
    var rightPadding: CGFloat { get }
    
    func topValue(_ containerHeight: CGFloat) -> CGFloat
    func bottomValue(_ containerHeight: CGFloat) -> CGFloat
    func leftValue(_ containerWidth: CGFloat) -> CGFloat
    func rightValue(_ containerWidth: CGFloat) -> CGFloat
    
    static func current(for deviceType: DeviceType, orientation: AppOrientation) -> Self
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Player Hand Layout Constants (PRESERVED ORIGINAL VALUES)
struct PlayerHandLayoutConstants: OverlayLayoutConstants {
    let topPadding: CGFloat      // Previously: playerHandTop
    let bottomPadding: CGFloat   // Previously: playerHandBottom
    let leftPadding: CGFloat     // Previously: playerHandLeft
    let rightPadding: CGFloat    // Previously: playerHandRight
    
    // Protocol implementation - new standardized methods
    func topValue(_ containerHeight: CGFloat) -> CGFloat {
        return topPadding * containerHeight
    }
    
    func bottomValue(_ containerHeight: CGFloat) -> CGFloat {
        return bottomPadding * containerHeight
    }
    
    func leftValue(_ containerWidth: CGFloat) -> CGFloat {
        return leftPadding * containerWidth
    }
    
    func rightValue(_ containerWidth: CGFloat) -> CGFloat {
        return rightPadding * containerWidth
    }
    
    // Convenience methods for overlay dimensions
    func overlayWidth(_ bodyWidth: CGFloat) -> CGFloat {
        return bodyWidth - leftValue(bodyWidth) - rightValue(bodyWidth)
    }
    
    func overlayHeight(_ bodyHeight: CGFloat) -> CGFloat {
        return bodyHeight - topValue(bodyHeight) - bottomValue(bodyHeight)
    }
    
    // EXACT ORIGINAL VALUES FROM YOUR WORKING IMPLEMENTATION
    static func current(for deviceType: DeviceType, orientation: AppOrientation) -> PlayerHandLayoutConstants {
        switch (deviceType, orientation) {
        case (.iPhone, .portrait):
            return PlayerHandLayoutConstants(
                topPadding: 0.9,      // 89% padding from top of BodyView
                bottomPadding: 0.0,   // 1% padding from bottom of BodyView
                leftPadding: 0.02,     // 2% padding from left side of BodyView
                rightPadding: 0.02     // 2% padding from right side of BodyView
            )
        case (.iPhone, .landscape):
            return PlayerHandLayoutConstants(
                topPadding: 0.05,      // 5% padding from top of BodyView
                bottomPadding: 0.0,    // 0% padding from bottom of BodyView
                leftPadding: 0.85,     // 85% padding from left side of BodyView
                rightPadding: 0.0      // 0% padding from right side of BodyView
            )
        case (.iPad, .portrait):
            return PlayerHandLayoutConstants(
                topPadding: 0.1,       // 10% padding from top of BodyView
                bottomPadding: 0.1,    // 10% padding from bottom of BodyView
                leftPadding: 0.87,     // 87% padding from left side of BodyView
                rightPadding: 0.03     // 3% padding from right side of BodyView
            )
        case (.iPad, .landscape):
            return PlayerHandLayoutConstants(
                topPadding: 0.07,      // 5% padding from top of BodyView
                bottomPadding: 0.07,   // 5% padding from bottom of BodyView
                leftPadding: 0.92,     // 5% padding from left side of BodyView
                rightPadding: 0.01     // 25% padding from right side of BodyView
            )
        case (.mac, .landscape):
            return PlayerHandLayoutConstants(
                topPadding: 0.06,      // 5% padding from top of BodyView
                bottomPadding: 0.06,   // 5% padding from bottom of BodyView
                leftPadding: 0.915,    // 5% padding from left side of BodyView
                rightPadding: 0.02     // 55% padding from right side of BodyView
            )
        case (.appleTV, .landscape):
            return PlayerHandLayoutConstants(
                topPadding: 0.08,      // 8% padding from top of BodyView
                bottomPadding: 0.0,    // 8% padding from bottom of BodyView
                leftPadding: 0.9,      // 5% padding from left side of BodyView
                rightPadding: 0.02     // 20% padding from right side of BodyView
            )
        default:
            return PlayerHandLayoutConstants(
                topPadding: 0.10,
                bottomPadding: 0.15,
                leftPadding: 0.05,
                rightPadding: 0.05
            )
        }
    }
    
    // Legacy method names for backward compatibility (if needed)
    func playerHandTopValue(_ bodyHeight: CGFloat) -> CGFloat {
        return topValue(bodyHeight)
    }
    
    func playerHandBottomValue(_ bodyHeight: CGFloat) -> CGFloat {
        return bottomValue(bodyHeight)
    }
    
    func playerHandLeftValue(_ bodyWidth: CGFloat) -> CGFloat {
        return leftValue(bodyWidth)
    }
    
    func playerHandRightValue(_ bodyWidth: CGFloat) -> CGFloat {
        return rightValue(bodyWidth)
    }
}

// MARK: - Global Layout Constants (PRESERVED ALL ORIGINAL VALUES)
struct GlobalLayoutConstants {
    let deviceLength: CGFloat
    let deviceWidth: CGFloat
    
    let headerHeight: CGFloat
    let headerWidth: CGFloat
    let bodyHeight: CGFloat
    let bodyWidth: CGFloat
    
    let gameBoardTopPadding: CGFloat
    let gameBoardLeftPadding: CGFloat
    let gameBoardBottomPadding: CGFloat
    let gameBoardRightPadding: CGFloat
    let gameBoardAnchor: AnchorPosition
    let gridAnchor: AnchorPosition
    
    // Computed properties for actual values
    func headerHeightValue(_ screenHeight: CGFloat) -> CGFloat {
        return headerHeight * screenHeight
    }
    
    func headerWidthValue(_ screenWidth: CGFloat) -> CGFloat {
        return headerWidth * screenWidth
    }
    
    func bodyHeightValue(_ screenHeight: CGFloat) -> CGFloat {
        return screenHeight - headerHeightValue(screenHeight)
    }
    
    func bodyWidthValue(_ screenWidth: CGFloat) -> CGFloat {
        return bodyWidth * screenWidth
    }
    
    func gameBoardTopPaddingValue(_ bodyHeight: CGFloat) -> CGFloat {
        return gameBoardTopPadding * bodyHeight
    }
    
    func gameBoardLeftPaddingValue(_ bodyWidth: CGFloat) -> CGFloat {
        return gameBoardLeftPadding * bodyWidth
    }
    
    func gameBoardBottomPaddingValue(_ bodyHeight: CGFloat) -> CGFloat {
        return gameBoardBottomPadding * bodyHeight
    }
    
    func gameBoardRightPaddingValue(_ bodyWidth: CGFloat) -> CGFloat {
        return gameBoardRightPadding * bodyWidth
    }
    
    static func current(for deviceType: DeviceType, orientation: AppOrientation) -> GlobalLayoutConstants {
        switch (deviceType, orientation) {
        case (.iPhone, .portrait):
            return iOSPortraitConstants()
        case (.iPhone, .landscape):
            return iOSLandscapeConstants()
        case (.iPad, .portrait):
            return iPadOSPortraitConstants()
        case (.iPad, .landscape):
            return iPadOSLandscapeConstants()
        case (.mac, .landscape):
            return macOSLandscapeConstants()
        case (.appleTV, .landscape):
            return appleTVLandscapeConstants()
        default:
            return iOSPortraitConstants() // fallback
        }
    }
    
    // MARK: - iOS Portrait Constants (PRESERVED ORIGINAL VALUES)
    private static func iOSPortraitConstants() -> GlobalLayoutConstants {
        return GlobalLayoutConstants(
            deviceLength: 0, // Will be set dynamically
            deviceWidth: 0,  // Will be set dynamically
            headerHeight: 0.05,          // 8% of device length
            headerWidth: 1.0,            // 100% of device width
            bodyHeight: 0.88,            // Calculated: device height minus header height
            bodyWidth: 1.0,              // 100% of device width
            gameBoardTopPadding: 0.12,  // 12.5% of body height
            gameBoardLeftPadding: 0.01,  // 5% of body width
            gameBoardBottomPadding: 0.125, // 12.5% of body height
            gameBoardRightPadding: 0.01, // 5% of body width
            gameBoardAnchor: .topLeft,
            gridAnchor: .topLeft
        )
    }
    
    // MARK: - iOS Landscape Constants (PRESERVED ORIGINAL VALUES)
    private static func iOSLandscapeConstants() -> GlobalLayoutConstants {
        return GlobalLayoutConstants(
            deviceLength: 0, // Will be set dynamically
            deviceWidth: 0,  // Will be set dynamically
            headerHeight: 0.08,          // 15% of device length
            headerWidth: 1.0,            // 100% of device width
            bodyHeight: 0.9,            // Calculated: device height minus header height
            bodyWidth: 1.0,              // 100% of device width
            gameBoardTopPadding: 0.01,   // 5% of body height
            gameBoardLeftPadding: 0.17,   // 20% of body width
            gameBoardBottomPadding: 0.0, // 0% of body height
            gameBoardRightPadding: 0.17,  // 20% of body width
            gameBoardAnchor: .bottomLeft,
            gridAnchor: .bottomLeft
        )
    }
    
    // MARK: - iPadOS Portrait Constants (PRESERVED ORIGINAL VALUES)
    private static func iPadOSPortraitConstants() -> GlobalLayoutConstants {
        return GlobalLayoutConstants(
            deviceLength: 0, // Will be set dynamically
            deviceWidth: 0,  // Will be set dynamically
            headerHeight: 0.05,          // 8% of device length
            headerWidth: 1.0,            // 100% of device width
            bodyHeight: 0.92,            // Calculated: device height minus header height
            bodyWidth: 1.0,              // 100% of device width
            gameBoardTopPadding: 0.1,   // 6% of body height (your adjustment)
            gameBoardLeftPadding: 0.15,  // 15% of body width
            gameBoardBottomPadding: 0.1, // 6% of body height (your adjustment)
            gameBoardRightPadding: 0.15, // 15% of body width
            gameBoardAnchor: .topLeft,
            gridAnchor: .topLeft
        )
    }
    
    // MARK: - iPadOS Landscape Constants (PRESERVED ORIGINAL VALUES)
    private static func iPadOSLandscapeConstants() -> GlobalLayoutConstants {
        return GlobalLayoutConstants(
            deviceLength: 0, // Will be set dynamically
            deviceWidth: 0,  // Will be set dynamically
            headerHeight: 0.05,          // 10% of device length
            headerWidth: 1.0,            // 100% of device width
            bodyHeight: 0.95,            // Calculated: device height minus header height
            bodyWidth: 1.0,              // 100% of device width
            gameBoardTopPadding: 0.05,   // 10% of body height
            gameBoardLeftPadding: 0.088,  // 20% of body width
            gameBoardBottomPadding: 0.05, // 10% of body height
            gameBoardRightPadding: 0.088, // 20% of body width
            gameBoardAnchor: .bottomLeft,
            gridAnchor: .bottomLeft
        )
    }
    
    // MARK: - macOS Landscape Constants (PRESERVED ORIGINAL VALUES)
    private static func macOSLandscapeConstants() -> GlobalLayoutConstants {
        return GlobalLayoutConstants(
            deviceLength: 0, // Will be set dynamically
            deviceWidth: 0,  // Will be set dynamically
            headerHeight: 0.08,          // 8% of device length
            headerWidth: 1.0,            // 100% of device width
            bodyHeight: 0.92,            // Calculated: device height minus header height
            bodyWidth: 1.0,              // 100% of device width
            gameBoardTopPadding: 0.03,   // 3% of body height
            gameBoardLeftPadding: 0.5,   // 50% of body width
            gameBoardBottomPadding: 0.03, // 3% of body height
            gameBoardRightPadding: 0.5,  // 50% of body width
            gameBoardAnchor: .bottomLeft,
            gridAnchor: .bottomLeft
        )
    }
    
    // MARK: - Apple TV Landscape Constants (PRESERVED ORIGINAL VALUES)
    private static func appleTVLandscapeConstants() -> GlobalLayoutConstants {
        return GlobalLayoutConstants(
            deviceLength: 0, // Will be set dynamically
            deviceWidth: 0,  // Will be set dynamically
            headerHeight: 0.01,          // 1% of device length
            headerWidth: 1.0,            // 100% of device width
            bodyHeight: 0.85,            // Calculated: device height minus header height
            bodyWidth: 1.0,              // 100% of device width
            gameBoardTopPadding: 0.09,   // 9% of body height
            gameBoardLeftPadding: 0.14,  // 14% of body width
            gameBoardBottomPadding: 0.01, // 1% of body height
            gameBoardRightPadding: 0.14, // 14% of body width
            gameBoardAnchor: .bottomLeft,
            gridAnchor: .bottomLeft
        )
    }
}

// MARK: - Glass Effect View Modifier (UNCHANGED)
struct GlassEffect: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func glassEffect() -> some View {
        modifier(GlassEffect())
    }
}

// MARK: - Color Extension for Hex Colors (UNCHANGED)
extension Color {
    init(hex: String) {
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
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - IMPORTANT NOTE
/*
 The DiscardOverlayLayoutConstants struct has been REMOVED from this file.
 
 All discard overlay positioning and grid configuration is now handled by the
 unified DiscardOverlayConfiguration system in DiscardOverlayConfiguration.swift.
 
 This change:
 - Consolidates all discard overlay logic in one place
 - Provides better control over grid sections and element positioning
 - Adds support for rotation and content types
 - Improves maintainability and reduces code duplication
 
 If you need to adjust discard overlay positioning or grid layout,
 modify the configurations in DiscardOverlayConfiguration.swift instead.
 */
