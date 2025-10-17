//
//  BodyView.swift
//  FivaDev
//
//  Enhanced with new layout system compatibility
//  Created by Doron Kauper on 9/17/25.
//  Updated: October 12, 2025, 11:59 PM Pacific - Added dead card notification tooltip
//  Updated: October 5, 2025, 2:30 PM Pacific - Digital-optimized layout now default
//  Updated: October 5, 2025, 1:50 PM Pacific - Added TestControlsView for board layout toggle
//  Optimized: October 3, 2025, 4:35 PM Pacific - Removed unused GeometryProxy parameter
//

import SwiftUI

struct BodyView: View {
    let width: CGFloat
    let height: CGFloat
    let layoutConstants: GlobalLayoutConstants
    let orientation: AppOrientation
    
    @EnvironmentObject var gameStateManager: GameStateManager
    
    var body: some View {
        ZStack {
            // Background for body
            Color.clear
            
            // Game Board
            GameBoard(
                bodyWidth: width,
                bodyHeight: height,
                layoutConstants: layoutConstants,
                orientation: orientation
            )
            .environmentObject(gameStateManager)
            
            // Discard Overlay - now self-contained with no extra parameters needed
            DiscardOverlayView(
                bodyWidth: width,
                bodyHeight: height,
                layoutConstants: layoutConstants,
                orientation: orientation
            )
            .environmentObject(gameStateManager)
            
            // Win celebration overlay
            if gameStateManager.showWinOverlay, let winner = gameStateManager.winningTeam {
                WinOverlayView(
                    winningColor: winner,
                    fivaCount: gameStateManager.teamFIVACount[winner] ?? 0,
                    bodyWidth: width,
                    bodyHeight: height,
                    onDismiss: {
                        gameStateManager.dismissWinOverlay()
                    }
                )
                .zIndex(10000)  // Above everything
            }
            
            // Player Hand Overlay - now self-contained with no extra parameters needed
            PlayerHandView(
                bodyWidth: width,
                bodyHeight: height,
                layoutConstants: layoutConstants,
                orientation: orientation
            )
            .environmentObject(gameStateManager)
            
            // Dead Card Notification Tooltip
            if let tooltipContent = gameStateManager.deadCardTooltipContent() {
                CenterTooltipView(
                    content: tooltipContent,
                    style: .emphasized,
                    bodyWidth: width,
                    bodyHeight: height,
                    isVisible: gameStateManager.deadCardNotification != nil
                )
                .allowsHitTesting(false)
            }
            
            // Development Controls (disabled - digital-optimized layout now default)
            // Uncomment to re-enable layout toggle for testing:
//             VStack {
//                 TestControlsView()
//                     .environmentObject(gameStateManager)
//                 Spacer()
//             }
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Enhanced Preview Support
#Preview("iPhone Portrait") {
    GeometryReader { geometry in
        let deviceType = DeviceType.iPhone
        let orientation = AppOrientation.portrait
        let layoutConstants = GlobalLayoutConstants.current(for: deviceType, orientation: orientation)
        let bodyHeight = layoutConstants.bodyHeightValue(geometry.size.height)
        let bodyWidth = layoutConstants.bodyWidthValue(geometry.size.width)
        
        BodyView(
            width: bodyWidth,
            height: bodyHeight,
            layoutConstants: layoutConstants,
            orientation: orientation
        )
        .environmentObject(GameStateManager())
    }
    .background(Color(hex: "B7E4CC"))
}

#Preview("iPad Landscape") {
    GeometryReader { geometry in
        let deviceType = DeviceType.iPad
        let orientation: AppOrientation = .landscape
        let layoutConstants = GlobalLayoutConstants.current(for: deviceType, orientation: orientation)
        let bodyHeight = layoutConstants.bodyHeightValue(geometry.size.height)
        let bodyWidth = layoutConstants.bodyWidthValue(geometry.size.width)
        
        BodyView(
            width: bodyWidth,
            height: bodyHeight,
            layoutConstants: layoutConstants,
            orientation: orientation
        )
        .environmentObject(GameStateManager())
    }
    .background(Color(hex: "B7E4CC"))
}

#Preview("Mac Landscape") {
    GeometryReader { geometry in
        let deviceType = DeviceType.mac
        let orientation: AppOrientation = .landscape
        let layoutConstants = GlobalLayoutConstants.current(for: deviceType, orientation: orientation)
        let bodyHeight = layoutConstants.bodyHeightValue(geometry.size.height)
        let bodyWidth = layoutConstants.bodyWidthValue(geometry.size.width)
        
        BodyView(
            width: bodyWidth,
            height: bodyHeight,
            layoutConstants: layoutConstants,
            orientation: orientation
        )
        .environmentObject(GameStateManager())
    }
    .background(Color(hex: "B7E4CC"))
}
