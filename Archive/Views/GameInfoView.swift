//
//  GameInfoView.swift
//  FivaDev
//
//  Created by Claude on 9/16/25.
//

import SwiftUI

struct GameInfoView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            // Right-side overlay with discard pile and current player info
            VStack(spacing: 12) {
                // Most recent discarded card
                discardPileSection
                
                Divider()
                    .background(Color.white.opacity(0.5))
                
                // Current player info
                currentPlayerSection
                
                // Game statistics
                if viewModel.gameState.phase == .playing {
                    Divider()
                        .background(Color.white.opacity(0.5))
                    
                    gameStatsSection
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
            )
        }
    }
    
    @ViewBuilder
    private var discardPileSection: some View {
        VStack(spacing: 4) {
            Text("Discard")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if let lastDiscarded = viewModel.gameState.discardPile.last {
                CardView(
                    card: lastDiscarded,
                    isSelected: false,
                    canDiscard: false,
                    size: .small
                )
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 60)
                    .overlay(
                        Text("Empty")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    )
            }
        }
    }
    
    @ViewBuilder
    private var currentPlayerSection: some View {
        VStack(spacing: 4) {
            Text("Current")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if let currentPlayer = viewModel.currentPlayer {
                VStack(spacing: 2) {
                    Circle()
                        .fill(currentPlayer.chipColor.color)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 1)
                        )
                    
                    Text(currentPlayer.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    
                    Text("\(currentPlayer.hand.count) cards")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private var gameStatsSection: some View {
        VStack(spacing: 6) {
            Text("Sequences")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 2) {
                ForEach(viewModel.gameState.players) { player in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(player.chipColor.color)
                            .frame(width: 12, height: 12)
                        
                        Text("\(player.completedSequences)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
            
            // Win requirement
            let requiredSequences = viewModel.gameState.players.count <= 3 ? 1 : 2
            Text("Need: \(requiredSequences)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Additional Info Views

struct SequenceIndicatorView: View {
    let sequence: GameSequence
    let playerColor: ChipColor
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(playerColor.color)
                .frame(width: 8, height: 8)
            
            Text(sequenceDescription)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var sequenceDescription: String {
        switch sequence.direction {
        case .horizontal: return "Horizontal"
        case .vertical: return "Vertical"
        case .diagonalUp: return "Diagonal ↗"
        case .diagonalDown: return "Diagonal ↘"
        }
    }
}

#Preview {
    HStack {
        Spacer()
        GameInfoView(viewModel: GameViewModel())
    }
    .background(Color.gray.opacity(0.3))
}
