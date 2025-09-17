//
//  GameBoardView.swift
//  FivaDev
//
//  Created by Claude on 9/16/25.
//

import SwiftUI

struct GameBoardView: View {
    @ObservedObject var viewModel: GameViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // GameBoard rectangle - maintains orientation relationship with device
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    GameGrid(viewModel: viewModel)
                        .padding(20) // Inner padding for the grid
                )
                .aspectRatio(1.0, contentMode: .fit) // Keep square aspect ratio
                .padding(.horizontal, 20) // Outer padding
            
            Spacer()
        }
    }
}

struct GameGrid: View {
    @ObservedObject var viewModel: GameViewModel
    let gridSize = 10
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: gridSize),
            spacing: 3
        ) {
            ForEach(0..<100, id: \.self) { position in
                GameGridElement(
                    position: position,
                    viewModel: viewModel
                )
            }
        }
    }
}

struct GameGridElement: View {
    let position: Int
    @ObservedObject var viewModel: GameViewModel
    
    private var boardSpace: BoardSpace? {
        viewModel.getBoardSpace(at: position)
    }
    
    private var isHighlighted: Bool {
        viewModel.shouldHighlightPosition(position)
    }
    
    private var hasHoverEffect: Bool {
        viewModel.shouldShowHoverEffect(position)
    }
    
    var body: some View {
        Rectangle()
            .fill(backgroundColor)
            .aspectRatio(1.0/1.5, contentMode: .fit) // 1:1.5 aspect ratio as specified
            .overlay(content: elementContent)
            .border(borderColor, width: borderWidth)
            .scaleEffect(hasHoverEffect ? 1.5 : 1.0) // 50% size increase on hover
            .animation(.easeInOut(duration: 0.2), value: hasHoverEffect)
            .onTapGesture {
                viewModel.selectBoardPosition(position)
            }
            .onHover { hovering in
                #if os(macOS)
                viewModel.hoverPosition(hovering ? position : nil)
                #endif
            }
    }
    
    private var backgroundColor: Color {
        if let boardSpace = boardSpace, boardSpace.position.isCorner {
            return Color.yellow.opacity(0.3) // Corner spaces (free)
        }
        
        if isHighlighted {
            return Color.green.opacity(0.3)
        }
        
        if boardSpace?.isPartOfSequence == true {
            return Color.orange.opacity(0.3)
        }
        
        return Color.white
    }
    
    private var borderColor: Color {
        if isHighlighted {
            return Color.green
        }
        
        if hasHoverEffect {
            return Color.blue
        }
        
        return Color.black
    }
    
    private var borderWidth: CGFloat {
        if isHighlighted || hasHoverEffect {
            return 2.0
        }
        return 0.5
    }
    
    @ViewBuilder
    private var elementContent: some View {
        VStack(spacing: 2) {
            // Position number (for debugging - remove in production)
            Text("\(position)")
                .font(.caption2)
                .foregroundColor(.gray)
            
            Spacer()
            
            // Card content
            if let boardSpace = boardSpace {
                if boardSpace.position.isCorner {
                    // Corner space - show Joker
                    Text("★")
                        .font(.title2)
                        .foregroundColor(.orange)
                } else if let card = boardSpace.position.card {
                    // Regular card position
                    VStack(spacing: 1) {
                        Text(card.rank.rawValue)
                            .font(.caption)
                            .fontWeight(.bold)
                        Text(card.suit.rawValue)
                            .font(.caption2)
                    }
                    .foregroundColor(card.suit.color)
                }
            }
            
            Spacer()
            
            // Chip overlay
            if let chip = boardSpace?.chip {
                Circle()
                    .fill(chip.color.color)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 1)
                    )
            }
        }
        .padding(2)
    }
}

#Preview {
    GeometryReader { geometry in
        GameBoardView(
            viewModel: GameViewModel(),
            geometry: geometry
        )
    }
}
