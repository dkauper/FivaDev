//
//  DiscardOverlayView.swift
//  FivaDev
//
//  CRASH FIX: Safe Array Access + Enhanced Error Handling
//  Created by Doron Kauper on 9/21/25.
//  Updated: September 23, 2025, 5:15 PM PST
//

import SwiftUI

// MARK: - Enhanced Discard Overlay View with Crash Protection
struct DiscardOverlayView: View {
    let bodyWidth: CGFloat
    let bodyHeight: CGFloat
    let layoutConstants: GlobalLayoutConstants
    let orientation: AppOrientation
    
    @EnvironmentObject var gameStateManager: GameStateManager
    @State private var hoveredElements: Set<DiscardElementType> = []
    @State private var touchedElements: Set<DiscardElementType> = []
    @State private var configurationError: String? = nil
    
    // Get unified configuration for current device/orientation
    private var overlayConfig: DiscardOverlayConfiguration {
        DiscardOverlayConfiguration.current(
            for: DeviceType.current,
            orientation: orientation
        )
    }
    
    var body: some View {
        let position = overlayConfig.overlayPosition
        let topPadding = position.topValue(bodyHeight)
        let bottomPadding = position.bottomValue(bodyHeight)
        let leftPadding = position.leftValue(bodyWidth)
        let rightPadding = position.rightValue(bodyWidth)
        
        let overlayWidth = position.overlayWidth(bodyWidth)
        let overlayHeight = position.overlayHeight(bodyHeight)
        
        VStack(spacing: 0) {
            Spacer().frame(height: topPadding)
            
            HStack(spacing: 0) {
                Spacer().frame(width: leftPadding)
                
                // Enhanced discard overlay with crash protection
                if let error = configurationError {
                    // Error state display
                    errorStateView(error: error, width: overlayWidth, height: overlayHeight)
                } else {
                    enhancedDiscardOverlay(width: overlayWidth, height: overlayHeight)
                }
                
                Spacer().frame(width: rightPadding)
            }
            
            Spacer().frame(height: bottomPadding)
        }
        .frame(width: bodyWidth, height: bodyHeight)
    }
    
    // MARK: - Error State View
    private func errorStateView(error: String, width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.red.opacity(0.1))
                .stroke(.red.opacity(0.6), lineWidth: 2)
            
            VStack(spacing: 4) {
                Text("Configuration Error")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                
                Text(error)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(8)
        }
        .frame(width: width, height: height)
    }
    
    private func enhancedDiscardOverlay(width: CGFloat, height: CGFloat) -> some View {
        let gridPaddingValue = overlayConfig.gridPadding * min(width, height)
        let availableWidth = width - (gridPaddingValue * 2)
        let availableHeight = height - (gridPaddingValue * 2)
        
        return ZStack {
            // Background container
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .stroke(.red.opacity(0.6), lineWidth: 2)
            
            // SAFE debug grid sections with bounds checking
            if overlayConfig.gridSections > 1 {
                safeDebugGridSections(availableWidth: availableWidth, availableHeight: availableHeight)
            }
            
            // Grid elements positioned independently using unified configuration
            ForEach(sortedVisibleElements(), id: \.self) { elementType in
                if let layout = overlayConfig.elements[elementType], layout.isVisible {
                    gridElement(
                        type: elementType,
                        layout: layout,
                        availableWidth: availableWidth,
                        availableHeight: availableHeight
                    )
                }
            }
        }
        .rotationEffect(overlayConfig.gridRotation)  // Apply grid rotation here
        .frame(width: width, height: height)
        .onAppear {
            validateConfiguration()
        }
    }
    
    // MARK: - SAFE Debug Grid Sections with Bounds Protection
    private func safeDebugGridSections(availableWidth: CGFloat, availableHeight: CGFloat) -> some View {
        Group {
            switch overlayConfig.gridOrientation {
            case .vertical:
                VStack(spacing: 0) {
                    ForEach(0..<overlayConfig.gridSections, id: \.self) { sectionIndex in
                        // SAFE proportion access using the configuration's safe method
                        let proportion = overlayConfig.sectionProportion(at: sectionIndex)
                        let sectionHeight = availableHeight * proportion
                        
                        Rectangle()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: availableWidth, height: max(0, sectionHeight))
                            .overlay(
                                Text("Section \(sectionIndex + 1)")
                                    .font(.caption2)
                                    .foregroundColor(.blue.opacity(0.7))
                            )
                    }
                }
            case .horizontal:
                HStack(spacing: 0) {
                    ForEach(0..<overlayConfig.gridSections, id: \.self) { sectionIndex in
                        // SAFE proportion access using the configuration's safe method
                        let proportion = overlayConfig.sectionProportion(at: sectionIndex)
                        let sectionWidth = availableWidth * proportion
                        
                        Rectangle()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: max(0, sectionWidth), height: availableHeight)
                            .overlay(
                                Text("Section \(sectionIndex + 1)")
                                    .font(.caption2)
                                    .foregroundColor(.blue.opacity(0.7))
                                    .rotationEffect(.degrees(-90)) // Rotate text for horizontal sections
                            )
                    }
                }
            }
        }
    }
    
    private func sortedVisibleElements() -> [DiscardElementType] {
        return overlayConfig.elements
            .filter { $0.value.isVisible }
            .sorted { $0.value.priority < $1.value.priority }
            .map { $0.key }
    }
    
    private func gridElement(
        type: DiscardElementType,
        layout: DiscardElementLayout,
        availableWidth: CGFloat,
        availableHeight: CGFloat
    ) -> some View {
        let elementWidth = layout.elementWidth(availableWidth)
        let elementHeight = layout.elementHeight(availableHeight)
        let topOffset = layout.topValue(availableHeight)
        let leftOffset = layout.leftValue(availableWidth)
        
        return Group {
            switch type {
            case .mostRecentDiscard:
                discardCardElement(
                    cardName: gameStateManager.mostRecentDiscard,
                    width: elementWidth,
                    height: elementHeight,
                    layout: layout,
                    elementType: type
                )
            case .currentPlayerInfo:
                currentPlayerElement(
                    width: elementWidth,
                    height: elementHeight,
                    layout: layout
                )
            case .lastCardPlayed:
                lastCardPlayedElement(
                    cardName: gameStateManager.lastCardPlayed,
                    width: elementWidth,
                    height: elementHeight,
                    layout: layout,
                    elementType: type
                )
            case .gameScore:
                gameScoreElement(
                    width: elementWidth,
                    height: elementHeight,
                    layout: layout
                )
            case .turnTimer:
                turnTimerElement(
                    width: elementWidth,
                    height: elementHeight,
                    layout: layout
                )
            case .actionButton:
                actionButtonElement(
                    width: elementWidth,
                    height: elementHeight,
                    layout: layout
                )
            case .statusIndicator:
                statusIndicatorElement(
                    width: elementWidth,
                    height: elementHeight,
                    layout: layout
                )
            case .nextPlayer:
                nextPlayerElement(
                    width: elementWidth,
                    height: elementHeight,
                    layout: layout
                )
            }
        }
        .rotationEffect(layout.rotation)
        .position(
            x: leftOffset + elementWidth / 2,
            y: topOffset + elementHeight / 2
        )
    }
    
    // MARK: - Grid Element Components with Enhanced Vertical Text Support
    
    private func discardCardElement(
        cardName: String?,
        width: CGFloat,
        height: CGFloat,
        layout: DiscardElementLayout,
        elementType: DiscardElementType
    ) -> some View {
        let isActive = hoveredElements.contains(elementType) || touchedElements.contains(elementType)
        
        return ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.3))
                .stroke(Color.green.opacity(1), lineWidth: 2)
            
            switch layout.contentType {
            case .image(let imageName):
                if let cardName = cardName ?? imageName {
                    Image(cardName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        .padding(1)
                } else {
                    placeholderContent(label: "Discard")
                }
            case .text(let content):
                Text(content)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            case .combined(let imageName, let text):
                VStack(spacing: 2) {
                    if let cardName = cardName ?? imageName {
                        Image(cardName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .frame(maxHeight: height * 0.7)
                    }
                    Text(text)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            case .dynamic:
                if let cardName = cardName {
                    Image(cardName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        .padding(1)
                } else {
                    placeholderContent(label: "Discard")
                }
            }
        }
        .frame(width: width, height: height)
        .glassEffect()
        .scaleEffect(isActive ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .onHover { isHovering in
            if isHovering {
                hoveredElements.insert(elementType)
            } else {
                hoveredElements.remove(elementType)
            }
            
            if let cardName = cardName {
                Task { @MainActor in
                    gameStateManager.highlightCard(cardName, highlight: isHovering)
                }
            }
        }
    }
    
    // MARK: - Enhanced Current Player Element with Vertical Text Support
    private func currentPlayerElement(
        width: CGFloat,
        height: CGFloat,
        layout: DiscardElementLayout
    ) -> some View {
        
        Group {
            switch layout.contentType {
            case .text(let content):
                enhancedTextView(
                    headerText: content,
                    bodyText: gameStateManager.currentPlayerName,
                    width: width,
                    height: height,
                    textLayoutMode: layout.textLayoutMode
                )
            case .dynamic:
                enhancedTextView(
                    headerText: "Current Player",
                    bodyText: gameStateManager.currentPlayerName,
                    width: width,
                    height: height,
                    textLayoutMode: layout.textLayoutMode
                )
            case .combined(_, let text):
                enhancedTextView(
                    headerText: text,
                    bodyText: gameStateManager.currentPlayerName,
                    width: width,
                    height: height,
                    textLayoutMode: layout.textLayoutMode
                )
            case .image:
                Text(gameStateManager.currentPlayerName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .frame(width: width, height: height)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.6))
                            .stroke(Color.green.opacity(0.8), lineWidth: 2)
                    )
            }
        }
    }
    
    // MARK: - Enhanced Text View with Vertical Layout Support
    private func enhancedTextView(
        headerText: String,
        bodyText: String,
        width: CGFloat,
        height: CGFloat,
        textLayoutMode: TextLayoutMode
    ) -> some View {
        Group {
            switch textLayoutMode {
            case .standard:
                // Standard layout - works for normal horizontal text
                VStack(spacing: 2) {
                    Text(headerText)
                        .font(.system(size: 8, weight: .regular, design: .default))
                        .foregroundColor(.red)
                    
                    Text(bodyText)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(width: width, height: height)
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.6))
                        .stroke(Color.green.opacity(0.8), lineWidth: 2)
                    )
                
            case .verticalExpanded:
                // Expanded layout for vertical text (-90° rotation)
                // Pre-rotation: Provide EXTRA WIDE frame so post-rotation has enough height
                VStack(spacing: 1) {
                    Text(headerText)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    
                    Text(bodyText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(width: max(width * 2.5, 120), height: height) // MUCH WIDER frame
                .padding(.horizontal, 2)
                
            case .verticalCompact:
                // Compact layout for vertical text
                VStack(spacing: 0) {
                    Text(headerText)
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Text(bodyText)
                        .font(.system(size: 10))
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(width: max(width * 2, 80), height: height)
                .padding(.horizontal, 1)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.6))
                        .stroke(Color.purple.opacity(0.8), lineWidth: 2)
                )
                
            case .horizontalExpanded:
                // Expanded layout for 90° rotated text
                HStack(spacing: 3) {
                    Text(headerText)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Text(bodyText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(width: width, height: max(height * 2, 60))
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.6))
                        .stroke(Color.orange.opacity(0.8), lineWidth: 2)
                    )
                
            case .customFrame(let customWidth, let customHeight):
                // Custom dimensions
                VStack(spacing: 1) {
                    Text(headerText)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Text(bodyText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(width: customWidth, height: customHeight)
                .padding(.horizontal, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.6))
                        .stroke(Color.mint.opacity(0.8), lineWidth: 2)
                    )
                
            }
        }
    }
    
    private func lastCardPlayedElement(
        cardName: String?,
        width: CGFloat,
        height: CGFloat,
        layout: DiscardElementLayout,
        elementType: DiscardElementType
    ) -> some View {
        let isActive = hoveredElements.contains(elementType) || touchedElements.contains(elementType)
        
        return ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.3))
                .stroke(Color.green.opacity(1), lineWidth: 2)
            
            switch layout.contentType {
            case .image(let imageName):
                if let cardName = cardName ?? imageName {
                    Image(cardName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        .padding(1)
                } else {
                    placeholderContent(label: "Last Played")
                }
            case .text(let content):
                Text(content)
                    .font(.caption)
                    .foregroundColor(.primary)
            case .combined(let imageName, let text):
                VStack(spacing: 2) {
                    if let cardName = cardName ?? imageName {
                        Image(cardName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .frame(maxHeight: height * 0.7)
                    }
                    Text(text)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            case .dynamic:
                if let cardName = cardName {
                    Image(cardName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        .padding(1)
                } else {
                    placeholderContent(label: "Last Played")
                }
            }
        }
        .frame(width: width, height: height)
        .glassEffect()
        .scaleEffect(isActive ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .onHover { isHovering in
            if isHovering {
                hoveredElements.insert(elementType)
            } else {
                hoveredElements.remove(elementType)
            }
            
            if let cardName = cardName {
                Task { @MainActor in
                    gameStateManager.highlightCard(cardName, highlight: isHovering)
                }
            }
        }
    }
    
    private func gameScoreElement(
        width: CGFloat,
        height: CGFloat,
        layout: DiscardElementLayout
    ) -> some View {
        Group {
            switch layout.contentType {
            case .text(let content):
                VStack(spacing: 1) {
                    Text(content)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Text("2")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text("-")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("1")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }
            case .dynamic:
                VStack(spacing: 1) {
                    Text("Score")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Text("2")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text("-")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("1")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }
            case .combined(_, let text):
                VStack(spacing: 1) {
                    Text(text)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Text("2")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text("-")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("1")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }
            case .image:
                HStack(spacing: 4) {
                    Text("2")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("-")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("1")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
        }
        .frame(width: width, height: height)
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(.white)
                .stroke(.green.opacity(0.6), lineWidth: 2)
        )
    }
    
    private func turnTimerElement(
        width: CGFloat,
        height: CGFloat,
        layout: DiscardElementLayout
    ) -> some View {
        Group {
            switch layout.contentType {
            case .text(let content):
                VStack(spacing: 1) {
                    Text(content)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("0:45")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            case .dynamic:
                VStack(spacing: 1) {
                    Text("Timer")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("0:45")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            case .combined(_, let text):
                VStack(spacing: 1) {
                    Text(text)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("0:45")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            case .image:
                Text("0:45")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
        }
        .frame(width: width, height: height)
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(.white)
                .stroke(.green.opacity(0.6), lineWidth: 2)
        )
    }
    
    private func actionButtonElement(
        width: CGFloat,
        height: CGFloat,
        layout: DiscardElementLayout
    ) -> some View {
        let buttonText = switch layout.contentType {
        case .text(let content): content
        case .combined(_, let text): text
        default: "Action"
        }
        
        return Button(buttonText) {
            print("Action button tapped")
        }
        .font(.caption)
        .foregroundColor(.white)
        .frame(width: width, height: height)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(.blue)
        )
    }
    
    private func statusIndicatorElement(
        width: CGFloat,
        height: CGFloat,
        layout: DiscardElementLayout
    ) -> some View {
        Circle()
            .fill(.green)
            .frame(width: min(width, height) * 0.6)
            .frame(width: width, height: height)
            .overlay(
                Text("●")
                    .font(.caption2)
                    .foregroundColor(.white)
            )
    }
    
    // MARK: - Enhanced Next Player Element with Vertical Text Support and Stroke
        private func nextPlayerElement(
            width: CGFloat,
            height: CGFloat,
            layout: DiscardElementLayout
        ) -> some View {
            
            Group {
                switch layout.contentType {
                case .text(let content):
                    enhancedTextView(
                        headerText: content,
                        bodyText: "Player 3", // TODO: Replace with actual next player name from game state
                        width: width,
                        height: height,
                        textLayoutMode: layout.textLayoutMode
                    )
                case .dynamic:
                    enhancedTextView(
                        headerText: "Next Player",
                        bodyText: "Player 3", // TODO: Replace with actual next player name from game state
                        width: width,
                        height: height,
                        textLayoutMode: layout.textLayoutMode
                    )
                case .combined(_, let text):
                    enhancedTextView(
                        headerText: text,
                        bodyText: "Player 3", // TODO: Replace with actual next player name from game state
                        width: width,
                        height: height,
                        textLayoutMode: layout.textLayoutMode
                    )
                case .image:
                    Text("Player 3") // TODO: Replace with actual next player name from game state
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(width: width, height: height)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.6))
                                .stroke(Color.pink.opacity(0.8), lineWidth: 2)
                        )
                }
            }
        }
    // MARK: - Helper Methods
    
    private func placeholderContent(label: String) -> some View {
        VStack(spacing: 2) {
            Image(systemName: "rectangle.dashed")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.7))
            Text("No \(label)")
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
    
    private func validateConfiguration() {
        let issues = overlayConfig.validate()
        if !issues.isEmpty {
            print("⚠️ Discard Overlay Configuration Issues:")
            for issue in issues {
                print("  - \(issue)")
            }
        }
    }
}

// MARK: - Preview Support
#Preview("iPhone Portrait") {
    GeometryReader { geometry in
        let deviceType = DeviceType.iPhone
        let orientation = AppOrientation.portrait
        let layoutConstants = GlobalLayoutConstants.current(for: deviceType, orientation: orientation)
        let bodyHeight = layoutConstants.bodyHeightValue(geometry.size.height)
        let bodyWidth = layoutConstants.bodyWidthValue(geometry.size.width)
        
        DiscardOverlayView(
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
            layoutConstants: layoutConstants,
            orientation: orientation
        )
        .environmentObject(GameStateManager())
    }
    .background(Color(hex: "B7E4CC"))
}

#Preview("iPad Landscape") {
    GeometryReader { geometry in
        let deviceType = DeviceType.iPad
        let orientation = AppOrientation.landscape
        let layoutConstants = GlobalLayoutConstants.current(for: deviceType, orientation: orientation)
        let bodyHeight = layoutConstants.bodyHeightValue(geometry.size.height)
        let bodyWidth = layoutConstants.bodyWidthValue(geometry.size.width)
        
        DiscardOverlayView(
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
            layoutConstants: layoutConstants,
            orientation: orientation
        )
        .environmentObject(GameStateManager())
    }
    .background(Color(hex: "B7E4CC"))
}

#Preview("macOS Landscape") {
    GeometryReader { geometry in
        let deviceType = DeviceType.mac
        let orientation = AppOrientation.landscape
        let layoutConstants = GlobalLayoutConstants.current(for: deviceType, orientation: orientation)
        let bodyHeight = layoutConstants.bodyHeightValue(geometry.size.height)
        let bodyWidth = layoutConstants.bodyWidthValue(geometry.size.width)
        
        DiscardOverlayView(
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
            layoutConstants: layoutConstants,
            orientation: orientation
        )
        .environmentObject(GameStateManager())
    }
    .background(Color(hex: "B7E4CC"))
}
