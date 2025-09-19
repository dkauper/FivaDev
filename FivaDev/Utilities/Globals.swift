//
//  Globals.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/17/25.
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

// MARK: - Player Hand Layout Constants
struct PlayerHandLayoutConstants {
    let playerHandTop: CGFloat
    let playerHandBottom: CGFloat
    let playerHandLeft: CGFloat
    let playerHandRight: CGFloat
    
    static func current(for deviceType: DeviceType, orientation: AppOrientation) -> PlayerHandLayoutConstants {
        switch (deviceType, orientation) {
        case (.iPhone, .portrait):
            return PlayerHandLayoutConstants(
                playerHandTop: 0.89,      // 10% padding from top of BodyView
                playerHandBottom: 0.01,    // 15% padding from bottom of BodyView
                playerHandLeft: 0.02,      // 5% padding from left side of BodyView
                playerHandRight: 0.02      // 5% padding from left side of GameBoard
            )
        case (.iPhone, .landscape):
            return PlayerHandLayoutConstants(
                playerHandTop: 0.05,      // 5% padding from top of BodyView
                playerHandBottom: 0.05,    // 5% padding from bottom of BodyView
                playerHandLeft: 0.05,      // 5% padding from left side of BodyView
                playerHandRight: 0.25      // 25% padding from left side of GameBoard
            )
        case (.iPad, .portrait):
            return PlayerHandLayoutConstants(
                playerHandTop: 0.08,      // 8% padding from top of BodyView
                playerHandBottom: 0.12,    // 12% padding from bottom of BodyView
                playerHandLeft: 0.05,      // 5% padding from left side of BodyView
                playerHandRight: 0.20      // 20% padding from left side of GameBoard
            )
        case (.iPad, .landscape):
            return PlayerHandLayoutConstants(
                playerHandTop: 0.05,      // 5% padding from top of BodyView
                playerHandBottom: 0.05,    // 5% padding from bottom of BodyView
                playerHandLeft: 0.05,      // 5% padding from left side of BodyView
                playerHandRight: 0.25      // 25% padding from left side of GameBoard
            )
        case (.mac, .landscape):
            return PlayerHandLayoutConstants(
                playerHandTop: 0.05,      // 5% padding from top of BodyView
                playerHandBottom: 0.05,    // 5% padding from bottom of BodyView
                playerHandLeft: 0.05,      // 5% padding from left side of BodyView
                playerHandRight: 0.55      // 55% padding from left side of GameBoard
            )
        case (.appleTV, .landscape):
            return PlayerHandLayoutConstants(
                playerHandTop: 0.08,      // 8% padding from top of BodyView
                playerHandBottom: 0.08,    // 8% padding from bottom of BodyView
                playerHandLeft: 0.05,      // 5% padding from left side of BodyView
                playerHandRight: 0.20      // 20% padding from left side of GameBoard
            )
        default:
            return PlayerHandLayoutConstants(
                playerHandTop: 0.10,
                playerHandBottom: 0.15,
                playerHandLeft: 0.05,
                playerHandRight: 0.05
            )
        }
    }
    
    func playerHandTopValue(_ bodyHeight: CGFloat) -> CGFloat {
        return playerHandTop * bodyHeight
    }
    
    func playerHandBottomValue(_ bodyHeight: CGFloat) -> CGFloat {
        return playerHandBottom * bodyHeight
    }
    
    func playerHandLeftValue(_ bodyWidth: CGFloat) -> CGFloat {
        return playerHandLeft * bodyWidth
    }
    
    func playerHandRightValue(_ bodyWidth: CGFloat) -> CGFloat {
        return playerHandRight * bodyWidth
    }
}

// MARK: - Global Layout Constants
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
    
    // MARK: - iOS Portrait Constants
    private static func iOSPortraitConstants() -> GlobalLayoutConstants {
        return GlobalLayoutConstants(
            deviceLength: 0, // Will be set dynamically
            deviceWidth: 0,  // Will be set dynamically
            headerHeight: 0.08,          // 12% of device length
            headerWidth: 1.0,            // 100% of device width
            bodyHeight: 0.88,            // Calculated: device height minus header height
            bodyWidth: 1.0,              // 100% of device width
            gameBoardTopPadding: 0.125,   // 5% of body height
            gameBoardLeftPadding: 0.05,  // 5% of body width
            gameBoardBottomPadding: 0.125, // 5% of body height
            gameBoardRightPadding: 0.05, // 5% of body width
            gameBoardAnchor: .topLeft,
            gridAnchor: .topLeft
        )
    }
    
    // MARK: - iOS Landscape Constants
    private static func iOSLandscapeConstants() -> GlobalLayoutConstants {
        return GlobalLayoutConstants(
            deviceLength: 0, // Will be set dynamically
            deviceWidth: 0,  // Will be set dynamically
            headerHeight: 0.15,          // 15% of device length
            headerWidth: 1.0,            // 100% of device width
            bodyHeight: 0.85,            // Calculated: device height minus header height
            bodyWidth: 1.0,              // 100% of device width
            gameBoardTopPadding: 0.05,   // 8% of body height
            gameBoardLeftPadding: 0.2,  // 15% of body width
            gameBoardBottomPadding: 0.0, // 8% of body height
            gameBoardRightPadding: 0.2, // 15% of body width
            gameBoardAnchor: .bottomLeft,
            gridAnchor: .bottomLeft
        )
    }
    
    // MARK: - iPadOS Portrait Constants
    private static func iPadOSPortraitConstants() -> GlobalLayoutConstants {
        return GlobalLayoutConstants(
            deviceLength: 0, // Will be set dynamically
            deviceWidth: 0,  // Will be set dynamically
            headerHeight: 0.08,          // 8% of device length
            headerWidth: 1.0,            // 100% of device width
            bodyHeight: 0.92,            // Calculated: device height minus header height
            bodyWidth: 1.0,              // 100% of device width
            gameBoardTopPadding: 0.08,   // 8% of body height
            gameBoardLeftPadding: 0.15,  // 15% of body width
            gameBoardBottomPadding: 0.08, // 8% of body height
            gameBoardRightPadding: 0.15, // 15% of body width
            gameBoardAnchor: .topLeft,
            gridAnchor: .topLeft
        )
    }
    
    // MARK: - iPadOS Landscape Constants
    private static func iPadOSLandscapeConstants() -> GlobalLayoutConstants {
        return GlobalLayoutConstants(
            deviceLength: 0, // Will be set dynamically
            deviceWidth: 0,  // Will be set dynamically
            headerHeight: 0.10,          // 10% of device length
            headerWidth: 1.0,            // 100% of device width
            bodyHeight: 0.90,            // Calculated: device height minus header height
            bodyWidth: 1.0,              // 100% of device width
            gameBoardTopPadding: 0.10,   // 10% of body height
            gameBoardLeftPadding: 0.20,  // 20% of body width
            gameBoardBottomPadding: 0.10, // 10% of body height
            gameBoardRightPadding: 0.20, // 20% of body width
            gameBoardAnchor: .bottomLeft,
            gridAnchor: .bottomLeft
        )
    }
    
    // MARK: - macOS Landscape Constants
    private static func macOSLandscapeConstants() -> GlobalLayoutConstants {
        return GlobalLayoutConstants(
            deviceLength: 0, // Will be set dynamically
            deviceWidth: 0,  // Will be set dynamically
            headerHeight: 0.08,          // 8% of device length
            headerWidth: 1.0,            // 100% of device width
            bodyHeight: 0.92,            // Calculated: device height minus header height
            bodyWidth: 1.0,              // 100% of device width
            gameBoardTopPadding: 0.03,   // 12% of body height
            gameBoardLeftPadding: 0.5,  // 25% of body width
            gameBoardBottomPadding: 0.03, // 12% of body height
            gameBoardRightPadding: 0.5, // 25% of body width
            gameBoardAnchor: .bottomLeft,
            gridAnchor: .bottomLeft
        )
    }
    
    // MARK: - Apple TV Landscape Constants
    private static func appleTVLandscapeConstants() -> GlobalLayoutConstants {
        return GlobalLayoutConstants(
            deviceLength: 0, // Will be set dynamically
            deviceWidth: 0,  // Will be set dynamically
            headerHeight: 0.01,          // 12% of device length
            headerWidth: 1.0,            // 100% of device width
            bodyHeight: 0.85,            // Calculated: device height minus header height
            bodyWidth: 1.0,              // 100% of device width
            gameBoardTopPadding: 0.09,   // 15% of body height
            gameBoardLeftPadding: 0.14,  // 20% of body width
            gameBoardBottomPadding: 0.01, // 15% of body height
            gameBoardRightPadding: 0.14, // 20% of body width
            gameBoardAnchor: .bottomLeft,
            gridAnchor: .bottomLeft
        )
    }
}

// MARK: - Glass Effect View Modifier
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

// MARK: - Color Extension for Hex Colors
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
