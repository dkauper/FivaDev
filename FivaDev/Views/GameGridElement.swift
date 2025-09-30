//
//  GameGridElement.swift
//  FivaDev
//
//  CORRECTED: Reverted to working orientation-based percentages approach
//  Created by Doron Kauper on 9/17/25.
//  Revised: September 28, 2025, 4:50 PM PST
//

import SwiftUI

struct GameGridElement: View {
    let position: Int
    let width: CGFloat
    let height: CGFloat
    let orientation: AppOrientation
    
    @EnvironmentObject var gameStateManager: GameStateManager
    
    // Card distribution for the 10x10 grid (100 positions, 0-99)
    // Updated to match Playing cards game board distribution.md
    private let cardDistribution = [
        "RedJoker", "5D", "6D", "7D", "8D", "9D", "QD", "KD", "AD", "BlackJoker",
        "5D", "3H", "2H", "2S", "3S", "4S", "5S", "6S", "7S", "AC",
        "4D", "4H", "KD", "AD", "AC", "KC", "QC", "10C", "8S", "KC",
        "3D", "5H", "QD", "QH", "10H", "9H", "8H", "9C", "9S", "QC",
        "2D", "6H", "10D", "KH", "3H", "2H", "7H", "8C", "10S", "10C",
        "AS", "7H", "9D", "AH", "4H", "5H", "6H", "7C", "QS", "9C",
        "KS", "8H", "8D", "2C", "3C", "4C", "5C", "6C", "KS", "8C",
        "QS", "9H", "7D", "6D", "5D", "4D", "3D", "2D", "AS", "7C",
        "10S", "10H", "QH", "KH", "AH", "2C", "3C", "4C", "5C", "6C",
        "BlackJoker", "9S", "8S", "7S", "6S", "5S", "4S", "3S", "2S", "RedJoker"
    ]
    
    private var cardName: String {
        guard position >= 0 && position < cardDistribution.count else {
            return "BlueBack" // Fallback
        }
        return cardDistribution[position]
    }
    
    private var cardData: CardData {
        return CardData.parse(from: cardName)
    }
    
    var body: some View {
        ElevatedCard(
            width: width,
            height: height,
            isHighlighted: gameStateManager.shouldHighlight(position: position),
            highlightScale: 1.5, // 50% increase per your specification
            zIndex: Double(position),
            highlightZIndex: 10000
        ) {
            PercentageBasedPlayingCard(
                cardData: cardData,
                width: width,
                height: height,
                deviceOrientation: orientation // Pass device orientation for component percentages
            )
        }
        .opacity(gameStateManager.shouldHighlight(position: position) ? 1.0 :
                (gameStateManager.highlightedCards.isEmpty ? 1.0 : 0.7))
    }
}

// MARK: - Card Data Structure
private struct CardData {
    let suit: Suit?
    let rank: Rank?
    let isJoker: Bool
    let jokerColor: JokerColor?
    
    enum Suit: String, CaseIterable {
        case hearts = "H", diamonds = "D", clubs = "C", spades = "S"
        
        var symbol: String {
            switch self {
            case .hearts: return "♥"
            case .diamonds: return "♦"
            case .clubs: return "♣"
            case .spades: return "♠"
            }
        }
        
        var color: Color {
            switch self {
            case .hearts, .diamonds: return .red
            case .clubs, .spades: return .black
            }
        }
    }
    
    enum Rank: String, CaseIterable {
        case two = "2", three = "3", four = "4", five = "5", six = "6", seven = "7", eight = "8", nine = "9", ten = "10"
        case jack = "J", queen = "Q", king = "K", ace = "A"
        
        var isFaceCard: Bool {
            return [.jack, .queen, .king].contains(self)
        }
        
        var isAce: Bool {
            return self == .ace
        }
        
        var pipPattern: String? {
            switch self {
            case .two: return "pip_pattern_2"
            case .three: return "pip_pattern_3"
            case .four: return "pip_pattern_4"     // READY: For your new asset
            case .five: return "pip_pattern_5"
            case .six: return "pip_pattern_6"      // READY: For your new asset
            case .seven: return "pip_pattern_7"
            case .eight: return "pip_pattern_8"    // READY: For your new asset
            case .nine: return "pip_pattern_9"     // READY: For your new asset
            case .ten: return "pip_pattern_10"
            default: return nil // Ace and face cards don't use pip patterns
            }
        }
    }
    
    enum JokerColor {
        case red, black
    }
    
    static func parse(from cardName: String) -> CardData {
        if cardName == "RedJoker" {
            return CardData(suit: nil, rank: nil, isJoker: true, jokerColor: .red)
        } else if cardName == "BlackJoker" {
            return CardData(suit: nil, rank: nil, isJoker: true, jokerColor: .black)
        }
        
        // Parse regular cards (e.g., "5D", "10H", "AC")
        let suitString = String(cardName.suffix(1))
        let rankString = String(cardName.dropLast(1))
        
        let suit = Suit(rawValue: suitString)
        let rank = Rank(rawValue: rankString)
        
        return CardData(suit: suit, rank: rank, isJoker: false, jokerColor: nil)
    }
}

// MARK: - Orientation-Based Component Percentages
private struct ComponentPercentages {
    // Center Rectangle percentages
    let centerRectangleTopPadding: CGFloat
    let centerRectangleBottomPadding: CGFloat
    let centerRectangleSidePadding: CGFloat
    
    // Corner Pip percentages
    let cornerPipTopPadding: CGFloat
    let cornerPipBottomPadding: CGFloat
    let cornerPipSidePadding: CGFloat
    let cornerPipHeight: CGFloat
    let cornerPipWidth: CGFloat
    let cornerSuitTopPadding: CGFloat
    let cornerSuitBottomPadding: CGFloat
    
    // ADDED: Separate sizing for rank and suit in corners
    let cornerRankHeight: CGFloat
    let cornerSuitHeight: CGFloat
    
    // Content scaling factors
    let faceCardScaleFactor: CGFloat
    let aceScaleFactor: CGFloat
    let pipPatternScaleFactor: CGFloat
    
    static func forOrientation(_ orientation: AppOrientation) -> ComponentPercentages {
        switch orientation {
        case .portrait:
            // Use "Vertical" percentages from Playing Card Components.md
            return ComponentPercentages(
                centerRectangleTopPadding: 0.15,    // 19%
                centerRectangleBottomPadding: 0.15, // 19%
                centerRectangleSidePadding: 0.03,   // 3%
                cornerPipTopPadding: 0.02,          // 5%
                cornerPipBottomPadding: 0.02,       // 5%
                cornerPipSidePadding: 0.13,         // 13%
                cornerPipHeight: 0.18,              // 18%
                cornerPipWidth: 0.22,               // 16%
                cornerSuitTopPadding: 0.3,         // 25%
                cornerSuitBottomPadding: 0.31,      // 75%
                cornerRankHeight: 0.34,             // 18% of card height for rank
                cornerSuitHeight: 0.25,             // 16% of card width for suit
                faceCardScaleFactor: 0.98,           // 90% of center rectangle for portrait
                aceScaleFactor: 0.7,                // 40% for ace pip size
                pipPatternScaleFactor: 0.90         // 95% of center rectangle for portrait pips
            )
        case .landscape:
            // Use "Horizontal" percentages from Playing Card Components.md
            return ComponentPercentages(
                centerRectangleTopPadding: 0.03,    // 3%
                centerRectangleBottomPadding: 0.03, // 3%
                centerRectangleSidePadding: 0.19,   // 19% (swapped from vertical)
                cornerPipTopPadding: 0.05,          // 5%
                cornerPipBottomPadding: 0.05,       // 5%
                cornerPipSidePadding: 0.12,         // 10%
                cornerPipHeight: 0.8,              // 27%
                cornerPipWidth: 0.105,              // 10.5%
                cornerSuitTopPadding: 0.5,         // 36%
                cornerSuitBottomPadding: 0.5,      // 67%
                cornerRankHeight: 0.6,             // 27% of card height for rank
                cornerSuitHeight: 0.18,            // 10.5% of card width for suit
                faceCardScaleFactor: 0.95,          // 85% of center rectangle for landscape
                aceScaleFactor: 0.5,               // 35% for ace pip size in landscape
                pipPatternScaleFactor: 0.88         // 88% of center rectangle for landscape pips
            )
        }
    }
}

// MARK: - Percentage-Based Playing Card View
private struct PercentageBasedPlayingCard: View {
    let cardData: CardData
    let width: CGFloat
    let height: CGFloat
    let deviceOrientation: AppOrientation
    
    // Get orientation-specific percentages
    private var percentages: ComponentPercentages {
        ComponentPercentages.forOrientation(deviceOrientation)
    }
    
    private let cardPadding: CGFloat = 0.02 // 2% padding around card edge
    
    var body: some View {
        ZStack {
            // Card background with border
            RoundedRectangle(cornerRadius: width * 0.05) // 5% corner radius
                .fill(Color.white)
                .stroke(Color.black, lineWidth: 1)
            
            if cardData.isJoker {
                jokerContent
            } else {
                regularCardContent
            }
        }
        .frame(width: width, height: height)
    }
    
    @ViewBuilder
    private var jokerContent: some View {
        if let jokerColor = cardData.jokerColor {
            let imageName = jokerColor == .red ? "JokerColor" : "JokerBW"
            
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(width * cardPadding)
        }
    }
    
    @ViewBuilder
    private var regularCardContent: some View {
        if let suit = cardData.suit, let rank = cardData.rank {
            ZStack {
                // Corner pips (rank and suit)
                cornerPips(suit: suit, rank: rank)
                
                // Center content
                centerContent(suit: suit, rank: rank)
            }
        }
    }
    
    @ViewBuilder
    private func cornerPips(suit: CardData.Suit, rank: CardData.Rank) -> some View {
        // TOP-LEFT CORNER: Rank above suit
        // Rank positioning
        Text(rank.rawValue)
            .font(.system(size: height * percentages.cornerRankHeight * 0.6, weight: .bold))
            .foregroundColor(suit.color)
            .position(
                x: width * percentages.cornerPipSidePadding,
                y: height * percentages.cornerPipTopPadding + (height * percentages.cornerRankHeight * 0.3)
            )
        
        // Suit symbol positioning
        Text(suit.symbol)
            .font(.system(size: width * percentages.cornerSuitHeight * 0.8))
            .foregroundColor(suit.color)
            .position(
                x: width * percentages.cornerPipSidePadding,
                y: height * percentages.cornerSuitTopPadding
            )
        
        // BOTTOM-RIGHT CORNER: Suit above rank (rotated 180°)
        // Suit symbol positioning (rotated)
        Text(suit.symbol)
            .font(.system(size: width * percentages.cornerSuitHeight * 0.8))
            .foregroundColor(suit.color)
            .rotationEffect(.degrees(180))
            .position(
                x: width * (1 - percentages.cornerPipSidePadding),
                y: height * (1 - percentages.cornerSuitBottomPadding)
            )
        
        // Rank positioning (rotated)
        Text(rank.rawValue)
            .font(.system(size: height * percentages.cornerRankHeight * 0.6, weight: .bold))
            .foregroundColor(suit.color)
            .rotationEffect(.degrees(180))
            .position(
                x: width * (1 - percentages.cornerPipSidePadding),
                y: height * (1 - percentages.cornerPipBottomPadding - (percentages.cornerRankHeight * 0.3))
            )
    }
    
    @ViewBuilder
    private func centerContent(suit: CardData.Suit, rank: CardData.Rank) -> some View {
        // Center rectangle calculation responds to orientation-based percentages
        let centerWidth = width * (1 - 2 * percentages.centerRectangleSidePadding)
        let centerHeight = height * (1 - percentages.centerRectangleTopPadding - percentages.centerRectangleBottomPadding)
        
        Rectangle()
            .fill(Color.clear)
            .frame(width: centerWidth, height: centerHeight)
            .overlay(
                Group {
                    if rank.isFaceCard {
                        faceCardContent(suit: suit, rank: rank, centerWidth: centerWidth, centerHeight: centerHeight)
                    } else if rank.isAce {
                        aceContent(suit: suit, centerWidth: centerWidth, centerHeight: centerHeight)
                    } else {
                        pipContent(suit: suit, rank: rank, centerWidth: centerWidth, centerHeight: centerHeight)
                    }
                }
            )
            .position(x: width * 0.5, y: height * 0.5)
    }
    
    @ViewBuilder
    private func faceCardContent(suit: CardData.Suit, rank: CardData.Rank, centerWidth: CGFloat, centerHeight: CGFloat) -> some View {
        // Face cards scale with orientation-based center rectangle and scale factor
        let scaledWidth = centerWidth * percentages.faceCardScaleFactor
        let scaledHeight = centerHeight * percentages.faceCardScaleFactor
        
        switch rank {
        case .jack:
            Image("Jack\(suit.rawValue == "H" ? "Hearts" : suit.rawValue == "D" ? "Diamonds" : suit.rawValue == "C" ? "Clubs" : "Spades")")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: scaledWidth, height: scaledHeight)
        case .queen:
            Image("Queen\(suit.rawValue == "H" ? "Hearts" : suit.rawValue == "D" ? "Diamonds" : suit.rawValue == "C" ? "Clubs" : "Spades")")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: scaledWidth, height: scaledHeight)
        case .king:
            Image("King\(suit.rawValue == "H" ? "Hearts" : suit.rawValue == "D" ? "Diamonds" : suit.rawValue == "C" ? "Clubs" : "Spades")")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: scaledWidth, height: scaledHeight)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func aceContent(suit: CardData.Suit, centerWidth: CGFloat, centerHeight: CGFloat) -> some View {
        // Ace scales with orientation-based percentages
        let pipSize = min(centerWidth, centerHeight) * percentages.aceScaleFactor
        
        Text(suit.symbol)
            .font(.system(size: pipSize))
            .foregroundColor(suit.color)
            .position(x: centerWidth * 0.5, y: centerHeight * 0.5)
    }
    
    @ViewBuilder
    private func pipContent(suit: CardData.Suit, rank: CardData.Rank, centerWidth: CGFloat, centerHeight: CGFloat) -> some View {
        if let pipPattern = rank.pipPattern {
            // Pip patterns use orientation-based scaling factors
            let scaledWidth = centerWidth * percentages.pipPatternScaleFactor
            let scaledHeight = centerHeight * percentages.pipPatternScaleFactor
            
            Image(pipPattern)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: scaledWidth, height: scaledHeight)
                .foregroundColor(suit.color)
        } else {
            // IMPROVED FALLBACK: Use orientation-responsive scaling while waiting for pip assets
            let fallbackSize = min(centerWidth, centerHeight) * percentages.pipPatternScaleFactor * 0.4
            
            Text(rank.rawValue)
                .font(.system(size: fallbackSize, weight: .bold))
                .foregroundColor(suit.color)
        }
    }
}

#Preview("Red Joker") {
    GameGridElement(
        position: 0,
        width: 60,
        height: 60,
        orientation: .portrait
    )
    .environmentObject(GameStateManager())
    .padding()
}

#Preview("King of Hearts - Portrait") {
    GameGridElement(
        position: 7, // KD position
        width: 60,
        height: 60,
        orientation: .portrait
    )
    .environmentObject(GameStateManager())
    .padding()
}

#Preview("King of Hearts - Landscape") {
    GameGridElement(
        position: 7, // KD position  
        width: 60,
        height: 60,
        orientation: .landscape
    )
    .environmentObject(GameStateManager())
    .padding()
}

#Preview("Two of Hearts - Portrait (Pip Pattern Test)") {
    GameGridElement(
        position: 12, // 2H position
        width: 60,
        height: 60,
        orientation: .portrait
    )
    .environmentObject(GameStateManager())
    .padding()
}

#Preview("Two of Hearts - Landscape (Pip Pattern Test)") {
    GameGridElement(
        position: 12, // 2H position
        width: 60,
        height: 60,
        orientation: .landscape
    )
    .environmentObject(GameStateManager())
    .padding()
}

#Preview("Ace of Spades - Portrait") {
    GameGridElement(
        position: 50, // AS position
        width: 60,
        height: 60,
        orientation: .portrait
    )
    .environmentObject(GameStateManager())
    .padding()
}

#Preview("Ace of Spades - Landscape") {
    GameGridElement(
        position: 50, // AS position
        width: 60,
        height: 60,
        orientation: .landscape
    )
    .environmentObject(GameStateManager())
    .padding()
}
