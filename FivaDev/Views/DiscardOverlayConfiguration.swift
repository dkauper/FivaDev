//
//  DiscardOverlayConfiguration.swift
//  FivaDev
//
//  CRASH FIX: Array Bounds Protection + Complete Struct Definitions
//  Created by Doron Kauper on 9/22/25.
//  Updated: September 23, 2025, 5:10 PM PST
//

import SwiftUI

// MARK: - Discard Grid Element Types
enum DiscardElementType: String, CaseIterable {
    case mostRecentDiscard = "mostRecentDiscard"
    case currentPlayerInfo = "currentPlayerInfo"
    case lastCardPlayed = "lastCardPlayed"
    case gameScore = "gameScore"
    case turnTimer = "turnTimer"
    case actionButton = "actionButton"
    case statusIndicator = "statusIndicator"
    case nextPlayer = "nextPlayer"
    
    var displayName: String {
        switch self {
        case .mostRecentDiscard: return "Discard"
        case .currentPlayerInfo: return "Current Player"
        case .lastCardPlayed: return "Last Played"
        case .gameScore: return "Score"
        case .turnTimer: return "Timer"
        case .actionButton: return "Action"
        case .statusIndicator: return "Status"
        case .nextPlayer: return "Next Player"
        }
    }
}

// MARK: - Text Layout Mode for Rotated Text
enum TextLayoutMode {
    case standard                    // Normal text layout
    case verticalExpanded           // Expanded frame for vertical text (-90° rotation)
    case verticalCompact            // Compact frame for vertical text (-90° rotation)
    case horizontalExpanded         // Expanded frame for horizontal text (90° rotation)
    case customFrame(width: CGFloat, height: CGFloat)  // Custom frame dimensions
}

// MARK: - Enhanced Element Content Type
enum ElementContentType {
    case image(imageName: String? = nil)
    case text(content: String)
    case combined(imageName: String?, text: String)
    case dynamic // Content determined at runtime
}

// MARK: - Grid Element Layout with Rotation Support - COMPLETE VERSION
struct DiscardElementLayout {
    // Position as percentages of the overlay area (not body area)
    let topPadding: CGFloat      // % from top of overlay area
    let bottomPadding: CGFloat   // % from bottom of overlay area
    let leftPadding: CGFloat     // % from left of overlay area
    let rightPadding: CGFloat    // % from right of overlay area
    
    // Visual properties
    let isVisible: Bool          // Whether this element should be shown
    let priority: Int            // Drawing order (higher = on top)
    let rotation: Angle          // Rotation angle for the element
    
    // Content type and layout mode
    let contentType: ElementContentType
    let textLayoutMode: TextLayoutMode
    
    // MARK: - Safe computed properties with bounds checking
    func topValue(_ overlayHeight: CGFloat) -> CGFloat {
        return max(0, min(topPadding * overlayHeight, overlayHeight))
    }
    
    func bottomValue(_ overlayHeight: CGFloat) -> CGFloat {
        return max(0, min(bottomPadding * overlayHeight, overlayHeight))
    }
    
    func leftValue(_ overlayWidth: CGFloat) -> CGFloat {
        return max(0, min(leftPadding * overlayWidth, overlayWidth))
    }
    
    func rightValue(_ overlayWidth: CGFloat) -> CGFloat {
        return max(0, min(rightPadding * overlayWidth, overlayWidth))
    }
    
    func elementWidth(_ overlayWidth: CGFloat) -> CGFloat {
        let left = leftValue(overlayWidth)
        let right = rightValue(overlayWidth)
        return max(0, overlayWidth - left - right)
    }
    
    func elementHeight(_ overlayHeight: CGFloat) -> CGFloat {
        let top = topValue(overlayHeight)
        let bottom = bottomValue(overlayHeight)
        return max(0, overlayHeight - top - bottom)
    }
}

// MARK: - Grid Orientation
enum GridOrientation {
    case vertical   // Sections stack vertically (top to bottom)
    case horizontal // Sections stack horizontally (left to right)
}

// MARK: - Unified Discard Overlay Configuration with CRASH PROTECTION
struct DiscardOverlayConfiguration {
    // MARK: - Overlay Positioning (relative to body area)
    let overlayPosition: OverlayPosition
    
    // MARK: - Grid Configuration
    let gridSections: Int                                        // Number of grid sections
    let gridOrientation: GridOrientation                         // Direction sections flow
    let gridRotation: Angle                                      // Rotation of entire grid container
    private let _sectionProportions: [CGFloat]                  // Size of each section (must sum to 1.0)
    let gridPadding: CGFloat                                    // Padding within overlay (0 = no padding)
    let elements: [DiscardElementType: DiscardElementLayout]    // Individual element configurations
    
    // MARK: - SAFE array access with bounds protection
    var sectionProportions: [CGFloat] {
        // Ensure array has exact number of elements needed
        let needed = max(1, gridSections)
        
        if _sectionProportions.count == needed {
            return _sectionProportions
        } else if _sectionProportions.count > needed {
            // Truncate if too many
            return Array(_sectionProportions.prefix(needed))
        } else {
            // Pad if too few
            var padded = _sectionProportions
            let remaining = needed - padded.count
            let fillValue = remaining > 0 ? (1.0 - padded.reduce(0, +)) / CGFloat(remaining) : 0.0
            
            for _ in 0..<remaining {
                padded.append(max(0.1, fillValue)) // Minimum 10% per section
            }
            
            // Normalize to sum to 1.0
            let sum = padded.reduce(0, +)
            if sum > 0 {
                return padded.map { $0 / sum }
            } else {
                return Array(repeating: 1.0 / CGFloat(needed), count: needed)
            }
        }
    }
    
    // MARK: - Safe section proportion access
    func sectionProportion(at index: Int) -> CGFloat {
        let props = sectionProportions
        if index >= 0 && index < props.count {
            return props[index]
        } else {
            // Fallback to equal distribution
            return 1.0 / CGFloat(max(1, gridSections))
        }
    }
    
    // MARK: - Custom initializer with validation
    init(
        overlayPosition: OverlayPosition,
        gridSections: Int,
        gridOrientation: GridOrientation,
        gridRotation: Angle,
        sectionProportions: [CGFloat],
        gridPadding: CGFloat,
        elements: [DiscardElementType: DiscardElementLayout]
    ) {
        self.overlayPosition = overlayPosition
        self.gridSections = max(1, gridSections) // Ensure at least 1 section
        self.gridOrientation = gridOrientation
        self.gridRotation = gridRotation
        self._sectionProportions = sectionProportions
        self.gridPadding = max(0, min(gridPadding, 0.5)) // Clamp between 0-50%
        self.elements = elements
    }
    
    // MARK: - Validation
    var isValid: Bool {
        let props = sectionProportions
        let sum = props.reduce(0, +)
        return abs(sum - 1.0) < 0.001 &&
               props.count == gridSections &&
               gridSections > 0 &&
               props.allSatisfy { $0 >= 0 }
    }
    
    // MARK: - Device-Specific Configurations
    static func current(for deviceType: DeviceType, orientation: AppOrientation) -> DiscardOverlayConfiguration {
        switch (deviceType, orientation) {
        case (.iPhone, .portrait):
            return iPhonePortraitConfiguration()
        case (.iPhone, .landscape):
            return iPhoneLandscapeConfiguration()
        case (.iPad, .portrait):
            return iPadPortraitConfiguration()
        case (.iPad, .landscape):
            return iPadLandscapeConfiguration()
        case (.mac, .landscape):
            return macOSLandscapeConfiguration()
        case (.appleTV, .landscape):
            return appleTVLandscapeConfiguration()
        default:
            return iPhonePortraitConfiguration()
        }
    }

    // MARK: - iPhone Portrait Configuration
    private static func iPhonePortraitConfiguration() -> DiscardOverlayConfiguration {
        return DiscardOverlayConfiguration(
            overlayPosition: OverlayPosition(
                topPadding: 0.016,      // 2% padding from top of BodyView
                bottomPadding: 0.89,   // 91% padding from bottom of BodyView
                leftPadding: 0.02,     // 2% padding from left side of BodyView
                rightPadding: 0.02     // 2% padding from right side of BodyView
            ),
            gridSections: 6,
            gridOrientation: .horizontal,  // Sections flow left to right
            gridRotation: .degrees(0),     // No rotation - sections naturally horizontal
            sectionProportions: [0.15, 0.15, 0.2, 0.2, 0.15, 0.15],  // Left section 25%, middle section 50%,  right section 25%
            gridPadding: 0.0,  // No internal padding
            elements: [
                .mostRecentDiscard: DiscardElementLayout(
                    topPadding: 0.06,       // 10% from top of overlay
                    bottomPadding: 0.065,    // 10% from bottom of overlay
                    leftPadding: 0.02,     // 5% from left of overlay
                    rightPadding: 0.87,    // 75% from right of overlay (left section)
                    isVisible: true,
                    priority: 1,
                    rotation: .degrees(0),
                    contentType: .image(),
                    textLayoutMode: .standard
                ),
                .gameScore: DiscardElementLayout(
                    topPadding: 0.08,      // 35% from top of overlay (second section)
                    bottomPadding: 0.08,    // 50% from bottom of overlay
                    leftPadding: 0.172,     // 5% from left of overlay
                    rightPadding: 0.72,    // 5% from right of overlay
                    isVisible: true,
                    priority: 3,
                    rotation: .degrees(0),
                    contentType: .text(content: "Score"),
                    textLayoutMode: .standard
                ),
                .currentPlayerInfo: DiscardElementLayout(
                    topPadding: 0.06,       // 10% from top of overlay
                    bottomPadding: 0.065,    // 10% from bottom of overlay
                    leftPadding: 0.32,     // 35% from left of overlay (right section)
                    rightPadding: 0.52,    // 5% from right of overlay
                    isVisible: true,
                    priority: 3,
                    rotation: .degrees(0),
                    contentType: .text(content: "Current Player"),
                    textLayoutMode: .standard
                ),
                .nextPlayer: DiscardElementLayout(
                    topPadding: 0.06,      // 45% from top of overlay (middle section)
                    bottomPadding: 0.065,   // 35% from bottom of overlay
                    leftPadding: 0.52,     // 55% from left of overlay
                    rightPadding: 0.315,    // 5% from right of overlay
                    isVisible: true,
                    priority: 4,
                    rotation: .degrees(0),
                    contentType: .text(content: "Next Player"),
                    textLayoutMode: .standard
                ),
                .turnTimer: DiscardElementLayout(
                    topPadding: 0.08,       // 80% from top of overlay (fourth section)
                    bottomPadding: 0.08,   // 5% from bottom of overlay
                    leftPadding: 0.72,     // 5% from left of overlay
                    rightPadding: 0.17,    // 5% from right of overlay
                    isVisible: true,
                    priority: 5,
                    rotation: .degrees(0),
                    contentType: .text(content: "Timer"),
                    textLayoutMode: .standard
                ),
                .lastCardPlayed: DiscardElementLayout(
                    topPadding: 0.06,      // 45% from top of overlay (middle section)
                    bottomPadding: 0.065,   // 35% from bottom of overlay
                    leftPadding: 0.87,      // 10% from left of overlay
                    rightPadding: 0.02,     // 10% from right of overlay
                    isVisible: true,
                    priority: 6,
                    rotation: .degrees(0),
                    contentType: .image(),
                    textLayoutMode: .standard
                )
            ]
        )
    }
    
    // MARK: - iPhone Landscape Configuration - FIXED FOR VERTICAL TEXT
    private static func iPhoneLandscapeConfiguration() -> DiscardOverlayConfiguration {
        return DiscardOverlayConfiguration(
            overlayPosition: OverlayPosition(
                topPadding: 0.05,      // 5% padding from top of BodyView
                bottomPadding: 0.022,    // 0% padding from bottom of BodyView
                leftPadding: 0.06,     // 5% padding from left side of BodyView
                rightPadding: 0.80     // 80% padding from right side of BodyView (WIDER FOR TEXT)
            ),
            gridSections: 3,
            gridOrientation: .vertical,    // Sections flow top to bottom
            gridRotation: .degrees(0),    // No grid rotation
            sectionProportions: [0.25, 0.5, 0.25],  // Top 25%, middle 50%, bottom 25%
            gridPadding: 0.02,  // 2% internal padding
            elements: [
                .lastCardPlayed: DiscardElementLayout(
                    topPadding: 0.045,      // 4.5% from top of overlay (middle section)
                    bottomPadding: 0.78,   // 78% from bottom of overlay
                    leftPadding: 0.13,      // 13% from left of overlay
                    rightPadding: 0.1,     // 10% from right of overlay
                    isVisible: false,
                    priority: 1,
                    rotation: .degrees(0),
                    contentType: .image(),
                    textLayoutMode: .standard
                ),
                .currentPlayerInfo: DiscardElementLayout(
                    topPadding: 0.0,      // 0% from top of overlay (full middle section)
                    bottomPadding: 0.0,   // 0% from bottom of overlay (full height)
                    leftPadding: 0.02,    // 2% from left of overlay (MORE ROOM)
                    rightPadding: 0.02,   // 2% from right of overlay (MORE ROOM)
                    isVisible: true,
                    priority: 2,
                    rotation: .degrees(-90),
                    contentType: .text(content: "Current Player"),
                    textLayoutMode: .verticalExpanded  // EXPANDED LAYOUT FOR VERTICAL TEXT
                ),
                .mostRecentDiscard: DiscardElementLayout(
                    topPadding: 0.78,      // 78% from top of overlay
                    bottomPadding: 0.045,   // 4.5% from bottom of overlay (bottom section)
                    leftPadding: 0.13,      // 13% from left of overlay
                    rightPadding: 0.1,     // 10% from right of overlay
                    isVisible: false,
                    priority: 3,
                    rotation: .degrees(0),
                    contentType: .image(),
                    textLayoutMode: .standard
                )
            ]
        )
    }
    
    // MARK: - iPad Portrait Configuration
    private static func iPadPortraitConfiguration() -> DiscardOverlayConfiguration {
        return DiscardOverlayConfiguration(
            overlayPosition: OverlayPosition(
                topPadding: 0.1,       // 10% padding from top of BodyView
                bottomPadding: 0.1,    // 10% padding from bottom of BodyView
                leftPadding: 0.03,      // 50% padding from left side of BodyView
                rightPadding: 0.87     // 87% padding from right side of BodyView
            ),
            gridSections: 6,
            gridOrientation: .vertical,    // Sections flow top to bottom
            gridRotation: .degrees(0),     // No rotation - keep vertical
            sectionProportions: [0.15, 0.15, 0.2, 0.2, 0.15, 0.15],  // Alternating sections
            gridPadding: 0.05,  // 5% internal padding
            elements: [
                .mostRecentDiscard: DiscardElementLayout(
                    topPadding: 0.03,      // 5% from top of overlay (first section)
                    bottomPadding: 0.83,   // 75% from bottom of overlay
                    leftPadding: 0.075,      // 10% from left of overlay
                    rightPadding: 0.0,     // 10% from right of overlay
                    isVisible: true,
                    priority: 1,
                    rotation: .degrees(0),
                    contentType: .image(),
                    textLayoutMode: .standard
                ),
                .gameScore: DiscardElementLayout(
                    topPadding: 0.24,      // 35% from top of overlay (second section)
                    bottomPadding: 0.63,    // 50% from bottom of overlay
                    leftPadding: 0.1,     // 5% from left of overlay
                    rightPadding: 0.0,    // 5% from right of overlay
                    isVisible: true,
                    priority: 3,
                    rotation: .degrees(0),
                    contentType: .text(content: "Score"),
                    textLayoutMode: .standard
                ),
                .currentPlayerInfo: DiscardElementLayout(
                    topPadding: 0.28,      // 28% from top of overlay (third section - BETTER CENTERING)
                    bottomPadding: 0.08,   // 8% from bottom of overlay (MORE HEIGHT)
                    leftPadding: 0.0,     // 0% from left of overlay (FULL WIDTH)
                    rightPadding: 0.0,    // 0% from right of overlay (FULL WIDTH)
                    isVisible: true,
                    priority: 2,
                    rotation: .degrees(-90),
                    contentType: .text(content: "Current Player"),
                    textLayoutMode: .verticalExpanded  // EXPANDED LAYOUT
                ),
                .turnTimer: DiscardElementLayout(
                    topPadding: 0.8,       // 80% from top of overlay (fourth section)
                    bottomPadding: 0.05,   // 5% from bottom of overlay
                    leftPadding: 0.05,     // 5% from left of overlay
                    rightPadding: 0.05,    // 5% from right of overlay
                    isVisible: true,
                    priority: 4,
                    rotation: .degrees(0),
                    contentType: .text(content: "Timer"),
                    textLayoutMode: .standard
                )
            ]
        )
    }
    
    // MARK: - iPad Landscape Configuration
    private static func iPadLandscapeConfiguration() -> DiscardOverlayConfiguration {
        return DiscardOverlayConfiguration(
            overlayPosition: OverlayPosition(
                topPadding: 0.07,      // 7% padding from top of BodyView
                bottomPadding: 0.07,   // 7% padding from bottom of BodyView
                leftPadding: 0.01,     // 1% padding from left side of BodyView
                rightPadding: 0.92     // 92% padding from right side of BodyView
            ),
            gridSections: 3,
            gridOrientation: .vertical,    // Sections flow top to bottom
            gridRotation: .degrees(0),     // No rotation - keep vertical
            sectionProportions: [0.4, 0.35, 0.25],  // Top 40%, middle 35%, bottom 25%
            gridPadding: 0.03,  // 3% internal padding
            elements: [
                .mostRecentDiscard: DiscardElementLayout(
                    topPadding: 0.05,      // 5% from top of overlay (top section)
                    bottomPadding: 0.65,   // 65% from bottom of overlay
                    leftPadding: 0.05,     // 5% from left of overlay
                    rightPadding: 0.5,     // 50% from right of overlay (left half)
                    isVisible: true,
                    priority: 1,
                    rotation: .degrees(0),
                    contentType: .image(),
                    textLayoutMode: .standard
                ),
                .gameScore: DiscardElementLayout(
                    topPadding: 0.05,      // 5% from top of overlay (top section)
                    bottomPadding: 0.65,   // 65% from bottom of overlay
                    leftPadding: 0.55,     // 55% from left of overlay (right half)
                    rightPadding: 0.05,    // 5% from right of overlay
                    isVisible: true,
                    priority: 3,
                    rotation: .degrees(0),
                    contentType: .text(content: "Score"),
                    textLayoutMode: .standard
                ),
                .lastCardPlayed: DiscardElementLayout(
                    topPadding: 0.45,      // 45% from top of overlay (middle section)
                    bottomPadding: 0.35,   // 35% from bottom of overlay
                    leftPadding: 0.05,     // 5% from left of overlay
                    rightPadding: 0.5,     // 50% from right of overlay
                    isVisible: true,
                    priority: 1,
                    rotation: .degrees(0),
                    contentType: .image(),
                    textLayoutMode: .standard
                ),
                .nextPlayer: DiscardElementLayout(
                    topPadding: 0.45,      // 45% from top of overlay (middle section)
                    bottomPadding: 0.35,   // 35% from bottom of overlay
                    leftPadding: 0.55,     // 55% from left of overlay
                    rightPadding: 0.05,    // 5% from right of overlay
                    isVisible: true,
                    priority: 4,
                    rotation: .degrees(0),
                    contentType: .text(content: "Next Player"),
                    textLayoutMode: .standard
                ),
                .currentPlayerInfo: DiscardElementLayout(
                    topPadding: 0.8,       // 80% from top of overlay (bottom section)
                    bottomPadding: 0.05,   // 5% from bottom of overlay
                    leftPadding: 0.05,     // 5% from left of overlay
                    rightPadding: 0.05,    // 5% from right of overlay (full width)
                    isVisible: true,
                    priority: 2,
                    rotation: .degrees(0),
                    contentType: .text(content: "Current Player"),
                    textLayoutMode: .standard
                )
            ]
        )
    }
    
    // MARK: - macOS Landscape Configuration
    private static func macOSLandscapeConfiguration() -> DiscardOverlayConfiguration {
        return DiscardOverlayConfiguration(
            overlayPosition: OverlayPosition(
                topPadding: 0.06,      // 6% padding from top of BodyView
                bottomPadding: 0.06,   // 6% padding from bottom of BodyView
                leftPadding: 0.02,     // 2% padding from left side of BodyView
                rightPadding: 0.915    // 91.5% padding from right side of BodyView
            ),
            gridSections: 3,
            gridOrientation: .vertical,    // Sections flow top to bottom
            gridRotation: .degrees(0),     // No rotation - keep vertical
            sectionProportions: [0.25, 0.5, 0.25],  // Top 25%, middle 50%, bottom 25%
            gridPadding: 0.05,  // 5% internal padding
            elements: [
                .mostRecentDiscard: DiscardElementLayout(
                    topPadding: 0.05,      // 5% from top of overlay
                    bottomPadding: 0.6,    // 60% from bottom of overlay
                    leftPadding: 0.05,     // 5% from left of overlay (left section)
                    rightPadding: 0.8,     // 80% from right of overlay
                    isVisible: true,
                    priority: 1,
                    rotation: .degrees(0),
                    contentType: .image(),
                    textLayoutMode: .standard
                ),
                .gameScore: DiscardElementLayout(
                    topPadding: 0.05,      // 5% from top of overlay
                    bottomPadding: 0.7,    // 70% from bottom of overlay
                    leftPadding: 0.3,      // 30% from left of overlay (center section)
                    rightPadding: 0.45,    // 45% from right of overlay
                    isVisible: true,
                    priority: 3,
                    rotation: .degrees(0),
                    contentType: .text(content: "Score"),
                    textLayoutMode: .standard
                ),
                .turnTimer: DiscardElementLayout(
                    topPadding: 0.05,      // 5% from top of overlay
                    bottomPadding: 0.7,    // 70% from bottom of overlay
                    leftPadding: 0.8,      // 80% from left of overlay (right section)
                    rightPadding: 0.05,    // 5% from right of overlay
                    isVisible: true,
                    priority: 4,
                    rotation: .degrees(0),
                    contentType: .text(content: "Timer"),
                    textLayoutMode: .standard
                ),
                .lastCardPlayed: DiscardElementLayout(
                    topPadding: 0.4,       // 40% from top of overlay
                    bottomPadding: 0.35,   // 35% from bottom of overlay
                    leftPadding: 0.05,     // 5% from left of overlay
                    rightPadding: 0.8,     // 80% from right of overlay
                    isVisible: true,
                    priority: 1,
                    rotation: .degrees(0),
                    contentType: .image(),
                    textLayoutMode: .standard
                ),
                .actionButton: DiscardElementLayout(
                    topPadding: 0.3,       // 30% from top of overlay
                    bottomPadding: 0.5,    // 50% from bottom of overlay
                    leftPadding: 0.3,      // 30% from left of overlay
                    rightPadding: 0.45,    // 45% from right of overlay
                    isVisible: false,      // Hidden by default
                    priority: 5,
                    rotation: .degrees(0),
                    contentType: .text(content: "Action"),
                    textLayoutMode: .standard
                ),
                .currentPlayerInfo: DiscardElementLayout(
                    topPadding: 0.75,      // 75% from top of overlay
                    bottomPadding: 0.05,   // 5% from bottom of overlay
                    leftPadding: 0.05,     // 5% from left of overlay
                    rightPadding: 0.05,    // 5% from right of overlay
                    isVisible: true,
                    priority: 2,
                    rotation: .degrees(0),
                    contentType: .text(content: "Current Player"),
                    textLayoutMode: .standard
                )
            ]
        )
    }
    
    // MARK: - Apple TV Landscape Configuration
    private static func appleTVLandscapeConfiguration() -> DiscardOverlayConfiguration {
        return DiscardOverlayConfiguration(
            overlayPosition: OverlayPosition(
                topPadding: 0.08,      // 8% padding from top of BodyView
                bottomPadding: 0.0,    // 0% padding from bottom of BodyView
                leftPadding: 0.02,     // 2% padding from left side of BodyView
                rightPadding: 0.9      // 90% padding from right side of BodyView
            ),
            gridSections: 2,
            gridOrientation: .vertical,    // Sections flow top to bottom
            gridRotation: .degrees(0),     // No rotation - keep vertical
            sectionProportions: [0.6, 0.4],  // Top 60%, bottom 40%
            gridPadding: 0.08,  // 8% internal padding for TV readability
            elements: [
                .mostRecentDiscard: DiscardElementLayout(
                    topPadding: 0.1,       // 10% from top of overlay (top section)
                    bottomPadding: 0.5,    // 50% from bottom of overlay
                    leftPadding: 0.1,      // 10% from left of overlay
                    rightPadding: 0.5,     // 50% from right of overlay (left half)
                    isVisible: true,
                    priority: 1,
                    rotation: .degrees(0),
                    contentType: .image(),
                    textLayoutMode: .standard
                ),
                .gameScore: DiscardElementLayout(
                    topPadding: 0.1,       // 10% from top of overlay
                    bottomPadding: 0.6,    // 60% from bottom of overlay
                    leftPadding: 0.6,      // 60% from left of overlay (right half)
                    rightPadding: 0.1,     // 10% from right of overlay
                    isVisible: true,
                    priority: 3,
                    rotation: .degrees(0),
                    contentType: .text(content: "Score"),
                    textLayoutMode: .standard
                ),
                .lastCardPlayed: DiscardElementLayout(
                    topPadding: 0.5,       // 50% from top of overlay (middle)
                    bottomPadding: 0.25,   // 25% from bottom of overlay
                    leftPadding: 0.1,      // 10% from left of overlay
                    rightPadding: 0.5,     // 50% from right of overlay
                    isVisible: true,
                    priority: 1,
                    rotation: .degrees(0),
                    contentType: .image(),
                    textLayoutMode: .standard
                ),
                .currentPlayerInfo: DiscardElementLayout(
                    topPadding: 0.7,       // 70% from top of overlay (bottom section)
                    bottomPadding: 0.1,    // 10% from bottom of overlay
                    leftPadding: 0.1,      // 10% from left of overlay
                    rightPadding: 0.1,     // 10% from right of overlay
                    isVisible: true,
                    priority: 2,
                    rotation: .degrees(0),
                    contentType: .text(content: "Current Player"),
                    textLayoutMode: .standard
                )
            ]
        )
    }
}

// MARK: - Overlay Position Structure
struct OverlayPosition {
    let topPadding: CGFloat      // % from top of body area
    let bottomPadding: CGFloat   // % from bottom of body area
    let leftPadding: CGFloat     // % from left of body area
    let rightPadding: CGFloat    // % from right of body area
    
    // Computed properties for actual values
    func topValue(_ bodyHeight: CGFloat) -> CGFloat {
        return topPadding * bodyHeight
    }
    
    func bottomValue(_ bodyHeight: CGFloat) -> CGFloat {
        return bottomPadding * bodyHeight
    }
    
    func leftValue(_ bodyWidth: CGFloat) -> CGFloat {
        return leftPadding * bodyWidth
    }
    
    func rightValue(_ bodyWidth: CGFloat) -> CGFloat {
        return rightPadding * bodyWidth
    }
    
    func overlayWidth(_ bodyWidth: CGFloat) -> CGFloat {
        return bodyWidth - leftValue(bodyWidth) - rightValue(bodyWidth)
    }
    
    func overlayHeight(_ bodyHeight: CGFloat) -> CGFloat {
        return bodyHeight - topValue(bodyHeight) - bottomValue(bodyHeight)
    }
}

// MARK: - Enhanced Configuration Validation with Crash Protection
extension DiscardOverlayConfiguration {
    func validate() -> [String] {
        var issues: [String] = []
        
        if !isValid {
            issues.append("Section proportions don't sum to 1.0 or count mismatch")
        }
        
        if gridSections <= 0 {
            issues.append("Grid sections must be greater than 0")
        }
        
        if gridPadding < 0 || gridPadding > 0.5 {
            issues.append("Grid padding should be between 0 and 0.5")
        }
        
        // Enhanced element layout validation
        for (elementType, layout) in elements {
            if layout.topPadding + layout.bottomPadding > 1.0 {
                issues.append("\(elementType.displayName): top + bottom padding exceeds 100%")
            }
            
            if layout.leftPadding + layout.rightPadding > 1.0 {
                issues.append("\(elementType.displayName): left + right padding exceeds 100%")
            }
            
            if layout.priority < 0 {
                issues.append("\(elementType.displayName): priority must be non-negative")
            }
            
            // Validate padding ranges
            if layout.topPadding < 0 || layout.topPadding > 1 {
                issues.append("\(elementType.displayName): topPadding must be 0-1")
            }
            if layout.bottomPadding < 0 || layout.bottomPadding > 1 {
                issues.append("\(elementType.displayName): bottomPadding must be 0-1")
            }
            if layout.leftPadding < 0 || layout.leftPadding > 1 {
                issues.append("\(elementType.displayName): leftPadding must be 0-1")
            }
            if layout.rightPadding < 0 || layout.rightPadding > 1 {
                issues.append("\(elementType.displayName): rightPadding must be 0-1")
            }
        }
        
        return issues
    }
    
    // Safe debug information
    func debugInfo() -> String {
        let validation = validate()
        return """
        DiscardOverlayConfiguration Debug:
        - Grid Sections: \(gridSections)
        - Section Proportions: \(sectionProportions) (count: \(sectionProportions.count))
        - Sum: \(sectionProportions.reduce(0, +))
        - Elements: \(elements.count)
        - Valid: \(isValid)
        - Issues: \(validation.isEmpty ? "None" : validation.joined(separator: ", "))
        """
    }
}
