//
//  GameGridElement.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/17/25.
//

import SwiftUI

struct GameGridElement: View {
    let position: Int
    let width: CGFloat
    let height: CGFloat
    let orientation: AppOrientation
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white)
                .stroke(Color.black.opacity(0.3), lineWidth: 1)
            
            // Position number for debugging
            Text("\(position)")
                .font(.caption2)
                .foregroundColor(.black.opacity(0.7))
        }
        .frame(width: width, height: height)
        // No rotation here - the entire grid will be rotated instead
    }
}

#Preview("Portrait") {
    GameGridElement(
        position: 42,
        width: 30,
        height: 45,
        orientation: .portrait
    )
    .padding()
}

#Preview("Landscape") {
    GameGridElement(
        position: 42,
        width: 30,
        height: 45,
        orientation: .landscape
    )
    .padding()
}
