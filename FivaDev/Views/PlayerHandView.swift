//
//  PlayerHandView.swift
//  FivaDev
//
//  Refactored to use SharedPlayingCardComponents
//  Created by Doron Kauper on 9/18/25.
//  Updated: October 1, 2025, 10:40 AM PDT
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
    
    // Use the enhanced layout system
    private var playerHandConstants: PlayerHandLayoutConstants {
        PlayerHandLayoutConstants.current(
            for: DeviceType.current,
            orientation: orientation
        )
    }
    
    // Card layout configuration
    private var cardLayoutConstants: PlayerHandCardLayoutConstants {
        PlayerHandCardLayoutConstants.current(
            for: DeviceType.current,
            orientation: orientation
        )
    }
    
    // Sample cards for the current player
    private var playerCards: [String] {
        return gameStateManager.currentPlayerCards
    }
    
    var body: some View {
        let topPadding = playerHandConstants.topValue(bodyHeight)
        let bottomPadding = playerHandConstants.bottomValue(bodyHeight)
        let leftPadding = playerHandConstants.leftValue(bodyWidth)
        let rightPadding = playerHandConstants.rightValue(bodyWidth)
        
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
        let overlayPadding = cardLayoutConstants.overlayPadding(overlayWidth: width, overlayHeight: height)
        
        return cardsGridContainer(
            availableWidth: width - (overlayPadding * 2),
            availableHeight: height - (overlayPadding * 2)
        )
        .padding(overlayPadding)
        .background(
            RoundedRectangle(cornerRadius: cardLayoutConstants.overlayCornerRadius(overlayWidth: width))
                .fill(.ultraThinMaterial)
                .stroke(.red.opacity(0.6), lineWidth: 2)
        )
        .frame(width: width, height: height)
    }
    
    private func cardsGridContainer(availableWidth: CGFloat, availableHeight: CGFloat) -> some View {
        fixedSizeCardsGrid(
            availableWidth: availableWidth,
            availableHeight: availableHeight
        )
    }
    
    private func fixedSizeCardsGrid(availableWidth: CGFloat, availableHeight: CGFloat) -> some View {
        let cardCount = CGFloat(playerCards.count)
        let spacing = cardLayoutConstants.cardSpacing(availableWidth: availableWidth, columns: playerCards.count)
        
        // Determine layout direction based on overlay dimensions
        let useHorizontalLayout = availableWidth > availableHeight
        
        if useHorizontalLayout {
            // HORIZONTAL LAYOUT: Cards flow left to right
            let totalSpacing = spacing * (cardCount - 1)
            let availableCardWidth = availableWidth - totalSpacing
            let availableCardHeight = availableHeight
            
            let cardWidth = availableCardWidth / cardCount
            let cardHeight = availableCardHeight
            
            return AnyView(
                HStack(spacing: spacing) {
                    ForEach(Array(playerCards.enumerated()), id: \.offset) { index, card in
                        playerCardView(
                            cardName: card,
                            width: cardWidth,
                            height: cardHeight,
                            index: index
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        } else {
            // VERTICAL LAYOUT: Cards stack top to bottom
            let totalSpacing = spacing * (cardCount - 1)
            let availableCardHeight = availableHeight - totalSpacing
            let availableCardWidth = availableWidth
            
            let cardHeight = availableCardHeight / cardCount
            let cardWidth = availableCardWidth
            
            return AnyView(
                VStack(spacing: spacing) {
                    ForEach(Array(playerCards.enumerated()), id: \.offset) { index, card in
                        playerCardView(
                            cardName: card,
                            width: cardWidth,
                            height: cardHeight,
                            index: index
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        }
    }
    
    private func playerCardView(cardName: String, width: CGFloat, height: CGFloat, index: Int) -> some View {
        let isHovered = hoveredCardIndex == index
        let isTouched = touchedCardIndex == index
        let isActive = isHovered || isTouched
        
        // Parse card data from card name
        let cardData = PlayingCardData.parse(from: cardName)
        
        return ZStack {
            // Card background with border - always vertical
            RoundedRectangle(cornerRadius: cardLayoutConstants.cardCornerRadius(cardWidth: width))
                .fill(Color.white.opacity(0.1))
                .stroke(Color.green.opacity(1), lineWidth: 2)
            
            // Use unified card component - cards in hand always portrait
            UnifiedPlayingCardView(
                cardData: cardData,
                width: width,
                height: height,
                orientation: .portrait,
                cardPadding: cardLayoutConstants.cardInternalPadding
            )
            .padding(cardLayoutConstants.cardInternalPadding)
        }
        .frame(width: width, height: height)
        .glassEffect()
        .scaleEffect(isActive ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .overlay(
            RoundedRectangle(cornerRadius: cardLayoutConstants.cardCornerRadius(cardWidth: width))
                .stroke(Color.blue.opacity(isActive ? 0.4 : 0), lineWidth: 1)
                .animation(.easeInOut(duration: 0.2), value: isActive)
        )
        #if !os(tvOS)
        .onHover { isHovering in
            hoveredCardIndex = isHovering ? index : nil
            
            Task { @MainActor in
                gameStateManager.highlightCard(cardName, highlight: isHovering)
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if touchedCardIndex != index {
                        touchedCardIndex = index
                        Task { @MainActor in
                            gameStateManager.highlightCard(cardName, highlight: true)
                        }
                    }
                }
                .onEnded { _ in
                    touchedCardIndex = nil
                    Task { @MainActor in
                        gameStateManager.highlightCard(cardName, highlight: false)
                    }
                }
        )
        #else
        .focusable(true) { isFocused in
            hoveredCardIndex = isFocused ? index : nil
            Task { @MainActor in
                gameStateManager.highlightCard(cardName, highlight: isFocused)
            }
        }
        #endif
        .onTapGesture {
            playCard(at: index)
        }
        .onChange(of: isActive) { _, newValue in
            #if canImport(UIKit) && !os(tvOS)
            if newValue {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
            #endif
        }
    }
    
    private func playCard(at index: Int) {
        let cardName = playerCards[index]
        print("Playing card: \(cardName) at index \(index)")
        
        withAnimation(.spring(duration: 0.3)) {
            // Future: Add card playing logic
        }
    }
}

// MARK: - Preview Support
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
