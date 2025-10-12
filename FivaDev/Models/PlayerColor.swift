//
//  PlayerColor.swift
//  FivaDev
//
//  Created: October 11, 2025, 5:15 PM Pacific
//  Chip placement system - Player color model
//

import SwiftUI

/// Represents player chip colors in the Fiva game
enum PlayerColor: String, CaseIterable, Codable {
    case red = "Red"
    case blue = "Blue"
    case green = "Green"
//    case yellow = "Yellow"
    
    /// Asset name for the chip image
    var chipImageName: String {
        switch self {
        case .red: return "RedChip"
        case .blue: return "BlueChip"
        case .green: return "GreenChip"
//        case .yellow: return "YellowChip"
        }
    }
    
    /// SwiftUI Color for the player
    var color: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
//        case .yellow: return .yellow
        }
    }
    
    /// Get player color for a specific player index
    static func forPlayer(_ index: Int) -> PlayerColor {
        let colors: [PlayerColor] = [.red, .blue, .green]
        return colors[index % colors.count]
    }
    
    /// Display name for the player
    var displayName: String {
        return rawValue
    }
}
