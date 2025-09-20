//
//  GameGridElement.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/17/25.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct GameGridElement: View {
    let position: Int
    let width: CGFloat
    let height: CGFloat
    let orientation: AppOrientation
    
    @EnvironmentObject var gameStateManager: GameStateManager
    
    // Card distribution for the 10x10 grid (100 positions, 0-99)
    private let cardDistribution = [
        "RedJoker", "6D", "7D", "8D", "9D", "10D", "QD", "KD", "AD", "BlackJoker",
        "5D", "3H", "2H", "2S", "3S", "4S", "5S", "6S", "7S", "AC",
        "4D", "4H", "KD", "AD", "AC", "KC", "QC", "10C", "8S", "KC",
        "3D", "5H", "QD", "QH", "10H", "9H", "8H", "9C", "9S", "QC",
        "2D", "6H", "10D", "KH", "3H", "2H", "7H", "8C", "10S", "10C",
        "AS", "7H", "9D", "AH", "4H", "5H", "6H", "7C", "QS", "9C",
        "KS", "8H", "8D", "2C", "3C", "4C", "5C", "6C", "KS", "8C",
        "QS", "9H", "7D", "6D", "5D", "4D", "3D", "2D", "AS", "7C",
        "10S", "10H", "QH", "KH", "AH", "2C", "3C", "4C", "5C", "6C",
        "BlackJoker", "9S", "8S", "7S", "6S", "5S", "4S", "3S", "2S", "RedJoker"
        
//        "RedJoker", "5D", "6D", "7D", "8D", "9D", "QD", "KD", "AD", "BlackJoker",
//        "5D", "3H", "2H", "2S", "3S", "4S", "5S", "6S", "7S", "AC",
//        "4D", "4H", "KD", "AD", "KS", "QS", "JS", "10S", "9S", "KS",
//        "2D", "5H", "QD", "KD", "6H", "7H", "8H", "9C", "8S", "QS",
//        "AD", "6H", "8D", "KD", "5H", "4H", "6H", "10C", "9S", "10C",
//        "AS", "7H", "9D", "3H", "4H", "7H", "9C", "JS", "8C", "9C",
//        "KS", "8H", "10D", "2C", "3C", "4C", "5C", "KS", "7C", "8C",
//        "QS", "9H", "JD", "KD", "AH", "2C", "3C", "4C", "5C", "6C",
//        "10S", "10H", "QD", "3S", "4S", "5S", "6S", "7S", "AS", "7C",
//        "BlackJoker", "9S", "8S", "7S", "6S", "5S", "4S", "3S", "2S", "RedJoker"
    ]
    
    private var cardName: String {
        guard position >= 0 && position < cardDistribution.count else {
            return "BlueBack" // Fallback
        }
        return cardDistribution[position]
    }
    
    var body: some View {
        let shouldHighlight = gameStateManager.shouldHighlight(position: position)
        
        ZStack {
            // Card background with rounded corners
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white)
//                .stroke(Color.black.opacity(0.9), lineWidth: 3)
//                .stroke(Color(hex: "009051").opacity(0.9), lineWidth: 3)
                .stroke(Color(hex: "009051"), lineWidth: 4)
            
            // Card image
            #if canImport(UIKit)
            if let cardImage = UIImage(named: cardName) {
                Image(uiImage: cardImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                    .padding(0)
            } else {
                // Fallback if image not found
                cardFallbackView
            }
            #else
            // Use SwiftUI Image for non-UIKit platforms (macOS, etc.)
            Image(cardName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .padding(2)
            #endif
        }
        .frame(width: width, height: height)
        .scaleEffect(shouldHighlight ? 1.5 : 1.0)
        .background(
            Group {
                if shouldHighlight {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                } else {
                    Color.clear
                }
            }
        )
        .opacity(shouldHighlight ? 1.0 : (gameStateManager.highlightedCards.isEmpty ? 1.0 : 0.7))
        .animation(.easeInOut(duration: 0.2), value: shouldHighlight)
        .zIndex(shouldHighlight ? 1 : 0)
    }
    
    private var cardFallbackView: some View {
        VStack {
            Text(cardName)
                .font(.caption2)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            Text("\(position)")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(2)
    }
}

#Preview("Card 0 - Red Joker") {
    GameGridElement(
        position: 0,
        width: 40,
        height: 60,
        orientation: .portrait
    )
    .environmentObject(GameStateManager())
    .padding()
}

#Preview("Card 50 - AS") {
    GameGridElement(
        position: 50,
        width: 40,
        height: 60,
        orientation: .portrait
    )
    .environmentObject(GameStateManager())
    .padding()
}
