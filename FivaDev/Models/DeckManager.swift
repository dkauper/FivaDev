//
//  DeckManager.swift
//  FivaDev
//
//  Comprehensive deck management system with secure shuffling
//  Created: October 4, 2025, 10:45 AM Pacific
//

import Foundation
import Combine

/// Manages card deck operations including shuffling, drawing, and discard pile management
@MainActor
class DeckManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current deck of cards available to draw
    @Published private(set) var deck: [String] = []
    
    /// Discard pile accumulating played cards
    @Published private(set) var discardPile: [String] = []
    
    /// Cards currently placed on the board
    @Published private(set) var cardsInPlay: Set<String> = []
    
    // MARK: - Private Properties
    
    /// Cryptographically secure random number generator for thorough shuffling
    private var rng = SystemRandomNumberGenerator()
    
    /// All standard playing cards (52 cards per deck, 2 decks = 104 cards)
    /// Excludes jokers as they are fixed board positions, not dealt cards
    private let standardDeck: [String] = {
        let suits = ["H", "D", "C", "S"] // Hearts, Diamonds, Clubs, Spades
        let ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
        
        var cards: [String] = []
        
        // Create two complete decks (2 × 52 = 104 cards)
        for _ in 0..<2 {
            for suit in suits {
                for rank in ranks {
                    cards.append("\(rank)\(suit)")
                }
            }
        }
        
        return cards
    }()
    
    // MARK: - Initialization
    
    init() {
        print("🃏 DeckManager: Initializing with \(standardDeck.count) cards")
    }
    
    // MARK: - Primary Deck Operations
    
    /// Shuffles the deck for the beginning of a new game
    /// Uses Fisher-Yates shuffle algorithm with cryptographically secure RNG
    func shuffleNewGame() {
        print("🔀 DeckManager: Starting new game shuffle...")
        
        // Reset all state
        discardPile.removeAll()
        cardsInPlay.removeAll()
        
        // Create fresh deck from standard cards
        deck = standardDeck
        
        // Perform secure shuffle
        shuffleDeck()
        
        print("✅ DeckManager: New game deck ready with \(deck.count) cards")
    }
    
    /// Reshuffles the discard pile when the main deck is depleted
    /// This maintains game continuity without ending prematurely
    func reshuffleDiscards() {
        guard deck.isEmpty else {
            print("⚠️ DeckManager: Cannot reshuffle - deck still has \(deck.count) cards")
            return
        }
        
        guard !discardPile.isEmpty else {
            print("⚠️ DeckManager: Cannot reshuffle - discard pile is empty")
            return
        }
        
        print("🔄 DeckManager: Reshuffling discard pile (\(discardPile.count) cards)...")
        
        // Move discards to deck
        deck = discardPile
        discardPile.removeAll()
        
        // Perform secure shuffle
        shuffleDeck()
        
        print("✅ DeckManager: Deck replenished with \(deck.count) cards")
    }
    
    /// Draws the top card from the deck
    /// Automatically triggers reshuffle if deck is empty but discards exist
    /// - Returns: The drawn card, or nil if no cards available
    func drawCard() -> String? {
        // Check if reshuffle is needed
        if deck.isEmpty && !discardPile.isEmpty {
            print("🔄 DeckManager: Deck empty, auto-reshuffling discards...")
            reshuffleDiscards()
        }
        
        guard let card = deck.first else {
            print("⚠️ DeckManager: Cannot draw - no cards available")
            return nil
        }
        
        deck.removeFirst()
        print("🎴 DeckManager: Drew card \(card). \(deck.count) cards remaining")
        
        return card
    }
    
    /// Draws multiple cards from the deck
    /// - Parameter count: Number of cards to draw
    /// - Returns: Array of drawn cards (may be fewer than requested if deck runs out)
    func drawCards(count: Int) -> [String] {
        var drawnCards: [String] = []
        
        for _ in 0..<count {
            if let card = drawCard() {
                drawnCards.append(card)
            } else {
                break
            }
        }
        
        print("🎴 DeckManager: Drew \(drawnCards.count) cards: \(drawnCards)")
        return drawnCards
    }
    
    // MARK: - Card Movement
    
    /// Adds a card to the discard pile
    /// - Parameter card: The card to discard
    func discard(_ card: String) {
        discardPile.append(card)
        cardsInPlay.remove(card)
        print("🗑️ DeckManager: Discarded \(card). Discard pile: \(discardPile.count)")
    }
    
    /// Marks a card as placed on the board (in play)
    /// - Parameter card: The card placed on board
    func placeOnBoard(_ card: String) {
        cardsInPlay.insert(card)
        print("🎲 DeckManager: Placed \(card) on board. Cards in play: \(cardsInPlay.count)")
    }
    
    /// Removes a card from board (e.g., picked up by one-eyed Jack)
    /// - Parameter card: The card to remove from play
    func removeFromBoard(_ card: String) {
        cardsInPlay.remove(card)
        print("↩️ DeckManager: Removed \(card) from board. Cards in play: \(cardsInPlay.count)")
    }
    
    // MARK: - Core Shuffle Algorithm
    
    /// Performs Fisher-Yates shuffle using cryptographically secure RNG
    /// This ensures truly random card distribution with O(n) complexity
    /// Time complexity: O(n) where n is the number of cards
    /// Space complexity: O(1) as it shuffles in-place
    private func shuffleDeck() {
        // Fisher-Yates shuffle algorithm
        // For each position from the end to the beginning:
        //   - Pick a random card from remaining unshuffled cards
        //   - Swap with current position
        // This guarantees each permutation is equally likely
        
        for i in (1..<deck.count).reversed() {
            // Generate secure random index from 0...i
            let j = Int.random(in: 0...i, using: &rng)
            
            // Swap cards at positions i and j
            deck.swapAt(i, j)
        }
        
        print("🔀 DeckManager: Shuffled \(deck.count) cards using Fisher-Yates algorithm")
    }
    
    // MARK: - Query Methods
    
    /// Returns the number of cards remaining in the deck
    var cardsRemaining: Int {
        deck.count
    }
    
    /// Returns the number of cards in the discard pile
    var discardsCount: Int {
        discardPile.count
    }
    
    /// Returns the number of cards currently on the board
    var cardsOnBoard: Int {
        cardsInPlay.count
    }
    
    /// Returns total cards accounted for (should equal 104 when all cards distributed)
    var totalCardsTracked: Int {
        deck.count + discardPile.count + cardsInPlay.count
    }
    
    /// Checks if a specific card is available in the deck
    /// - Parameter card: Card to check for
    /// - Returns: true if card is in deck
    func isDeckCardAvailable(_ card: String) -> Bool {
        deck.contains(card)
    }
    
    /// Checks if a specific card is in the discard pile
    /// - Parameter card: Card to check for
    /// - Returns: true if card is in discard pile
    func isCardDiscarded(_ card: String) -> Bool {
        discardPile.contains(card)
    }
    
    /// Checks if a specific card is in play on the board
    /// - Parameter card: Card to check for
    /// - Returns: true if card is on board
    func isCardInPlay(_ card: String) -> Bool {
        cardsInPlay.contains(card)
    }
    
    // MARK: - Debug & Testing
    
    #if DEBUG
    /// Returns detailed state information for debugging
    func getDebugInfo() -> String {
        return """
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        🃏 DECK MANAGER DEBUG INFO
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        📚 Deck: \(deck.count) cards
        🗑️ Discards: \(discardPile.count) cards
        🎲 In Play: \(cardsInPlay.count) cards
        📊 Total: \(totalCardsTracked) / 104 cards
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        Top 5 deck: \(deck.prefix(5))
        Last 5 discards: \(discardPile.suffix(5))
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        """
    }
    
    /// Prints the entire deck state (use sparingly)
    func printFullDeckState() {
        print(getDebugInfo())
        print("Full Deck: \(deck)")
        print("Full Discards: \(discardPile)")
        print("Cards in Play: \(Array(cardsInPlay).sorted())")
    }
    
    /// Verifies deck integrity (all 104 cards accounted for)
    func verifyDeckIntegrity() -> Bool {
        let allCards = Set(deck + discardPile + Array(cardsInPlay))
        let expectedCards = Set(standardDeck)
        
        let isValid = allCards == expectedCards && totalCardsTracked == 104
        
        if isValid {
            print("✅ DeckManager: Integrity check passed - all 104 cards accounted for")
        } else {
            print("❌ DeckManager: Integrity check FAILED!")
            print("   Expected: 104 cards")
            print("   Found: \(totalCardsTracked) cards")
            print("   Missing: \(expectedCards.subtracting(allCards))")
            print("   Extra: \(allCards.subtracting(expectedCards))")
        }
        
        return isValid
    }
    
    /// Simulates dealing cards to players for testing
    /// - Parameters:
    ///   - playerCount: Number of players (2-12)
    ///   - cardsPerPlayer: Cards to deal each player (optional, uses GameState calculation if nil)
    /// - Returns: Array of player hands
    func simulateDealToPlayers(playerCount: Int, cardsPerPlayer: Int? = nil) -> [[String]] {
        let gameState = GameState(numPlayers: playerCount)
        let cardsEach = cardsPerPlayer ?? gameState.cardsPerPlayer
        var playerHands: [[String]] = []
        
        print("🎴 DeckManager: Simulating deal to \(playerCount) players (\(cardsEach) cards each)...")
        
        for playerIndex in 0..<playerCount {
            let hand = drawCards(count: cardsEach)
            playerHands.append(hand)
            print("   Player \(playerIndex + 1): \(hand)")
        }
        
        return playerHands
    }
    #endif
}
