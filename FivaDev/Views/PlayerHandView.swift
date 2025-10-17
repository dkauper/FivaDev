//
//  PlayerHandView.swift
//  FivaDev
//
//  Fixed: Layout constants now update on first render
//  Created by Doron Kauper on 9/18/25.
//  Updated: October 6, 2025, 10:15 PM Pacific - Fixed initial layout calculation
//  Optimized: October 3, 2025, 4:45 PM Pacific - Added dimension validation
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
    
    // FIXED: Computed properties instead of @State - ensures fresh calculation on every render
    private var playerHandConstants: PlayerHandLayoutConstants {
        PlayerHandLayoutConstants.current(
            for: DeviceType.current,
            orientation: orientation,
            bodyHeight: bodyHeight,
            bodyWidth: bodyWidth
        )
    }
    
    private var cardLayoutConstants: PlayerHandCardLayoutConstants {
        PlayerHandCardLayoutConstants.current(
            for: DeviceType.current,
            orientation: orientation
        )
    }
    
    private var playerCards: [String] {
        return gameStateManager.currentPlayerCards
    }
    
    // Helper to ensure valid dimensions
    private func validDimension(_ value: CGFloat) -> CGFloat {
        guard value.isFinite && value > 0 else { return 1 }
        return value
    }
    
    var body: some View {
        let topPadding = playerHandConstants.topValue(bodyHeight)
        let bottomPadding = playerHandConstants.bottomValue(bodyHeight)
        let leftPadding = playerHandConstants.leftValue(bodyWidth)
        let rightPadding = playerHandConstants.rightValue(bodyWidth)
        
        let handWidth = playerHandConstants.overlayWidth(bodyWidth)
        let handHeight = playerHandConstants.overlayHeight(bodyHeight)
        
        VStack(spacing: 0) {
            Spacer().frame(height: validDimension(topPadding))
            
            HStack(spacing: 0) {
                Spacer().frame(width: validDimension(leftPadding))
                playerHandOverlay(width: handWidth, height: handHeight)
                Spacer().frame(width: validDimension(rightPadding))
            }
            
            Spacer().frame(height: validDimension(bottomPadding))
        }
        .frame(width: bodyWidth, height: bodyHeight)
    }
    
    private func playerHandOverlay(width: CGFloat, height: CGFloat) -> some View {
        // Validate input dimensions
        let safeWidth = validDimension(width)
        let safeHeight = validDimension(height)
        let overlayPadding = cardLayoutConstants.overlayPadding(overlayWidth: safeWidth, overlayHeight: safeHeight)
        
        return cardsGridContainer(
            availableWidth: max(1, safeWidth - (overlayPadding * 2)),
            availableHeight: max(1, safeHeight - (overlayPadding * 2))
        )
        .padding(overlayPadding)
        .background(
            RoundedRectangle(cornerRadius: cardLayoutConstants.overlayCornerRadius(overlayWidth: width))
                .fill(.ultraThinMaterial)
                .stroke(.red.opacity(0.6), lineWidth: 2)
        )
        .frame(width: safeWidth, height: safeHeight)
    }
    
    private func cardsGridContainer(availableWidth: CGFloat, availableHeight: CGFloat) -> some View {
        fixedSizeCardsGrid(
            availableWidth: availableWidth,
            availableHeight: availableHeight
        )
    }
    
    // OPTIMIZED: Unified layout using AnyLayout (reduces ~40 lines of duplicate code)
    private func fixedSizeCardsGrid(availableWidth: CGFloat, availableHeight: CGFloat) -> some View {
        // Validate input dimensions
        let safeWidth = validDimension(availableWidth)
        let safeHeight = validDimension(availableHeight)
        let cardCount = max(1, CGFloat(playerCards.count))
        let spacing = cardLayoutConstants.cardSpacing(availableWidth: safeWidth, columns: playerCards.count)
        let useHorizontalLayout = safeWidth > safeHeight
        
        // Calculate card dimensions based on layout direction with validation
        let (cardWidth, cardHeight): (CGFloat, CGFloat)
        if useHorizontalLayout {
            let totalSpacing = spacing * (cardCount - 1)
            cardWidth = max(1, (safeWidth - totalSpacing) / cardCount)
            cardHeight = max(1, safeHeight)
        } else {
            let totalSpacing = spacing * (cardCount - 1)
            cardWidth = max(1, safeWidth)
            cardHeight = max(1, (safeHeight - totalSpacing) / cardCount)
        }
        
        // Use AnyLayout to dynamically switch between HStack and VStack
        let layout = useHorizontalLayout ? AnyLayout(HStackLayout(spacing: spacing))
                                         : AnyLayout(VStackLayout(spacing: spacing))
        
        return layout {
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
    }
    
    private func playerCardView(cardName: String, width: CGFloat, height: CGFloat, index: Int) -> some View {
        let isHovered = hoveredCardIndex == index
        let isTouched = touchedCardIndex == index
        let isSelected = gameStateManager.selectedCardIndex == index
        let isActive = isHovered || isTouched
        let cardData = PlayingCardData.parse(from: cardName)
        
        // Validate dimensions before rendering
        let validWidth = validDimension(width)
        let validHeight = validDimension(height)
        
        return ZStack {
            RoundedRectangle(cornerRadius: cardLayoutConstants.cardCornerRadius(cardWidth: validWidth))
                .fill(Color.white.opacity(0.1))
                .stroke(isSelected ? Color.yellow : Color.green, lineWidth: isSelected ? 3 : 2)
            
            UnifiedPlayingCardView(
                cardData: cardData,
                width: validWidth,
                height: validHeight,
                orientation: .portrait,
                cardPadding: cardLayoutConstants.cardInternalPadding
            )
            .padding(cardLayoutConstants.cardInternalPadding)
        }
        .frame(width: validWidth, height: validHeight)
        .glassEffect()
        .scaleEffect(isActive ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .overlay(
            RoundedRectangle(cornerRadius: cardLayoutConstants.cardCornerRadius(cardWidth: validWidth))
                .stroke(Color.blue.opacity(isActive ? 0.4 : 0), lineWidth: 1)
                .animation(.easeInOut(duration: 0.2), value: isActive)
        )
        #if !os(tvOS)
        .onTapGesture {
            print("🎴 HAND TAP: Card \(cardName) at index \(index)")
            playCard(at: index)
        }
        .onHover { isHovering in
            hoveredCardIndex = isHovering ? index : nil
            gameStateManager.highlightCard(cardName, highlight: isHovering)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if touchedCardIndex != index {
                        touchedCardIndex = index
                        gameStateManager.highlightCard(cardName, highlight: true)
                    }
                }
                .onEnded { _ in
                    touchedCardIndex = nil
                    gameStateManager.highlightCard(cardName, highlight: false)
                }
        )
        #else
        .focusable(true) { isFocused in
            hoveredCardIndex = isFocused ? index : nil
            gameStateManager.highlightCard(cardName, highlight: isFocused)
        }
        .onTapGesture {
            print("🎴 HAND TAP: Card \(cardName) at index \(index)")
            playCard(at: index)
        }
        #endif
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
        print("Selecting card: \(cardName) at index \(index)")
        
        withAnimation(.spring(duration: 0.3)) {
            // Select the card - this will highlight valid board positions
            gameStateManager.selectCard(at: index)
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
