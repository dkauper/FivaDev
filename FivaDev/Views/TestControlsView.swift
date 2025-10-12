//
//  TestControlsView.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/18/25.
//  Updated: October 12, 2025, 9:55 PM Pacific - Added FIVA testing controls
//  Updated: October 12, 2025, 6:15 PM Pacific - Updated for instance-based GameState
//  Updated: October 5, 2025, 1:40 PM Pacific - Added board layout toggle
//
//  Development controls for testing player counts, board layouts, and FIVA detection

import SwiftUI

struct TestControlsView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    
    var body: some View {
        VStack(spacing: 8) {
            // Current game info
            HStack {
                Text("Players: \(gameStateManager.gameState.numPlayers)")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                
                Text("Teams: \(gameStateManager.gameState.numTeams)")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .padding(.leading, 8)
                
                Text("(\(gameStateManager.gameState.teamConfigurationDescription))")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.caption)
                
                Spacer()
                
                // Show deck info
                Text("Cards/P: \(gameStateManager.gameState.cardsPerPlayer)")
                    .foregroundColor(.white)
                    .font(.caption)
                
                Text("Deck: \(gameStateManager.deckManager.cardsRemaining)")
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(.leading, 8)
            }
            
            // Quick game presets
            HStack(spacing: 4) {
                Text("🎮 Quick:")
                    .foregroundColor(.white)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                presetButton("2P", config: .twoPlayer)
                presetButton("3P", config: .threePlayer)
                presetButton("4P 2v2", config: .fourPlayer2v2)
                presetButton("6P 3v3", config: .sixPlayer3v3)
                presetButton("6P 2v2v2", config: .sixPlayer2v2v2)
                
                Spacer()
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
            
            // FIVA Testing Controls
            HStack(spacing: 4) {
                Text("🎯 FIVA:")
                    .foregroundColor(.white)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Button("Test Detection") {
                    gameStateManager.testFIVADetection()
                }
                .foregroundColor(.white)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.purple.opacity(0.6))
                .cornerRadius(3)
                
                Button("Show Status") {
                    print("\n" + gameStateManager.getFIVADebugInfo())
                }
                .foregroundColor(.white)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.orange.opacity(0.6))
                .cornerRadius(3)
                
                Button("Full Debug") {
                    print("\n" + gameStateManager.getDebugInfo())
                }
                .foregroundColor(.white)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.cyan.opacity(0.6))
                .cornerRadius(3)
                
                Button("Board State") {
                    print("\n" + gameStateManager.getBoardStateDebugInfo())
                }
                .foregroundColor(.white)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.pink.opacity(0.6))
                .cornerRadius(3)
                
                Spacer()
            }
            
            // FIVA Status Summary (visible in UI)
            HStack(spacing: 8) {
                Text("FIVAs:")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.caption2)
                
                ForEach(PlayerColor.allCases, id: \.self) { color in
                    HStack(spacing: 2) {
                        Circle()
                            .fill(color.color)
                            .frame(width: 8, height: 8)
                        Text("\(gameStateManager.teamFIVACount[color] ?? 0)")
                            .foregroundColor(.white)
                            .font(.caption2)
                            .fontWeight(.semibold)
                        if (gameStateManager.teamFIVACount[color] ?? 0) >= gameStateManager.gameState.fivasToWin {
                            Text("🏆")
                                .font(.caption2)
                        }
                    }
                }
                
                Spacer()
                
                Text("Need: \(gameStateManager.gameState.fivasToWin)")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.caption2)
                
                Text("Total: \(gameStateManager.completedFIVAs.count)")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.caption2)
                    .padding(.leading, 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
    }
    
    private func presetButton(_ label: String, config: GameState) -> some View {
        Button(label) {
            gameStateManager.gameState = config
            gameStateManager.startNewGame()
        }
        .foregroundColor(.white)
        .font(.caption2)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.green.opacity(0.6))
        .cornerRadius(3)
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
