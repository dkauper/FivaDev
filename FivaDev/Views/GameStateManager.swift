//
//  GameStateManager.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/18/25.
//  Optimized: October 3, 2025, 2:45 PM Pacific - Fixed memory leak in highlightingTimeouts
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
    
    // New properties for discard overlay
    @Published var mostRecentDiscard: String? = nil
    @Published var lastCardPlayed: String? = nil
    @Published var currentPlayerName: String = "Player 1"
    
    // Track the current highlighting state to prevent rapid state changes
    private var highlightingTimeouts: [String: Task<Void, Never>] = [:]
    
    // All possible cards that could be dealt (matching game board distribution)
    private let availableCards = [
        "2H", "3H", "4H", "5H", "6H", "7H", "8H", "9H", "10H", "JH", "QH", "KH", "AH",
        "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "JD", "QD", "KD", "AD",
        "2C", "3C", "4C", "5C", "6C", "7C", "8C", "9C", "10C", "JC", "QC", "KC", "AC",
        "2S", "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "JS", "QS", "KS", "AS"
    ]
    
    // Card distribution that matches the exact board layout
    private let cardDistribution = [
        "RedJoker", "6D", "7D", "8D", "9D", "10D", "QD", "KD", "AD", "BlackJoker",
        "5D", "3H", "2H", "2S", "3S", "4S", "5S", "6S", "7S", "AC",
        "4D", "4H", "KD", "AD", "AC", "KC", "QC", "10C", "8S", "KC",
        "3D", "5H", "QD", "QH", "10H", "9H", "8H", "9C", "9S", "QC",
        "2D", "6H", "10D", "KH", "3H", "2H", "7H", "8C", "10S", "10C",
        "AS", "7H", "9D", "AH", "4H", "5H", "6H", "7C", "QS", "9C",
        "KS", "8H", "8D", "2C", "3C", "4C", "5C", "6C", "KS", "8C",
        "QS", "9H", "7D", "6D", "5D", "4D", "3D", "2D", "AS", "7C",
        "10S", "10H", "QH", "KH", "AH", "2C", "3C", "4C", "5C", "6C",
        "BlackJoker", "9S", "8S", "7S", "6S", "5S", "4S", "3S", "2S", "RedJoker"
    ]
    
    // Player names array for easy access
    private let playerNames = ["Player 1", "Player 2", "Player 3", "Player 4"]
    
    init() {
        updatePlayerCards()
        setupInitialGameState()
    }
    
    // Function to sync with your GameState and update cards
    func updatePlayerCards() {
        // Future: Use GameState.cardsPerPlayer when implementing card dealing
        // currentPlayerCards = Array(availableCards.prefix(GameState.cardsPerPlayer))
        currentPlayerCards = ["AS", "5H", "KH", "AH", "7H", "9C", "4H"]
    }
    
    // Setup initial game state for testing purposes
    private func setupInitialGameState() {
        currentPlayerName = playerNames[GameState.currentPlayer]
        
        // For demo purposes, set some sample cards
        mostRecentDiscard = "5H"
        lastCardPlayed = "8D"
    }
    
    // Function to manually trigger card update (for testing)
    func refreshCards() {
        updatePlayerCards()
    }
    
    // Function to update current player
    func updateCurrentPlayer() {
        currentPlayerName = playerNames[GameState.currentPlayer % playerNames.count]
    }
    
    // Function to simulate playing a card
    func playCard(_ cardName: String) {
        // Remove card from player's hand
        if let index = currentPlayerCards.firstIndex(of: cardName) {
            currentPlayerCards.remove(at: index)
        }
        
        // Update last card played
        lastCardPlayed = cardName
        
        // Move current discard to most recent discard
        if let currentLastCard = lastCardPlayed {
            mostRecentDiscard = currentLastCard
        }
        
        // Advance to next player
        GameState.currentPlayer = (GameState.currentPlayer + 1) % GameState.numPlayers
        updateCurrentPlayer()
        
        print("Card played: \(cardName)")
        print("Current player: \(currentPlayerName)")
    }
    
    // Function to simulate discarding a card
    func discardCard(_ cardName: String) {
        // Remove card from player's hand
        if let index = currentPlayerCards.firstIndex(of: cardName) {
            currentPlayerCards.remove(at: index)
        }
        
        // Update most recent discard
        mostRecentDiscard = cardName
        
        // Advance to next player
        GameState.currentPlayer = (GameState.currentPlayer + 1) % GameState.numPlayers
        updateCurrentPlayer()
        
        print("Card discarded: \(cardName)")
        print("Current player: \(currentPlayerName)")
    }
    
    // OPTIMIZED: Enhanced function to highlight cards on the board when hovering over player hand
    // Fixed memory leak by ensuring task cleanup on completion
    func highlightCard(_ cardName: String, highlight: Bool) {
        // Cancel any existing timeout for this card and clean up
        highlightingTimeouts[cardName]?.cancel()
        highlightingTimeouts.removeValue(forKey: cardName)
        
        if highlight {
            // Immediate highlighting
            highlightedCards.insert(cardName)
        } else {
            // Add a small delay before removing highlight to prevent flickering
            highlightingTimeouts[cardName] = Task {
                try? await Task.sleep(nanoseconds: 50_000_000) // 50ms delay
                if !Task.isCancelled {
                    highlightedCards.remove(cardName)
                    // FIXED: Clean up task from dictionary after completion
                    highlightingTimeouts.removeValue(forKey: cardName)
                }
            }
        }
    }
    
    // Function to get all board positions for a specific card
    func getBoardPositions(for cardName: String) -> [Int] {
        var positions: [Int] = []
        for (index, card) in cardDistribution.enumerated() {
            if card == cardName {
                positions.append(index)
            }
        }
        return positions
    }
    
    // Enhanced function to check if a board position should be highlighted
    func shouldHighlight(position: Int) -> Bool {
        guard position >= 0 && position < cardDistribution.count else { return false }
        let cardAtPosition = cardDistribution[position]
        return highlightedCards.contains(cardAtPosition)
    }
    
    // Function to clear all highlights (useful for debugging or resetting state)
    func clearAllHighlights() {
        // Cancel all pending timeouts
        for timeout in highlightingTimeouts.values {
            timeout.cancel()
        }
        highlightingTimeouts.removeAll()
        
        // Clear highlighted cards
        highlightedCards.removeAll()
    }
    
    #if DEBUG
    // OPTIMIZED: Debug methods moved to DEBUG builds only
    
    // Function to get highlighting debug info
    func getHighlightingDebugInfo() -> String {
        return """
        Highlighted Cards: \(Array(highlightedCards).sorted())
        Active Timeouts: \(highlightingTimeouts.keys.count)
        Player Cards: \(currentPlayerCards)
        Current Player: \(currentPlayerName)
        Most Recent Discard: \(mostRecentDiscard ?? "None")
        Last Card Played: \(lastCardPlayed ?? "None")
        """
    }
    
    // Function to test highlighting with specific card
    func testHighlight(_ cardName: String) {
        highlightCard(cardName, highlight: true)
        
        // Auto-remove after 2 seconds for testing
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            highlightCard(cardName, highlight: false)
        }
    }
    
    // Function to reset game state for testing
    func resetGameState() {
        clearAllHighlights()
        GameState.currentPlayer = 0
        updateCurrentPlayer()
        updatePlayerCards()
        mostRecentDiscard = nil
        lastCardPlayed = nil
        
        // Set some demo values after a brief delay
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            mostRecentDiscard = "5H"
            lastCardPlayed = "8D"
        }
    }
    #endif
}
