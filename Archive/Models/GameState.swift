//
//  GameState.swift
//  FivaDev
//
//  Created by Claude on 9/16/25.
//

import SwiftUI

enum GamePhase: String, CaseIterable {
    case setup = "setup"
    case playing = "playing"
    case gameOver = "gameOver"
}

struct GameSequence: Identifiable {
    let id = UUID()
    let positions: [Int] // Board positions that form the sequence
    let playerID: UUID
    let direction: SequenceDirection
    
    enum SequenceDirection {
        case horizontal
        case vertical
        case diagonalUp    // Bottom-left to top-right
        case diagonalDown  // Top-left to bottom-right
    }
}

@MainActor
class GameState: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var phase: GamePhase = .setup
    @Published var players: [Player] = []
    @Published var currentPlayerIndex: Int = 0
    @Published var boardSpaces: [BoardSpace] = []
    @Published var deck: [Card] = []
    @Published var discardPile: [Card] = []
    @Published var completedSequences: [GameSequence] = []
    @Published var winner: Player?
    
    // MARK: - Computed Properties
    
    var currentPlayer: Player? {
        guard currentPlayerIndex < players.count else { return nil }
        return players[currentPlayerIndex]
    }
    
    var gameBoard: [BoardSpace] {
        return boardSpaces
    }
    
    // MARK: - Game Setup
    
    func startNewGame(playerCount: Int) {
        reset()
        setupPlayers(count: playerCount)
        setupBoard()
        setupDeck()
        dealInitialCards()
        phase = .playing
    }
    
    private func reset() {
        phase = .setup
        players.removeAll()
        currentPlayerIndex = 0
        boardSpaces.removeAll()
        deck.removeAll()
        discardPile.removeAll()
        completedSequences.removeAll()
        winner = nil
    }
    
    private func setupPlayers(count: Int) {
        let chipColors: [ChipColor] = [.red, .blue, .green, .yellow]
        
        for i in 0..<min(count, chipColors.count) {
            let player = Player(
                name: "Player \(i + 1)",
                chipColor: chipColors[i]
            )
            players.append(player)
        }
        
        // Set first player as current
        if !players.isEmpty {
            players[0].isCurrentPlayer = true
        }
    }
    
    private func setupBoard() {
        boardSpaces = GameLogic.createBoardSpaces()
    }
    
    private func setupDeck() {
        deck = GameLogic.createGameDeck()
    }
    
    private func dealInitialCards() {
        let cardsPerPlayer: Int = {
            switch players.count {
            case 2: return 7
            case 3, 4: return 6
            case 5, 6: return 5
            case 7, 8, 9: return 4
            case 10, 11, 12: return 3
            default: return 6
            }
        }()
        
        for playerIndex in 0..<players.count {
            for _ in 0..<cardsPerPlayer {
                if let card = drawCard() {
                    players[playerIndex].hand.append(card)
                }
            }
        }
    }
    
    private func drawCard() -> Card? {
        guard !deck.isEmpty else { return nil }
        return deck.removeFirst()
    }
    
    // MARK: - Game Actions
    
    func playCard(_ card: Card, at position: Int) -> Bool {
        guard let currentPlayer = currentPlayer else { return false }
        guard isValidMove(card: card, position: position) else { return false }
        
        // Remove card from player's hand
        if let cardIndex = currentPlayer.hand.firstIndex(of: card) {
            players[currentPlayerIndex].hand.remove(at: cardIndex)
        }
        
        // Handle different card types
        if card.isTwoEyedJack {
            return handleTwoEyedJack(at: position)
        } else if card.isOneEyedJack {
            return handleOneEyedJack(at: position)
        } else {
            return handleRegularCard(card: card, at: position)
        }
    }
    
    private func isValidMove(card: Card, position: Int) -> Bool {
        guard let currentPlayer = currentPlayer else { return false }
        return GameLogic.isValidMove(
            card: card,
            position: position,
            boardSpaces: boardSpaces,
            currentPlayer: currentPlayer
        )
    }
    
    private func handleTwoEyedJack(at position: Int) -> Bool {
        guard let currentPlayer = currentPlayer else { return false }
        
        let chip = Chip(color: currentPlayer.chipColor, playerID: currentPlayer.id)
        boardSpaces[position].chip = chip
        
        checkForSequences(after: position)
        advanceTurn()
        return true
    }
    
    private func handleOneEyedJack(at position: Int) -> Bool {
        boardSpaces[position].chip = nil
        advanceTurn()
        return true
    }
    
    private func handleRegularCard(card: Card, at position: Int) -> Bool {
        guard let currentPlayer = currentPlayer else { return false }
        
        let chip = Chip(color: currentPlayer.chipColor, playerID: currentPlayer.id)
        boardSpaces[position].chip = chip
        
        checkForSequences(after: position)
        advanceTurn()
        return true
    }
    
    private func advanceTurn() {
        // Reset current player flag
        players[currentPlayerIndex].isCurrentPlayer = false
        
        // Move to next player
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        
        // Set new current player
        players[currentPlayerIndex].isCurrentPlayer = true
        
        // Draw a new card for the player
        if let newCard = drawCard() {
            players[currentPlayerIndex].hand.append(newCard)
        }
    }
    
    // MARK: - Sequence Detection
    
    private func checkForSequences(after position: Int) {
        let newSequences = detectSequences(from: position)
        
        for sequence in newSequences {
            // Mark positions as part of a sequence
            for pos in sequence.positions {
                boardSpaces[pos].isPartOfSequence = true
            }
            
            completedSequences.append(sequence)
            
            // Update player's completed sequence count
            if let playerIndex = players.firstIndex(where: { $0.id == sequence.playerID }) {
                players[playerIndex].completedSequences += 1
            }
        }
        
        checkWinCondition()
    }
    
    private func detectSequences(from position: Int) -> [GameSequence] {
        guard let currentPlayer = currentPlayer else { return [] }
        
        return GameLogic.detectSequencesFrom(
            position: position,
            boardSpaces: boardSpaces,
            playerID: currentPlayer.id
        )
    }
    private func checkWinCondition() {
        for player in players {
            let requiredSequences = GameConstants.requiredSequences(for: players.count)
            
            if player.completedSequences >= requiredSequences {
                winner = player
                phase = .gameOver
                return
            }
        }
    }
}
