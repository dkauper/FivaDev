//
//  ContentView.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/16/25.
//  Optimized: October 3, 2025, 4:35 PM Pacific - Removed unused geometry parameter
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameStateManager = GameStateManager()
    
    var body: some View {
        GeometryReader { geometry in
            let deviceType = DeviceType.current
            let orientation = AppOrientation.current(geometry: geometry)
            let layoutConstants = GlobalLayoutConstants.current(for: deviceType, orientation: orientation)
            
            // Calculate actual dimensions
            let headerHeight = layoutConstants.headerHeightValue(geometry.size.height)
            let bodyHeight = layoutConstants.bodyHeightValue(geometry.size.height)
            let bodyWidth = layoutConstants.bodyWidthValue(geometry.size.width)
            
            Color(hex: "B7E4CC")
//            Color(hex: "009051").opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section
                HeaderView()
                    .frame(height: headerHeight)
                // Body Section
                BodyView(
                    width: bodyWidth,
                    height: bodyHeight,
                    layoutConstants: layoutConstants,
                    orientation: orientation
                )
                .frame(width: bodyWidth, height: bodyHeight)
                .environmentObject(gameStateManager)
            }
        }
        // Force view to update on size changes using geometry dimensions instead of UIScreen.main
        .id("view-refresh")
    }
}

#Preview {
    ContentView()
}
