// PaddingFormulae.swift
// FivaDev
//
// Created: October 10, 2025, 7:00 PM Pacific
// Padding calculation functions for PlayerHandLayoutConstants

import Foundation

/// Returns computed left and right padding for iPhone Portrait orientation
/// - Parameters:
///   - bodyHeight: Total available body height
///   - bodyWidth: Total available body width
///   - topPadding: Manually defined top padding (as percentage)
///   - bottomPadding: Manually defined bottom padding (as percentage)
///   - cardsPerPlayer: Number of cards in player hand
/// - Returns: Computed padding value (as percentage)
func returnLeftAndRight(
    bodyHeight: CGFloat,
    bodyWidth: CGFloat,
    topPadding: CGFloat,
    bottomPadding: CGFloat,
    cardsPerPlayer: CGFloat
) -> CGFloat {
    let cardRatio: CGFloat = 1.25
    
    // Determine available height after removing top/bottom padding
    let availableHeight = bodyHeight - (bodyHeight * (topPadding + bottomPadding))
    
    // Width of card based on available height
    let cardWidth = availableHeight * cardRatio
    
    // Total width of overlay (all cards side by side)
    let overlayWidth = cardWidth * cardsPerPlayer
    
    // Calculate padding
    let dif = bodyWidth - overlayWidth
    var results = (dif / bodyWidth) / 2
    
    // Ensure minimum padding
    if results < 0 {
        results = 0.02
    }
    
    return results
}

/// Returns computed top and bottom padding for all non-iPhone-Portrait orientations
/// - Parameters:
///   - bodyHeight: Total available body height
///   - bodyWidth: Total available body width
///   - leftPadding: Manually defined left padding (as percentage)
///   - rightPadding: Manually defined right padding (as percentage)
///   - cardsPerPlayer: Number of cards in player hand
/// - Returns: Computed padding value (as percentage)
func returnTopAndBottom(
    bodyHeight: CGFloat,
    bodyWidth: CGFloat,
    leftPadding: CGFloat,
    rightPadding: CGFloat,
    cardsPerPlayer: CGFloat
) -> CGFloat {
    let cardRatio: CGFloat = 1.5
    
    // Determine available width after removing left/right padding
    let availableWidth = bodyWidth - (bodyWidth * (leftPadding + rightPadding))
    
    // Height of card based on available width
    let cardHeight = availableWidth * cardRatio
    
    // Total height of overlay (all cards stacked)
    let overlayHeight = cardHeight * cardsPerPlayer
    
    // Calculate padding
    let dif = bodyHeight - overlayHeight
    var results = (dif / bodyHeight) / 2
    
    // Ensure minimum padding
    if results < 0 {
        results = 0.02
    }
    
    return results
}
