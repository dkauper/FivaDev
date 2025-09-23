//
//  PlayerHandView.swift
//  FivaDev
//
//  Enhanced with new layout system compatibility
//  Created by Doron Kauper on 9/18/25.
//  Updated: September 22, 2025, 2:45 PM
//

import SwiftUI

struct PlayerHandView: View {
    let bodyWidth: CGFloat
    let bodyHeight: CGFloat
    let layoutConstants: GlobalLayoutConstants
    let orientation: AppOrientation
    
    @EnvironmentObject var gameStateManager: GameStateManager
    @State private var hoveredCardIndex: Int? = nil
    @State private var touchedCardIndex: Int? = nil
    
    // Use the enhanced layout system (no longer need to pass playerHandConstants)
    private var playerHandConstants: PlayerHandLayoutConstants {
        PlayerHandLayoutConstants.current(
            for: DeviceType.current,
            orientation: orientation
        )
    }
    
    // Sample cards for the current player (will be replaced with actual game state)
    private var playerCards: [String] {
        return gameStateManager.currentPlayerCards
    }
    
    var body: some View {
        // Use the new protocol methods instead of the old specific method names
        let topPadding = playerHandConstants.topValue(bodyHeight)
        let bottomPadding = playerHandConstants.bottomValue(bodyHeight)
        let leftPadding = playerHandConstants.leftValue(bodyWidth)
        let rightPadding = playerHandConstants.rightValue(bodyWidth)
        
        // Use convenience methods for cleaner code
        let handWidth = playerHandConstants.overlayWidth(bodyWidth)
        let handHeight = playerHandConstants.overlayHeight(bodyHeight)
        
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
        let overlayPadding: CGFloat = 8
        
        return cardsGridContainer(
            availableWidth: width - (overlayPadding * 2),
            availableHeight: height - (overlayPadding * 2)
        )
        .padding(overlayPadding)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .stroke(.red.opacity(0.6), lineWidth: 2)
        )
        .frame(width: width, height: height)
    }
    
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func playerCardView(cardName: String, width: CGFloat, height: CGFloat, index: Int) -> some View {
        let isHovered = hoveredCardIndex == index
        let isTouched = touchedCardIndex == index
        let isActive = isHovered || isTouched
        
        return ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.3))
                .stroke(Color.green.opacity(1), lineWidth: 2)
            
            // Card image
            Image(cardName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .padding(1)
        }
        .frame(width: width, height: height)
        .glassEffect()
        .scaleEffect(isActive ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .overlay(
            // Subtle border highlight when active
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.blue.opacity(isActive ? 0.4 : 0), lineWidth: 1)
                .animation(.easeInOut(duration: 0.2), value: isActive)
        )
        #if !os(tvOS)
        .onHover { isHovering in
            // Immediate state update for responsiveness
            hoveredCardIndex = isHovering ? index : nil
            
            // Use async to ensure proper timing for game state updates
            Task { @MainActor in
                gameStateManager.highlightCard(cardName, highlight: isHovering)
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    // Touch/press started
                    if touchedCardIndex != index {
                        touchedCardIndex = index
                        Task { @MainActor in
                            gameStateManager.highlightCard(cardName, highlight: true)
                        }
                    }
                }
                .onEnded { _ in
                    // Touch/press ended
                    touchedCardIndex = nil
                    Task { @MainActor in
                        gameStateManager.highlightCard(cardName, highlight: false)
                    }
                }
        )
        #else
        // tvOS: Use focus-based interaction
        .focusable(true) { isFocused in
            // Focus-based highlighting for Apple TV
            hoveredCardIndex = isFocused ? index : nil
            Task { @MainActor in
                gameStateManager.highlightCard(cardName, highlight: isFocused)
            }
        }
        #endif
        .onTapGesture {
            // Handle card selection/play with enhanced feedback
            playCard(at: index)
        }
        .onChange(of: isActive) { _, newValue in
            // Enhanced haptic feedback on iOS when card becomes active
            #if canImport(UIKit) && !os(tvOS)
            if newValue {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
            #endif
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
            let spacing = max(minSpacing, min(12, availableWidth / CGFloat(columns * 4)))
            
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
        // Enhanced card playing logic with visual feedback
        let cardName = playerCards[index]
        print("Playing card: \(cardName) at index \(index)")
        
        // Add visual feedback for card selection
        withAnimation(.spring(duration: 0.3)) {
            // Could add temporary effects here like removing from hand
        }
        
        // TODO: Implement actual card playing logic
        // This will integrate with the game state management
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
        
        PlayerHandView(
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
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
        
        PlayerHandView(
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
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
        
        PlayerHandView(
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
            layoutConstants: layoutConstants,
            orientation: orientation
        )
        .environmentObject(GameStateManager())
    }
    .background(Color(hex: "B7E4CC"))
}
