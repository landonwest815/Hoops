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
            // MARK: Basketball
                Image(systemName: "basketball.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.orange)
                    .padding(.bottom, 20)
            
            // MARK: New Session Button
                NavigationLink(destination: ShotSelection()) {
                    Text("New Session")
                }.simultaneousGesture(TapGesture().onEnded{
                    WKInterfaceDevice.current().play(.click)
                })
                .tint(.green)
        }
    }
}

#Preview {
    ContentView()
}
