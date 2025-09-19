//
//  GameBoard.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/17/25.
//

import SwiftUI

struct GameBoard: View {
    let bodyWidth: CGFloat
    let bodyHeight: CGFloat
    let layoutConstants: GlobalLayoutConstants
    let orientation: AppOrientation
    
    @EnvironmentObject var gameStateManager: GameStateManager
    
    var body: some View {
        let topPadding = layoutConstants.gameBoardTopPaddingValue(bodyHeight)
        let leftPadding = layoutConstants.gameBoardLeftPaddingValue(bodyWidth)
        let bottomPadding = layoutConstants.gameBoardBottomPaddingValue(bodyHeight)
        let rightPadding = layoutConstants.gameBoardRightPaddingValue(bodyWidth)
        
        let gameBoardWidth = bodyWidth - leftPadding - rightPadding
        let gameBoardHeight = bodyHeight - topPadding - bottomPadding
        
        // Use HStack and VStack for proper alignment instead of .position()
        VStack(spacing: 0) {
            // Top padding
            if layoutConstants.gameBoardAnchor == .topLeft {
                Spacer()
                    .frame(height: topPadding)
            } else {
                Spacer() // Push to bottom for bottom-left anchor
            }
            
            HStack(spacing: 0) {
                // Left padding
                Spacer()
                    .frame(width: leftPadding)
                
                // GameBoard Rectangle with Grid
                ZStack(alignment: layoutConstants.gameBoardAnchor == .topLeft ? .topLeading : .bottomLeading) {
                    // GameBoard background
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    
                    // GameGrid aligned within GameBoard
                    GameGrid(
                        width: gameBoardWidth,
                        height: gameBoardHeight,
                        anchor: layoutConstants.gridAnchor,
                        orientation: orientation
                    )
                    .environmentObject(gameStateManager)
                }
                .frame(width: gameBoardWidth, height: gameBoardHeight)
                
                // Right padding
                Spacer()
                    .frame(width: rightPadding)
            }
            
            // Bottom padding
            if layoutConstants.gameBoardAnchor == .bottomLeft {
                Spacer()
                    .frame(height: bottomPadding)
            } else {
                Spacer() // Push to top for top-left anchor
            }
        }
        .frame(width: bodyWidth, height: bodyHeight)
    }
}

#Preview {
    GeometryReader { geometry in
        let deviceType = DeviceType.current
        let orientation = AppOrientation.current(geometry: geometry)
        let layoutConstants = GlobalLayoutConstants.current(for: deviceType, orientation: orientation)
        let bodyHeight = layoutConstants.bodyHeightValue(geometry.size.height)
        let bodyWidth = layoutConstants.bodyWidthValue(geometry.size.width)
        
        GameBoard(
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
            layoutConstants: layoutConstants,
            orientation: orientation
        )
    }
//    .background(Color(hex: "B7E4CC"))
    .background(Color(hex: "0B770A"))
}
