//
//  HeaderView.swift
//  FivaDev
//
//  Cross-platform header view with fixed app icon loading
//  Updated: September 29, 2025, 12:30 PM PDT
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        ZStack {
            // Use a subtle material to stand out against the background
            Color.clear.background(.ultraThinMaterial)
            
            HStack{
                // Restart icon with palette rendering
                Image(systemName: "repeat")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.red, .blue)
                    .font(.largeTitle)
                    .padding(.leading, 18)
                Image(systemName: "speaker.slash")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.red, .blue)
                    .font(.largeTitle)
                    .padding(.leading, 18)
                Spacer()
            }
            
            // Centered app icon and title
            HStack(alignment: .center, spacing: 12) {
                // App Icon - Cross-platform approach using iconImage
                Group {
                    if let appIconImage = Bundle.main.iconImage {
                        appIconImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        // Fallback if app icon can't be loaded
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.secondary)
                            .overlay(
                                Text("F")
                                    .font(.title2.bold())
                                    .foregroundStyle(.primary)
                            )
                    }
                }
                .frame(width: 32, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // App Title
                Text("Fiva")
                    .font(.title.bold())
                    .bold()
                    .foregroundStyle(.primary)
            }
            
            HStack{
                Spacer()
                // Help icon with palette rendering
                Image(systemName: "questionmark.circle")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.red, .blue)
                    .font(.largeTitle)
//                    .padding(.trailing)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    HeaderView()
        .frame(height: 80)
        .background(Color(hex: "B7E4CC"))
//        .background(Color(hex: "ff9300"))
}
