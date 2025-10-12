//
//  PlayerColor.swift
//  FivaDev
//
//  Created: October 11, 2025, 5:15 PM Pacific
//  Updated: October 12, 2025, 6:10 PM Pacific
//  MAX 3 TEAMS: Red, Blue, Green chip colors only (Yellow will not be implemented)
//  Multiple players can share the same chip color when on the same team
//

import SwiftUI

/// Represents team chip colors in the Fiva game
/// LIMITED TO 3 TEAMS - Multiple players can share the same chip color
enum PlayerColor: String, CaseIterable, Codable {
    case red = "Red"
    case blue = "Blue"
    case green = "Green"
    // Yellow will NOT be implemented - 3 team maximum
    
    /// Asset name for the chip image
    var chipImageName: String {
        switch self {
        case .red: return "RedChip"
        case .blue: return "BlueChip"
        case .green: return "GreenChip"
        }
    }
    
    /// SwiftUI Color for the team
    var color: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        }
    }
    
    /// Get chip color for a specific team index (0-2)
    static func forTeam(_ index: Int) -> PlayerColor {
        guard index >= 0 && index < allCases.count else {
            return .red  // Fallback to red for invalid index
        }
        return allCases[index]
    }
    
    /// Display name for the team
    var displayName: String {
        return rawValue
    }
}
