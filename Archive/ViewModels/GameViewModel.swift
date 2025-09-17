//
//  GameViewModel.swift
//  FivaDev
//
//  Created by Claude on 9/16/25.
//

import SwiftUI

@MainActor
class GameViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var gameState = GameState()
    @Published var selectedCard: Card?
    @Published var hoveredPosition: Int?
    @Published var showGameSetup = false
    @Published var errorMessage: String?
    
    // MARK: - Game Setup
    
    func startNewGame(with playerCount: Int = 2) {
        gameState.startNewGame(playerCount: playerCount)
        selectedCard = nil
        hoveredPosition = nil
        errorMessage = nil
    }
    
    // MARK: - Card Selection
    
    func selectCard(_ card: Card) {
        if selectedCard == card {
            selectedCard = nil // Deselect if same card
        } else {
            selectedCard = card
        }
        errorMessage = nil
    }
    
    // MARK: - Board Interaction
    
    func selectBoardPosition(_ position: Int) {
        guard let card = selectedCard else {
            errorMessage = "Please select a card from your hand first"
            return
        }
        
        let success = gameState.playCard(card, at: position)
        
        if success {
            selectedCard = nil
            errorMessage = nil
        } else {
            errorMessage = getInvalidMoveMessage(for: card, at: position)
        }
    }
    
    func hoverPosition(_ position: Int?) {
        hoveredPosition = position
    }
    
    // MARK: - Game State Queries
    
    var currentPlayer: Player? {
        return gameState.currentPlayer
    }
    
    var isGameOver: Bool {
        return gameState.phase == .gameOver
    }
    
    var winner: Player? {
        return gameState.winner
    }
    
    func getBoardSpace(at position: Int) -> BoardSpace? {
        guard position >= 0 && position < gameState.boardSpaces.count else { return nil }
        return gameState.boardSpaces[position]
    }
    
    func getValidPositions(for card: Card) -> Set<Int> {
        var validPositions: Set<Int> = []
        
        for (index, boardSpace) in gameState.boardSpaces.enumerated() {
            if isValidMove(card: card, position: index) {
                validPositions.insert(index)
            }
        }
        
        return validPositions
    }
    
    private func isValidMove(card: Card, position: Int) -> Bool {
        guard position >= 0 && position < gameState.boardSpaces.count else { return false }
        
        let boardSpace = gameState.boardSpaces[position]
        
        // Two-eyed Jack can be played anywhere that's empty
        if card.isTwoEyedJack {
            return boardSpace.chip == nil
        }
        
        // One-eyed Jack can remove opponent chips (not in completed sequences)
        if card.isOneEyedJack {
            guard let chip = boardSpace.chip else { return false }
            return chip.playerID != currentPlayer?.id && !boardSpace.isPartOfSequence
        }
        
        // Regular cards must match the board position and be empty
        guard let boardCard = boardSpace.position.card else { return false }
        return card.suit == boardCard.suit && 
               card.rank == boardCard.rank && 
               boardSpace.chip == nil
    }
    
    private func getInvalidMoveMessage(for card: Card, at position: Int) -> String {
        guard position >= 0 && position < gameState.boardSpaces.count else {
            return "Invalid board position"
        }
        
        let boardSpace = gameState.boardSpaces[position]
        
        if card.isTwoEyedJack {
            if boardSpace.chip != nil {
                return "Two-eyed Jack can only be played on empty spaces"
            }
        } else if card.isOneEyedJack {
            if boardSpace.chip == nil {
                return "One-eyed Jack can only remove opponent chips"
            } else if boardSpace.chip?.playerID == currentPlayer?.id {
                return "Cannot remove your own chip"
            } else if boardSpace.isPartOfSequence {
                return "Cannot remove chips that are part of a completed sequence"
            }
        } else {
            if let boardCard = boardSpace.position.card {
                if card.suit != boardCard.suit || card.rank != boardCard.rank {
                    return "Card doesn't match this board position"
                }
            }
            
            if boardSpace.chip != nil {
                return "This position is already occupied"
            }
        }
        
        return "Invalid move"
    }
    
    // MARK: - Dead Card Logic
    
    func canDiscardDeadCard(_ card: Card) -> Bool {
        return GameLogic.isDeadCard(card, boardSpaces: gameState.boardSpaces)
    }
    
    func discardDeadCard(_ card: Card) {
        guard let currentPlayer = currentPlayer,
              let cardIndex = currentPlayer.hand.firstIndex(of: card),
              canDiscardDeadCard(card) else { return }
        
        // Remove card from hand
        gameState.players[gameState.currentPlayerIndex].hand.remove(at: cardIndex)
        
        // Add to discard pile
        gameState.discardPile.append(card)
        
        // Draw new card
        if let newCard = drawCard() {
            gameState.players[gameState.currentPlayerIndex].hand.append(newCard)
        }
        
        // Advance turn
        advanceTurn()
    }
    
    private func drawCard() -> Card? {
        guard !gameState.deck.isEmpty else { return nil }
        return gameState.deck.removeFirst()
    }
    
    private func advanceTurn() {
        // Reset current player flag
        gameState.players[gameState.currentPlayerIndex].isCurrentPlayer = false
        
        // Move to next player
        gameState.currentPlayerIndex = (gameState.currentPlayerIndex + 1) % gameState.players.count
        
        // Set new current player
        gameState.players[gameState.currentPlayerIndex].isCurrentPlayer = true
    }
    
    // MARK: - UI Helpers
    
    func shouldHighlightPosition(_ position: Int) -> Bool {
        guard let card = selectedCard else { return false }
        return getValidPositions(for: card).contains(position)
    }
    
    func shouldShowHoverEffect(_ position: Int) -> Bool {
        return hoveredPosition == position && shouldHighlightPosition(position)
    }
    
    func getCardPositions(for card: Card) -> [Int] {
        return GameLogic.findMatchingPositions(for: card, in: gameState.boardSpaces)
    }
}
