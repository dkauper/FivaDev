//
//  GameGridElement.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/17/25.
//  Updated: October 11, 2025, 5:45 PM Pacific - Fixed chip persistence on rotation
//  Updated: October 11, 2025, 5:25 PM Pacific - Added chip rendering
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
        // CRITICAL: Direct access to boardState to force view updates on chip changes
        let chipState = gameStateManager.boardState[position]
        
        ElevatedCard(
            width: width,
            height: height,
            isHighlighted: isHighlighted,
            highlightScale: 1.5,
            zIndex: Double(position),
            highlightZIndex: 10000
        ) {
            ZStack {
                // Card background
                UnifiedPlayingCardView(
                    cardData: cardData,
                    width: width,
                    height: height,
                    orientation: orientation
                )
                
                // Chip overlay (if position is occupied)
                // Using chipState directly ensures view updates when boardState changes
                if let color = chipState {
                    ChipView(
                        color: color,
                        size: min(width, height) * 0.85  // 85% of card size for better visibility
                    )
                }
            }
        }
        .opacity(cardOpacity)
        .onTapGesture {
            handleTap()
        }
    }
    
    // MARK: - Tap Handling
    
    private func handleTap() {
        print("🎯 BOARD TAP: Position \(position) (\(cardName))")
        // Play the selected card at this position
        gameStateManager.playSelectedCard(at: position)
    }
}

// MARK: - Chip View Component
struct ChipView: View {
    let color: PlayerColor
    let size: CGFloat
    
    var body: some View {
        Image(color.chipImageName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
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

#Preview("Red Joker with Chip") {
    let manager = GameStateManager()
    manager.placeChip(at: 0, color: .red)
    
    return GameGridElement(
        position: 0,
        width: 60,
        height: 60,
        orientation: .portrait
    )
    .environmentObject(manager)
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

#Preview("King of Diamonds with Blue Chip") {
    let manager = GameStateManager()
    manager.placeChip(at: 7, color: .blue)
    
    return GameGridElement(
        position: 7,
        width: 60,
        height: 60,
        orientation: .portrait
    )
    .environmentObject(manager)
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

#Preview("Five of Diamonds with Green Chip") {
    let manager = GameStateManager()
    manager.placeChip(at: 1, color: .green)
    
    return GameGridElement(
        position: 1,
        width: 60,
        height: 60,
        orientation: .portrait
    )
    .environmentObject(manager)
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
