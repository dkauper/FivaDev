//
//  SharedPlayingCardComponents.swift
//  FivaDev
//
//  Unified card rendering components shared between PlayerHandView and GameGridElement
//  Created: October 1, 2025, 10:30 AM PDT
//  Optimized: October 3, 2025, 4:45 PM Pacific - Added dimension validation
//

import SwiftUI

// MARK: - Card Data Structure
/// Shared card data structure for parsing and representing playing cards
struct PlayingCardData {
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
        
        var assetName: String {
            switch self {
            case .hearts: return "Hearts"
            case .diamonds: return "Diamonds"
            case .clubs: return "Clubs"
            case .spades: return "Spades"
            }
        }
    }
    
    enum Rank: String, CaseIterable {
        case two = "2", three = "3", four = "4", five = "5", six = "6"
        case seven = "7", eight = "8", nine = "9", ten = "10"
        case jack = "J", queen = "Q", king = "K", ace = "A"
        
        var isFaceCard: Bool {
            return [.jack, .queen, .king].contains(self)
        }
        
        var isAce: Bool {
            return self == .ace
        }
        
        /// Returns the pip pattern name for this rank and suit
        /// OPTIMIZED: String concatenation instead of interpolation
        func pipPattern(for suit: Suit) -> String? {
            let suitCode = suit.rawValue
            switch self {
            case .two: return "pip_pattern_2_" + suitCode
            case .three: return "pip_pattern_3_" + suitCode
            case .four: return "pip_pattern_4_" + suitCode
            case .five: return "pip_pattern_5_" + suitCode
            case .six: return "pip_pattern_6_" + suitCode
            case .seven: return "pip_pattern_7_" + suitCode
            case .eight: return "pip_pattern_8_" + suitCode
            case .nine: return "pip_pattern_9_" + suitCode
            case .ten: return "pip_pattern_10_" + suitCode
            default: return nil // Ace and face cards don't use pip patterns
            }
        }
    }
    
    enum JokerColor {
        case red, black
    }
    
    static func parse(from cardName: String) -> PlayingCardData {
        if cardName == "RedJoker" {
            return PlayingCardData(suit: nil, rank: nil, isJoker: true, jokerColor: .red)
        } else if cardName == "BlackJoker" {
            return PlayingCardData(suit: nil, rank: nil, isJoker: true, jokerColor: .black)
        }
        
        // Parse regular cards (e.g., "5D", "10H", "AC")
        let suitString = String(cardName.suffix(1))
        let rankString = String(cardName.dropLast(1))
        
        let suit = Suit(rawValue: suitString)
        let rank = Rank(rawValue: rankString)
        
        return PlayingCardData(suit: suit, rank: rank, isJoker: false, jokerColor: nil)
    }
}

// MARK: - Component Percentages
/// Orientation-specific layout percentages for card components
/// OPTIMIZED: Pre-computed static instances to avoid repeated allocation
struct CardComponentPercentages {
    // Center Rectangle percentages
    let centerRectangleTopPadding: CGFloat
    let centerRectangleBottomPadding: CGFloat
    let centerRectangleSidePadding: CGFloat
    
    // Corner Pip percentages
    let cornerPipTopPadding: CGFloat
    let cornerPipBottomPadding: CGFloat
    let cornerPipSidePadding: CGFloat
    let cornerSuitTopPadding: CGFloat
    let cornerSuitBottomPadding: CGFloat
    
    // Sizing for rank and suit in corners
    let cornerRankHeight: CGFloat
    let cornerSuitHeight: CGFloat
    
    // Content scaling factors
    let faceCardScaleFactor: CGFloat
    let aceScaleFactor: CGFloat
    let pipPatternScaleFactor: CGFloat
    
    // OPTIMIZED: Pre-computed static instances
    static let portrait = CardComponentPercentages(
        centerRectangleTopPadding: 0.15,
        centerRectangleBottomPadding: 0.15,
        centerRectangleSidePadding: 0.03,
        cornerPipTopPadding: 0.02,
        cornerPipBottomPadding: 0.02,
        cornerPipSidePadding: 0.13,
        cornerSuitTopPadding: 0.3,
        cornerSuitBottomPadding: 0.31,
        cornerRankHeight: 0.34,
        cornerSuitHeight: 0.25,
        faceCardScaleFactor: 1.1,
        aceScaleFactor: 0.7,
        pipPatternScaleFactor: 0.90
    )
    
    static let landscape = CardComponentPercentages(
        centerRectangleTopPadding: 0.02,
        centerRectangleBottomPadding: 0.02,
        centerRectangleSidePadding: 0.18,
        cornerPipTopPadding: 0.05,
        cornerPipBottomPadding: 0.05,
        cornerPipSidePadding: 0.16,
        cornerSuitTopPadding: 0.5,
        cornerSuitBottomPadding: 0.5,
        cornerRankHeight: 0.6,
        cornerSuitHeight: 0.18,
        faceCardScaleFactor: 1.0,
        aceScaleFactor: 0.5,
        pipPatternScaleFactor: 0.88
    )
    
    // OPTIMIZED: Zero allocation - returns pre-computed reference
    static func forOrientation(_ orientation: AppOrientation) -> CardComponentPercentages {
        orientation == .portrait ? portrait : landscape
    }
}

// MARK: - Unified Playing Card View
/// Unified card rendering view used by both PlayerHandView and GameGridElement
/// OPTIMIZED: Cached computed values to avoid repeated calculation
struct UnifiedPlayingCardView: View {
    let cardData: PlayingCardData
    let width: CGFloat
    let height: CGFloat
    let orientation: AppOrientation
    let cardPadding: CGFloat
    
    // OPTIMIZED: Cache computed values
    private let percentages: CardComponentPercentages
    private let cornerRadius: CGFloat
    
    init(cardData: PlayingCardData, width: CGFloat, height: CGFloat, orientation: AppOrientation, cardPadding: CGFloat = 0.02) {
        self.cardData = cardData
        self.width = width
        self.height = height
        self.orientation = orientation
        self.cardPadding = cardPadding
        
        // OPTIMIZED: Compute and cache values once during initialization
        self.percentages = CardComponentPercentages.forOrientation(orientation)
        self.cornerRadius = width * 0.05
    }
    
    // Helper to ensure valid dimensions
    private func validDimension(_ value: CGFloat) -> CGFloat {
        guard value.isFinite && value > 0 else { return 1 }
        return value
    }
    
    var body: some View {
        // Validate dimensions at entry
        let safeWidth = validDimension(width)
        let safeHeight = validDimension(height)
        
        return ZStack {
            // Card background with border - use cached cornerRadius
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white)
                .stroke(Color.black, lineWidth: 1)
            
            if cardData.isJoker {
                jokerContent(safeWidth: safeWidth)
            } else {
                regularCardContent(safeWidth: safeWidth, safeHeight: safeHeight)
            }
        }
        .frame(width: safeWidth, height: safeHeight)
    }
    
    @ViewBuilder
    private func jokerContent(safeWidth: CGFloat) -> some View {
        if let jokerColor = cardData.jokerColor {
            let imageName = jokerColor == .red ? "JokerColor" : "JokerBW"
            
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(safeWidth * cardPadding)
        }
    }
    
    @ViewBuilder
    private func regularCardContent(safeWidth: CGFloat, safeHeight: CGFloat) -> some View {
        if let suit = cardData.suit, let rank = cardData.rank {
            ZStack {
                cornerPips(suit: suit, rank: rank, safeWidth: safeWidth, safeHeight: safeHeight)
                centerContent(suit: suit, rank: rank, safeWidth: safeWidth, safeHeight: safeHeight)
            }
        }
    }
    
    @ViewBuilder
    private func cornerPips(suit: PlayingCardData.Suit, rank: PlayingCardData.Rank, safeWidth: CGFloat, safeHeight: CGFloat) -> some View {
        // TOP-LEFT CORNER: Rank above suit
        Text(rank.rawValue)
            .font(.system(size: safeHeight * percentages.cornerRankHeight * 0.6, weight: .bold))
            .foregroundColor(suit.color)
            .position(
                x: safeWidth * percentages.cornerPipSidePadding,
                y: safeHeight * percentages.cornerPipTopPadding + (safeHeight * percentages.cornerRankHeight * 0.3)
            )
        
        Text(suit.symbol)
            .font(.system(size: safeWidth * percentages.cornerSuitHeight * 0.8))
            .foregroundColor(suit.color)
            .position(
                x: safeWidth * percentages.cornerPipSidePadding,
                y: safeHeight * percentages.cornerSuitTopPadding
            )
        
        // BOTTOM-RIGHT CORNER: Suit above rank (rotated 180°)
        Text(suit.symbol)
            .font(.system(size: safeWidth * percentages.cornerSuitHeight * 0.8))
            .foregroundColor(suit.color)
            .rotationEffect(.degrees(180))
            .position(
                x: safeWidth * (1 - percentages.cornerPipSidePadding),
                y: safeHeight * (1 - percentages.cornerSuitBottomPadding)
            )
        
        Text(rank.rawValue)
            .font(.system(size: safeHeight * percentages.cornerRankHeight * 0.6, weight: .bold))
            .foregroundColor(suit.color)
            .rotationEffect(.degrees(180))
            .position(
                x: safeWidth * (1 - percentages.cornerPipSidePadding),
                y: safeHeight * (1 - percentages.cornerPipBottomPadding - (percentages.cornerRankHeight * 0.3))
            )
    }
    
    @ViewBuilder
    private func centerContent(suit: PlayingCardData.Suit, rank: PlayingCardData.Rank, safeWidth: CGFloat, safeHeight: CGFloat) -> some View {
        let centerWidth = validDimension(safeWidth * (1 - 2 * percentages.centerRectangleSidePadding))
        let centerHeight = validDimension(safeHeight * (1 - percentages.centerRectangleTopPadding - percentages.centerRectangleBottomPadding))
        
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
            .position(x: safeWidth * 0.5, y: safeHeight * 0.5)
    }
    
    @ViewBuilder
    private func faceCardContent(suit: PlayingCardData.Suit, rank: PlayingCardData.Rank, centerWidth: CGFloat, centerHeight: CGFloat) -> some View {
        let scaledWidth = validDimension(centerWidth * percentages.faceCardScaleFactor)
        let scaledHeight = validDimension(centerHeight * percentages.faceCardScaleFactor)
        
        let faceImageName = "\(rank == .jack ? "Jack" : rank == .queen ? "Queen" : "King")\(suit.assetName)"
        
        Image(faceImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: scaledWidth, height: scaledHeight)
    }
    
    @ViewBuilder
    private func aceContent(suit: PlayingCardData.Suit, centerWidth: CGFloat, centerHeight: CGFloat) -> some View {
        let pipSize = validDimension(min(centerWidth, centerHeight) * percentages.aceScaleFactor)
        
        Text(suit.symbol)
            .font(.system(size: pipSize))
            .foregroundColor(suit.color)
            .position(x: centerWidth * 0.5, y: centerHeight * 0.5)
    }
    
    @ViewBuilder
    private func pipContent(suit: PlayingCardData.Suit, rank: PlayingCardData.Rank, centerWidth: CGFloat, centerHeight: CGFloat) -> some View {
        // Use suit-specific pip pattern
        if let pipPattern = rank.pipPattern(for: suit) {
            let scaledWidth = validDimension(centerWidth * percentages.pipPatternScaleFactor)
            let scaledHeight = validDimension(centerHeight * percentages.pipPatternScaleFactor)
            
            Image(pipPattern)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: scaledWidth, height: scaledHeight)
                .foregroundColor(suit.color)
        } else {
            // Fallback for missing assets
            let fallbackSize = validDimension(min(centerWidth, centerHeight) * percentages.pipPatternScaleFactor * 0.4)
            
            Text(rank.rawValue)
                .font(.system(size: fallbackSize, weight: .bold))
                .foregroundColor(suit.color)
        }
    }
}
