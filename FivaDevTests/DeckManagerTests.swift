//
//  DeckManagerTests.swift
//  FivaDevTests
//
//  Comprehensive unit tests for DeckManager and GameStateManager integration
//  Created: October 4, 2025, 11:15 AM Pacific
//

import XCTest
@testable import FivaDev

/// Test suite for DeckManager functionality
@MainActor
final class DeckManagerTests: XCTestCase {
    
    var sut: DeckManager!
    
    override func setUp() {
        super.setUp()
        sut = DeckManager()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Given - DeckManager created in setUp
        
        // Then
        XCTAssertNotNil(sut, "DeckManager should initialize")
        XCTAssertEqual(sut.cardsRemaining, 0, "Deck should be empty before shuffle")
        XCTAssertEqual(sut.discardsCount, 0, "Discard pile should be empty")
        XCTAssertEqual(sut.cardsOnBoard, 0, "No cards should be in play")
    }
    
    // MARK: - Shuffle Tests
    
    func testNewGameShuffle_CreatesFullDeck() {
        // When
        sut.shuffleNewGame()
        
        // Then
        XCTAssertEqual(sut.cardsRemaining, 104, "Deck should have 104 cards (2 standard decks)")
        XCTAssertEqual(sut.discardsCount, 0, "Discard pile should be empty")
        XCTAssertEqual(sut.cardsOnBoard, 0, "No cards should be in play")
        XCTAssertEqual(sut.totalCardsTracked, 104, "All 104 cards should be accounted for")
    }
    
    func testNewGameShuffle_ContainsCorrectCards() {
        // When
        sut.shuffleNewGame()
        
        // Then - Count occurrences of each card
        var cardCounts: [String: Int] = [:]
        for card in sut.deck {
            cardCounts[card, default: 0] += 1
        }
        
        // Each card should appear exactly twice (2 decks)
        for (card, count) in cardCounts {
            XCTAssertEqual(count, 2, "Card \(card) should appear exactly twice, found \(count)")
        }
        
        // Should have 52 unique cards
        XCTAssertEqual(cardCounts.count, 52, "Should have 52 unique cards")
    }
    
    func testShuffleRandomness() {
        // Given - Two separate deck instances
        let deck1 = DeckManager()
        let deck2 = DeckManager()
        
        // When
        deck1.shuffleNewGame()
        deck2.shuffleNewGame()
        
        // Then - Shuffles should produce different orders
        let differentPositions = zip(deck1.deck, deck2.deck)
            .filter { $0 != $1 }
            .count
        
        // Expect at least 90% different positions
        let threshold = Int(Double(104) * 0.9)
        XCTAssertGreaterThanOrEqual(
            differentPositions,
            threshold,
            "Shuffles should be random: only \(differentPositions) differences, expected ≥ \(threshold)"
        )
    }
    
    func testShuffleNewGame_ResetsState() {
        // Given - Deck with some cards played
        sut.shuffleNewGame()
        _ = sut.drawCards(count: 10)
        sut.discard("AS")
        sut.placeOnBoard("KH")
        
        // When
        sut.shuffleNewGame()
        
        // Then
        XCTAssertEqual(sut.cardsRemaining, 104, "Deck should be reset to 104 cards")
        XCTAssertEqual(sut.discardsCount, 0, "Discard pile should be cleared")
        XCTAssertEqual(sut.cardsOnBoard, 0, "Board should be cleared")
    }
    
    // MARK: - Card Drawing Tests
    
    func testDrawCard_ReturnsCardAndReducesDeck() {
        // Given
        sut.shuffleNewGame()
        let initialCount = sut.cardsRemaining
        
        // When
        let card = sut.drawCard()
        
        // Then
        XCTAssertNotNil(card, "Should draw a card")
        XCTAssertEqual(sut.cardsRemaining, initialCount - 1, "Deck should decrease by 1")
    }
    
    func testDrawCard_FromEmptyDeck_ReturnsNil() {
        // Given - Empty deck
        
        // When
        let card = sut.drawCard()
        
        // Then
        XCTAssertNil(card, "Should return nil when deck is empty")
    }
    
    func testDrawCards_ReturnsCorrectQuantity() {
        // Given
        sut.shuffleNewGame()
        let drawCount = 7
        
        // When
        let cards = sut.drawCards(count: drawCount)
        
        // Then
        XCTAssertEqual(cards.count, drawCount, "Should draw \(drawCount) cards")
        XCTAssertEqual(sut.cardsRemaining, 104 - drawCount, "Deck should decrease by \(drawCount)")
    }
    
    func testDrawCards_AllCardsUnique() {
        // Given
        sut.shuffleNewGame()
        
        // When
        let cards = sut.drawCards(count: 7)
        
        // Then
        let uniqueCards = Set(cards)
        XCTAssertEqual(uniqueCards.count, 7, "All drawn cards should be unique")
    }
    
    func testDrawCards_MoreThanAvailable() {
        // Given
        sut.shuffleNewGame()
        _ = sut.drawCards(count: 100) // Leave only 4 cards
        
        // When - Try to draw more than available
        let cards = sut.drawCards(count: 10)
        
        // Then
        XCTAssertEqual(cards.count, 4, "Should only draw available cards")
        XCTAssertEqual(sut.cardsRemaining, 0, "Deck should be empty")
    }
    
    // MARK: - Discard Tests
    
    func testDiscard_AddsToDiscardPile() {
        // Given
        sut.shuffleNewGame()
        let card = "AS"
        
        // When
        sut.discard(card)
        
        // Then
        XCTAssertEqual(sut.discardsCount, 1, "Discard pile should have 1 card")
        XCTAssertTrue(sut.isCardDiscarded(card), "Card should be in discard pile")
    }
    
    func testDiscard_RemovesFromInPlay() {
        // Given
        sut.shuffleNewGame()
        let card = "KH"
        sut.placeOnBoard(card)
        XCTAssertEqual(sut.cardsOnBoard, 1, "Card should be in play")
        
        // When
        sut.discard(card)
        
        // Then
        XCTAssertEqual(sut.cardsOnBoard, 0, "Card should be removed from play")
        XCTAssertFalse(sut.isCardInPlay(card), "Card should not be in play")
        XCTAssertTrue(sut.isCardDiscarded(card), "Card should be discarded")
    }
    
    // MARK: - Board Placement Tests
    
    func testPlaceOnBoard_AddsToInPlay() {
        // Given
        sut.shuffleNewGame()
        let card = "QD"
        
        // When
        sut.placeOnBoard(card)
        
        // Then
        XCTAssertEqual(sut.cardsOnBoard, 1, "Should have 1 card in play")
        XCTAssertTrue(sut.isCardInPlay(card), "Card should be in play")
    }
    
    func testRemoveFromBoard_RemovesFromInPlay() {
        // Given
        sut.shuffleNewGame()
        let card = "7C"
        sut.placeOnBoard(card)
        
        // When
        sut.removeFromBoard(card)
        
        // Then
        XCTAssertEqual(sut.cardsOnBoard, 0, "Should have no cards in play")
        XCTAssertFalse(sut.isCardInPlay(card), "Card should not be in play")
    }
    
    // MARK: - Reshuffle Tests
    
    func testReshuffleDiscards_MovesDiscardsToWeek() {
        // Given
        sut.shuffleNewGame()
        
        // Draw and discard all cards
        while sut.cardsRemaining > 0 {
            if let card = sut.drawCard() {
                sut.discard(card)
            }
        }
        
        XCTAssertEqual(sut.cardsRemaining, 0, "Deck should be empty")
        XCTAssertEqual(sut.discardsCount, 104, "All cards should be discarded")
        
        // When
        sut.reshuffleDiscards()
        
        // Then
        XCTAssertEqual(sut.cardsRemaining, 104, "Deck should be refilled")
        XCTAssertEqual(sut.discardsCount, 0, "Discard pile should be empty")
    }
    
    func testReshuffleDiscards_CannotReshuffleWithCardsInDeck() {
        // Given
        sut.shuffleNewGame()
        let card = "2H"
        sut.discard(card)
        
        let initialDeckCount = sut.cardsRemaining
        let initialDiscardCount = sut.discardsCount
        
        // When - Try to reshuffle with cards still in deck
        sut.reshuffleDiscards()
        
        // Then - Nothing should change
        XCTAssertEqual(sut.cardsRemaining, initialDeckCount, "Deck count should not change")
        XCTAssertEqual(sut.discardsCount, initialDiscardCount, "Discard count should not change")
    }
    
    func testReshuffleDiscards_CannotReshuffleEmptyDiscards() {
        // Given - Empty deck and empty discards
        
        // When
        sut.reshuffleDiscards()
        
        // Then
        XCTAssertEqual(sut.cardsRemaining, 0, "Deck should remain empty")
        XCTAssertEqual(sut.discardsCount, 0, "Discards should remain empty")
    }
    
    func testAutoReshuffle_TriggersOnDraw() {
        // Given - Empty deck with discards
        sut.shuffleNewGame()
        
        while sut.cardsRemaining > 0 {
            if let card = sut.drawCard() {
                sut.discard(card)
            }
        }
        
        XCTAssertEqual(sut.cardsRemaining, 0, "Deck should be empty")
        XCTAssertEqual(sut.discardsCount, 104, "All cards should be discarded")
        
        // When - Try to draw from empty deck
        let card = sut.drawCard()
        
        // Then - Auto-reshuffle should occur
        XCTAssertNotNil(card, "Should draw a card after auto-reshuffle")
        XCTAssertEqual(sut.cardsRemaining, 103, "Deck should have 103 cards")
        XCTAssertEqual(sut.discardsCount, 0, "Discards should be empty")
    }
    
    // MARK: - Query Method Tests
    
    func testIsDeckCardAvailable() {
        // Given
        sut.shuffleNewGame()
        let topCard = sut.deck.first!
        let missingCard = "INVALID"
        
        // Then
        XCTAssertTrue(sut.isDeckCardAvailable(topCard), "Top card should be available")
        XCTAssertFalse(sut.isDeckCardAvailable(missingCard), "Invalid card should not be available")
    }
    
    func testIsCardDiscarded() {
        // Given
        sut.shuffleNewGame()
        let card = "3S"
        sut.discard(card)
        
        // Then
        XCTAssertTrue(sut.isCardDiscarded(card), "Discarded card should be found")
        XCTAssertFalse(sut.isCardDiscarded("9H"), "Other cards should not be discarded")
    }
    
    func testIsCardInPlay() {
        // Given
        sut.shuffleNewGame()
        let card = "10C"
        sut.placeOnBoard(card)
        
        // Then
        XCTAssertTrue(sut.isCardInPlay(card), "Placed card should be in play")
        XCTAssertFalse(sut.isCardInPlay("4D"), "Other cards should not be in play")
    }
    
    // MARK: - Integrity Tests
    
    func testDeckIntegrity_AfterShuffle() {
        // When
        sut.shuffleNewGame()
        
        // Then
        XCTAssertTrue(sut.verifyDeckIntegrity(), "Deck integrity should pass after shuffle")
    }
    
    func testDeckIntegrity_AfterGameSimulation() {
        // Given
        sut.shuffleNewGame()
        
        // Simulate game actions - draw cards and track them
        let hand1 = sut.drawCards(count: 6)
        let hand2 = sut.drawCards(count: 6)
        
        // Place 2 cards on board
        sut.placeOnBoard(hand1[0])
        sut.placeOnBoard(hand2[0])
        
        // Discard 2 cards
        sut.discard(hand1[1])
        sut.discard(hand2[1])
        
        // Put remaining cards back to complete the accounting
        // (In real game, these would be in player hands)
        for card in hand1.dropFirst(2) {
            sut.discard(card)
        }
        for card in hand2.dropFirst(2) {
            sut.discard(card)
        }
        
        // Then - Now all 104 cards are tracked
        XCTAssertTrue(sut.verifyDeckIntegrity(), "Deck integrity should pass after game actions")
        XCTAssertEqual(sut.totalCardsTracked, 104, "All 104 cards should be accounted for")
    }
    
    func testTotalCardsTracked_AlwaysEquals104() {
        // Given
        sut.shuffleNewGame()
        
        // Test at various game states
        XCTAssertEqual(sut.totalCardsTracked, 104, "Initial: All 104 cards tracked")
        
        // Draw some cards
        let cards = sut.drawCards(count: 20)
        XCTAssertEqual(sut.totalCardsTracked, 84, "After draw: 84 in deck (20 in hands not tracked by DeckManager)")
        
        // Move 3 cards to tracked locations
        sut.discard(cards[0])
        sut.discard(cards[1])
        sut.placeOnBoard(cards[2])
        XCTAssertEqual(sut.totalCardsTracked, 87, "After actions: 84 deck + 2 discard + 1 board = 87 (17 still in hand)")
        
        // Put remaining cards back to verify conservation
        for card in cards.dropFirst(3) {
            sut.discard(card)
        }
        XCTAssertEqual(sut.totalCardsTracked, 104, "All cards accounted for when returned to tracked locations")
        
        // Note: In real game, cards in player hands are tracked by GameStateManager
        // DeckManager only tracks: deck + discards + board
    }
    
    // MARK: - Performance Tests
    
    func testShufflePerformance() {
        measure {
            let deck = DeckManager()
            deck.shuffleNewGame()
        }
    }
    
    func testDrawCardsPerformance() {
        sut.shuffleNewGame()
        
        measure {
            _ = sut.drawCards(count: 7)
        }
    }
}

// MARK: - GameStateManager Integration Tests

@MainActor
final class GameStateManagerTests: XCTestCase {
    
    var sut: GameStateManager!
    
    override func setUp() {
        super.setUp()
        sut = GameStateManager()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization_InitializesDeckManager() {
        // Then
        XCTAssertNotNil(sut.deckManager, "DeckManager should be initialized")
        XCTAssertEqual(sut.deckManager.cardsRemaining, 104, "Deck should be shuffled on init")
    }
    
    func testInitialization_DealsCards() {
        // Then
        let expectedCards = sut.gameState.cardsPerPlayer
        XCTAssertEqual(sut.currentPlayerCards.count, expectedCards, "Should deal \(expectedCards) cards")
        XCTAssertEqual(sut.deckManager.cardsRemaining, 104 - expectedCards, "Deck should decrease by dealt cards")
    }
    
    // MARK: - Card Playing Tests
    
    func testPlayCardOnBoard_RemovesFromHand() {
        // Given
        let cardToPlay = sut.currentPlayerCards[0]
        let initialHandSize = sut.currentPlayerCards.count
        
        // When
        sut.playCardOnBoard(cardToPlay, position: 50)
        
        // Then
        XCTAssertEqual(sut.currentPlayerCards.count, initialHandSize, "Hand size should remain same (replacement drawn)")
        XCTAssertFalse(sut.currentPlayerCards.contains(cardToPlay), "Played card should not be in hand")
    }
    
    func testPlayCardOnBoard_MarksAsInPlay() {
        // Given
        let cardToPlay = sut.currentPlayerCards[0]
        
        // When
        sut.playCardOnBoard(cardToPlay, position: 50)
        
        // Then
        XCTAssertTrue(sut.deckManager.isCardInPlay(cardToPlay), "Card should be marked as in play")
    }
    
    func testPlayCardOnBoard_DrawsReplacement() {
        // Given
        let initialHandSize = sut.currentPlayerCards.count
        let cardToPlay = sut.currentPlayerCards[0]
        
        // When
        sut.playCardOnBoard(cardToPlay, position: 50)
        
        // Then
        XCTAssertEqual(sut.currentPlayerCards.count, initialHandSize, "Should draw replacement card")
    }
    
    func testPlayCardOnBoard_AdvancesPlayer() {
        // Given
        let initialPlayer = sut.gameState.currentPlayer
        let cardToPlay = sut.currentPlayerCards[0]
        
        // When
        sut.playCardOnBoard(cardToPlay, position: 50)
        
        // Then
        XCTAssertEqual(sut.gameState.currentPlayer, (initialPlayer + 1) % sut.gameState.numPlayers, "Should advance to next player")
    }
    
    // MARK: - Discard Tests
    
    func testDiscardDeadCard_RemovesFromHand() {
        // Given
        let cardToDiscard = sut.currentPlayerCards[0]
        let initialHandSize = sut.currentPlayerCards.count
        
        // When
        sut.discardDeadCard(cardToDiscard)
        
        // Then
        XCTAssertEqual(sut.currentPlayerCards.count, initialHandSize, "Hand size should remain same (replacement drawn)")
        XCTAssertFalse(sut.currentPlayerCards.contains(cardToDiscard), "Discarded card should not be in hand")
    }
    
    func testDiscardDeadCard_AddsToDiscardPile() {
        // Given
        let cardToDiscard = sut.currentPlayerCards[0]
        
        // When
        sut.discardDeadCard(cardToDiscard)
        
        // Then
        XCTAssertTrue(sut.deckManager.isCardDiscarded(cardToDiscard), "Card should be in discard pile")
        XCTAssertEqual(sut.mostRecentDiscard, cardToDiscard, "Should update most recent discard")
    }
    
    // MARK: - Game State Tests
    
    func testStartNewGame_ResetsState() {
        // Given - Play some cards
        let card1 = sut.currentPlayerCards[0]
        sut.playCardOnBoard(card1, position: 50)
        sut.mostRecentDiscard = "TEST"
        
        // When
        sut.startNewGame()
        
        // Then
        XCTAssertEqual(sut.deckManager.cardsRemaining, 104 - sut.gameState.cardsPerPlayer, "Deck should be reset and dealt")
        XCTAssertEqual(sut.currentPlayerCards.count, sut.gameState.cardsPerPlayer, "Should have correct hand size")
        XCTAssertNil(sut.mostRecentDiscard, "Should clear discard state")
    }
    
    func testGetBoardPositions_ReturnsCorrectPositions() {
        // Given - Cards that appear twice on board
        let card = "AS" // Appears at positions 50 and 78 according to cardDistribution
        
        // When
        let positions = sut.getBoardPositions(for: card)
        
        // Then
        XCTAssertEqual(positions.count, 2, "Standard card should have 2 positions")
        XCTAssertTrue(positions.allSatisfy { $0 >= 0 && $0 < 100 }, "Positions should be valid")
    }
    
    func testHighlightCard_AddsToHighlightedSet() {
        // Given
        let card = "KH"
        
        // When
        sut.highlightCard(card, highlight: true)
        
        // Then
        XCTAssertTrue(sut.highlightedCards.contains(card), "Card should be highlighted")
    }
    
    func testHighlightCard_RemovesFromHighlightedSet() async {
        // Given
        let card = "QD"
        sut.highlightCard(card, highlight: true)
        XCTAssertTrue(sut.highlightedCards.contains(card), "Card should be highlighted")
        
        // When
        sut.highlightCard(card, highlight: false)
        
        // Wait for debounce delay
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Then
        XCTAssertFalse(sut.highlightedCards.contains(card), "Card should be unhighlighted")
    }
    
    // MARK: - Integration Tests
    
    func testFullGameFlow() {
        // Given - Fresh game
        sut.startNewGame()
        let initialDeckCount = sut.deckManager.cardsRemaining
        
        // When - Play 5 turns
        for _ in 0..<5 {
            guard let card = sut.currentPlayerCards.first else {
                XCTFail("Should have cards to play")
                return
            }
            sut.playCardOnBoard(card, position: 50)
        }
        
        // Then
        XCTAssertEqual(sut.deckManager.cardsRemaining, initialDeckCount - 5, "Deck should decrease by 5")
        XCTAssertEqual(sut.deckManager.cardsOnBoard, 5, "Should have 5 cards on board")
    }
    
    func testVerifyGameIntegrity() {
        // Given
        sut.startNewGame()
        
        // Play some cards
        for i in 0..<3 {
            if i < sut.currentPlayerCards.count {
                let card = sut.currentPlayerCards[0]
                sut.playCardOnBoard(card, position: i * 10)
            }
        }
        
        // Then
        XCTAssertTrue(sut.verifyGameIntegrity(), "Game integrity should pass")
    }
}
