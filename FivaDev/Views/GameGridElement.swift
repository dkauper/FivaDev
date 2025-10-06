//
//  GameGridElement.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/17/25.
//  Updated: October 5, 2025, 1:40 PM Pacific - Uses dynamic layout from GameStateManager
//  Optimized: October 3, 2025, 3:00 PM Pacific - Reduced environment object lookups
//  Refactored to use SharedPlayingCardComponents
//

import SwiftUI

struct GameGridElement: View {
    let position: Int
    let width: CGFloat
    let height: CGFloat
    let orientation: AppOrientation
    
    @EnvironmentObject var gameStateManager: GameStateManager
    
    private var cardName: String {
        let cardDistribution = gameStateManager.currentLayout
        guard position >= 0 && position < cardDistribution.count else {
            return "BlueBack"
        }
        return cardDistribution[position]
    }
    
    private var cardData: PlayingCardData {
        return PlayingCardData.parse(from: cardName)
    }
    
    // OPTIMIZED: Computed property to reduce environment object lookups
    private var cardOpacity: Double {
        let isHighlighted = gameStateManager.shouldHighlight(position: position)
        let hasAnyHighlights = !gameStateManager.highlightedCards.isEmpty
        return isHighlighted ? 1.0 : (hasAnyHighlights ? 0.7 : 1.0)
    }
    
    var body: some View {
        // OPTIMIZED: Cache environment lookups once per render
        let isHighlighted = gameStateManager.shouldHighlight(position: position)
        
        ElevatedCard(
            width: width,
            height: height,
            isHighlighted: isHighlighted,
            highlightScale: 1.5,
            zIndex: Double(position),
            highlightZIndex: 10000
        ) {
            UnifiedPlayingCardView(
                cardData: cardData,
                width: width,
                height: height,
                orientation: orientation
            )
        }
        .opacity(cardOpacity)
    }
}

// MARK: - Previews
#Preview("Red Joker") {
    GameGridElement(
        position: 0,
        width: 60,
        height: 60,
        orientation: .portrait
    )
    .environmentObject(GameStateManager())
    .padding()
}

#Preview("King of Diamonds - Portrait") {
    GameGridElement(
        position: 7,
        width: 60,
        height: 60,
        orientation: .portrait
    )
    .environmentObject(GameStateManager())
    .padding()
}

#Preview("King of Diamonds - Landscape") {
    GameGridElement(
        position: 7,
        width: 60,
        height: 60,
        orientation: .landscape
    )
    .environmentObject(GameStateManager())
    .padding()
}

#Preview("Two of Hearts - Portrait") {
    GameGridElement(
        position: 12,
        width: 60,
        height: 60,
        orientation: .portrait
    )
    .environmentObject(GameStateManager())
    .padding()
}

#Preview("Five of Diamonds - Portrait") {
    GameGridElement(
        position: 1,
        width: 60,
        height: 60,
        orientation: .portrait
    )
    .environmentObject(GameStateManager())
    .padding()
}

#Preview("Three of Clubs - Landscape") {
    GameGridElement(
        position: 63,
        width: 60,
        height: 60,
        orientation: .landscape
    )
    .environmentObject(GameStateManager())
    .padding()
}
