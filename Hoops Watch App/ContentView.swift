//
//  ContentView.swift
//  Hoops Watch App
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI

struct ContentView: View {
    
    @State var hapticsTrigger = 0
    
    var body: some View {
        
        NavigationStack {
            Image(systemName: "basketball.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.orange)
                .padding(.bottom, 20)
            
            NavigationLink(destination: ShotSelection()) {
                Text("New Session")
            }.simultaneousGesture(TapGesture().onEnded{
                hapticsTrigger += 1
            })
            .sensoryFeedback(.selection, trigger: hapticsTrigger)
            .tint(.green)
        }
        
        
    }
}

#Preview {
    ContentView()
}
