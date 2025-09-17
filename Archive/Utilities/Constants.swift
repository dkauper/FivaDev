//
//  Constants.swift
//  FivaDev
//
//  Created by Claude on 9/16/25.
//

import SwiftUI

struct GameConstants {
    
    // MARK: - Board Configuration
    
    static let boardSize = 10
    static let totalPositions = boardSize * boardSize
    static let gridSpacing: CGFloat = 3.0
    static let gridElementAspectRatio: CGFloat = 1.0 / 1.5
    
    // MARK: - Color Configuration
    
    static let backgroundColor = Color(hex: "#B7E4CC")
    static let boardBackgroundColor = Color.gray.opacity(0.2)
    static let cornerSpaceColor = Color.yellow.opacity(0.3)
    static let highlightColor = Color.green.opacity(0.3)
    static let sequenceColor = Color.orange.opacity(0.3)
    
    // MARK: - Card Configuration
    
    static let cardsPerDeck = 52
    static let totalDecks = 2
    static let totalCards = cardsPerDeck * totalDecks
    
    // Cards per player based on player count
    static let cardsPerPlayer: [Int: Int] = [
        2: 7,
        3: 6,
        4: 6,
        5: 5,
        6: 5,
        7: 4,
        8: 4,
        9: 4,
        10: 3,
        11: 3,
        12: 3
    ]
    
    // MARK: - Win Conditions
    
    static func requiredSequences(for playerCount: Int) -> Int {
        return playerCount <= 3 ? 1 : 2
    }
    
    // MARK: - Animation Settings
    
    static let cardSelectionAnimationDuration = 0.2
    static let hoverEffectAnimationDuration = 0.2
    static let handExpandAnimationDuration = 0.3
    static let chipPlacementAnimationDuration = 0.4
    
    // MARK: - UI Dimensions
    
    struct CardSizes {
        static let tiny = CGSize(width: 30, height: 45)
        static let small = CGSize(width: 40, height: 60)
        static let medium = CGSize(width: 50, height: 75)
        static let large = CGSize(width: 60, height: 90)
    }
    
    struct ChipSizes {
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
    }
    
    // MARK: - Overlay Settings
    
    struct OverlaySettings {
        static let handOverlayMaxWidth: CGFloat = 120
        static let infoOverlayMaxWidth: CGFloat = 120
        static let overlayCornerRadius: CGFloat = 10
        static let overlayOpacity = 0.8
        static let overlayPadding: CGFloat = 12
    }
}

// MARK: - Game Rules

struct GameRules {
    
    /// Corner positions on the 10x10 board
    static let cornerPositions: Set<Int> = [0, 9, 90, 99]
    
    /// Directions for sequence detection
    static let sequenceDirections: [(row: Int, col: Int)] = [
        (0, 1),   // Horizontal
        (1, 0),   // Vertical
        (1, 1),   // Diagonal down-right
        (-1, 1)   // Diagonal up-right
    ]
    
    /// Minimum sequence length required to win
    static let sequenceLength = 5
    
    /// Maximum number of players
    static let maxPlayers = 4
    
    /// Minimum number of players
    static let minPlayers = 2
}

// MARK: - Error Messages

struct ErrorMessages {
    static let selectCardFirst = "Please select a card from your hand first"
    static let invalidPosition = "Invalid board position"
    static let twoEyedJackEmptyOnly = "Two-eyed Jack can only be played on empty spaces"
    static let oneEyedJackOpponentOnly = "One-eyed Jack can only remove opponent chips"
    static let cannotRemoveOwnChip = "Cannot remove your own chip"
    static let cannotRemoveSequenceChip = "Cannot remove chips that are part of a completed sequence"
    static let cardDoesntMatch = "Card doesn't match this board position"
    static let positionOccupied = "This position is already occupied"
    static let invalidMove = "Invalid move"
    static let gameNotStarted = "Game has not been started"
    static let noCurrentPlayer = "No current player found"
}

// MARK: - Asset Names

struct AssetNames {
    
    // Playing card asset naming convention: [Rank][Suit]
    // Example: "AS" for Ace of Spades, "KH" for King of Hearts
    
    static func cardImageName(rank: Rank, suit: Suit) -> String {
        return "\(rank.rawValue)\(suit.rawValue)"
    }
    
    // Joker cards for corner spaces
    static let blackJoker = "BlackJoker"
    static let redJoker = "RedJoker"
    
    // Card backs
    static let blueBack = "BlueBack"
    static let redBack = "RedBack"
    
    // Chip colors (if we add chip images later)
    struct ChipAssets {
        static let red = "RedChip"
        static let blue = "BlueChip" 
        static let green = "GreenChip"
        static let yellow = "YellowChip"
    }
}
