//
//  GameGrid.swift
//  FivaDev
//
//  FIXED: Cards now maintain vertical orientation regardless of device rotation
//  Created by Doron Kauper on 9/17/25.
//  Revised: September 28, 2025, 4:00 PM PST
//

import SwiftUI

struct GameGrid: View {
    let width: CGFloat
    let height: CGFloat
    let anchor: AnchorPosition
    let orientation: AppOrientation
    
    @EnvironmentObject var gameStateManager: GameStateManager
    
    // Grid configuration - percentage-based within GameBoard constraints
    private let gridSize = 10
    
    // Percentage-based spacing and padding configuration
    private let gridPaddingPercent: CGFloat = 0.02    // 2% padding around entire grid
    private let cardSpacingPercent: CGFloat = 0.008   // 0.8% spacing between cards
    
    var body: some View {
        ZStack {
            buildPercentageBasedGrid()
        }
    }
    
    private func buildPercentageBasedGrid() -> some View {
        let gridGeometry = calculatePercentageBasedGeometry()
        let columns = Array(repeating: GridItem(.fixed(gridGeometry.cardWidth), spacing: gridGeometry.spacing), count: gridSize)
        
        let grid = LazyVGrid(columns: columns, spacing: gridGeometry.spacing) {
            ForEach(0..<(gridSize * gridSize), id: \.self) { position in
                GameGridElement(
                    position: position,
                    width: gridGeometry.cardWidth,
                    height: gridGeometry.cardHeight,
                    orientation: orientation // FIXED: Pass device orientation for component percentages
                )
                .environmentObject(gameStateManager)
            }
        }
        .padding(gridGeometry.gridPadding)
        .frame(width: width, height: height)
        
        // REMOVED: No longer rotating the entire grid
        // Cards now maintain their vertical orientation in all device orientations
        return AnyView(grid)
    }
    
    private func calculatePercentageBasedGeometry() -> GridGeometry {
        // Use the GameBoard-provided dimensions directly
        // These come from GlobalLayoutConstants calculations
        
        // FIXED: No need to swap dimensions for landscape since we're not rotating the grid
        let useWidth = width
        let useHeight = height
        
        // Calculate grid padding based on percentage of GameBoard dimensions
        let gridPadding = min(useWidth, useHeight) * gridPaddingPercent
        
        // Available space after padding
        let availableWidth = useWidth - (gridPadding * 2)
        let availableHeight = useHeight - (gridPadding * 2)
        
        // Calculate spacing between cards based on available space
        let spacing = min(availableWidth, availableHeight) * cardSpacingPercent
        let totalSpacingWidth = spacing * CGFloat(gridSize - 1)
        let totalSpacingHeight = spacing * CGFloat(gridSize - 1)
        
        // Net available space for cards
        let netAvailableWidth = availableWidth - totalSpacingWidth
        let netAvailableHeight = availableHeight - totalSpacingHeight
        
        // Calculate card dimensions proportionally within available space
        let cardWidth = netAvailableWidth / CGFloat(gridSize)
        let cardHeight = netAvailableHeight / CGFloat(gridSize)
        
        return GridGeometry(
            cardWidth: cardWidth,
            cardHeight: cardHeight,
            spacing: spacing,
            gridPadding: gridPadding,
            availableWidth: availableWidth,
            availableHeight: availableHeight
        )
    }
}

// MARK: - Supporting Structures
private struct GridGeometry {
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let spacing: CGFloat
    let gridPadding: CGFloat
    let availableWidth: CGFloat
    let availableHeight: CGFloat
    
    // Computed properties for debugging and layout analysis
    var totalGridWidth: CGFloat {
        return (cardWidth * 10) + (spacing * 9) + (gridPadding * 2)
    }
    
    var totalGridHeight: CGFloat {
        return (cardHeight * 10) + (spacing * 9) + (gridPadding * 2)
    }
    
    var cardAspectRatio: CGFloat {
        return cardWidth / cardHeight
    }
    
    var spaceUtilizationWidth: CGFloat {
        return (cardWidth * 10) / availableWidth
    }
    
    var spaceUtilizationHeight: CGFloat {
        return (cardHeight * 10) / availableHeight
    }
}

// MARK: - Debug Information Extension
extension GameGrid {
    /// Provides detailed geometry information for debugging
    private var debugInfo: String {
        let geometry = calculatePercentageBasedGeometry()
        return """
        GameGrid Debug Info:
        - GameBoard Container: \(String(format: "%.1f", width)) x \(String(format: "%.1f", height))
        - Card Size: \(String(format: "%.1f", geometry.cardWidth)) x \(String(format: "%.1f", geometry.cardHeight))
        - Aspect Ratio: \(String(format: "%.3f", geometry.cardAspectRatio))
        - Spacing: \(String(format: "%.1f", geometry.spacing))
        - Grid Padding: \(String(format: "%.1f", geometry.gridPadding))
        - Space Utilization: \(String(format: "%.1f", geometry.spaceUtilizationWidth * 100))% x \(String(format: "%.1f", geometry.spaceUtilizationHeight * 100))%
        - Total Grid: \(String(format: "%.1f", geometry.totalGridWidth)) x \(String(format: "%.1f", geometry.totalGridHeight))
        - Orientation: \(orientation) (Cards always remain portrait)
        """
    }
}

#Preview("Portrait - iPhone") {
    GameGrid(
        width: 350,
        height: 600,
        anchor: .topLeft,
        orientation: .portrait
    )
    .environmentObject(GameStateManager())
    .background(Color.gray.opacity(0.1))
}

#Preview("Landscape - iPhone") {
    GameGrid(
        width: 600,
        height: 350,
        anchor: .bottomLeft,
        orientation: .landscape
    )
    .environmentObject(GameStateManager())
    .background(Color.gray.opacity(0.1))
}

#Preview("Portrait - iPad") {
    GameGrid(
        width: 600,
        height: 800,
        anchor: .topLeft,
        orientation: .portrait
    )
    .environmentObject(GameStateManager())
    .background(Color.gray.opacity(0.1))
}

#Preview("Landscape - iPad") {
    GameGrid(
        width: 800,
        height: 600,
        anchor: .bottomLeft,
        orientation: .landscape
    )
    .environmentObject(GameStateManager())
    .background(Color.gray.opacity(0.1))
}
