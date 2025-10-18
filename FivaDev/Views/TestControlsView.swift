//
//  TestControlsView.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/18/25.
//  Updated: October 12, 2025, 10:10 PM Pacific - Added manual player/team configuration
//  Updated: October 12, 2025, 9:55 PM Pacific - Added FIVA testing controls
//  Updated: October 12, 2025, 6:15 PM Pacific - Updated for instance-based GameState
//  Updated: October 5, 2025, 1:40 PM Pacific - Added board layout toggle
//
//  Development controls for testing player counts, board layouts, and FIVA detection

import SwiftUI

struct TestControlsView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    
    // Local state for manual configuration
    @State private var manualPlayers: Int = 2
    @State private var manualTeams: Int = 2
    
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
            
            // Manual Configuration Row
            HStack(spacing: 8) {
                Text("⚙️ Manual:")
                    .foregroundColor(.white)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                // Players Stepper
                HStack(spacing: 4) {
                    Text("P:")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption2)
                    
                    Button("-") {
                        if manualPlayers > 2 {
                            manualPlayers -= 1
                        }
                    }
                    .foregroundColor(.white)
                    .font(.caption2)
                    .frame(width: 20, height: 20)
                    .background(Color.red.opacity(0.6))
                    .cornerRadius(3)
                    
                    Text("\(manualPlayers)")
                        .foregroundColor(.white)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(minWidth: 20)
                    
                    Button("+") {
                        if manualPlayers < 12 {
                            manualPlayers += 1
                        }
                    }
                    .foregroundColor(.white)
                    .font(.caption2)
                    .frame(width: 20, height: 20)
                    .background(Color.green.opacity(0.6))
                    .cornerRadius(3)
                }
                
                // Teams Stepper
                HStack(spacing: 4) {
                    Text("T:")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption2)
                    
                    Button("-") {
                        if manualTeams > 2 {
                            manualTeams -= 1
                        }
                    }
                    .foregroundColor(.white)
                    .font(.caption2)
                    .frame(width: 20, height: 20)
                    .background(Color.red.opacity(0.6))
                    .cornerRadius(3)
                    
                    Text("\(manualTeams)")
                        .foregroundColor(.white)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(minWidth: 20)
                    
                    Button("+") {
                        if manualTeams < 3 {
                            manualTeams += 1
                        }
                    }
                    .foregroundColor(.white)
                    .font(.caption2)
                    .frame(width: 20, height: 20)
                    .background(Color.green.opacity(0.6))
                    .cornerRadius(3)
                }
                
                // Apply Button
                Button("Apply") {
                    applyManualConfiguration()
                }
                .foregroundColor(.white)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.blue.opacity(0.7))
                .cornerRadius(3)
                
                Spacer()
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
//            HStack {
//                Text("🎲 Layout:")
//                    .foregroundColor(.white)
//                    .fontWeight(.semibold)
//                    .font(.caption)
//                
//                Button(action: {
//                    gameStateManager.toggleBoardLayout()
//                }) {
//                    HStack(spacing: 4) {
//                        Text(gameStateManager.currentLayoutType.rawValue)
//                            .fontWeight(.medium)
//                        Image(systemName: "arrow.left.arrow.right")
//                    }
//                }
//                .foregroundColor(.white)
//                .padding(.horizontal, 10)
//                .padding(.vertical, 4)
//                .background(
//                    gameStateManager.currentLayoutType == .digitalOptimized
//                        ? Color.blue.opacity(0.7)
//                        : Color.orange.opacity(0.7)
//                )
//                .cornerRadius(4)
//                
//                Text(layoutDescription)
//                    .foregroundColor(.white.opacity(0.8))
//                    .font(.caption2)
//                    .lineLimit(1)
//                
//                Spacer()
//            }
            
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
        .onAppear {
            // Sync local state with current game state
            manualPlayers = gameStateManager.gameState.numPlayers
            manualTeams = gameStateManager.gameState.numTeams
        }
    }
    
    private func applyManualConfiguration() {
        // Generate default player names
        let names = (1...manualPlayers).map { "Player \($0)" }
        
        // Configure game with manual values
        gameStateManager.configureGame(
            players: manualPlayers,
            teams: manualTeams,
            names: names,
            teamAssignments: nil  // Auto-distribute teams
        )
        
        print("⚙️ TestControlsView: Applied manual config - \(manualPlayers)P, \(manualTeams)T")
    }
    
    private func presetButton(_ label: String, config: GameState) -> some View {
        Button(label) {
            gameStateManager.gameState = config
            gameStateManager.startNewGame()
            
            // Sync manual controls with preset
            manualPlayers = gameStateManager.gameState.numPlayers
            manualTeams = gameStateManager.gameState.numTeams
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
    
    // MARK: - AI Controls
    
    private var aiControlsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("🤖 AI Opponent")
                .foregroundColor(.white)
                .font(.caption)
                .fontWeight(.semibold)
            
            // Quick Setup Buttons
            HStack(spacing: 4) {
                Button("vs Easy") {
                    gameStateManager.setupHumanVsAI(aiDifficulty: .easy)
                }
                .foregroundColor(.white)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.green.opacity(0.5))
                .cornerRadius(3)
                
                Button("vs Medium") {
                    gameStateManager.setupHumanVsAI(aiDifficulty: .medium)
                }
                .foregroundColor(.white)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.blue.opacity(0.6))
                .cornerRadius(3)
                
                Button("vs Hard") {
                    gameStateManager.setupHumanVsAI(aiDifficulty: .hard)
                }
                .foregroundColor(.white)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.red.opacity(0.6))
                .cornerRadius(3)
            }
            
            // AI vs AI and Clear
            HStack(spacing: 4) {
                Button("AI vs AI") {
                    gameStateManager.setupAIvsAI(
                        ai1Difficulty: .medium,
                        ai2Difficulty: .medium
                    )
                }
                .foregroundColor(.white)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.purple.opacity(0.6))
                .cornerRadius(3)
                
                Button("Clear AI") {
                    gameStateManager.clearAllAI()
                }
                .foregroundColor(.white)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.gray.opacity(0.6))
                .cornerRadius(3)
            }
            
            // Current AI Status
            if !gameStateManager.aiPlayers.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Active AI:")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption2)
                    
                    ForEach(Array(gameStateManager.aiPlayers.keys.sorted()), id: \.self) { playerIndex in
                        if let ai = gameStateManager.aiPlayers[playerIndex] {
                            HStack(spacing: 4) {
                                Text("P\(playerIndex + 1):")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.caption2)
                                Text(ai.displayName)
                                    .foregroundColor(.white)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
                .padding(.top, 2)
            }
            
            // Current Turn Indicator
            HStack(spacing: 4) {
                if gameStateManager.isCurrentPlayerAI {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 6, height: 6)
                    Text("AI Thinking...")
                        .foregroundColor(.purple)
                        .font(.caption2)
                } else {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Your Turn")
                        .foregroundColor(.green)
                        .font(.caption2)
                }
            }
            .padding(.top, 2)
        }
        .padding(6)
        .background(Color.black.opacity(0.3))
        .cornerRadius(4)
    }
}

// To use this, add it to your HeaderView or ContentView temporarily:
// TestControlsView().environmentObject(gameStateManager)
