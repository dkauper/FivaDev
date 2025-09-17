//
//  BodyView.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/17/25.
//

import SwiftUI

struct BodyView: View {
    let width: CGFloat
    let height: CGFloat
    let layoutConstants: GlobalLayoutConstants
    let orientation: AppOrientation
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            // Background for body
            Color.clear
            
            // Game Board
            GameBoard(
                bodyWidth: width,
                bodyHeight: height,
                layoutConstants: layoutConstants,
                orientation: orientation
            )
        }
        .frame(width: width, height: height)
    }
}

#Preview {
    GeometryReader { geometry in
        let deviceType = DeviceType.current
        let orientation = AppOrientation.current(geometry: geometry)
        let layoutConstants = GlobalLayoutConstants.current(for: deviceType, orientation: orientation)
        let bodyHeight = layoutConstants.bodyHeightValue(geometry.size.height)
        let bodyWidth = layoutConstants.bodyWidthValue(geometry.size.width)
        
        BodyView(
            width: bodyWidth,
            height: bodyHeight,
            layoutConstants: layoutConstants,
            orientation: orientation,
            geometry: geometry
        )
    }
    .background(Color(hex: "B7E4CC"))
}
