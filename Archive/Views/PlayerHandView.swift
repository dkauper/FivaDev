//
//  PlayerHandView.swift
//  FivaDev
//
//  Created by Claude on 9/16/25.
//

import SwiftUI

struct PlayerHandView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            Spacer()
            
            // Draggable, semi-transparent overlay for player's hand
            handOverlay
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                        .opacity(0.8)
                )
        }
    }
    
    @ViewBuilder
    private var handOverlay: some View {
        VStack(spacing: 8) {
            // Header with expand/collapse button
            HStack {
                Text("Hand")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { 
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.left" : "chevron.right")
                        .font(.caption)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            
            // Cards container
            if let currentPlayer = viewModel.currentPlayer {
                if isExpanded {
                    // Expanded view - show all cards
                    expandedCardView(cards: currentPlayer.hand)
                } else {
                    // Collapsed view - show limited cards
                    collapsedCardView(cards: currentPlayer.hand)
                }
            }
        }
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private func expandedCardView(cards: [Card]) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 4) {
                ForEach(cards) { card in
                    CardView(
                        card: card,
                        isSelected: viewModel.selectedCard == card,
                        canDiscard: viewModel.canDiscardDeadCard(card),
                        size: .small
                    )
                    .onTapGesture {
                        if viewModel.canDiscardDeadCard(card) {
                            // Show discard option
                        } else {
                            viewModel.selectCard(card)
                            highlightCardPositions(for: card)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(maxHeight: 300)
    }
    
    @ViewBuilder
    private func collapsedCardView(cards: [Card]) -> some View {
        VStack(spacing: 4) {
            // Show first 3-4 cards
            ForEach(Array(cards.prefix(4))) { card in
                CardView(
                    card: card,
                    isSelected: viewModel.selectedCard == card,
                    canDiscard: viewModel.canDiscardDeadCard(card),
                    size: .tiny
                )
                .onTapGesture {
                    if viewModel.canDiscardDeadCard(card) {
                        // Show discard option
                    } else {
                        viewModel.selectCard(card)
                        highlightCardPositions(for: card)
                    }
                }
            }
            
            // Show card count if more cards exist
            if cards.count > 4 {
                Text("+\(cards.count - 4)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func highlightCardPositions(for card: Card) {
        let positions = viewModel.getCardPositions(for: card)
        // Here you could add temporary visual effects to highlight
        // the corresponding positions on the game board
    }
}

struct CardView: View {
    let card: Card
    let isSelected: Bool
    let canDiscard: Bool
    let size: CardSize
    
    enum CardSize {
        case tiny, small, medium, large
        
        var dimensions: (width: CGFloat, height: CGFloat) {
            switch self {
            case .tiny: return (30, 45)
            case .small: return (40, 60) 
            case .medium: return (50, 75)
            case .large: return (60, 90)
            }
        }
        
        var fontSize: Font {
            switch self {
            case .tiny: return .caption2
            case .small: return .caption
            case .medium: return .footnote
            case .large: return .body
            }
        }
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.white)
            .frame(width: size.dimensions.width, height: size.dimensions.height)
            .overlay(
                cardContent
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .background(
                // Glass effect as specified in requirements
                RoundedRectangle(cornerRadius: 6)
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
            )
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    @ViewBuilder
    private var cardContent: some View {
        VStack(spacing: 1) {
            Text(card.rank.rawValue)
                .font(size.fontSize)
                .fontWeight(.bold)
                .foregroundColor(card.suit.color)
            
            Text(card.suit.rawValue)
                .font(.caption2)
                .foregroundColor(card.suit.color)
            
            if size == .medium || size == .large {
                Spacer()
                
                // Special jack indicators
                if card.isTwoEyedJack {
                    Text("Wild")
                        .font(.caption2)
                        .foregroundColor(.blue)
                } else if card.isOneEyedJack {
                    Text("Remove")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                
                if canDiscard {
                    Text("Dead")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(2)
    }
    
    private var borderColor: Color {
        if isSelected {
            return .blue
        } else if canDiscard {
            return .orange
        } else {
            return .black
        }
    }
    
    private var borderWidth: CGFloat {
        isSelected ? 2.0 : 1.0
    }
}

#Preview {
    HStack {
        PlayerHandView(viewModel: GameViewModel())
        Spacer()
    }
    .background(Color.gray.opacity(0.3))
}
