//
//  HeaderView.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/17/25.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        ZStack {
            // Use a subtle material to stand out against the background
            Color.clear.background(.ultraThinMaterial)
            HStack{
                Text("Left")
                Spacer()
            }
            
            HStack(alignment: .center){
                Text("Fiva")
                    .font(.title2.bold())
                    .bold()
                    .foregroundStyle(.primary)
            }
            HStack{
                Spacer()
                Text("Right")
            }//            HStack {
//                Text("Fiva")
//                    .font(.largeTitle)
//                    .bold()
//                    
//                    .foregroundStyle(.primary)
//                Spacer()
//                Text("Header Content")
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    HeaderView()
        .frame(height: 80)
        .background(Color(hex: "B7E4CC"))
}
