//
//  ContentView.swift
//  Hoops Watch App
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                
                Text("hoops.")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
                
                // MARK: New Session Button
                NavigationLink(destination: SessionSelection()) {
                    Text("New Session")
                }.simultaneousGesture(TapGesture().onEnded{
                    WKInterfaceDevice.current().play(.click)
                })
                .tint(.green)
                
                // MARK: Basketball
                Image(systemName: "basketball.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                    .foregroundStyle(.orange.opacity(0.75))
                    .padding(.top, 5)
            }
            .offset(y: 95)
        }
    }
}

#Preview {
    ContentView()
}
