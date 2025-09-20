//
//  GameStateManager.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/18/25.
//

import SwiftUI
import Combine

@MainActor
class GameStateManager: ObservableObject {
    @Published var highlightedCards: Set<String> = []
    
    // Use your existing GameState values but make them reactive
    @Published var currentPlayerCards: [String] = [] {
        didSet {
            // Trigger UI update when cards change
        }
    }
    
    // All possible cards that could be dealt (matching game board distribution)
    private let availableCards = [
        "2H", "3H", "4H", "5H", "6H", "7H", "8H", "9H", "10H", "JH", "QH", "KH", "AH",
        "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "JD", "QD", "KD", "AD",
        "2C", "3C", "4C", "5C", "6C", "7C", "8C", "9C", "10C", "JC", "QC", "KC", "AC",
        "2S", "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "JS", "QS", "KS", "AS"
    ]
    
    init() {
        updatePlayerCards()
    }
    
    // Function to sync with your GameState and update cards
    func updatePlayerCards() {
        let cardCount = GameState.cardsPerPlayer // Uses your static GameState
        // Take first N cards based on your GameState.cardsPerPlayer
        currentPlayerCards = Array(availableCards.prefix(cardCount))
    }
    
    // Function to manually trigger card update (for testing)
    func refreshCards() {
        updatePlayerCards()
    }
    
    // Function to highlight cards on the board when hovering over player hand
    func highlightCard(_ cardName: String, highlight: Bool) {
        if highlight {
            highlightedCards.insert(cardName)
        } else {
            highlightedCards.remove(cardName)
        }
    }
    
    // Function to get all board positions for a specific card
    func getBoardPositions(for cardName: String) -> [Int] {
        let cardDistribution = [
            "RedJoker", "5D", "6D", "7D", "8D", "9D", "QD", "KD", "AD", "BlackJoker",
            "5D", "3H", "2H", "2S", "3S", "4S", "5S", "6S", "7S", "AC",
            "4D", "4H", "KD", "AD", "KS", "QS", "JS", "10S", "9S", "KS",
            "2D", "5H", "QD", "KD", "6H", "7H", "8H", "9C", "8S", "QS",
            "AD", "6H", "8D", "KD", "5H", "4H", "6H", "10C", "9S", "10C",
            "AS", "7H", "9D", "3H", "4H", "7H", "9C", "JS", "8C", "9C",
            "KS", "8H", "10D", "2C", "3C", "4C", "5C", "KS", "7C", "8C",
            "QS", "9H", "JD", "KD", "AH", "2C", "3C", "4C", "5C", "6C",
            "10S", "10H", "QD", "3S", "4S", "5S", "6S", "7S", "AS", "7C",
            "BlackJoker", "9S", "8S", "7S", "6S", "5S", "4S", "3S", "2S", "RedJoker"
        ]
        
        var positions: [Int] = []
        for (index, card) in cardDistribution.enumerated() {
            if card == cardName {
                positions.append(index)
            }
        }
        return positions
    }
    
    // Check if a board position should be highlighted
    func shouldHighlight(position: Int) -> Bool {
        let cardDistribution = [
            "RedJoker", "5D", "6D", "7D", "8D", "9D", "QD", "KD", "AD", "BlackJoker",
            "5D", "3H", "2H", "2S", "3S", "4S", "5S", "6S", "7S", "AC",
            "4D", "4H", "KD", "AD", "KS", "QS", "JS", "10S", "9S", "KS",
            "2D", "5H", "QD", "KD", "6H", "7H", "8H", "9C", "8S", "QS",
            "AD", "6H", "8D", "KD", "5H", "4H", "6H", "10C", "9S", "10C",
            "AS", "7H", "9D", "3H", "4H", "7H", "9C", "JS", "8C", "9C",
            "KS", "8H", "10D", "2C", "3C", "4C", "5C", "KS", "7C", "8C",
            "QS", "9H", "JD", "KD", "AH", "2C", "3C", "4C", "5C", "6C",
            "10S", "10H", "QD", "3S", "4S", "5S", "6S", "7S", "AS", "7C",
            "BlackJoker", "9S", "8S", "7S", "6S", "5S", "4S", "3S", "2S", "RedJoker"
        ]
        
        guard position >= 0 && position < cardDistribution.count else { return false }
        let cardAtPosition = cardDistribution[position]
        return highlightedCards.contains(cardAtPosition)
    }
}
