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
            Image(systemName: "basketball.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.orange)
                .padding(.bottom, 20)
            
            NavigationLink(destination: ShotSelection()) {
                Text("New Session")
            }
            .tint(.green)
        }
        
        
    }
}

#Preview {
    ContentView()
}
