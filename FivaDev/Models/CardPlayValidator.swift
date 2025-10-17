//
//  CardPlayValidator.swift
//  FivaDev
//
//  Jack special rules and card play validation
//  Created: October 12, 2025, 11:00 PM Pacific
//  Updated: October 12, 2025, 11:40 PM Pacific - Two-eyed Jacks now show no highlights
//  Updated: October 12, 2025, 11:35 PM Pacific - Fixed one-eyed Jack highlighting (position-based)
//  Integrates with existing GameStateManager FIVA protection
//

import Foundation

// MARK: - Jack Type Classification

/// Identifies Jack card types and their special abilities
enum JackType {
    case twoEyed    // ♣J ♦J - Wild placement anywhere
    case oneEyed    // ♠J ♥J - Remove opponent chip
    case none       // Not a Jack
    
    /// Classifies a card as two-eyed Jack, one-eyed Jack, or normal card
    /// - Parameter cardName: Card name in format "RankSuit" (e.g., "JH", "5D")
    /// - Returns: JackType classification
    static func classify(_ cardName: String) -> JackType {
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

// MARK: - Card Play Result

/// Result of card play validation
enum CardPlayResult {
    case valid(CardPlayAction)
    case invalid(String)
    
    var isValid: Bool {
        if case .valid = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .invalid(let message) = self { return message }
        return nil
    }
}

/// Action to perform when playing a card
enum CardPlayAction {
    case placeChip(position: Int)
    case removeChip(position: Int)
}

// MARK: - Card Play Validator

/// Validates card plays according to Fiva rules including Jack special abilities
struct CardPlayValidator {
    
    /// Validates if a card can be played at a specific board position
    /// - Parameters:
    ///   - cardName: The card being played
    ///   - position: Target board position (0-99)
    ///   - boardLayout: Current board layout
    ///   - boardState: Current chip placement state
    ///   - currentPlayerColor: Color of current player's team
    ///   - isProtected: Function to check if position is part of completed FIVA
    /// - Returns: CardPlayResult indicating validity and action
    static func validatePlay(
        cardName: String,
        at position: Int,
        boardLayout: [String],
        boardState: [Int: PlayerColor],
        currentPlayerColor: PlayerColor,
        isProtected: (Int) -> Bool
    ) -> CardPlayResult {
        
        // Validate board position
        guard position >= 0 && position < 100 else {
            return .invalid("Invalid board position: \(position)")
        }
        
        let jackType = JackType.classify(cardName)
        
        switch jackType {
        case .twoEyed:
            return validateTwoEyedJack(
                at: position,
                boardState: boardState
            )
            
        case .oneEyed:
            return validateOneEyedJack(
                at: position,
                boardState: boardState,
                currentPlayerColor: currentPlayerColor,
                isProtected: isProtected
            )
            
        case .none:
            return validateNormalCard(
                cardName: cardName,
                at: position,
                boardLayout: boardLayout,
                boardState: boardState
            )
        }
    }
    
    // MARK: - Two-Eyed Jack Validation (Wild Placement)
    
    /// Validates two-eyed Jack play (can place chip anywhere that's empty)
    private static func validateTwoEyedJack(
        at position: Int,
        boardState: [Int: PlayerColor]
    ) -> CardPlayResult {
        
        // Can place anywhere that's unoccupied
        guard boardState[position] == nil else {
            return .invalid("Position already occupied")
        }
        
        return .valid(.placeChip(position: position))
    }
    
    // MARK: - One-Eyed Jack Validation (Remove Opponent)
    
    /// Validates one-eyed Jack play (can remove opponent's chip if not in completed FIVA)
    private static func validateOneEyedJack(
        at position: Int,
        boardState: [Int: PlayerColor],
        currentPlayerColor: PlayerColor,
        isProtected: (Int) -> Bool
    ) -> CardPlayResult {
        
        // Must have an opponent's chip
        guard let chipColor = boardState[position] else {
            return .invalid("No chip at this position to remove")
        }
        
        // Cannot remove your own chip
        guard chipColor != currentPlayerColor else {
            return .invalid("Cannot remove your own team's chip")
        }
        
        // CRITICAL: Cannot remove from completed FIVA
        guard !isProtected(position) else {
            return .invalid("Cannot remove chip from completed FIVA")
        }
        
        return .valid(.removeChip(position: position))
    }
    
    // MARK: - Normal Card Validation
    
    /// Validates normal card play (must match board position and be unoccupied)
    private static func validateNormalCard(
        cardName: String,
        at position: Int,
        boardLayout: [String],
        boardState: [Int: PlayerColor]
    ) -> CardPlayResult {
        
        // Card must match board position
        guard position < boardLayout.count else {
            return .invalid("Invalid board position")
        }
        
        let boardCard = boardLayout[position]
        guard boardCard == cardName else {
            return .invalid("Card \(cardName) doesn't match board position \(boardCard)")
        }
        
        // Position must be unoccupied
        guard boardState[position] == nil else {
            return .invalid("Position already occupied")
        }
        
        return .valid(.placeChip(position: position))
    }
    
    // MARK: - Helper: Get Valid Positions for Card
    
    /// Returns all valid positions where a card can be played
    /// - Parameters:
    ///   - cardName: The card to check
    ///   - boardLayout: Current board layout
    ///   - boardState: Current chip placement state
    ///   - currentPlayerColor: Current player's team color
    ///   - isProtected: Function to check FIVA protection
    /// - Returns: Set of valid position indices
    static func validPositions(
        for cardName: String,
        boardLayout: [String],
        boardState: [Int: PlayerColor],
        currentPlayerColor: PlayerColor,
        isProtected: (Int) -> Bool
    ) -> Set<Int> {
        
        var positions = Set<Int>()
        let jackType = JackType.classify(cardName)
        
        switch jackType {
        case .twoEyed:
            // Can place anywhere that's empty
            for (index, _) in boardLayout.enumerated() {
                if boardState[index] == nil {
                    positions.insert(index)
                }
            }
            
        case .oneEyed:
            // Can remove any opponent chip not in completed FIVA
            for (position, color) in boardState {
                if color != currentPlayerColor && !isProtected(position) {
                    positions.insert(position)
                }
            }
            
        case .none:
            // Must match board card and be unoccupied
            for (index, boardCard) in boardLayout.enumerated() {
                if boardCard == cardName && boardState[index] == nil {
                    positions.insert(index)
                }
            }
        }
        
        return positions
    }
}

// MARK: - GameStateManager Integration

extension GameStateManager {
    
    /// Validates if a card can be played at a position using Jack rules
    /// - Parameters:
    ///   - cardName: Card being played
    ///   - position: Target position
    /// - Returns: CardPlayResult with validation outcome
    func validateCardPlay(_ cardName: String, at position: Int) -> CardPlayResult {
        return CardPlayValidator.validatePlay(
            cardName: cardName,
            at: position,
            boardLayout: currentLayout,
            boardState: boardState,
            currentPlayerColor: currentPlayerColor,
            isProtected: isPartOfCompletedFIVA
        )
    }
    
    /// Gets all valid positions for playing a card (includes Jack special rules)
    /// - Parameter cardName: Card to check
    /// - Returns: Set of valid position indices
    func getValidPositions(for cardName: String) -> Set<Int> {
        return CardPlayValidator.validPositions(
            for: cardName,
            boardLayout: currentLayout,
            boardState: boardState,
            currentPlayerColor: currentPlayerColor,
            isProtected: isPartOfCompletedFIVA
        )
    }
    
    /// Highlights valid positions for a card (Jack-aware)
    /// - Parameter cardName: Card to highlight positions for
    func highlightValidPositionsForCard(_ cardName: String) {
        clearAllHighlights()
        
        let validPositions = getValidPositions(for: cardName)
        let jackType = JackType.classify(cardName)
        
        switch jackType {
        case .twoEyed:
            // Two-eyed Jacks: No highlighting (can place anywhere empty without visual hint)
            print("🃏 GameStateManager: Two-eyed Jack selected - no highlighting (wild card)")
            
        case .oneEyed:
            // Highlight specific positions with opponent chips (position-based)
            highlightedPositions = validPositions
            
        case .none:
            // Highlight matching card positions
            if !validPositions.isEmpty {
                highlightedCards.insert(cardName)
            }
        }
        
        print("🎯 GameStateManager: Highlighted \(highlightedCards.count) cards + \(highlightedPositions.count) positions for \(cardName) (\(jackType))")
    }
}
