//
//  Profile.swift
//  Hoops
//
//  Created by Landon West on 2/5/25.
//

import SwiftUI

struct Profile: View {
    var body: some View {
        ZStack {
            Image(.jersey)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 225)
            
            VStack(spacing: 5) {
                ResizableTextView(text: "west")
                
                Text("0")
                    .font(.system(size: 90))
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .padding(.top, 5)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
            
    }
}

struct ResizableTextView: View {
    let text: String
    let maxFontSize: CGFloat = 40 // Set your max font size

    var body: some View {
        GeometryReader { geometry in
            Text(text.uppercased())
                .font(.system(size: min(maxFontSize, geometry.size.width * 0.8))) // Scales dynamically
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .lineLimit(1)
                .minimumScaleFactor(0.01) // Allows shrinking but within limits
        }
        .frame(width: 95, height: 30) // Fixed width and height
    }
}

#Preview {
    Profile()
}
