//
//  GameModels.swift
//  FivaDev
//
//  Created by Claude on 9/16/25.
//

import SwiftUI

// MARK: - Card Models

enum Suit: String, CaseIterable, Codable {
    case hearts = "H"
    case diamonds = "D" 
    case clubs = "C"
    case spades = "S"
    
    var color: Color {
        switch self {
        case .hearts, .diamonds:
            return .red
        case .clubs, .spades:
            return .black
        }
    }
    
    var name: String {
        switch self {
        case .hearts: return "Hearts"
        case .diamonds: return "Diamonds"
        case .clubs: return "Clubs"
        case .spades: return "Spades"
        }
    }
}

enum Rank: String, CaseIterable, Codable {
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "10"
    case jack = "J"
    case queen = "Q"
    case king = "K"
    case ace = "A"
    
    var value: Int {
        switch self {
        case .ace: return 1
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        case .ten: return 10
        case .jack: return 11
        case .queen: return 12
        case .king: return 13
        }
    }
}

struct Card: Identifiable, Codable, Equatable, Hashable {
    let id = UUID()
    let suit: Suit
    let rank: Rank
    
    /// Two-eyed Jacks (Hearts and Diamonds) are wild cards
    var isTwoEyedJack: Bool {
        rank == .jack && (suit == .hearts || suit == .diamonds)
    }
    
    /// One-eyed Jacks (Spades and Clubs) remove opponent chips
    var isOneEyedJack: Bool {
        rank == .jack && (suit == .spades || suit == .clubs)
    }
    
    /// Jacks don't appear on the game board
    var isJack: Bool {
        rank == .jack
    }
    
    /// Image name for the card asset
    var imageName: String {
        if isJack {
            return "\(rank.rawValue)\(suit.rawValue)"
        }
        return "\(rank.rawValue)\(suit.rawValue)"
    }
    
    /// Display name for the card
    var displayName: String {
        "\(rank.rawValue) of \(suit.name)"
    }
}

// MARK: - Board Models

struct BoardPosition: Identifiable, Equatable, Hashable {
    let id: Int // 0-99 for 10x10 grid
    let row: Int
    let col: Int
    let card: Card? // nil for corner "free" spaces
    
    init(id: Int, card: Card? = nil) {
        self.id = id
        self.row = id / 10
        self.col = id % 10
        self.card = card
    }
    
    /// Corner positions (free spaces)
    var isCorner: Bool {
        (row == 0 && col == 0) ||    // Top-left
        (row == 0 && col == 9) ||    // Top-right
        (row == 9 && col == 0) ||    // Bottom-left
        (row == 9 && col == 9)       // Bottom-right
    }
}

enum ChipColor: String, CaseIterable, Codable {
    case red = "Red"
    case blue = "Blue"
    case green = "Green"
    case yellow = "Yellow"
    
    var color: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        }
    }
}

struct Chip: Identifiable, Equatable {
    let id = UUID()
    let color: ChipColor
    let playerID: UUID
}

struct BoardSpace: Identifiable {
    let id: Int
    let position: BoardPosition
    var chip: Chip?
    var isPartOfSequence: Bool = false // Cannot be removed by one-eyed Jack
    
    init(position: BoardPosition) {
        self.id = position.id
        self.position = position
    }
}

// MARK: - Player Models

struct Player: Identifiable, Codable {
    let id = UUID()
    let name: String
    let chipColor: ChipColor
    var hand: [Card] = []
    var isCurrentPlayer: Bool = false
    var completedSequences: Int = 0
    
    init(name: String, chipColor: ChipColor) {
        self.name = name
        self.chipColor = chipColor
    }
}

// MARK: - Game Board Layout

/// Static game board layout based on Sequence game rules
/// Each card (except Jacks) appears exactly twice on the 10x10 board
/// Uses the official board layout from GameLogic
struct GameBoardLayout {
    
    /// The static 10x10 board layout (positions 0-99)
    /// Based on the official Sequence board game layout
    static var boardLayout: [Card?] {
        return GameLogic.officialBoardLayout
    }
}
