//
//  GameStateManager.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/18/25.
//  Updated: October 5, 2025, 1:40 PM Pacific - Added board layout toggle support
//  Updated: October 4, 2025, 11:10 AM Pacific - Integrated DeckManager
//  Optimized: October 3, 2025, 2:45 PM Pacific - Fixed memory leak in highlightingTimeouts
//

import SwiftUI
import Combine

@MainActor
class GameStateManager: ObservableObject {
    // MARK: - Board Layout
    
    /// Current board layout type (toggle between legacy and digital-optimized)
    @Published var currentLayoutType: BoardLayoutType = .digitalOptimized {
        didSet {
            print("🎲 GameStateManager: Board layout changed to \(currentLayoutType.rawValue)")
            // Validate the new layout
            _ = BoardLayouts.validateLayout(currentLayout)
        }
    }
    
    /// Returns the current board layout based on selected type
    var currentLayout: [String] {
        return BoardLayouts.getLayout(currentLayoutType)
    }
    
    // MARK: - Deck Management
    
    /// Centralized deck manager for card operations
    @Published var deckManager = DeckManager()
    
    // MARK: - Game State
    
    @Published var highlightedCards: Set<String> = []
    
    /// Current player's hand of cards
    @Published var currentPlayerCards: [String] = [] {
        didSet {
            // Trigger UI update when cards change
            print("🎴 GameStateManager: Player hand updated - \(currentPlayerCards.count) cards")
        }
    }
    
    // New properties for discard overlay
    @Published var mostRecentDiscard: String? = nil
    @Published var lastCardPlayed: String? = nil
    @Published var currentPlayerName: String = "Player 1"
    
    // Track the current highlighting state to prevent rapid state changes
    private var highlightingTimeouts: [String: Task<Void, Never>] = [:]
    
    // Player names array for easy access
    private let playerNames = ["Player 1", "Player 2", "Player 3", "Player 4"]
    
    // MARK: - Initialization
    
    init() {
        // Initialize deck and deal cards
        startNewGame()
    }
    
    // MARK: - Game Setup
    
    /// Starts a new game by shuffling deck and dealing cards
    func startNewGame() {
        print("🎮 GameStateManager: Starting new game...")
        
        // Shuffle deck for new game
        deckManager.shuffleNewGame()
        
        // Deal cards to current player
        dealCardsToCurrentPlayer()
        
        // Setup initial game state
        setupInitialGameState()
        
        print("✅ GameStateManager: New game ready!")
    }
    
    /// Deals initial cards to the current player
    /// Future: Extend to deal to all players
    private func dealCardsToCurrentPlayer() {
        let cardsPerPlayer = GameState.cardsPerPlayer
        currentPlayerCards = deckManager.drawCards(count: cardsPerPlayer)
        
        print("🎴 GameStateManager: Dealt \(currentPlayerCards.count) cards to \(currentPlayerName)")
        print("   Cards: \(currentPlayerCards)")
    }
    
    /// Setup initial game state for testing purposes
    private func setupInitialGameState() {
        currentPlayerName = playerNames[GameState.currentPlayer]
        
        // Clear demo values - using real deck now
        mostRecentDiscard = nil
        lastCardPlayed = nil
    }
    
    // MARK: - Card Operations
    
    /// Plays a card on the board at the specified position
    /// - Parameters:
    ///   - cardName: The card being played
    ///   - position: Board position (0-99)
    func playCardOnBoard(_ cardName: String, position: Int) {
        // Validate card is in player's hand
        guard let cardIndex = currentPlayerCards.firstIndex(of: cardName) else {
            print("⚠️ GameStateManager: Cannot play \(cardName) - not in hand")
            return
        }
        
        // Remove card from player's hand
        currentPlayerCards.remove(at: cardIndex)
        
        // Mark card as in play on board
        deckManager.placeOnBoard(cardName)
        
        // Update last card played
        lastCardPlayed = cardName
        
        // Draw replacement card
        if let newCard = deckManager.drawCard() {
            currentPlayerCards.append(newCard)
            print("🎴 GameStateManager: Drew replacement card \(newCard)")
        } else {
            print("⚠️ GameStateManager: No cards available to draw")
        }
        
        // Advance to next player
        advanceToNextPlayer()
        
        print("✅ GameStateManager: Played \(cardName) at position \(position)")
    }
    
    /// Discards a dead card (both board positions occupied)
    /// - Parameter cardName: The card to discard
    func discardDeadCard(_ cardName: String) {
        // Validate card is in player's hand
        guard let cardIndex = currentPlayerCards.firstIndex(of: cardName) else {
            print("⚠️ GameStateManager: Cannot discard \(cardName) - not in hand")
            return
        }
        
        // Remove card from player's hand
        currentPlayerCards.remove(at: cardIndex)
        
        // Add to discard pile
        deckManager.discard(cardName)
        
        // Update most recent discard
        mostRecentDiscard = cardName
        
        // Draw replacement card
        if let newCard = deckManager.drawCard() {
            currentPlayerCards.append(newCard)
            print("🎴 GameStateManager: Drew replacement card \(newCard)")
        } else {
            print("⚠️ GameStateManager: No cards available to draw")
        }
        
        // Advance to next player
        advanceToNextPlayer()
        
        print("🗑️ GameStateManager: Discarded dead card \(cardName)")
    }
    
    /// Checks if a card is dead (both board positions occupied)
    /// - Parameter cardName: Card to check
    /// - Returns: True if both positions are occupied
    func isDeadCard(_ cardName: String) -> Bool {
        let positions = getBoardPositions(for: cardName)
        
        // Jokers are never dead cards
        if cardName.contains("Joker") {
            return false
        }
        
        // Check if all positions for this card are occupied
        // TODO: Implement board occupation tracking
        // For now, return false until board state is implemented
        return false
    }
    
    // MARK: - Player Management
    
    /// Advances to the next player
    private func advanceToNextPlayer() {
        GameState.currentPlayer = (GameState.currentPlayer + 1) % GameState.numPlayers
        updateCurrentPlayer()
    }
    
    /// Updates the current player name
    func updateCurrentPlayer() {
        currentPlayerName = playerNames[GameState.currentPlayer % playerNames.count]
        print("👤 GameStateManager: Current player is now \(currentPlayerName)")
    }
    
    // MARK: - Legacy Methods (Deprecated - Use playCardOnBoard/discardDeadCard instead)
    
    /// Legacy method - use playCardOnBoard instead
    @available(*, deprecated, message: "Use playCardOnBoard(_:position:) instead")
    func playCard(_ cardName: String) {
        playCardOnBoard(cardName, position: -1)
    }
    
    /// Legacy method - use discardDeadCard instead
    @available(*, deprecated, message: "Use discardDeadCard(_:) instead")
    func discardCard(_ cardName: String) {
        discardDeadCard(cardName)
    }
    
    // MARK: - Card Highlighting
    
    /// Highlights or unhighlights cards on the board when hovering over player hand
    /// Fixed memory leak by ensuring task cleanup on completion
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
                    // Clean up task from dictionary after completion
                    highlightingTimeouts.removeValue(forKey: cardName)
                }
            }
        }
    }
    
    /// Gets all board positions for a specific card
    func getBoardPositions(for cardName: String) -> [Int] {
        var positions: [Int] = []
        for (index, card) in currentLayout.enumerated() {
            if card == cardName {
                positions.append(index)
            }
        }
        return positions
    }
    
    /// Checks if a board position should be highlighted
    func shouldHighlight(position: Int) -> Bool {
        guard position >= 0 && position < currentLayout.count else { return false }
        let cardAtPosition = currentLayout[position]
        return highlightedCards.contains(cardAtPosition)
    }
    
    // MARK: - Board Layout Management
    
    /// Toggles between board layouts
    func toggleBoardLayout() {
        currentLayoutType = (currentLayoutType == .legacy) ? .digitalOptimized : .legacy
    }
    
    /// Sets a specific board layout
    func setBoardLayout(_ type: BoardLayoutType) {
        currentLayoutType = type
    }
    
    /// Clears all card highlights
    func clearAllHighlights() {
        // Cancel all pending timeouts
        for timeout in highlightingTimeouts.values {
            timeout.cancel()
        }
        highlightingTimeouts.removeAll()
        
        // Clear highlighted cards
        highlightedCards.removeAll()
    }
    
    // MARK: - Debug Methods
    
    #if DEBUG
    
    /// Gets comprehensive game state debug info
    func getDebugInfo() -> String {
        return """
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        🎮 GAME STATE DEBUG INFO
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        🎲 Board Layout: \(currentLayoutType.rawValue)
        👤 Current Player: \(currentPlayerName)
        🎴 Hand Size: \(currentPlayerCards.count) cards
        ✨ Highlighted: \(Array(highlightedCards).sorted())
        🎯 Last Played: \(lastCardPlayed ?? "None")
        🗑️ Last Discard: \(mostRecentDiscard ?? "None")
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        \(deckManager.getDebugInfo())
        """
    }
    
    /// Gets highlighting debug info
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
    
    /// Tests highlighting with a specific card
    func testHighlight(_ cardName: String) {
        highlightCard(cardName, highlight: true)
        
        // Auto-remove after 2 seconds for testing
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            highlightCard(cardName, highlight: false)
        }
    }
    
    /// Resets entire game state for testing
    func resetGameState() {
        print("🔄 GameStateManager: Resetting game state...")
        
        clearAllHighlights()
        GameState.currentPlayer = 0
        
        // Start fresh game
        startNewGame()
    }
    
    /// Simulates a full game turn for testing
    func simulateGameTurn() {
        guard let card = currentPlayerCards.first else {
            print("⚠️ GameStateManager: No cards to play")
            return
        }
        
        // Simulate playing the first card
        playCardOnBoard(card, position: 50)
    }
    
    /// Verifies game state integrity
    func verifyGameIntegrity() -> Bool {
        let deckIntegrity = deckManager.verifyDeckIntegrity()
        let handSize = currentPlayerCards.count
        let expectedHandSize = GameState.cardsPerPlayer
        
        let handValid = handSize <= expectedHandSize
        
        if deckIntegrity && handValid {
            print("✅ GameStateManager: Integrity check passed")
        } else {
            print("❌ GameStateManager: Integrity check FAILED")
            if !deckIntegrity {
                print("   - Deck integrity failed")
            }
            if !handValid {
                print("   - Hand size invalid: \(handSize) (expected ≤ \(expectedHandSize))")
            }
        }
        
        return deckIntegrity && handValid
    }
    
    #endif
}
