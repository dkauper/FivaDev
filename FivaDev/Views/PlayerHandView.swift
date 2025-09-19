//
//  PlayerHandView.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/18/25.
//

import SwiftUI

struct PlayerHandView: View {
    let bodyWidth: CGFloat
    let bodyHeight: CGFloat
    let layoutConstants: GlobalLayoutConstants
    let playerHandConstants: PlayerHandLayoutConstants
    let orientation: AppOrientation
    
    @EnvironmentObject var gameStateManager: GameStateManager
    @State private var hoveredCardIndex: Int? = nil
    
    // Sample cards for the current player (will be replaced with actual game state)
    private var playerCards: [String] {
        return gameStateManager.currentPlayerCards
    }
    
    var body: some View {
        let topPadding = playerHandConstants.playerHandTopValue(bodyHeight)
        let bottomPadding = playerHandConstants.playerHandBottomValue(bodyHeight)
        let leftPadding = playerHandConstants.playerHandLeftValue(bodyWidth)
        let rightPadding = playerHandConstants.playerHandRightValue(bodyWidth)
        
        let handWidth = bodyWidth - leftPadding - rightPadding
        let handHeight = bodyHeight - topPadding - bottomPadding
        
        VStack(spacing: 0) {
            // Top padding
            Spacer()
                .frame(height: topPadding)
            
            HStack(spacing: 0) {
                // Left padding
                Spacer()
                    .frame(width: leftPadding)
                
                // Player hand overlay
                playerHandOverlay(width: handWidth, height: handHeight)
                
                // Right padding
                Spacer()
                    .frame(width: rightPadding)
            }
            
            // Bottom padding
            Spacer()
                .frame(height: bottomPadding)
        }
        .frame(width: bodyWidth, height: bodyHeight)
    }
    
    
    private func playerHandOverlay(width: CGFloat, height: CGFloat) -> some View {
        let overlayPadding: CGFloat = 4
        
        return cardsGridContainer(
            availableWidth: width - (overlayPadding * 2),
            availableHeight: height - (overlayPadding * 2)
        )
        .padding(overlayPadding)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .stroke(.white.opacity(0.6), lineWidth: 2) // Added visible border
        )
        .frame(width: width, height: height)
    }
    
    // Remove overlayHeader function since we no longer need it
    
    private func cardsGridContainer(availableWidth: CGFloat, availableHeight: CGFloat) -> some View {
        GeometryReader { geometry in
            flexibleCardsGrid(
                availableWidth: availableWidth,
                availableHeight: availableHeight
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func flexibleCardsGrid(availableWidth: CGFloat, availableHeight: CGFloat) -> some View {
        let gridDimensions = calculateFlexibleGrid(
            for: playerCards.count,
            availableWidth: availableWidth,
            availableHeight: availableHeight
        )
        
        let columns = Array(
            repeating: GridItem(.flexible(minimum: gridDimensions.cardWidth, maximum: gridDimensions.cardWidth),
                               spacing: gridDimensions.spacing),
            count: gridDimensions.columns
        )
        
        return LazyVGrid(columns: columns, spacing: gridDimensions.spacing) {
            ForEach(Array(playerCards.enumerated()), id: \.offset) { index, card in
                playerCardView(
                    cardName: card,
                    width: gridDimensions.cardWidth,
                    height: gridDimensions.cardHeight,
                    index: index
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private func playerCardView(cardName: String, width: CGFloat, height: CGFloat, index: Int) -> some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
                .stroke(Color.black.opacity(0.3), lineWidth: 0.5)
            
            // Card image
            Image(cardName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .padding(1)
        }
        .frame(width: width, height: height)
        .glassEffect()
        .scaleEffect(hoveredCardIndex == index ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: hoveredCardIndex)
        .onHover { isHovering in
            hoveredCardIndex = isHovering ? index : nil
            gameStateManager.highlightCard(cardName, highlight: isHovering)
        }
        .onTapGesture {
            // Handle card selection/play
            playCard(at: index)
        }
    }
    
    private func calculateFlexibleGrid(for cardCount: Int, availableWidth: CGFloat, availableHeight: CGFloat) -> (columns: Int, cardWidth: CGFloat, cardHeight: CGFloat, spacing: CGFloat) {
        let aspectRatio: CGFloat = 1.0 / 1.5 // Card aspect ratio (width:height)
        let minSpacing: CGFloat = 4
        let minCardWidth: CGFloat = 20
        let minCardHeight: CGFloat = 30
        
        // Try different column counts to find the best fit
        var bestFit: (columns: Int, cardWidth: CGFloat, cardHeight: CGFloat, spacing: CGFloat)?
        var bestCardArea: CGFloat = 0
        
        // Test column counts from 1 to the number of cards (max 8)
        let maxColumns = min(cardCount, 8)
        
        for columns in 1...maxColumns {
            let rows = Int(ceil(Double(cardCount) / Double(columns)))
            
            // Calculate spacing - use more space for fewer cards
            let spacing = max(minSpacing, min(12, availableWidth / CGFloat(columns * 2)))
            
            // Calculate total space used by spacing
            let totalHorizontalSpacing = spacing * CGFloat(max(0, columns - 1))
            let totalVerticalSpacing = spacing * CGFloat(max(0, rows - 1))
            
            // Calculate available space for cards
            let availableCardWidth = (availableWidth - totalHorizontalSpacing) / CGFloat(columns)
            let availableCardHeight = (availableHeight - totalVerticalSpacing) / CGFloat(rows)
            
            // Determine actual card size based on aspect ratio
            let cardWidth: CGFloat
            let cardHeight: CGFloat
            
            if availableCardWidth / availableCardHeight > aspectRatio {
                // Height is the limiting factor
                cardHeight = max(minCardHeight, availableCardHeight)
                cardWidth = max(minCardWidth, cardHeight * aspectRatio)
            } else {
                // Width is the limiting factor
                cardWidth = max(minCardWidth, availableCardWidth)
                cardHeight = max(minCardHeight, cardWidth / aspectRatio)
            }
            
            // Check if this layout fits within bounds
            let totalRequiredWidth = (cardWidth * CGFloat(columns)) + totalHorizontalSpacing
            let totalRequiredHeight = (cardHeight * CGFloat(rows)) + totalVerticalSpacing
            
            if totalRequiredWidth <= availableWidth && totalRequiredHeight <= availableHeight {
                let cardArea = cardWidth * cardHeight
                if cardArea > bestCardArea {
                    bestCardArea = cardArea
                    bestFit = (columns: columns, cardWidth: cardWidth, cardHeight: cardHeight, spacing: spacing)
                }
            }
        }
        
        // Return best fit or sensible fallback
        if let best = bestFit {
            return best
        } else {
            // Fallback: single row if possible, otherwise single column
            let singleRowCardWidth = (availableWidth - (minSpacing * CGFloat(cardCount - 1))) / CGFloat(cardCount)
            if singleRowCardWidth >= minCardWidth {
                let cardHeight = min(availableHeight, singleRowCardWidth / aspectRatio)
                let finalCardWidth = min(singleRowCardWidth, cardHeight * aspectRatio)
                return (columns: cardCount, cardWidth: finalCardWidth, cardHeight: cardHeight, spacing: minSpacing)
            } else {
                // Single column fallback
                let cardWidth = min(availableWidth, minCardWidth * 2)
                let cardHeight = min(availableHeight / CGFloat(cardCount), cardWidth / aspectRatio)
                return (columns: 1, cardWidth: cardWidth, cardHeight: cardHeight, spacing: minSpacing)
            }
        }
    }
    
    private func playCard(at index: Int) {
        // TODO: Implement card playing logic
        // This will integrate with the game state management
        print("Playing card: \(playerCards[index]) at index \(index)")
    }
}

#Preview("Portrait") {
    GeometryReader { geometry in
        let deviceType = DeviceType.current
        let orientation = AppOrientation.current(geometry: geometry)
        let layoutConstants = GlobalLayoutConstants.current(for: deviceType, orientation: orientation)
        let playerHandConstants = PlayerHandLayoutConstants.current(for: deviceType, orientation: orientation)
        let bodyHeight = layoutConstants.bodyHeightValue(geometry.size.height)
        let bodyWidth = layoutConstants.bodyWidthValue(geometry.size.width)
        
        PlayerHandView(
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
            layoutConstants: layoutConstants,
            playerHandConstants: playerHandConstants,
            orientation: orientation
        )
        .environmentObject(GameStateManager())
    }
    .background(Color(hex: "B7E4CC"))
}

#Preview("Landscape") {
    GeometryReader { geometry in
        let deviceType = DeviceType.current
        let orientation: AppOrientation = .landscape
        let layoutConstants = GlobalLayoutConstants.current(for: deviceType, orientation: orientation)
        let playerHandConstants = PlayerHandLayoutConstants.current(for: deviceType, orientation: orientation)
        let bodyHeight = layoutConstants.bodyHeightValue(geometry.size.height)
        let bodyWidth = layoutConstants.bodyWidthValue(geometry.size.width)
        
        PlayerHandView(
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
            layoutConstants: layoutConstants,
            playerHandConstants: playerHandConstants,
            orientation: orientation
        )
        .environmentObject(GameStateManager())
    }
    .background(Color(hex: "B7E4CC"))
}
