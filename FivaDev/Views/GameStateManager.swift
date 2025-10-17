//
//  GameStateManager.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/18/25.
//  Updated: October 12, 2025, 11:59 PM Pacific - Added dead card auto-detection with tooltip
//  Updated: October 12, 2025, 11:40 PM Pacific - Two-eyed Jacks show no highlights (wild placement)
//  Updated: October 12, 2025, 11:35 PM Pacific - Fixed one-eyed Jack highlighting (position-based)
//  Updated: October 12, 2025, 11:20 PM Pacific - Integrated Jack special rules with CardPlayValidator
//  Updated: October 12, 2025, 9:50 PM Pacific - Added 5-in-a-row detection system
//  Updated: October 12, 2025, 1:30 PM Pacific - Added multi-player hand tracking
//  Updated: October 12, 2025, 6:10 PM Pacific - Refactored to use GameState model
//  Updated: October 11, 2025, 7:45 PM Pacific - Update discard overlay on chip placement
//  Updated: October 11, 2025, 5:20 PM Pacific - Added chip placement system
//  Updated: October 5, 2025, 1:40 PM Pacific - Added board layout toggle support
//  Updated: October 4, 2025, 11:10 AM Pacific - Integrated DeckManager
//  Optimized: October 3, 2025, 2:45 PM Pacific - Fixed memory leak in highlightingTimeouts
//

import SwiftUI
import Combine

// MARK: - FIVA Detection Models

/// Represents a completed 5-in-a-row (FIVA)
struct CompletedFIVA: Equatable {
    let positions: Set<Int>
    let color: PlayerColor
    let direction: FIVADirection
    
    enum FIVADirection: String {
        case horizontal = "Horizontal"
        case vertical = "Vertical"
        case diagonalDown = "Diagonal ↘"
        case diagonalUp = "Diagonal ↗"
    }
}

/// Represents a dead card notification for UI display
struct DeadCardNotification: Equatable {
    let cardName: String
    let timestamp: Date = Date()
}

// MARK: - GameStateManager

@MainActor
class GameStateManager: ObservableObject {
    // MARK: - Game Configuration
    
    /// Game configuration (will be set by pre-game dialog in future)
//    @Published var gameState: GameState = .threePlayer {
        @Published var gameState: GameState = GameState(numPlayers: 3, numTeams: 3) {
        didSet {
            // Sync player names when game state changes
            updatePlayerNames()
            print("🎮 GameStateManager: Game configured for \(gameState.numPlayers) players")
        }
    }
    
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
    
    /// Audio manager for game sounds
    @Published var audioManager = AudioManager()

    /// Win state tracking
    @Published var winningTeam: PlayerColor? = nil
    @Published var showWinOverlay: Bool = false
    
    // MARK: - Deck Management
    
    /// Centralized deck manager for card operations
    @Published var deckManager = DeckManager()
    
    // MARK: - Player Hand Management
    
    /// Stores each player's hand of cards
    /// Key: player index (0-11), Value: array of card names
    @Published private var playerHands: [Int: [String]] = [:]
    
    // MARK: - Board State (Chip Placement)
    
    /// Tracks which player occupies each board position
    /// Key: board position (0-99), Value: player color
    @Published var boardState: [Int: PlayerColor] = [:]
    
    /// Corner positions (free spaces for all players)
    private let cornerPositions: Set<Int> = [0, 9, 90, 99]
    
    // MARK: - FIVA Tracking
    
    /// Tracks all completed FIVAs to prevent chip removal
    @Published var completedFIVAs: [CompletedFIVA] = []
    
    /// Tracks FIVA count per team
    @Published var teamFIVACount: [PlayerColor: Int] = [:]
    
    // MARK: - Game State
    
    @Published var highlightedCards: Set<String> = []
    @Published var highlightedPositions: Set<Int> = []  // For one-eyed Jack targeting
    
    /// Index of selected card in player's hand (for placement)
    @Published var selectedCardIndex: Int? = nil
    
    /// Current player's hand of cards (computed from playerHands)
    var currentPlayerCards: [String] {
        get {
            return playerHands[gameState.currentPlayer] ?? []
        }
        set {
            playerHands[gameState.currentPlayer] = newValue
            print("🎴 GameStateManager: Player \(gameState.currentPlayer) hand updated - \(newValue.count) cards")
        }
    }
    
    // New properties for discard overlay
    @Published var mostRecentDiscard: String? = nil
    @Published var lastCardPlayed: String? = nil
    @Published var currentPlayerName: String = "Player 1"
    
    /// Dead card notification state (for tooltip display)
    @Published var deadCardNotification: DeadCardNotification? = nil
    
    // Track the current highlighting state to prevent rapid state changes
    private var highlightingTimeouts: [String: Task<Void, Never>] = [:]
    
    // MARK: - Initialization
    
    init() {
        let instanceID = UUID().uuidString.prefix(8)
        print("❗️ GameStateManager.init() called - Instance: \(instanceID)")
        // Initialize deck and deal cards
        startNewGame()
    }
    
    // MARK: - Game Configuration
    
    /// Configures game for new match (called by pre-game dialog or testing)
    /// - Parameters:
    ///   - players: Number of players (2-12)
    ///   - teams: Number of teams (2-3)
    ///   - names: Player names
    ///   - teamAssignments: Optional custom team assignments
    func configureGame(players: Int, teams: Int, names: [String], teamAssignments: [Int]? = nil) {
        gameState.configure(players: players, teams: teams, names: names, teamAssignments: teamAssignments)
        startNewGame()
    }
    
    /// Updates internal player name tracking from game state
    private func updatePlayerNames() {
        currentPlayerName = gameState.currentPlayerName
    }
    
    // MARK: - Game Setup
    
    /// Starts a new game by shuffling deck and dealing cards
    func startNewGame() {
        print("🎮 GameStateManager: Starting new game...")
        
        // Clear board state
        boardState.removeAll()
        
        // Clear FIVA tracking
        completedFIVAs.removeAll()
        teamFIVACount.removeAll()
        
        // Clear player hands
        playerHands.removeAll()
        
        // Reset game state
        gameState.resetForNewGame()
        
        // Shuffle deck for new game
        deckManager.shuffleNewGame()
        
        // Deal cards to ALL players
        dealCardsToAllPlayers()
        
        // Setup initial game state
        setupInitialGameState()
        
        print("✅ GameStateManager: New game ready!")
        print("   Players: \(gameState.numPlayers)")
        print("   Cards per player: \(gameState.cardsPerPlayer)")
        print("   FIVAs to win: \(gameState.fivasToWin)")
    }
    
    /// Deals initial cards to all players
    private func dealCardsToAllPlayers() {
        let cardsPerPlayer = gameState.cardsPerPlayer
        
        // Clear existing hands
        playerHands.removeAll()
        
        // Deal to each player
        for playerIndex in 0..<gameState.numPlayers {
            let cards = deckManager.drawCards(count: cardsPerPlayer)
            playerHands[playerIndex] = cards
            print("🎴 GameStateManager: Dealt \(cards.count) cards to Player \(playerIndex + 1)")
        }
        
        // Log current player's hand
        print("   Current player (\(currentPlayerName)) hand: \(currentPlayerCards)")
    }
    
    /// Setup initial game state for testing purposes
    private func setupInitialGameState() {
        currentPlayerName = gameState.currentPlayerName
        
        // Clear demo values - using real deck now
        mostRecentDiscard = nil
        lastCardPlayed = nil
    }
    
    // MARK: - Chip Placement
    
    /// Places a chip on the board at the specified position
    /// - Parameters:
    ///   - position: Board position (0-99)
    ///   - playerColor: Color of the chip to place
    /// - Returns: True if placement was successful
    @discardableResult
    func placeChip(at position: Int, color playerColor: PlayerColor) -> Bool {
        // Validate position
        guard position >= 0 && position < 100 else {
            print("⚠️ GameStateManager: Invalid position \(position)")
            return false
        }
        
        // Check if position is already occupied
        if isPositionOccupied(position) {
            print("⚠️ GameStateManager: Position \(position) already occupied")
            return false
        }
        
        // Place chip
        boardState[position] = playerColor
        print("🎯 GameStateManager: Placed \(playerColor.rawValue) chip at position \(position)")
        
        return true
    }
    
    /// Removes a chip from the board at the specified position
    /// - Parameter position: Board position (0-99)
    /// - Returns: True if removal was successful
    @discardableResult
    func removeChip(at position: Int) -> Bool {
        // Validate position
        guard position >= 0 && position < 100 else {
            print("⚠️ GameStateManager: Invalid position \(position)")
            return false
        }
        
        // Check if position is occupied
        guard boardState[position] != nil else {
            print("⚠️ GameStateManager: No chip at position \(position)")
            return false
        }
        
        // Prevent removal from completed FIVAs
        if isPartOfCompletedFIVA(position) {
            print("🚫 GameStateManager: Cannot remove chip at \(position) - part of completed FIVA")
            return false
        }
        
        // Remove chip
        let removedColor = boardState[position]!
        boardState.removeValue(forKey: position)
        print("🗑️ GameStateManager: Removed \(removedColor.rawValue) chip from position \(position)")
        
        return true
    }
    
    /// Checks if a board position is occupied
    /// - Parameter position: Board position (0-99)
    /// - Returns: True if position has a chip
    func isPositionOccupied(_ position: Int) -> Bool {
        return boardState[position] != nil
    }
    
    /// Gets the player color at a specific position
    /// - Parameter position: Board position (0-99)
    /// - Returns: Player color if occupied, nil otherwise
    func getChipColor(at position: Int) -> PlayerColor? {
        return boardState[position]
    }
    
    /// Checks if a position is a corner (free space)
    /// - Parameter position: Board position (0-99)
    /// - Returns: True if position is a corner
    func isCornerPosition(_ position: Int) -> Bool {
        return cornerPositions.contains(position)
    }
    
    // MARK: - Card Operations
    
    /// Plays a card on the board at the specified position with Jack rule validation
    /// - Parameters:
    ///   - cardName: The card being played
    ///   - position: Board position (0-99)
    func playCardOnBoard(_ cardName: String, position: Int) {
        // Validate card is in player's hand
        guard let cardIndex = currentPlayerCards.firstIndex(of: cardName) else {
            print("⚠️ GameStateManager: Cannot play \(cardName) - not in hand")
            return
        }
        
        // Validate play using Jack-aware validator
        let validationResult = validateCardPlay(cardName, at: position)
        
        guard case .valid(let action) = validationResult else {
            if let error = validationResult.errorMessage {
                print("⚠️ GameStateManager: \(error)")
            }
            return
        }
        
        let playerColor = currentPlayerColor
        
        // Execute the validated action
        switch action {
        case .placeChip(let pos):
            // Place chip on board
            if placeChip(at: pos, color: playerColor) {
                handleSuccessfulPlay(cardName: cardName, cardIndex: cardIndex, position: pos)
            }
            
        case .removeChip(let pos):
            // Remove opponent's chip (one-eyed Jack)
            if removeChip(at: pos) {
                print("🃏 GameStateManager: One-eyed Jack removed opponent chip at position \(pos)")
                handleSuccessfulPlay(cardName: cardName, cardIndex: cardIndex, position: pos)
            }
        }
    }
    
    /// Handles post-play actions after successful card play
    private func handleSuccessfulPlay(cardName: String, cardIndex: Int, position: Int) {
        // Check for completed FIVAs (only if chip was placed, not removed)
        if let chipColor = boardState[position] {
            let newFIVAs = checkForNewFIVAs(at: position, color: chipColor)
            if !newFIVAs.isEmpty {
                print("🎉 GameStateManager: Completed \(newFIVAs.count) FIVA(s)!")
                
                // Check for winner
                if let winner = checkForWinner() {
                    print("🏆 GameStateManager: GAME OVER! \(winner.rawValue) team wins!")
                }
            }
        }
        
        // Remove card from player's hand
        currentPlayerCards.remove(at: cardIndex)
        
        // Mark card as in play or discarded
        deckManager.placeOnBoard(cardName)
        
        // Update last card played
        lastCardPlayed = cardName
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
        
        // Jacks are never dead (wild cards)
        if cardName.contains("J") {
            return false
        }
        
        // Check if all positions for this card are occupied
        return positions.allSatisfy { isPositionOccupied($0) }
    }
    
    // MARK: - FIVA Detection
    
    /// Checks if placing a chip creates any new FIVAs
    /// - Parameters:
    ///   - position: Position where chip was just placed
    ///   - color: Color of the chip
    /// - Returns: Array of newly completed FIVAs
    @discardableResult
    func checkForNewFIVAs(at position: Int, color: PlayerColor) -> [CompletedFIVA] {
        var newFIVAs: [CompletedFIVA] = []
        
        // Check all 4 directions
        if let fiva = checkHorizontalFIVA(at: position, color: color) {
            if !completedFIVAs.contains(fiva) {
                newFIVAs.append(fiva)
                completedFIVAs.append(fiva)
            }
        }
        
        if let fiva = checkVerticalFIVA(at: position, color: color) {
            if !completedFIVAs.contains(fiva) {
                newFIVAs.append(fiva)
                completedFIVAs.append(fiva)
            }
        }
        
        if let fiva = checkDiagonalDownFIVA(at: position, color: color) {
            if !completedFIVAs.contains(fiva) {
                newFIVAs.append(fiva)
                completedFIVAs.append(fiva)
            }
        }
        
        if let fiva = checkDiagonalUpFIVA(at: position, color: color) {
            if !completedFIVAs.contains(fiva) {
                newFIVAs.append(fiva)
                completedFIVAs.append(fiva)
            }
        }
        
        // Update team FIVA count
        if !newFIVAs.isEmpty {
            teamFIVACount[color, default: 0] += newFIVAs.count
            print("🎉 GameStateManager: \(color.rawValue) completed \(newFIVAs.count) FIVA(s)!")
            print("   Total FIVAs for \(color.rawValue): \(teamFIVACount[color] ?? 0)")
        }
        
        return newFIVAs
    }
    
    // MARK: - Direction-Specific FIVA Checks
    
    /// Checks horizontal line (row)
    private func checkHorizontalFIVA(at position: Int, color: PlayerColor) -> CompletedFIVA? {
        let row = position / 10
        let startPos = row * 10
        
        // Scan the entire row for sequences of 5
        for col in 0...5 {  // Can start at columns 0-5 for a 5-length sequence
            let positions = (0..<5).map { startPos + col + $0 }
            if isValidFIVA(positions: positions, color: color) {
                return CompletedFIVA(
                    positions: Set(positions),
                    color: color,
                    direction: .horizontal
                )
            }
        }
        return nil
    }
    
    /// Checks vertical line (column)
    private func checkVerticalFIVA(at position: Int, color: PlayerColor) -> CompletedFIVA? {
        let col = position % 10
        
        // Scan the entire column for sequences of 5
        for row in 0...5 {  // Can start at rows 0-5 for a 5-length sequence
            let positions = (0..<5).map { (row + $0) * 10 + col }
            if isValidFIVA(positions: positions, color: color) {
                return CompletedFIVA(
                    positions: Set(positions),
                    color: color,
                    direction: .vertical
                )
            }
        }
        return nil
    }
    
    /// Checks diagonal down-right (↘)
    private func checkDiagonalDownFIVA(at position: Int, color: PlayerColor) -> CompletedFIVA? {
        let row = position / 10
        let col = position % 10
        
        // Find leftmost position in this diagonal that could start a FIVA
        let startRow = max(0, row - min(row, col))
        let startCol = max(0, col - min(row, col))
        
        // Check all possible 5-length sequences on this diagonal
        var checkRow = startRow
        var checkCol = startCol
        
        while checkRow <= 5 && checkCol <= 5 {  // Can fit a 5-length sequence
            let positions = (0..<5).map { (checkRow + $0) * 10 + (checkCol + $0) }
            if isValidFIVA(positions: positions, color: color) {
                return CompletedFIVA(
                    positions: Set(positions),
                    color: color,
                    direction: .diagonalDown
                )
            }
            checkRow += 1
            checkCol += 1
        }
        return nil
    }
    
    /// Checks diagonal up-right (↗)
    private func checkDiagonalUpFIVA(at position: Int, color: PlayerColor) -> CompletedFIVA? {
        let row = position / 10
        let col = position % 10
        
        // Find leftmost position in this diagonal that could start a FIVA
        let startRow = min(9, row + min(9 - row, col))
        let startCol = max(0, col - min(9 - row, col))
        
        // Check all possible 5-length sequences on this diagonal
        var checkRow = startRow
        var checkCol = startCol
        
        while checkRow >= 4 && checkCol <= 5 {  // Can fit a 5-length sequence
            let positions = (0..<5).map { (checkRow - $0) * 10 + (checkCol + $0) }
            if isValidFIVA(positions: positions, color: color) {
                return CompletedFIVA(
                    positions: Set(positions),
                    color: color,
                    direction: .diagonalUp
                )
            }
            checkRow -= 1
            checkCol += 1
        }
        return nil
    }
    
    // MARK: - FIVA Validation
    
    /// Validates if 5 positions form a valid FIVA for a color
    /// Handles corner wildcards (any player can use)
    private func isValidFIVA(positions: [Int], color: PlayerColor) -> Bool {
        guard positions.count == 5 else { return false }
        
        for position in positions {
            // Corner positions count as wildcards (free for all)
            if cornerPositions.contains(position) {
                continue
            }
            
            // Position must be occupied by this color
            if let occupyingColor = boardState[position] {
                if occupyingColor != color {
                    return false
                }
            } else {
                return false  // Position must be occupied
            }
        }
        
        return true
    }
    
    /// Checks if a position is part of any completed FIVA
    /// Used to prevent chip removal from completed FIVAs
    func isPartOfCompletedFIVA(_ position: Int) -> Bool {
        return completedFIVAs.contains { fiva in
            fiva.positions.contains(position)
        }
    }
    
    /// Gets the FIVA color for a position if it's part of a completed FIVA
    /// - Parameter position: Board position (0-99)
    /// - Returns: PlayerColor if position is part of a FIVA, nil otherwise
    func getFIVAColor(at position: Int) -> PlayerColor? {
        for fiva in completedFIVAs {
            if fiva.positions.contains(position) {
                return fiva.color
            }
        }
        return nil
    }
    
    // MARK: - Win Condition Check
    
    /// Checks if any team has won the game
    /// - Returns: Winning color if game is won, nil otherwise
    func checkForWinner() -> PlayerColor? {
        let fivasNeeded = gameState.fivasToWin
        
        for (color, count) in teamFIVACount {
            if count >= fivasNeeded {
                print("🏆 GameStateManager: \(color.rawValue) WINS with \(count) FIVA(s)!")
                
                // ⭐️ NEW: Trigger win celebration
                winningTeam = color
                showWinOverlay = true
                audioManager.playCrowdCheer()
                
                return color
            }
        }
        
        return nil
    }
    
    /// Dismisses win overlay and starts new game
    func dismissWinOverlay() {
        showWinOverlay = false
        winningTeam = nil
        audioManager.stopAudio()
        resetGameState()
    }
    
    // MARK: - Player Management
    
    /// Advances to the next player and restores their hand
    private func advanceToNextPlayer() {
        let previousPlayer = gameState.currentPlayer
        let previousHand = currentPlayerCards
        
        gameState.advanceToNextPlayer()
        
        // Verify hand was preserved
        let restoredHand = currentPlayerCards
        
        print("👤 GameStateManager: Switched from Player \(previousPlayer + 1) to Player \(gameState.currentPlayer + 1)")
        print("   Previous hand size: \(previousHand.count)")
        print("   Restored hand size: \(restoredHand.count)")
        
        updateCurrentPlayer()
    }
    
    /// Updates the current player name
    func updateCurrentPlayer() {
        currentPlayerName = gameState.currentPlayerName
        print("👤 GameStateManager: Current player is now \(currentPlayerName)")
    }
    
    /// Gets current player's color
    var currentPlayerColor: PlayerColor {
        return gameState.colorFor(player: gameState.currentPlayer)
    }
    
    // MARK: - Card Selection
    
    /// Selects a card from the player's hand with dead card detection
    /// - Parameter index: Index of the card in the hand
    func selectCard(at index: Int) {
        guard index >= 0 && index < currentPlayerCards.count else {
            print("⚠️ GameStateManager: Invalid card index \(index)")
            return
        }
        
        let cardName = currentPlayerCards[index]
        
        // ⚡️ DEAD CARD DETECTION: Auto-discard if both positions occupied
        if isDeadCard(cardName) {
            print("💀 GameStateManager: Dead card detected: \(cardName)")
            
            // Show notification
            deadCardNotification = DeadCardNotification(cardName: cardName)
            
            // Auto-discard and replace
            discardDeadCard(cardName)
            
            // Clear notification after 2 seconds
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                if deadCardNotification?.cardName == cardName {
                    deadCardNotification = nil
                }
            }
            
            return
        }
        
        // Normal selection flow
        selectedCardIndex = index
        print("🎴 GameStateManager: Selected card \(cardName) at index \(index)")
        print("   Valid positions will be highlighted...")
        
        // Highlight valid positions for this card
        highlightValidPositions(for: cardName)
    }
    
    /// Deselects the currently selected card
    func deselectCard() {
        selectedCardIndex = nil
        clearAllHighlights()
        print("🎴 GameStateManager: Deselected card")
    }
    
    /// Gets the currently selected card name
    var selectedCardName: String? {
        guard let index = selectedCardIndex,
              index >= 0 && index < currentPlayerCards.count else {
            return nil
        }
        return currentPlayerCards[index]
    }
    
    /// Highlights valid positions for a card (Jack-aware)
    private func highlightValidPositions(for cardName: String) {
        clearAllHighlights()
        
        // Use the CardPlayValidator extension method
        highlightValidPositionsForCard(cardName)
    }
    
    /// Attempts to play the selected card at the specified position
    /// - Parameter position: Board position to place the card
    /// - Returns: True if the card was successfully played
    @discardableResult
    func playSelectedCard(at position: Int) -> Bool {
        print("🎯 GameStateManager: Attempting to play at position \(position)")
        
        guard let cardIndex = selectedCardIndex else {
            print("⚠️ GameStateManager: No card selected")
            return false
        }
        
        guard cardIndex >= 0 && cardIndex < currentPlayerCards.count else {
            print("⚠️ GameStateManager: Invalid selected card index \(cardIndex)")
            return false
        }
        
        let cardName = currentPlayerCards[cardIndex]
        print("   Playing card: \(cardName)")
        
        // Play the card
        playCardOnBoard(cardName, position: position)
        
        // Deselect after playing
        deselectCard()
        
        return true
    }
    
    // MARK: - Card Playability Helpers
    
    /// Checks if a card can be played at any position on the board
    /// - Parameter cardName: Card to check
    /// - Returns: True if card has at least one valid position
    func canPlayCard(_ cardName: String) -> Bool {
        let validPositions = getValidPositions(for: cardName)
        return !validPositions.isEmpty
    }
    
    /// Gets all positions where a card could be played
    /// - Parameter cardName: Card to check
    /// - Returns: Array of valid position indices
    func getPlayablePositions(for cardName: String) -> [Int] {
        return Array(getValidPositions(for: cardName)).sorted()
    }
    
    // MARK: - Legacy Methods (Deprecated - Use new methods instead)
    
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
        
        // Check position-based highlighting (one-eyed Jacks)
        if highlightedPositions.contains(position) {
            return true
        }
        
        // Check card-based highlighting (normal cards, two-eyed Jacks)
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
        
        // Clear highlighted cards and positions
        highlightedCards.removeAll()
        highlightedPositions.removeAll()
    }
    
    // MARK: - Hand Management Helpers
    
    /// Gets hand information for all players
    func getAllPlayerHands() -> [Int: [String]] {
        return playerHands
    }
    
    /// Gets specific player's hand
    func getPlayerHand(_ playerIndex: Int) -> [String] {
        return playerHands[playerIndex] ?? []
    }
    
    // MARK: - Dead Card Tooltip
    
    /// Gets tooltip content for dead card notification
    func deadCardTooltipContent() -> TooltipContent? {
        guard let notification = deadCardNotification else { return nil }
        return TooltipContent(
            title: "Dead Card: \(notification.cardName)",
            description: "Both board positions occupied\nCard discarded and replaced"
        )
    }
    
    // MARK: - Debug Methods
    
    #if DEBUG
    
    /// Gets comprehensive game state debug info
    func getDebugInfo() -> String {
        var handsInfo = "👥 Player Hands:\n"
        for playerIndex in 0..<gameState.numPlayers {
            let hand = playerHands[playerIndex] ?? []
            let isCurrent = playerIndex == gameState.currentPlayer
            let marker = isCurrent ? " ← CURRENT" : ""
            handsInfo += "   Player \(playerIndex + 1): \(hand.count) cards\(marker)\n"
        }
        
        return """
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        🎮 GAME STATE DEBUG INFO
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        🎲 Board Layout: \(currentLayoutType.rawValue)
        👥 Players: \(gameState.numPlayers) (\(gameState.teamConfigurationDescription))
        👤 Current Player: \(currentPlayerName) (\(currentPlayerColor.rawValue))
        🎴 Current Hand: \(currentPlayerCards)
        🎯 Chips Placed: \(boardState.count) positions occupied
        🏆 FIVAs to Win: \(gameState.fivasToWin)
        ✨ Highlighted Cards: \(Array(highlightedCards).sorted())
        ✨ Highlighted Positions: \(Array(highlightedPositions).sorted())
        🎯 Last Played: \(lastCardPlayed ?? "None")
        🗑️ Last Discard: \(mostRecentDiscard ?? "None")
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        \(handsInfo)
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        \(getFIVADebugInfo())
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        \(deckManager.getDebugInfo())
        """
    }
    
    /// Gets FIVA status debug info
    func getFIVADebugInfo() -> String {
        var info = "🎯 FIVA Status:\n"
        
        // Team FIVA counts
        for color in PlayerColor.allCases {
            let count = teamFIVACount[color] ?? 0
            let marker = count >= gameState.fivasToWin ? " 🏆 WINNER!" : ""
            info += "   \(color.rawValue): \(count) FIVA(s)\(marker)\n"
        }
        
        // Completed FIVAs detail
        if completedFIVAs.isEmpty {
            info += "   No completed FIVAs yet"
        } else {
            info += "   Completed FIVAs (\(completedFIVAs.count)):\n"
            for (index, fiva) in completedFIVAs.enumerated() {
                let positions = fiva.positions.sorted()
                info += "   \(index + 1). \(fiva.color.rawValue) \(fiva.direction.rawValue) @ \(positions)"
                if index < completedFIVAs.count - 1 {
                    info += "\n"
                }
            }
        }
        
        return info
    }
    
    /// Gets board state debug info
    func getBoardStateDebugInfo() -> String {
        var info = "🎯 Board State (\(boardState.count) chips):\n"
        let sortedPositions = boardState.keys.sorted()
        for position in sortedPositions {
            let color = boardState[position]!
            let card = currentLayout[position]
            let isProtected = isPartOfCompletedFIVA(position) ? " 🔒" : ""
            info += "  Position \(position) (\(card)): \(color.rawValue)\(isProtected)\n"
        }
        return info
    }
    
    /// Gets highlighting debug info
    func getHighlightingDebugInfo() -> String {
        return """
        Highlighted Cards: \(Array(highlightedCards).sorted())
        Highlighted Positions: \(Array(highlightedPositions).sorted())
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
        boardState.removeAll()
        completedFIVAs.removeAll()
        teamFIVACount.removeAll()
        gameState.resetToFirstPlayer()
        
        // Start fresh game
        startNewGame()
    }
    
    /// Simulates a full game turn for testing
    func simulateGameTurn() {
        guard let card = currentPlayerCards.first else {
            print("⚠️ GameStateManager: No cards to play")
            return
        }
        
        // Get valid positions for this card
        let positions = getBoardPositions(for: card)
        guard let position = positions.first else {
            print("⚠️ GameStateManager: No valid positions for \(card)")
            return
        }
        
        // Simulate playing the first card at its first valid position
        playCardOnBoard(card, position: position)
    }
    
    /// Tests FIVA detection with a sample scenario
    func testFIVADetection() {
        print("🧪 GameStateManager: Testing FIVA Detection...")
        
        // Clear board
        boardState.removeAll()
        completedFIVAs.removeAll()
        teamFIVACount.removeAll()
        
        // Create horizontal FIVA for red team (row 0, cols 0-4)
        print("   Creating horizontal FIVA (Red)...")
        for col in 0..<5 {
            boardState[col] = .red
        }
        let hFivas = checkForNewFIVAs(at: 4, color: .red)
        print("   ✅ Found \(hFivas.count) horizontal FIVA(s)")
        
        // Try vertical FIVA for blue team (col 5, rows 0-4)
        print("   Creating vertical FIVA (Blue)...")
        for row in 0..<5 {
            boardState[row * 10 + 5] = .blue
        }
        let vFivas = checkForNewFIVAs(at: 45, color: .blue)
        print("   ✅ Found \(vFivas.count) vertical FIVA(s)")
        
        // Try diagonal FIVA using corner wildcard
        print("   Creating diagonal FIVA with corner wildcard (Green)...")
        boardState[0] = .green  // Corner wildcard
        boardState[11] = .green
        boardState[22] = .green
        boardState[33] = .green
        boardState[44] = .green
        let dFivas = checkForNewFIVAs(at: 44, color: .green)
        print("   ✅ Found \(dFivas.count) diagonal FIVA(s)")
        
        print("\n" + getFIVADebugInfo())
    }
    
    /// Verifies game state integrity
    func verifyGameIntegrity() -> Bool {
        let deckIntegrity = deckManager.verifyDeckIntegrity()
        let handSize = currentPlayerCards.count
        let expectedHandSize = gameState.cardsPerPlayer
        
        let handValid = handSize <= expectedHandSize
        
        // Check board state validity
        let boardValid = boardState.keys.allSatisfy { $0 >= 0 && $0 < 100 }
        
        if deckIntegrity && handValid && boardValid {
            print("✅ GameStateManager: Integrity check passed")
        } else {
            print("❌ GameStateManager: Integrity check FAILED")
            if !deckIntegrity {
                print("   - Deck integrity failed")
            }
            if !handValid {
                print("   - Hand size invalid: \(handSize) (expected ≤ \(expectedHandSize))")
            }
            if !boardValid {
                print("   - Board state has invalid positions")
            }
        }
        
        return deckIntegrity && handValid && boardValid
    }
    
    #endif
}
