//
//  DiscardOverlayView.swift
//  FivaDev
//
//  Revised with grid orientation logic matching PlayerHandView
//  Created by Doron Kauper on 9/21/25.
//  Updated: September 29, 2025, 11:55 AM PDT
//

import SwiftUI

// MARK: - Discard Overlay View
struct DiscardOverlayView: View {
    let bodyWidth: CGFloat
    let bodyHeight: CGFloat
    let layoutConstants: GlobalLayoutConstants
    let orientation: AppOrientation
    
    @EnvironmentObject var gameStateManager: GameStateManager
    @State private var hoveredElements: Set<DiscardElementType> = []
    @State private var touchedElements: Set<DiscardElementType> = []
    
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
                
                discardOverlay(width: overlayWidth, height: overlayHeight)
                
                Spacer().frame(width: rightPadding)
            }
            
            Spacer().frame(height: bottomPadding)
        }
        .frame(width: bodyWidth, height: bodyHeight)
    }
    
    private func discardOverlay(width: CGFloat, height: CGFloat) -> some View {
        let gridPaddingValue = overlayConfig.gridPadding * min(width, height)
        let availableWidth = width - (gridPaddingValue * 2)
        let availableHeight = height - (gridPaddingValue * 2)
        
        return ZStack {
            // Background container
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .stroke(.red.opacity(0.6), lineWidth: 2)
            
            // Grid container with orientation logic
            elementsGrid(
                availableWidth: availableWidth,
                availableHeight: availableHeight
            )
            .padding(gridPaddingValue)
        }
        .frame(width: width, height: height)
        .onAppear {
            validateConfiguration()
        }
    }
    
    private func elementsGrid(availableWidth: CGFloat, availableHeight: CGFloat) -> some View {
        let elements = sortedVisibleElements()
        let elementCount = CGFloat(elements.count)
        let spacing: CGFloat = min(availableWidth, availableHeight) * 0.02 // 2% spacing
        
        // Determine layout direction based on overlay dimensions
        // When width > height: horizontal layout (elements in a row)
        // When height > width: vertical layout (elements in a column)
        let useHorizontalLayout = availableWidth > availableHeight
        
        if useHorizontalLayout {
            // HORIZONTAL LAYOUT: Elements flow left to right
            let totalSpacing = spacing * (elementCount - 1)
            let availableElementWidth = availableWidth - totalSpacing
            let availableElementHeight = availableHeight
            
            let elementWidth = availableElementWidth / elementCount
            let elementHeight = availableElementHeight
            
            return AnyView(
                HStack(spacing: spacing) {
                    ForEach(elements, id: \.self) { elementType in
                        if let layout = overlayConfig.elements[elementType] {
                            elementView(
                                type: elementType,
                                layout: layout,
                                width: elementWidth,
                                height: elementHeight
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        } else {
            // VERTICAL LAYOUT: Elements stack top to bottom
            let totalSpacing = spacing * (elementCount - 1)
            let availableElementHeight = availableHeight - totalSpacing
            let availableElementWidth = availableWidth
            
            let elementHeight = availableElementHeight / elementCount
            let elementWidth = availableElementWidth
            
            return AnyView(
                VStack(spacing: spacing) {
                    ForEach(elements, id: \.self) { elementType in
                        if let layout = overlayConfig.elements[elementType] {
                            elementView(
                                type: elementType,
                                layout: layout,
                                width: elementWidth,
                                height: elementHeight
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        }
    }
    
    private func sortedVisibleElements() -> [DiscardElementType] {
        return overlayConfig.elements
            .filter { $0.value.isVisible }
            .sorted { $0.value.priority < $1.value.priority }
            .map { $0.key }
    }
    
    private func elementView(
        type: DiscardElementType,
        layout: DiscardElementLayout,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        Group {
            switch type {
            case .lastDiscard:
                discardCardElement(
                    cardName: gameStateManager.mostRecentDiscard,
                    width: width,
                    height: height,
                    layout: layout,
                    elementType: type
                )
            case .lastPlayer:
                sfSymbolElement(
                    elementType: type,
                    width: width,
                    height: height,
                    layout: layout
                )
            case .nextPlayer:
                sfSymbolElement(
                    elementType: type,
                    width: width,
                    height: height,
                    layout: layout
                )
            case .score:
                sfSymbolElement(
                    elementType: type,
                    width: width,
                    height: height,
                    layout: layout
                )
            case .timer:
                sfSymbolElement(
                    elementType: type,
                    width: width,
                    height: height,
                    layout: layout
                )
            }
        }
    }
    
    // MARK: - Discard Card Element
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
    
    // MARK: - SF Symbol Element with Palette Rendering
    private func sfSymbolElement(
        elementType: DiscardElementType,
        width: CGFloat,
        height: CGFloat,
        layout: DiscardElementLayout
    ) -> some View {
        let isActive = hoveredElements.contains(elementType) || touchedElements.contains(elementType)
        
        return ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.1))
                .stroke(Color.green.opacity(0.8), lineWidth: 2)
            
            // Render SF Symbol based on content type
            if case .sfSymbol(let symbolName, let rendering) = layout.contentType {
                switch rendering {
                case .palette(let primary, let secondary, let tertiary):
                    Image(systemName: symbolName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(primary, secondary, tertiary ?? .clear)
                        .padding(width * 0.15)
                        
                case .monochrome(let color):
                    Image(systemName: symbolName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(color)
                        .padding(width * 0.15)
                }
            } else {
                // Fallback for non-SF symbol content
                Text(elementType.displayName)
                    .font(.caption2)
                    .foregroundColor(.primary)
            }
        }
        .frame(width: width, height: height)
        .glassEffect()
        .scaleEffect(isActive ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .help(elementType.tooltip) // Tooltip for macOS
        .onHover { isHovering in
            if isHovering {
                hoveredElements.insert(elementType)
            } else {
                hoveredElements.remove(elementType)
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
