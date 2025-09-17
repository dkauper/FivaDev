//
//  GameView.swift
//  FivaDev
//
//  Created by Claude on 9/16/25.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color as specified in requirements
                Color(hex: "#B7E4CC")
                    .ignoresSafeArea()
                
                if viewModel.gameState.phase == .setup || viewModel.showGameSetup {
                    GameSetupView(viewModel: viewModel)
                } else {
                    gameContent(geometry: geometry)
                }
            }
        }
        .onAppear {
            if viewModel.gameState.phase == .setup {
                viewModel.startNewGame(with: 2) // Default 2-player game
            }
        }
    }
    
    @ViewBuilder
    private func gameContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Game status bar
            gameStatusBar
            
            Spacer()
            
            // Main game area with board and overlays
            ZStack {
                GameBoardView(
                    viewModel: viewModel,
                    geometry: geometry
                )
                
                // Player hand overlay (left side)
                HStack {
                    PlayerHandView(viewModel: viewModel)
                        .frame(maxWidth: 120)
                    
                    Spacer()
                    
                    // Game info overlay (right side)
                    GameInfoView(viewModel: viewModel)
                        .frame(maxWidth: 120)
                }
                .padding()
            }
            
            Spacer()
            
            // Error message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .alert("Game Over", isPresented: .constant(viewModel.isGameOver)) {
            Button("New Game") {
                viewModel.showGameSetup = true
            }
            Button("OK") { }
        } message: {
            if let winner = viewModel.winner {
                Text("\(winner.name) wins!")
            }
        }
    }
    
    private var gameStatusBar: some View {
        HStack {
            if let currentPlayer = viewModel.currentPlayer {
                HStack {
                    Circle()
                        .fill(currentPlayer.chipColor.color)
                        .frame(width: 20, height: 20)
                    Text("\(currentPlayer.name)'s Turn")
                        .font(.headline)
                }
            }
            
            Spacer()
            
            Button("Menu") {
                viewModel.showGameSetup = true
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
    }
}

struct GameSetupView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var playerCount: Int = 2
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Fiva Game Setup")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 20) {
                Text("Number of Players")
                    .font(.headline)
                
                Picker("Players", selection: $playerCount) {
                    ForEach(2...4, id: \.self) { count in
                        Text("\(count) Players")
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Button("Start Game") {
                viewModel.startNewGame(with: playerCount)
                viewModel.showGameSetup = false
            }
            .font(.title2)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}

#Preview {
    GameView()
}
