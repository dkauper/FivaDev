//
//  BoardLayouts.swift
//  FivaDev
//
//  Created: Sunday, October 5, 2025, 1:35 PM Pacific
//  Contains both legacy and digital-optimized board layouts
//

import Foundation

// MARK: - Board Layout Type

enum BoardLayoutType: String, CaseIterable {
    case legacy = "Legacy"
    case digitalOptimized = "Digital-Optimized"
    
    var description: String {
        switch self {
        case .legacy:
            return "Legacy (180° Symmetry)"
        case .digitalOptimized:
            return "Digital-Optimized (Suit Zones)"
        }
    }
}

// MARK: - Board Layouts

struct BoardLayouts {
    
    /// Legacy board layout - designed for physical board game with 180° rotational symmetry
    static let legacy: [String] = [
        "RedJoker", "5D", "6D", "7D", "8D", "9D", "QD", "KD", "AD", "BlackJoker",
        "5D", "3H", "2H", "2S", "3S", "4S", "5S", "6S", "7S", "AC",
        "4D", "4H", "KD", "AD", "AC", "KC", "QC", "10C", "8S", "KC",
        "3D", "5H", "QD", "QH", "10H", "9H", "8H", "9C", "9S", "QC",
        "2D", "6H", "10D", "KH", "3H", "2H", "7H", "8C", "10S", "10C",
        "AS", "7H", "9D", "AH", "4H", "5H", "6H", "7C", "QS", "9C",
        "KS", "8H", "8D", "2C", "3C", "4C", "5C", "6C", "KS", "8C",
        "QS", "9H", "7D", "6D", "5D", "4D", "3D", "2D", "AS", "7C",
        "10S", "10H", "QH", "KH", "AH", "2C", "3C", "4C", "5C", "6C",
        "BlackJoker", "9S", "8S", "7S", "6S", "5S", "4S", "3S", "2S", "RedJoker"
    ]
    
    /// Digital-optimized layout - designed for visual scanning efficiency with suit zones
    static let digitalOptimized: [String] = [
        // Row 1 (Index 0-9)
        "RedJoker", "2C", "3C", "4H", "5H", "6D", "7D", "8S", "9S", "BlackJoker",
        
        // Row 2 (Index 10-19)
        "4C", "5C", "6C", "AH", "2H", "AD", "2D", "10S", "2S", "QS",
        
        // Row 3 (Index 20-29)
        "7C", "8C", "9C", "3H", "4H", "3D", "4D", "3S", "4S", "KS",
        
        // Row 4 (Index 30-39)
        "10C", "QC", "AC", "6H", "7H", "5D", "8D", "5S", "6S", "7S",
        
        // Row 5 - ROYAL ROW (Index 40-49)
        "KC", "AC", "QH", "KH", "8H", "QD", "KD", "AS", "QS", "KS",
        
        // Row 6 (Index 50-59)
        "2C", "3C", "10H", "9H", "10D", "9D", "QH", "10S", "KH", "AH",
        
        // Row 7 (Index 60-69)
        "4C", "5C", "6C", "2H", "3H", "2D", "3D", "2S", "3S", "4S",
        
        // Row 8 (Index 70-79)
        "7C", "8C", "9C", "10H", "5H", "4D", "5D", "5S", "6S", "7S",
        
        // Row 9 (Index 80-89)
        "10C", "QC", "KC", "6H", "7H", "6D", "7D", "8S", "9S", "AS",
        
        // Row 10 (Index 90-99)
        "BlackJoker", "9H", "8H", "8D", "9D", "10D", "QD", "KD", "AD", "RedJoker"
    ]
    
    /// Returns the card distribution for the specified layout type
    static func getLayout(_ type: BoardLayoutType) -> [String] {
        switch type {
        case .legacy:
            return legacy
        case .digitalOptimized:
            return digitalOptimized
        }
    }
    
    // MARK: - Layout Validation
    
    /// Validates that a layout has correct card distribution
    static func validateLayout(_ layout: [String]) -> Bool {
        // Check total positions
        guard layout.count == 100 else {
            print("❌ Layout validation failed: Expected 100 positions, got \(layout.count)")
            return false
        }
        
        // Check jokers in corners
        let corners = [0, 9, 90, 99]
        for corner in corners {
            guard layout[corner].contains("Joker") else {
                print("❌ Layout validation failed: Position \(corner) should be a Joker")
                return false
            }
        }
        
        // Check no Jacks on board
        for card in layout {
            if card.contains("J") && !card.contains("Joker") {
                print("❌ Layout validation failed: Found Jack on board: \(card)")
                return false
            }
        }
        
        // Check each non-Joker card appears exactly twice
        var cardCounts: [String: Int] = [:]
        for card in layout {
            if !card.contains("Joker") {
                cardCounts[card, default: 0] += 1
            }
        }
        
        for (card, count) in cardCounts {
            if count != 2 {
                print("❌ Layout validation failed: \(card) appears \(count) times (expected 2)")
                return false
            }
        }
        
        print("✅ Layout validation passed")
        return true
    }
    
    // MARK: - Layout Information
    
    /// Gets information about a specific layout
    static func getLayoutInfo(_ type: BoardLayoutType) -> String {
        switch type {
        case .legacy:
            return """
            Legacy Layout
            - 180° rotational symmetry
            - Designed for physical board game
            - Edge sequential runs
            - Face card clustering in center
            """
        case .digitalOptimized:
            return """
            Digital-Optimized Layout
            - Suit zones (Diamonds left, Hearts center-left, Clubs center-right, Spades right)
            - Royal Row (Row 5 with high-value cards)
            - Diamond Streets (Columns 2-3)
            - Corner sequential anchors
            - Optimized for visual scanning
            """
        }
    }
}
