//
//  BodyView.swift
//  FivaDev
//
//  Enhanced with new layout system compatibility
//  Created by Doron Kauper on 9/17/25.
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
            
            // Player Hand Overlay - now self-contained with no extra parameters needed
            PlayerHandView(
                bodyWidth: width,
                bodyHeight: height,
                layoutConstants: layoutConstants,
                orientation: orientation
            )
            .environmentObject(gameStateManager)
            
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
