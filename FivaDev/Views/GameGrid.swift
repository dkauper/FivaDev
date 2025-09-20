//
//  GameGrid.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/17/25.
//

import SwiftUI

struct GameGrid: View {
    let width: CGFloat
    let height: CGFloat
    let anchor: AnchorPosition
    let orientation: AppOrientation
    
    @EnvironmentObject var gameStateManager: GameStateManager
    
    private let gridSize = 10
    private let spacingRatio: CGFloat = 0.005
    
    var body: some View {
        ZStack {
            // Dark green background to show card alignment and spacing
//            Rectangle()
//                .fill(Color(hex: "eabf90"))//.opacity(0.1))
//                .frame(width: width, height: height)
//            
            buildGrid()
        }
    }
    
    private func buildGrid() -> some View {
        let cellDims = calculateCellDimensions()
        let useWidth = orientation == .landscape ? height : width
        let useHeight = orientation == .landscape ? width : height
        let spacing = min(useWidth, useHeight) * spacingRatio
        let columns = Array(repeating: GridItem(.fixed(cellDims.width), spacing: spacing), count: gridSize)
        
        let grid = LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                GameGridElement(
                    position: index,
                    width: cellDims.width,
                    height: cellDims.height,
                    orientation: .portrait
                )
                .environmentObject(gameStateManager)
            }
        }
        .padding(8)
        
        if orientation == .landscape {
            return AnyView(
                grid
                    .rotationEffect(.degrees(-90))
                    .frame(width: width, height: height)
            )
        } else {
            return AnyView(
                grid
                    .frame(width: width, height: height)
            )
        }
    }
    
    private func calculateCellDimensions() -> (width: CGFloat, height: CGFloat) {
        let useWidth = orientation == .landscape ? height : width
        let useHeight = orientation == .landscape ? width : height
        
        // Account for grid padding
        let paddingAdjustment: CGFloat = 4
        let adjustedWidth = useWidth - paddingAdjustment
        let adjustedHeight = useHeight - paddingAdjustment
        
        // Calculate spacing
        let spacing = min(adjustedWidth, adjustedHeight) * spacingRatio
        let totalHorizontalSpacing = spacing * CGFloat(gridSize - 1)
        let totalVerticalSpacing = spacing * CGFloat(gridSize - 1)
        
        // Available space for cards
        let availableWidth = adjustedWidth - totalHorizontalSpacing
        let availableHeight = adjustedHeight - totalVerticalSpacing
        
        // Calculate maximum cell dimensions
        let maxCellWidth = availableWidth / CGFloat(gridSize)
        let maxCellHeight = availableHeight / CGFloat(gridSize)
        
        // Maintain 1:1.5 aspect ratio for cards (width:height)
        let cardAspectRatio: CGFloat = 1.0 / 1.5
        
        let finalWidth: CGFloat
        let finalHeight: CGFloat
        
        if maxCellWidth / maxCellHeight > cardAspectRatio {
            // Height is the limiting factor - use full height
            finalHeight = maxCellHeight
            finalWidth = maxCellHeight * cardAspectRatio
        } else {
            // Width is the limiting factor - use full width
            finalWidth = maxCellWidth
            finalHeight = maxCellWidth / cardAspectRatio
        }
        
        return (finalWidth, finalHeight)
    }
}

#Preview("Portrait") {
    GameGrid(
        width: 400,
        height: 600,
        anchor: .topLeft,
        orientation: .portrait
    )
}

#Preview("Landscape") {
    GameGrid(
        width: 600,
        height: 400,
        anchor: .bottomLeft,
        orientation: .landscape
    )
}
