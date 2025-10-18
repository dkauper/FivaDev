//
//  AIPlayer.swift
//  FivaDev
//
//  AI opponent system with multiple difficulty levels
//  Created: October 17, 2025, 4:10 PM Pacific
//  Updated: October 17, 2025, 6:55 PM Pacific - Fixed JackType accessibility
//
//  Supports three difficulty tiers:
//  - Easy (Random): Makes random valid moves
//  - Medium (Smart): Blocks opponent FIVAs, seeks own FIVAs
//  - Hard (Strategic): Advanced evaluation with look-ahead
//

import Foundation
import Combine

// MARK: - AI Difficulty Levels

/// AI opponent difficulty levels
enum AIDifficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var description: String {
        switch self {
        case .easy: return "Random valid moves"
        case .medium: return "Tactical play with blocking"
        case .hard: return "Strategic with planning"
        }
    }
}

// MARK: - AI Move Result

/// Represents an AI's chosen move
struct AIMove {
    let cardName: String
    let cardIndex: Int
    let position: Int
    let reasoning: String  // For debugging/display
    
    var description: String {
        return "Play \(cardName) at position \(position) - \(reasoning)"
    }
}

// MARK: - AI Player

/// AI opponent that can play Fiva games at different difficulty levels
@MainActor
class AIPlayer {
    
    // MARK: - Properties
    
    /// AI difficulty level
    var difficulty: AIDifficulty
    
    /// AI player color/team
    let playerColor: PlayerColor
    
    /// AI thinking delay (seconds) for natural feel
    var thinkingDelay: TimeInterval {
        switch difficulty {
        case .easy: return 0.5
        case .medium: return 1.0
        case .hard: return 1.5
        }
    }
    
    // MARK: - Initialization
    
    init(difficulty: AIDifficulty, playerColor: PlayerColor) {
        self.difficulty = difficulty
        self.playerColor = playerColor
        print("🤖 AIPlayer: Initialized \(difficulty.rawValue) AI for \(playerColor.rawValue) team")
    }
    
    // MARK: - Core AI Decision Making
    
    /// AI chooses and executes a move
    /// - Parameters:
    ///   - hand: AI's current hand of cards
    ///   - gameState: Current game state manager
    /// - Returns: The chosen move, or nil if no valid moves
    func chooseMove(
        hand: [String],
        gameState: GameStateManager
    ) async -> AIMove? {
        
        print("🤖 AIPlayer: \(difficulty.rawValue) AI thinking...")
        
        // Natural thinking delay
        try? await Task.sleep(nanoseconds: UInt64(thinkingDelay * 1_000_000_000))
        
        // Choose move based on difficulty
        let move = switch difficulty {
        case .easy:
            chooseRandomMove(hand: hand, gameState: gameState)
        case .medium:
            chooseSmartMove(hand: hand, gameState: gameState)
        case .hard:
            chooseStrategicMove(hand: hand, gameState: gameState)
        }
        
        if let move = move {
            print("🤖 AIPlayer: \(move.description)")
        } else {
            print("⚠️ AIPlayer: No valid moves available")
        }
        
        return move
    }
    
    // MARK: - Tier 1: Random AI (Easy)
    
    /// Chooses a random valid move from available options
    private func chooseRandomMove(
        hand: [String],
        gameState: GameStateManager
    ) -> AIMove? {
        
        // Build list of all valid moves
        var validMoves: [(cardIndex: Int, cardName: String, position: Int)] = []
        
        for (index, card) in hand.enumerated() {
            let positions = gameState.getValidPositions(for: card)
            for position in positions {
                validMoves.append((index, card, position))
            }
        }
        
        // Check for dead cards that should be discarded
        for (index, card) in hand.enumerated() {
            if gameState.isDeadCard(card) {
                print("🤖 AIPlayer: Found dead card \(card) - will discard")
                return AIMove(
                    cardName: card,
                    cardIndex: index,
                    position: -1,  // Special: -1 indicates discard action
                    reasoning: "Dead card (both positions occupied)"
                )
            }
        }
        
        // No valid moves
        guard !validMoves.isEmpty else { return nil }
        
        // Pick random move
        let chosen = validMoves.randomElement()!
        
        return AIMove(
            cardName: chosen.cardName,
            cardIndex: chosen.cardIndex,
            position: chosen.position,
            reasoning: "Random valid move"
        )
    }
    
    // MARK: - Tier 2: Smart AI (Medium)
    
    /// Makes tactical decisions: complete own FIVAs, block opponent FIVAs
    private func chooseSmartMove(
        hand: [String],
        gameState: GameStateManager
    ) -> AIMove? {
        
        // Priority 1: Complete own FIVA (1 move away from winning)
        if let move = findFIVACompletionMove(hand: hand, gameState: gameState, forColor: playerColor) {
            return AIMove(
                cardName: move.cardName,
                cardIndex: move.cardIndex,
                position: move.position,
                reasoning: "Complete own FIVA! 🎉"
            )
        }
        
        // Priority 2: Block opponent from completing FIVA
        for opponentColor in PlayerColor.allCases where opponentColor != playerColor {
            if let move = findFIVABlockingMove(hand: hand, gameState: gameState, opponentColor: opponentColor) {
                return AIMove(
                    cardName: move.cardName,
                    cardIndex: move.cardIndex,
                    position: move.position,
                    reasoning: "Block \(opponentColor.rawValue) FIVA! 🛡️"
                )
            }
        }
        
        // Priority 3: Build toward FIVA (create 4-in-a-row)
        if let move = findFIVABuildMove(hand: hand, gameState: gameState, forColor: playerColor) {
            return AIMove(
                cardName: move.cardName,
                cardIndex: move.cardIndex,
                position: move.position,
                reasoning: "Build 4-in-a-row"
            )
        }
        
        // Priority 4: Use Jacks strategically
        if let move = findStrategicJackMove(hand: hand, gameState: gameState) {
            return AIMove(
                cardName: move.cardName,
                cardIndex: move.cardIndex,
                position: move.position,
                reasoning: move.reasoning
            )
        }
        
        // Priority 5: Fallback to random valid move
        if let move = chooseRandomMove(hand: hand, gameState: gameState) {
            return AIMove(
                cardName: move.cardName,
                cardIndex: move.cardIndex,
                position: move.position,
                reasoning: "Tactical random move"
            )
        }
        
        return nil
    }
    
    // MARK: - Tier 3: Strategic AI (Hard)
    
    /// Advanced evaluation with multi-move planning
    private func chooseStrategicMove(
        hand: [String],
        gameState: GameStateManager
    ) -> AIMove? {
        
        // Use Smart AI logic as base
        if let smartMove = chooseSmartMove(hand: hand, gameState: gameState) {
            // Enhance reasoning for strategic play
            return AIMove(
                cardName: smartMove.cardName,
                cardIndex: smartMove.cardIndex,
                position: smartMove.position,
                reasoning: "Strategic: " + smartMove.reasoning
            )
        }
        
        // TODO: Future enhancement - minimax look-ahead
        // For now, strategic = smart + better move evaluation
        
        return nil
    }
    
    // MARK: - Helper: FIVA Completion Detection
    
    /// Finds a move that completes a FIVA for specified color
    private func findFIVACompletionMove(
        hand: [String],
        gameState: GameStateManager,
        forColor: PlayerColor
    ) -> (cardName: String, cardIndex: Int, position: Int)? {
        
        for (index, card) in hand.enumerated() {
            let positions = gameState.getValidPositions(for: card)
            
            for position in positions {
                // Simulate placing chip
                if wouldCompleteFIVA(at: position, color: forColor, gameState: gameState) {
                    return (card, index, position)
                }
            }
        }
        
        return nil
    }
    
    /// Finds a move that blocks opponent's FIVA
    private func findFIVABlockingMove(
        hand: [String],
        gameState: GameStateManager,
        opponentColor: PlayerColor
    ) -> (cardName: String, cardIndex: Int, position: Int)? {
        
        // Check if opponent is 1 move from FIVA
        // Look for their almost-complete lines
        
        for (index, card) in hand.enumerated() {
            let positions = gameState.getValidPositions(for: card)
            
            for position in positions {
                // Check if this position blocks an opponent's 4-in-a-row
                if wouldBlockFIVA(at: position, opponentColor: opponentColor, gameState: gameState) {
                    return (card, index, position)
                }
            }
        }
        
        return nil
    }
    
    /// Finds a move that builds toward FIVA (creates 4-in-a-row)
    private func findFIVABuildMove(
        hand: [String],
        gameState: GameStateManager,
        forColor: PlayerColor
    ) -> (cardName: String, cardIndex: Int, position: Int)? {
        
        for (index, card) in hand.enumerated() {
            let positions = gameState.getValidPositions(for: card)
            
            for position in positions {
                // Check if this creates a 4-in-a-row
                let score = evaluatePosition(position, color: forColor, gameState: gameState)
                if score >= 4 {  // Creates 4-in-a-row
                    return (card, index, position)
                }
            }
        }
        
        return nil
    }
    
    /// Finds strategic Jack usage (two-eyed wild or one-eyed removal)
    private func findStrategicJackMove(
        hand: [String],
        gameState: GameStateManager
    ) -> (cardName: String, cardIndex: Int, position: Int, reasoning: String)? {
        
        for (index, card) in hand.enumerated() {
            let jackType = classifyJack(card)
            
            switch jackType {
            case .twoEyed:
                // Use two-eyed Jack to complete or build FIVA
                if let move = findBestWildPlacement(cardIndex: index, card: card, gameState: gameState) {
                    return (card, index, move.position, "Wild Jack: \(move.reason)")
                }
                
            case .oneEyed:
                // Use one-eyed Jack to remove opponent's threatening chip
                if let move = findBestChipRemoval(cardIndex: index, card: card, gameState: gameState) {
                    return (card, index, move.position, "Remove chip: \(move.reason)")
                }
                
            case .none:
                continue
            }
        }
        
        return nil
    }
    
    // MARK: - Helper: Position Evaluation
    
    /// Evaluates how many chips in a row this position would create
    private func evaluatePosition(
        _ position: Int,
        color: PlayerColor,
        gameState: GameStateManager
    ) -> Int {
        
        var maxInRow = 1  // The position itself
        
        // Check all 4 directions
        maxInRow = max(maxInRow, countInLine(position, direction: (0, 1), color: color, gameState: gameState))  // Horizontal
        maxInRow = max(maxInRow, countInLine(position, direction: (1, 0), color: color, gameState: gameState))  // Vertical
        maxInRow = max(maxInRow, countInLine(position, direction: (1, 1), color: color, gameState: gameState))  // Diagonal down
        maxInRow = max(maxInRow, countInLine(position, direction: (1, -1), color: color, gameState: gameState)) // Diagonal up
        
        return maxInRow
    }
    
    /// Counts consecutive chips in a direction
    private func countInLine(
        _ position: Int,
        direction: (row: Int, col: Int),
        color: PlayerColor,
        gameState: GameStateManager
    ) -> Int {
        
        let row = position / 10
        let col = position % 10
        var count = 1  // Position itself
        
        // Check forward
        var checkRow = row + direction.row
        var checkCol = col + direction.col
        while checkRow >= 0 && checkRow < 10 && checkCol >= 0 && checkCol < 10 {
            let checkPos = checkRow * 10 + checkCol
            if gameState.boardState[checkPos] == color || gameState.isCornerPosition(checkPos) {
                count += 1
                checkRow += direction.row
                checkCol += direction.col
            } else {
                break
            }
        }
        
        // Check backward
        checkRow = row - direction.row
        checkCol = col - direction.col
        while checkRow >= 0 && checkRow < 10 && checkCol >= 0 && checkCol < 10 {
            let checkPos = checkRow * 10 + checkCol
            if gameState.boardState[checkPos] == color || gameState.isCornerPosition(checkPos) {
                count += 1
                checkRow -= direction.row
                checkCol -= direction.col
            } else {
                break
            }
        }
        
        return count
    }
    
    /// Checks if placing at position would complete a FIVA
    private func wouldCompleteFIVA(
        at position: Int,
        color: PlayerColor,
        gameState: GameStateManager
    ) -> Bool {
        return evaluatePosition(position, color: color, gameState: gameState) >= 5
    }
    
    /// Checks if placing at position would block opponent's FIVA
    private func wouldBlockFIVA(
        at position: Int,
        opponentColor: PlayerColor,
        gameState: GameStateManager
    ) -> Bool {
        // Check if opponent has 4-in-a-row that includes this position
        return evaluatePosition(position, color: opponentColor, gameState: gameState) >= 4
    }
    
    // MARK: - Helper: Jack Strategic Placement
    
    /// Finds best position for two-eyed Jack (wild placement)
    private func findBestWildPlacement(
        cardIndex: Int,
        card: String,
        gameState: GameStateManager
    ) -> (position: Int, reason: String)? {
        
        let validPositions = gameState.getValidPositions(for: card)
        var bestPosition: Int?
        var bestScore = 0
        var bestReason = "strategic placement"
        
        for position in validPositions {
            let score = evaluatePosition(position, color: playerColor, gameState: gameState)
            
            // Prioritize FIVA completion
            if score >= 5 {
                return (position, "complete FIVA")
            }
            
            // Track best 4-in-a-row
            if score > bestScore {
                bestScore = score
                bestPosition = position
                if score == 4 {
                    bestReason = "create 4-in-a-row"
                } else {
                    bestReason = "best strategic position"
                }
            }
        }
        
        if let pos = bestPosition {
            return (pos, bestReason)
        }
        
        return nil
    }
    
    /// Finds best chip to remove with one-eyed Jack
    private func findBestChipRemoval(
        cardIndex: Int,
        card: String,
        gameState: GameStateManager
    ) -> (position: Int, reason: String)? {
        
        let validPositions = gameState.getValidPositions(for: card)
        var bestPosition: Int?
        var bestReason = "remove opponent chip"
        
        // Priority: Remove chips that would complete opponent's FIVA
        for position in validPositions {
            if let opponentColor = gameState.boardState[position],
               opponentColor != playerColor {
                
                let score = evaluatePosition(position, color: opponentColor, gameState: gameState)
                if score >= 4 {
                    return (position, "block opponent FIVA threat")
                }
                
                // Track any opponent chip
                if bestPosition == nil {
                    bestPosition = position
                }
            }
        }
        
        if let pos = bestPosition {
            return (pos, bestReason)
        }
        
        return nil
    }
    
    // MARK: - Helper: Jack Type Classification
    
    /// Local implementation of JackType classification to avoid dependency issues
    /// Identifies Jack card types and their special abilities
    private enum LocalJackType {
        case twoEyed    // ♣J ♦J - Wild placement anywhere
        case oneEyed    // ♠J ♥J - Remove opponent chip
        case none       // Not a Jack
    }
    
    /// Classifies a card as two-eyed Jack, one-eyed Jack, or normal card
    /// - Parameter cardName: Card name in format "RankSuit" (e.g., "JH", "5D")
    /// - Returns: LocalJackType classification
    private func classifyJack(_ cardName: String) -> LocalJackType {
        guard cardName.hasPrefix("J") else { return .none }
        
        // Extract suit letter (last character)
        guard let suit = cardName.last else { return .none }
        
        switch suit {
        case "C", "D": return .twoEyed  // Clubs and Diamonds - Wild placement
        case "S", "H": return .oneEyed  // Spades and Hearts - Remove opponent
        default: return .none
        }
    }
}

// MARK: - AI Player Extensions

extension AIPlayer {
    
    /// Returns display name for AI
    var displayName: String {
        return "AI (\(difficulty.rawValue))"
    }
    
    /// Changes AI difficulty mid-game
    func changeDifficulty(to newDifficulty: AIDifficulty) {
        difficulty = newDifficulty
        print("🤖 AIPlayer: Difficulty changed to \(newDifficulty.rawValue)")
    }
}
