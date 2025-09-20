//
//  TestControlsView.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/18/25.
//
//  Add this view temporarily to test changing player counts

import SwiftUI

struct TestControlsView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    @State private var currentPlayers = GameState.numPlayers
    
    var body: some View {
        HStack {
            Text("Players: \(currentPlayers)")
                .foregroundColor(.white)
                .fontWeight(.semibold)
            
            Button("-") {
                if currentPlayers > 2 {
                    currentPlayers -= 1
                    GameState.numPlayers = currentPlayers
                    gameStateManager.updatePlayerCards()
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
                    gameStateManager.updatePlayerCards()
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.green.opacity(0.7))
            .cornerRadius(4)
            
            Spacer()
            
            Text("Cards: \(GameState.cardsPerPlayer)")
                .foregroundColor(.white)
                .font(.caption)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
    }
}

// To use this, add it to your HeaderView or ContentView temporarily:
// TestControlsView().environmentObject(gameStateManager)
