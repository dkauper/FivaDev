//
//  TestControlsView.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/18/25.
//  Updated: October 5, 2025, 1:40 PM Pacific - Added board layout toggle
//
//  Development controls for testing player counts and board layouts

import SwiftUI

struct TestControlsView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    @State private var currentPlayers = GameState.numPlayers
    
    var body: some View {
        VStack(spacing: 8) {
            // Player count controls
            HStack {
                Text("Players: \(currentPlayers)")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                
                Button("-") {
                    if currentPlayers > 2 {
                        currentPlayers -= 1
                        GameState.numPlayers = currentPlayers
                        gameStateManager.startNewGame()
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.7))
                .cornerRadius(4)
                
                Button("+") {
                    if currentPlayers < 12 {
                        currentPlayers += 1
                        GameState.numPlayers = currentPlayers
                        gameStateManager.startNewGame()
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.7))
                .cornerRadius(4)
                
                Spacer()
                
                // Show deck info
                Text("Cards: \(GameState.cardsPerPlayer)")
                    .foregroundColor(.white)
                    .font(.caption)
                
                Text("Deck: \(gameStateManager.deckManager.cardsRemaining)")
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(.leading, 8)
            }
            
            // Board layout toggle
            HStack {
                Text("🎲 Layout:")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .font(.caption)
                
                Button(action: {
                    gameStateManager.toggleBoardLayout()
                }) {
                    HStack(spacing: 4) {
                        Text(gameStateManager.currentLayoutType.rawValue)
                            .fontWeight(.medium)
                        Image(systemName: "arrow.left.arrow.right")
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    gameStateManager.currentLayoutType == .digitalOptimized
                        ? Color.blue.opacity(0.7)
                        : Color.orange.opacity(0.7)
                )
                .cornerRadius(4)
                
                Text(layoutDescription)
                    .foregroundColor(.white.opacity(0.8))
                    .font(.caption2)
                    .lineLimit(1)
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
    }
    
    private var layoutDescription: String {
        switch gameStateManager.currentLayoutType {
        case .legacy:
            return "180° Symmetry"
        case .digitalOptimized:
            return "Suit Zones"
        }
    }
}

// To use this, add it to your HeaderView or ContentView temporarily:
// TestControlsView().environmentObject(gameStateManager)
