//
//  Globals.swift
//  FivaDev
//
//  Enhanced with Player Hand Card Layout Configuration System
//  Created by Doron Kauper on 9/17/25.
//  Updated: October 10, 2025, 7:01 PM Pacific - Dynamic padding calculations
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

// MARK: - Device Type Detection
enum DeviceType: Hashable {
    case iPhone
    case iPad
    case mac
    
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
        #else
        return .iPhone // fallback
        #endif
    }
}

// MARK: - Orientation Detection
enum AppOrientation: Hashable {
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

// MARK: - Layout Constants
// GameState model now lives in Models/GameState.swift
// Using max expected cards for layout calculations (6 cards for 3-4 player game)
private let maxCardsPerPlayerForLayout: CGFloat = 6.0

// MARK: - Overlay Layout Protocol
protocol OverlayLayoutConstants {
    var topPadding: CGFloat { get }
    var bottomPadding: CGFloat { get }
    var leftPadding: CGFloat { get }
    var rightPadding: CGFloat { get }
    
    func topValue(_ containerHeight: CGFloat) -> CGFloat
    func bottomValue(_ containerHeight: CGFloat) -> CGFloat
    func leftValue(_ containerWidth: CGFloat) -> CGFloat
    func rightValue(_ containerWidth: CGFloat) -> CGFloat
    
    static func current(for deviceType: DeviceType, orientation: AppOrientation, bodyHeight: CGFloat, bodyWidth: CGFloat) -> Self
}

// MARK: - Player Hand Card Layout Constants
struct PlayerHandCardLayoutConstants {
    let overlayPaddingPercent: CGFloat
    let cardSpacingPercent: CGFloat
    let minCardSpacing: CGFloat
    let maxCardSpacing: CGFloat
    let overlayCornerRadiusPercent: CGFloat
    let cardCornerRadiusPercent: CGFloat
    let cardInternalPadding: CGFloat
    
    func overlayPadding(overlayWidth: CGFloat, overlayHeight: CGFloat) -> CGFloat {
        return min(overlayWidth, overlayHeight) * overlayPaddingPercent
    }
    
    func cardSpacing(availableWidth: CGFloat, columns: Int) -> CGFloat {
        let calculatedSpacing = availableWidth * cardSpacingPercent
        return max(minCardSpacing, min(maxCardSpacing, calculatedSpacing))
    }
    
    func overlayCornerRadius(overlayWidth: CGFloat) -> CGFloat {
        return overlayWidth * overlayCornerRadiusPercent
    }
    
    func cardCornerRadius(cardWidth: CGFloat) -> CGFloat {
        return cardWidth * cardCornerRadiusPercent
    }
    
    // OPTIMIZED: Pre-computed cache for O(1) lookup
    private static let layoutCache: [DeviceType: [AppOrientation: PlayerHandCardLayoutConstants]] = [
        .iPhone: [
            .portrait: PlayerHandCardLayoutConstants(
                overlayPaddingPercent: 0.02, cardSpacingPercent: 0.02,
                minCardSpacing: 4, maxCardSpacing: 12,
                overlayCornerRadiusPercent: 0.03, cardCornerRadiusPercent: 0.05,
                cardInternalPadding: 2
            ),
            .landscape: PlayerHandCardLayoutConstants(
                overlayPaddingPercent: 0.025, cardSpacingPercent: 0.07,
                minCardSpacing: 3, maxCardSpacing: 10,
                overlayCornerRadiusPercent: 0.04, cardCornerRadiusPercent: 0.05,
                cardInternalPadding: 1.5
            )
        ],
        .iPad: [
            .portrait: PlayerHandCardLayoutConstants(
                overlayPaddingPercent: 0.03, cardSpacingPercent: 0.015,
                minCardSpacing: 6, maxCardSpacing: 16,
                overlayCornerRadiusPercent: 0.025, cardCornerRadiusPercent: 0.05,
                cardInternalPadding: 3
            ),
            .landscape: PlayerHandCardLayoutConstants(
                overlayPaddingPercent: 0.035, cardSpacingPercent: 0.018,
                minCardSpacing: 6, maxCardSpacing: 18,
                overlayCornerRadiusPercent: 0.03, cardCornerRadiusPercent: 0.05,
                cardInternalPadding: 3
            )
        ],
        .mac: [
            .landscape: PlayerHandCardLayoutConstants(
                overlayPaddingPercent: 0.04, cardSpacingPercent: 0.02,
                minCardSpacing: 8, maxCardSpacing: 20,
                overlayCornerRadiusPercent: 0.025, cardCornerRadiusPercent: 0.05,
                cardInternalPadding: 4
            )
        ]
    ]
    
    static func current(for deviceType: DeviceType, orientation: AppOrientation) -> PlayerHandCardLayoutConstants {
        layoutCache[deviceType]?[orientation] ?? layoutCache[.iPhone]![.portrait]!
    }
}

// MARK: - Player Hand Layout Constants
struct PlayerHandLayoutConstants: OverlayLayoutConstants {
    let topPadding: CGFloat
    let bottomPadding: CGFloat
    let leftPadding: CGFloat
    let rightPadding: CGFloat
    
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
    
    func overlayWidth(_ bodyWidth: CGFloat) -> CGFloat {
        return bodyWidth - leftValue(bodyWidth) - rightValue(bodyWidth)
    }
    
    func overlayHeight(_ bodyHeight: CGFloat) -> CGFloat {
        return bodyHeight - topValue(bodyHeight) - bottomValue(bodyHeight)
    }
    
    // OPTIMIZED: Dynamic calculation cache using closures for computed padding values
    private static let layoutCache: [DeviceType: [AppOrientation: (CGFloat, CGFloat) -> PlayerHandLayoutConstants]] = [
        .iPhone: [
            .portrait: { bodyHeight, bodyWidth in
                let topPadding: CGFloat = 0.89
                let bottomPadding: CGFloat = 0.02
                let cardsPerPlayer = maxCardsPerPlayerForLayout
                
                // Compute left/right padding using formula
                let computedPadding = returnLeftAndRight(
                    bodyHeight: bodyHeight,
                    bodyWidth: bodyWidth,
                    topPadding: topPadding,
                    bottomPadding: bottomPadding,
                    cardsPerPlayer: cardsPerPlayer
                )
                
                return PlayerHandLayoutConstants(
                    topPadding: topPadding,
                    bottomPadding: bottomPadding,
                    leftPadding: computedPadding,
                    rightPadding: computedPadding
                )
            },
            .landscape: { bodyHeight, bodyWidth in
                let leftPadding: CGFloat = 0.92
                let rightPadding: CGFloat = 0.0
                let cardsPerPlayer = maxCardsPerPlayerForLayout
                
                // Compute top/bottom padding using formula
                let computedPadding = returnTopAndBottom(
                    bodyHeight: bodyHeight,
                    bodyWidth: bodyWidth,
                    leftPadding: leftPadding,
                    rightPadding: rightPadding,
                    cardsPerPlayer: cardsPerPlayer
                )
                
                return PlayerHandLayoutConstants(
                    topPadding: computedPadding,
                    bottomPadding: computedPadding,
                    leftPadding: leftPadding,
                    rightPadding: rightPadding
                )
            }
        ],
        .iPad: [
            .portrait: { bodyHeight, bodyWidth in
                let leftPadding: CGFloat = 0.88
                let rightPadding: CGFloat = 0.015
                let cardsPerPlayer = maxCardsPerPlayerForLayout
                
                // Compute top/bottom padding using formula
                let computedPadding = returnTopAndBottom(
                    bodyHeight: bodyHeight,
                    bodyWidth: bodyWidth,
                    leftPadding: leftPadding,
                    rightPadding: rightPadding,
                    cardsPerPlayer: cardsPerPlayer
                )
                
                return PlayerHandLayoutConstants(
                    topPadding: computedPadding,
                    bottomPadding: computedPadding,
                    leftPadding: leftPadding,
                    rightPadding: rightPadding
                )
            },
            .landscape: { bodyHeight, bodyWidth in
                let leftPadding: CGFloat = 0.915
                let rightPadding: CGFloat = 0.015
                let cardsPerPlayer = maxCardsPerPlayerForLayout
                
                // Compute top/bottom padding using formula
                let computedPadding = returnTopAndBottom(
                    bodyHeight: bodyHeight,
                    bodyWidth: bodyWidth,
                    leftPadding: leftPadding,
                    rightPadding: rightPadding,
                    cardsPerPlayer: cardsPerPlayer
                )
                
                return PlayerHandLayoutConstants(
                    topPadding: computedPadding,
                    bottomPadding: computedPadding,
                    leftPadding: leftPadding,
                    rightPadding: rightPadding
                )
            }
        ],
        .mac: [
            .landscape: { bodyHeight, bodyWidth in
                let leftPadding: CGFloat = 0.915
                let rightPadding: CGFloat = 0.02
                let cardsPerPlayer = maxCardsPerPlayerForLayout
                
                // Compute top/bottom padding using formula
                let computedPadding = returnTopAndBottom(
                    bodyHeight: bodyHeight,
                    bodyWidth: bodyWidth,
                    leftPadding: leftPadding,
                    rightPadding: rightPadding,
                    cardsPerPlayer: cardsPerPlayer
                )
                
                return PlayerHandLayoutConstants(
                    topPadding: computedPadding,
                    bottomPadding: computedPadding,
                    leftPadding: leftPadding,
                    rightPadding: rightPadding
                )
            }
        ]
    ]
    
    static func current(
        for deviceType: DeviceType,
        orientation: AppOrientation,
        bodyHeight: CGFloat,
        bodyWidth: CGFloat
    ) -> PlayerHandLayoutConstants {
        if let closure = layoutCache[deviceType]?[orientation] {
            return closure(bodyHeight, bodyWidth)
        }
        // Fallback
        return layoutCache[.iPhone]![.portrait]!(bodyHeight, bodyWidth)
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
    
    // OPTIMIZED: Pre-computed cache for O(1) lookup
    private static let layoutCache: [DeviceType: [AppOrientation: GlobalLayoutConstants]] = [
        .iPhone: [
            .portrait: GlobalLayoutConstants(
                deviceLength: 0, deviceWidth: 0,
                headerHeight: 0.05, headerWidth: 1.0,
                bodyHeight: 0.88, bodyWidth: 1.0,
                gameBoardTopPadding: 0.125, gameBoardLeftPadding: 0.01,
                gameBoardBottomPadding: 0.125, gameBoardRightPadding: 0.01,
                gameBoardAnchor: .topLeft, gridAnchor: .topLeft
            ),
            .landscape: GlobalLayoutConstants(
                deviceLength: 0, deviceWidth: 0,
                headerHeight: 0.08, headerWidth: 1.0,
                bodyHeight: 0.9, bodyWidth: 1.0,
                gameBoardTopPadding: 0.01, gameBoardLeftPadding: 0.15,
                gameBoardBottomPadding: 0.0, gameBoardRightPadding: 0.09,
                gameBoardAnchor: .bottomLeft, gridAnchor: .bottomLeft
            )
        ],
        .iPad: [
            .portrait: GlobalLayoutConstants(
                deviceLength: 0, deviceWidth: 0,
                headerHeight: 0.05, headerWidth: 1.0,
                bodyHeight: 0.95, bodyWidth: 1.0,
                gameBoardTopPadding: 0.03, gameBoardLeftPadding: 0.12,
                gameBoardBottomPadding: 0.03, gameBoardRightPadding: 0.12,
                gameBoardAnchor: .topLeft, gridAnchor: .topLeft
            ),
            .landscape: GlobalLayoutConstants(
                deviceLength: 0, deviceWidth: 0,
                headerHeight: 0.05, headerWidth: 1.0,
                bodyHeight: 0.92, bodyWidth: 1.0,
                gameBoardTopPadding: 0.03, gameBoardLeftPadding: 0.085,
                gameBoardBottomPadding: 0.03, gameBoardRightPadding: 0.085,
                gameBoardAnchor: .bottomLeft, gridAnchor: .bottomLeft
            )
        ],
        .mac: [
            .landscape: GlobalLayoutConstants(
                deviceLength: 0, deviceWidth: 0,
                headerHeight: 0.08, headerWidth: 1.0,
                bodyHeight: 0.92, bodyWidth: 1.0,
                gameBoardTopPadding: 0.04, gameBoardLeftPadding: 0.1,
                gameBoardBottomPadding: 0.04, gameBoardRightPadding: 0.1,
                gameBoardAnchor: .bottomLeft, gridAnchor: .bottomLeft
            )
        ]
    ]
    
    static func current(for deviceType: DeviceType, orientation: AppOrientation) -> GlobalLayoutConstants {
        layoutCache[deviceType]?[orientation] ?? layoutCache[.iPhone]![.portrait]!
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
