//
//  Globals.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/17/25.
//

import SwiftUI
import UIKit

// MARK: - Device Type Detection
enum DeviceType {
    case iPhone
    case iPad
    case mac
    case appleTV
    
    static var current: DeviceType {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .iPad
        } else {
            return .iPhone
        }
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
            headerHeight: 0.12,          // 12% of device length
            headerWidth: 1.0,            // 100% of device width
            bodyHeight: 0.88,            // Calculated: device height minus header height
            bodyWidth: 1.0,              // 100% of device width
            gameBoardTopPadding: 0.05,   // 5% of body height
            gameBoardLeftPadding: 0.05,  // 5% of body width
            gameBoardBottomPadding: 0.05, // 5% of body height
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
            gameBoardTopPadding: 0.08,   // 8% of body height
            gameBoardLeftPadding: 0.15,  // 15% of body width
            gameBoardBottomPadding: 0.08, // 8% of body height
            gameBoardRightPadding: 0.15, // 15% of body width
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
            gameBoardTopPadding: 0.05,   // 10% of body height
            gameBoardLeftPadding: 0.10,  // 20% of body width
            gameBoardBottomPadding: 0.05, // 10% of body height
            gameBoardRightPadding: 0.10, // 20% of body width
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
            gameBoardTopPadding: 0.12,   // 12% of body height
            gameBoardLeftPadding: 0.25,  // 25% of body width
            gameBoardBottomPadding: 0.12, // 12% of body height
            gameBoardRightPadding: 0.25, // 25% of body width
            gameBoardAnchor: .bottomLeft,
            gridAnchor: .bottomLeft
        )
    }
    
    // MARK: - Apple TV Landscape Constants
    private static func appleTVLandscapeConstants() -> GlobalLayoutConstants {
        return GlobalLayoutConstants(
            deviceLength: 0, // Will be set dynamically
            deviceWidth: 0,  // Will be set dynamically
            headerHeight: 0.12,          // 12% of device length
            headerWidth: 1.0,            // 100% of device width
            bodyHeight: 0.88,            // Calculated: device height minus header height
            bodyWidth: 1.0,              // 100% of device width
            gameBoardTopPadding: 0.15,   // 15% of body height
            gameBoardLeftPadding: 0.20,  // 20% of body width
            gameBoardBottomPadding: 0.15, // 15% of body height
            gameBoardRightPadding: 0.20, // 20% of body width
            gameBoardAnchor: .bottomLeft,
            gridAnchor: .bottomLeft
        )
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
