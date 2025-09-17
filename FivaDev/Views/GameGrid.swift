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
    
    private let gridSize = 10
    private let spacingRatio: CGFloat = 0.02
    
    var body: some View {
        ZStack {
            // Debug background - should be RED in landscape, BLUE in portrait
            Rectangle()
                .fill(orientation == .landscape ? Color.red : Color.blue)
                .opacity(0.5)
                .frame(width: width, height: height)
            
            // Debug text overlay
            VStack {
                Text(orientation == .landscape ? "LANDSCAPE MODE" : "PORTRAIT MODE")
                    .font(.title)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.7))
                    .padding()
                Spacer()
            }
            
            // The grid
            buildGrid()
        }
    }
    
    private func buildGrid() -> some View {
        let cellDims = calculateCellDimensions()
        let spacing = (orientation == .landscape ? width : height) * spacingRatio
        let columns = Array(repeating: GridItem(.fixed(cellDims.width), spacing: spacing), count: gridSize)
        
        let grid = LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                GameGridElement(
                    position: index,
                    width: cellDims.width,
                    height: cellDims.height,
                    orientation: .portrait
                )
            }
        }
        
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
        
        let totalHorizontalSpacing = useWidth * spacingRatio * CGFloat(gridSize - 1)
        let totalVerticalSpacing = useHeight * spacingRatio * CGFloat(gridSize - 1)
        
        let availableWidth = useWidth - totalHorizontalSpacing
        let availableHeight = useHeight - totalVerticalSpacing
        
        let cellWidth = availableWidth / CGFloat(gridSize)
        let cellHeight = availableHeight / CGFloat(gridSize)
        
        let cardAspectRatio: CGFloat = 1.0 / 1.5
        
        if cellWidth / cellHeight > cardAspectRatio {
            let finalHeight = cellHeight
            let finalWidth = cellHeight * cardAspectRatio
            return (finalWidth, finalHeight)
        } else {
            let finalWidth = cellWidth
            let finalHeight = cellWidth / cardAspectRatio
            return (finalWidth, finalHeight)
        }
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
